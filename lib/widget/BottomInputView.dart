// ignore_for_file: file_names, prefer_const_constructors,no_logic_in_create_state, use_key_in_widget_constructors, must_be_immutable
import 'package:ai_chat_gpt/api/AiTalk.dart';
import 'package:ai_chat_gpt/res/res_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

///
/// 底部输入交互栏
///
class BottomInputView extends StatefulWidget {

  Function sendTextFunc;

  BottomInputView(this.sendTextFunc);

  @override
  State<StatefulWidget> createState() {
    return BottomInputViewState(sendTextFunc);
  }
}

class BottomInputViewState extends State<BottomInputView> {

  bool isShowExpand = false;
  bool isShowInput = true;
  bool isShowSendBtn = false;

  Function sendTextFunc;

  final TextEditingController _textEditingController = TextEditingController();
  List<BottomMoreGridBean> expandMenus = [
    BottomMoreGridBean("开启朗读",Icons.mic_none_outlined),
  ];


  BottomInputViewState(this.sendTextFunc);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildInputView(),
        _buildExpandView()
      ],
    );
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
          Expanded(
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
            )),
          ),
          _buildShowMoreView(),
          _buildSendBtnView()
        ],
      ),
    );
  }

  _buildVoiceAndInputIcon(){
    return  GestureDetector(
      onTap: () {
        setState(() {
          isShowInput = !isShowInput;
          isShowExpand = false;
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
          setState(() {
            isShowExpand = !isShowExpand;
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
          AiTalk().requestOpenAi(text);
          _textEditingController.clear();
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
      decoration: InputDecoration(
        hintText: "请输入内容",
        hintStyle: TextStyle(
          fontSize: 14,
          color: ResColors.material_grey_500,
        ),
        border: InputBorder.none,
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
        crossAxisSpacing: 40,
      ),
      itemBuilder: (context, index) {
        BottomMoreGridBean bean = expandMenus[index];
        return GestureDetector(
          onTap: (){
            String toastMsg = "";
            for (var element in expandMenus) {
              if(element.name == "开启朗读"){
                element.name = "关闭朗读";
                element.icon = Icons.mic_off;
                toastMsg = "关闭朗读成功";
              }else if(element.name == "关闭朗读"){
                element.name = "开启朗读";
                element.icon = Icons.mic_none_outlined;
                toastMsg = "开启朗读成功";
              }
            }
            setState(() {
              isShowExpand = false;
            });
            Fluttertoast.showToast(msg:toastMsg);
          },
          child: Container(
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


}

class BottomMoreGridBean{
  String name;
  IconData icon;
  BottomMoreGridBean(this.name,this.icon);
}
