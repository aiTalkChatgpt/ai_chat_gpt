// ignore_for_file: file_names

import 'dart:convert';
import 'dart:ffi';
import 'package:ai_chat_gpt/utils/data_util.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class AiTalk {
  final MethodChannel _listenChannel =
      const MethodChannel('my_app/listenChannel');
  final MethodChannel _speakChannel =
      const MethodChannel('my_app/speakChannel');
  final MethodChannel _stopChannel = const MethodChannel('my_app/stopChannel');

  bool _isListening = false;
  bool canListen = true;

  Future<void> callListen() async {
    try {
      if (_isListening) {
        return ;
      }
      canListen = true;
      _isListening = true;
      String result = await _listenChannel
          .invokeMethod('openListening', {"arg": "my_argument"});
      if (result.trim().isNotEmpty) {
        _requestOpenAi(result);
        // 处理成功结果
        _isListening = false;
        callListen();
      }
    } on PlatformException catch (e) {
      // 处理异常
      return ;
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
      if (!text.contains("关闭") && canListen) {
        callListen();
      }
      return text;
      // 处理成功结果
    } on PlatformException catch (e) {
      // 处理异常
      return 'error';
    }
  }

  Future<void> _requestOpenAi(String data) async {
    final url = Uri.parse("https://chat-gpt-next-web5-puce.vercel.app/api/chat-stream");
    List<Map<String, dynamic>> list = await DatabaseUtil.db.queryAllRows("Chat");
    List messages = [];
    if(list.length > 10) {
      list = list.sublist(0, 10);
    }
    if(list.isNotEmpty){
      for (var element in list) {
        if(element["type"] == 0){
          messages.add({"role": "user", "content": element["content"]});
        }else {
          messages.add({"role": "assistant",
            "content": element["content"]});
        }
      }
    }
    messages.add({"role": "user", "content": data});
    DatabaseUtil.db.insert("Chat", {"content": data, "type": 0});
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'messages': messages,
          "model": "gpt-3.5-turbo",
          'temperature': 0.6,
          'max_tokens':2000,
          'presence_penalty':0,
          "stream":true,
        }),
        headers: {'Content-Type': 'application/json'
          ,'access-code':"stxxf.789","path":"v1/chat/completions"},
      );
      callSpeak(response.body);
      DatabaseUtil.db.insert("Chat", {"content": response.body, "type": 1});
    } catch (error) {
      print('Error: $error');
      DatabaseUtil.db.insert("Chat", {"content": 'error', "type": 1});
    }
  }
}
