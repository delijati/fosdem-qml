Fosdem Schedule
===============

Fosdem schedule app for ubuntu touch written in python and qml. This should
also work with other conferences as we use ``Pentabarf`` XML format.

Development
-----------

ARM Development works currently only under 16.04.

ARM
~~~

First we need to install ubuntu-sdk and ubuntu-emulator::

    $ sudo apt-get install ubuntu-sdk
    $ sudo ubuntu-emulator create utouch

Create a emulator::

    $ sudo ubuntu-emulator create utouch

Desktop
-------

Use Vim, Neovim to edit. 

Start::

    $ qmlscene Main.qml

QML Widgets
-----------

Show avaidable QML widgets::

    $ qmlscene /usr/lib/x86_64-linux-gnu/qt5/examples/ubuntu-ui-toolkit/examples/ubuntu-ui-toolkit-gallery/ubuntu-ui-toolkit-gallery.qml

Publish app
-----------

To upload click app there as is a ``CLI`` tool `click-toolbelt <https://pypi.python.org/pypi/click-toolbelt>`_ to upload a
click app.

How::

    $ pip install click-toolbelt

Or upload it with the plublish function in qt-creator.

TODO
----

- I18n

- Tests!!!

- Show lectures by current time 

- Geting rid of ``libpython3.4m.so.1.0`` as it should be already on the
  system!?

- Conditional Layout 
