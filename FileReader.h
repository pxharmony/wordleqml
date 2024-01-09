// FileReader.h
#ifndef FILEREADER_H
#define FILEREADER_H

#include <QObject>
#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

class FileReader : public QObject {
    Q_OBJECT
public:
    explicit FileReader(QObject *parent = nullptr) : QObject(parent) {}

    Q_INVOKABLE QStringList readAndProcessWordList(const QString &filePath) {
        QFile file(filePath);
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            return fiveLetterWordsInCaseReadFailure();
        }

        QTextStream in(&file);
        QString jsonDataText = in.readAll();
        QJsonDocument doc = QJsonDocument::fromJson(jsonDataText.toUtf8());

        QStringList wordList;
        if (!doc.isNull()) {
            QJsonObject jsonObj = doc.object();
            QJsonArray jsonWordlist = jsonObj["wordlist"].toArray();
            for (const QJsonValue &value : jsonWordlist) {
                QString word = value.toString();
                if (word.length() == 5) {
                    wordList.append(word);
                }
            }
        }

        if (wordList.isEmpty()) {
            return fiveLetterWordsInCaseReadFailure();
        }

        return wordList;
    }

private:
    QStringList fiveLetterWordsInCaseReadFailure() {
        return {"apple", "table", "chair", "house", "sunny", "water", "hello", "world", "stack", "watch", "glass", "phone", "music", "earth", "clock", "paper", "mouse", "light", "plane", "green", "brown", "white", "black", "beach", "grass", "smile", "dream", "happy"};
    }
};

#endif // FILEREADER_H
