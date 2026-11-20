import QtQuick 2.9

// Screenshots of the main features for the README, taken with the demo
// ("fake") schedule. Run through tools/screenshots.sh.
Item {
    id: root
    width: 420
    height: 760

    property var app: loader.item
    property var py: null
    property var stack: null
    property var steps: []
    property int stepIndex: 0
    property var talk: null

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

    // grabToImage waits for the next frame, so force one
    Rectangle {
        id: frameKick
        width: 1
        height: 1
        z: 1000
        color: "transparent"
    }

    function shot(name) {
        frameKick.color = frameKick.color == "#00000000" ? "#01000000" : "#00000000";
        (root.parent || root).grabToImage(function(result) {
            result.saveToFile("/out/" + name + ".png");
            console.log("SHOT " + name);
        });
    }

    function push(page, props) {
        stack.push(Qt.resolvedUrl("../../src/ui/" + page), props || {});
    }

    function next() {
        if (stepIndex >= steps.length) {
            console.log("SHOTS DONE");
            Qt.quit();
            return;
        }
        steps[stepIndex++]();
    }

    Timer {
        id: tick
        interval: 1500
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
                // no schedule yet: the app opened the download dialog
                var dialog = find(root, function(o) { return o.progress_visible !== undefined; }, 0);
                find(dialog, function(o) { return o.objectName === "downloadUrl"; }, 0).text = "fake";
                find(dialog, function(o) { return o.objectName === "downloadButton"; }, 0).clicked();
            }),
            function() {
                py.call("backend.save_note", [0, "Measure first: py-spy record -o profile.svg\nFlame graph shows json.loads as hot path", 1003], function() {
                    py.call("backend.save_note", [0, "Hallway track: ask the UBports folks about Lomiri on PinePhone"], function() {
                        app.notesChanged();
                        tick.start();
                    });
                });
            },
            after(function() { shot("days"); }),
            after(function() { push("Now.qml"); }),
            after(function() { shot("now"); }),
            function() {
                py.call("backend.search", ["python performance"], function(found) {
                    var model = Qt.createQmlObject("import QtQuick 2.9; ListModel {}", root);
                    model.append(found[0]);
                    root.talk = model;
                    push("Lecture.qml", {"model": model.get(0)});
                    tick.start();
                });
            },
            after(function() { shot("talk"); }),
            after(function() { push("Checked.qml"); }),
            after(function() { shot("agenda"); }),
            after(function() { push("Search.qml"); }),
            after(function() {
                find(stack.currentPage, function(o) { return o.objectName === "searchField"; }, 0).text = "python";
            }),
            after(function() { shot("search"); }),
            after(function() { push("Notes.qml"); }),
            after(function() { shot("notes"); }),
        ];
        tick.interval = 3000;
        tick.start();
        tick.interval = 1500;
    }
}
