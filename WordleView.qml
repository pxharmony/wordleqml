import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import Qt.labs.platform 1.1
import QtWebView 1.2
import FileReader 1.0
import "WordleConstants.js" as WordleConstants
Rectangle {
    id:parentRec
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0
    color: WordleConstants.defaultMainRecBackgroundColor
    property string secretWord: generateRandomWord()

    property int currentAttempt: 0
    property ListModel gridModel: ListModel {}
    property bool isGameOver: false
    property var words: []
    property int scaleVal: parentRec.height/16
    property var letterColors: ({})
    property var letterWords: ({})
    signal updateKeyboard()
    property string currentGuess: ""
    property var guessedWords: [];
    property real lastKeyPressTime: 0
    property real keyPressDelay: 500
    property bool isModified: false
    property string oldCurrentGuess: ""
    focus: true
    onFocusChanged: focus = true
    Keys.enabled: true
    ToastMessage {
        id: toastMessage
        anchors.horizontalCenter: parentRec.horizontalCenter
        y: parentRec.height/15
    }

    Rectangle {
        anchors.fill: parent

        WebView {
            id: webView
            anchors.fill: parent
            url: WordleConstants.particlesHTMLNameWSuffix
        }
    }

    //TODO: Delay workaround. Connect to the end of animation
    Timer {
        id: updateKeyboardTimer
        interval: 1000
        onTriggered: {
            updateKeyboard();
        }
    }

    Timer {
        id: shakeTimer
        interval: 50
        repeat: true
        property int shakeCount: 0
        property int maxShakes: 12
        property int shakeMagnitude: 4
        property var cellsToShake: []

        onTriggered: {
            if (shakeCount < maxShakes) {
                var moveLeft = shakeCount % 2 === 0;
                for (var i = 0; i < cellsToShake.length; ++i) {
                    var cell = cellsToShake[i];
                    cell.x += moveLeft ? -shakeMagnitude : shakeMagnitude;
                }
                shakeCount++;
            } else {
                shakeTimer.stop();
                shakeTimer.shakeCount = 0;
                for (var j = 0; j < cellsToShake.length; ++j) {
                    var cell_ = cellsToShake[j];
                    if(cell_)
                        cell_.x = cell_.currentX;
                }
                shakeTimer.cellsToShake = [];
            }
        }
    }
    FileReader {
        id: fileReader
    }

    Keys.onPressed:
        (event)=>
        {
            if(isGameOver){
                return
            }
            if (event.key === Qt.Key_Enter | event.key === Qt.Key_Return && isModified) {
                if (currentGuess.length === WordleConstants.wordLength) {;
                    submitGuess();
                }
                event.accepted = true;
            } else if ((event.key === Qt.Key_Backspace | event.key === Qt.Key_Delete) && currentGuess.length > 0) {
                currentGuess = currentGuess.substring(0, currentGuess.length - 1);
                updateCell()
                event.accepted = true;
            } else {
                var pressedChar = String.fromCharCode(event.key);
                if (pressedChar.match(WordleConstants.regexForKeyboardEnterence) && currentGuess.length < WordleConstants.wordLength) {
                    currentGuess += pressedChar.toUpperCase();
                    updateCell()
                    event.accepted = true;
                } else {
                    event.accepted = false;
                }
            }
            oldCurrentGuess = currentGuess
        }
    function initializeGame() {
        secretWord = generateRandomWord().toUpperCase()
        isGameOver = false
        console.log("Secret word is:" + secretWord);
        currentAttempt = 0;
        gridModel.clear();
        for (var i = 0; i < WordleConstants.maxAttempts * WordleConstants.wordLength; i++) {
            gridModel.append({ letter: "", color: WordleConstants.defaultColorCell});
        }
        resetToDefault()
        guessedWords = []
        isModified = false
        currentGuess = ""

    }

    function generateRandomWord() {
        return words[Math.floor(Math.random() * words.length)];
    }

    function handleButtonPress(pressedText) {
        if (pressedText === WordleConstants.delText) {
            currentGuess = currentGuess.substring(0, currentGuess.length - 1);
        } else if (currentGuess.length < WordleConstants.wordLength) {
            currentGuess += pressedText.toUpperCase();
        }
        isModified = true
        updateCell();
    }

    function resetToDefault(){
        letterWords = {}
        WordleConstants.keyboardLetters.split("").forEach(function(letter) {
            letterWords[letter] = WordleConstants.defaultButtonColor;
        });
        updateKeyboard()
    }

    function getLetterCellColor(letter) {
        return letterWords[letter] || WordleConstants.defaultButtonColor;
    }

    function updateKeyboardLetters() {
        var letterColors = {};
        if(guessedWords.length < 0){
            console.log("guessed list empty returning.")
            return
        }
        for (const guessedWord of guessedWords) {
            for (let i = 0; i < guessedWord.length; i++) {
                let ch = guessedWord[i];
                if (letterColors[ch] === WordleConstants.greenColor) {
                    continue;
                }
                if (secretWord[i] === ch) {
                    letterColors[ch] = WordleConstants.greenColor;
                } else if (secretWord.includes(ch) && letterColors[ch] !== WordleConstants.greenColor) {
                    letterColors[ch] = WordleConstants.yellowColor;
                } else {
                    letterColors[ch] = WordleConstants.darkButtonColor;
                }
            }
        }
        for (const letter in letterWords) {
            if (letterColors[letter]) {
                letterWords[letter] = letterColors[letter];
            }
        }
        updateKeyboardTimer.restart();
    }

    function shakeRow(startIndex, endIndex) {
        var cells = [];
        for (var i = startIndex; i <= endIndex; i++) {
            var cell = guessesGrid.children[i];
            cell.currentX = cell.x;
            cells.push(cell);
        }
        shakeTimer.cellsToShake = cells;
        shakeTimer.start();
    }

    function submitGuess()
    {
        if (currentGuess.length !== WordleConstants.wordLength || !isWordValid(currentGuess)) {
            console.log("submitGuess() word is not valid. guess cells will shake")
            var startIndex = currentAttempt * WordleConstants.wordLength;
            var endIndex = startIndex + WordleConstants.wordLength - 1;
            shakeRow(startIndex, endIndex);

            toastMessage.showToastMessage(WordleConstants.notValidMessage, false, isGameOver)
            return;
        }

        updateGuessCells(currentGuess);
        currentAttempt++;

        var isGameWin = true
        if(currentAttempt >= WordleConstants.maxAttempts) {
            showToastMessage(!isGameWin);
        }
        else if (currentGuess.toUpperCase() === secretWord){
            showToastMessage(isGameWin);
        }

        guessedWords.push(currentGuess);
        updateKeyboardLetters()
        currentGuess = ""

        console.log("guessed words: " + guessedWords)
    }

    function showToastMessage(isWin) {
        var message = isWin ?  WordleConstants.successMessage : WordleConstants.gameIsOverMessage + secretWord.toUpperCase();
        isGameOver = true
        toastMessage.showToastMessage(message,isWin, isGameOver)
    }

    function updateGuessCells(guess) {
        var startIndex = currentAttempt * WordleConstants.wordLength;
        if(startIndex >= WordleConstants.maxAttempts * WordleConstants.wordLength)
            return
        for (var i = 0; i < guess.length; i++) {
            var letter = guess.charAt(i);
            var color = getLetterColor(letter, i,guess);
            gridModel.setProperty(startIndex + i, "letter", letter);
            gridModel.setProperty(startIndex + i, "color", color);
        }
    }
    //refactor
    function updateCell() {
        var guess = currentGuess
        var startIndex = currentAttempt * WordleConstants.wordLength;
        for (var i = 0; i < WordleConstants.wordLength; i++) {
            var letter = ""
            if(i < currentGuess.length){
                letter = guess.charAt(i)
                if(guess.charAt(i+1) === "")
                    animateRowSizeChange(startIndex+i,startIndex+i)
            }else{
                letter = ""
            }
            gridModel.setProperty(startIndex + i, "letter", letter);
            gridModel.setProperty(startIndex + i, "color", WordleConstants.defaultColorCell);
        }
        isModified = true
    }
    function animateRowSizeChange(startIndex, endIndex) {
        for (var i = startIndex; i <= endIndex; i++) {
            var cell = guessesGrid.children[i];
            var scaleAnimation = Qt.createQmlObject('import QtQuick 2.0; PropertyAnimation {}', cell);
            scaleAnimation.target = cell;
            scaleAnimation.property = "scale";
            scaleAnimation.from = 1;
            scaleAnimation.to = 1.2;
            scaleAnimation.duration = 150;
            scaleAnimation.easing.type = Easing.InOutQuad;

            var returnAnimation = Qt.createQmlObject('import QtQuick 2.0; PropertyAnimation {}', cell);
            returnAnimation.target = cell;
            returnAnimation.property = "scale";
            returnAnimation.from = 1.2;
            returnAnimation.to = 1;
            returnAnimation.duration = 150;
            returnAnimation.easing.type = Easing.InOutQuad;
            scaleAnimation.start();
            returnAnimation.start();
        }
    }

    function isWordValid(word) {
        word = word.toUpperCase();
        for (var i = 0; i < words.length; i++) {
            if (words[i].toUpperCase() === word) {
                return true;
            }
        }
        isModified = false
        return false;
    }

    function getLetterColor(letter, index, guessedWord) {
        letter = letter.toUpperCase();
        guessedWord = guessedWord.toUpperCase();
        var letterCount = {};
        var resultColors = new Array(guessedWord.length).fill(WordleConstants.darkButtonColor);

        for (var i = 0; i < secretWord.length; i++) {
            var secretChar = secretWord.charAt(i);
            if (!letterCount[secretChar]) {
                letterCount[secretChar] = 0;
            }
            letterCount[secretChar]++;
        }
        for (var j = 0; j < guessedWord.length; j++) {
            var guessedChar = guessedWord.charAt(j);
            if (guessedChar === secretWord.charAt(j)) {
                resultColors[j] = WordleConstants.greenColor;
                letterCount[guessedChar]--;
            }
        }
        for (var k = 0; k < guessedWord.length; k++) {
            var guessedCharSecond = guessedWord.charAt(k);
            if (guessedCharSecond !== secretWord.charAt(k) && secretWord.includes(guessedCharSecond) && letterCount[guessedCharSecond] > 0) {
                resultColors[k] = WordleConstants.yellowColor;
                letterCount[guessedCharSecond]--;
            }
        }

        return resultColors[index];
    }


    ColumnLayout {
        id:cells
        focus: true
        anchors.centerIn: parentRec

        Grid {
            id: guessesGrid
            columns: WordleConstants.wordLength
            spacing: WordleConstants.cellsSpacing
            Repeater {
                model: gridModel
                Rectangle {
                    id: guessCell
                    width: scaleVal
                    height: scaleVal
                    color: model.color
                    opacity:{ if(model.color === WordleConstants.defaultColorCell){
                            return 0.8
                        }else{
                            return 1
                        }

                    }
                    border.width: 2
                    border.color: {if(model.color === WordleConstants.borderColor){
                            return model.color
                        }else{
                            return WordleConstants.borderColor
                        }
                    }
                    property int currentX: 0
                    Behavior on color {
                        SequentialAnimation {
                            ScriptAction {
                                script: {
                                    guessCell.border.color = WordleConstants.borderColor;
                                    letterText.visible = false;

                                }
                            }
                            PauseAnimation {
                                duration: Math.max(0, index % WordleConstants.wordLength * 150)
                            }
                            ParallelAnimation {
                                PropertyAnimation {
                                    target: guessCell
                                    property: "height"
                                    to: 0
                                    duration: 300
                                }
                                PropertyAnimation {
                                    target: guessCell
                                    property: "color"
                                    to: WordleConstants.defaultColorCell
                                    duration: 300
                                }
                            }
                            ParallelAnimation {
                                PropertyAnimation {
                                    target: guessCell
                                    property: "height"
                                    to: scaleVal
                                    duration: 300
                                }
                                ScriptAction {
                                    script: {
                                        guessCell.border.color = model.color;
                                    }
                                }
                                PropertyAnimation {
                                    target: guessCell
                                    property: "color"
                                    to: model.color
                                    duration: 300
                                }
                            }
                            ScriptAction {
                                script: {
                                    letterText.visible = true;
                                }
                            }
                        }
                    }
                    Text {
                        id: letterText
                        anchors.centerIn: parent
                        text: model.letter
                        color: WordleConstants.gridTextColor
                        font.pixelSize: guessesGrid.width/13
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
        Item{
            id: spacerItem
            height: 5
        }
        ColumnLayout {
            id:buttonsLayout
            implicitWidth: guessesGrid.width +40
            RowLayout {
                Layout.leftMargin: -guessesGrid.width/20
                Repeater {

                    model: WordleConstants.row1Keys
                    delegate: ButtonWordle {
                        backgroundColor: {
                            parentRec.updateKeyboard.connect(
                                        function() { backgroundColor = getLetterCellColor(text); })
                        }

                        font.pixelSize: guessesGrid.width/15
                        font.bold: true
                        text: modelData
                        enabled: if( text === WordleConstants.enterText){
                                     !isGameOver
                                 }else{
                                     true
                                 }
                        onPressed: {
                            if(currentGuess.length !== WordleConstants.wordLength)
                                !isGameOver ? parentRec.handleButtonPress(text) : ""
                        }
                    }
                }
            }
            RowLayout {
                Repeater {
                    model: WordleConstants.row2Keys
                    delegate: ButtonWordle {
                        backgroundColor: {
                            parentRec.updateKeyboard.connect(
                                        function() { backgroundColor = getLetterCellColor(text); })
                        }
                        font.bold: true
                        font.pixelSize: guessesGrid.width/15
                        text: modelData
                        enabled: if( text === WordleConstants.enterText && guessedWords.length === WordleConstants.maxAttempt){
                                     !isGameOver
                                 }else{
                                     true
                                 }
                        onPressed: {
                            if(currentGuess.length !== WordleConstants.wordLength)
                                !isGameOver ? parentRec.handleButtonPress(text) : ""
                        }
                    }
                }
            }
            RowLayout {
                Layout.leftMargin: -guessesGrid.width/25
                Repeater {
                    model: WordleConstants.row3Keys
                    delegate: ButtonWordle {
                        backgroundColor: {
                            parentRec.updateKeyboard.connect( function() { backgroundColor = getLetterCellColor(text); })
                        }
                        font.pixelSize: if(text === WordleConstants.delText || text === WordleConstants.enterText){
                                            guessesGrid.width/25
                                        }else{
                                            guessesGrid.width/15
                                        }
                        enabled: if( text === WordleConstants.enterText && guessedWords.length === WordleConstants.maxAttempt){
                                     !isGameOver
                                 }else{
                                     true
                                 }
                        font.bold: true
                        text: modelData
                        onPressed: {
                            if(text === WordleConstants.enterText && currentGuess.length === WordleConstants.wordLength && isModified){
                                submitGuess()
                                return
                            }
                            if(text !== WordleConstants.enterText  && currentGuess.length !== WordleConstants.wordLength){
                                !isGameOver ? parentRec.handleButtonPress(text) : ""
                                return
                            }
                            if(text === WordleConstants.delText){
                                !isGameOver ? parentRec.handleButtonPress(text) : ""
                            }
                        }
                    }
                }
            }
        }
    }
    Component.onCompleted: {
        words = fileReader.readAndProcessWordList(appDirPath + "/" + WordleConstants.wordlistJsonFileNameWSuffix);
        //console.log("Word List:", words);
        initializeGame()
        forceActiveFocus();
    }
}
