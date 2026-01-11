import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'screens/chat_screen.dart';
import 'models/message.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
        ChangeNotifierProvider<ChatProvider>(create: (ctx) => ChatProvider(ctx.read<ApiService>())),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 03 REST API Chat',
      theme: ThemeData(useMaterial3: true),
      home: const ChatScreen(),
    );
  }
}

class ChatProvider extends ChangeNotifier {
  final ApiService api;
  ChatProvider(this.api) { loadMessages(); }
  List<Message> messages = [];
  bool isLoading = false;
  String? error;

  Future<void> loadMessages() async {
    isLoading = true; error = null; notifyListeners();
    try { messages = await api.getMessages(); } catch (e) { error = e.toString(); }
    isLoading = false; notifyListeners();
  }
  Future<void> createMessage(String user, String content) async {
    await api.createMessage(CreateMessageRequest(username: user, content: content)).then((m) => messages.insert(0, m)).catchError((e) => error = e.toString());
    notifyListeners();
  }
  Future<void> updateMessage(int id, String content) async {
    await api.updateMessage(id, UpdateMessageRequest(content: content)).then((m) { final i = messages.indexWhere((x) => x.id==id); if (i!=-1) messages[i]=m; }).catchError((e) => error = e.toString());
    notifyListeners();
  }
  Future<void> deleteMessage(int id) async {
    await api.deleteMessage(id).then((_) => messages.removeWhere((x) => x.id==id)).catchError((e) => error = e.toString());
    notifyListeners();
  }
}
