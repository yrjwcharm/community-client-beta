import 'package:commuitynapp/http/API.dart';
import 'package:commuitynapp/util/LogUtil.dart';
import 'package:dio/adapter.dart';

import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
* Http请求配置工具类
*/
class NetUtils {
  static BuildContext context = null;

  BaseOptions _options;
  Dio dio;

  // 工厂模式
  factory NetUtils() => _getInstance();

  static NetUtils get instance => _getInstance();
  static NetUtils _instance;

  NetUtils._internal() {

    //初始化
    dio = getDio();
  }

  static NetUtils _getInstance() {
    //LogUtil.init(isDebug: false,tag: "****NetUtils****");
    if (_instance == null) {
      _instance = new NetUtils._internal();
    }
    return _instance;
  }

  /**
   * 获取dio实例,不配置根url，完全使用传入的绝对路径url
   */
  Dio getDio({String url, BaseOptions options}) {

    if (options == null) {

    } else {
      _options = options;
    }
    Dio _dio = new Dio(_options);
//    _dio.interceptors.add(new TokenInterceptor());//待完善
//    _dio.interceptors.add(new ErrorInterceptor(_dio));//待优化
    //_dio.interceptors.add(new HeaderInterceptor());
//    _dio.interceptors.add(new LogInterceptor());
    setProxy(_dio);
    return _dio;
  }

  /**
   * 设置代理
   * */
  void setProxy(Dio dio) {
    //debug模式且为wifi网络时设置代理
    if (API.debug) {
      //debug模式下设置代理
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        //设置代理
        client.findProxy = (uri) {
          return "PROXY " + API.PROXY_URI;
        };
      };
    }
  }

  post(BuildContext context, url, {data, BaseOptions options,cancelToken}) async {
    LogUtil.v('启动post请求 url：$url ,body: $data');

    Response response;
    try {
      if (url != null &&
          (url.startsWith("http://") || url.startsWith("https://"))) {
        dio = getDio(url: url,options: options);
      }
      response = await dio.post(url, data: data, cancelToken: cancelToken);

      LogUtil.v('post请求成功 response.data：${response.toString()}');
    } on DioError catch (e) {
      if (CancelToken.isCancel(e)) {

        LogUtil.v('post请求取消:' + e.message);
      }

      LogUtil.v('post请求发生错误：$e');
    }
    return response; //response.data.toString()这种方式不是标准json,不能使用
  }

  get(BuildContext context, url, {data,BaseOptions options,cancelToken}) async {
    //LogUtil.v('启动get请求 url：$url ,body: $data');
    Response response;
    try {
      if (url != null &&
          (url.startsWith("http://") || url.startsWith("https://"))) {
        dio = getDio(url: url,options: options);
      }
      response =
      await dio.get(url, queryParameters: data, cancelToken: cancelToken);
      //LogUtil.v('get请求成功 response.data：${response.toString()}');
    } on DioError catch (e) {
      if (CancelToken.isCancel(e)) {
        //LogUtil.v('get请求取消:' + e.message);
      }
      //LogUtil.v('get请求发生错误：$e');
    }
    return response;
  }
}

