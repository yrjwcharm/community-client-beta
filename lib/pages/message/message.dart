
import 'package:commuitynapp/constant/constant.dart';
import 'package:commuitynapp/pages/message/message_content.dart';
import 'package:commuitynapp/pages/message/message_topbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MessagePage extends StatefulWidget {
  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
        //padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
        padding: EdgeInsets.only(
            left: ScreenUtil().setWidth(Constant.MARGIN_LEFT),
            right: ScreenUtil().setWidth(Constant.MARGIN_RIGHT),
            top: ScreenUtil().setHeight(Constant.MARGIN_TOP+20)),
        color: Colors.white,
        child: Column(children: <Widget>[
      MessageTopBar(),
      Expanded(child: MessageContent()),
      SizedBox(
        height: 1,
      )
    ]));
  }
}
