import 'dart:async';

import 'package:commuitynapp/http/API.dart';
import 'package:commuitynapp/http/http_request.dart';
import 'package:commuitynapp/pages/person/login_page.dart';
import 'package:flutter/material.dart';
import 'package:commuitynapp/pages/container_page.dart';
import 'package:commuitynapp/constant/constant.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as Convert;
///打开APP首页
class SplashWidget extends StatefulWidget {
  @override
  _SplashWidgetState createState() => _SplashWidgetState();
}

class _SplashWidgetState extends State<SplashWidget> {
  var container ;//主界面入口

  bool showAd = true;
  bool tokenok = true;
  var _request = HttpRequest(API.COMMUNITY_BASE_URL);
  void requestHomeAPI() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('X-Access-Token');
    print("获取令牌$accessToken");
    if (accessToken != null) {
      var body1 = {"lat": 0, "lng": 0, "location": "北京市海淀区"};
      final Map result1 = await _request.post(
          '/feed/recommend_dynamic?pageNo=0&pageSize=1',
          Convert.jsonEncode(body1),
          headers: {
            "content-type": "application/json",
            "X-Access-Token": accessToken
          });

      //final Map result = await _request.get(WEEKLY);
      var code = result1['status'];
      if(code==500){
        tokenok=false;
      }

      isLogin();
    }else{
      container=LoginPage();
    }

  }

  isLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userInfo = prefs.getString('userInfo');

    if(userInfo==null||tokenok==false){
      container=LoginPage();

    }else{
      container= ContainerPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    //设置适配尺寸 (填入设计稿中设备的屏幕尺寸) 假如设计稿是按iPhone6的尺寸设计的(iPhone6 750*1334)
    ScreenUtil.instance = ScreenUtil(width: 750, height: 1334)..init(context);
    print('build splash');
    requestHomeAPI();

    return SafeArea(
        child: Stack(
      children: <Widget>[
        Offstage(
          child: container,
          offstage: showAd,
        ),
        Offstage(
          child: Container(
            width: ScreenUtil.getInstance().setWidth(750),
            height: ScreenUtil.getInstance().setHeight(1334),
            color: Colors.white,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Align(
                  alignment: Alignment(0.0, 0.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          width: ScreenUtil.getInstance().setWidth(750),
                          height: ScreenUtil.getInstance().setWidth(750),
                          child: CircleAvatar(
                            radius: 25.0,
                            backgroundColor: Colors.white,
                            backgroundImage:
                                AssetImage(Constant.ASSETS_IMG + 'home.png'),
                          )),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Text(
                          '',
                          style: TextStyle(fontSize: 15.0, color: Colors.black),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Align(
                      alignment: Alignment(1.0, 0.0),
                      child: Container(
                        margin: const EdgeInsets.only(right: 30.0, top: 20.0),
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 10.0, top: 2.0, bottom: 2.0),
                        child: CountDownWidget(
                          onCountDownFinishCallBack: (bool value) {
                            if (value) {
                              setState(() {
                                showAd = false;
                              });
                            }
                          },
                        ),
                        decoration: BoxDecoration(
                            color: Color(0xffEDEDED),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20.0))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          //Image.asset(
                         //   Constant.ASSETS_IMG + 'ic_launcher.png',
                         //   width: 50.0,
                         //   height: 50.0,
                         //),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              'Hi,尬聊聊',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 30.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ))
              ],
            ),
          ),
          offstage: !showAd,
        )
      ],
    ));
  }
}

class CountDownWidget extends StatefulWidget {
  final onCountDownFinishCallBack;

  CountDownWidget({Key key, @required this.onCountDownFinishCallBack})
      : super(key: key);

  @override
  _CountDownWidgetState createState() => _CountDownWidgetState();
}

class _CountDownWidgetState extends State<CountDownWidget> {
  var _seconds = 6;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '$_seconds',
      style: TextStyle(fontSize: 17.0),
    );
  }

  /// 启动倒计时的计时器。
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
      if (_seconds <= 1) {
        widget.onCountDownFinishCallBack(true);
        _cancelTimer();
        return;
      }
      _seconds--;
    });
  }

  /// 取消倒计时的计时器。
  void _cancelTimer() {
    _timer?.cancel();
  }
}
