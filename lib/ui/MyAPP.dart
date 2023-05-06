// ignore: file_names
// ignore_for_file: file_names

import 'dart:async';

import 'package:ai_chat_gpt/api/AiTalk.dart';
import 'package:ai_chat_gpt/ui/ChatBubble.dart';
import 'package:ai_chat_gpt/utils/data_util.dart';
import 'package:ai_chat_gpt/widget/BottomInputView.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Speech to Text Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyHomePage> {
  List<Map<String, dynamic>> items = [
    {'content': '你好', 'type': 1}
  ];
  late StreamSubscription<bool> _streamSubscription;
  AiTalk aiTalk = AiTalk();

  @override
  void initState() {
    super.initState();
    DatabaseUtil.db.queryAllRows("chat").then((value) => {
      setState(() {
        items = value;
      })
    });
    _streamSubscription =
        DatabaseUtil.db.databaseChangeStream.listen((bool isChanged) {
          if (isChanged) {
            setState(() {
              DatabaseUtil.db.queryAllRows("chat").then((value) => {
                setState(() {
                  items = value;
                })
              });
            });
          }
        });
  }

  void _callListen() async {
    try {
      aiTalk.canListen = true;
      aiTalk.callListen();
      // 处理成功结果
    } on PlatformException catch (e) {
      // 处理异常
      print('error');
    }
  }

  void _stop() {
    aiTalk.callStop();
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 聊天机器人'),
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = items[index];
                  switch (item["type"]) {
                    case 0:
                      return ChatBubble(
                          message: item["content"],
                          margin: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                          width: 0.7,
                          alignment: Alignment.centerLeft,
                          isSentByMe: true
                      );
                    case 1:
                      return ChatBubble(
                          message: item["content"],
                          backgroundColor: Colors.amberAccent,
                          margin: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                          width: 0.7,
                          alignment: Alignment.centerRight,
                          isSentByMe: false
                      );
                    default:
                      return Container();
                  }
                },
              )),
          BottomInputView((){

          }),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  child: const Icon(Icons.mic),
                  onPressed: _callListen,
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  child: const Icon(Icons.stop),
                  onPressed: _stop,
                ),
              ],
            ),
            height: 60,
          )
        ],
      ),
    );
  }
}
