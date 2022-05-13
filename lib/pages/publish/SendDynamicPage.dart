
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:commuitynapp/bean/oss_tokendata_entity.dart';
import 'package:commuitynapp/bean/subject_entity.dart';
import 'package:commuitynapp/constant/constant.dart';
import 'package:commuitynapp/http/API.dart';
import 'package:commuitynapp/http/http_request.dart';
import 'package:commuitynapp/pages/publish/subject_sendynamic_image_widget.dart';
import 'package:commuitynapp/router.dart' as AppRouter;
import 'package:commuitynapp/util/LogUtil.dart';
import 'package:commuitynapp/widgets/animal_photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:commuitynapp/network/OssService.dart';
import 'package:commuitynapp/network/OssUtil.dart';
import 'dart:math' as math;
import 'dart:convert' as Convert;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
/*
*发布动态页
*/
class SendDynamicPage extends StatefulWidget {
  SendDynamicPage();

  State<StatefulWidget> createState() => new _SendDynamicPage();
}

class _SendDynamicPage extends State<SendDynamicPage> {


  String _dongtaiMessage;
  String filePath;
  List<SubjectImage> photofilePathList = List();
  _SendDynamicPage();
  int uploadImgCount=0;
  String uploadImgUrl="";
  String accessToken = null;
  final ImagePicker imagePicker = ImagePicker();
  @override
  void initState() {
    //LogUtil.init(isDebug: true, tag: "****MyPhotoPage****");
    uploadImgCount=0;
    uploadImgUrl="";
    photofilePathList.clear();
  }
  var hotChildAspectRatio;
  var itemW;
  //声明一个TextEditingController保存输入框的值
  static TextEditingController textEditingController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    //
    MediaQuery.of(context);
    var w = MediaQuery.of(context).size.width;
    itemW = (w - 30.0) / 2.5;
    hotChildAspectRatio = (377.0 / 674.0);

    Widget _sectionAddPhoto = Container(
      child: IconButton(
          iconSize: 60,
          onPressed: () {
            _selectImage();
          },
          icon: Icon(Icons.add)),
    );
    Widget _sectionAddAudio = Container(
      child: IconButton(
          iconSize: 60,
          onPressed: () {

            //AppRouter.Router.push(context, Router.recorderPage, "");
          },
          icon: Icon(Icons.audiotrack)),
    );
    Widget _sectionImage = Container(
      width: 1000,
      height: 500,
      child: Image.asset("$filePath"),
    );
    //页面主体
    Widget _body = Container(
      child: Column(
        children: <Widget>[
          //filePath != null ? _sectionImage : Container(),
         buildSendTextField,
          _pictureBuilder(context, photofilePathList),//图片容器
          _sectionAddPhoto,//上传图片按钮
          _sectionAddAudio,
        ],
      ),
    );

    return new MaterialApp(
      theme: ThemeData(backgroundColor: Colors.white),
      debugShowCheckedModeBanner: false,
      home: new Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.white,
          //title: new Text('发布动态'),
          centerTitle: true,
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: onBack),
          actions: <Widget>[
            Container(
              //margin: const EdgeInsets.only(bottom: 10.0),
              padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 10,
                  bottom: 10.0),
              child: RaisedButton(
              child: Text(
                '发布动态',
                  style: TextStyle(fontSize: 12, color: Colors.white)
                //style: Theme.of(context).primaryTextTheme.body1,
              ),
              color: Colors.blue,
              //elevation: 10,
              onPressed: () {
                _getOssToken();
              },

              shape: const RoundedRectangleBorder(
                  side: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(50))),
            ),
          )
          ],
          //actions: <Widget>[new Container()],
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
      //setState(() {

        // print(image.lengthSync());
        filePath = image.path ?? "";
        final Map<String, dynamic> data = new Map<String, dynamic>();
        // images = Images(img['small'], img['large'], img['medium']);
        data['images'] = Images(filePath, filePath, filePath);
        SubjectImage sj = new SubjectImage.fromMap(data);
        if(photofilePathList.length<=6){

          setState(() {
            photofilePathList.add(sj);
          });

        }

        //_getOssToken();
     // });
    }
  }

  /*
  * 获取STS OssToken，并上传
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
      LogUtil.v("获取STS授权成功，开始上传图片逻辑");
      if (photofilePathList.length>0) {
        int index=0;
        for (var value in photofilePathList) {
          index++;
          //开始压缩图片
          var targetPath=getFileImage(value.images.large,index).then((data) {
            _uploadImage(data.absolute.path);//上传图片到oss
          });

        }
      }else{
        //普通文字发布
        publishDtAPI();
      }


    });
  }


  Future getFileImage(String filePath,int index) async {


    var dir = await getTemporaryDirectory();
    var targetPath = dir.absolute.path + "/$index-temp.jpg";
    var imgFile;
    print("pre compress");
    File file = File(filePath);
    print(file.lengthSync());
    //file.writeAsBytesSync(data.buffer.asUint8List());
    String imageType=filePath?.substring(filePath?.lastIndexOf("."),filePath?.length);
    if(imageType==".gif"||imageType==".GIF"){
      //targetPath = filePath+ "-temp.gif";
      //不压缩
      imgFile=file;
    }else{
      //targetPath = filePath + "-temp.png";
      imgFile= await testCompressAndGetFile(file, targetPath);
    }

    setState(() {});
    return imgFile;
  }

  Future<List<int>> testCompressFile(File file) async {
    print("testCompressFile");
    var result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 2300,
      minHeight: 1500,
      quality: 94,
      rotate: 180,
    );
    print(file.lengthSync());
    print(result.length);
    return result;
  }

  Future<File> testCompressAndGetFile(File file, String targetPath) async {
    print("testCompressAndGetFile");
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 90,
      minWidth: 1024,
      minHeight: 1024,
      //rotate: 90,
    );

    print(file.lengthSync());
    print(result.lengthSync());

    return result;
  }

  void _uploadImage(String filePath) async {
    //压缩文件

    String uploadName = OssUtil.instance.getImageUploadName("photo", filePath);
    //String uploadName ="photo/"+filePath;
    await ApiService.uploadImage(context, uploadName, filePath).then((data) {
      //LogUtil.v("----上传图片完成----data：" + data?.toString());
      if (data != null) {
        //Fluttertoast.showToast(msg: "图片上传成功"+uploadName);
        //更新数据库中数据
        uploadImgCount=uploadImgCount+1;
        //拼接url
        uploadImgUrl=uploadImgUrl+uploadName+"|";
        if(uploadImgCount==photofilePathList.length){
          //所有图片上传成功后，提交发布动态接口。
          //uploadImgUrl.substring(1,uploadImgUrl.length-1);
          publishDtAPI();
        }
      }else{
        Fluttertoast.showToast(msg: "图片上传失败+uploadName");
        //重试+1
        _uploadImage(filePath);
      }
    }).then((data) {

    });
  }


  Widget buildSendTextField = Container(
      child: TextField(
        autofocus: true,
        decoration: InputDecoration(
          hintText: "请输入发布的内容",

        ),
        //使用controller保存输入框的值
        controller: textEditingController
      )
  );

  //图片展示，1-6张的情况都有相应的展示方法
  Widget _pictureBuilder1(BuildContext context, List<SubjectImage> imgs) {
    //var imgs = imgs1.sublist(0, 3);
    //imgs.add(imgs1[0]);
    //imgs.add(imgs1[1]);

    //imgs = (imgs[0]);
    //print(imgs.length);
    if (imgs == null || imgs.length == 0) {
      return Container();
    }

    //最多显示6张
    if (imgs.length > 6) {
      imgs.sublist(0, 6);
    }

    Widget child;
    var picWidth;
    var picHeight;
    var width;

    if (imgs.length == 1) {
      picWidth = (ScreenUtil().setWidth(750) -
          Constant.MARGIN_LEFT -
          Constant.MARGIN_RIGHT -
          10) *
          0.6;
      picHeight = picWidth;
      //print(picHeight);
      child = Container(
        width: picWidth,
        height: picHeight,
        child:SubjectSendynamicImageWidget( imgs[0].images.small, width:picWidth),
      );
      width = picWidth;
    } else if (imgs.length == 4 || imgs.length == 2) {
      picWidth = (ScreenUtil().setWidth(750) -
          Constant.MARGIN_LEFT -
          Constant.MARGIN_RIGHT -
          10) *
          0.4;
      picHeight = picWidth;
      child = GridView.count(
        primary: true,
        physics: const NeverScrollableScrollPhysics(),
        //shrinkWrap: true,
        crossAxisCount: 2,
        mainAxisSpacing: ScreenUtil().setWidth(5),
        crossAxisSpacing: ScreenUtil().setWidth(5),
        childAspectRatio: 1.0,
        children: imgs.map((img) {
          return SubjectSendynamicImageWidget( img.images.small, width:picWidth);
        }).toList(),
      );
      width = picWidth * 2 + 10;
    } else {
      picWidth = (ScreenUtil().setWidth(750) -
          Constant.MARGIN_LEFT -
          Constant.MARGIN_RIGHT -
          10) /
          3;
      picHeight = picWidth;
      child = GridView.count(
        primary: true,
        physics: const NeverScrollableScrollPhysics(),
        //shrinkWrap: true,
        crossAxisCount: 3,
        mainAxisSpacing: ScreenUtil().setWidth(5),
        crossAxisSpacing: ScreenUtil().setWidth(5),
        childAspectRatio: 1.0,
        children: imgs.map((img) {
          return SubjectSendynamicImageWidget( img.images.small, width:picWidth);
        }).toList(),
      );
      width = ScreenUtil().setWidth(750);
    }
    // print(ScreenUtil().setWidth(750));
    // print(picHeight);
    // print(picWidth);
    // print(imgs.length);
    // print("\n");
    return Container(
      width: width,
      height: (imgs.length > 3 ? picHeight * 2 : picHeight) + 20,
      //color: Colors.cyan,
      padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(10)),
      //constraints: BoxConstraints(maxHeight: picHeight * 2, minHeight: 0),
      child: child,
    );
  }
  ///动态图片item
  Widget _getDongtaiPhotos(
      BuildContext context, SubjectImage subjectImage, double width) {
    if (subjectImage == null) {
      return Container();
    }

    return GestureDetector(
      child: ClipRRect(
        child: Image.file( new File(subjectImage.images.small)),
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),

      onTap: () {
        //调起相册浏览
        AnimalPhoto.show(
            context,1,subjectImage.images.small);
        /*
      Fluttertoast.showToast(
        msg: "这是一个图片",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
      );

       */
        //AppRouter.Router.push(context, AppRouter.Router.detailPage, hotMovieBean.id);
      },
    );
  }
//图片展示，1-6张的情况都有相应的展示方法
  Widget _pictureBuilder(BuildContext context, List<SubjectImage> imgs) {
    //var imgs = imgs1.sublist(0, 3);

    //imgs.add(imgs[1]);

    //imgs = (imgs[0]);
    //print(imgs.length);
    if (imgs == null || imgs.length == 0) {
      return Container();
    }

    //最多显示6张
    if (imgs.length > 6) {
      imgs = imgs.sublist(0, 6);
    }

    Widget child;
    var picWidth;
    var picHeight;
    var width;

    if (imgs.length == 1) {
      picWidth = (ScreenUtil.getInstance().setWidth(750) -
          Constant.MARGIN_LEFT -
          Constant.MARGIN_RIGHT -
          10) *
          0.6;
      picHeight = picWidth;
      //print(picHeight);
      child = Container(
        width: picWidth,
        height: picHeight,
        child: _getDongtaiPhotos(context, imgs[0], picWidth),
      );
      width = picWidth;
    } else if (imgs.length == 4 || imgs.length == 2) {
      picWidth = (ScreenUtil.getInstance().setWidth(750) -
          Constant.MARGIN_LEFT -
          Constant.MARGIN_RIGHT -
          ScreenUtil.getInstance().setWidth(10)) *
          0.4;
      picHeight = picWidth;
      if (imgs.length == 2) {
        child = Container(
          height: picHeight,
          child: Row(
            children: <Widget>[
              Container(
                width: picWidth,
                height: picHeight,
                margin:
                EdgeInsets.only(right: ScreenUtil.getInstance().setWidth(5)),
                child: _getDongtaiPhotos(context, imgs[0], picWidth),
              ),
              Container(
                width: picWidth,
                height: picHeight,
                child: _getDongtaiPhotos(context, imgs[1], picWidth),
              ),
            ],
          ),
        );
      } else if (imgs.length == 4) {
        child = Column(
          children: <Widget>[
            Padding(
              child: Row(
                children: <Widget>[
                  Container(
                    //color: Colors.red,
                    width: picWidth,
                    height: picHeight,
                    margin: EdgeInsets.only(
                        right: ScreenUtil.getInstance().setWidth(5)),
                    child: _getDongtaiPhotos(context, imgs[0], picWidth),
                  ),
                  Container(
                    width: picWidth,
                    height: picHeight,
                    child: _getDongtaiPhotos(context, imgs[1], picWidth),
                  ),
                ],
              ),
              padding:
              EdgeInsets.only(bottom: ScreenUtil.getInstance().setWidth(10)),
            ),
            Row(
              children: <Widget>[
                Container(
                  width: picWidth,
                  height: picHeight,
                  margin: EdgeInsets.only(
                      right: ScreenUtil.getInstance().setWidth(5)),
                  child: _getDongtaiPhotos(context, imgs[2], picWidth),
                ),
                Container(
                  width: picWidth,
                  height: picHeight,
                  child: _getDongtaiPhotos(context, imgs[3], picWidth),
                ),
              ],
            ),
          ],
        );
      }
      width = picWidth * 2 + ScreenUtil.getInstance().setWidth(10);
    } else {
      picWidth = (ScreenUtil.getInstance().setWidth(750) -
          Constant.MARGIN_LEFT -
          Constant.MARGIN_RIGHT -
          ScreenUtil.getInstance().setWidth(10)) /
          3;
      picHeight = picWidth;
      List<Widget> columnList = List();
      List<Widget> secRowList = List();
      columnList.add(
        Row(
          children: <Widget>[
            Container(
              width: picWidth,
              height: picHeight,
              margin:
              EdgeInsets.only(right: ScreenUtil.getInstance().setWidth(5)),
              child: _getDongtaiPhotos(context, imgs[0], picWidth),
            ),
            Container(
              width: picWidth,
              height: picHeight,
              margin:
              EdgeInsets.only(right: ScreenUtil.getInstance().setWidth(5)),
              child: _getDongtaiPhotos(context, imgs[1], picWidth),
            ),
            Container(
              width: picWidth,
              height: picHeight,
              child: _getDongtaiPhotos(context, imgs[2], picWidth),
            ),
          ],
        ),
      );

      for (int i = 3; i < imgs.length; i++) {
        secRowList.add(
          Container(
            width: picWidth,
            height: picHeight,
            margin: EdgeInsets.only(
                right: i < imgs.length - 1
                    ? ScreenUtil.getInstance().setWidth(5)
                    : 0),
            child: _getDongtaiPhotos(context, imgs[i], picWidth),
          ),
        );
      }
      columnList.add(Padding(
          padding: EdgeInsets.only(top: ScreenUtil.getInstance().setWidth(10)),
          child: Row(
            children: secRowList,
          )));
      child = Column(
        children: columnList,
      );
      width = picWidth * 3 + ScreenUtil.getInstance().setWidth(10);
    }
    // print(ScreenUtil.getInstance().setWidth(750));
    // print(picHeight);
    // print(picWidth);
    // print(imgs.length);
    // print("\n");
    return Container(
      width: width,
      //height: (imgs.length > 3 ? picHeight * 2 : picHeight) + ScreenUtil.getInstance().setWidth(20),
      //color: Colors.cyan,
      margin: EdgeInsets.only(top: ScreenUtil.getInstance().setHeight(5)),
      //constraints: BoxConstraints(maxHeight: picHeight * 2, minHeight: 0),
      child: child,
    );
  }

  var _request = HttpRequest(API.COMMUNITY_BASE_URL);
  void publishDtAPI() async {
    String sendmsg=textEditingController.text.toString();
    int dType=0;
    if(uploadImgUrl!=""){
      dType=1;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('X-Access-Token');

    String userInfo;
    Map<String, dynamic> user;
    userInfo = prefs.getString('userInfo');
    if(userInfo==null){
      return;
    }
    user=Convert.jsonDecode(userInfo);

    if (accessToken != null) {

      var body1 = {
        "dHotscore": 0,
    "dIsdel": 0,
    "dMessage": "$sendmsg",
    "dPosttime": "",
    "dTitle": "",
    "dType": dType,
    "dZancount": 0,
    "did": "",
    "dUrl": "$uploadImgUrl",
    "location": "北京市海淀区",
    "uid": user["uid"]
    };

      final Map result1 = await _request.post(
          '/feed/publishDt',
          Convert.jsonEncode(body1),
          headers: {
            "content-type": "application/json",
            "X-Access-Token": accessToken
          });

      var result = result1['result'];
      if (result!="") {
        Fluttertoast.showToast(msg: "发布成功");
        Navigator.pop(context);
      }
    }


  }

}

