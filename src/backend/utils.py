import os
import datetime

import pyotherside

from backend.config import FILENAME


def create_path(filename):
    dirname = os.path.dirname(filename)
    if not os.path.exists(dirname):
        os.makedirs(dirname)


def generate_fake_data():
    now = datetime.datetime.now()
    today = now.strftime("%Y-%m-%d")

    fake_xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<schedule>
  <conference>
    <title>FOSDEM {now.year}</title>
    <start>{today}</start>
    <end>{today}</end>
  </conference>
  <day date="{today}" index="1">
    <room name="Main Track">
      <event id="1001">
        <start>{(now - datetime.timedelta(hours=1)).strftime("%H:%M")}</start>
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
        <start>{(now - datetime.timedelta(minutes=15)).strftime("%H:%M")}</start>
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
        <start>{now.strftime("%H:%M")}</start>
        <duration>01:00</duration>
        <title>Python Performance Optimization</title>
        <subtitle>Making your Python code fly</subtitle>
        <track>Python</track>
        <abstract>Discover techniques to dramatically improve Python application performance.</abstract>
        <description>Deep dive into Python performance optimization including profiling, caching strategies, and async programming. Real-world examples and benchmarks included.</description>
        <persons>
          <person>Mike Pythonista</person>
          <person>Lisa CodeSpeed</person>
        </persons>
      </event>
      <event id="1004">
        <start>{(now + datetime.timedelta(minutes=30)).strftime("%H:%M")}</start>
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
        <start>{(now - datetime.timedelta(minutes=45)).strftime("%H:%M")}</start>
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
        <start>{(now + datetime.timedelta(minutes=15)).strftime("%H:%M")}</start>
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
        <start>{(now + datetime.timedelta(hours=1, minutes=30)).strftime("%H:%M")}</start>
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
        <start>{(now - datetime.timedelta(hours=2)).strftime("%H:%M")}</start>
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
        <start>{(now + datetime.timedelta(minutes=45)).strftime("%H:%M")}</start>
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
</schedule>"""

    create_path(FILENAME)
    with open(FILENAME, "w") as f:
        f.write(fake_xml)

    for i in range(10):
        pyotherside.send("on-progress", i * 5)

    return FILENAME
