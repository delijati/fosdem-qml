import sqlite3

from backend.config import DB_FILE
from backend.utils import create_path


CREATE_TABLE = """
CREATE TABLE IF NOT EXISTS events (
    id INT,
    start TEXT,
    end TEXT,
    room TEXT,
    title TEXT,
    subtitle TEXT,
    abstract TEXT,
    description TEXT,
    persons TEXT
)"""

INSERT_EVENT = """
INSERT INTO events VALUES (
    :id,
    :start,
    :end,
    :room,
    :title,
    :subtitle,
    :abstract,
    :description,
    :persons
)"""

DELETE_EVENT = "DELETE FROM events WHERE id=:id"
SELECT_EVENT = "SELECT * FROM events WHERE id=:id"
SELECT_IDS_EVENT = "SELECT id FROM events"


def open_db():
    create_path(DB_FILE)
    con = sqlite3.connect(DB_FILE)
    con.set_trace_callback(print)

    with con:
        cur = con.cursor()
        cur.execute(CREATE_TABLE)

    return con


def insert(event):
    con = open_db()

    with con:
        cur = con.cursor()
        cur.execute(INSERT_EVENT, dict(
            id=event.id,
            start=event.start,
            end=event.end,
            room=event.room,
            title=event.title,
            subtitle=event.subtitle,
            abstract=event.abstract,
            description=event.description,
            persons=event.persons,
        ))


def delete(event_id):
    con = open_db()

    with con:
        cur = con.cursor()
        cur.execute(DELETE_EVENT, dict(id=event_id))


def toggle(event):
    con = open_db()

    with con:
        cur = con.cursor()
        cur.execute(SELECT_EVENT, dict(id=int(event.id)))
        data = cur.fetchone()
        ret = False
        if data:
            delete(event.id)
        else:
            ret = True
            insert(event)
        return ret


def select_ids():
    con = open_db()

    with con:
        cur = con.cursor()
        cur.execute(SELECT_IDS_EVENT)
        data = cur.fetchall()
        return [x[0] for x in data]
