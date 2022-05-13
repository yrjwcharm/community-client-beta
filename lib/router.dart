import 'package:commuitynapp/pages/home/dong_tai_page_detail.dart';
//import 'package:commuitynapp/pages/publish/RecorderPage.dart';
import 'package:commuitynapp/pages/publish/SendDynamicPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:commuitynapp/pages/detail/detail_page.dart';
import 'package:commuitynapp/pages/container_page.dart';
import 'package:commuitynapp/pages/videos_play_page.dart';
import 'package:commuitynapp/pages/search/search_page.dart';
import 'package:commuitynapp/pages/photo_hero_page.dart';
import 'package:commuitynapp/pages/person/person_detail_page.dart';
import 'package:commuitynapp/pages/web_view_page.dart';
import 'package:commuitynapp/pages/person/login_page.dart';
import 'package:commuitynapp/pages/publish/MyPhotoPage.dart';
///https://www.jianshu.com/p/b9d6ec92926f

class Router {
  static const homePage = 'app://';
  static const detailPage = 'app://DetailPage';
  static const playListPage = 'app://VideosPlayPage';
  static const searchPage = 'app://SearchPage';
  static const photoHero = 'app://PhotoHero';
  static const personDetailPage = 'app://PersonDetailPage';
  static const loginPage = 'app://LoginPage';
  static const myPhotoPage = 'app://MyPhotoPage';
  static const dongTaiDetailPage = 'app://DongTaiDetailPage';
  static const sendDynamicPage = 'app://SendDynamicPage';//发布动态页
  //static const recorderPage ='app://RecorderPage'; //发布音频

//  Widget _router(String url, dynamic params) {
//    String pageId = _pageIdMap[url];
//    return _getPage(pageId, params);
//  }
//
//  Map<String, dynamic> _pageIdMap = <String, dynamic>{
//    'app/': 'ContainerPageWidget',
//    detailPage: 'DetailPage',
//  };

  Widget _getPage(String url, dynamic params) {
    if (url.startsWith('https://') || url.startsWith('http://')) {
      return WebViewPage(url, params: params);
    } else {
      switch (url) {
        case myPhotoPage:
          return MyPhotoPage();
        //case recorderPage:
        //  return RecorderPage();
        case sendDynamicPage:
          return SendDynamicPage();
        case loginPage:
          return LoginPage();
        case detailPage:
          return DetailPage(params);
        case homePage:
          return ContainerPage();
        case playListPage:
          return VideoPlayPage(params);
        case searchPage:
          return SearchPage(searchHintContent: params);
        case photoHero:
          return PhotoHeroPage(
              photoUrl: params['photoUrl'], width: params['width']);
        case personDetailPage:
          return PersonDetailPage(data:params);
        case dongTaiDetailPage:
          return DongTaiDetailPage(data: params,);
      }
    }
    return null;
  }

//
//  void push(BuildContext context, String url, dynamic params) {
//    Navigator.push(context, MaterialPageRoute(builder: (context) {
//      return _getPage(url, params);
//    }));
//  }

  Router.pushNoParams(BuildContext context, String url) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return _getPage(url, null);
    }));
  }

  Router.push(BuildContext context, String url, dynamic params) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return _getPage(url, params);
    }));
  }
}
