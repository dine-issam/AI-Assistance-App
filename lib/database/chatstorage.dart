import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatStorage {
  static const String _chatKey = 'chat_messages';

  // Save messages to local storage
  static Future<void> saveMessages(List<Map<String, String>> messages) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonMessages = jsonEncode(messages);
    await prefs.setString(_chatKey, jsonMessages);
  }

  // Load messages from local storage
  static Future<List<Map<String, String>>> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonMessages = prefs.getString(_chatKey);

    if (jsonMessages != null) {
      List<dynamic> decodedList = jsonDecode(jsonMessages);
      return decodedList.map((e) => Map<String, String>.from(e)).toList();
    }   
    return [];
  }

  // Clear all messages
  static Future<void> clearMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chatKey);
  }
}
