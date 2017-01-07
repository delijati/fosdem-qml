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

    $ adb push fosdem-qml.delijati_0.4.0_multi.click /home/phablet/Downloads/
    $ cd Downloads
    $ pkcon install-local --allow-untrusted fosdem-qml.delijati_*_multi.click
    $ sudo reboot # TODO find out how to refresh UI

QT-Creator
~~~~~~~~~~

ARM Emulator Development works currently only under 16.04.

ARM
+++

First we need to install ubuntu-sdk and ubuntu-emulator::

    $ sudo apt-get install ubuntu-sdk
    $ sudo apt-get install pyotherside

Create a emulator::

    $ sudo ubuntu-emulator create utouch

QML Widgets
~~~~~~~~~~~

Show avaidable QML widgets::

    $ qmlscene /usr/lib/x86_64-linux-gnu/qt5/examples/ubuntu-ui-toolkit/examples/ubuntu-ui-toolkit-gallery/ubuntu-ui-toolkit-gallery.qml

Publish app
~~~~~~~~~~~

Upload new version via form::

    $ firefox https://myapps.developer.ubuntu.com/dev/click-apps/4389/stats/

To upload click app there as is a ``CLI`` tool `click-toolbelt <https://pypi.python.org/pypi/click-toolbelt>`_ to upload a
click app.

How::

    $ pip install click-toolbelt

TODO
----

- I18n

- Tests!!!

- Show lectures by current time 

- Geting rid of ``libpython3.4m.so.1.0`` as it should be already on the
  system!?

- Conditional Layout 
