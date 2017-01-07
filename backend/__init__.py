import datetime
import sys
import os
import pyotherside
import xml.etree.ElementTree as ET

from urllib.request import urlretrieve
from backend.config import FILENAME
from backend.utils import create_path
from backend.db import toggle, select_ids, select_all, delete_all


__version__ = "0.4.0"


def download_file(url):

    def reporthook(blocknum, blocksize, totalsize):
        readsofar = blocknum * blocksize
        if totalsize > 0:
            percent = (readsofar * 1e2 / totalsize) / 2.
            pyotherside.send("on-progress", percent)
        else:
            sys.stderr.write("read %d\n" % (readsofar,))

    create_path(FILENAME)

    return urlretrieve(url, FILENAME, reporthook)


def get_schedule_file_path(reset=False):
    if reset:
        delete_all()
    return FILENAME


def file_exists():
    return os.path.exists(FILENAME)


def find_tracks_by_day(day):
    with open(FILENAME, 'r') as f:
        tree = ET.parse(f)
        tracks = tree.findall("./day[@date='%s']/room/event/track" % day)
        tracks = sorted(set([x.text for x in tracks]))
        ret = [{'title': x} for x in tracks]
        return ret


def find_events_by_day_track(day, track):

    def set_end(start_str, duration_str):
        start = datetime.datetime.strptime(start_str, "%H:%M")
        duration = datetime.timedelta(
            hours=datetime.datetime.strptime(duration_str, "%H:%M").hour,
            minutes=datetime.datetime.strptime(duration_str, "%H:%M").minute
        )
        end = start + duration
        return end.strftime("%H:%M")

    def event_detail(event, checked_ids, day):
        ret = {"id": int(event.get("id"))}
        for t in event.getchildren():
            text = ""
            if t.text:
                text = t.text
            if t.tag == "persons":
                text = ",".join([x.text for x in t.getchildren()])
            elif t.tag == "duration":
                ret["end"] = set_end(ret["start"], t.text)
            ret[t.tag] = text

        ret["lecture_checked"] = False
        if ret["id"] in checked_ids:
            ret["lecture_checked"] = True
        ret["day"] = day
        datetime_start = "%s %s" % (day, ret["start"])
        ret["datetime_start"] = datetime.datetime.strptime(
            datetime_start, "%Y-%m-%d %H:%M")
        datetime_end = "%s %s" % (day, ret["end"])
        ret["datetime_end"] = datetime.datetime.strptime(
            datetime_end, "%Y-%m-%d %H:%M")
        return ret

    checked_ids = select_ids()

    with open(FILENAME, 'r') as f:
        tree = ET.parse(f)
        events = tree.findall(
            "./day[@date='%s']/room/event/[track='%s']" % (day, track))
        return [event_detail(x, checked_ids, day) for x in events]
