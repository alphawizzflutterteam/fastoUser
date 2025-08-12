import 'package:flutter/material.dart';

class ReadBeforeYou extends StatefulWidget {
  const ReadBeforeYou({Key,key});

  @override
  State<ReadBeforeYou> createState() => _ReadBeforeYouState();
}

class _ReadBeforeYouState extends State<ReadBeforeYou> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios,
            size: 20,
          ),
        ),
        centerTitle: true,
        title: Text(
          'ReadBeforeYou',
          style: TextStyle(fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hiudshjhdjsdfhj")
          ],
        ),
      ),
    );
  }
}
