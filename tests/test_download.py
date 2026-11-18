from pathlib import Path

import backend
from conftest import DATA


def file_url(path):
    return Path(path).resolve().as_uri()


def test_valid_schedule_replaces_old(schedule, tmp_path, pyotherside):
    new = tmp_path / "new.xml"
    new.write_text(
        (DATA / "small.xml").read_text().replace("Closing FOSDEM 2025", "Bye"))

    assert backend.download_file(file_url(new)) == ""
    assert "Bye" in schedule.read_text()
    assert pyotherside.sent[-1] == ("on-progress", 100)
    assert list(schedule.parent.glob("*.part")) == []


def test_broken_xml_keeps_old_schedule(schedule, tmp_path):
    old = schedule.read_text()
    broken = tmp_path / "broken.xml"
    broken.write_text(old[: len(old) // 2])

    error = backend.download_file(file_url(broken))
    assert error
    assert schedule.read_text() == old
    assert list(schedule.parent.glob("*.part")) == []


def test_not_a_schedule_keeps_old_schedule(schedule, tmp_path):
    old = schedule.read_text()
    html = tmp_path / "page.html"
    html.write_text("<html><body>Not found</body></html>")

    assert "schedule" in backend.download_file(file_url(html))
    assert schedule.read_text() == old


def test_unreachable_url_returns_error(schedule, tmp_path):
    old = schedule.read_text()

    assert backend.download_file(file_url(tmp_path / "missing.xml"))
    assert schedule.read_text() == old


def test_first_download_without_old_schedule(data_dir):
    assert backend.download_file(file_url(DATA / "small.xml")) == ""
    assert backend.file_exists()
