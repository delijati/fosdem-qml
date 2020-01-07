Fosdem Schedule
===============

Fosdem schedule app for ubuntu touch written in python and qml. This should
also work with other conferences as we use ``Pentabarf`` XML format.

Development
-----------

Run 
~~~

Install deps::

    $ sudo apt-get install pyotherside

Start::

    $ qmlscene Main.qml

Build::

    $ click build fosdem-qml/

Test the click app directly with the device::

    Attach device to computer with usb
    Activate developer mode on device and authorize device 

    $ clickable

Run with ``nvidia-docker2``::

    $ docker build -t nv-docker2 Dockerfile.nvidia
    $ nvidia-docker run -ti --rm -v /tmp/.docker.xauth:/tmp/.docker.xauth -e XAUTHORITY=/tmp/.docker.xauth -e DISPLAY=:0 -v /tmp/.X11-unix:/tmp/.X11-unix -u 1000 -v `pwd`:/app/dev foo bash -c "cd /app/dev && qmlscene src/Main.qml"

Run with ``docker``::

    $ docker build . -t ubports:xenial
    $ docker run -ti --rm -v /tmp/.docker.xauth:/tmp/.docker.xauth -e XAUTHORITY=/tmp/.docker.xauth -e DISPLAY=:0 -v /tmp/.X11-unix:/tmp/.X11-unix -u 1000 -v `pwd`:/app/dev ubports:xenial bash -c "cd /app/dev && qmlscene src/Main.qml"

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

We use ``clickable``::

    $ clickable 

TODO
----

- [ ] Tests!!!

- [ ] Show lectures by current time 

- [ ] Conditional Layout 
