class PostsModel {
  String? uId;
  String? name;
  String? image;
  String? dateTime;
  String? postId;
  int? amountOfLikes = 0;
  bool? isLiked = false;
  int? amountOfComments = 0;
  int? amountOfShares = 0;
  String? text;
  String? postImage;

  PostsModel({
    this.uId,
    this.name,
    this.image,
    this.dateTime,
    this.postId,
    this.amountOfLikes,
    this.isLiked,
    this.amountOfComments,
    this.amountOfShares,
    this.text,
    this.postImage,
  });

  PostsModel.fromJson(Map<String, dynamic> json) {
    uId = json['uId'];
    name = json['name'];
    image = json['image'];
    postId = json['postId'];
    dateTime = json['dateTime'];
    amountOfLikes = json['amountOfLikes'] ?? 0;
    amountOfComments = json['amountOfComments'] ?? 0;
    amountOfShares = json['amountOfShares'] ?? 0;
    text = json['text'];
    postImage = json['postImage'];
  }

  Map<String, dynamic> toMap() {
    return {
      'uId': uId,
      'name': name,
      'image': image,
      'dateTime': dateTime,
      'postId': postId,
      'amountOfLikes': amountOfLikes,
      'amountOfComments': amountOfComments,
      'amountOfShares': amountOfShares,
      'text': text,
      'postImage': postImage,
    };
  }
}
