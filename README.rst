Fosdem Schedule
===============

Fosdem schedule app for ubuntu touch written in python and qml. This should
also work with other conferences as we use ``Pentabarf`` XML format.

Development
-----------

Run 
~~~

Install deps::

    $ pip install clickable-ut

Start::

    $ clickable desktop

Build::

    $ clickable build

Test the click app directly with the device::

    Attach device to computer with usb
    Activate developer mode on device and authorize device 

    $ clickable

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
    $ clickable build # && copy *.click pakage to openstore

We use ``clickable``::

    $ clickable 

TODO
----

- [ ] Tests!!!

- [ ] Show lectures by current time 

- [ ] Conditional Layout 
