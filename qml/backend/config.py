import os


DIR = os.path.abspath(os.path.curdir)
APP_ID = "fosdem-qml.delijati"

if os.environ.get('XDG_DATA_HOME'):
    DIR = os.path.join(os.environ['XDG_DATA_HOME'], APP_ID)

FILENAME = os.path.join(DIR, "schedule.xml")
DB_FILE = os.path.join(DIR, "saved.db")
