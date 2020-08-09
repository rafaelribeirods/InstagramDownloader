import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';

class NotificationController {

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  NotificationAppLaunchDetails notificationAppLaunchDetails;

  NotificationController() {
    _init();
  }

  void _init() async {
    notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (int id, String title, String body, String payload) async {
        print('Running onDidReceiveLocalNotification...');
      });
    var initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: (String payload) async => onSelectNotification(payload));
  }

  onSelectNotification(String payload) async {
    if(payload != null) {
      await OpenFile.open(payload);
    }
  }

  void show(String path) async {
    //await showNotification();
    await _showBigPictureNotification(path);
  }

  Future<void> showNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      DateTime.now().millisecondsSinceEpoch.toString(),
      'your channel name',
      'your channel description',
      importance: Importance.Max, priority: Priority.High, ticker: 'ticker'
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        int.parse(DateTime.now().millisecondsSinceEpoch.toString().substring(DateTime.now().millisecondsSinceEpoch.toString().length - 4)),
      'plain title',
      'plain body',
      platformChannelSpecifics,
      payload: 'item x'
    );
  }

  Future<void> _showBigPictureNotification(String path) async {
    var largeIconPath = path;
    var bigPicturePath = path;
    var bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath),
      //largeIcon: FilePathAndroidBitmap(largeIconPath),
      contentTitle: 'Download completed!',
      htmlFormatContentTitle: true,
      summaryText: path.substring(path.lastIndexOf('/')+1),
      htmlFormatSummaryText: true
    );
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      DateTime.now().millisecondsSinceEpoch.toString(),
      'big text channel name',
      'big text channel description',
      styleInformation: bigPictureStyleInformation
    );
    var platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, null);
    await flutterLocalNotificationsPlugin.show(
      int.parse(DateTime.now().millisecondsSinceEpoch.toString().substring(DateTime.now().millisecondsSinceEpoch.toString().length - 4)),
      'big text title',
      'silent body',
      platformChannelSpecifics,
      payload: path
    );
  }

}