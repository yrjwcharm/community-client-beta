import 'package:commuitynapp/main.dart';
import 'package:commuitynapp/pages/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:commuitynapp/http/http_request.dart';
import 'package:commuitynapp/http/mock_request.dart';
import 'package:commuitynapp/http/API.dart';
import 'dart:convert' as Convert;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:commuitynapp/pages/home/my_home_tab_bar.dart';
import 'package:commuitynapp/pages/container_page.dart';

import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}
//登录页面
class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email, _password;
  bool _isObscure = true;
  Color _eyeColor;
  List _loginMethod = [
    {
      "title": "facebook",
      "icon": GroovinMaterialIcons.facebook,
    },
    {
      "title": "google",
      "icon": GroovinMaterialIcons.google,
    },
    {
      "title": "twitter",
      "icon": GroovinMaterialIcons.twitter,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 22.0),
              children: <Widget>[
                SizedBox(
                  height: kToolbarHeight,
                ),
                buildTitle(),
                buildTitleLine(),
                SizedBox(height: 70.0),
                buildEmailTextField(),
                SizedBox(height: 30.0),
                buildPasswordTextField(context),
                buildForgetPasswordText(context),
                SizedBox(height: 60.0),
                buildLoginButton(context),
                SizedBox(height: 30.0),
                buildOtherLoginText(),
                buildOtherMethod(context),
                buildRegisterText(context),
              ],
            )));
  }

  Align buildRegisterText(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('没有账号？'),
            GestureDetector(
              child: Text(
                '点击注册',
                style: TextStyle(color: Colors.green),
              ),
              onTap: () {
                //TODO 跳转到注册页面
                print('去注册');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  ButtonBar buildOtherMethod(BuildContext context) {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: _loginMethod
          .map((item) => Builder(
        builder: (context) {
          return IconButton(
              icon: Icon(item['icon'],
                  color: Theme.of(context).iconTheme.color),
              onPressed: () {
                //TODO : 第三方登录方法
                Scaffold.of(context).showSnackBar(new SnackBar(
                  content: new Text("${item['title']}登录"),
                  action: new SnackBarAction(
                    label: "取消",
                    onPressed: () {},
                  ),
                ));
              });
        },
      ))
          .toList(),
    );
  }

  Align buildOtherLoginText() {
    return Align(
        alignment: Alignment.center,
        child: Text(
          '其他账号登录',
          style: TextStyle(color: Colors.grey, fontSize: 14.0),
        ));
  }

  //登录按钮
  Align buildLoginButton(BuildContext context) {
    return Align(
      child: SizedBox(
        height: 45.0,
        width: 270.0,
        child: RaisedButton(
          child: Text(
            '登录',
            style: TextStyle(color: Colors.grey, fontSize: 14.0),
          ),
          color: Colors.black,
          onPressed: () {
            if (_formKey.currentState.validate()) {
              ///只有输入的内容符合要求通过才会到达此处
              _formKey.currentState.save();
              //TODO 执行登录方法
              requestHomeAPI( _email, _password);
              print('email:$_email , assword:$_password');
            }
          },
          shape: StadiumBorder(side: BorderSide()),
        ),
      ),
    );
  }
  void requestHomeAPI(String _email,String _password) async {
    var _request = HttpRequest(API.COMMUNITY_BASE_URL);
    int start = 1;
    //var heads = new Map<String, String>();
    //heads['content-captcha']='application/json';
    //var heads={"content-type" : "application/json"};//创建 Map 集合
    var body = {"captcha": "", "password": "$_password", "username": "$_email"};

    final Map result = await _request.post('/sys/login',
        Convert.jsonEncode(body),
        headers: {"content-type": "application/json"});

//    final Map result = await _request.get(API.TOP_250 + '?start=$start&count=30');

    if (result['result'] != null) {
      var accessToken = result['result']['token'];
      var userInfo = result['result']['userInfo'];
      String user=Convert.jsonEncode(userInfo);
      print('[accessToken=$accessToken]');
      saveToken(accessToken,user); //保存登录token
      //SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    //跳转并关闭当前页面
      RestartWidget.restartApp(context);
      /*
      Navigator.pushAndRemoveUntil(
        context,
        new MaterialPageRoute(builder: (context) => new HomePage()),
            (route) => route == null,
      );
       */
  }else{

      Fluttertoast.showToast(
          msg: result['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
      );
    }

  }

  saveToken(String token,String userInfo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('X-Access-Token', token);
    await prefs.setString('userInfo', userInfo);
  }

  Padding buildForgetPasswordText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: FlatButton(
          child: Text(
            '忘记密码？',
            style: TextStyle(fontSize: 14.0, color: Colors.grey),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  TextFormField buildPasswordTextField(BuildContext context) {
    return TextFormField(
      onSaved: (String value) => _password = value,
      obscureText: _isObscure,
      validator: (String value) {
        if (value.isEmpty) {
          return '请输入密码';
        }
      },
      decoration: InputDecoration(
          labelText: '用户密码',
          suffixIcon: IconButton(
              icon: Icon(
                Icons.remove_red_eye,
                color: _eyeColor,
              ),
              onPressed: () {
                setState(() {
                  _isObscure = !_isObscure;
                  _eyeColor = _isObscure
                      ? Colors.grey
                      : Theme.of(context).iconTheme.color;
                });
              })),
    );
  }

  TextFormField buildEmailTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: '用户名',
      ),
      validator: (String value) {
        if (value.isEmpty) {
          return '请输入用户名';
        }
        /*
        var emailReg = RegExp(
            r"[\w!#$%&'*+/=?^_`{|}~-]+(?:\.[\w!#$%&'*+/=?^_`{|}~-]+)*@(?:[\w](?:[\w-]*[\w])?\.)+[\w](?:[\w-]*[\w])?");
        if (!emailReg.hasMatch(value)) {
          return '请输入正确的邮箱地址';
        }
        */
      },
      onSaved: (String value) => _email = value,
    );
  }

  Padding buildTitleLine() {
    return Padding(
      padding: EdgeInsets.only(left: 12.0, top: 4.0),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          color: Colors.black,
          width: 40.0,
          height: 2.0,
        ),
      ),
    );
  }

  Padding buildTitle() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        '第一次使用',
        style: TextStyle(fontSize: 42.0),
      ),
    );
  }
}