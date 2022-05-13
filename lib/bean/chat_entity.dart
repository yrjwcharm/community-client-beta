import 'package:commuitynapp/util/date_format.dart';

class ChatEntity{
  String fromname;
  String toname;
  String fromnameHead;
  String tonameHead;
  String fromUid;
  String toUid;
  String message;
  String createTime;
  int type;
  String online;
  String chatId;

  ChatEntity.fromMap(Map<String, dynamic> json) {
    chatId=json['chatId'];
    fromname = json['fromname'];
    toname = json['toname'];
    fromnameHead = json['fromnameHead'];
    tonameHead = json['tonameHead'];
    fromUid = json['fromUid'];
    toUid = json['toUid'];
    message = json['message'];
    createTime = formatDate(DateTime.parse(json['createTime']) ,[yyyy,'-',mm,'-',dd]) ;
    type = json['type'];
    online = json['online'];

  }

  ChatEntity.fromMap2(Map<String, dynamic> json) {
    chatId=json['chatId'];
    fromname = json['fromname'];
    toname = json['toname'];
    fromnameHead = json['fromnameHead'];
    tonameHead = json['tonameHead'];
    fromUid = json['fromUid'];
    toUid = json['toUid'];
    message = json['message'];
    createTime = formatDate(DateTime.fromMillisecondsSinceEpoch(json['createTime']) ,[yyyy,'-',mm,'-',dd, " ", DD, " ", HH, ":", nn, ":", ss]).toString() ;
    type = json['type'];
    online = json['online'];

  }

  ChatEntity.fromMap3(Map<String, dynamic> json) {
    chatId=json['chatId'];
    fromname = json['fromname'];
    toname = json['toname'];
    fromnameHead = json['fromnameHead'];
    tonameHead = json['tonameHead'];
    fromUid = json['fromUid'];
    toUid = json['toUid'];
    message = json['message'];
    createTime = formatDate(DateTime.parse(json['createTime']) ,[yyyy,'-',mm,'-',dd, " ", DD, " ", HH, ":", nn, ":", ss]) ;
    type = json['type'];
    online = json['online'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fromname'] = this.fromname;
    data['toname'] = this.toname;
    data['fromnameHead'] = this.fromnameHead;
    data['tonameHead'] = this.tonameHead;
    data['fromUid'] = this.fromUid;
    data['toUid'] = this.toUid;
    data['message'] = this.message;
    data['createTime'] = this.createTime;
    data['type'] = this.type;
    data['online'] = this.online;

    return data;
  }
}
