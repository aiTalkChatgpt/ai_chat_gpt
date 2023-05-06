// ignore_for_file: file_names, prefer_const_constructors,no_logic_in_create_state, use_key_in_widget_constructors, must_be_immutable
import 'dart:async';

import 'package:ai_chat_gpt/api/AiTalk.dart';
import 'package:ai_chat_gpt/res/res_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'custom_overlay.dart';

///
/// 底部输入交互栏
///
class BottomInputView extends StatefulWidget {

  Function sendTextFunc;
  Function pressVoiceFunc;

  Function startLongVoiceFunc;
  Function cancelLongVoiceFunc;

  Function commonFunc;

  BottomInputView({required this.sendTextFunc, required this.pressVoiceFunc, required this.startLongVoiceFunc,
    required this.cancelLongVoiceFunc, required this.commonFunc});

  @override
  State<StatefulWidget> createState() {
    return BottomInputViewState(sendTextFunc,pressVoiceFunc, cancelLongVoiceFunc,startLongVoiceFunc,this.commonFunc);
  }
}

class BottomInputViewState extends State<BottomInputView> {

  bool isShowExpand = false;//显示扩展工具
  bool isShowInput = true;//显示输入框
  bool isShowSendBtn = false;//显示发送那妞

  Function sendTextFunc;
  Function pressVoiceFunc;
  Function cancelLongVoiceFunc;
  Function startLongVoiceFunc;
  Function commonFunc;

  final TextEditingController _textEditingController = TextEditingController();
  List<BottomMoreGridBean> expandMenus = [
    BottomMoreGridBean("开启陪娃",Icons.mic_none_outlined),
  ];

  ///语音输入动画
  Timer? _timer;
  int _count = 0;
  OverlayEntry? overlayEntry;
  String voiceIco = "images/voice_volume_1.png";

  String voiceHintText = "松开手指发送";


  final FocusNode focusNode = FocusNode();


  BottomInputViewState(this.sendTextFunc, this.pressVoiceFunc, this.cancelLongVoiceFunc,this.startLongVoiceFunc,this.commonFunc);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildInputView(),
        _buildExpandView()
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {
          isShowExpand = false;
        });
      } else {

      }
    });
  }

  ///
  /// 语音和文字切换布局
  ///
  _buildInputView() {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
      color: ResColors.material_grey_800,
      child: Row(
        children: [
          _buildVoiceAndInputIcon(),
          SizedBox(
            width: 10,
          ),
          _buildInputAndPressVoiceView(),
          _buildShowMoreView(),
          _buildSendBtnView()
        ],
      ),
    );
  }

  ///
  /// 长按语音和文字数据框
  ///
  _buildInputAndPressVoiceView(){
    return Expanded(
      child: GestureDetector(
        onLongPressStart: (details) {
          if(isShowInput)return;
          voiceHintText = "松开手指发送";
          _startVoice();
          pressVoiceFunc();
        },
        onLongPressEnd: (details) {
          if(isShowInput)return;
          _stopVoice();
        },
        child: Container(
          alignment: isShowInput ? null :Alignment.center,
          height: 40,
          padding: EdgeInsets.only(left: 10, right: 10),
          decoration: BoxDecoration(
            color: ResColors.material_grey_900,
            borderRadius: BorderRadius.circular(20),
          ),
          child: isShowInput ?  _buildTextFieldView() : Text("按住 说话", style: TextStyle(
              color: ResColors.material_grey_500,
              fontSize: 16
          ),
          )),),
    );
  }

  ///
  /// 开始语音
  ///
  _startVoice(){
    _timer = Timer.periodic(Duration(milliseconds: 100), (t) {
      _count++;
      if(_count>=7){
        _count = 1;
      }
      setState(() {
        if(voiceHintText == "松开手指发送"){
          isShowExpand = false;
        }
        voiceIco = "images/voice_volume_$_count.png";
        if (overlayEntry != null) {
          overlayEntry!.markNeedsBuild();
        }
      });
    });
    showVoiceView();
  }

  ///
  /// 停止语音
  ///
  _stopVoice(){
    hideVoiceView();
  }

  ///
  /// 左侧-语音和文字切换图标
  ///
  _buildVoiceAndInputIcon(){
    return  GestureDetector(
      onTap: () {
        setState(() {
          isShowInput = !isShowInput;
          isShowExpand = false;
          isShowSendBtn = false;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: ResColors.material_grey_900,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          isShowInput ? Icons.mic_none : Icons.keyboard_alt_outlined,
          color: ResColors.material_grey_500,
        ),
      ),);
  }

  ///
  /// 右侧更多菜单按钮
  ///
  _buildShowMoreView(){
    return Row(children: [
      SizedBox(
        width: 10,
      ),
      GestureDetector(
        onTap: (){
          FocusScope.of(context).requestFocus(FocusNode());
          setState(() {
            isShowExpand = !isShowExpand;
          });
          commonFunc(FuncType.scrollBottom);
        },
        child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: ResColors.material_grey_900,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          Icons.add_circle_outline,
          color: ResColors.material_grey_500,
        ),
      ),)
    ],);
  }
  ///
  /// 发送按钮
  ///
  _buildSendBtnView(){
    return isShowSendBtn ? Row(children: [
      SizedBox(
        width: 10,
      ),
      GestureDetector(
        onTap: (){
          String text = _textEditingController.text;
          _textEditingController.clear();
          sendTextFunc(text);
          setState(() {
            isShowSendBtn = false;
          });
        },
        child: Container(
        width: 60,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ResColors.color_0071d1,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text("发送",style: TextStyle(color: ResColors.white),),
      ),),
    ],) : SizedBox(
      width: 0,
    );
  }

  ///
  /// 输入框
  ///
  _buildTextFieldView(){
    return TextField(
      controller: _textEditingController,
      style: TextStyle(
        fontSize: 16,
        color: ResColors.material_grey_500,
      ),
      focusNode: focusNode,
      decoration: InputDecoration(
        hintText: "请输入内容",
        hintStyle: TextStyle(
          fontSize: 14,
          color: ResColors.material_grey_500,
        ),
        border: OutlineInputBorder(borderSide: BorderSide.none),
        contentPadding: EdgeInsets.all(0),
      ),
      onChanged: (value) {
         setState(() {
           isShowSendBtn = value.isNotEmpty;
         });
      },
    );
  }

  ///
  /// 底部扩展栏
  ///
  _buildExpandView() {
    return isShowExpand ? Container(
      height: 200,
      color: ResColors.material_grey_800,
      child: Column(children: [
        Divider(height: 1,color: ResColors.material_grey_700,),
        Expanded(child: _buildGridView())
      ],),
    ) : SizedBox(
      height: 0,
    );
  }

  ///
  /// 网格布局
  ///
  _buildGridView() {
    return GridView.builder(
      padding: EdgeInsets.only(left: 20,right: 20,top: 30,bottom: 40),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 15,
        crossAxisSpacing: 30,
      ),
      itemBuilder: (context, index) {
        BottomMoreGridBean bean = expandMenus[index];
        return GestureDetector(
          onTap: (){
            String toastMsg = "";
            for (var element in expandMenus) {
              if(element.name == "开启陪娃"){
                element.name = "关闭陪娃";
                element.icon = Icons.mic_off;
                toastMsg = "开启陪娃成功";
                voiceHintText = "请说话...";
                _startVoice();
                startLongVoiceFunc();
              }else if(element.name == "关闭陪娃"){
                element.name = "开启陪娃";
                element.icon = Icons.mic_none_outlined;
                toastMsg = "关闭陪娃成功";
                _stopVoice();
                cancelLongVoiceFunc();
              }
            }
            setState(() {
              isShowExpand = false;
            });
            Fluttertoast.showToast(msg:toastMsg);
          },
          child: Container(
            padding: EdgeInsets.only(left: 3,right: 3,bottom: 3,top: 2),
          decoration: BoxDecoration(
            color: ResColors.material_grey_900,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(bean.icon,color: ResColors.material_grey_500,size: 30,),
              Text(bean.name,style: TextStyle(color: ResColors.material_grey_500,fontSize: 11))
            ],),
        ),);
      },
      itemCount: expandMenus.length,
    );
  }

  ///
  ///显示录音悬浮布局
  ///
  buildOverLayView(BuildContext context) {
    if (overlayEntry == null) {
      overlayEntry = OverlayEntry(builder: (content) {
        return CustomOverlay(
          icon: Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: Image.asset(
                  "assets/"+voiceIco,
                  width: 100,
                  height: 100,
                ),
              ),
              Text(
                voiceHintText,
                style: TextStyle(
                  fontStyle: FontStyle.normal,
                  color: Colors.white,
                  fontSize: 14,
                ),
              )
            ],
          ),
        );
      });
      Overlay.of(context)!.insert(overlayEntry!);
    }
  }

  ///
  /// 显示语音动画
  ///
  showVoiceView() {
    buildOverLayView(context);
  }

  ///
  /// 隐藏语音动画
  ///
  hideVoiceView() {
    if (_timer!.isActive) {
      _timer?.cancel();
      _count = 0;
    }
    if (overlayEntry != null) {
      overlayEntry?.remove();
      overlayEntry = null;
    }
  }
}

class BottomMoreGridBean{
  String name;
  IconData icon;
  BottomMoreGridBean(this.name,this.icon);
}

enum FuncType {
  scrollBottom,
}
