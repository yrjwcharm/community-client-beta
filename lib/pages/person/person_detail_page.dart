import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:commuitynapp/bean/subject_entity.dart';
import 'package:commuitynapp/constant/constant.dart';
import 'package:commuitynapp/http/API.dart';
import 'package:commuitynapp/http/http_request.dart';
import 'package:commuitynapp/router.dart' as AppRouter;
import 'package:commuitynapp/util/date_format.dart';
import 'package:commuitynapp/widgets/animal_photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:commuitynapp/widgets/image/radius_img.dart';
import 'package:commuitynapp/repository/person_detail_repository.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';
import 'dart:convert' as Convert;
import 'package:flutter/services.dart';
class PersonDetailPage extends StatefulWidget {
  final DynamicsEntity data;

  const PersonDetailPage({this.data, Key key}) : super(key: key);

  String get name => "PersonDetailPage";

  @override
  State<StatefulWidget> createState() {
    return _PersonDetailPageState();
  }
}

class _PersonDetailPageState extends State<PersonDetailPage>
    with SingleTickerProviderStateMixin {
  bool loading = true;
  //下拉上滑
  ScrollController _controller = ScrollController();
  int _count = 10;
  bool _isLoding = true;
  bool _showPersonPage = true;
  //bool _isRefreshing = false;
  String loadingText = "加载中.....";
  List<Subject> list;
  List<DynamicsEntity> dylist = List();
  int start = 1;
  double singleLineImgHeight = 180.0;
  double contentVideoHeight = 350.0;

  double contentHeight = 200.0;
  List<SubjectImage> hotBeans = List();
  bool _photoshow = false;
  bool _videoshow = false;
  bool _audioshow = false;
  int dazhaohu=0;
  Map<String, dynamic> api_data;
  String accessToken = null;
  PageController _pageController;
  TabController _tabController;
  var currentPage = 0;
  var isPageCanChanged = true;
  var PersonDetailMap;
  var _tabs = ['资料', '动态', '视频'];

  @override
  void initState() {
    super.initState();
    //widget.data.uid
    requestPersonDetailAPI(widget.data);

    _pageController = PageController(initialPage: 0);
    // 创建Controller
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      //TabBar的监听
      if (_tabController.indexIsChanging) {
        //判断TabBar是否切换
        // print(_tabController.index);
        onPageChange(_tabController.index, p: _pageController);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _pageController.dispose();
  }

  onPageChange(int index, {PageController p, TabController t}) async {
    if (p != null) {
      //判断是哪一个切换
      isPageCanChanged = false;
      await _pageController.animateToPage(index,
          duration: Duration(milliseconds: 200),
          curve: Curves.ease); //等待pageview切换完毕,再释放pageivew监听
      isPageCanChanged = true;
    } else {
      _tabController.animateTo(index); //切换Tabbar
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            //appBar: _appBarBuilder(),
            body: Stack(
      children: <Widget>[
        NestedScrollView(
            headerSliverBuilder: _sliverBuilder,
            body: Column(
              children: <Widget>[
                //_selectTabBarBuilder(),
                _selectPageBuilder()
              ],
            )),
        Positioned(
          top: 0,
          right: 0,
          left: 0,
          child: PreferredSize(
              preferredSize: Size(ScreenUtil.getInstance().setWidth(750),
                  ScreenUtil.getInstance().setHeight(Constant.APP_BAR_HEIGHT)),
              child: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    if(_showPersonPage){
                      Navigator.pop(context);
                    }

                  },
                ),
                actions: <Widget>[
                  new PopupMenuButton<String>(
                    //这是点击弹出菜单的操作，点击对应菜单后，改变屏幕中间文本状态，将点击的菜单值赋予屏幕中间文本
                      onSelected: (String value) {
                        setState(() {
                          //_bodyText = value;
                          if(value=="logout"){
                            logoutApi();
                          }
                        });
                      },
                      //这是弹出菜单的建立，包含了两个子项，分别是增加和删除以及他们对应的值
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        PopupMenuItem(
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              new Text('登出'),
                              //new Icon(Icons.add_circle)
                            ],
                          ),
                          value: 'logout',
                        ),
                        PopupMenuItem(
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              new Text('充值'),
                              //new Icon(Icons.remove_circle)
                            ],
                          ),
                          value: 'pay',
                        )
                      ])
                  /*
                  IconButton(
                    icon: Icon(
                      Icons.more_horiz,
                      color: Colors.black,
                    ),
                    onPressed: () {},
                  )
                  */
                ],
              )),
        ),
        Positioned(
            bottom: 0,
            right: 0,
            left: 0,
          child: new Visibility(
            child: Container(
              // color: Colors.cyan,
              height: ScreenUtil.getInstance().setWidth(120),
              padding: EdgeInsets.only(
                  bottom: ScreenUtil.getInstance().setWidth(10),
                  left: ScreenUtil.getInstance().setWidth(20),
                  right: ScreenUtil.getInstance().setWidth(20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                      onTap: () {
                      //打招呼，就是发消息
                        sendChat(widget.data);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          // 边色与边宽度
                          color: Colors.orange, // 底色
                          //        borderRadius: new BorderRadius.circular((20.0)), // 圆角度
                          borderRadius: new BorderRadius.circular(50),
                        ),
                        margin: EdgeInsets.symmetric(horizontal: ScreenUtil.getInstance().setWidth(5)),
                        padding: EdgeInsets.only(
                            left: ScreenUtil.getInstance().setWidth(85),
                            right: ScreenUtil.getInstance().setWidth(85),
                            top: ScreenUtil.getInstance().setWidth(10),
                            bottom: ScreenUtil.getInstance().setWidth(10)),
                        child: Row(
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.only(
                                    right:
                                        ScreenUtil.getInstance().setWidth(10)),
                                child: Icon(Icons.cloud_circle,
                                    size:
                                        ScreenUtil.getInstance().setWidth(50))),
                            Text("打招呼",
                                style: TextStyle(
                                    fontSize:
                                        ScreenUtil.getInstance().setSp(30)))
                          ],

                        ),
                      )),
                  GestureDetector(
                      onTap: () {},
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: ScreenUtil.getInstance().setWidth(5)),
                        decoration: BoxDecoration(
                          // 边色与边宽度
                          color: Colors.blue, // 底色
                          //        borderRadius: new BorderRadius.circular((20.0)), // 圆角度
                          borderRadius: new BorderRadius.circular(50),
                        ),
                        padding: EdgeInsets.only(
                            left: ScreenUtil.getInstance().setWidth(85),
                            right: ScreenUtil.getInstance().setWidth(85),
                            top: ScreenUtil.getInstance().setWidth(10),
                            bottom: ScreenUtil.getInstance().setWidth(10)),
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                  right: ScreenUtil.getInstance().setWidth(10)),
                              child: Icon(Icons.people,
                                  size: ScreenUtil.getInstance().setWidth(50)),
                            ),
                            Text(
                              "关注",
                              style: TextStyle(
                                  fontSize: ScreenUtil.getInstance().setSp(30)),
                            )
                          ],
                        ),
                      ))
                ],
              ),
            ),
            visible: _showPersonPage,
        ),
        )
      ],
    )));
  }

  List<Widget> _sliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      PreferredSize(
        preferredSize: Size(ScreenUtil.getInstance().setWidth(750),
            ScreenUtil.getInstance().setHeight(Constant.APP_BAR_HEIGHT)),
        child: SliverAppBar(
            backgroundColor: Colors.white,
            leading: null,
            elevation: 0,
            automaticallyImplyLeading: false,
            primary: false,
            bottom: _selectTabBarBuilder(),
            expandedHeight: ScreenUtil.getInstance().setWidth(750), //展开高度200
            floating: false, //不随着滑动隐藏标题
            pinned: true, //固定在顶部
            snap: false,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: _createSwiper(),
            )),
      ),
    ];
  }

  //轮播图
  Widget _createSwiper() {
    return Swiper(
      itemBuilder: _swiperBuilder,
      itemCount: 3,
      pagination: new SwiperPagination(
          builder: DotSwiperPaginationBuilder(
        color: Colors.black54,
        activeColor: Colors.white,
      )),
      //control: new SwiperControl(),
      scrollDirection: Axis.horizontal,
      autoplay: false,
      itemWidth: ScreenUtil.getInstance().setWidth(750),
      itemHeight: ScreenUtil.getInstance().setWidth(750),
      // onIndexChanged: (index) {
      //   swipperIndex = index;
      //   (context as Element).markNeedsBuild();
      // },
      onTap: (index) {},
    );
  }

  Widget _swiperBuilder(BuildContext context, int index) {
    return api_data != null
        ? FadeInImage.memoryNetwork(
            placeholder: kTransparentImage,
            image: API.URL_OSS_UPLOAD_IMAGE + '${api_data["head"]}',
            fit: BoxFit.fitWidth,
          )
        : Container();
  }

  Widget _selectTabBarBuilder() {
    return PreferredSize(
        preferredSize: Size(ScreenUtil.getInstance().setWidth(750),
            ScreenUtil.getInstance().setWidth(30)),
        child: Container(
            color: Colors.white,
            width: ScreenUtil.getInstance().setWidth(750),
            child: TabBar(
                //生成Tab菜单
                controller: _tabController,
                indicatorPadding: EdgeInsets.only(
                    left: ScreenUtil.getInstance().setWidth(10),
                    right: ScreenUtil.getInstance().setWidth(10)),
                indicatorSize: TabBarIndicatorSize.label,
                unselectedLabelStyle: TextStyle(fontSize: 20),
                labelStyle: TextStyle(fontSize: 20),
                unselectedLabelColor: Colors.grey,
                labelColor: Colors.black,
                indicatorColor: Colors.black,
                isScrollable: true,
                tabs: _tabs.map((e) => Tab(text: e)).toList())));
  }

  Widget _selectPageBuilder() {
    return Expanded(
      child: PageView.builder(
        physics: new AlwaysScrollableScrollPhysics(),
        itemCount: _tabs.length,
        onPageChanged: (index) {
          //等待上一次切换完成再进行切换
          if (isPageCanChanged) {
            //由于pageview切换是会回调这个方法,又会触发切换tabbar的操作,所以定义一个flag,控制pageview的回调
            onPageChange(index);
          }
        },
        controller: _pageController,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return _infoBuilder();
          } else if (index == 1) {
            return _dongTaiBuilder();
          } else if (index == 2) {
            return _vedioVuilder();
          }
        },
      ),
    );
  }

  Widget _infoBuilder() {
    if (api_data == null || api_data.isEmpty) {
      return UnconstrainedBox(
          alignment: Alignment.center, child: CircularProgressIndicator());
    }
    return Container(
      color: Colors.white,
      padding: new EdgeInsets.only(
          left: ScreenUtil.getInstance().setWidth(20),
          right: ScreenUtil.getInstance().setWidth(20),
          top: ScreenUtil.getInstance().setWidth(10),
          bottom: ScreenUtil.getInstance().setWidth(10)), //左上边距
      child: ListView(
        children: <Widget>[
          new Container(
            height: ScreenUtil.getInstance().setWidth(90),
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Text(
              (api_data["nickname"] ?? "unknow"),
              style: TextStyle(
                  fontSize: ScreenUtil.getInstance().setSp(40),
                  fontWeight: FontWeight.bold),
            ),
          ),
          new Container(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Row(
              children: <Widget>[
                Container(
                  height: ScreenUtil.getInstance().setWidth(30),
                  padding: EdgeInsets.only(
                      left: ScreenUtil.getInstance().setWidth(10),
                      right: ScreenUtil.getInstance().setWidth(10)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            right: ScreenUtil.getInstance().setWidth(5)),
                        child: Icon(
                          Icons.cloud_circle,
                          color: Colors.white,
                          size: ScreenUtil.getInstance().setWidth(20),
                        ),
                      ),
                      Text(api_data["age"],
                          style: TextStyle(
                              fontSize: ScreenUtil.getInstance().setWidth(20),
                              color: Colors.white))
                    ],
                  ),
                  decoration: BoxDecoration(
                    // 边色与边宽度
                    color: Colors.pink, // 底色
                    //        borderRadius: new BorderRadius.circular((20.0)), // 圆角度
                    borderRadius: new BorderRadius.circular(50),
                  ),
                ),
                Container(
                  height: ScreenUtil.getInstance().setWidth(30),
                  margin: EdgeInsets.only(
                      left: ScreenUtil.getInstance().setWidth(10)),
                  padding: EdgeInsets.only(
                      left: ScreenUtil.getInstance().setWidth(10),
                      right: ScreenUtil.getInstance().setWidth(10)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            right: ScreenUtil.getInstance().setWidth(5)),
                        child: Text(
                          "Lv",
                          style: TextStyle(
                              fontSize: ScreenUtil.getInstance().setWidth(20),
                              color: Colors.white),
                        ),
                      ),
                      Text("19",
                          style: TextStyle(
                              fontSize: ScreenUtil.getInstance().setWidth(20),
                              color: Colors.white))
                    ],
                  ),
                  decoration: BoxDecoration(
                    // 边色与边宽度
                    color: Colors.orange, // 底色
                    //        borderRadius: new BorderRadius.circular((20.0)), // 圆角度
                    borderRadius: new BorderRadius.circular(50),
                  ),
                )
              ],
            ),
          ),
          new Container(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Text(
              "账号信息",
              style: TextStyle(
                  fontSize: ScreenUtil.getInstance().setSp(20),
                  fontWeight: FontWeight.bold),
            ),
          ),
          // new Container(
          //   padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
          //   child: Text(api_data.toString()),
          // ),
          new Container(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Text(
              "昵称：" + (api_data["nickname"]),
              style: TextStyle(
                fontSize: ScreenUtil.getInstance().setSp(25),
              ),
            ),
          ),
          new Container(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Text(
                "注册日期：" + (formatDate(DateTime.parse(api_data["createTime"]) ,[yyyy,'-',mm,'-',dd])),
                style: TextStyle(
                  fontSize: ScreenUtil.getInstance().setSp(25),
                )),
          ),
          Container(
            padding: EdgeInsets.symmetric(
                vertical: ScreenUtil.getInstance().setWidth(10)),
          ),
          new Container(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Text(
              "个人信息",
              style: TextStyle(
                  fontSize: ScreenUtil.getInstance().setSp(20),
                  fontWeight: FontWeight.bold),
            ),
          ),
          new Container(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Text("性别：" + (api_data["sex"] == 0 ? ("男") : ("女")),
                style: TextStyle(
                  fontSize: ScreenUtil.getInstance().setSp(25),
                )),
          ),
          new Container(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Text("年龄：" + api_data["age"],
                style: TextStyle(
                  fontSize: ScreenUtil.getInstance().setSp(25),
                )),
          ),
          new Container(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Text("位置：" + (api_data["location"]),
                style: TextStyle(
                  fontSize: ScreenUtil.getInstance().setSp(25),
                )),
          ),
          new Container(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Text("地址：" + (api_data["addr"]),
                style: TextStyle(
                  fontSize: ScreenUtil.getInstance().setSp(25),
                )),
          ),
          Container(
            padding: EdgeInsets.symmetric(
                vertical: ScreenUtil.getInstance().setWidth(10)),
          ),
          new Container(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Text(
              "我的标签",
              style: TextStyle(
                  fontSize: ScreenUtil.getInstance().setSp(20),
                  fontWeight: FontWeight.bold),
            ),
          ),
          new Container(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: new SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _tagBuilder(),
                )),
          ),
        ],
      ),
    );
  }

  List<Widget> _tagBuilder() {
    List<String> tags = [
      "小清新",
      "乐天派",
      "宅",
      "开心",
      "动漫",
      "影视",
      "影视",
      "影视",
      "影视",
      "影视",
      "影视",
      "影视",
      "影视",
      "影视",
      "影视"
    ];
    return tags.map((String tag) {
      return Container(
        margin: EdgeInsets.only(right: ScreenUtil.getInstance().setWidth(10)),
        padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil.getInstance().setWidth(10)),
        decoration: BoxDecoration(
          // 边色与边宽度
          color: Color(0xfff2f2f2), // 底色
          //        borderRadius: new BorderRadius.circular((20.0)), // 圆角度
          borderRadius: new BorderRadius.circular(50),
        ),
        height: ScreenUtil.getInstance().setWidth(40),
        child: Text(
          tag,
          style: TextStyle(fontSize: ScreenUtil.getInstance().setSp(30)),
        ),
      );
    }).toList();
  }

  Widget _dongTaiBuilder() {
    Widget dongTai = getDynamicsPageContent();

    return dongTai;
  }

  Widget _vedioVuilder() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[Text("")],
      ),
    );
  }

  void requestAPI() async {
    Future(() => (PersonDetailRepository().requestAPI(api_data["uid"])))
        .then((personDetailRepository) {
      //setState(() {
        loading = false;
      //});
    });
  }

  Widget _tabPageBuilder(BuildContext context, int index) {
    if (api_data == null) {
      return Container();
    }
    if (index == 0) {
    } else if (index == 1) {
    } else if (index == 2) {
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[Text("")],
        ),
      );
    }
  }

  var _request = HttpRequest(API.COMMUNITY_BASE_URL);
  void requestPersonDetailAPI(var data) async {
    var uid;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('X-Access-Token');
    var userInfo = prefs.getString('userInfo');
    if(userInfo==null||userInfo==""){
      return;
    }
    Map<String, dynamic> user=Convert.jsonDecode(userInfo);
    //如果参数空，判断为我的主页
    if(data==null||data==""){
      //默认从缓存取
      //SharedPreferences prefs = await SharedPreferences.getInstance();
      uid=user["uid"];
      _showPersonPage=false;
    }else{
      uid=data.uid;
      //if(user["uid"]==uid){
      //  _showPersonPage=false;
      //}

    }


    if (accessToken != null) {
      final Map result1 =
          await _request.post('/feed/getPersondetail', "uid=$uid", headers: {
        "content-type": "application/x-www-form-urlencoded",
        "X-Access-Token": accessToken
      });
      setState(() {
        api_data = result1;
        //widget.data.uid=uid;
        requestHomeAPI(false);
      });
    }
  }

  void logoutApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('X-Access-Token');

    if (accessToken != null) {
      final Map result1 =
      await _request.post('/sys/logout', "", headers: {
        "content-type": "application/x-www-form-urlencoded",
        "X-Access-Token": accessToken
      });
      setState(() {
        if(result1!=null){
          prefs.clear();
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        }
      });
    }
  }


  void sendChat(var data) async {
    if(dazhaohu==1){
      return;
    }
    var uid;
    var to_uid;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('X-Access-Token');

      //默认从缓存取
      var userInfo = prefs.getString('userInfo');
      if(userInfo==null||userInfo==""){
        return;
      }
      Map<String, dynamic> user=Convert.jsonDecode(userInfo);
      uid=user["uid"];//这个是没有打开页面，是我的主页
      to_uid=data.uid;//这个是打开页面，有参数传入，是个人的主页
    if (accessToken != null) {
      var body1 = {
        "createTime": "",
        "fromUid": "$uid",
        "message": "你好",
        "toUid": "$to_uid",
        "type": 0
      };
      final Map result1 = await _request.post(
          '/feed/publishChat',
          Convert.jsonEncode(body1),
          headers: {
            "content-type": "application/json",
            "X-Access-Token": accessToken
          });

      if (result1 != null && result1['result'] == "1") {
        setState(() {
          //   api_data = result1;
          dazhaohu=1;
        });
      }

      Fluttertoast.showToast(
        msg: "已经打招呼给对方",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
      );

    }
  }

//我的动态列表
  Widget getDynamicsPageContent() {
    if (accessToken == null) {
      return Container();
    }

    if (dylist == null || dylist.length == 0) {
      requestHomeAPI(false);
      print('暂无数据');
      return Text('暂无数据', style: new TextStyle(color: Colors.black87));
    }
    // print('getDynamicsPageContent');
    //print(dylist);

    return Container(
        child: NotificationListener(
      child: RefreshIndicator(
        child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            key: PageStorageKey<String>("PersonaldongTai"),
            itemCount: dylist.length,
            itemBuilder: (BuildContext context, int index) {
              //print(index);
              return getDynamicCommonItem(index);
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
    ));
  }

  ///动态的列表的普通单个item
  getDynamicCommonItem(int index) {
    DynamicsEntity item = dylist[index];

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


    //print(item);
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

//获取动态列表API
  void requestHomeAPI(bool isdown) async {
    if (isdown) {
      //setState(() {
        start += 1;
      //});
    } else {
      //setState(() {
        start = 1;
        dylist.clear();
     // });
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('X-Access-Token');
    print(accessToken);
    if (accessToken != null) {
      var uid = api_data["uid"];

      final Map result1 = await _request.post(
          '/feed/my_dynamics', 'uid=$uid&pageNo=$start&pageSize=10',
          headers: {
            "content-type": "application/x-www-form-urlencoded",
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
}
