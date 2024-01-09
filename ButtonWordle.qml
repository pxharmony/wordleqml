import QtQuick 2.15
import QtQuick.Templates 2.15 as T
import QtQuick.Controls 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Material.impl 2.15
import "WordleConstants.js" as WordleConstants
T.Button {
    id: control
    x: -30
    implicitWidth: if(control.text === WordleConstants.delText || control.text === WordleConstants.enterText){
                    guessesGrid.width/6 - 10
                   } else guessesGrid.width/9 - 5
    implicitHeight: guessesGrid.width/9 + 2
    property string backgroundColor: WordleConstants.defaultColorCell
    property string borderColor: "transparent"
    property int borderWidth: 2
    Material.background: flat ? "transparent" : undefined

    contentItem: Text {
        text: control.text
        font: control.font

        color: {
                if(backgroundColor === WordleConstants.defaultButtonColor){
                    return WordleConstants.buttonTextColorBlack
                }else{
                    return WordleConstants.buttonTextColorWhite
                }
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        id:backgroundRecAlphabetButton
        radius: 2
        color: backgroundColor
        opacity: 0.9
        border.color: borderColor
        border.width: borderWidth
        PaddedRectangle {

            width: parent.width
            height: 4
            radius: 2
            topPadding: -2
            clip: true
            visible: control.checkable && (!control.highlighted || control.flat)
            color: control.checked && control.enabled ? control.Material.accentColor : control.Material.secondaryTextColor
        }
        layer.effect: ElevationEffect {
            elevation: control.Material.elevation
        }

        Ripple {
            clipRadius: 2
            width: parent.width
            height: parent.height
            pressed: control.pressed
            anchor: control
            active: control.down || control.visualFocus || control.hovered
            color: control.Material.rippleColor
        }
    }
}
