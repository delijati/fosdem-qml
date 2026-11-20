import types

import backend
from conftest import event_xml


def ids(query):
    return [e["id"] for e in backend.search(query)]


def test_by_speaker(schedule):
    assert ids("pythonista") == [200, 201]


def test_by_title_word(schedule):
    assert ids("asyncio") == [201]


def test_by_subtitle_and_abstract(schedule):
    assert ids("Sub 101") == [101]
    assert ids("event loops") == [201]


def test_all_words_must_match(schedule):
    assert ids("alice async") == [201]
    assert ids("alice keynote") == []


def test_all_days(schedule):
    assert ids("fosdem 2025") == [100, 400]


def test_empty_query(schedule):
    assert ids("") == []
    assert ids("   ") == []


def test_no_schedule(data_dir):
    assert ids("python") == []


def test_case_and_umlauts(write_schedule):
    write_schedule({"2025-02-01": {"K.1.105": [
        event_xml(1, title="Über Größen"),
        event_xml(2, title="STRASSE"),
    ]}})

    assert ids("über") == [1]
    assert ids("GRÖSSEN") == [1]
    assert ids("straße") == [2]


def test_marks_favorites(schedule):
    backend.toggle(types.SimpleNamespace(**backend.find_events_by_day_track("2025-02-01", "Python")[1]))

    assert [e["lecture_checked"] for e in backend.search("pythonista")] == [False, True]
