import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:commuitynapp/widgets/bottom_drag_widget.dart';
import 'package:commuitynapp/pages/splash/splash_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  //runApp(MyApp());
  //if (Platform.isAndroid) {
    //设置Android头部的导航栏透明
   // SystemUiOverlayStyle systemUiOverlayStyle =
   //     SystemUiOverlayStyle(statusBarColor: Colors.transparent);
   // SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  //}

  //WidgetsFlutterBinding.ensureInitialized();
  //SystemChrome.setEnabledSystemUIOverlays([]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    
    
    return RestartWidget(
      child: MaterialApp(
        //theme: ThemeData(backgroundColor: Colors.white),
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.grey[100],
            accentColor: Colors.white,
          ),

        debugShowCheckedModeBanner: false,  // 设置这一属性即可隐藏debug
        home: Scaffold(
          resizeToAvoidBottomInset: false, //输入框抵住键盘
          body: SplashWidget(),
        ),
      ),
    );
  }
}

///这个组件用来重新加载整个child Widget的。当我们需要重启APP的时候，可以使用这个方案
///https://stackoverflow.com/questions/50115311/flutter-how-to-force-an-application-restart-in-production-mode
class RestartWidget extends StatefulWidget {
  final Widget child;

  RestartWidget({Key key, @required this.child})
      : assert(child != null),
        super(key: key);

  static restartApp(BuildContext context) {
    final _RestartWidgetState state =
        context.findAncestorStateOfType<_RestartWidgetState>();
    state.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Container(
      key: key,
      child: widget.child,
    );
  }
}
