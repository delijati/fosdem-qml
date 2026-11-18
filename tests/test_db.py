import sqlite3
import types

import backend
import backend.db

LEGACY_TABLE = """
CREATE TABLE events (
    id INT, day TEXT, start TEXT, datetime_start TIMESTAMP, end TEXT,
    datetime_end TIMESTAMP, room TEXT, title TEXT, subtitle TEXT,
    abstract TEXT, description TEXT, persons TEXT, lecture_checked BOOL
)"""


def legacy_db(path, rows):
    con = sqlite3.connect(str(path))
    con.execute(LEGACY_TABLE)
    for event_id, day, start, room, title in rows:
        con.execute(
            "INSERT INTO events VALUES (?, ?, ?, ?, '', '', ?, ?, '', '', '', '', 1)",
            (event_id, day, start, day + " " + start + ":00", room, title))
    con.commit()
    con.close()


def tables(path):
    con = sqlite3.connect(str(path))
    names = [r[0] for r in con.execute("SELECT name FROM sqlite_master WHERE type='table'")]
    con.close()
    return sorted(names)


def test_migrates_legacy_favorites(schedule, data_dir):
    legacy_db(data_dir / "saved.db", [
        (200, "2025-02-01", "10:00", "UB2.252A (Lameere)", "Python typing in practice"),
        (100, "2025-02-01", "09:30", "Janson", "Welcome to FOSDEM 2025"),
    ])

    assert backend.select_ids() == [100, 200]
    assert "events" not in tables(data_dir / "saved.db")
    assert [r["id"] for r in backend.select_all()] == [100, 200]


def test_migration_runs_once(schedule, data_dir):
    legacy_db(data_dir / "saved.db", [(100, "2025-02-01", "09:30", "Janson", "Welcome")])
    backend.select_ids()
    backend.toggle(types.SimpleNamespace(**backend.find_events_by_day_track("2025-02-01", "Keynotes")[0]))

    assert backend.select_ids() == []


def test_toggle_twice_keeps_one_row(schedule, data_dir):
    event = types.SimpleNamespace(**backend.find_events_by_day_track("2025-02-01", "Python")[0])
    backend.toggle(event)
    backend.db.insert(event)

    assert backend.select_ids() == [200]


def test_favorites_show_current_schedule_data(schedule, data_dir):
    event = types.SimpleNamespace(**backend.find_events_by_day_track("2025-02-01", "Python")[0])
    backend.toggle(event)
    schedule.write_text(schedule.read_text().replace(
        "<room>UB2.252A (Lameere)</room>", "<room>K.3.201</room>").replace(
        '<room name="UB2.252A (Lameere)"', '<room name="K.3.201"'))

    assert backend.select_all()[0]["room"] == "K.3.201"


def test_connections_are_closed(schedule, data_dir, monkeypatch):
    opened = []
    real_connect = sqlite3.connect

    class Tracking(sqlite3.Connection):
        def close(self):
            opened.remove(self)
            super().close()

    def connect(*args, **kwargs):
        con = real_connect(*args, factory=Tracking, **kwargs)
        opened.append(con)
        return con

    monkeypatch.setattr(backend.db.sqlite3, "connect", connect)
    event = types.SimpleNamespace(**backend.find_events_by_day_track("2025-02-01", "Python")[0])
    backend.toggle(event)
    backend.toggle(event)
    backend.select_ids()
    backend.select_all()

    assert opened == []
