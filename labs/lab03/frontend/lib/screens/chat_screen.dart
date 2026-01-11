import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../main.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('REST API Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: Provider.of<ChatProvider>(context, listen: false).loadMessages,
          ),
        ],
      ),
      body: Consumer<ChatProvider>(builder: (ctx, prov, _) {
        if (prov.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (prov.error != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 8),
                Text(prov.error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: prov.loadMessages,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return Column(
          children: [
            if (prov.messages.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('No messages yet'),
                      SizedBox(height: 8),
                      Text('Send your first message to get started!'),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: prov.loadMessages,
                  child: ListView.builder(
                    reverse: true,
                    itemCount: prov.messages.length,
                    itemBuilder: (_, i) {
                      final msg = prov.messages[i];
                      return ListTile(
                        leading: CircleAvatar(child: Text(msg.username[0].toUpperCase())),
                        title: Text(
                          '${msg.username} • ${msg.timestamp.toLocal()}'.split('.').first,
                        ),
                        subtitle: Text(msg.content),
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) {
                            if (v == 'edit') _edit(context, prov, msg);
                            if (v == 'delete') prov.deleteMessage(msg.id);
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                        ),
                        onTap: () => _showStatusDialog(
                          context,
                          prov,
                          [200, 404, 500][Random().nextInt(3)],
                        ),
                      );
                    },
                  ),
                ),
              ),
            const Divider(height: 1),
            _InputArea(),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: Provider.of<ChatProvider>(context, listen: false).loadMessages,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  void _showStatusDialog(BuildContext context, ChatProvider prov, int code) async {
    try {
      final info = await prov.api.getHTTPStatus(code);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('HTTP Status: $code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                info.imageUrl,
                errorBuilder: (ctx, error, stack) {
                  return const Icon(
                    Icons.broken_image,
                    size: 48,
                    color: Colors.grey,
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(info.description),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _edit(BuildContext context, ChatProvider prov, Message msg) async {
    final controller = TextEditingController(text: msg.content);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
        ],
      ),
    );
    if (result != null) prov.updateMessage(msg.id, result);
  }
}

class _InputArea extends StatefulWidget {
  @override
  State<_InputArea> createState() => _InputAreaState();
}

class _InputAreaState extends State<_InputArea> {
  final _userCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ChatProvider>(context, listen: false);
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey.shade200,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _userCtrl,
            decoration: const InputDecoration(labelText: 'Enter your username'),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _msgCtrl,
                  decoration: const InputDecoration(labelText: 'Enter your message'),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final msg = await prov.api.createMessage(CreateMessageRequest(
                      username: _userCtrl.text,
                      content: _msgCtrl.text,
                    ));
                    prov.messages.insert(0, msg);
                    _msgCtrl.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Message sent')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
                child: const Text('Send'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _showStatusDialog(context, prov, 200),
                child: const Text('200 OK'),
              ),
              ElevatedButton(
                onPressed: () => _showStatusDialog(context, prov, 404),
                child: const Text('404 Not Found'),
              ),
              ElevatedButton(
                onPressed: () => _showStatusDialog(context, prov, 500),
                child: const Text('500 Error'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showStatusDialog(BuildContext context, ChatProvider prov, int code) async {
    try {
      final info = await prov.api.getHTTPStatus(code);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('HTTP Status: $code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                info.imageUrl,
                errorBuilder: (ctx, error, stack) {
                  return const Icon(
                    Icons.broken_image,
                    size: 48,
                    color: Colors.grey,
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(info.description),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}