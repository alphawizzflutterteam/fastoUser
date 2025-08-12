import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceAssistant extends StatefulWidget {
  @override
  _VoiceAssistantState createState() => _VoiceAssistantState();
}

class _VoiceAssistantState extends State<VoiceAssistant> {
  stt.SpeechToText? _speech;
  bool _isListening = false;
  String _text = 'Say something...';
  String? _receivedMessage; // Variable to store received message
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    // initializeNotifications();
  }

  // void initializeNotifications() {
  //   flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  //   const AndroidInitializationSettings initializationSettingsAndroid =
  //       AndroidInitializationSettings('@mipmap/ic_launcher');
  //
  //   final InitializationSettings initializationSettings =
  //       InitializationSettings(
  //     android: initializationSettingsAndroid,
  //   );
  //
  //   flutterLocalNotificationsPlugin!.initialize(initializationSettings,
  //       onSelectNotification: (String? payload) async {
  //     if (payload != null) {
  //       // Play the message when the notification is tapped
  //       speakMessage(payload);
  //     }
  //   });
  // }

  Future<void> showNotification(String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id', // Channel ID
      'your_channel_name', // Channel Name
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin!.show(
      0,
      'New Message from Vasim', // Notification title
      message, // Notification body (message content)
      platformChannelSpecifics,
      payload: message, // Pass the message as payload
    );
  }

  Future<void> speakMessage(String message) async {
    await flutterTts.speak(message); // Convert the message to speech
  }

  void _startListening() async {
    bool available = await _speech!.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech!.listen(onResult: (result) {
        setState(() {
          _text = result.recognizedWords;
          if (result.finalResult) {
            processCommand(_text);
          }
        });
      });
    } else {
      setState(() => _isListening = false);
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech!.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Assistant'),
      ),
      body: Column(
        children: [
          // Message bubble with voice note and timestamp
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Voice message simulation
                    Row(
                      children: [
                        Icon(Icons.play_arrow), // Play button icon
                        Expanded(
                          child: Slider(
                            value: 0,
                            onChanged: (value) {},
                          ),
                        ),
                        Text("0:00"), // Duration time
                      ],
                    ),
                    SizedBox(height: 8.0),
                    // Message timestamp
                    Text(
                      '03:45 PM',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Spacer(),
          // Input text and voice message button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Please enter message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                FloatingActionButton(
                  onPressed: _isListening ? _stopListening : _startListening,
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void processCommand(String command) {
    print('Command received: $command');
    String sender = "Vasim";
    String recipient = "Tanmay";
    String message = "$recipient, $sender messaged you: $command";
    // Store the received message for Tanmay
    _receivedMessage = message;
    // Show notification for Tanmay
    showNotification(message);
    speakMessage("Vasim, your message to Tanmay was: $command");
  }
}
