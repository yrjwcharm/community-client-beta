class SubjectEntity {

//  "subject":Object{...},
//  "rank":1,
//  "delta":0

  Subject subject;
  var rank;
  var delta;

  SubjectEntity.fromMap(Map<String, dynamic> map){
    rank = map['rank'];
    delta = map['delta'];
    var subjectMap = map['subject'];
    subject = Subject.fromMap(subjectMap);
  }
}
class DynamicsEntity {

  String did;
  String uid;
  String dMessage;
  String dPosttime;
  String dTitle;
  int dType;
  int dIsdel;
  int dHotscore;
  int dZancount;
  int dDiscusscount;
  String location;
  String userHead;
  String usrNickname;
  String dUrl;

  DynamicsEntity.fromMap(Map<String, dynamic> map){
    did = map['did'];
    uid = map['uid'];
    dMessage = map['dMessage'];
    dPosttime = map['dPosttime'];
    dTitle = map['dTitle'];
    dType = map['dType'];
    dIsdel = map['dIsdel'];
    dHotscore = map['dHotscore'];
    dZancount = map['dZancount'];
    dDiscusscount = map['dDiscusscount'];
    location = map['location'];
    userHead = map['userHead'];
    usrNickname = map['usrNickname'];
    dUrl=map['dUrl']==null?"":map['dUrl'];
  }

  //DynamicsEntity.fromParams({this.did, this.uid, this.dMessage, this.dPosttime, this.dTitle, this.dType,this.dIsdel,this.dHotscore,this.dZancount,
  //  this.location});


  DynamicsEntity.fromJson(Map<String, dynamic> jsonRes) {
    did = jsonRes['did'];
    uid = jsonRes['uid'];
    dMessage = jsonRes['dMessage'];
    dPosttime = jsonRes['dPosttime'];
    dTitle = jsonRes['dTitle'];
    dType = jsonRes['dType'];
    dIsdel = jsonRes['dIsdel'];
    dHotscore = jsonRes['dHotscore'];
    dZancount = jsonRes['dZancount'];
    dDiscusscount = jsonRes['dDiscusscount'];
    location = jsonRes['location'];
    userHead = jsonRes['userHead'];
    usrNickname = jsonRes['usrNickname'];
    dUrl=jsonRes['dUrl'];

  }

  //@override
 // String toString() {
  //  return '{"did": ${did != null?'${json.encode(did)}':'null'},"uid": ${uid != null?'${json.encode(uid)}':'null'},"dMessage": ${dMessage != null?'${json.encode(dMessage)}':'null'},"dPosttime": ${dPosttime != null?'${json.encode(dPosttime)}':'null'},"dTitle": ${dTitle != null?'${json.encode(dTitle)}':'null'},"dType": ${dType != null?'${json.encode(dType)}':'null'},"dIsdel": ${dIsdel != null?'${json.encode(dIsdel)}':'null'},"dHotscore": ${dHotscore != null?'${json.encode(dHotscore)}':'null'},"dZancount": ${dZancount != null?'${json.encode(dZancount)}':'null'},"location": ${location != null?'${json.encode(location)}':'null'}}';
  //}
}


class SubjectImage {

  Images images;


  ///构造函数
  SubjectImage.fromMap(Map<String, dynamic> map) {

    var img = map['images'];
    if(img!=null) {
      images = img;
    }
  }

  _converCasts(casts) {
    return casts.map<Cast>((item)=>Cast.fromMap(item)).toList();
  }

}

class Subject {
  bool tag = false;
  Rating rating;
  var genres;
  var title;
  List<Cast> casts;
  var durations;
  var collect_count;
  var mainland_pubdate;
  var has_video;
  var original_title;
  var subtype;
  var directors;
  var pubdates;
  var year;
  Images images;
  var alt;
  var id;

  ///构造函数
  Subject.fromMap(Map<String, dynamic> map) {
    var rating = map['rating'];
    this.rating = Rating(rating['average'], rating['max']);
    genres = map['genres'];
    title = map['title'];
    var castMap = map['casts'];
    casts = _converCasts(castMap);
    collect_count = map['collect_count'];
    original_title = map['original_title'];
    subtype = map['subtype'];
    directors = map['directors'];
    year = map['year'];
    var img = map['images'];
    images = Images(img['small'], img['large'], img['medium']);
    alt = map['alt'];
    id = map['id'];
    durations = map['durations'];
    mainland_pubdate = map['mainland_pubdate'];
    has_video = map['has_video'];
    pubdates = map['pubdates'];
  }

  _converCasts(casts) {
    return casts.map<Cast>((item)=>Cast.fromMap(item)).toList();
  }

}

class Images {
  var small;
  var large;
  var medium;

  Images(this.small, this.large, this.medium);
}

class Rating {
  var average;
  var max;
  Rating(this.average, this.max);
}



class Cast {
  var id;
  var name_en;
  var name;
  Avatar avatars;
  var alt;
  Cast(this.avatars, this.name_en, this.name, this.alt, this.id);

  Cast.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name_en = map['name_en'];
    name = map['name'];
    alt = map['alt'];
    var tmp = map['avatars'];
    if(tmp == null){
      avatars = null;
    }else{
      avatars = Avatar(tmp['small'], tmp['large'], tmp['medium']);
    }

  }
}

class Avatar {
  var medium;
  var large;
  var small;
  Avatar(this.small, this.large, this.medium);
}
