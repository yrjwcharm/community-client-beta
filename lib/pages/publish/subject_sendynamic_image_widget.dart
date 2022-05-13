import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
//import 'package:commuitynapp/widgets/image/cached_network_image.dart';
//import 'package:connectivity/connectivity.dart';

typedef BoolCallback = void Function(bool markAdded);

///点击图片变成订阅状态的缓存图片控件
class SubjectSendynamicImageWidget extends StatefulWidget {
  final imgNetUrl;
  final BoolCallback markAdd;
  var height;
  final width;
  ///360 x 513

  SubjectSendynamicImageWidget(this.imgNetUrl,
      {Key key, this.markAdd, this.width = 150.0})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    height = this.width / 150.0 * 210.0;
    return _SubjectSendynamicImageWidget(imgNetUrl, markAdd, width, height);
  }
}

class _SubjectSendynamicImageWidget extends State<SubjectSendynamicImageWidget> {
  var markAdded = false;
  String imgLocalPath, imgNetUrl;
  final BoolCallback markAdd;
  var markAddedIcon, defaultMarkIcon;
  var loadImg;
  var imgWH = 28.0;
  var height;
  var width;

  _SubjectSendynamicImageWidget(this.imgNetUrl, this.markAdd, this.width, this.height);

  @override
  void initState() {
    super.initState();
    markAddedIcon = Image(
      image: AssetImage('assets/images/ic_subject_mark_added.png'),
      width: imgWH,
      height: imgWH,
    );
    defaultMarkIcon = ClipRRect(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(5.0), bottomRight: Radius.circular(5.0)),
      child:Icon(Icons.close,color: Colors.red),
    );
    //var defaultImg = Image.asset('assets/images/ic_default_img_subject_movie.9.png');

    loadImg = ClipRRect(
      child: CachedNetworkImage(
        imageUrl: imgNetUrl,
        width: width,
        height: height,
        fit: BoxFit.fill,
        placeholder: (BuildContext context, String url){
          return Image.asset(imgNetUrl);
        },
        fadeInDuration: const Duration(milliseconds: 80),
        fadeOutDuration: const Duration(milliseconds: 80),
      ),
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        loadImg,
        GestureDetector(
          child: markAdded ? markAddedIcon : defaultMarkIcon,
          onTap: () {
            if (markAdd != null) {
              markAdd(markAdded);
            }
            setState(() {
              markAdded = !markAdded;
            });
          },
        ),
      ],
    );
  }

}
