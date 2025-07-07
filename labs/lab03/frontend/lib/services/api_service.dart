import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ChatApi {
  static const String endpoint = 'http://localhost:8080';
  static const Duration reqTimeout = Duration(seconds: 30);

  final http.Client _http;

  ChatApi() : _http = http.Client();

  void close() => _http.close();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  T _parse<T>(http.Response resp, T Function(Map<String, dynamic>) fromJson) {
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final Map<String, dynamic> data = json.decode(resp.body);
      if (data.containsKey('data')) {
        return fromJson(data['data']);
      } else {
        return fromJson(data);
      }
    } else if (resp.statusCode >= 400 && resp.statusCode < 500) {
      throw ClientErr('Ошибка клиента: ${resp.body}');
    } else if (resp.statusCode >= 500) {
      throw ServerErr('Ошибка сервера: ${resp.body}');
    } else {
      throw ClientErr('Неожиданный статус: ${resp.statusCode}');
    }
  }

  Future<List<ChatMsg>> fetchAll() async {
    final resp = await _http
        .get(Uri.parse('$endpoint/api/messages'), headers: _headers)
        .timeout(reqTimeout);
    if (resp.statusCode == 200) {
      final decoded = json.decode(resp.body);
      final list = (decoded['data'] as List)
          .map((e) => ChatMsg.fromJson(e as Map<String, dynamic>))
          .toList();
      return list;
    } else {
      throw ClientErr('Ошибка загрузки: ${resp.body}');
    }
  }

  Future<ChatMsg> addMsg(NewMsgReq req) async {
    final err = req.check();
    if (err != null) throw ValidationErr(err);
    final resp = await _http
        .post(Uri.parse('$endpoint/api/messages'),
            headers: _headers, body: json.encode(req.toJson()))
        .timeout(reqTimeout);
    return _parse<ChatMsg>(resp, (json) => ChatMsg.fromJson(json));
  }

  Future<ChatMsg> editMsg(int msgId, EditMsgReq req) async {
    final err = req.check();
    if (err != null) throw ValidationErr(err);
    final resp = await _http
        .put(Uri.parse('$endpoint/api/messages/$msgId'),
            headers: _headers, body: json.encode(req.toJson()))
        .timeout(reqTimeout);
    return _parse<ChatMsg>(resp, (json) => ChatMsg.fromJson(json));
  }

  Future<void> removeMsg(int msgId) async {
    final resp = await _http
        .delete(Uri.parse('$endpoint/api/messages/$msgId'), headers: _headers)
        .timeout(reqTimeout);
    if (resp.statusCode != 204) {
      throw ClientErr('Ошибка удаления: ${resp.body}');
    }
  }

  Future<StatusInfo> fetchStatus(int code) async {
    if (code < 100 || code > 599) {
      throw ValidationErr('Некорректный код статуса');
    }
    final resp = await _http
        .get(Uri.parse('$endpoint/api/status/$code'), headers: _headers)
        .timeout(reqTimeout);
    return _parse<StatusInfo>(resp, (json) => StatusInfo.fromJson(json));
  }

  Future<Map<String, dynamic>> ping() async {
    final resp = await _http
        .get(Uri.parse('$endpoint/api/health'), headers: _headers)
        .timeout(reqTimeout);
    return json.decode(resp.body);
  }
}

class ClientErr implements Exception {
  final String msg;
  ClientErr(this.msg);
  @override
  String toString() => 'ClientErr: $msg';
}

class ServerErr extends ClientErr {
  ServerErr(String msg) : super(msg);
}

class ValidationErr extends ClientErr {
  ValidationErr(String msg) : super(msg);
}
