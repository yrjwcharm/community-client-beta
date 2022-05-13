import 'dart:convert';
import 'package:commuitynapp/bean/chat_entity.dart';
import 'package:commuitynapp/global/global.dart';
import 'package:commuitynapp/http/API.dart';
import 'package:commuitynapp/http/http_request.dart';
//import 'package:commuitynapp/model/Observer.dart';
import 'package:commuitynapp/model/chat_message_model.dart';
import 'package:commuitynapp/model/contact_people.dart';
import 'package:commuitynapp/router.dart' as AppRouter;
import 'package:commuitynapp/widgets/widget_w_popup_menu.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as Convert;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

const gVpao = 10.0;
const gHpao = 16.0;

HttpRequest _request;
bool isLoading = false;
int currentPage = 1;
String test1="41479828b219239398cc75363fc6fa9f";
String test2="5484f6fdc9b0faf1a32f31476d38c9d9";
String userInfo;
Map<String, dynamic> user;
class MessageChat extends StatefulWidget {
  final ChatEntity friend;


  //final channel = new IOWebSocketChannel.connect('ws://echo.websocket.org');
  MessageChat({this.friend});
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<MessageChat>  {
  //WebSocketChannel channel;
  final ScrollController col = ScrollController();
  IOWebSocketChannel _channel ;
  var messageList = [];
  int flag = 0;
  final List<String> actions = [
   // '复制',
    '撤回',
  ];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();
  @override
  update(ChatMessage data) {
      setState(() {

        //messageList.add({"text": data.msg, "identity": this.widget.friend.fromUid});
      });
  }
  //头部下拉刷新
  Future<String> _RrefreshPull() async {
    messageList.clear();
    currentPage=0;
    getChatMessage();
    return "_RrefreshPull";
  }
  //滑动底部刷新
  Future<String> _RrefreshPullDown() async {
    //getChatMessage();
    return "_RrefreshPull";
  }

  getInitChatMessage() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    userInfo = prefs.getString('userInfo');
    if(userInfo==null){
      return;
    }
    user=Convert.jsonDecode(userInfo);
    String accessToken = prefs.getString('X-Access-Token');
    if (accessToken != null) {
      final Map result1 = await _request.post('/feed/my_chat',
          "myuid=${test1}&touid=${test2}&pageNo=$currentPage&pageSize=10",
          headers: {
            "content-type": "application/x-www-form-urlencoded",
            "X-Access-Token": accessToken
          });
      var resultList = result1['result']['records'];
      var pages = result1['result']['pages'];
      currentPage=pages;
      if(resultList.length==0){
        currentPage =currentPage- 1;
      }
      getChatMessage();

      //if (currentPage-1 == 1) getMessagePersons();
    }
  }

  getChatMessage() async {
    if(currentPage<=0){
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userInfo = prefs.getString('userInfo');
    if(userInfo==null){
      return;
    }
    user=Convert.jsonDecode(userInfo);

   // if (isLoading) {
   //   return;
   // }
    //isLoading = true;


    String accessToken = prefs.getString('X-Access-Token');
    if (accessToken != null) {
      final Map result1 = await _request.post('/feed/my_chat',
          "myuid=${test1}&touid=${test2}&pageNo=$currentPage&pageSize=10",
          headers: {
            "content-type": "application/x-www-form-urlencoded",
            "X-Access-Token": accessToken
          });
      var resultList = result1['result']['records'];
      var pages = result1['result']['pages'];


      currentPage -= 1;
      setState(() {
        messageList.insertAll(0,resultList
            .map<ChatEntity>(
                (item) => ChatEntity.fromMap3(item))
            .toList());
        isLoading = false;

        //print("\n\n\n\n\n\n\n$commentList\n\n\n\n\n\n\n");
      });
      //if (currentPage-1 == 1) getMessagePersons();
    }
  }

  delChatMessage(String chat_id,index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('X-Access-Token');
    if (accessToken != null) {
      final Map result1 = await _request.post('/feed/delChat',
          "chat_id=${chat_id}&touser=${test2}",
          headers: {
            "content-type": "application/x-www-form-urlencoded",
            "X-Access-Token": accessToken
          });
      //var resultList = result1['result']['records'];
      //var pages = result1['result']['pages'];
      setState(() {
        //删除数组相关记录
        messageList.removeAt(index);
      });

    }
  }
  sendChatMessage(String str) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('X-Access-Token');
    if (accessToken != null) {

      var body1 = {
        "createTime": "",
        "fromUid": "$test1",
        "message": "$str",
        "toUid": "$test2",
        "type": 0
      };
      final Map result1 = await _request.post('/feed/publishChat',
          Convert.jsonEncode(body1),
          headers: {
            "content-type": "application/json",
            "X-Access-Token": accessToken
          });
      var resultList = result1['result'];



        if(resultList!=""||resultList!=null){
          var timestamp = result1['timestamp'];

          var body1 = {
            "chatId":resultList,
            "fromnameHead":user['head'],
            "createTime": timestamp,
            "fromUid": "$test1",
            "message": "$str",
            "toUid": "$test2",
            "type": 0
          };
          setState(() {
          messageList.add(ChatEntity.fromMap2(body1));

          });
        }




    }
  }

  @override
  void initState() {
    super.initState();
    test1=widget.friend.fromUid;
    test2=widget.friend.toUid;
    //开启我的websocket用于接收发送到我这里的消息。
    var socketUrl=API.COMMUNITY_BASE_URL+"/websocket/"+test1;
    socketUrl=socketUrl.replaceAll("https","ws").replaceAll("http","ws");
    _channel= IOWebSocketChannel.connect(socketUrl);
    _channel.stream.listen((message) {
         print(message);
         var messageList1 = [];
         var message_en=Convert.jsonDecode(message);
         if(message_en['type']==4){
           for(ChatEntity item in messageList) {
             if(item.chatId==message_en['chatId']){
               //item.message="--撤回消息--";
               //messageList1.add(item);
            }else{
               messageList1.add(item);
             }


           }
           setState(() {
             messageList.clear();
             messageList=messageList1;
           });
           col.jumpTo(col.position.maxScrollExtent+50);
         }else{
           setState(() {
             messageList.add(ChatEntity.fromMap2(message_en));
             col.jumpTo(col.position.maxScrollExtent+50);
           });
         }

         


         //col.jumpTo(col.position.maxScrollExtent);
    });


    col.addListener(() {
      if(col.position.pixels == col.position.maxScrollExtent) {
        print('arrive end: hasMore = ');

      }
    });

    messageList.clear();
    currentPage=0;
    _request = HttpRequest(API.COMMUNITY_BASE_URL);
    setState(() {
      getInitChatMessage();
    });
  }

  @override
  void dispose() {
    super.dispose();
    //gChannel.sink.close();
  }

  Widget buildTextField() {
    return Theme(
      data: new ThemeData(
          primaryColor: Color.fromRGBO(189, 189, 189, 1),
          hintColor: Colors.blue),
      child: TextField(
        onChanged: (String str) {},
        onSubmitted: (String str) {
         // gChannel.sink.add(json.encode({"from":gUid,"send_to":this.widget.friend.id,"msg":str}));
          //messageList.add({"text": str, "identity": flag.hashCode});

          setState(() {
            sendChatMessage(str);
            col.jumpTo(col.position.maxScrollExtent);
            //col.jumpTo(col.position.maxScrollExtent);
          });
        },
        style: TextStyle(
          fontSize: 20.0,
          color: Color.fromRGBO(85, 85, 85, 1),
        ),
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.fromLTRB(15, 10, 0, 0),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: null,
            focusColor: Colors.transparent,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(20.0),
            )),
      ),
    );
  }

  Widget writeList(item,index) {

      if (item.fromUid != test1) {

        return
          Column(
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                    height: 50,
                    child:
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                  SizedBox(
                    width: 5,
                  ),
                    //右侧是本人，左侧是聊天对象
                      CircleAvatar(
                        //radius: 25.0,
                        backgroundImage: item.fromnameHead != null
                            ? NetworkImage(
                            API.URL_OSS_UPLOAD_IMAGE + '${item.fromnameHead}')
                            : AssetImage('assets/images/nohead.jpg'),
                        backgroundColor: Colors.white,
                        child: GestureDetector(
                          //onTap: _onClick,//写入方法名称就可以了，但是是无参的
                          onTap: () {

                          },
                          //child: Text("dianji"),
                        ),
                      ),
                  SizedBox(
                    width: 5,
                  ),
                  Container(
                      padding: EdgeInsets.fromLTRB(gHpao,gVpao,gHpao,gVpao),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(topRight: Radius.circular(5),bottomRight: Radius.circular(5),bottomLeft: Radius.circular(5)),
                          color: gColor.lightGray,
                          // image:
                          // DecorationImage(
                          //     image: ExactAssetImage("images/left_pao.jpg"),
                          //     fit: BoxFit.fill
                          //     )
                         ),
                      child: Container(
                          child: GestureDetector(
                              onTap: () {
                                //print("--------------");
                              },
                              child: Text(
                                item.message,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                          )
                      )),
                  Expanded(
                    child: SizedBox(),
                  ),

                ]),
              ),
              Container(
                //color: Colors.blue,
                //width: 100.0,
                //height: 50.0,
                child: Align(
                  alignment: Alignment.center,
                  widthFactor: 2.0,
                  heightFactor: 2.0,
                  child: Text(item.createTime,
                      style: TextStyle(fontSize: 12, color: Colors.black26)),
                ),
              ),
    ],
    );
      } else {

        return
          Column(
            //crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                  Container(
                    height: 50,
                    child:
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                  Expanded(
                    child: SizedBox(),
                  ),
                  Container(
                      padding: EdgeInsets.fromLTRB(gHpao,gVpao,gHpao,gVpao),
                      decoration: BoxDecoration(
                          border: Border(right: BorderSide.none),
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(5),bottomRight: Radius.circular(5),bottomLeft: Radius.circular(5)),
                          color: Colors.blueAccent[100],
                           //image: DecorationImage(
                           //    image: ExactAssetImage("assets/images/right_pao.png"),
                            //   fit: BoxFit.fill)
                              ),
                      child: Container(
                          child: WPopupMenu(

                            alignment: Alignment.center,

                            onValueChanged: (int value) {
                              if(value==0){
                                delChatMessage(item.chatId,index);
                              }
                            print("---------------$value");
                            },
                            pressType: PressType.longPress,
                            actions: actions,
                            child: Text(
                              item.message,
                              textAlign: TextAlign.start,
                              style: TextStyle(color: Colors.white,fontSize: 16),
                            ),
                          ),

                          /*
                          child: Text(
                            item.message,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          */

                      )),
                  SizedBox(
                    width: 5,
                  ),
                    CircleAvatar(
                      //radius: 25.0,
                      backgroundImage: item.fromnameHead != null
                          ? NetworkImage(
                          API.URL_OSS_UPLOAD_IMAGE + '${item.fromnameHead}')
                          : AssetImage('assets/images/nohead.jpg'),
                      backgroundColor: Colors.white,
                      child: GestureDetector(
                        //onTap: _onClick,//写入方法名称就可以了，但是是无参的
                        onTap: () {

                        },
                        //child: Text("dianji"),
                      ),
                    ),
                  SizedBox(
                    width: 5,
                  )
                ])),
                Container(
                  //color: Colors.blue,
                  //width: 100.0,
                  //height: 50.0,
                  child: Align(
                    alignment: Alignment.center,
                    widthFactor: 2.0,
                    heightFactor: 2.0,
                    child: Text(item.createTime,
                        style: TextStyle(fontSize: 12, color: Colors.black26)),
                  ),
                ),
            ],
          );



      }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                backgroundImage: widget.friend.tonameHead != null
                    ? NetworkImage(
                    API.URL_OSS_UPLOAD_IMAGE + '${widget.friend.tonameHead}')
                    : AssetImage('assets/images/nohead.jpg'),

                child: GestureDetector(
                  //onTap: _onClick,//写入方法名称就可以了，但是是无参的
                  onTap: () {

                  },
                  //child: Text("dianji"),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: ScreenUtil().setWidth(15)),
                child: Text(widget.friend.toname != null
                    ? '${widget.friend.toname}'
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
        body: Column(
      children: <Widget>[
        //Screen.topSafeWidget(color: Colors.white),

        Container(
          height: gChatUnderlineHeight,
          color: gChatUnderlineColor,
        ),
        SizedBox(height: 3,),
        Expanded(
          child: Container(
            color: Colors.white,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                //background
                 //Image.asset(
                 //  "assets/images/bk.jpg",
                //   fit: BoxFit.cover,
                // ),


                NotificationListener(

                  //下拉条
                  child: RefreshIndicator(
                    displacement: 1.0,
                    child: ListView.builder(
                      /*
                      BouncingScrollPhysics ：允许滚动超出边界，但之后内容会反弹回来。
                      ClampingScrollPhysics ： 防止滚动超出边界，夹住 。
                      AlwaysScrollableScrollPhysics ：始终响应用户的滚动。
                      NeverScrollableScrollPhysics ：不响应用户的滚动。
                       */
                        physics: AlwaysScrollableScrollPhysics(),
                        key: _refreshIndicatorKey,
                        controller:col,
                        itemCount: messageList.length,
                        itemBuilder: (BuildContext context, int index) {
                          //print(index);
                          return writeList(messageList[index],index);
                        }),
                    onRefresh: () {

                      return getChatMessage();

                    },
                  ),
                  onNotification: (notification) {
                    if (notification is ScrollUpdateNotification &&
                        notification.depth == 0) {
                      if (notification.metrics.pixels ==
                          notification.metrics.minScrollExtent) {
                        print('滑动到了最顶部');
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


                )








              ],
            ),
          ),
        ),
        Container(
          color: Color.fromRGBO(240, 240, 240, 1),
          height: 54,
          child: Row(
            children: <Widget>[
              SizedBox(width: 8),
              Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2.5)),
                  child: Icon(
                    Icons.keyboard_voice,
                    // color: Color.fromRGBO(127, 132, 135, 1),
                    color: Colors.grey[900],
                    size: 25,
                  )),
              SizedBox(width: 8),
              Expanded(
                child: buildTextField(),
              ),
              SizedBox(width: 5),
              Icon(
                Icons.mood,
                color: Colors.grey[900],
                // color: Color.fromRGBO(127, 132, 135, 1),
                size: 35,
              ),
              SizedBox(width: 5),
              Icon(
                Icons.control_point,
                color: Colors.grey[900],
                // color: Color.fromRGBO(127, 132, 135, 1),
                size: 35,
              ),
              SizedBox(width: 5)
            ],
          ),
        ),
      ],
    ));
  }


}
