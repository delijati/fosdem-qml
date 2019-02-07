Fosdem Schedule
===============

Fosdem schedule app for ubuntu touch written in python and qml. This should
also work with other conferences as we use ``Pentabarf`` XML format.

Development
-----------

CLI 
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

QML Widgets
~~~~~~~~~~~

Show avaidable QML widgets::

    $ qmlscene /usr/lib/x86_64-linux-gnu/qt5/examples/ubuntu-ui-toolkit/examples/ubuntu-ui-toolkit-gallery/ubuntu-ui-toolkit-gallery.qml

Publish app
~~~~~~~~~~~

clickable 

TODO
----

- [x] I18n

- [ ] Tests!!!

- [ ] Show lectures by current time 

- [x] Geting rid of ``libpython3.4m.so.1.0`` as it should be already on the
  system!?

- [ ] Conditional Layout 
