// ignore_for_file: file_names

import 'dart:convert';
import 'dart:ffi';
import 'package:ai_chat_gpt/utils/data_util.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class AiTalk {
  final MethodChannel _listenChannel = const MethodChannel('my_app/listenChannel');
  final MethodChannel _speakChannel = const MethodChannel('my_app/speakChannel');
  final MethodChannel _stopChannel = const MethodChannel('my_app/stopChannel');

  bool _isListening = false;
  bool canListen = true;

  Future<List<dynamic>>  callListen() async {
    try {
      if(_isListening){
        return [];
      }
      canListen = true;
      _isListening = true;
      String result = await _listenChannel.invokeMethod('openListening', {"arg": "my_argument"});
      if(result.trim().isNotEmpty){
        DatabaseUtil.db.insert("Chat", {"content": result, "type": 0});
        // 处理成功结果
        return [{"content": result, "type": 0}, {"content": _requestOpenAi(result), "type": 0}];
      } else {
        _isListening = false;
        callListen();
        return [];
      }

    } on PlatformException catch (e) {
      // 处理异常
      return [];
    }
  }

  Future<void> callStop() async {
    try {
      canListen = false;
      _isListening = false;
      await _stopChannel.invokeMethod('stop', {"arg": "my_argument"});
      // 处理成功结果
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Future<String> callSpeak(String text) async {
    try {
      await _speakChannel.invokeMethod('openSpeak', {"arg": text});
      _isListening = false;
      if(!text.contains("关闭") && canListen){
        callListen();
      }
      return text;
      // 处理成功结果
    } on PlatformException catch (e) {
      // 处理异常
      return 'error';
    }
  }

  Future<String> _requestOpenAi(String data) async {
    final url = Uri.parse("https://chat-bzl.maybee.shop/api");
    try {
      final response = await http.post(
        url,
        body: json.encode({'messages':[{'role': 'user', 'content': data}],
          'password':'bzl','key':'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'
          ,"model":"gpt-3.5-turbo",
          'temperature':0.6}),
        headers: {'Content-Type': 'application/json'},
      );
      callSpeak(response.body);
      DatabaseUtil.db.insert("Chat", {"content": response.body, "type": 1});
      return response.body;
    } catch (error) {
      print('Error: $error');
      DatabaseUtil.db.insert("Chat", {"content": 'error', "type": 1});
      return 'error';
    }
  }
}
