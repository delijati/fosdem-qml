import QtQuick 2.9
import Lomiri.Components.Popups 1.3

// Loads the app, opens every page once and saves a screenshot of each.
// Run through tools/qml-smoke.sh; it fails on QML or python errors in the log.
Item {
    id: root
    width: 450
    height: 700

    property var app: loader.item
    property var py: null
    property var stack: null
    property string outDir: "/out"
    property var steps: []
    property int stepIndex: 0

    Loader {
        id: loader
        anchors.fill: parent
        source: "../../src/Main.qml"
    }

    function find(obj, test, depth) {
        if (!obj || depth > 8)
            return null;
        if (test(obj))
            return obj;
        var kids = obj.data || [];
        for (var i = 0; i < kids.length; i++) {
            var hit = find(kids[i], test, depth + 1);
            if (hit)
                return hit;
        }
        return null;
    }

    function listModel(items) {
        var model = Qt.createQmlObject("import QtQuick 2.9; ListModel {}", root);
        for (var i = 0; i < items.length; i++)
            model.append(items[i]);
        return model;
    }

    function shot(name) {
        (root.parent || root).grabToImage(function(result) {
            result.saveToFile(outDir + "/" + name + ".png");
        });
        console.log("SMOKE page " + name + " depth=" + stack.depth);
    }

    function expect(label, actual, expected) {
        if (actual === expected)
            console.log("SMOKE ok: " + label);
        else
            console.error("SMOKE MISMATCH " + label + ": got " + actual + ", want " + expected);
    }

    function downloadDialog() {
        return find(root, function(o) { return o.progress_visible !== undefined; }, 0);
    }

    function dialogButton(name) {
        return find(downloadDialog(), function(o) { return o.objectName === name; }, 0);
    }

    function download(url) {
        find(downloadDialog(), function(o) { return o.objectName === "downloadUrl"; }, 0).text = url;
        dialogButton("downloadButton").clicked();
    }

    function next() {
        if (stepIndex >= steps.length) {
            console.log("SMOKE DONE");
            Qt.quit();
            return;
        }
        steps[stepIndex++]();
    }

    Timer {
        id: tick
        interval: 1200
        onTriggered: next()
    }

    function after(fn) {
        return function() { fn(); tick.start(); };
    }

    Component.onCompleted: {
        stack = find(app, function(o) { return o.push !== undefined && o.depth !== undefined; }, 0);
        py = find(app, function(o) { return o.importModule !== undefined; }, 0);
        steps = [
            after(function() {
                root.daysPage = stack.currentPage;
                expect("days at start", root.daysPage.dayModel.count, 2);
                shot("01-days");
            }),
            function() {
                py.call("backend.find_tracks_by_day", ["2025-02-01"], function(tracks) {
                    app.path = ["2025-02-01"];
                    stack.push(Qt.resolvedUrl("../../src/ui/Track.qml"), {"model": listModel(tracks)});
                    tick.start();
                });
            },
            after(function() { shot("02-track"); }),
            function() {
                py.call("backend.find_events_by_day_track", ["2025-02-01", "Keynotes"], function(events) {
                    root.events = listModel(events);
                    stack.push(Qt.resolvedUrl("../../src/ui/Schedule.qml"), {"model": root.events});
                    tick.start();
                });
            },
            after(function() { shot("03-schedule"); }),
            after(function() {
                stack.push(Qt.resolvedUrl("../../src/ui/Lecture.qml"), {"model": root.events.get(0)});
            }),
            after(function() { shot("04-lecture"); }),
            after(function() { stack.push(Qt.resolvedUrl("../../src/ui/Now.qml")); }),
            after(function() { shot("05-now"); }),
            function() {
                py.call("backend.toggle", [root.events.get(0)], function(marked) {
                    expect("toggle marked", marked, true);
                    stack.push(Qt.resolvedUrl("../../src/ui/Checked.qml"));
                    tick.start();
                });
            },
            after(function() {
                expect("checked count", stack.currentPage.model.count, 1);
                shot("06-checked");
            }),
            function() {
                var item = stack.currentPage.model.get(0);
                stack.push(Qt.resolvedUrl("../../src/ui/Lecture.qml"), {"model": item});
                py.call("backend.toggle", [item], function(marked) {
                    expect("unmark from lecture page", marked, false);
                    stack.pop();
                    tick.start();
                });
            },
            function() {
                expect("checked count after unmark and back", stack.currentPage.model.count, 0);
                py.call("backend.toggle", [root.events.get(0)], function(marked) {
                    expect("mark again", marked, true);
                    tick.start();
                });
            },
            after(function() { stack.push(Qt.resolvedUrl("../../src/ui/About.qml")); }),
            after(function() { shot("07-about"); }),
            after(function() { stack.push(Qt.resolvedUrl("../../src/ui/Map.qml")); }),
            after(function() { shot("08-map"); }),
            after(function() {
                root.errorDialog = app.showError(
                    "Traceback (most recent call last):\n"
                    + "  File \"/repo/src/backend/__init__.py\", line 1, in fetch\n"
                    + "ValueError: unknown url type: 'htp://x'");
            }),
            after(function() {
                expect("error summary", root.errorDialog.summary, "ValueError: unknown url type: 'htp://x'");
                shot("08b-error");
            }),
            after(function() { root.errorDialog.showDetails = true; }),
            after(function() {
                shot("08c-error-details");
                PopupUtils.close(root.errorDialog);
            }),
            after(function() {
                app.load_schedule(false);
                download("file:///repo/tests/data/missing.xml");
            }),
            after(function() {
                expect("download failure message", downloadDialog() !== null && downloadDialog().error !== "", true);
                shot("09-download-error");
            }),
            after(function() {
                // double tap: the second press must not start a second download
                download("http://127.0.0.1:18765/small-update.xml");
                dialogButton("downloadButton").clicked();
            }),
            after(function() {}),
            after(function() {}),
            after(function() {}),
            after(function() {
                expect("dialog closed after download", downloadDialog(), null);
                shot("10-after-download");
            }),
            after(function() { stack.push(Qt.resolvedUrl("../../src/ui/Checked.qml")); }),
            after(function() {
                expect("checked count after download", stack.currentPage.model.count, 1);
                shot("11-checked-after-download");
            }),
            after(function() {
                // cancel while the download runs
                app.load_schedule(false);
                download("http://127.0.0.1:18765/one-day.xml");
                dialogButton("cancelButton").clicked();
            }),
            after(function() {}),
            after(function() {}),
            after(function() {
                expect("dialog closed after cancel", downloadDialog(), null);
                expect("days reloaded after cancelled dialog", root.daysPage.dayModel.count, 1);
                app.load_schedule(false);
                download("fake");
            }),
            after(function() {
                expect("days reloaded after download", root.daysPage.dayModel.count, 1);
                stack.push(Qt.resolvedUrl("../../src/ui/Now.qml"));
            }),
            after(function() {
                expect("now count (fake schedule)", stack.currentPage.model.count, 2);
                shot("12-now-fake");
            }),
            after(function() {
                // what the header's Home action does
                stack.clear();
                stack.push(Qt.resolvedUrl("../../src/ui/Days.qml"));
            }),
            after(function() { expect("home", stack.depth, 1); }),
        ];
        tick.interval = 2500;
        tick.start();
        tick.interval = 1200;
    }

    property var events: null
    property var errorDialog: null
    property var daysPage: null
}
