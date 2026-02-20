import 'package:flutter/material.dart';
import 'chat_service.dart';
import 'dart:async';

// ChatScreen displays the chat UI
class ChatScreen extends StatefulWidget {
  final ChatService chatService;
  const ChatScreen({super.key, required this.chatService});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final textEditingController = TextEditingController();
  List<String> messages = [];
  bool failConnect = false;
  String error = "Connection error";
  Stream<String>? messageStream;

  void initConnect() async {
    try {
      await widget.chatService.connect();
    }
    catch(e) {
      setState(() {
        failConnect = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    messageStream = widget.chatService.messageStream;
    initConnect();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    
    try {
      if (!failConnect) {
        await widget.chatService.sendMessage(textEditingController.text);
        setState(() {
          textEditingController.clear();
        });
      }
    }
    catch(e){}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            TextField(
              controller: textEditingController,
            ),
            ElevatedButton(
              onPressed: _sendMessage, 
              child: Icon(Icons.send)
            ),
            StreamBuilder<String>(
              stream: messageStream, 
              builder: (context, snapshot) {
                if (failConnect) {
                  return Text(error);
                }
                else if (snapshot.hasData) {
                  String data = snapshot.data!;
                  return Text(data);
                }
                else {
                  return Text("");
                }
              }
            )
          ]  
        )
      ),
    );
  }
}
