import datetime
import types

import backend
from conftest import event_xml

UTC = datetime.timezone.utc


def utc(*args):
    return datetime.datetime(*args, tzinfo=UTC)


def running_ids(now, **kwargs):
    return sorted(e["id"] for e in backend.get_current_lectures(now=now, **kwargs))


def test_uses_conference_offset_not_device_time(write_schedule):
    # 10:00-11:00 Brussels (UTC+1) is 09:00-10:00 UTC, whatever the phone's zone.
    write_schedule({"2025-02-01": {"Janson": [
        event_xml(1, start="10:00", duration="01:00",
                  date="2025-02-01T10:00:00+01:00"),
    ]}})

    assert running_ids(utc(2025, 2, 1, 9, 30)) == [1]
    assert running_ids(utc(2025, 2, 1, 10, 30)) == []
    tokyo = datetime.timezone(datetime.timedelta(hours=9))
    assert running_ids(datetime.datetime(2025, 2, 1, 18, 30, tzinfo=tokyo)) == [1]


def test_utc_date_with_z_suffix(write_schedule):
    write_schedule({"2025-02-01": {"Janson": [
        event_xml(1, start="10:00", duration="01:00", date="2025-02-01T09:00:00Z"),
    ]}})

    assert running_ids(utc(2025, 2, 1, 9, 30)) == [1]


def test_event_times_keep_offset(write_schedule):
    write_schedule({"2025-02-01": {"Janson": [
        event_xml(1, start="10:00", duration="01:00",
                  date="2025-02-01T10:00:00+01:00"),
    ]}})

    event = backend.find_events_by_day_track("2025-02-01", "Python")[0]
    assert event["datetime_start"] == utc(2025, 2, 1, 9, 0)
    assert event["datetime_end"] == utc(2025, 2, 1, 10, 0)
    assert (event["start"], event["end"]) == ("10:00", "11:00")


def test_without_date_falls_back_to_device_time(write_schedule):
    write_schedule({"2025-02-01": {"Janson": [
        event_xml(1, start="10:00", duration="01:00"),
    ]}})

    local_now = datetime.datetime(2025, 2, 1, 10, 30).astimezone()
    assert running_ids(local_now) == [1]


def test_show_only_marked(schedule):
    now = utc(2025, 2, 1, 9, 15)
    assert running_ids(now) == [101, 200]

    event = backend.find_events_by_day_track("2025-02-01", "Python")[0]
    backend.db.insert(types.SimpleNamespace(**event))
    assert running_ids(now, show_only_marked=True) == [200]


def test_fake_schedule_running_talks(data_dir):
    for hour, minute in ((12, 0), (0, 5)):
        now = datetime.datetime(2025, 2, 2, hour, minute).astimezone()
        backend.utils.generate_fake_data(now=now)
        assert running_ids(now) == [1002, 1003], now


def now_next(now, **kwargs):
    return [(e["id"], e["group"], e["minutes"])
            for e in backend.get_now_and_next(now=now, **kwargs)]


def test_now_and_next(schedule):
    # 09:15 UTC = 10:15 Brussels: 101 and 200 running, 201 starts 10:30
    assert now_next(utc(2025, 2, 1, 9, 15)) == [
        (200, "now", 15),
        (101, "now", 35),
        (201, "next", 15),
    ]


def test_next_window(schedule):
    # 08:00 Brussels: welcome at 09:30 is 90 min away
    assert now_next(utc(2025, 2, 1, 7, 0)) == []
    assert now_next(utc(2025, 2, 1, 7, 0), window_min=100) == [(100, "next", 90)]


def test_minutes_round_up(schedule):
    # 10:14:30 Brussels: 200 ends 10:30 -> 15.5 min -> "15" would be too early
    assert now_next(utc(2025, 2, 1, 9, 14, 30))[0] == (200, "now", 16)


def test_now_and_next_only_marked(schedule):
    event = backend.find_events_by_day_track("2025-02-01", "Python")[1]
    backend.toggle(types.SimpleNamespace(**event))

    assert now_next(utc(2025, 2, 1, 9, 15), show_only_marked=True) == [(201, "next", 15)]


def test_fake_schedule_now_and_next(data_dir):
    now = datetime.datetime(2025, 2, 1, 12, 0).astimezone()
    backend.utils.generate_fake_data(now=now)

    assert now_next(now) == [
        (1002, "now", 30), (1003, "now", 60),
        (2002, "next", 15), (1004, "next", 30), (3002, "next", 45),
    ]
