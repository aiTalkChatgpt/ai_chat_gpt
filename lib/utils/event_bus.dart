import 'dart:collection';

import 'package:flutter/material.dart';

///
/// <pre>
///     author : pengMaster
///     e-mail : 
///     time   : 8/9/22 2:04 PM
///     desc   : 
///     version: v1.0
/// </pre>
///
class EventBus {

  static Map<String,Function> maps = HashMap();
  static Map<String,List<Function>> mapList = HashMap();


  ///
  /// 一对一刷新
  ///
  static void postSingle(String key,Object? content){
    Function? function = maps[key];
    if(null!=function){
      function(content ?? "");
    }
  }

  ///
  /// 一对一观察
  /// 注意：后面设置的监听会覆盖之前的，如果只有一个监听，可以使用
  ///
  static void observerSingle(String key,Function function){
     maps[key] = function;
  }

  ///
  /// 多对多刷新
  ///
  static void post(Widget widget,String key,Object content){
    mapList.forEach((keyList, value) {
      if(keyList == "$widget-$key"){
        value.forEach((element) {
          element(content);
        });
      }
    });
  }

  ///
  /// 多对多观察
  ///
  static void observer(Widget widget,String key,Function function){
    List<Function> list = mapList["$widget-$key"] ?? [];
    list.add(function);
    mapList["$widget-$key"] = list;
  }

  ///
  /// 多对多取消观察
  ///
  static void cancel(Widget widget){
    mapList.forEach((key, value) {
      if(key.contains(widget.toString())){
        mapList.remove(key);
      }
    });
  }
}