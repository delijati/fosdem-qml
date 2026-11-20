import datetime
import math
import os
import types
import pyotherside
import xml.etree.ElementTree as ET

from urllib.request import urlopen
from backend import db
from backend.config import FILENAME
from backend.utils import create_path, generate_fake_data
from backend.db import toggle, select_ids  # NOQA


__version__ = "0.8.0"

DOWNLOAD_TIMEOUT = 30


def text(elem, tag):
    """Text of a child element; "" when it is missing or empty."""
    return elem.findtext(tag) or ""


def parse_start(event, day, start):
    """Aware datetime from <date> (has the conference offset), else naive local."""
    date = text(event, "date")
    if date:
        return datetime.datetime.fromisoformat(date)
    return datetime.datetime.strptime(f"{day} {start}", "%Y-%m-%d %H:%M")


def is_running(event_data, now):
    """now must be timezone aware; naive events are compared in device time."""
    if event_data["datetime_start"].tzinfo is None:
        now = now.astimezone().replace(tzinfo=None)
    return event_data["datetime_start"] <= now <= event_data["datetime_end"]


def parse_event(event, day, room):
    """Row for db.EVENT_COLUMNS; None for events without start or duration."""
    start = text(event, "start")
    duration = text(event, "duration")

    if not start or not duration:
        return None

    hours, minutes = duration.split(":")[:2]
    duration_td = datetime.timedelta(hours=int(hours), minutes=int(minutes))

    datetime_start = parse_start(event, day, start)
    datetime_end = datetime_start + duration_td

    persons_elem = event.find("persons")
    persons = ""
    if persons_elem is not None:
        persons = ", ".join([p.text for p in persons_elem.findall("person") if p.text])

    return {
        "id": int(event.get("id")),
        "day": day,
        "start": start,
        "end": datetime_end.strftime("%H:%M"),
        "datetime_start": datetime_start.isoformat(),
        "datetime_end": datetime_end.isoformat(),
        "room": room,
        "title": text(event, "title"),
        "subtitle": text(event, "subtitle"),
        "track": text(event, "track"),
        "abstract": text(event, "abstract"),
        "description": text(event, "description"),
        "persons": persons,
        "url": text(event, "url"),
        "feedback_url": text(event, "feedback_url"),
        "type": text(event, "type"),
        "language": text(event, "language"),
    }


def parse_links(event):
    """(event_id, position, kind, title, href) for attachments and links."""
    event_id = int(event.get("id"))
    elems = [("attachment", e) for e in event.findall("./attachments/attachment")]
    elems += [("link", e) for e in event.findall("./links/link")]
    return [
        (event_id, position, kind, (elem.text or "").strip(), elem.get("href"))
        for position, (kind, elem) in enumerate(elems)
        if elem.get("href")
    ]


def import_schedule(stamp):
    tree = ET.parse(FILENAME)
    meta = {c.tag: c.text or "" for c in tree.findall("./conference/*")}
    meta["source_stamp"] = stamp
    events = []
    links = []
    for day_elem in tree.findall("./day"):
        day = day_elem.get("date")
        for room_elem in day_elem.findall("./room"):
            room = room_elem.get("name")
            for event in room_elem.findall("./event"):
                event_data = parse_event(event, day, room)
                if event_data is not None:
                    events.append(event_data)
                    links.extend(parse_links(event))
    db.replace_schedule(meta, events, links)


def ensure_imported():
    """Import schedule.xml into the database when it changed since the last import."""
    if not os.path.exists(FILENAME):
        return
    st = os.stat(FILENAME)
    stamp = "%d:%d" % (st.st_mtime_ns, st.st_size)
    if db.get_meta("source_stamp") != stamp:
        import_schedule(stamp)


def to_event(row):
    """Database row -> dict for QML."""
    row["datetime_start"] = datetime.datetime.fromisoformat(row["datetime_start"])
    row["datetime_end"] = datetime.datetime.fromisoformat(row["datetime_end"])
    row["lecture_checked"] = bool(row["lecture_checked"])
    row["removed"] = False
    return row


def removed_event(fav):
    """Event dict for a favorite that is no longer in the schedule."""
    event = {c: "" for c in db.EVENT_COLUMNS}
    event.update(fav)
    start = datetime.datetime.strptime(fav["day"] + " " + fav["start"], "%Y-%m-%d %H:%M")
    end = datetime.datetime.strptime(fav["day"] + " " + fav["end"], "%Y-%m-%d %H:%M")
    event["datetime_start"] = start
    event["datetime_end"] = end if end >= start else end + datetime.timedelta(days=1)
    event["lecture_checked"] = True
    event["removed"] = True
    return event


def select_events(*args, **kwargs):
    ensure_imported()
    return [to_event(r) for r in db.select_events(*args, **kwargs)]


def get_days():
    ensure_imported()
    return [{"date": d} for d in db.select_days()]


def find_tracks_by_day(day):
    ensure_imported()
    return [{"title": t} for t in db.select_tracks(day)]


def find_events_by_day_track(day, track):
    return select_events("e.day = ? AND e.track = ?", (day, track))


SEARCH_TEXT = "fold(e.title || ' ' || e.subtitle || ' ' || e.persons || ' ' || e.abstract)"


def search(query):
    """Talks of all days whose title, subtitle, speakers or abstract contain
    every word of query (case-insensitive)."""
    words = query.casefold().split()
    if not words:
        return []
    where = " AND ".join(["instr(%s, ?) > 0" % SEARCH_TEXT] * len(words))
    return select_events(where, words)


def get_current_lectures(show_only_marked=False, now=None):
    if now is None:
        now = datetime.datetime.now(datetime.timezone.utc)
    events = select_events(favorites_only=show_only_marked)
    return [e for e in events if is_running(e, now)]


def minutes_until(when, now):
    """Whole minutes from now until when, rounded up (naive = device time)."""
    if when.tzinfo is None:
        now = now.astimezone().replace(tzinfo=None)
    return math.ceil((when - now).total_seconds() / 60)


def get_now_and_next(show_only_marked=False, now=None, window_min=60):
    """Running talks ("group": "now", "minutes" until the end) and talks
    starting within window_min ("group": "next", "minutes" until the start),
    each group sorted by "minutes"."""
    if now is None:
        now = datetime.datetime.now(datetime.timezone.utc)
    running = []
    upcoming = []
    for event in select_events(favorites_only=show_only_marked):
        if is_running(event, now):
            event["group"] = "now"
            event["minutes"] = minutes_until(event["datetime_end"], now)
            running.append(event)
        else:
            starts_in = minutes_until(event["datetime_start"], now)
            if 0 < starts_in <= window_min:
                event["group"] = "next"
                event["minutes"] = starts_in
                upcoming.append(event)
    key = lambda e: (e["minutes"], e["id"])  # noqa: E731
    return sorted(running, key=key) + sorted(upcoming, key=key)


def select_all():
    """Favorites with the data of the current schedule, ordered by start.

    Favorites whose talk was removed from the schedule are kept with
    "removed": True and the data from when they were marked.
    "clash_titles" lists the other favorites running at the same time
    (", " separated, "" if none; removed talks never clash).
    """
    events = select_events(favorites_only=True)
    for event in events:
        event["clash_titles"] = ", ".join(
            other["title"] for other in events
            if other is not event
            and other["datetime_start"] < event["datetime_end"]
            and event["datetime_start"] < other["datetime_end"]
        )
    removed = [removed_event(f) for f in db.select_removed_favorites()]
    for event in removed:
        event["clash_titles"] = ""
    return sorted(events + removed, key=lambda e: (e["datetime_start"].replace(tzinfo=None), e["id"]))


# Favorites set by the "fake" schedule so the agenda shows days and overlaps:
# 1002/1003 and 4001/4002 overlap, 1001 and 4004 do not.
FAKE_FAVORITES = [1001, 1002, 1003, 4001, 4002, 4004]


def mark_fake_favorites():
    ensure_imported()
    marked = set(db.select_ids())
    for event in select_events():
        if event["id"] in FAKE_FAVORITES and event["id"] not in marked:
            db.insert(types.SimpleNamespace(**event))


def check_schedule(path):
    """Error message if path is not a usable Pentabarf schedule, else ""."""
    try:
        root = ET.parse(path).getroot()
    except ET.ParseError as e:
        return "invalid XML (%s)" % e
    if root.tag != "schedule" or root.find("day") is None:
        return "not a Pentabarf schedule"
    return ""


def fetch(url, target):
    with urlopen(url, timeout=DOWNLOAD_TIMEOUT) as response, open(target, "wb") as f:
        total = int(response.headers.get("Content-Length") or 0)
        done = 0
        while True:
            chunk = response.read(64 * 1024)
            if not chunk:
                break
            f.write(chunk)
            done += len(chunk)
            if total:
                pyotherside.send("on-progress", min(99, done * 100 // total))


def download_file(url):
    """Download into a temp file and replace the schedule only if it is valid.

    Returns "" on success, else a short error message; the old schedule stays.
    """
    create_path(FILENAME)

    if url.lower() == "fake" or url.lower() == "test":
        generate_fake_data()
        mark_fake_favorites()
        return ""

    part = FILENAME + ".part"
    try:
        fetch(url, part)
        error = check_schedule(part)
    except (OSError, ValueError) as e:
        error = str(getattr(e, "reason", None) or e)

    if error:
        if os.path.exists(part):
            os.remove(part)
        return error

    os.replace(part, FILENAME)
    ensure_imported()
    pyotherside.send("on-progress", 100)
    return ""


def file_exists():
    return os.path.exists(FILENAME)
