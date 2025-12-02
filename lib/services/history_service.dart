import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/message.dart';

class HistoryService {
  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/chat_history.json';
  }

  Future<List<Message>> loadMessages() async {
    try {
      final path = await _getFilePath();
      final file = File(path);
      if (!await file.exists()) return [];

      final content = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(content);
      return jsonList.map((json) => Message.fromJson(json)).toList();
    } catch (e) {
      print('Error loading history: $e');
      return [];
    }
  }

  Future<void> saveMessages(List<Message> messages) async {
    try {
      final path = await _getFilePath();
      final file = File(path);
      final jsonList = messages.map((msg) => msg.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      print('Error saving history: $e');
    }
  }
}
