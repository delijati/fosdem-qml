import datetime
import sys
import os
import pyotherside
import xml.etree.ElementTree as ET

from urllib.request import urlretrieve
from backend.config import FILENAME
from backend.utils import create_path, generate_fake_data
from backend.db import toggle, select_ids, select_all, delete_all  # NOQA


__version__ = "0.7.0"


def parse_event(event, day, room, checked_ids):
    event_id = int(event.get("id"))
    lecture_checked = event_id in checked_ids

    start = event.find("start").text if event.find("start") is not None else ""
    duration = event.find("duration").text if event.find("duration") is not None else ""

    if not start or not duration:
        return None

    start_dt = datetime.datetime.strptime(start, "%H:%M")
    duration_td = datetime.timedelta(
        hours=datetime.datetime.strptime(duration, "%H:%M").hour,
        minutes=datetime.datetime.strptime(duration, "%H:%M").minute,
    )
    end = (start_dt + duration_td).strftime("%H:%M")

    datetime_start = datetime.datetime.strptime(f"{day} {start}", "%Y-%m-%d %H:%M")
    datetime_end = datetime.datetime.strptime(f"{day} {end}", "%Y-%m-%d %H:%M")

    title = event.find("title").text if event.find("title") is not None else ""
    subtitle = event.find("subtitle").text if event.find("subtitle") is not None else ""
    track = event.find("track").text if event.find("track") is not None else ""

    persons_elem = event.find("persons")
    persons = ""
    if persons_elem is not None:
        persons = ",".join([p.text for p in persons_elem.findall("person") if p.text])

    abstract = event.find("abstract").text if event.find("abstract") is not None else ""
    description = (
        event.find("description").text if event.find("description") is not None else ""
    )

    return {
        "id": event_id,
        "day": day,
        "start": start,
        "end": end,
        "datetime_start": datetime_start,
        "datetime_end": datetime_end,
        "room": room,
        "title": title,
        "subtitle": subtitle,
        "track": track,
        "abstract": abstract,
        "description": description,
        "persons": persons,
        "lecture_checked": lecture_checked,
    }


def get_current_lectures(show_only_marked=False):
    now = datetime.datetime.now()
    checked_ids = select_ids()
    current_lectures = []

    if not os.path.exists(FILENAME):
        return current_lectures

    with open(FILENAME, "r") as f:
        tree = ET.parse(f)
        for day_elem in tree.findall("./day"):
            day = day_elem.get("date")
            for room_elem in day_elem.findall("./room"):
                room = room_elem.get("name")
                for event in room_elem.findall("./event"):
                    if show_only_marked and int(event.get("id")) not in checked_ids:
                        continue

                    event_data = parse_event(event, day, room, checked_ids)
                    if event_data is None:
                        continue

                    if (
                        event_data["datetime_start"]
                        <= now
                        <= event_data["datetime_end"]
                    ):
                        current_lectures.append(event_data)
                        print(event_data)

    return current_lectures


def download_file(url):

    def reporthook(blocknum, blocksize, totalsize):
        readsofar = blocknum * blocksize
        if totalsize > 0:
            percent = (readsofar * 1e2 / totalsize) / 2.0
            pyotherside.send("on-progress", percent)
        else:
            sys.stderr.write("read %d\n" % (readsofar,))

    create_path(FILENAME)

    if url.lower() == "fake" or url.lower() == "test":
        return generate_fake_data()

    return urlretrieve(url, FILENAME, reporthook)


def get_schedule_file_path(reset=False):
    if reset:
        delete_all()
    return FILENAME


def file_exists():
    return os.path.exists(FILENAME)


def find_tracks_by_day(day):
    with open(FILENAME, "r") as f:
        tree = ET.parse(f)
        tracks = tree.findall("./day[@date='%s']/room/event/track" % day)
        tracks = sorted(set([x.text for x in tracks]))
        ret = [{"title": x} for x in tracks]
        return ret


def find_events_by_day_track(day, track):
    checked_ids = select_ids()

    with open(FILENAME, "r") as f:
        tree = ET.parse(f)
        results = []
        for room_elem in tree.findall("./day[@date='%s']/room" % day):
            room = room_elem.get("name")
            for event in room_elem.findall("./event/[track='%s']" % track):
                event_data = parse_event(event, day, room, checked_ids)
                if event_data:
                    results.append(event_data)
        return results
