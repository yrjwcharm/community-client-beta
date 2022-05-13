
import 'package:commuitynapp/constant/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// 首页轮播组件编写
class SwiperDiy extends StatelessWidget {
  final List swiperDataList;

  SwiperDiy({Key key, this.swiperDataList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1300,
      height: 200,
      margin: const EdgeInsets.only(bottom: 10.0),
      //padding: const EdgeInsets.only(
      //    left: Constant.MARGIN_LEFT,
      //    right: Constant.MARGIN_RIGHT,
      //    top: Constant.MARGIN_RIGHT,
      //    bottom: 10.0),
      child: Swiper(
        scrollDirection: Axis.horizontal,
        // 横向
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
              onTap: () {
                //轮播图点击跳转详情页
                //Toast.show('您点击了${swiperDataList[index]}');
              },
              child: Container(
                decoration: BoxDecoration(
                  //color: Colors.blue,
                    //borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage("${swiperDataList[index]}"),
                      fit: BoxFit.fill,
                    )),
              ));
        },
        itemCount: swiperDataList.length,
        //pagination: new SwiperPagination(),
        autoplay: false,

        viewportFraction: 0.8,
        // 当前视窗展示比例 小于1可见上一个和下一个视窗
        //scale: 0.8, // 两张图片之间的间隔
      ),
    );
  }
}