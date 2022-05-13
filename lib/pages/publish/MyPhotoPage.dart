import 'package:commuitynapp/bean/oss_tokendata_entity.dart';
import 'package:commuitynapp/util/LogUtil.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:commuitynapp/network/OssService.dart';
import 'package:commuitynapp/network/OssUtil.dart';

/*
*我的相册
*/
class MyPhotoPage extends StatefulWidget {
  MyPhotoPage();

  State<StatefulWidget> createState() => new _MyPhotoPageState();
}

class _MyPhotoPageState extends State<MyPhotoPage> {
  String filePath;

  _MyPhotoPageState();
  final ImagePicker imagePicker = ImagePicker();

  @override
  void initState() {
    //LogUtil.init(isDebug: true, tag: "****MyPhotoPage****");
  }

  @override
  Widget build(BuildContext context) {
    Widget _sectionAdd = Container(
      child: IconButton(
          iconSize: 60,
          onPressed: () {
            _selectImage();
          },
          icon: Icon(Icons.add)),
    );

    Widget _sectionImage = Container(
      width: 1000,
      height: 500,
      child: Image.asset("$filePath"),
    );

    Widget _body = Container(
      child: Column(
        children: <Widget>[
          filePath != null ? _sectionImage : Container(),
          _sectionAdd,
        ],
      ),
    );

    return new MaterialApp(
      theme: ThemeData(backgroundColor: Colors.white),
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('我的相册'),
          centerTitle: true,
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: onBack),
          actions: <Widget>[new Container()],
        ),
        body: _body,
      ),
    );
  }

  /*
  * 返回事件
  */
  void onBack() {
    Navigator.pop(context);
  }

  /*
  * 读取本地图片路径
  */
  Future _selectImage() async {
    var image = await imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        //LogUtil.i(image.path);
        filePath = image.path ?? "";
        _getOssToken();
      });
    }
  }

  /*
  * 获取OssToken
  */
  void _getOssToken() async {
    await ApiService.getOssToken(context).then((data) {
      //LogUtil.i("----开始获取 getOssToken()----");
      Map<String, dynamic> userMap = json.decode(data.toString());
      OssTokenDataEntity baseModel = OssTokenDataEntity.fromMap(userMap);
      if (baseModel != null && baseModel.credentials != null) {
        //已经获取到OssToken
        var _sign = baseModel.credentials;
        //LogUtil.i("getOssToken=" + baseModel.toString());
        OssUtil.accesskeyId = _sign.accessKeyId;
        OssUtil.accessKeySecret = _sign.accessKeySecret;
        OssUtil.stsToken = _sign.securityToken;
      } else {
        Fluttertoast.showToast(msg: "Token获取异常");
      }
    }).then((data) {
      //LogUtil.i("----开始上传图片----");
      _uploadImage();
    });
  }

  void _uploadImage() async {
    String uploadName = OssUtil.instance.getImageUploadName("photo", filePath);
    await ApiService.uploadImage(context, uploadName, filePath).then((data) {
      //LogUtil.v("----上传图片完成----data：" + data?.toString());
      if (data != null) {
        Fluttertoast.showToast(msg: "图片上传成功"+uploadName);
      }else{
        Fluttertoast.showToast(msg: "图片上传失败+uploadName");
      }
    }).then((data) {
      //更新数据库中数据
    });
  }
}

