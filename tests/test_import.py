import sqlite3

import backend
import backend.db
from conftest import DATA


def rows(data_dir, sql):
    con = sqlite3.connect(str(data_dir / "saved.db"))
    try:
        return con.execute(sql).fetchall()
    finally:
        con.close()


def test_days(schedule):
    assert backend.get_days() == [{"date": "2025-02-01"}, {"date": "2025-02-02"}]


def test_no_schedule(data_dir):
    assert backend.get_days() == []
    assert backend.find_tracks_by_day("2025-02-01") == []
    assert backend.get_current_lectures() == []
    assert backend.select_all() == []


def test_import_stores_everything(schedule, data_dir):
    backend.get_days()

    assert rows(data_dir, "SELECT count(*) FROM schedule_events") == [(5,)]
    assert rows(data_dir, "SELECT url, feedback_url, type, language FROM schedule_events WHERE id=100") == [(
        "https://fosdem.org/2025/schedule/event/fosdem-2025-100-welcome/",
        "https://pretalx.fosdem.org/fosdem-2025/talk/AAA/feedback/",
        "keynote", "en")]
    assert rows(data_dir, "SELECT kind, title, href FROM schedule_links WHERE event_id=100 ORDER BY position") == [
        ("attachment", "Talk slides", "https://fosdem.org/2025/events/attachments/100/slides.pdf"),
        ("link", "Video recording (MP4)", "https://video.fosdem.org/2025/janson/fosdem-2025-100-welcome.mp4"),
        ("link", "Chat room(web)", "https://chat.fosdem.org/#/room/#2025-keynote:fosdem.org"),
        ("link", "Submit Feedback", "https://pretalx.fosdem.org/fosdem-2025/talk/AAA/feedback/"),
    ]
    assert dict(rows(data_dir, "SELECT key, value FROM schedule_meta WHERE key IN ('title', 'time_zone_name')")) == {
        "title": "FOSDEM 2025", "time_zone_name": "Europe/Brussels"}


def test_xml_parsed_once(schedule, monkeypatch):
    backend.get_days()

    def fail(*args, **kwargs):
        raise AssertionError("schedule parsed again")

    monkeypatch.setattr(backend.ET, "parse", fail)
    assert len(backend.find_events_by_day_track("2025-02-01", "Keynotes")) == 2
    assert backend.find_tracks_by_day("2025-02-02") == [{"title": "Keynotes"}]
    backend.get_current_lectures()
    backend.select_all()


def test_reimport_when_file_changes(schedule):
    assert backend.find_events_by_day_track("2025-02-02", "Keynotes")[0]["title"] == "Closing FOSDEM 2025"

    schedule.write_text(schedule.read_text().replace("Closing FOSDEM 2025", "Goodbye"))
    assert backend.find_events_by_day_track("2025-02-02", "Keynotes")[0]["title"] == "Goodbye"


def test_download_imports(data_dir, tmp_path):
    source = tmp_path / "s.xml"
    source.write_text((DATA / "small.xml").read_text())
    assert backend.download_file(source.resolve().as_uri()) == ""
    assert rows(data_dir, "SELECT count(*) FROM schedule_events") == [(5,)]

