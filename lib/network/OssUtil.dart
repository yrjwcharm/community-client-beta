import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:math';

/*
* Oss工具类
* PostObject方式上传图片官方文档：https://help.aliyun.com/document_detail/31988.html
*/
class OssUtil {

//  static String accesskeyId = '******';//Bucket 拥有者的accesskeyId 。
//  static String accessKeySecret = '******';//Bucket 拥有者的accessKeySecret。
  static String accesskeyId = '';//临时用户的AccessKeyId，通过后台接口动态获取
  static String accessKeySecret = '';//临时用户的accessKeySecret，通过后台接口动态获取
  static String stsToken='';//临时用户鉴权Token,临时用户认证时必传，通过后台接口动态获取
  //验证文本域
  static String _policyText =
      '{"expiration": "2069-05-22T03:15:00.000Z","conditions": [["content-length-range", 0, 1048576000]]}';//UTC时间+8=北京时间

  //进行utf8编码
  static List<int> _policyText_utf8 = utf8.encode(_policyText);
  //进行base64编码
  static String policy= base64.encode(_policyText_utf8);

  //再次进行utf8编码
  static List<int> _policy_utf8 = utf8.encode(policy);

  // 工厂模式
  factory OssUtil() => _getInstance();

  static OssUtil get instance => _getInstance();
  static OssUtil _instance;

  OssUtil._internal() {

  }

  static OssUtil _getInstance() {
    if (_instance == null) {
      _instance = new OssUtil._internal();
    }
    return _instance;
  }

  /*
  *获取signature签名参数
  */
  String getSignature(String _accessKeySecret){
    //进行utf8 编码
    List<int> _accessKeySecret_utf8 = utf8.encode(_accessKeySecret);

    //通过hmac,使用sha1进行加密
    List<int> signature_pre = new Hmac(sha1, _accessKeySecret_utf8).convert(_policy_utf8).bytes;

    //最后一步，将上述所得进行base64 编码
    String signature = base64.encode(signature_pre);
    return signature;
  }

  /**
   * 生成上传上传图片的名称 ,获得的格式:photo/20171027175940_oCiobK
   * 可以定义上传的路径uploadPath(Oss中保存文件夹的名称)
   * @param uploadPath 上传的路径 如：/photo
   * @return photo/20171027175940_oCiobK
   */
  String getImageUploadName(String uploadPath,String filePath) {
    String imageMame = "";
    var timestamp = new DateTime.now().millisecondsSinceEpoch;
    imageMame =timestamp.toString()+"_"+getRandom(6);
    if(uploadPath!=null&&uploadPath.isNotEmpty){
      imageMame=uploadPath+"/"+imageMame;
    }
    String imageType=filePath?.substring(filePath?.lastIndexOf("."),filePath?.length);
    return imageMame+imageType;
  }

  /*
  * 生成固定长度的随机字符串
  * */
  String getRandom(int num) {
    String alphabet = 'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM';
    String left = '';
    for (var i = 0; i < num; i++) {
//    right = right + (min + (Random().nextInt(max - min))).toString();
      left = left + alphabet[Random().nextInt(alphabet.length)];
    }
    return left;
  }

  /*
  * 根据图片本地路径获取图片名称
  * */
  String getImageNameByPath(String filePath) {
    return filePath?.substring(filePath?.lastIndexOf("/")+1,filePath?.length);
  }
}


