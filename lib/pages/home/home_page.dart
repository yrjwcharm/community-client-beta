import 'package:cached_network_image/cached_network_image.dart';
import 'package:commuitynapp/pages/detail/look_confirm_button.dart';
import 'package:commuitynapp/widgets/VideoScreen.dart';
import 'package:commuitynapp/widgets/animal_photo.dart';
import 'package:commuitynapp/widgets/subject_dynamic_image_widget.dart';
import 'package:commuitynapp/widgets/subject_mark_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:commuitynapp/widgets/search_text_field_widget.dart';
import 'package:commuitynapp/pages/home/home_app_bar.dart' as myapp;
import 'package:commuitynapp/http/http_request.dart';
import 'package:commuitynapp/http/mock_request.dart';
import 'package:commuitynapp/http/API.dart';
import 'package:commuitynapp/bean/subject_entity.dart';
import 'package:commuitynapp/widgets/image/radius_img.dart';
import 'package:commuitynapp/constant/constant.dart';
import 'package:commuitynapp/widgets/video_widget.dart';
import 'package:commuitynapp/router.dart' as AppRouter;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert' as Convert;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math' as math;

import 'package:transparent_image/transparent_image.dart';

typedef RequestCallBack<T> = void Function(T value);
String accessToken = null;

//将按下的颜色设置较为浅色
var btnPressedColor = Color.fromARGB(100, 0, 0, 0);

///首页，TAB页面，显示动态和推荐TAB
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('build HomePage');
    return getWidget();
  }
}

var _tabs = ['推荐', '动态'];

DefaultTabController getWidget() {
  return DefaultTabController(
    initialIndex: 0,
    length: _tabs.length, // This is the number of tabs.
    child: NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        // These are the slivers that show up in the "outer" scroll view.
        return <Widget>[
          SliverOverlapAbsorber(
            // This widget takes the overlapping behavior of the SliverAppBar,
            // and redirects it to the SliverOverlapInjector below. If it is
            // missing, then it is possible for the nested "inner" scroll view
            // below to end up under the SliverAppBar even when the inner
            // scroll view thinks it has not been scrolled.
            // This is not necessary if the "headerSliverBuilder" only builds
            // widgets that do not overlap the next sliver.
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: myapp.SliverAppBar(
              pinned: true,
              expandedHeight: 80.0,
              primary: false,
              titleSpacing: 0.0,
              backgroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Container(
                  color: Colors.white,
                  alignment: Alignment(0.0, -0.5),
                ),
              ),
              /* tab上的搜索框
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Container(

                  color: Colors.green,

                  child: SearchTextFieldWidget(
                    hintText: '影视作品中你难忘的离别',
                    margin: const EdgeInsets.only(left: 15.0, right: 15.0),
                    onTab: () {
                      AppRouter.Router.push(context, AppRouter.Router.searchPage, '影视作品中你难忘的离别');
                    },
                  ),


                  alignment: Alignment(0.0, 0.0),
                ),
              ),
               */

              // The "forceElevated" property causes the SliverAppBar to show
              // a shadow. The "innerBoxIsScrolled" parameter is true when the
              // inner scroll view is scrolled beyond its "zero" point, i.e.
              // when it appears to be scrolled below the SliverAppBar.
              // Without this, there are cases where the shadow would appear
              // or not appear inappropriately, because the SliverAppBar is
              // not actually aware of the precise position of the inner
              // scroll views.
              bottomTextString: _tabs,
              bottom: TabBar(
                // These are the widgets to put in each tab in the tab bar.
                tabs: _tabs
                    .map((String name) => Container(
                          child: Text(name, textScaleFactor: 5),
                          padding: const EdgeInsets.only(bottom: 5.0),
                        ))
                    .toList(),
              ),
            ),
          ),
        ];
      },
      //渲染tabbar下的内容
      body: TabBarView(
        // These are the contents of the tab views, below the tabs.
        children: _tabs.map((String name) {
          return SliverContainer(
            name: name,
          );
        }).toList(),
      ),
    ),
  );
}

class SliverContainer extends StatefulWidget {
  final String name;

  SliverContainer({Key key, @required this.name}) : super(key: key);

  @override
  _SliverContainerState createState() => _SliverContainerState();
}

class _SliverContainerState extends State<SliverContainer> {

  final ValueNotifier<double> notifier = ValueNotifier(-1);

  //下拉上滑
  ScrollController _controller = ScrollController();
  int _count = 10;
  bool _isLoding = true;
  //bool _isRefreshing = false;
  String loadingText = "加载中.....";
  List<Subject> list;
  List<DynamicsEntity> dylist = List();
  int start = 1;

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void initState() {
    super.initState();

    print('init state${widget.name}');

    ///
    //if (list == null || list.isEmpty) {
    if (_tabs[0] == widget.name) {
      //请求推荐数据
      requestAPI();
    } else {
      ///请求动态数据

      requestHomeAPI(false);
/*
        _controller.addListener(() {
          if (_controller.position.pixels ==
              _controller.position.maxScrollExtent) {
            print('滑动到了最底部${_controller.position.pixels}');


          }
        });
        */
    }
    //}
  }

  var _request = HttpRequest(API.COMMUNITY_BASE_URL);
  void requestHomeAPI(bool isdown) async {
    if (isdown) {
        start += 1;
    } else {
        start = 1;
        dylist.clear();
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('X-Access-Token');
    if (accessToken != null) {
      var body1 = {"lat": 0, "lng": 0, "location": "北京市海淀区"};
      final Map result1 = await _request.post(
          '/feed/recommend_dynamic?pageNo=$start&pageSize=10',
          Convert.jsonEncode(body1),
          headers: {
            "content-type": "application/json",
            "X-Access-Token": accessToken
          });

      //final Map result = await _request.get(WEEKLY);
      var resultList = result1['result']['records'];
      setState(() {
          dylist.addAll(resultList
              .map<DynamicsEntity>((item) => DynamicsEntity.fromMap(item))
              .toList());
          if (resultList.length == 0) {

              loadingText = "没有更多的了";
              //_isLoding = false;

          }
      });
    }

  }

//点赞
  Future<bool> requestZanAPI(String did, String uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('X-Access-Token');
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

  void requestAPI() async {
//    var _request = HttpRequest(API.BASE_URL);
//    int start = math.Random().nextInt(220);
//    final Map result = await _request.get(API.TOP_250 + '?start=$start&count=30');
//    var resultList = result['subjects'];

    var _request = MockRequest();
    var result = await _request.get(API.TOP_250);
    var resultList = result['subjects'];

    setState(() {
      list = resultList.map<Subject>((item) => Subject.fromMap(item)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    MediaQuery.of(context);
    var w = MediaQuery.of(context).size.width;
    itemW = (w - 30.0) / 2.5;
    hotChildAspectRatio = (377.0 / 674.0);
    if (widget.name == _tabs[0]) {
      return getContentSliver(context, list);
    }
    if (widget.name == _tabs[1]) {
      return getDynamicsPageContentSliver(context, dylist);
    }
  }

///////////////////////

//头部下拉刷新
  Future<String> _RrefreshPull() async {
    requestHomeAPI(false);
    return "_RrefreshPull";
  }

//滑动底部刷新
  Future<String> _RrefreshPullDown() async {
    requestHomeAPI(true);
    return "_RrefreshPull";
  }

  /////////推荐代码///////////

  getContentSliver1(BuildContext context, List<Subject> list) {
    print('getContentSliver');
    if (list == null || list.length == 0) {
      return Text('暂无数据');
    }
    return SafeArea(
      top: false,
      bottom: false,
      child: Builder(
        // This Builder is needed to provide a BuildContext that is "inside"
        // the NestedScrollView, so that sliverOverlapAbsorberHandleFor() can
        // find the NestedScrollView.
        builder: (BuildContext context) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            // The "controller" and "primary" members should be left
            // unset, so that the NestedScrollView can control this
            // inner scroll view.
            // If the "controller" property is set, then this scroll
            // view will not be associated with the NestedScrollView.
            // The PageStorageKey should be unique to this ScrollView;
            // it allows the list to remember its scroll position when
            // the tab view is not on the screen.
            key: PageStorageKey<String>(widget.name),
            slivers: <Widget>[
              SliverOverlapInjector(
                // This is the flip side of the SliverOverlapAbsorber above.
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              SliverList(
                  delegate: SliverChildBuilderDelegate(
                      ((BuildContext context, int index) {
                return getCommonItem(list, index);
              }), childCount: list.length)),
            ],
          );
        },
      ),
    );
  }

  getContentSliver(BuildContext context, List<Subject> list) {
    print('getContentSliver');
    if (list == null || list.length == 0) {
      return Text('暂无数据');
    }
    return SafeArea(
      top: false,
      bottom: false,
      child: Builder(
        // This Builder is needed to provide a BuildContext that is "inside"
        // the NestedScrollView, so that sliverOverlapAbsorberHandleFor() can
        // find the NestedScrollView.
        builder: (BuildContext context) {
          return NotificationListener<ScrollNotification>(

            onNotification: (ScrollNotification notification) {
              notifier.value = notification.metrics.pixels;
              return true;
            },
            child: RefreshIndicator(
              child: CustomScrollView(
                controller: _controller,
                physics: const BouncingScrollPhysics(),
                key: PageStorageKey<String>(widget.name),
                slivers: <Widget>[
                  SliverOverlapInjector(
                    // This is the flip side of the SliverOverlapAbsorber above.
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context),
                  ),

                  SliverList(
                      delegate: SliverChildBuilderDelegate(
                          ((BuildContext context, int index) {
                            return getCommonItem(list, index);
                          }), childCount: list.length)),
                  //加载中

                ],
              ),
              onRefresh: () {
                //return null;
              },
            ),

          );
        },
      ),
    );
  }

  getDynamicsPageContentSliver(
      BuildContext context, List<DynamicsEntity> dylist) {
    if (accessToken == null) {
      return _loginContainer(context);
    }

    print('getContentSliver');
    if (dylist == null || dylist.length == 0) {
      return Text('暂无数据', style: new TextStyle(color: Colors.black87));
    }
    return new MaterialApp(
      home: Scaffold(
        //发布动态按钮
        floatingActionButton: Container(
          height: 70,
          width: 70,
          padding: EdgeInsets.all(8),
          margin: EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            color: Colors.white,
          ),
          child: FloatingActionButton(
              child: Icon(Icons.add, color: Colors.black, size: 40),
              onPressed: () {
                AppRouter.Router.push(context, AppRouter.Router.sendDynamicPage, "");
                print('FloatingActionButton');
              },
              backgroundColor: Colors.yellow),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        body: new Container(
          child: new NotificationListener(
            child: RefreshIndicator(
              child: CustomScrollView(
                controller: _controller,
                physics: const BouncingScrollPhysics(),
                key: PageStorageKey<String>(widget.name),
                slivers: <Widget>[
                  SliverOverlapInjector(
                    // This is the flip side of the SliverOverlapAbsorber above.
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context),
                  ),

                  SliverList(
                      delegate: SliverChildBuilderDelegate(
                          ((BuildContext context, int index) {
                    return getDynamicCommonItem(dylist, index);
                  }), childCount: dylist.length)),
                  //加载中

                  new SliverToBoxAdapter(
                    child: new Visibility(
                      child: new Container(
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: new Center(
                          child: new Text(loadingText,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black26)),
                        ),
                      ),
                      visible: _isLoding,
                    ),
                  ),
                ],
              ),
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
                  //setState(() {
                    _isLoding = true;
                    loadingText = "加载中.....";
                  //});
                  _RrefreshPullDown().then((value) {
                    print('加载成功.............');
                  }).catchError((error) {
                    print('failed');
                    //setState(() {
                      _isLoding = true;
                      loadingText = "加载失败.....";
                    //});
                  });
                }
              }
            },
          ),
        ),
      ),
    );
  }

  double singleLineImgHeight = 180.0;
  double contentVideoHeight = 350.0;

  double contentHeight = 200.0;
  List<SubjectImage> hotBeans = List();
  bool _photoshow = false;
  bool _videoshow = false;
  bool _audioshow = false;
  getDynamicCommonItem
  ///动态的列表的普通单个item
  (List<DynamicsEntity> items, int index) {
    DynamicsEntity item = items[index];
    if (item.dType == 0) {
      //文字
      contentHeight = ScreenUtil.getInstance().setWidth(200);
      _photoshow = false;
    } else if (item.dType == 1) {
      //文字和图片
      contentHeight = ScreenUtil.getInstance().setWidth(390);
      _photoshow = true;
      hotBeans.clear();
      List ls = item.dUrl.toString().split("|");
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
              hotBeans.add(sj);
            }
          }
        }
      }
    } else if (item.dType == 2) {
      //文字和语音
      contentHeight = ScreenUtil.getInstance().setWidth(200);
    } else if (item.dType == 3) {
      //文字和视频
      contentHeight = ScreenUtil.getInstance().setWidth(350);
    }
//singleLineImgHeight
    return Container(
      //height: contentHeight,
      color: Colors.white,
      padding: EdgeInsets.only(
        left: ScreenUtil.getInstance().setWidth(Constant.MARGIN_LEFT),
        right: ScreenUtil.getInstance().setWidth(Constant.MARGIN_RIGHT),
        top: ScreenUtil.getInstance().setHeight(Constant.MARGIN_TOP),
      ),
      //child: Text('SliverFixedExtentList item $index'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 25.0,
                backgroundImage: item.userHead != null
                    ? NetworkImage(
                        API.URL_OSS_UPLOAD_IMAGE + '${item.userHead}')
                    : AssetImage('assets/images/nohead.jpg'),
                backgroundColor: Colors.white,
                child: GestureDetector(
                  //onTap: _onClick,//写入方法名称就可以了，但是是无参的
                  onTap: () {
                    AppRouter.Router.push(context, AppRouter.Router.personDetailPage, item);
                  },
                  //child: Text("dianji"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                    item.usrNickname != null ? '${item.usrNickname}' : '游客'),
              ),
              Expanded(
                child: Align(
                  child: Icon(
                    Icons.more_horiz,
                    color: Colors.grey,
                    size: 18.0,
                  ),
                  alignment: Alignment.centerRight,
                ),
              )
            ],
          ),
          /*
          Expanded(
              child: Container(
                child: Text(item.dMessage+item.dType.toString()+item.dUrl),
                    //child:if(1){},
                //child: showVideo ? getContentVideo(index) : getItemCenterImg(item),
              )),

           */

          //文字
          GestureDetector(
              onTap: () {
                AppRouter.Router.push(context, AppRouter.Router.dongTaiDetailPage, item);
              },
              child: Container(
                //color: Colors.cyan,
                width: ScreenUtil.screenWidth,
                padding: EdgeInsets.only(
                  top: ScreenUtil.getInstance().setHeight(10),
                ),
                child: Text(
                  item.dMessage,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                //child: showVideo ? getContentVideo(index) : getItemCenterImg(item),
              )),

          //图片
          Visibility(
            child: _pictureBuilder(context, hotBeans),
            visible: _photoshow,
          ),
          Container(
            //color: Colors.blue,
            //width: 100.0,
            //height: 50.0,
            child: Padding(
              child: Text("1小时前发布.10km.2344阅读",
                  style: TextStyle(fontSize: 12, color: Colors.black26)),
              padding: EdgeInsets.only(
                  top: ScreenUtil.getInstance().setHeight(10),
                  bottom: ScreenUtil.getInstance().setHeight(10)),
            ),
          ),
          Row(
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
                          requestZanAPI(item.did, item.uid).then((data) {
                            if(data){
                              item.dZancount = item.dZancount + 1;
                              (context as Element).markNeedsBuild();
                            }else{
                              Fluttertoast.showToast(
                                msg: "您已经点过赞",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                              );
                            }

                          });
                        },
                        child: Image.asset(
                          Constant.ASSETS_IMG + 'ic_vote.png',
                          width: 25.0,
                          height: 25.0,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(item.dZancount.toString(),style: TextStyle(fontSize: 12, color: Colors.black26)),
                      ),
                    ],
                  );
                },
              )),
              Expanded(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        //onTap: _onClick,//写入方法名称就可以了，但是是无参的
                        onTap: () {
                          AppRouter.Router.push(context, AppRouter.Router.dongTaiDetailPage, item);
                        },
                        child:
                        Image.asset(
                          Constant.ASSETS_IMG +
                              'ic_notification_tv_calendar_comments.png',
                          width: 20.0,
                          height: 20.0,
                        ),
                      ),

                      Container(
                          padding: EdgeInsets.only(left: 5),
                          child: Text(item.dDiscusscount.toString(),style: TextStyle(fontSize: 12, color: Colors.black26))),
                    ]),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    //onTap: _onClick,//写入方法名称就可以了，但是是无参的
                    onTap: () {},

                    child: Image.asset(
                      Constant.ASSETS_IMG + 'ic_status_detail_reshare_icon.png',
                      width: 25.0,
                      height: 25.0,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  ///列表的普通单个item
  getCommonItem(List<Subject> items, int index) {
    Subject item = items[index];
    bool showVideo = index == 1 || index == 3;
    return Container(
      height: showVideo ? contentVideoHeight : singleLineImgHeight,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.only(
          left: Constant.MARGIN_LEFT,
          right: Constant.MARGIN_RIGHT,
          top: Constant.MARGIN_RIGHT,
          bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 25.0,
                backgroundImage: NetworkImage(item.casts[0].avatars.medium),
                backgroundColor: Colors.white,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(item.title),
              ),
              Expanded(
                child: Align(
                  child: Icon(
                    Icons.more_horiz,
                    color: Colors.grey,
                    size: 18.0,
                  ),
                  alignment: Alignment.centerRight,
                ),
              )
            ],
          ),
          Expanded(
              child: Container(
            child: showVideo ? getContentVideo(index) : getItemCenterImg(item),
          )),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Image.asset(
                  Constant.ASSETS_IMG + 'ic_vote.png',
                  width: 25.0,
                  height: 25.0,
                ),
                Image.asset(
                  Constant.ASSETS_IMG +
                      'ic_notification_tv_calendar_comments.png',
                  width: 20.0,
                  height: 20.0,
                ),
                Image.asset(
                  Constant.ASSETS_IMG + 'ic_status_detail_reshare_icon.png',
                  width: 25.0,
                  height: 25.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getItemCenterImg(Subject item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Expanded(
          child: RadiusImg.get(item.images.large, null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5.0),
                    bottomLeft: Radius.circular(5.0)),
              )),
        ),
        Expanded(
          child: RadiusImg.get(item.casts[1].avatars.medium, null, radius: 0.0),
        ),
        Expanded(
          child: RadiusImg.get(item.casts[2].avatars.medium, null,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(5.0),
                      bottomRight: Radius.circular(5.0)))),
        )
      ],
    );
  }

  getContentVideo(int index) {
    if (!mounted) {
      return Container();
    }
    return VideoScreen(index: index, notifier: notifier,url:index == 1 ? Constant.URL_MP4_DEMO_0 : Constant.URL_MP4_DEMO_1);
    /*
    return VideoWidget(
      index == 1 ? Constant.URL_MP4_DEMO_0 : Constant.URL_MP4_DEMO_1,
      showProgressBar: false,
    );
    */
  }
}

///动态TAB
_loginContainer(BuildContext context) {
  return Align(
    alignment: Alignment(0.0, 0.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          Constant.ASSETS_IMG + 'ic_new_empty_view_default.png',
          width: 120.0,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15.0, bottom: 25.0),
          child: Text(
            '登录后查看关注人动态',
            style: TextStyle(fontSize: 16.0, color: Colors.grey),
          ),
        ),
        GestureDetector(
          child: Container(
            child: Text(
              '去登录',
              style: TextStyle(fontSize: 16.0, color: Colors.green),
            ),
            padding: const EdgeInsets.only(
                left: 35.0, right: 35.0, top: 8.0, bottom: 8.0),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.green),
                borderRadius: const BorderRadius.all(Radius.circular(6.0))),
          ),
          onTap: () {
            AppRouter.Router.push(context, AppRouter.Router.loginPage, '');
          },
        )
      ],
    ),
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

var hotChildAspectRatio;
var itemW;

///动态图片布局
SliverGrid getCommonSliverGrid(List<SubjectImage> hotBeans) {
  return SliverGrid(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return _getDongtaiPhotos(context, hotBeans[index], itemW);
      }, childCount: math.min(hotBeans.length, 6)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 0.0,
          childAspectRatio: hotChildAspectRatio));
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
          context,0, API.URL_OSS_UPLOAD_IMAGE + subjectImage.images.large);
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
