#include "mainwindow.h"
#include "./ui_mainwindow.h"
#include <QDir>
#include <QQmlContext>
#include "FileReader.h"
MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , quick_view_wordle_(new QQuickView())
    , container_widget_(QWidget::createWindowContainer(quick_view_wordle_,this))
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    container_widget_->setParent(ui->widget);
    container_widget_->setFixedSize(ui->centralwidget->size());
    QString path = QCoreApplication::applicationDirPath();
    qmlRegisterType<FileReader>("FileReader", 1, 0, "FileReader");
    quick_view_wordle_->rootContext()->setContextProperty("appDirPath",path);
    quick_view_wordle_->setSource(QUrl("qrc:/resources/WordleView.qml"));
    quick_view_wordle_->setResizeMode(QQuickView::ResizeMode::SizeViewToRootObject);
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::resizeEvent(QResizeEvent *event)
{
   container_widget_->setFixedSize(ui->centralwidget->size());
}
