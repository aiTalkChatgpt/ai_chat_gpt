// ignore_for_file: file_names

import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final TextStyle textStyle;
  final EdgeInsetsGeometry margin;
  final double width;
  final AlignmentGeometry alignment;
  final bool isSentByMe;
  const ChatBubble({
    Key? key,
    required this.message,
    this.backgroundColor = Colors.lightBlue,
    this.borderRadius = 10,
    this.padding = const EdgeInsets.all(10),
    this.textStyle = const TextStyle(fontSize: 16),
    this.margin = const EdgeInsets.all(0),
    this.width =  0.6,
    this.alignment =  Alignment.centerRight,
    required this.isSentByMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * width;
    return Row(
      mainAxisAlignment:
      isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isSentByMe) ...[
          const CircleAvatar(
            backgroundImage: AssetImage("assets/images/ai.webp"),
          ),
          SizedBox(width: 10),
        ],
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Text(
            message,
            style: textStyle,
          ),
        ),
        if (isSentByMe) ...[
          SizedBox(width: 10),
          CircleAvatar(
            backgroundImage:AssetImage("assets/images/tx.png"),
          ),
        ],
      ],
    );
  }
}
