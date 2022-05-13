
import 'package:commuitynapp/model/common_item.dart';
import 'package:commuitynapp/model/task.dart';
import 'package:flutter/material.dart';

class ContractPeople extends StatefulWidget {
  // final bool bGroup ;
  // final int  chatid;
  final String name;
  final int id;
  final Widget right;
  final OnDoCallback<_ContractPeopleState> onpress;
  ContractPeople({this.name, this.id, this.onpress,this.right});
  @override
  _ContractPeopleState createState() => _ContractPeopleState();
}

class _ContractPeopleState extends State<ContractPeople> {
  @override
  Widget build(BuildContext context) {
    // Color color = Color.fromARGB(a, r, g, b);
    return CommonItem(
      onPress: () {
        if (this.widget.onpress != null) this.widget.onpress(this);
      },
      decroate: CommonItemDecroate(
          right: this.widget.right??Container(),
          left: CircleAvatar(
            backgroundColor: Colors.green,
          ),
          center: Text(widget.name)),
    );
  }
}
