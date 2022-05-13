import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
//import 'package:commuitynapp/widgets/image/cached_network_image.dart';
//import 'package:connectivity/connectivity.dart';

typedef BoolCallback = void Function(bool markAdded);

//test http://img1.doubanio.com/view/photo/s_ratio_poster/public/p457760035.webp
///点击图片变成订阅状态的缓存图片控件
class SubjectDynamicImageWidget extends StatefulWidget {
  final imgNetUrl;
  final BoolCallback markAdd;
  var height;
  final width;
  ///360 x 513

  SubjectDynamicImageWidget(this.imgNetUrl,
      {Key key, this.markAdd, this.width = 150.0})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    height = this.width / 150.0 * 210.0;
    return _SubjectDynamicImageWidget(imgNetUrl, markAdd, width, height);
  }
}

class _SubjectDynamicImageWidget extends State<SubjectDynamicImageWidget> {
  var markAdded = false;
  String imgLocalPath, imgNetUrl;
  final BoolCallback markAdd;

  var loadImg;
  var imgWH = 28.0;
  var height;
  var width;

  _SubjectDynamicImageWidget(this.imgNetUrl, this.markAdd, this.width, this.height);

  @override
  void initState() {
    super.initState();

    var defaultImg = Image.asset('assets/images/ic_default_img_subject_movie.9.png');

    loadImg = ClipRRect(
      child: CachedNetworkImage(
        imageUrl: imgNetUrl,
        width: width,
        height: height,
        fit: BoxFit.fill,
        placeholder: (BuildContext context, String url){
          return defaultImg;
        },
        //fadeInDuration: const Duration(milliseconds: 80),
        //fadeOutDuration: const Duration(milliseconds: 80),
      ),
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        loadImg,
      ],
    );
  }

}
