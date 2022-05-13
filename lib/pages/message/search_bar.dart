import 'package:commuitynapp/global/global.dart';
import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  final TextEditingController controller = TextEditingController();
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  bool bFocus = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Row(children: [
          SizedBox(
            width: hPadding,
          ),
          Expanded(
              child: TextField(
            onTap: () {
              setState(() {
                bFocus = true;
              });
            },
            onEditingComplete: () {
              setState(() {
                bFocus = false;
              });
            },
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                fillColor: gColor.lightGray,
                filled: true,
                border: OutlineInputBorder(
                    gapPadding: 0,
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none)),
          )
          ),
          SizedBox(
            width: hPadding,
          )
        ]),
        Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Offstage(
              offstage: bFocus,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.search,
                      color: Colors.grey,
                    ),
                    Text(
                      "搜索",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ]),
            )),
      ],
    );
  }
}
