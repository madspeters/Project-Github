#include "dialog.h"
#include "ui_dialog.h"
#include <QGraphicsScene>
#include <QGraphicsview>
#include <QGraphicsItem>
#include <QGraphicsObject>
#include <QPixmap>
#include <vector>
#include <QPen>
#include <QMenuBar>
#include <iostream>
#include <QPainterPath>
#include <QSerialPort>
#include <QSerialPortInfo>
#include <QString>
#include <QDebug>
#include <QIODevice>
#include <QByteArray>
#include <QDataStream>
#include <QObject>

using namespace std;
Dialog::Dialog(QWidget *parent) :

    QDialog(parent),
    ui(new Ui::Dialog)
{
    ui->setupUi(this);
    serial = new QSerialPort(this);


    scene = new QGraphicsScene(this);
    ui->graphicsView->setScene(scene);
    QObject::connect(serial, SIGNAL(readyRead()), this, SLOT(readSerial()));
}

Dialog::~Dialog()
{
    serial->close();
    delete ui;
}


// Når startknappen klikkes

void Dialog::readSerial(){
    QByteArray datafrabil;
    serial->waitForReadyRead(2000);
    datafrabil.append(serial->read(1));
    qDebug() << (int)datafrabil.at(0);
}

void Dialog::on_Start_clicked()
{
    char data[1];
    data[0] = '60';
    serial->write(data);


}

// Når stopknappen klikkes
void Dialog::on_Stop_clicked()
{
    char data[1];
    data[0] = '0';
    serial->write(data);

}


void Dialog::on_Connect_clicked()
{
    ui->Connected_label->setText("Connecting... ");
    serial->setPortName("COM3"); //dev/tty.Bluetooth-Incoming-Port
    serial->setPortName("/dev/tty.RNBT-7996-RNI-SPP");
    serial->open(QSerialPort::ReadWrite);
    serial->setBaudRate(QSerialPort::Baud9600);
    serial->setDataBits(QSerialPort::Data8);
    serial->setParity(QSerialPort::NoParity);
    serial->setStopBits(QSerialPort::OneStop);
    serial->setFlowControl(QSerialPort::NoFlowControl);
    if(serial->isOpen())
        ui->Connected_label->setText("You are connected!");
    else
        ui->Connected_label->setText("Bitch you messed up");
}


void Dialog::on_dutybutton_clicked()
{
    if (ui->dutycycle->text().length() > 0){
    char data[1];
    string talstring;
    int omregning;
    talstring = ui->dutycycle->text().toStdString();
    omregning = (stoi(talstring)/100.0)*256.0;
    data[0] = (char)omregning;
    serial->write(data);
    }
    else
        ui->dutycycle->setPlaceholderText("You must enter a valid number");

}
