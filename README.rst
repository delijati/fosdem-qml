Fosdem Schedule
===============

Fosdem schedule app for ubuntu touch written in python and qml. This should
also work with other conferences as we use ``Pentabarf`` XML format.

Development
-----------

Run 
~~~

Needs ``uv``, ``make`` and docker or podman. ``make help`` lists all targets.

Install clickable (uv keeps it in its tool cache; the first ``make`` target
that needs it installs it too)::

    $ make install

Start on this computer::

    $ make desktop

Build the click package::

    $ make build

Test the click app directly with the device::

    Attach device to computer with usb
    Activate developer mode on device and authorize device

    $ make device

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

The app targets Ubuntu Touch 24.04 (framework ``ubuntu-touch-24.04-1.x``,
Python 3.12, Qt 5.15). The python backend is tested with pytest on 3.12,
warnings as errors::

    $ make test

QML smoke check: runs the app in the clickable 24.04 SDK image under xvfb,
opens every page with ``tests/data/small.xml`` and fails on QML or python
errors. Screenshots of each page land in the given directory::

    $ make smoke
    $ tools/qml-smoke.sh /tmp/smoke

QML Widgets
~~~~~~~~~~~

Show avaidable QML widgets::

    $ qmlscene /usr/lib/x86_64-linux-gnu/qt5/examples/ubuntu-ui-toolkit/examples/ubuntu-ui-toolkit-gallery/ubuntu-ui-toolkit-gallery.qml

Publish app
~~~~~~~~~~~

Set new version::

    $ bump2version --verbose [patch|minor|major]
    $ git push
    $ git push origin --tags
    $ make build # && copy *.click pakage to openstore

TODO
----

- [ ] Show lectures by current time 

- [ ] Conditional Layout 
