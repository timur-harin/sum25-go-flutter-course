import 'package:flutter/material.dart';

typedef ApiServiceProvider = Object;

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: const Center(
        child: Text('TODO: implement chat screen'),
      ),
    );
  }
}
