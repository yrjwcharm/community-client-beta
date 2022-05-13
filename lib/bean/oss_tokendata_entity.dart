class OssTokenDataEntity {

  String accessKeyId;
  String accessKeySecret;
  String securityToken;
  Credentials credentials;
  OssTokenDataEntity.fromMap(Map<String, dynamic> map){
    accessKeyId = map['accessKeyId'];
    accessKeySecret = map['accessKeySecret'];
    securityToken = map['securityToken'];

    var tmp = map['credentials'];
    if(tmp == null){
      credentials = null;
    }else{
      credentials = Credentials(tmp['securityToken'], tmp['accessKeySecret'], tmp['accessKeyId'], tmp['expiration']);
    }

  }


}
class Credentials {
  var securityToken;
  var accessKeySecret;
  var accessKeyId;
  var expiration;
  Credentials(this.securityToken, this.accessKeySecret, this.accessKeyId,this.expiration);
}