/********************************************************************************
** Form generated from reading UI file 'dialog.ui'
**
** Created by: Qt User Interface Compiler version 5.8.0
**
** WARNING! All changes made in this file will be lost when recompiling UI file!
********************************************************************************/

#ifndef UI_DIALOG_H
#define UI_DIALOG_H

#include <QtCore/QVariant>
#include <QtWidgets/QAction>
#include <QtWidgets/QApplication>
#include <QtWidgets/QButtonGroup>
#include <QtWidgets/QDialog>
#include <QtWidgets/QFrame>
#include <QtWidgets/QGraphicsView>
#include <QtWidgets/QGridLayout>
#include <QtWidgets/QHeaderView>
#include <QtWidgets/QLCDNumber>
#include <QtWidgets/QLabel>
#include <QtWidgets/QLineEdit>
#include <QtWidgets/QPushButton>
#include <QtWidgets/QSlider>
#include <QtWidgets/QSpacerItem>
#include <QtWidgets/QVBoxLayout>
#include <QtWidgets/QWidget>

QT_BEGIN_NAMESPACE

class Ui_Dialog
{
public:
    QWidget *layoutWidget;
    QGridLayout *gridLayout;
    QGraphicsView *graphicsView;
    QWidget *layoutWidget_2;
    QVBoxLayout *verticalLayout;
    QLabel *laptime;
    QLCDNumber *Laptime_number;
    QLabel *best_laptime;
    QLCDNumber *best_laptime_number;
    QLabel *Top_speed;
    QLCDNumber *top_speed_number;
    QPushButton *Start;
    QPushButton *Stop;
    QFrame *line;
    QPushButton *Connect;
    QLabel *Connected_label;
    QFrame *line_2;
    QLineEdit *dutycycle;
    QPushButton *dutybutton;
    QFrame *line_3;
    QSpacerItem *verticalSpacer;
    QSlider *pwm_slider;

    void setupUi(QDialog *Dialog)
    {
        if (Dialog->objectName().isEmpty())
            Dialog->setObjectName(QStringLiteral("Dialog"));
        Dialog->resize(1157, 698);
        Dialog->setMinimumSize(QSize(1157, 0));
        Dialog->setMaximumSize(QSize(1157, 16777215));
        layoutWidget = new QWidget(Dialog);
        layoutWidget->setObjectName(QStringLiteral("layoutWidget"));
        layoutWidget->setGeometry(QRect(10, 10, 871, 681));
        gridLayout = new QGridLayout(layoutWidget);
        gridLayout->setSpacing(6);
        gridLayout->setContentsMargins(11, 11, 11, 11);
        gridLayout->setObjectName(QStringLiteral("gridLayout"));
        gridLayout->setSizeConstraint(QLayout::SetNoConstraint);
        gridLayout->setContentsMargins(0, 0, 0, 0);
        graphicsView = new QGraphicsView(layoutWidget);
        graphicsView->setObjectName(QStringLiteral("graphicsView"));
        QSizePolicy sizePolicy(QSizePolicy::Preferred, QSizePolicy::Preferred);
        sizePolicy.setHorizontalStretch(0);
        sizePolicy.setVerticalStretch(0);
        sizePolicy.setHeightForWidth(graphicsView->sizePolicy().hasHeightForWidth());
        graphicsView->setSizePolicy(sizePolicy);

        gridLayout->addWidget(graphicsView, 0, 0, 1, 1);

        layoutWidget_2 = new QWidget(Dialog);
        layoutWidget_2->setObjectName(QStringLiteral("layoutWidget_2"));
        layoutWidget_2->setGeometry(QRect(900, -20, 241, 681));
        verticalLayout = new QVBoxLayout(layoutWidget_2);
        verticalLayout->setSpacing(6);
        verticalLayout->setContentsMargins(11, 11, 11, 11);
        verticalLayout->setObjectName(QStringLiteral("verticalLayout"));
        verticalLayout->setSizeConstraint(QLayout::SetNoConstraint);
        verticalLayout->setContentsMargins(0, 0, 0, 0);
        laptime = new QLabel(layoutWidget_2);
        laptime->setObjectName(QStringLiteral("laptime"));
        QSizePolicy sizePolicy1(QSizePolicy::Preferred, QSizePolicy::Fixed);
        sizePolicy1.setHorizontalStretch(0);
        sizePolicy1.setVerticalStretch(0);
        sizePolicy1.setHeightForWidth(laptime->sizePolicy().hasHeightForWidth());
        laptime->setSizePolicy(sizePolicy1);

        verticalLayout->addWidget(laptime);

        Laptime_number = new QLCDNumber(layoutWidget_2);
        Laptime_number->setObjectName(QStringLiteral("Laptime_number"));
        QSizePolicy sizePolicy2(QSizePolicy::Minimum, QSizePolicy::Fixed);
        sizePolicy2.setHorizontalStretch(0);
        sizePolicy2.setVerticalStretch(0);
        sizePolicy2.setHeightForWidth(Laptime_number->sizePolicy().hasHeightForWidth());
        Laptime_number->setSizePolicy(sizePolicy2);

        verticalLayout->addWidget(Laptime_number);

        best_laptime = new QLabel(layoutWidget_2);
        best_laptime->setObjectName(QStringLiteral("best_laptime"));
        sizePolicy1.setHeightForWidth(best_laptime->sizePolicy().hasHeightForWidth());
        best_laptime->setSizePolicy(sizePolicy1);

        verticalLayout->addWidget(best_laptime);

        best_laptime_number = new QLCDNumber(layoutWidget_2);
        best_laptime_number->setObjectName(QStringLiteral("best_laptime_number"));
        sizePolicy2.setHeightForWidth(best_laptime_number->sizePolicy().hasHeightForWidth());
        best_laptime_number->setSizePolicy(sizePolicy2);

        verticalLayout->addWidget(best_laptime_number);

        Top_speed = new QLabel(layoutWidget_2);
        Top_speed->setObjectName(QStringLiteral("Top_speed"));
        sizePolicy1.setHeightForWidth(Top_speed->sizePolicy().hasHeightForWidth());
        Top_speed->setSizePolicy(sizePolicy1);

        verticalLayout->addWidget(Top_speed);

        top_speed_number = new QLCDNumber(layoutWidget_2);
        top_speed_number->setObjectName(QStringLiteral("top_speed_number"));
        sizePolicy2.setHeightForWidth(top_speed_number->sizePolicy().hasHeightForWidth());
        top_speed_number->setSizePolicy(sizePolicy2);

        verticalLayout->addWidget(top_speed_number);

        Start = new QPushButton(layoutWidget_2);
        Start->setObjectName(QStringLiteral("Start"));
        Start->setMinimumSize(QSize(0, 50));

        verticalLayout->addWidget(Start);

        Stop = new QPushButton(layoutWidget_2);
        Stop->setObjectName(QStringLiteral("Stop"));
        Stop->setMinimumSize(QSize(0, 50));

        verticalLayout->addWidget(Stop);

        line = new QFrame(layoutWidget_2);
        line->setObjectName(QStringLiteral("line"));
        line->setFrameShape(QFrame::HLine);
        line->setFrameShadow(QFrame::Sunken);

        verticalLayout->addWidget(line);

        Connect = new QPushButton(layoutWidget_2);
        Connect->setObjectName(QStringLiteral("Connect"));

        verticalLayout->addWidget(Connect);

        Connected_label = new QLabel(layoutWidget_2);
        Connected_label->setObjectName(QStringLiteral("Connected_label"));

        verticalLayout->addWidget(Connected_label);

        line_2 = new QFrame(layoutWidget_2);
        line_2->setObjectName(QStringLiteral("line_2"));
        line_2->setFrameShape(QFrame::HLine);
        line_2->setFrameShadow(QFrame::Sunken);

        verticalLayout->addWidget(line_2);

        dutycycle = new QLineEdit(layoutWidget_2);
        dutycycle->setObjectName(QStringLiteral("dutycycle"));
        dutycycle->setClearButtonEnabled(false);

        verticalLayout->addWidget(dutycycle);

        dutybutton = new QPushButton(layoutWidget_2);
        dutybutton->setObjectName(QStringLiteral("dutybutton"));

        verticalLayout->addWidget(dutybutton);

        line_3 = new QFrame(layoutWidget_2);
        line_3->setObjectName(QStringLiteral("line_3"));
        line_3->setFrameShape(QFrame::HLine);
        line_3->setFrameShadow(QFrame::Sunken);

        verticalLayout->addWidget(line_3);

        verticalSpacer = new QSpacerItem(20, 20, QSizePolicy::Minimum, QSizePolicy::Expanding);

        verticalLayout->addItem(verticalSpacer);

        pwm_slider = new QSlider(layoutWidget_2);
        pwm_slider->setObjectName(QStringLiteral("pwm_slider"));
        pwm_slider->setMinimum(0);
        pwm_slider->setMaximum(200);
        pwm_slider->setSingleStep(1);
        pwm_slider->setPageStep(1);
        pwm_slider->setValue(100);
        pwm_slider->setSliderPosition(100);
        pwm_slider->setTracking(true);
        pwm_slider->setOrientation(Qt::Horizontal);
        pwm_slider->setInvertedAppearance(false);
        pwm_slider->setInvertedControls(false);

        verticalLayout->addWidget(pwm_slider);


        retranslateUi(Dialog);

        QMetaObject::connectSlotsByName(Dialog);
    } // setupUi

    void retranslateUi(QDialog *Dialog)
    {
        Dialog->setWindowTitle(QApplication::translate("Dialog", "Dialog", Q_NULLPTR));
        laptime->setText(QApplication::translate("Dialog", "Laptime:", Q_NULLPTR));
        best_laptime->setText(QApplication::translate("Dialog", "Best laptime:", Q_NULLPTR));
        Top_speed->setText(QApplication::translate("Dialog", "Top speed:", Q_NULLPTR));
        Start->setText(QApplication::translate("Dialog", "Start", Q_NULLPTR));
        Stop->setText(QApplication::translate("Dialog", "Stop", Q_NULLPTR));
        Connect->setText(QApplication::translate("Dialog", "Connect to Bluetooth", Q_NULLPTR));
        Connected_label->setText(QApplication::translate("Dialog", "Not connected", Q_NULLPTR));
        dutycycle->setPlaceholderText(QApplication::translate("Dialog", "Choose speed (0-100%)", Q_NULLPTR));
        dutybutton->setText(QApplication::translate("Dialog", "Set speed", Q_NULLPTR));
    } // retranslateUi

};

namespace Ui {
    class Dialog: public Ui_Dialog {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_DIALOG_H
