import 'dart:io';

import 'package:commuitynapp/routers/pop_router.dart';
import 'package:flutter/material.dart';

///点击图片放大显示
class AnimalPhoto {
  AnimalPhoto.show(BuildContext context,int type, String url, {double width}) {
    if (width == null) {
      width = MediaQuery.of(context).size.width;
    }
    Navigator.of(context).push(PopRoute(
        child: Container(
      // The blue background emphasizes that it's a new route.
      color: Colors.black54,
      padding: const EdgeInsets.all(10.0),
      alignment: Alignment.center,
      child: _PhotoHero(
        type:type,
        photo: url,
        width: width,
        onTap: () {
          Navigator.of(context).pop();
        },
      ),
    )));
  }
}

class _PhotoHero extends StatelessWidget {
  const _PhotoHero({Key key, this.photo, this.type,this.onTap, this.width})
      : super(key: key);

  final String photo;
  final int type;

  final VoidCallback onTap;
  final double width;

  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Hero(
        tag: photo,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: type==0?Image.network(
              photo,
              fit: BoxFit.contain,
            ):Image.file(new File(photo)),
          ),
        ),
      ),
    );
  }
}
