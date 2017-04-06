#include "dialog.h"
#include <QApplication>
#include <QWindow>
#include <QComboBox>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    Dialog w;
    w.show();
    return a.exec();
}
