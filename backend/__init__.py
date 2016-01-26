import datetime
import sys
import os
import pyotherside
import xml.etree.ElementTree as ET

from urllib.request import urlretrieve


__version__ = "0.2.2"

DIR = os.path.abspath(os.path.curdir)
APP_ID = "fosdem-qml.delijati"

if os.environ.get('XDG_DATA_HOME'):
    DIR = os.path.join(os.environ['XDG_DATA_HOME'], APP_ID)

FILENAME = os.path.join(DIR, "schedule.xml")


def download_file(url):

    def reporthook(blocknum, blocksize, totalsize):
        readsofar = blocknum * blocksize
        if totalsize > 0:
            percent = (readsofar * 1e2 / totalsize) / 2.
            pyotherside.send("on-progress", percent)
        else:
            sys.stderr.write("read %d\n" % (readsofar,))

    return urlretrieve(url, FILENAME, reporthook)


def get_schedule_file_path():
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

    def event_detail(event):
        ret = {"id": event.get("id")}
        for t in event.getchildren():
            text = ""
            if t.text:
                text = t.text
            if t.tag == "persons":
                text = ",".join([x.text for x in t.getchildren()])
            elif t.tag == "duration":
                ret["end"] = set_end(ret["start"], t.text)
            ret[t.tag] = text
        return ret

    with open(FILENAME, 'r') as f:
        tree = ET.parse(f)
        events = tree.findall(
            "./day[@date='%s']/room/event/[track='%s']" % (day, track))
        return [event_detail(x) for x in events]
