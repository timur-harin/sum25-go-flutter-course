import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../services/api_service.dart';

/// Provider for chat business logic and state
class ChatProvider extends ChangeNotifier {
  final ApiService apiService;
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ChatProvider(this.apiService) {
    loadMessages();
  }

  Future<void> loadMessages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _messages = await apiService.getMessages();
    } catch (e) {
      _error = 'Failed to load messages';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String username, String content, BuildContext context) async {
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Username is required')));
      return;
    }
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Content is required')));
      return;
    }
    try {
      final msg = await apiService.createMessage(CreateMessageRequest(username: username, content: content));
      _messages.add(msg);
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message sent')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to send message')));
    }
  }

  Future<void> showStatusDialog(BuildContext context, int code) async {
  try {
    final status = await apiService.getHTTPStatus(code);
    final imageUrl = status.imageUrl.startsWith('http://localhost')
        ? 'https://http.cat/${status.statusCode}'
        : status.imageUrl;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        key: const Key('httpStatusDialog'),
        title: Text('HTTP Status: ${status.statusCode}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(status.description),
            const SizedBox(height: 8),
            Image.network(imageUrl, key: const Key('statusImage')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  } catch (e) {
    await showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        key: Key('httpStatusDialog'),
        title: Text('Error'),
        content: Text('Could not fetch HTTP status'),
      ),
    );
  }
}


  Future<void> refresh() async {
    await loadMessages();
  }
}

/// Chat screen UI
class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('REST API Chat'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: provider.refresh,
              ),
            ],
          ),
          body: _buildBody(provider),
          bottomSheet: SingleChildScrollView(child: _buildMessageInput(provider)),
          floatingActionButton: FloatingActionButton(
            onPressed: provider.refresh,
            child: const Icon(Icons.refresh),
          ),
        );
      },
    );
  }

  Widget _buildBody(ChatProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text(provider.error!),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: provider.loadMessages,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (provider.messages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('No messages yet', key: Key('emptyMessageText')),
            SizedBox(height: 8),
            Text('Send your first message to get started!'),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 160, top: 8),
      itemCount: provider.messages.length,
      itemBuilder: (context, index) {
        final msg = provider.messages[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(msg.username.isNotEmpty ? msg.username[0] : '?'),
          ),
          title: Text('${msg.username} • ${msg.timestamp.toLocal().toIso8601String()}'),
          subtitle: Text(msg.content),
          onTap: () => provider.showStatusDialog(context, 200),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {},
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageInput(ChatProvider provider) {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(hintText: 'Enter your username'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(hintText: 'Enter your message'),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: () => provider.sendMessage(
                  _usernameController.text,
                  _messageController.text,
                  context,
                ),
                child: const Text('Send'),
              ),
              ElevatedButton(
                onPressed: () => provider.showStatusDialog(context, 200),
                child: const Text('200 OK'),
              ),
              ElevatedButton(
                onPressed: () => provider.showStatusDialog(context, 404),
                child: const Text('404 Not Found'),
              ),
              ElevatedButton(
                onPressed: () => provider.showStatusDialog(context, 500),
                child: const Text('500 Error'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
