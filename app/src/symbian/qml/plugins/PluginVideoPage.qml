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

import QtQuick 1.1
import com.nokia.symbian 1.1
import cuteTube 2.0
import ".."

MyPage {
    id: root

    function load(videoOrId) {
        if (videoOrId.hasOwnProperty("id")) {
            video.loadVideo(videoOrId);

            if (video.userId) {
                user.loadUser(video.service, video.userId);
            }
        }
        else {
            video.loadVideo(Settings.currentService, videoOrId);
        }
    }

    title: view.currentTab.title
    showProgressIndicator: (video.status == ResourcesRequest.Loading)
                           || (user.status == ResourcesRequest.Loading)
                           || (view.currentTab.showProgressIndicator)

    tools: view.currentTab.tools ? view.currentTab.tools : ownTools
    onToolsChanged: if (status == PageStatus.Active) appWindow.pageStack.toolBar.setTools(tools, "set");

    ToolBarLayout {
        id: ownTools

        visible: false

        BackToolButton {}
    }

    PluginVideo {
        id: video

        onStatusChanged: {
            switch (status) {
            case ResourcesRequest.Ready:
                if ((userId) && (userId != !user.id)) {
                    user.loadUser(service, userId);
                }

                break;
            case ResourcesRequest.Failed:
                infoBanner.showMessage(errorString);
                break;
            default:
                break;
            }
        }
    }

    PluginUser {
        id: user

        onStatusChanged: if (status == ResourcesRequest.Failed) infoBanner.showMessage(errorString);
    }

    TabView {
        id: view

        anchors.fill: parent
        visible: video.id != ""

        Tab {
            id: infoTab

            width: view.width
            height: view.height
            title: qsTr("Video info")
            tools: ToolBarLayout {
                BackToolButton {}

                MyToolButton {
                    iconSource: "toolbar-view-menu"
                    toolTipText: qsTr("Options")
                    enabled: video.id != ""
                    onClicked: menu.open()
                }
            }

            MyMenu {
                id: menu

                focusItem: flicker

                MenuLayout {

                    MenuItem {
                        text: qsTr("Download")
                        enabled: video.downloadable
                        onClicked: {
                            dialogLoader.sourceComponent = downloadDialog;
                            dialogLoader.item.videoId = video.id;
                            dialogLoader.item.videoTitle = video.title;
                            dialogLoader.item.streamUrl = video.streamUrl;
                            dialogLoader.item.listSubtitles = video.subtitles;
                            dialogLoader.item.open();
                        }
                    }

                    MenuItem {
                        text: qsTr("Copy URL")
                        onClicked: {
                            Clipboard.text = video.url;
                            infoBanner.showMessage(qsTr("URL copied to clipboard"));
                        }
                    }
                }
            }

            VideoThumbnail {
                id: thumbnail

                z: 10
                width: parent.width - platformStyle.paddingLarge * 2
                height: Math.floor(width * 3 / 4)
                anchors {
                    left: parent.left
                    top: parent.top
                    margins: platformStyle.paddingLarge
                }
                source: video.largeThumbnailUrl
                durationText: video.duration
                enabled: video.id ? true : false
                onClicked: {
                    if (Settings.videoPlayer == "cutetube") {
                        appWindow.pageStack.push(Qt.resolvedUrl("../VideoPlaybackPage.qml")).addVideos([video]);
                    }
                    else if (video.streamUrl.toString()) {
                        VideoLauncher.playVideo(video.streamUrl);
                    }
                    else {
                        dialogLoader.sourceComponent = playbackDialog;
                        dialogLoader.item.model.list(video.id);
                        dialogLoader.item.open();
                    }
                }
            }

            MyFlickable {
                id: flicker

                anchors {
                    left: parent.left
                    right: parent.right
                    top: thumbnail.bottom
                    topMargin: platformStyle.paddingLarge
                    bottom: parent.bottom
                }
                contentHeight: flow.height + platformStyle.paddingLarge * 2
                clip: true

                Flow {
                    id: flow

                    anchors {
                        left: parent.left
                        leftMargin: platformStyle.paddingLarge
                        right: parent.right
                        rightMargin: platformStyle.paddingLarge
                        top: parent.top
                    }
                    spacing: platformStyle.paddingLarge

                    Label {
                        width: parent.width
                        font.bold: true
                        wrapMode: Text.WordWrap
                        text: video.title
                    }

                    Avatar {
                        id: avatar

                        width: platformStyle.graphicSizeMedium
                        height: platformStyle.graphicSizeMedium
                        source: user.thumbnailUrl
                        visible: user.thumbnailUrl.toString() != ""
                        onClicked: appWindow.pageStack.push(Qt.resolvedUrl("PluginUserPage.qml")).load(user)
                    }

                    Item {
                        width: parent.width - avatar.width - platformStyle.paddingLarge
                        height: avatar.visible ? avatar.height : dateLabel.height

                        Label {
                            id: userLabel

                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                            }
                            verticalAlignment: Text.AlignTop
                            elide: Text.ElideRight
                            font.pixelSize: platformStyle.fontSizeSmall
                            text: user.username
                            visible: avatar.visible
                        }

                        Label {
                            id: dateLabel

                            anchors {
                                left: parent.left
                                right: parent.right
                                bottom: parent.bottom
                            }
                            verticalAlignment: Text.AlignBottom
                            elide: Text.ElideRight
                            font.pixelSize: platformStyle.fontSizeSmall
                            font.weight: Font.Light
                            color: platformStyle.colorNormalMid
                            text: qsTr("Published on") + " " + video.date
                            visible: video.date != ""
                        }
                    }

                    Label {
                        width: parent.width
                        wrapMode: Text.Wrap
                        text: video.description ? Utils.toRichText(video.description) : qsTr("No description")
                        onLinkActivated: {
                            var resource = Resources.getResourceFromUrl(link);

                            if (resource.service != Settings.currentService) {
                                Qt.openUrlExternally(link);
                                return;
                            }

                            if (resource.type == Resources.USER) {
                                appWindow.pageStack.push(Qt.resolvedUrl("PluginUserPage.qml")).load(resource.id);
                            }
                            else if (resource.type == Resources.PLAYLIST) {
                                appWindow.pageStack.push(Qt.resolvedUrl("PluginPlaylistPage.qml")).load(resource.id);
                            }
                            else {
                                appWindow.pageStack.push(Qt.resolvedUrl("PluginVideoPage.qml")).load(resource.id);
                            }
                        }
                    }
                }
            }

            MyScrollBar {
                flickableItem: flicker
            }

            Loader {
                id: dialogLoader
            }

            Component {
                id: playbackDialog

                PluginPlaybackDialog {
                    focusItem: flicker
                    onAccepted: VideoLauncher.playVideo(value.url)
                }
            }

            Component {
                id: downloadDialog

                PluginDownloadDialog {
                    focusItem: flicker
                }
            }

            states: State {
                name: "landscape"
                when: !appWindow.inPortrait

                PropertyChanges {
                    target: thumbnail
                    width: 280
                }

                AnchorChanges {
                    target: flicker
                    anchors {
                        left: thumbnail.right
                        top: parent.top
                    }
                }
            }
        }

        TabLoader {
            id: relatedTab

            width: view.width
            height: view.height
            title: qsTr("Related")
            tab: Component {
                PluginVideosTab {
                    Component.onCompleted: {                        
                        if (video.relatedVideosId) {
                            model.list(video.relatedVideosId);
                        }
                        else {
                            infoBanner.showMessage(qsTr("This video does not have any related videos"));
                        }
                    }
                }
            }
        }

        TabLoader {
            id: commentsTab

            width: view.width
            height: view.height
            title: qsTr("Comments")
            tab: Component {
                PluginCommentsTab {
                    Component.onCompleted: {                        
                        if (video.commentsId) {
                            model.list(video.commentsId);
                        }
                        else {
                            infoBanner.showMessage(qsTr("This video does not have any comments"));
                        }
                    }
                }
            }
        }
    }
}
