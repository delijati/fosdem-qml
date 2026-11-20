Fosdem Schedule
===============

.. image:: https://github.com/delijati/fosdem-qml/actions/workflows/ci.yml/badge.svg
   :target: https://github.com/delijati/fosdem-qml/actions/workflows/ci.yml

FOSDEM schedule app for Ubuntu Touch 24.04, written in Python and QML. The
schedule is downloaded once and works offline. It should also work with other
conferences that publish a ``Pentabarf`` XML schedule.

Features
--------

- **Days and tracks**: browse the schedule by day (with weekday) and track.
- **Now and next up**: talks running now with the time left, and talks
  starting within the next hour; refreshes every minute while the page is
  shown.
- **Favorites agenda**: starred talks grouped by day, with a warning when two
  of them overlap. Favorites stay when a new schedule is downloaded; talks
  dropped from the schedule are marked.
- **Search**: title, speaker, subtitle and abstract of all days.
- **Talk page**: time, room, speakers, description, and links to the event
  page, slides, video, chat and feedback.
- **Notes**: one note per talk, written from the talk page, plus free notes
  (hallway track); the Notes page lists them by day, newest first, to read
  after the conference.
- **Map** of the ULB campus.

.. list-table::
   :widths: 33 33 33

   * - .. image:: docs/screenshots/now.png
          :width: 250
     - .. image:: docs/screenshots/agenda.png
          :width: 250
     - .. image:: docs/screenshots/talk.png
          :width: 250
   * - Now and next up
     - Favorites with overlap warnings
     - Talk with note and links
   * - .. image:: docs/screenshots/days.png
          :width: 250
     - .. image:: docs/screenshots/search.png
          :width: 250
     - .. image:: docs/screenshots/notes.png
          :width: 250
   * - Days
     - Search
     - Notes

Development
-----------

Needs ``uv``, ``make`` and docker or podman. ``make help`` lists all targets.
The app targets Ubuntu Touch 24.04 (framework ``ubuntu-touch-24.04-1.x``,
Python 3.12, Qt 5.15).

Run
~~~

Install clickable (uv keeps it in its tool cache; the first ``make`` target
that needs it installs it too)::

    $ make install

Start on this computer::

    $ make desktop

Demo data: in the app, open the download dialog (Import) and enter ``fake``
as URL. This loads a generated schedule for today and tomorrow, with talks
running right now, and marks some overlapping favorites.

Build the click package (``build/all/app/*.click``)::

    $ make build

Install and start on a phone (USB, developer mode on and the computer
authorized on the phone)::

    $ make device
    $ make logs

With podman, ``make build``, ``desktop``, ``device`` and ``review`` first pull
Clickable's image with a plain ``podman pull``: Clickable runs its containers
with a small ``--uidmap``, and a pull done by such a ``podman run`` fails on the
24.04 images (``container ID 32011 cannot be mapped to a host ID``). Layers left
behind by such a failed pull break later pulls too; remove them once with::

    $ podman system check --repair --max=1m

``make desktop`` runs without Clickable's nvidia mode, which needs
``nvidia-docker`` version 1 with podman. The app does not need the GPU. To use
nvidia mode anyway (docker with the NVIDIA Container Toolkit)::

    $ CLICKABLE_NVIDIA=1 make desktop

Tests
~~~~~

Python backend, pytest on 3.12 with warnings as errors::

    $ make test

QML smoke check: runs the app in the Clickable 24.04 SDK image under xvfb,
opens every page with ``tests/data/small.xml``, checks results and fails on
QML or python errors. Screenshots of each page land in the given directory::

    $ make smoke
    $ tools/qml-smoke.sh /tmp/smoke

Screenshots
~~~~~~~~~~~

The screenshots above are taken in the same image with the demo schedule
(``tests/qml/screenshots.qml``); after UI changes, refresh them with::

    $ make screenshots

CI
~~

GitHub Actions (``.github/workflows/ci.yml``) runs on every push and pull
request: ``make test``, the QML smoke check (screenshots are uploaded as the
``smoke-screenshots`` artifact) and ``clickable build`` in the 24.04 image (the
click package is uploaded as the ``click`` artifact).

Publish
~~~~~~~

New version (bump2version via uv: changes ``.bumpversion.cfg``,
``manifest.json.in`` and ``src/backend/__init__.py``, commits and tags; needs a
clean working tree)::

    $ make bump PART=patch   # or minor, major
    $ git push --follow-tags
    $ make build             # upload build/all/app/*.click to the OpenStore
