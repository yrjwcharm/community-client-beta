import 'dart:convert' show json;
class DynamicsEntity {

	String did;
	String uid;
	String dMessage;
	String dPosttime;
	String dTitle;
	String dType;
	String dIsdel;
	String dHotscore;
	String dZancount;
	String location;


	DynamicsEntity.fromParams({this.did, this.uid, this.dMessage, this.dPosttime, this.dTitle, this.dType,this.dIsdel,this.dHotscore,this.dZancount,
	this.location});

	DynamicsEntity.fromJson(jsonRes) {
		did = jsonRes['did'];
		uid = jsonRes['uid'];
		dMessage = jsonRes['dMessage'];
		dPosttime = jsonRes['dPosttime'];
		dTitle = jsonRes['dTitle'];
		dType = jsonRes['dType'];
		dIsdel = jsonRes['dIsdel'];
		dHotscore = jsonRes['dHotscore'];
		dZancount = jsonRes['dZancount'];
		location = jsonRes['location'];
	}

	@override
	String toString() {
		return '{"did": ${did != null?'${json.encode(did)}':'null'},"uid": ${uid != null?'${json.encode(uid)}':'null'},"dMessage": ${dMessage != null?'${json.encode(dMessage)}':'null'},"dPosttime": ${dPosttime != null?'${json.encode(dPosttime)}':'null'},"dTitle": ${dTitle != null?'${json.encode(dTitle)}':'null'},"dType": ${dType != null?'${json.encode(dType)}':'null'},"dIsdel": ${dIsdel != null?'${json.encode(dIsdel)}':'null'},"dHotscore": ${dHotscore != null?'${json.encode(dHotscore)}':'null'},"dZancount": ${dZancount != null?'${json.encode(dZancount)}':'null'},"location": ${location != null?'${json.encode(location)}':'null'}}';
	}
}

