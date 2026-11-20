import os
import datetime

import pyotherside

from backend.config import FILENAME


def create_path(filename):
    dirname = os.path.dirname(filename)
    if not os.path.exists(dirname):
        os.makedirs(dirname)


def generate_fake_data(now=None):
    if now is None:
        now = datetime.datetime.now().astimezone()
    today = now.strftime("%Y-%m-%d")
    tomorrow_date = (now + datetime.timedelta(days=1)).date()
    tomorrow = tomorrow_date.isoformat()

    def at(hour, minute):
        """Fixed clock time tomorrow, so the second day never crosses midnight."""
        return datetime.datetime.combine(
            tomorrow_date, datetime.time(hour, minute), tzinfo=now.tzinfo)

    def start(t):
        # <date> carries day and offset, so talks before midnight stay on
        # the previous day
        return f"<date>{t.isoformat(timespec='seconds')}</date>\n        <start>{t:%H:%M}</start>"

    fake_xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<schedule>
  <conference>
    <title>FOSDEM {now.year}</title>
    <start>{today}</start>
    <end>{tomorrow}</end>
  </conference>
  <day date="{today}" index="1">
    <room name="Main Track">
      <event id="1001">
        {start(now - datetime.timedelta(hours=1))}
        <duration>00:30</duration>
        <title>Opening Keynote - The Future of Open Source</title>
        <subtitle>A comprehensive overview of where we're headed</subtitle>
        <track>Keynotes</track>
        <abstract>An inspiring look at the future of open source software and community collaboration.</abstract>
        <description>This keynote will explore emerging trends in open source development, community building, and the changing landscape of software collaboration. We'll discuss the challenges and opportunities that lie ahead for the open source movement.</description>
        <persons>
          <person>Jane Developer</person>
          <person>John Contributor</person>
        </persons>
      </event>
      <event id="1002">
        {start(now - datetime.timedelta(minutes=15))}
        <duration>00:45</duration>
        <title>Building Better Applications with QML</title>
        <subtitle>Modern UI development patterns</subtitle>
        <track>Qt</track>
        <abstract>Learn how to build responsive and beautiful applications using QML.</abstract>
        <description>This talk covers advanced QML techniques for building modern cross-platform applications. Topics include component architecture, state management, and performance optimization.</description>
        <persons>
          <person>Sarah QtDev</person>
        </persons>
      </event>
      <event id="1003">
        {start(now)}
        <duration>01:00</duration>
        <title>Python Performance Optimization</title>
        <subtitle>Making your Python code fly</subtitle>
        <track>Python</track>
        <abstract>Discover techniques to dramatically improve Python application performance.</abstract>
        <description>Deep dive into Python performance optimization including profiling, caching strategies, and async programming. Real-world examples and benchmarks included. Code: &lt;a href="https://github.com/python/pyperformance"&gt;pyperformance&lt;/a&gt;.</description>
        <url>https://fosdem.org/schedule/event/python-performance/</url>
        <feedback_url>https://pretalx.fosdem.org/talk/PYPERF/feedback/</feedback_url>
        <persons>
          <person>Mike Pythonista</person>
          <person>Lisa CodeSpeed</person>
        </persons>
        <attachments>
          <attachment type="slides" href="https://fosdem.org/events/attachments/python-performance/slides.pdf">Talk slides</attachment>
        </attachments>
        <links>
          <link href="https://video.fosdem.org/python-performance.mp4">Video recording (MP4)</link>
          <link href="https://chat.fosdem.org/#/room/#python:fosdem.org">Chat room(web)</link>
        </links>
      </event>
      <event id="1004">
        {start(now + datetime.timedelta(minutes=30))}
        <duration>00:50</duration>
        <title>Container Orchestration Best Practices</title>
        <subtitle>Beyond the basics</subtitle>
        <track>DevOps</track>
        <abstract>Advanced patterns for managing containerized applications at scale.</abstract>
        <description>Learn proven strategies for deploying and managing containers in production. We'll cover service mesh, monitoring, security, and CI/CD integration.</description>
        <persons>
          <person>Alex CloudOps</person>
        </persons>
      </event>
    </room>
    <room name="Developer Room A">
      <event id="2001">
        {start(now - datetime.timedelta(minutes=45))}
        <duration>00:30</duration>
        <title>Git Workflows for Teams</title>
        <subtitle>Collaboration made easy</subtitle>
        <track>Version Control</track>
        <abstract>Effective Git strategies for team collaboration.</abstract>
        <description>Explore different Git workflows including GitFlow, trunk-based development, and how to choose the right approach for your team.</description>
        <persons>
          <person>Tom GitMaster</person>
        </persons>
      </event>
      <event id="2002">
        {start(now + datetime.timedelta(minutes=15))}
        <duration>00:45</duration>
        <title>Database Design Patterns</title>
        <subtitle>Schema design for scalability</subtitle>
        <track>Databases</track>
        <abstract>Learn how to design databases that scale with your application.</abstract>
        <description>Comprehensive coverage of database design patterns, normalization, indexing strategies, and performance considerations for modern applications.</description>
        <persons>
          <person>Emma DataArch</person>
          <person>Chris DBExpert</person>
        </persons>
      </event>
      <event id="2003">
        {start(now + datetime.timedelta(hours=1, minutes=30))}
        <duration>01:00</duration>
        <title>Testing Strategies for Reliable Software</title>
        <subtitle>From unit to integration</subtitle>
        <track>Testing</track>
        <abstract>Build confidence in your code with comprehensive testing.</abstract>
        <description>This session covers unit testing, integration testing, end-to-end testing, and how to build a testing strategy that catches bugs early while maintaining development velocity.</description>
        <persons>
          <person>Rachel TestDriven</person>
        </persons>
      </event>
    </room>
    <room name="Developer Room B">
      <event id="3001">
        {start(now - datetime.timedelta(hours=2))}
        <duration>00:25</duration>
        <title>Lightning Talk: WebAssembly Everywhere</title>
        <subtitle></subtitle>
        <track>WebAssembly</track>
        <abstract>Quick overview of WebAssembly use cases beyond the browser.</abstract>
        <description>A lightning-fast tour of WebAssembly applications in edge computing, serverless, and embedded systems.</description>
        <persons>
          <person>Kevin WasmFan</person>
        </persons>
      </event>
      <event id="3002">
        {start(now + datetime.timedelta(minutes=45))}
        <duration>00:50</duration>
        <title>Secure Coding Practices</title>
        <subtitle>Defense in depth</subtitle>
        <track>Security</track>
        <abstract>Write secure code from the ground up.</abstract>
        <description>Learn essential security practices including input validation, authentication, authorization, and common vulnerability prevention (OWASP Top 10).</description>
        <persons>
          <person>Diana SecDev</person>
        </persons>
      </event>
    </room>
  </day>
  <day date="{tomorrow}" index="2">
    <room name="Main Track">
      <event id="4001">
        {start(at(10, 0))}
        <duration>00:50</duration>
        <title>Rust in the Linux Kernel</title>
        <subtitle>Two years later</subtitle>
        <track>Kernel</track>
        <abstract>Where Rust drivers stand today.</abstract>
        <description>An update on the Rust for Linux effort: merged drivers, tooling and what is still missing.</description>
        <persons>
          <person>Miguel Ferris</person>
        </persons>
      </event>
      <event id="4003">
        {start(at(14, 0))}
        <duration>00:45</duration>
        <title>Closing Keynote</title>
        <subtitle>See you next year</subtitle>
        <track>Keynotes</track>
        <abstract>Thanks to all volunteers.</abstract>
        <description>The closing session with numbers, thanks and an outlook.</description>
        <persons>
          <person>Jane Developer</person>
        </persons>
      </event>
    </room>
    <room name="Developer Room A">
      <event id="4002">
        {start(at(10, 30))}
        <duration>00:30</duration>
        <title>Ubuntu Touch on 24.04</title>
        <subtitle>Porting apps to Qt 5.15</subtitle>
        <track>Mobile</track>
        <abstract>What changed for app developers.</abstract>
        <description>Framework, AppArmor policy and Python 3.12: what you need to change in your click package.</description>
        <url>https://fosdem.org/schedule/event/ubuntu-touch-2404/</url>
        <persons>
          <person>Peat Psuwit</person>
        </persons>
        <links>
          <link href="https://forums.ubports.com/topic/11333">Porting guide (forum)</link>
        </links>
      </event>
      <event id="4004">
        {start(at(11, 30))}
        <duration>00:25</duration>
        <title>Lightning Talk: Offline-first Schedules</title>
        <subtitle></subtitle>
        <track>Mobile</track>
        <abstract>Conference apps without network.</abstract>
        <description>Why a conference app should work in a basement full of people.</description>
        <persons>
          <person>Josip Delic</person>
        </persons>
      </event>
    </room>
  </day>
</schedule>"""

    create_path(FILENAME)
    with open(FILENAME, "w") as f:
        f.write(fake_xml)

    for i in range(11):
        pyotherside.send("on-progress", i * 10)

    return FILENAME
