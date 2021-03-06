/*
 * Copyright (C) 2016 Stuart Howarth <showarth@marxoft.co.uk>
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

#ifndef PLUGINPLAYLIST_H
#define PLUGINPLAYLIST_H

#include "playlist.h"
#include "resourcesrequest.h"

class PluginPlaylist : public CTPlaylist
{
    Q_OBJECT
    
    Q_PROPERTY(QString videosId READ videosId NOTIFY videosIdChanged)
    Q_PROPERTY(QString errorString READ errorString NOTIFY statusChanged)
    Q_PROPERTY(ResourcesRequest::Status status READ status NOTIFY statusChanged)

public:
    explicit PluginPlaylist(QObject *parent = 0);
    explicit PluginPlaylist(const QString &service, const QString &id, QObject *parent = 0);
    explicit PluginPlaylist(const QString &service, const QVariantMap &playlist, QObject *parent = 0);
    explicit PluginPlaylist(const PluginPlaylist *playlist, QObject *parent = 0);
    
    QString videosId() const;
    
    QString errorString() const;
        
    ResourcesRequest::Status status() const;
        
    Q_INVOKABLE void loadPlaylist(const QString &service, const QString &id);
    Q_INVOKABLE void loadPlaylist(const QString &service, const QVariantMap &playlist);
    Q_INVOKABLE void loadPlaylist(PluginPlaylist *playlist);

protected:
    void setVideosId(const QString &i);

private Q_SLOTS:
    void onRequestFinished();
    
Q_SIGNALS:
    void videosIdChanged();
    void statusChanged(ResourcesRequest::Status s);

private:
    ResourcesRequest* request();
    
    ResourcesRequest *m_request;
    
    QString m_videosId;
};

#endif // PLUGINPLAYLIST_H
