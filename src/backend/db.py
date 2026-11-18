import contextlib
import datetime
import sqlite3

from backend.config import DB_FILE
from backend.utils import create_path


SCHEMA_VERSION = 2

CREATE_FAVORITES = """
CREATE TABLE IF NOT EXISTS favorites (
    event_id INTEGER PRIMARY KEY,
    added_at TEXT NOT NULL,
    day TEXT,
    start TEXT,
    end TEXT,
    room TEXT,
    title TEXT
)"""

CREATE_SCHEDULE = [
    """CREATE TABLE schedule_events (
        id INTEGER PRIMARY KEY,
        day TEXT NOT NULL,
        start TEXT NOT NULL,
        end TEXT NOT NULL,
        datetime_start TEXT NOT NULL,
        datetime_end TEXT NOT NULL,
        room TEXT NOT NULL,
        track TEXT NOT NULL,
        title TEXT NOT NULL,
        subtitle TEXT NOT NULL,
        abstract TEXT NOT NULL,
        description TEXT NOT NULL,
        persons TEXT NOT NULL,
        url TEXT NOT NULL,
        feedback_url TEXT NOT NULL,
        type TEXT NOT NULL,
        language TEXT NOT NULL
    )""",
    "CREATE INDEX schedule_events_day_track ON schedule_events (day, track)",
    """CREATE TABLE schedule_links (
        event_id INTEGER NOT NULL,
        position INTEGER NOT NULL,
        kind TEXT NOT NULL,
        title TEXT NOT NULL,
        href TEXT NOT NULL,
        PRIMARY KEY (event_id, position)
    )""",
    "CREATE TABLE schedule_meta (key TEXT PRIMARY KEY, value TEXT NOT NULL)",
]

EVENT_COLUMNS = [
    "id", "day", "start", "end", "datetime_start", "datetime_end", "room",
    "track", "title", "subtitle", "abstract", "description", "persons", "url",
    "feedback_url", "type", "language",
]

EVENT_ORDER = "ORDER BY e.datetime_start, e.room, e.id"

# Up to 0.8.0 favorites were full copies of the event in a table "events".
MIGRATE_LEGACY_EVENTS = """
INSERT OR IGNORE INTO favorites (event_id, added_at, day, start, end, room, title)
SELECT id, :now, day, start, end, room, title FROM events"""

INSERT_FAVORITE = """
INSERT OR REPLACE INTO favorites (event_id, added_at, day, start, end, room, title)
VALUES (:event_id, :added_at, :day, :start, :end, :room, :title)"""


def now_iso():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()


def table_exists(con, name):
    row = con.execute(
        "SELECT 1 FROM sqlite_master WHERE type='table' AND name=?", (name,)).fetchone()
    return row is not None


def migrate(con):
    version = con.execute("PRAGMA user_version").fetchone()[0]
    if version >= SCHEMA_VERSION:
        return
    if version < 1:
        con.execute(CREATE_FAVORITES)
        if table_exists(con, "events"):
            con.execute(MIGRATE_LEGACY_EVENTS, {"now": now_iso()})
            con.execute("DROP TABLE events")
    if version < 2:
        for sql in CREATE_SCHEDULE:
            con.execute(sql)
    con.execute("PRAGMA user_version = %d" % SCHEMA_VERSION)


@contextlib.contextmanager
def connect():
    """Connection with the current schema; commits on success, always closes."""
    create_path(DB_FILE)
    con = sqlite3.connect(DB_FILE)
    try:
        with con:
            migrate(con)
            yield con
    finally:
        con.close()


def insert(event, con=None):
    if con is None:
        with connect() as con:
            return insert(event, con)
    con.execute(INSERT_FAVORITE, dict(
        event_id=int(event.id),
        added_at=now_iso(),
        day=event.day,
        start=event.start,
        end=event.end,
        room=event.room,
        title=event.title,
    ))


def toggle(event):
    """Mark or unmark a favorite; returns True if it is marked now."""
    with connect() as con:
        event_id = int(event.id)
        row = con.execute(
            "SELECT 1 FROM favorites WHERE event_id=?", (event_id,)).fetchone()
        if row:
            con.execute("DELETE FROM favorites WHERE event_id=?", (event_id,))
            return False
        insert(event, con)
        return True


def select_ids():
    with connect() as con:
        rows = con.execute("SELECT event_id FROM favorites ORDER BY event_id")
        return [r[0] for r in rows]


def replace_schedule(meta, events, links):
    """Replace the stored schedule in one transaction.

    meta: {key: value}, events: dicts with EVENT_COLUMNS,
    links: (event_id, position, kind, title, href) tuples.
    """
    with connect() as con:
        con.execute("DELETE FROM schedule_events")
        con.execute("DELETE FROM schedule_links")
        con.execute("DELETE FROM schedule_meta")
        con.executemany(
            "INSERT OR REPLACE INTO schedule_events (%s) VALUES (%s)" % (
                ", ".join(EVENT_COLUMNS), ", ".join(":" + c for c in EVENT_COLUMNS)),
            events)
        con.executemany(
            "INSERT OR REPLACE INTO schedule_links VALUES (?, ?, ?, ?, ?)", links)
        con.executemany(
            "INSERT INTO schedule_meta VALUES (?, ?)", sorted(meta.items()))


def get_meta(key):
    with connect() as con:
        row = con.execute("SELECT value FROM schedule_meta WHERE key=?", (key,)).fetchone()
        return row[0] if row else None


def select_days():
    with connect() as con:
        rows = con.execute("SELECT DISTINCT day FROM schedule_events ORDER BY day")
        return [r[0] for r in rows]


def select_tracks(day):
    with connect() as con:
        rows = con.execute(
            "SELECT DISTINCT track FROM schedule_events WHERE day=? ORDER BY track", (day,))
        return [r[0] for r in rows]


def select_events(where="1", params=(), favorites_only=False):
    """Event dicts plus "lecture_checked", in start order."""
    join = "JOIN" if favorites_only else "LEFT JOIN"
    sql = """
        SELECT e.*, f.event_id IS NOT NULL AS lecture_checked
        FROM schedule_events e %s favorites f ON f.event_id = e.id
        WHERE %s %s""" % (join, where, EVENT_ORDER)
    with connect() as con:
        con.row_factory = sqlite3.Row
        return [dict(r) for r in con.execute(sql, params)]


def select_removed_favorites():
    """Favorites whose event is no longer in the schedule (snapshot data)."""
    with connect() as con:
        con.row_factory = sqlite3.Row
        rows = con.execute("""
            SELECT f.event_id AS id, f.day, f.start, f.end, f.room, f.title
            FROM favorites f LEFT JOIN schedule_events e ON e.id = f.event_id
            WHERE e.id IS NULL""")
        return [dict(r) for r in rows]
