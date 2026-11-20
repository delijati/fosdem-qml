import backend
from conftest import event_xml


def test_links_of_talk(schedule):
    assert backend.get_links(100) == [
        {"kind": "event", "title": "Event page",
         "href": "https://fosdem.org/2025/schedule/event/fosdem-2025-100-welcome/"},
        {"kind": "attachment", "title": "Talk slides",
         "href": "https://fosdem.org/2025/events/attachments/100/slides.pdf"},
        {"kind": "link", "title": "Video recording (MP4)",
         "href": "https://video.fosdem.org/2025/janson/fosdem-2025-100-welcome.mp4"},
        {"kind": "link", "title": "Chat room(web)",
         "href": "https://chat.fosdem.org/#/room/#2025-keynote:fosdem.org"},
        {"kind": "link", "title": "Submit Feedback",
         "href": "https://pretalx.fosdem.org/fosdem-2025/talk/AAA/feedback/"},
    ]


def test_feedback_url_added_when_not_in_links(write_schedule):
    write_schedule({"2025-02-01": {"A": [event_xml(
        1, extra="<url>https://e/1</url><feedback_url>https://f/1</feedback_url>")]}})

    assert backend.get_links(1) == [
        {"kind": "event", "title": "Event page", "href": "https://e/1"},
        {"kind": "feedback", "title": "Feedback", "href": "https://f/1"},
    ]


def test_link_without_title_uses_address(write_schedule):
    write_schedule({"2025-02-01": {"A": [event_xml(
        1, extra="<links><link href='https://v/1.mp4'></link></links>")]}})

    assert backend.get_links(1) == [{"kind": "link", "title": "https://v/1.mp4", "href": "https://v/1.mp4"}]


def test_no_links(schedule):
    assert backend.get_links(101) == [
        {"kind": "event", "title": "Event page",
         "href": "https://fosdem.org/2025/schedule/event/fosdem-2025-101-creative-coding/"},
    ]
    assert backend.get_links(999) == []


def test_fake_schedule_has_links(data_dir):
    assert backend.download_file("fake") == ""

    kinds = [link["kind"] for link in backend.get_links(1003)]
    assert kinds == ["event", "attachment", "link", "link", "feedback"]
    assert [link["kind"] for link in backend.get_links(4002)] == ["event", "link"]
