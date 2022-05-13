import 'dart:io';
//import 'package:commuitynapp/model/contact_people.dart';
import 'package:commuitynapp/model/observer.dart';
//import 'package:commuitynapp/utility/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
//import 'package:web_socket_channel/io.dart';

bool glogin = false;

class gColor {
  static const Color gray = Color(0xFF888888);
  static const Color write = Color(0xFFFFFFFF);
  static const Color black = Color(0x00000000);
  static const Color lightGray = Color(0xFFEEEEEE);
  static const Color golden = Color(0xff8B7961);
  static const Color lightBack = Color(0xFFF9FAFC);
  static const Color themeBlue = Color(0xFF007BFF);
  static const Color topTextColor = Color(0xFFFFFFFF);
  static const Color forwardColor = Color(0xcccccccc);
}

class KeyValue<K, V> {
  K key;
  V value;
  KeyValue(this.key,this.value);
}

const int server_start = 1;
const double hPadding = 20;

const double gChatMargin = 10;
const double gChatUnderlineHeight = 1;
const Color  gChatUnderlineColor = gColor.lightGray;

String gAddress = "";
String gAccount = "";
String gPassword = "";
String gSid = "";
int gUid = 0;
int gPort = 0;

//List<ContractPeople> gFriendList =List<ContractPeople>();

// XStack gPageStack = new XStack<FilePage>();

enum gCopyKind { TYPE_NONE, TYPE_COPY, TYPE_CUT }
enum gTaskKind { TASK_UPLOAD, TASK_DOWNLOAD, TASK_BAK }

bool gBSelectState = false;
bool gBTranslateSelectState = false;
bool gWifiTranslateOnly = false;

gCopyKind gCopyState = gCopyKind.TYPE_NONE;
gTaskKind gCurrentTaskKind = gTaskKind.TASK_UPLOAD;
// SharedPreferences gPreferences;
Directory gDir;
String gDownloadPath = "";

//global 
//IOWebSocketChannel gChannel = IOWebSocketChannel.connect("ws://szp123.asuscomm.com:8081");
MyObserver gMyObserver = new MyObserver();

//Setting Item Mehon
// const defalutMethon = SettingInfoItemBuildMethonDefalut();
// const tightMethon = SettingInfoItemBuildMethonTight();
// const defalutDecroate = SettingInfoItemDecroate();

//Setting Menu Decroate
// const menuDefalutDecroate = SettingInfoMenuMenuDecroate();
//const topbarDefalutDecroate = TopbarDecroate();

closedialog(context) {
  Navigator.of(context, rootNavigator: true).pop();
}

gRefreshState(State st) {
  gBSelectState = false;
  // gPageStack.peek().clearSelects();
  st.setState(() {});
}

KeyValue<String, String> gCut(String str, String pattern, int pos) {
  bool reserve = pos < 0;
  if (reserve) pos *= -1;
  if (pos == 0) return KeyValue(str, str);
  int rpos = reserve ? str.length - 1 : 0;
  for (int index = 0; index < pos; index++) {
    var tpos =
        reserve ? str.lastIndexOf(pattern, rpos) : str.indexOf(pattern, rpos);
    // rpos = reserve ? tpos : tpos + 1;
    rpos = tpos+1;
    if (rpos == -1) break;
  }
  if (rpos == -1) return KeyValue(str, str);
  return KeyValue(str.substring(0, rpos), str.substring(rpos));
}

String gResolveName(String name) {
  String imageAddr;
  if (name == "@recycle") {
    imageAddr = "images/recycle.png";
    return imageAddr;
  }
  if (!name.contains(name)) {
    imageAddr = "images/other.png";
  }
  String sa = gCut(name, ".", -1).value.toUpperCase();
  if (sa == "MP4") {
    imageAddr = "images/video.png";
  } else if (sa == "MP3") {
    imageAddr = "images/music.png";
  } else if (sa.contains("HTM")) {
    imageAddr = "images/html.png";
  } else if (sa.contains("RAR") || sa.contains("7Z") || sa.contains("ZIP")) {
    imageAddr = "images/rar.png";
  } else if (sa.contains("JPEG") || sa.contains("JPG") || sa.contains("PNG")) {
    imageAddr = "images/image.png";
  } else if (sa.contains("PDF")) {
    imageAddr = "images/pdf.png";
  } else if (sa.contains("PPT")) {
    imageAddr = "images/ppt.png";
  } else if (sa.contains("DOC")) {
    imageAddr = "images/word.png";
  } else if (sa.contains("XLS")) {
    imageAddr = "images/excel.png";
  } else if (sa.contains("PPT")) {
    imageAddr = "images/ppt.png";
  } else {
    imageAddr = "images/other.png";
  }
  return imageAddr;
}
