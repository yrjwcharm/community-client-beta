
import 'package:commuitynapp/http/API.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:commuitynapp/network/OssUtil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'NetUtils.dart';
import 'OssUtil.dart';

/*
 * 接口请求方法
 * 封装了传参方式及参数
 */
class ApiService {
  /*
  * 获取OSS Token
  */
  static Future<dynamic> getOssToken(BuildContext context,
      {cancelToken}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var accessToken=  prefs.getString('X-Access-Token');
    BaseOptions _options = new BaseOptions(
      baseUrl: API.BASE_URL,
      connectTimeout: 15000,
      receiveTimeout: 15000,
      contentType: "application/x-www-form-urlencoded",
    );
    _options.headers["X-Access-Token"]=accessToken;
    return NetUtils.instance
        .post(context, API.COMMUNITY_BASE_URL+API.URL_OSS_TOKEN, data: null,options:_options,cancelToken: cancelToken);
  }
//上传图片
  static Future<dynamic> uploadImage(
      BuildContext context, String uploadName, String filePath,
      {cancelToken}) async {
    BaseOptions options = new BaseOptions();
    options.responseType = ResponseType.plain; //必须,否则上传失败后aliyun返回的提示信息(非JSON格式)看不到
    options.contentType = "multipart/form-data";
    //创建一个formdata，作为dio的参数
    File file = new File(filePath);

    String path = file.path;
    String chuo = DateTime.now().millisecondsSinceEpoch.toString() + path.substring(path.lastIndexOf('.'));
    String fileName = path.lastIndexOf('/') > -1 ? path.substring(path.lastIndexOf('/') + 1) : path;

    FormData data = new FormData.fromMap({
      'Filename': uploadName,//文件名，随意
      'key': uploadName, //"可以填写文件夹名（对应于oss服务中的文件夹）/" + fileName
      'policy': OssUtil.policy,
      'OSSAccessKeyId':OssUtil.accesskeyId,//Bucket 拥有者的AccessKeyId。
      'success_action_status': '200',//让服务端返回200，不然，默认会返回204
      'Access-Control-Allow-Origin': '*',
      'signature': OssUtil.instance.getSignature(OssUtil.accessKeySecret),
      'x-oss-security-token':OssUtil.stsToken,//临时用户授权时必须，需要携带后台返回的security-token
      'file':File(OssUtil.instance.getImageNameByPath(filePath)) //必须放在参数最后
    });
    return NetUtils.instance
        .post(context, API.URL_OSS_UPLOAD_IMAGE, data: data, options: options);
  }
}

