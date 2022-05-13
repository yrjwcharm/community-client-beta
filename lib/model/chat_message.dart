import 'package:commuitynapp/bean/chat_entity.dart';
import 'package:commuitynapp/global/global.dart';
import 'package:commuitynapp/http/API.dart';
import 'package:commuitynapp/model/contact_people.dart';
//import 'package:commuitynapp/model/contact_people.dart';
import 'package:commuitynapp/model/message.dart';
import 'package:commuitynapp/pages/message/message_chat.dart';
//import 'package:abc/ui/item/count_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../router.dart';


class ChatMessageWidget extends StatefulWidget {
  // final ChatMessage msgs;
  // ChatMessageWidget(this.msgs);
  final ChatEntity data;

  const ChatMessageWidget(this.data);

  @override
  _ChatMessageWidgetState createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>MessageChat(
          friend: widget.data,
        )));
      },
      child: Column(
        children: [
          Container(
              margin: const EdgeInsets.symmetric(vertical: gChatMargin),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    child: CircleAvatar(
                      radius: 25.0,
                      backgroundImage: widget.data.tonameHead != null
                          ? NetworkImage(
                          API.URL_OSS_UPLOAD_IMAGE + '${widget.data.tonameHead}')
                          : AssetImage('assets/images/nohead.jpg'),
                      backgroundColor: Colors.white,
                      child: GestureDetector(
                        //onTap: _onClick,//写入方法名称就可以了，但是是无参的
                        onTap: () {
                          //AppRouter.Router.push(context, Router.personDetailPage, item);
                        },
                        //child: Text("dianji"),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 1,
                      ),
                      Text(
                        widget.data.toname!=null?widget.data.toname:"",
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(widget.data.message!=null?widget.data.message:"",
                          style: TextStyle(color: Colors.grey, fontSize: 15)),
                      SizedBox(
                        height: 1,
                      ),
                    ],
                  )),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      SizedBox(
                        height: 1,
                      ),
                      Text(
                          widget.data.createTime!=null?widget.data.createTime:"",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      //CountAdapter(1),
                      SizedBox(
                        height: 1,
                      )
                    ],
                  ),
                  SizedBox(
                    width: 10,
                  )
                ],
              )),
          Container(
            height: gChatUnderlineHeight,
            color: gChatUnderlineColor,
            margin: const EdgeInsets.only(left: 60),
          )
        ],
      ),
    );
  }
}
