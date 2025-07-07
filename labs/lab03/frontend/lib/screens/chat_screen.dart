import 'dart:math';
import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/api_service.dart';

class MessengerPage extends StatefulWidget {
  const MessengerPage({Key? key}) : super(key: key);

  @override
  State<MessengerPage> createState() => _MessengerPageState();
}

class _MessengerPageState extends State<MessengerPage> {
  final ChatApi _api = ChatApi();
  List<ChatMsg> _chatList = [];
  bool _busy = false;
  String? _failMsg;
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _textCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _textCtrl.dispose();
    _api.close();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _busy = true;
      _failMsg = null;
    });
    try {
      _chatList = await _api.fetchAll();
    } catch (e) {
      _failMsg = e.toString();
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _postMsg() async {
    final user = _nameCtrl.text.trim();
    final msg = _textCtrl.text.trim();
    if (user.isEmpty || msg.isEmpty) return;
    final req = NewMsgReq(user: user, body: msg);
    final err = req.check();
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    try {
      final newMsg = await _api.addMsg(req);
      setState(() => _chatList.add(newMsg));
      _textCtrl.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _changeMsg(ChatMsg msg) async {
    final ctrl = TextEditingController(text: msg.body);
    final res = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Изменить сообщение'),
        content: TextField(controller: ctrl),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('Сохранить')),
        ],
      ),
    );
    if (res == null) return;
    final req = EditMsgReq(body: res);
    final err = req.check();
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    try {
      final upd = await _api.editMsg(msg.msgId, req);
      setState(() {
        final idx = _chatList.indexWhere((m) => m.msgId == msg.msgId);
        _chatList[idx] = upd;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _removeMsg(ChatMsg msg) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить сообщение?'),
        content: const Text('Вы уверены, что хотите удалить это сообщение?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Нет')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Да')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _api.removeMsg(msg.msgId);
      setState(() => _chatList.removeWhere((m) => m.msgId == msg.msgId));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _showStatus(int code) async {
    try {
      final info = await _api.fetchStatus(code);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('${info.code} ${info.desc}'),
          content: Image.network(info.img),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Закрыть')),
          ],
        ),
      );
    } catch (_) {}
  }

  Widget _msgTile(ChatMsg msg) {
    return ListTile(
      leading: CircleAvatar(child: Text(msg.user.isNotEmpty ? msg.user[0].toUpperCase() : '?')),
      title: Text('${msg.user} • ${msg.sentAt.toLocal()}'),
      subtitle: Text(msg.body),
      trailing: PopupMenuButton<String>(
        onSelected: (val) {
          if (val == 'edit') _changeMsg(msg);
          if (val == 'delete') _removeMsg(msg);
        },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'edit', child: Text('Изменить')),
          const PopupMenuItem(value: 'delete', child: Text('Удалить')),
        ],
      ),
      onTap: () => _showStatus([200, 404, 500][Random().nextInt(3)]),
    );
  }

  Widget _inputArea() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey[100],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Имя'),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textCtrl,
                  decoration: const InputDecoration(labelText: 'Сообщение'),
                ),
              ),
              IconButton(onPressed: _postMsg, icon: const Icon(Icons.send)),
              PopupMenuButton<int>(
                icon: const Icon(Icons.info_outline),
                onSelected: _showStatus,
                itemBuilder: (_) => [100, 200, 201, 400, 404, 418, 500, 503]
                    .map((c) => PopupMenuItem(value: c, child: Text(c.toString())))
                    .toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Чат')), 
      body: Column(
        children: [
          Expanded(
            child: _busy
                ? const Center(child: CircularProgressIndicator())
                : _failMsg != null
                    ? Center(child: Text(_failMsg!))
                    : ListView.builder(
                        itemCount: _chatList.length,
                        itemBuilder: (_, i) => _msgTile(_chatList[i]),
                      ),
          ),
          _inputArea(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refresh,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
