"""Serve files from a directory, each answer delayed by DELAY seconds.

Lets the smoke check press buttons while a download is still running.
usage: python3 slow_server.py DIR PORT
"""
import functools
import http.server
import sys
import time

DELAY = 2


class SlowHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        time.sleep(DELAY)
        super().do_GET()

    def log_message(self, *args):
        pass


handler = functools.partial(SlowHandler, directory=sys.argv[1])
http.server.ThreadingHTTPServer(("127.0.0.1", int(sys.argv[2])), handler).serve_forever()
