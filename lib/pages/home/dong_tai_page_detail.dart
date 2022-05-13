import 'package:cached_network_image/cached_network_image.dart';
import 'package:commuitynapp/bean/comments_entity.dart';
import 'package:commuitynapp/routers/pop_router.dart';
import 'package:commuitynapp/router.dart' as AppRouter;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';
import 'dart:convert' as Convert;
import '../../bean/subject_entity.dart';
import '../../constant/constant.dart';
import '../../http/API.dart';
import '../../http/http_request.dart';
import '../../widgets/animal_photo.dart';
String commentGuid = "10b981f796c24c4fe27fb16d5a327348";
String userInfo;
Map<String, dynamic> user;
HttpRequest _request;
class DongTaiDetailPage extends StatefulWidget {
  final DynamicsEntity data;

  const DongTaiDetailPage({Key key, this.data}) : super(key: key);

  @override
  _DongTaiDetailPageState createState() => _DongTaiDetailPageState();
}

class _DongTaiDetailPageState extends State<DongTaiDetailPage> implements OnDialogClickListener{

  double singleLineImgHeight = 180.0;
  bool isRaised;
  List<SubjectImage> hotBeans = List();
  TextEditingController commentController = new TextEditingController();

  List<SingleCommentEntity> commentList = [];
  bool isLoading = false;
  int currentPage = 1;

  @override
  void initState() {
    commentGuid=widget.data.did;
    _request = HttpRequest(API.COMMUNITY_BASE_URL);
    getComments();

    //初始化点赞
    isRaised = false;
    hotBeans.clear();
    List ls = widget.data.dUrl.toString().split("|");
    //print(ls.length);
    int index = 0;
    if (ls != null && ls.length > 0) {
      for (var value in ls) {
        if (value != "") {
          index++;
          if (index <= 3) {
            final Map<String, dynamic> data = new Map<String, dynamic>();
            // images = Images(img['small'], img['large'], img['medium']);
            data['images'] = Images(value, value, value);
            SubjectImage sj = new SubjectImage.fromMap(data);
            //print("*********************$sj");
            hotBeans.add(sj);
          }
        }
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    _request = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //print(hotBeans.length);
    return SafeArea(
      child: Scaffold(
          resizeToAvoidBottomInset: true,

          //backgroundColor: Colors.white,
          appBar: AppBar(
            //brightness: Brightness.light,
            elevation: 2.0,
            //backgroundColor: Colors.white,
            title: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: ScreenUtil().setWidth(30),
                  backgroundImage: widget.data.userHead != null
                      ? NetworkImage(
                          API.URL_OSS_UPLOAD_IMAGE + '${widget.data.userHead}')
                      : AssetImage('assets/images/nohead.jpg'),

                  child: GestureDetector(
                    //onTap: _onClick,//写入方法名称就可以了，但是是无参的
                    onTap: () {
                      AppRouter.Router.push(
                          context, AppRouter.Router.personDetailPage, widget.data);
                    },
                    //child: Text("dianji"),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: ScreenUtil().setWidth(15)),
                  child: Text(widget.data.usrNickname != null
                      ? '${widget.data.usrNickname}'
                      : '游客'),
                ),

              ],
            ),
            actions: <Widget>[
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.more_horiz,
                  color: Colors.grey,
                  size: 18.0,
                ),
              ),
            ],
          ),
          body: Stack(children: <Widget>[
            Container(
                padding: EdgeInsets.only(
                    left: ScreenUtil().setWidth(Constant.MARGIN_LEFT),
                    right: ScreenUtil().setWidth(Constant.MARGIN_RIGHT),
                    top: ScreenUtil().setHeight(Constant.MARGIN_TOP)),
                width: ScreenUtil().setWidth(750),
                height: ScreenUtil().setHeight(1334),
                child: NotificationListener(
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
                  child: ListView(
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(
                              top: ScreenUtil.getInstance().setWidth(5)),
                          child: _contentBuilder()),
                      Padding(
                        padding: EdgeInsets.only(
                            top: ScreenUtil.getInstance().setWidth(5),
                            bottom: ScreenUtil.getInstance().setWidth(5)),
                        child: _pictureBuilder(context, hotBeans),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: ScreenUtil.getInstance().setWidth(5),
                            bottom: ScreenUtil.getInstance().setWidth(5)),
                        child: Container(
                          child: Text("1小时前发布.10km.2344阅读",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black26)),
                          padding: EdgeInsets.only(
                              top: ScreenUtil.getInstance().setHeight(10),
                              bottom: ScreenUtil.getInstance().setHeight(10)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: ScreenUtil.getInstance().setWidth(5),
                            bottom: ScreenUtil.getInstance().setWidth(5)),
                        child: _operationBuilder(),
                      ),
                      _commentListBuilder(),
                      Container(
                        color: Colors.transparent,
                        width: ScreenUtil.getInstance().setWidth(750),
                        height: ScreenUtil.getInstance().setHeight(100),
                      )
                    ],
                  ),
                )),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: ScreenUtil.getInstance().setHeight(100),
                decoration: BoxDecoration(
                    color: Color(0xfffbfbfb),
                    border: Border(
                        top: BorderSide(
                            width: ScreenUtil.getInstance().setWidth(1),
                            color: Color(0xffe1e1e1),
                            style: BorderStyle.solid))),
//        color: Color(0xfffbfbfb),
                child: Container(
                  height: ScreenUtil().setWidth(98),
                  padding: EdgeInsets.only(
                    left: ScreenUtil().setWidth(30),
                    right: ScreenUtil().setWidth(30),
                  ),
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      _comment(context,"");
                    },
                    child: Container(
                      alignment: Alignment.center,
                      //padding: EdgeInsets.only(left: ScreenUtil().setWidth(20)),
                      //width: ScreenUtil().setWidth(50),
                      height: ScreenUtil().setWidth(62),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: Color(0xffbcbcbc),
                              width: ScreenUtil().setWidth(1)),
                          borderRadius: BorderRadius.all(
                              Radius.circular(ScreenUtil().setWidth(10)))),
                      child: Text(
                        '发表你的评论',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: ScreenUtil().setSp(28)),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ])),
    );
  }

  void _comment(BuildContext context,String uid) async {
    var comment = await Navigator.push(context,
        PopRoute(child: BottomInputDialog(uid, commentController,this)));
    if (comment != null) {
      setState(() {
       // print(widget.data);
      });
    }
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
    //imgs.add(imgs[0]);
    //imgs.add(imgs[0]);
    //imgs.add(imgs[0]);
    // print(imgs.length);
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
              ScreenUtil.getInstance().setWidth(10)) *
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
              10) *
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
              padding: EdgeInsets.only(
                  bottom: ScreenUtil.getInstance().setWidth(10)),
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

  ///动态图片item
  Widget _getDongtaiPhotos(
      BuildContext context, SubjectImage subjectImage, double width) {
    if (subjectImage == null) {
      return Container();
    }

    return GestureDetector(
      child: ClipRRect(
        child: FadeInImage.memoryNetwork(
          placeholder: kTransparentImage,
          image: API.URL_OSS_UPLOAD_IMAGE + subjectImage.images.large,
          fit: BoxFit.cover,
          width: width,
          height: width,
        ),
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
      onTap: () {
        //调起相册浏览
        AnimalPhoto.show(
            context, 0,API.URL_OSS_UPLOAD_IMAGE + subjectImage.images.large);
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

//点赞
  Future<bool> requestZanAPI(String did, String uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var accessToken = prefs.getString('X-Access-Token');
    if (accessToken != null) {
      final Map result1 =
          await _request.post('/feed/zan', "did=$did&uid=$uid", headers: {
        "content-type": "application/x-www-form-urlencoded",
        "X-Access-Token": accessToken
      });
      if (result1 != null && result1['result'] == "1") {
        return true;
      }
    }
    return false;
  }

  Widget _contentBuilder() {
    return Container(
      child: Text(
        widget.data.dMessage,
        maxLines: 10,
        overflow: TextOverflow.fade,
        style: TextStyle(fontSize: 20),
      ),
      //child: showVideo ? getContentVideo(index) : getItemCenterImg(item),
    );
  }

  Widget _operationBuilder() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(child: Builder(
          builder: (context) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  //onTap: _onClick,//写入方法名称就可以了，但是是无参的
                  onTap: () {
                    if (isRaised) {
                      isRaised = false;
                      widget.data.dZancount = widget.data.dZancount - 1;
                      (context as Element).markNeedsBuild();
                    } else {
                      //requestZanAPI(widget.data.did, widget.data.uid).then((data) {
                      // if (data) {
                      isRaised = true;
                      widget.data.dZancount = widget.data.dZancount + 1;
                      (context as Element).markNeedsBuild();
                    }
                    //}
                    //}).catchError((err) {});

                    //AppRouter.Router.push(context, AppRouter.Router.detailPage,"");
                  },
                  child: isRaised
                      ? Image.asset(
                          Constant.ASSETS_IMG + 'ic_vote.png',
                          color: Colors.blue,
                          width: 25.0,
                          height: 25.0,
                        )
                      : Image.asset(
                          Constant.ASSETS_IMG + 'ic_vote.png',
                          width: 25.0,
                          height: 25.0,
                        ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 5),
                  child: Text(widget.data.dZancount.toString()),
                ),
              ],
            );
          },
        )),
        Expanded(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  Constant.ASSETS_IMG +
                      'ic_notification_tv_calendar_comments.png',
                  width: 20.0,
                  height: 20.0,
                ),
                Container(
                    padding: EdgeInsets.only(left: 5),
                    child: Text(widget.data.dDiscusscount.toString())),
              ]),
        ),
        Expanded(
          child: Container(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              //onTap: _onClick,//写入方法名称就可以了，但是是无参的
              onTap: () {
                AppRouter.Router.push(context, AppRouter.Router.myPhotoPage, "");
              },

              child: Image.asset(
                Constant.ASSETS_IMG + 'ic_status_detail_reshare_icon.png',
                width: 25.0,
                height: 25.0,
              ),
            ),
          ),
        ),
      ],
    );
  }




  getComments() async {
    if (isLoading) {
      return;
    }
    isLoading = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('X-Access-Token');


    userInfo = prefs.getString('userInfo');
    if(userInfo==null){
      return;
    }
    user=Convert.jsonDecode(userInfo);



    if (accessToken != null) {
      final Map result1 = await _request.post('/feed/dt_discusslist',
          "did=${commentGuid}&pageNo=$currentPage&pageSize=10",
          headers: {
            "content-type": "application/x-www-form-urlencoded",
            "X-Access-Token": accessToken
          });
      var resultList = result1['result']['records'];

      setState(() {
        commentList.addAll(resultList
            .map<SingleCommentEntity>(
                (item) => SingleCommentEntity.fromMap(item))
            .toList());
        isLoading = false;
        currentPage += 1;
        //print("\n\n\n\n\n\n\n$commentList\n\n\n\n\n\n\n");
      });
      if (currentPage-1 == 1) getComments();
    }
  }

  //滑动底部刷新
  Future<String> _RrefreshPullDown() async {
    getComments();
    return "_RrefreshPull";
  }

  Widget _commentListBuilder() {
    return Container(
        child: ListView.builder(
      shrinkWrap: true,
      physics: new NeverScrollableScrollPhysics(),
      itemCount: commentList.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Text("最新评论(${commentList.length})");
        }
        return ListTile(
          leading: CircleAvatar(
            radius: ScreenUtil().setWidth(30),
            backgroundImage: commentList[index - 1].userHead != null
                ? NetworkImage(
                    API.URL_OSS_UPLOAD_IMAGE + '${commentList[index - 1].userHead}')
                : AssetImage('assets/images/nohead.jpg'),
            backgroundColor: Colors.white,
            child: GestureDetector(
              //onTap: _onClick,//写入方法名称就可以了，但是是无参的
              onTap: () {
                AppRouter.Router.push(context, AppRouter.Router.detailPage, "");
              },
              //child: Text("dianji"),
            ),
          ),
          title: Text(
            commentList[index - 1].usrNickname != null
                ? '${commentList[index - 1].usrNickname}'
                : '游客',
            style: TextStyle(color: Colors.grey),
          ),
          subtitle: Text(commentList[index - 1].discMessage+(commentList[index - 1].atUsers!=null?"@"+commentList[index - 1].atUsers:""),
              style: TextStyle(color: Colors.black)),

          trailing: FlatButton(
            onPressed: () {
              _comment(context,commentList[index - 1].discUid);
            },
            child: Text(
              "回复",
              style: TextStyle(color: Colors.blue),
            ),
          ),
        );
      },
    ));
  }

  @override
  void onCancel() {
    // TODO: implement onCancel
  }

  @override
  void onOk() {
    setState(() {
      currentPage=1;
      commentList.clear();
      getComments();
    });
    // TODO: implement onOk
  }
}

//定义一个抽象类
abstract class OnDialogClickListener {
  void onOk();
  void onCancel();
}

//评论框
class BottomInputDialog extends StatefulWidget {
  final data;
  final commentController;
  final OnDialogClickListener callback;
  BottomInputDialog(this.data, this.commentController,this.callback);

  @override
  _BottomInputDialogState createState() =>
      _BottomInputDialogState(this.data, this.commentController,this.callback);
}

//评论框
class _BottomInputDialogState extends State<BottomInputDialog>
    with SingleTickerProviderStateMixin {
  final String _data;
  final TextEditingController commentController;
  final OnDialogClickListener callback;
  Animation<double> animation;
  AnimationController controller;
  double begin = ScreenUtil().setHeight(1334);
  double end = ScreenUtil().setHeight(0);

  //焦点控制
  final FocusNode focusNode = new FocusNode();

  _BottomInputDialogState(this._data, this.commentController,this.callback);

  @override
  void initState() {
    super.initState();
    //监听焦点变化
    focusNode.addListener(onFocusChange);
    controller = new AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);

    animation = new Tween(begin: begin, end: end).animate(controller)
      ..addListener(() {
        setState(() {});
      });
    controller.forward();
  }

  //焦点更新
  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {});
    }
  }

  void addComments(String text) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('X-Access-Token');
    var body = {
      "discAtUid": _data,
      "discCreatime": "",
      "discDid": "$commentGuid",
      "discId": "",
      "discMessage": text,
      "discPid": "",
      "discUid": user["uid"]
    };

    if (accessToken != null) {
      final Map result = await _request.post('/feed/add_discuss',
          Convert.jsonEncode(body),
          headers: {"content-type": "application/json",
            "X-Access-Token": accessToken
          });

      if (result['result'] != null) {
        callback.onOk();
        Navigator.pop(context);
        //getComments();
      } else {
        Fluttertoast.showToast(
          msg: result['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBuilder(
          animation: animation,
          builder: (BuildContext ctx, Widget child) {
            return child;
          },
          child: Container(
              width: ScreenUtil().setWidth(750),
              height: ScreenUtil().setHeight(1334),
              child: new Stack(children: <Widget>[
                Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: new GestureDetector(
                      child: new Container(
                        color: Colors.black54,
                      ),
                      onTap: () {
                        controller.reverse();
                        Navigator.pop(context);
                      },
                    )),
                Positioned(
                    left: 0,
                    right: 0,
                    bottom: -animation.value,
                    child: Container(
                      color: Colors.white,
                      child: Column(children: <Widget>[
                        Container(
                          color: Colors.white,
                          child: TextField(
                              controller: commentController,
                              maxLength: 300,
                              maxLines: 3,
                              style: TextStyle(
                                  fontFamily: "CNLight",
                                  fontSize: ScreenUtil().setSp(24),
                                  color: Color(0xff7d7d7d)),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: ScreenUtil().setWidth(38),
                                    right: ScreenUtil().setWidth(38),
                                    top: ScreenUtil().setWidth(28)),
                                hintStyle: TextStyle(
                                    fontFamily: "CNLight",
                                    fontSize: ScreenUtil().setSp(24),
                                    color: Color(0xff7d7d7d)),
                                hintText: '写下你的评论',
                                border: InputBorder.none,
                              ),
                              autofocus: true,
                              focusNode: focusNode,
                              onChanged: (value) {}),
                        ),
                        Container(
                            height: ScreenUtil().setWidth(90),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                    top: BorderSide(
                                        width: ScreenUtil().setWidth(2),
                                        color: Color(0xfff0f0f0),
                                        style: BorderStyle.solid))),
                            child: Container(
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(
                                  right: ScreenUtil().setWidth(50)),
                              child: GestureDetector(
                                onTap: () {
                                  //调用发布评论接口
                                  addComments(commentController.text);
                                  //print('input ${commentController.text}');
                                },
                                child: Container(
                                  color: Colors.transparent,
                                  alignment: Alignment.center,
                                  child: Text("发送",
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(28),
                                          color: Colors.cyan)),
                                ),
                              ),
                            )),
                      ]),
                    ))
              ]))),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
