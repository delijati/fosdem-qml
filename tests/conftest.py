import shutil
import sys
import types
from pathlib import Path
from xml.sax.saxutils import escape, quoteattr

import pytest

DATA = Path(__file__).parent / "data"


class FakePyotherside(types.ModuleType):
    def __init__(self):
        super().__init__("pyotherside")
        self.sent = []

    def send(self, *args):
        self.sent.append(args)


sys.modules.setdefault("pyotherside", FakePyotherside())

import backend  # noqa: E402 - needs the pyotherside stub above
import backend.db  # noqa: E402
import backend.utils  # noqa: E402


@pytest.fixture
def pyotherside():
    mod = sys.modules["pyotherside"]
    mod.sent.clear()
    return mod


@pytest.fixture
def data_dir(tmp_path, monkeypatch):
    """Point all backend paths into a fresh tmp dir."""
    schedule = tmp_path / "schedule.xml"
    db_file = tmp_path / "saved.db"
    monkeypatch.setattr(backend, "FILENAME", str(schedule))
    monkeypatch.setattr(backend.utils, "FILENAME", str(schedule))
    monkeypatch.setattr(backend.db, "DB_FILE", str(db_file))
    return tmp_path


def event_xml(event_id, start="10:00", duration="00:30", track="Python",
              title=None, date=None, extra=""):
    """One Pentabarf <event>; track=None leaves the element out."""
    track_xml = "" if track is None else "<track>%s</track>" % escape(track)
    date_xml = "" if date is None else "<date>%s</date>" % date
    return """
      <event id="%s">
        %s
        <start>%s</start>
        <duration>%s</duration>
        <title>%s</title>
        %s
        %s
      </event>""" % (event_id, date_xml, start, duration,
                     escape(title or "Talk %s" % event_id), track_xml, extra)


def schedule_xml(days, tz="Europe/Brussels"):
    """days: {date: {room: [event_xml, ...]}}"""
    out = ["<?xml version='1.0' encoding='UTF-8'?><schedule><conference>"
           "<title>Test</title><time_zone_name>%s</time_zone_name>"
           "</conference>" % tz]
    for day, rooms in days.items():
        out.append("<day date=%s>" % quoteattr(day))
        for room, events in rooms.items():
            out.append("<room name=%s>%s</room>" % (quoteattr(room), "".join(events)))
        out.append("</day>")
    out.append("</schedule>")
    return "".join(out)


@pytest.fixture
def write_schedule(data_dir):
    def write(days, **kwargs):
        target = data_dir / "schedule.xml"
        target.write_text(schedule_xml(days, **kwargs), encoding="utf-8")
        return target
    return write


@pytest.fixture
def schedule(data_dir):
    """The small FOSDEM-like schedule installed as the current schedule."""
    target = data_dir / "schedule.xml"
    shutil.copy(DATA / "small.xml", target)
    return target
