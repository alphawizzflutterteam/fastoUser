import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pristine_andaman/Model/my_ride_model.dart';
import 'package:pristine_andaman/utils/ApiBaseHelper.dart';
import 'package:pristine_andaman/utils/common.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../BookRide/payment_dailog.dart';
import 'constant.dart';

// Notification Plugin Instance
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
FirebaseMessaging messaging = FirebaseMessaging.instance;

Future<void> backgroundMessage(RemoteMessage message) async {
  print(message);
}

class PushNotificationService {
  late BuildContext context;
  ValueChanged onResult;
  PushNotificationService({required this.context, required this.onResult});

  Future initialise() async {
    await App.init();
    iOSPermission();

    messaging.getToken().then((token) async {
      fcmToken = token;
      print("FCM Token: $fcmToken");
    });

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Create notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'default_notification_channel',
      'Default Channel',
      description: 'Used for all important notifications.',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        final payload = response.payload;
        // Handle notification tap
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      App.localStorage.setBool("notStatus", true);
      print("0k" + message.toString());

      var data = message.notification!;
      log("cehed" + data.toString());
      var title = data.title.toString();
      var body = data.body.toString();
      var test = message.data;

      if (title.toLowerCase().contains("accepted") ||
          body.toLowerCase().contains("accepted")) {
        onResult("accept");
      } else if (title.toLowerCase().contains("completed") ||
          body.toLowerCase().contains("completed")) {
        onResult("com");
      } else if (title.toLowerCase().contains("start") ||
          body.toLowerCase().contains("start")) {
        onResult("start");
      } else if (title.toLowerCase().contains("cancel") ||
          body.toLowerCase().contains("cancel")) {
        onResult("cancel");
      } else {
        onResult("refresh");
      }

      if (test != null &&
          test['booking_type'] != null &&
          (test['booking_type'] == "Rental Booking")) {
        getBooking(context);
      }

      print(test);
      print(test['Booking_id']);

      String? image = test['image']; // add image fetch logic
      if (image != null && image != 'null' && image != '') {
        generateImageNotication(title, body, image, "", "");
      } else {
        generateSimpleNotication(title, body, "", "");
      }
    });

    messaging.getInitialMessage().then((RemoteMessage? message) async {
      await Future.delayed(Duration.zero);
      if (message != null) {
        var data = message.notification!;
        var title = data.title.toString();
        var body = data.body.toString();

        if (title.toLowerCase().contains("accepted") ||
            body.toLowerCase().contains("accepted")) {
          onResult("accept");
        } else if (title.toLowerCase().contains("completed") ||
            body.toLowerCase().contains("completed")) {
          onResult("com");
        }
      }
    });

    FirebaseMessaging.onBackgroundMessage(backgroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // Handle when app opened from terminated/background
    });
  }

  void iOSPermission() async {
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}

Future<dynamic> myForgroundMessageHandler(RemoteMessage message) async {
  return Future<void>.value();
}

Future<String> _downloadAndSaveImage(String url, String fileName) async {
  var directory = await getApplicationDocumentsDirectory();
  var filePath = '${directory.path}/$fileName';
  var response = await http.get(Uri.parse(url));
  var file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return filePath;
}

Future<void> generateImageNotication(
    String title, String msg, String image, String type, String id) async {
  var largeIconPath = await _downloadAndSaveImage(image, 'largeIcon');
  var bigPicturePath = await _downloadAndSaveImage(image, 'bigPicture');

  var bigPictureStyleInformation = BigPictureStyleInformation(
    FilePathAndroidBitmap(bigPicturePath),
    hideExpandedLargeIcon: true,
    contentTitle: title,
    htmlFormatContentTitle: true,
    summaryText: msg,
    htmlFormatSummaryText: true,
  );

  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'default_notification_channel',
    'big text channel name',
    channelDescription: 'big text channel description',
    largeIcon: FilePathAndroidBitmap(largeIconPath),
    styleInformation: bigPictureStyleInformation,
    importance: Importance.high,
    priority: Priority.high,
  );

  var platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: DarwinNotificationDetails(),
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    msg,
    platformChannelSpecifics,
    payload: type + "," + id,
  );
}

Future<void> generateSimpleNotication(
    String title, String msg, String type, String id) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'default_notification_channel',
    'High Importance Notifications',
    channelDescription: 'your channel description',
    importance: Importance.max,
    priority: Priority.high,
    styleInformation: BigTextStyleInformation(""),
    ticker: 'ticker',
  );

  var platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: DarwinNotificationDetails(),
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    msg,
    platformChannelSpecifics,
    payload: type + "," + id,
  );
}

ApiBaseHelper apiBaseHelper = ApiBaseHelper();

registerToken() async {
  Map data = {
    "user_id": curUserId ?? '',
    "device_id": fcmToken ?? '',
  };

  Map response = await apiBaseHelper.postAPICall(
    Uri.parse(baseUrl + "update_Fcm_token_user"),
    data,
  );
  if (response['status']) {
    // Token registered successfully
  } else {
    // Handle error
  }
}

getBooking(context) async {
  Map data = {
    "user_id": curUserId,
    "device_id": fcmToken,
  };

  Map response = await apiBaseHelper.postAPICall(
    Uri.parse(baseUrl1 + "Payment/rental_ride_payment_check"),
    data,
  );

  if (response['status'] && response['data'].length > 0) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          PaymentDialog(MyRideModel.fromJson(response['data'][0])),
    );
  } else {
    // No booking to show
  }
}
