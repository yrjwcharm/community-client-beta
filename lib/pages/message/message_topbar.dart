import 'package:commuitynapp/global/global.dart';
import 'package:commuitynapp/pages/message/search_bar.dart';

import 'package:flutter/material.dart';

class MessageTopBar extends StatefulWidget {
  @override
  _MessageTopBarState createState() => _MessageTopBarState();
}

class _MessageTopBarState extends State<MessageTopBar> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [

      //SizedBox(height: 10,),
      SearchBar(),
      //SizedBox(height: 10,)
    ]);
  }
}
