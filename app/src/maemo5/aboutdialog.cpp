/*
 * Copyright (C) 2014 Stuart Howarth <showarth@marxoft.co.uk>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms and conditions of the GNU General Public License,
 * version 3, as published by the Free Software Foundation.
 *
 * This program is distributed in the hope it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
 */

#include "aboutdialog.h"
#include "definitions.h"
#include <QDesktopServices>
#include <QUrl>
#include <QLabel>
#include <QDialogButtonBox>
#include <QPushButton>
#include <QGridLayout>

AboutDialog::AboutDialog(QWidget *parent) :
    Dialog(parent)
{
    setWindowTitle(tr("About"));

    QLabel *imageLabel = new QLabel(this);
    imageLabel->setPixmap(QPixmap("/usr/share/icons/hicolor/64x64/apps/cutetube2.png"));
    imageLabel->setFixedWidth(64);
    QLabel *titleLabel = new QLabel(QString("<b><font size='20'>cuteTube2 %1</font></b>").arg(VERSION_NUMBER), this);
    titleLabel->setAlignment(Qt::AlignVCenter);
    QLabel *descriptionLabel = new QLabel("A feature-rich client for YouTube, Dailymotion and Vimeo that can be \
    extended via plugins.<br><br>&copy; Stuart Howarth 2016", this);
    descriptionLabel->setWordWrap(true);
    QDialogButtonBox *buttonBox = new QDialogButtonBox(Qt::Vertical, this);
    QPushButton *bugButton = new QPushButton(tr("Report bug"), this);
    buttonBox->addButton(bugButton, QDialogButtonBox::ActionRole);

    QGridLayout *grid = new QGridLayout(this);
    grid->addWidget(imageLabel, 0, 0);
    grid->addWidget(titleLabel, 0, 1);
    grid->addWidget(descriptionLabel, 1, 0, 1, 2);
    grid->addWidget(buttonBox, 1, 2);

    connect(bugButton, SIGNAL(clicked()), this, SLOT(reportBug()));
}

void AboutDialog::reportBug() {
    QDesktopServices::openUrl(QString("mailto:showarth@marxoft.co.uk?subject=cuteTube2 %1 for Maemo5")
                                     .arg(VERSION_NUMBER));
    accept();
}
