import QtQuick 2.15

Item {
    id: root
    property alias frontImage: frontImg.source
    property alias backImage: backImg.source
    property alias spineImage: spineImg.source
    property real spineWidth: 40
    property real imageWidth: 300
    property real imageHeight: 400
    property real rotationAngle: 0

    width: imageWidth + spineWidth
    height: imageHeight

    // Projection math
    property real rad: rotationAngle * Math.PI / 180
    property real cosR: Math.cos(rad)
    property real sinR: Math.sin(rad)

    property real frontW: imageWidth * Math.abs(cosR)
    property real spineW: spineWidth * Math.abs(sinR)

    property bool frontVisible: cosR >= 0
    property bool spineOnLeft: sinR >= 0

    // Fixed width container to prevent the whole box from shrinking
    Item {
        width: root.imageWidth + root.spineWidth
        height: root.imageHeight
        anchors.centerIn: parent

        // Front face
        Item {
            x: root.spineOnLeft ? root.spineW : 0
            y: 0
            width: root.frontW
            height: root.imageHeight
            clip: true
            visible: root.frontVisible

            Image {
                id: frontImg
                anchors.fill: parent
                fillMode: Image.PreserveAspectFill
                asynchronous: true
                smooth: true
            }
            Rectangle {
                anchors.fill: parent
                color: "black"
                opacity: 1 - (0.72 + 0.28 * Math.abs(root.cosR))
            }
        }

        // Back face
        Item {
            x: root.spineOnLeft ? root.spineW : 0
            y: 0
            width: root.frontW
            height: root.imageHeight
            clip: true
            visible: !root.frontVisible

            Image {
                id: backImg
                anchors.fill: parent
                fillMode: Image.PreserveAspectFill
                asynchronous: true
                smooth: true
            }
            Rectangle {
                anchors.fill: parent
                color: "#0d0d1a"
                visible: !(root.backImage)
            }
            Rectangle {
                anchors.fill: parent
                color: "black"
                opacity: 1 - (0.72 + 0.28 * Math.abs(root.cosR))
            }
        }

        // Spine face
        Item {
            x: root.spineOnLeft ? 0 : root.frontW
            y: 0
            width: root.spineW
            height: root.imageHeight
            clip: true

            Image {
                id: spineImg
                width: root.imageHeight
                height: root.spineWidth
                source: root.spineImage
                fillMode: Image.Stretch
                asynchronous: true
                smooth: true
                transformOrigin: Item.TopLeft
                rotation: 90
                x: 0
                y: -root.spineWidth
                visible: status === Image.Ready && (root.spineImage)
            }
            Rectangle {
                anchors.fill: parent
                color: "#0a0a18"
                visible: !spineImg.visible
            }
            Rectangle {
                anchors.fill: parent
                color: "black"
                opacity: 1 - (0.30 + 0.25 * Math.abs(root.sinR))
            }
        }

        // Top/Bottom edges
        Rectangle {
            x: root.spineOnLeft ? root.spineW : 0; y: -3
            width: root.frontW; height: 3
            color: "#1a1a30"; opacity: 0.9
        }
        Rectangle {
            x: root.spineOnLeft ? root.spineW : 0; y: root.imageHeight
            width: root.frontW; height: 3
            color: "#08080f"; opacity: 0.9
        }
    }

    MouseArea {
        anchors.fill: parent
        property real lastX: 0
        onPressed: { lastX = mouse.x }
        onPositionChanged: {
            var delta = mouse.x - lastX
            lastX = mouse.x
            root.rotationAngle += delta * 0.5
            if (root.rotationAngle > 180) root.rotationAngle = -180
            else if (root.rotationAngle < -180) root.rotationAngle = 180
        }
    }
}
