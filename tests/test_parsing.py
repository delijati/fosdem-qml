import datetime

import backend
from conftest import event_xml


def test_track_name_with_quote(write_schedule):
    write_schedule({"2025-02-01": {"K.1.105": [
        event_xml(1, track="Children's track"),
        event_xml(2, track='The "Quoted" Track'),
        event_xml(3, track="Python"),
    ]}})

    assert backend.find_tracks_by_day("2025-02-01") == [
        {"title": "Children's track"},
        {"title": "Python"},
        {"title": 'The "Quoted" Track'},
    ]
    events = backend.find_events_by_day_track("2025-02-01", "Children's track")
    assert [e["id"] for e in events] == [1]
    events = backend.find_events_by_day_track("2025-02-01", 'The "Quoted" Track')
    assert [e["id"] for e in events] == [2]


def test_events_without_track(write_schedule):
    write_schedule({"2025-02-01": {"K.1.105": [
        event_xml(1, track=None),
        event_xml(2, track=""),
        event_xml(3, track="Python"),
    ]}})

    assert backend.find_tracks_by_day("2025-02-01") == [
        {"title": ""},
        {"title": "Python"},
    ]
    events = backend.find_events_by_day_track("2025-02-01", "")
    assert [e["id"] for e in events] == [1, 2]
    assert [e["track"] for e in events] == ["", ""]


def test_empty_elements_are_empty_strings(write_schedule):
    write_schedule({"2025-02-01": {"K.1.105": [
        event_xml(1, extra="<subtitle></subtitle><abstract/><persons/>"),
    ]}})

    event = backend.find_events_by_day_track("2025-02-01", "Python")[0]
    for key in ("subtitle", "abstract", "description", "persons"):
        assert event[key] == "", key


def test_end_after_midnight(write_schedule):
    write_schedule({"2025-02-01": {"K.1.105": [
        event_xml(1, start="23:30", duration="01:00"),
    ]}})

    event = backend.find_events_by_day_track("2025-02-01", "Python")[0]
    assert event["end"] == "00:30"
    assert event["datetime_end"] - event["datetime_start"] == datetime.timedelta(hours=1)


def test_long_duration(write_schedule):
    write_schedule({"2025-02-01": {"K.1.105": [
        event_xml(1, start="09:00", duration="08:15"),
    ]}})

    event = backend.find_events_by_day_track("2025-02-01", "Python")[0]
    assert event["end"] == "17:15"
