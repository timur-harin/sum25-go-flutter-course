import 'package:flutter/material.dart';
import 'chat_service.dart';

// ChatScreen displays the chat UI
class ChatScreen extends StatefulWidget {
  final ChatService chatService;
  const ChatScreen({super.key, required this.chatService});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textCtrl = TextEditingController();
  String _lastErr = ""; // last error met
  bool errMet = false; // specifies if the error was met
  Stream<String>? _msgsStream;

  @override
  void initState() {
    super.initState();
    connectToChatService();
  }

  // Connects to a chat service
  void connectToChatService() async {
    try {
      await widget.chatService.connect();
      _msgsStream = widget.chatService.messageStream;
      setState(() {
        errMet = false; // no error
      });
    } catch (err) {
      setState(() {
        _lastErr = "Connection error"; // Failed connection
        errMet = true;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Imitates sending a message
  void _sendMessage() {
    // Send the message storred in the text controller
    try {
      setState(() {
        widget.chatService.sendMessage(_textCtrl.text);
        _textCtrl.clear();
        errMet = false; // no error
      });
    } catch (sendErr) {
      setState(() {
        _lastErr = sendErr.toString(); // will render an error
        errMet = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Center(
          child: Column(
        // Message board and a button under it
        children: [
          TextField(
            controller: _textCtrl,
          ),
          // To split the text field and the button
          SizedBox(
            height: 20,
          ),
          ElevatedButton(onPressed: _sendMessage, child: Icon(Icons.send)),
          SizedBox(
            height: 20,
          ),
          StreamBuilder(
              stream: _msgsStream,
              builder: (context, snapshot) {
                if (errMet) {
                  return Text(_lastErr); // Render the last error met
                }

                if (snapshot.hasData) {
                  return Text(snapshot.data!); // Render the last sent message
                }

                return Text(_lastErr); // should be empty
              }),
        ],
      )),
    );
  }
}
