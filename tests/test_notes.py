import datetime

import backend
import backend.db

UTC = datetime.timezone.utc


def at(hour, minute=0, day=1):
    return datetime.datetime(2025, 2, day, hour, minute, tzinfo=UTC)


def test_note_without_talk(schedule):
    note_id = backend.save_note(0, "Met the Lomiri folks at the booth", now=at(11))

    [note] = backend.list_notes()
    assert note["id"] == note_id
    assert note["text"] == "Met the Lomiri folks at the booth"
    assert note["event_id"] == 0
    assert note["talk_title"] == ""


def test_note_linked_to_talk_that_is_no_favorite(schedule):
    assert backend.select_ids() == []
    backend.save_note(0, "asyncio slides: use TaskGroup", event_id=201, now=at(9, 40))

    [note] = backend.list_notes()
    assert note["event_id"] == 201
    assert note["talk_title"] == "asyncio deep dive"
    assert (note["talk_day"], note["talk_start"], note["talk_room"]) == (
        "2025-02-01", "10:30", "UB2.252A (Lameere)")
    assert [n["id"] for n in backend.notes_for_event(201)] == [note["id"]]
    assert backend.notes_for_event(200) == []


def test_edit_keeps_creation_time(schedule):
    note_id = backend.save_note(0, "first", now=at(9))
    assert backend.save_note(note_id, "second", now=at(10)) == note_id

    [note] = backend.list_notes()
    assert note["text"] == "second"
    assert note["created_at"] < note["updated_at"]


def test_empty_note_is_discarded(schedule):
    assert backend.save_note(0, "   \n", now=at(9)) == 0
    assert backend.list_notes() == []

    note_id = backend.save_note(0, "something", now=at(9))
    assert backend.save_note(note_id, "", now=at(10)) == 0
    assert backend.list_notes() == []


def test_delete(schedule):
    keep = backend.save_note(0, "keep", now=at(9))
    gone = backend.save_note(0, "gone", now=at(10))
    backend.delete_note(gone)

    assert [n["id"] for n in backend.list_notes()] == [keep]


def test_newest_first_with_local_day(schedule):
    backend.save_note(0, "saturday", now=at(9, day=1))
    backend.save_note(0, "sunday early", now=at(9, day=2))
    backend.save_note(0, "sunday late", now=at(15, day=2))

    notes = backend.list_notes()
    assert [n["text"] for n in notes] == ["sunday late", "sunday early", "saturday"]
    local = at(15, day=2).astimezone()
    assert (notes[0]["day"], notes[0]["time"]) == (local.strftime("%Y-%m-%d"), local.strftime("%H:%M"))


def test_note_survives_new_schedule_without_its_talk(schedule, tmp_path):
    backend.save_note(0, "welcome notes", event_id=100, now=at(9))
    update = tmp_path / "update.xml"
    text = schedule.read_text()
    start = text.index('<event guid="g-100"')
    end = text.index("</event>", start) + len("</event>")
    update.write_text(text[:start] + text[end:])
    assert backend.download_file(update.resolve().as_uri()) == ""

    [note] = backend.list_notes()
    assert note["text"] == "welcome notes"
    assert note["talk_title"] == "Welcome to FOSDEM 2025"


def test_unknown_talk_is_not_linked(schedule):
    backend.save_note(0, "typo id", event_id=999, now=at(9))

    [note] = backend.list_notes()
    assert (note["event_id"], note["talk_title"]) == (0, "")


def test_existing_database_gets_notes_table(schedule):
    backend.select_ids()  # database with the current schema minus notes
    with backend.db.connect() as con:
        con.execute("DROP TABLE notes")
        con.execute("PRAGMA user_version = 2")

    backend.save_note(0, "after upgrade", now=at(9))
    assert [n["text"] for n in backend.list_notes()] == ["after upgrade"]


def test_one_note_per_talk_text_is_appended(schedule):
    first = backend.save_note(0, "first idea", event_id=201, now=at(9, 35))
    second = backend.save_note(0, "second idea", event_id=201, now=at(9, 50))

    assert second == first
    [note] = backend.notes_for_event(201)
    assert note["text"] == "first idea\nsecond idea"
    assert len(backend.list_notes()) == 1


def test_free_notes_stay_separate(schedule):
    backend.save_note(0, "one", now=at(9))
    backend.save_note(0, "two", now=at(10))

    assert len(backend.list_notes()) == 2
