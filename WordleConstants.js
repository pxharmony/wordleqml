.pragma library

var maxAttempts = 6
var wordLength = 5
var cellsSpacing = 7
var toastMessageDisplayTimeMs = 2000

var wordlistJsonFileNameWSuffix = "wordlist.json"
var particlesHTMLNameWSuffix = "particles.html"

var defaultButtonColor = "#c0c0c0"
var greenColor = "#6ca965"
var yellowColor = "#c8b653"
var darkButtonColor = "#212529"
var darkButtonColorNewGame = "#5A5A5A"
var toastMessageTextColor = "white"
var withouSuccessToastMessageBackgroundColor = "#212529"
var buttonTextColorBlack = "black"
var buttonTextColorWhite = "white"
var gridTextColor = "white"
var borderColorNewGameButton = "white"
var defaultColorCell = "black"
var defaultMainRecBackgroundColor = "#1B1212"
var borderColor = "grey"

var delText ="Del"
var enterText ="Enter"
var row1Keys = ["Q", "W", "E", "R", "T", "Y", "U", "I","O", "P"]
var row2Keys = ["A", "S", "D", "F", "G", "H", "J", "K", "L"]
var row3Keys = [enterText,"Z", "X", "C", "V", "B", "N", "M",delText]
var keyboardLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
var notValidMessage = "Word is not valid in game dictionary"
var successMessage = "Congratulations! You guessed the word."
var gameIsOverMessage =  "Game Over. The word was: "
var newGameButtonText =  "New Game"


var regexForKeyboardEnterence = /^[A-Za-z]$/

