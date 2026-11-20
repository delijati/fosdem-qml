import contextlib
import datetime
import sqlite3

from backend.config import DB_FILE
from backend.utils import create_path


SCHEMA_VERSION = 3

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

# A note may link to a talk; the talk's data is copied so the note still
# shows it after the talk left the schedule (or next year's schedule reuses
# the id).
CREATE_NOTES = """
CREATE TABLE notes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    text TEXT NOT NULL,
    event_id INTEGER,
    talk_title TEXT NOT NULL DEFAULT '',
    talk_day TEXT NOT NULL DEFAULT '',
    talk_start TEXT NOT NULL DEFAULT '',
    talk_end TEXT NOT NULL DEFAULT '',
    talk_room TEXT NOT NULL DEFAULT ''
)"""

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
    if version < 3:
        con.execute(CREATE_NOTES)
    con.execute("PRAGMA user_version = %d" % SCHEMA_VERSION)


@contextlib.contextmanager
def connect():
    """Connection with the current schema; commits on success, always closes."""
    create_path(DB_FILE)
    con = sqlite3.connect(DB_FILE)
    # SQLite's lower() and LIKE only fold ASCII; search needs "Über" == "über"
    con.create_function("fold", 1, lambda s: s.casefold() if s else "", deterministic=True)
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


def select_links(event_id):
    """(url, feedback_url, [(kind, title, href)]) of an event; None if unknown."""
    with connect() as con:
        row = con.execute(
            "SELECT url, feedback_url FROM schedule_events WHERE id=?", (event_id,)).fetchone()
        if row is None:
            return None
        links = con.execute(
            "SELECT kind, title, href FROM schedule_links WHERE event_id=? ORDER BY position",
            (event_id,)).fetchall()
        return row[0], row[1], links


def insert_note(text, now, talk=None):
    """New note; talk is an event dict or None. Returns the note id."""
    talk = talk or {}
    with connect() as con:
        cur = con.execute(
            """INSERT INTO notes (created_at, updated_at, text, event_id, talk_title,
                                  talk_day, talk_start, talk_end, talk_room)
               VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)""",
            (now, now, text, talk.get("id"), talk.get("title", ""), talk.get("day", ""),
             talk.get("start", ""), talk.get("end", ""), talk.get("room", "")))
        return cur.lastrowid


def update_note(note_id, text, now):
    with connect() as con:
        con.execute("UPDATE notes SET text=?, updated_at=? WHERE id=?", (text, now, note_id))


def delete_note(note_id):
    with connect() as con:
        con.execute("DELETE FROM notes WHERE id=?", (note_id,))


def select_notes(event_id=None):
    """Notes, newest first; only those of one talk if event_id is given."""
    where, params = ("WHERE event_id=?", (event_id,)) if event_id is not None else ("", ())
    with connect() as con:
        con.row_factory = sqlite3.Row
        rows = con.execute(
            "SELECT * FROM notes %s ORDER BY created_at DESC, id DESC" % where, params)
        return [dict(r) for r in rows]
