import QtQuick 2.3
import QtQuick.Controls 1.0
import QtQuick.Window 2.2

Window {
    id: root

    visible: true
    width: 200
    height: 180
    title: qsTr("Hello World")

    property string response

    Column {
        anchors.centerIn: parent

        TextField {
            id: nameField

            placeholderText: qsTr("Name")
        }

        Button {
            text: qsTr("Send")

            onClicked: root.response = grpcManager.send(nameField.text)
        }

        Text {
            text: qsTr("Response: %1").arg(response)
        }
    }
}
