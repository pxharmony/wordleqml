import QtQuick 2.15
import QtQuick.Layouts 1.15
import "WordleConstants.js" as WordleConstants
Rectangle {
    id: toast
    property string message: ""
    property bool success: false
    width: toastText.width + 30
    height: 33 + buttonToast.height
    color: success ? WordleConstants.greenColor : WordleConstants.withouSuccessToastMessageBackgroundColor
    opacity: 0.9
    radius: 8
    visible: false
    z: 9
    ColumnLayout{
         anchors.centerIn: parent
    Text {
        id: toastText
           text: toast.message
           color: WordleConstants.toastMessageTextColor
           font.bold: true
           minimumPixelSize: 10
           wrapMode: Text.WordWrap

           horizontalAlignment: Text.AlignHCenter
           verticalAlignment: Text.AlignVCenter
           width: parent.width
       }
        ButtonWordle {
            id:buttonToast
            Layout.alignment: Qt.AlignHCenter
            text: WordleConstants.newGameButtonText
            backgroundColor: WordleConstants.defaultColorCell
            borderColor: WordleConstants.borderColorNewGameButton
            implicitWidth: toast.width/3
            implicitHeight: 30
            opacity: 0.9
            font.bold: true
            onClicked: {
                initializeGame()
                 toast.visible = false
            }
            visible: isGameOver
        }
    }
    Timer {
        id: hideTimer
        interval: WordleConstants.toastMessageDisplayTimeMs
        onTriggered: toast.visible = false
    }

    function showToastMessage(msg, isSuccess, isStay) {
        toast.message = msg
        toast.success = isSuccess
        toast.visible = true
        if(isStay === true){
            hideTimer.stop()
        }
        if(isStay === false)
            hideTimer.restart()
    }
}
