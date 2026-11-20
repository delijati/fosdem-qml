import datetime
import types

import backend
import backend.utils
from conftest import event_xml


def mark(*event_ids):
    for event in backend.select_events():
        if event["id"] in event_ids:
            backend.toggle(types.SimpleNamespace(**event))


def clashes():
    return {e["id"]: e["clash_titles"] for e in backend.select_all()}


def test_overlapping_favorites_flagged(schedule):
    # 101 Janson 10:00-10:50, 200 10:00-10:30, 201 10:30-11:00
    mark(101, 200, 201)

    assert clashes() == {
        101: "Python typing in practice, asyncio deep dive",
        200: "Program to Learn: The Power of Creative Coding",
        201: "Program to Learn: The Power of Creative Coding",
    }


def test_back_to_back_is_no_clash(schedule):
    # 200 ends 10:30, 201 starts 10:30
    mark(200, 201)

    assert clashes() == {200: "", 201: ""}


def test_only_favorites_count(schedule):
    mark(200)

    assert clashes() == {200: ""}


def test_other_day_is_no_clash(write_schedule):
    write_schedule({
        "2025-02-01": {"A": [event_xml(1, start="10:00")]},
        "2025-02-02": {"A": [event_xml(2, start="10:00")]},
    })
    mark(1, 2)

    assert clashes() == {1: "", 2: ""}


def test_removed_favorite_is_no_clash(schedule, tmp_path):
    mark(100, 101)
    text = schedule.read_text()
    start = text.index('<event guid="g-101"')
    end = text.index("</event>", start) + len("</event>")
    update = tmp_path / "update.xml"
    update.write_text(text[:start] + text[end:])
    assert backend.download_file(update.resolve().as_uri()) == ""

    assert clashes() == {100: "", 101: ""}


def test_fake_schedule_shows_agenda(data_dir):
    now = datetime.datetime(2025, 2, 1, 12, 0).astimezone()
    backend.utils.generate_fake_data(now=now)
    backend.mark_fake_favorites()

    agenda = backend.select_all()
    days = sorted({e["day"] for e in agenda})
    assert days == ["2025-02-01", "2025-02-02"]
    clashing = {e["id"] for e in agenda if e["clash_titles"]}
    assert {1002, 1003, 4001, 4002} <= clashing
    assert {e["id"] for e in agenda} - clashing, "some favorites without overlap"


def test_fake_download_marks_favorites(data_dir):
    assert backend.download_file("fake") == ""

    assert backend.select_ids() == sorted(backend.FAKE_FAVORITES)
