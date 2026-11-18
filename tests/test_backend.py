import types

import backend
import backend.db


def as_event(data):
    """QML hands list model items to python as objects with attributes."""
    return types.SimpleNamespace(**data)


def test_file_exists(data_dir, schedule):
    assert backend.file_exists()


def test_file_missing(data_dir):
    assert not backend.file_exists()


def test_tracks_by_day(schedule):
    assert backend.find_tracks_by_day("2025-02-01") == [
        {"title": "Keynotes"},
        {"title": "Python"},
    ]
    assert backend.find_tracks_by_day("2025-02-02") == [{"title": "Keynotes"}]


def test_events_by_day_track(schedule):
    events = backend.find_events_by_day_track("2025-02-01", "Python")
    assert [e["id"] for e in events] == [200, 201]
    first = events[0]
    assert first["day"] == "2025-02-01"
    assert first["start"] == "10:00"
    assert first["end"] == "10:30"
    assert first["room"] == "UB2.252A (Lameere)"
    assert first["title"] == "Python typing in practice"
    assert first["track"] == "Python"
    assert first["persons"] == "Alice Pythonista"
    assert first["lecture_checked"] is False


def test_event_fields(schedule):
    events = backend.find_events_by_day_track("2025-02-01", "Keynotes")
    welcome = events[0]
    assert welcome["id"] == 100
    assert welcome["persons"] == "FOSDEM Staff, Jane Speaker"
    assert welcome["abstract"] == "<p>FOSDEM welcome and opening talk.</p>"
    assert welcome["subtitle"] == ""
    assert welcome["end"] == "09:50"


def test_toggle_marks_and_unmarks(schedule):
    event = backend.find_events_by_day_track("2025-02-01", "Python")[0]

    assert backend.toggle(as_event(event)) is True
    assert backend.select_ids() == [200]
    marked = backend.find_events_by_day_track("2025-02-01", "Python")
    assert [e["lecture_checked"] for e in marked] == [True, False]

    assert backend.toggle(as_event(event)) is False
    assert backend.select_ids() == []


def test_select_all_ordered_by_start(schedule):
    py = backend.find_events_by_day_track("2025-02-01", "Python")
    keynotes = backend.find_events_by_day_track("2025-02-01", "Keynotes")
    for event in (py[1], keynotes[0]):
        backend.toggle(as_event(event))

    rows = backend.select_all()
    assert [r["id"] for r in rows] == [100, 201]
    assert rows[0]["title"] == "Welcome to FOSDEM 2025"


def test_download_keeps_favorites(schedule, tmp_path):
    for track in ("Python", "Keynotes"):
        backend.toggle(as_event(backend.find_events_by_day_track("2025-02-01", track)[0]))
    update = tmp_path / "update.xml"
    text = schedule.read_text()
    start = text.index('<event guid="g-100"')
    end = text.index("</event>", start) + len("</event>")
    update.write_text(text[:start] + text[end:].replace("UB2.252A (Lameere)", "K.3.201"))

    assert backend.download_file(update.resolve().as_uri()) == ""

    assert backend.select_ids() == [100, 200]
    favorites = backend.select_all()
    assert [(f["id"], f["room"], f["removed"]) for f in favorites] == [
        (100, "Janson", True),
        (200, "K.3.201", False),
    ]
    removed = favorites[0]
    assert removed["title"] == "Welcome to FOSDEM 2025"
    assert (removed["day"], removed["start"], removed["end"]) == ("2025-02-01", "09:30", "09:50")
    assert removed["lecture_checked"] is True
    assert set(removed) == set(favorites[1])


def test_fake_download(data_dir, pyotherside):
    assert backend.download_file("fake") == ""
    assert backend.file_exists()
    assert pyotherside.sent[-1] == ("on-progress", 100)
