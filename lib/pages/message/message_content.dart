import 'package:commuitynapp/bean/chat_entity.dart';
import 'package:commuitynapp/constant/constant.dart';
import 'package:commuitynapp/http/API.dart';
import 'package:commuitynapp/http/http_request.dart';
import 'package:commuitynapp/model/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as Convert;
class MessageContent extends StatefulWidget {
  @override
  _MessageContentState createState() => _MessageContentState();
}

class _MessageContentState extends State<MessageContent> {
  HttpRequest _request;
  bool isLoading = false;
  int currentPage = 1;
  String test="41479828b219239398cc75363fc6fa9f";
  List<ChatEntity> chatPersonList = [];
  @override
  void initState() {
    super.initState();
    _request = HttpRequest(API.COMMUNITY_BASE_URL);
    getMessagePersonsTop();

  }

  @override
  Widget build(BuildContext context) {
    return Container(
            padding: EdgeInsets.only(
                left: ScreenUtil().setWidth(Constant.MARGIN_LEFT),
                right: ScreenUtil().setWidth(Constant.MARGIN_RIGHT),
                top: ScreenUtil().setHeight(Constant.MARGIN_TOP)),
            width: ScreenUtil().setWidth(750),
            height: ScreenUtil().setHeight(1334),
            child: NotificationListener(

              //下拉条
              child: RefreshIndicator(
                child: ListView.builder(
                    //physics: const BouncingScrollPhysics(),
                    key: PageStorageKey<String>("ChatPersons"),
                    itemCount: chatPersonList.length,
                    itemBuilder: (BuildContext context, int index) {
                      //print(index);
                      return ChatMessageWidget(chatPersonList[index]);
                    }),
                onRefresh: () {
                  //if (_isLoding) return null;
                  return _RrefreshPull().then((value) {
                    print('success');
                  }).catchError((error) {
                    print('failed');
                  });
                },
              ),
              onNotification: (notification) {
                if (notification is ScrollUpdateNotification &&
                    notification.depth == 0) {
                  if (notification.metrics.pixels ==
                      notification.metrics.maxScrollExtent) {
                    print('滑动到了最底部');
                    setState(() {});
                    _RrefreshPullDown().then((value) {
                      print('加载成功.............');
                    }).catchError((error) {
                      print('failed');
                      setState(() {});
                    });
                  }
                }
              },
    /*
              child: ListView(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(
                          top: ScreenUtil.getInstance().setWidth(5)),
                      child:       ChatMessageWidget()),
                  Container(
                    color: Colors.transparent,
                    width: ScreenUtil.getInstance().setWidth(750),
                    height: ScreenUtil.getInstance().setHeight(100),
                  )
                ],
              ),
              */

            )


    );
  }

  //滑动底部刷新
  Future<String> _RrefreshPullDown() async {
    getMessagePersons();
    return "_RrefreshPull";
  }
  getMessagePersons() async {
    if (isLoading) {
      return;
    }
    isLoading = true;
    currentPage += 1;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('X-Access-Token');
    String userInfo;
    Map<String, dynamic> user;
    userInfo = prefs.getString('userInfo');
    if(userInfo==null){
      return;
    }
    user=Convert.jsonDecode(userInfo);
    test=user["uid"];

    if (accessToken != null) {
      final Map result1 = await _request.post('/feed/my_chatPerson',
          "myuid=${test}&pageNo=$currentPage&pageSize=10",
          headers: {
            "content-type": "application/x-www-form-urlencoded",
            "X-Access-Token": accessToken
          });
      var resultList = result1['result']['records'];

      setState(() {
        chatPersonList.addAll(resultList
            .map<ChatEntity>(
                (item) => ChatEntity.fromMap(item))
            .toList());
        isLoading = false;

        //print("\n\n\n\n\n\n\n$commentList\n\n\n\n\n\n\n");
      });
      //if (currentPage-1 == 1) getMessagePersons();
    }
  }
  //头部下拉刷新
  Future<String> _RrefreshPull() async {
    getMessagePersonsTop();
    return "_RrefreshPull";
  }

  getMessagePersonsTop() async {
    currentPage=1;
    chatPersonList.clear();
    if (isLoading) {
      return;
    }
    isLoading = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('X-Access-Token');

    String userInfo;
    Map<String, dynamic> user;
    userInfo = prefs.getString('userInfo');
    if(userInfo==null){
      return;
    }
    user=Convert.jsonDecode(userInfo);
    test=user["uid"];
    if (accessToken != null) {
      final Map result1 = await _request.post('/feed/my_chatPerson',
          "myuid=${test}&pageNo=$currentPage&pageSize=10",
          headers: {
            "content-type": "application/x-www-form-urlencoded",
            "X-Access-Token": accessToken
          });
      var resultList = result1['result']['records'];

      setState(() {
        chatPersonList.addAll(resultList
            .map<ChatEntity>(
                (item) => ChatEntity.fromMap(item))
            .toList());
        isLoading = false;
      });

    }
  }
}