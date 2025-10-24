class CommentsModel {
  String? userName;
  String? userId;
  String? postId;
  String? userImage;
  String? commentText;
  int? amountOfReplies;
  int? amountOfLikes;
  bool? isLiked;
  String? commentId;

  CommentsModel({
    this.userName,
    this.userId,
    this.userImage,
    this.postId,
    this.commentText,
    this.amountOfLikes,
    this.isLiked,
    this.amountOfReplies,
    this.commentId,
  });

  CommentsModel.fromJson(Map<String, dynamic> json) {
    userName = json['userName'];
    userId = json['userId'];
    postId = json['postId'];
    userImage = json['userImage'];
    commentText = json['commentText'];
    amountOfLikes = json['amountOfLikes'];
    isLiked = json['isLiked'];
    amountOfReplies = json['amountOfReplies'];
    commentId = json['commentId'];
  }
  Map<String, dynamic> toMap() => ({
    'userName': userName,
    'userId': userId,
    'postId': postId,
    'userImage': userImage,
    'commentText': commentText,
    'amountOfLikes': amountOfLikes,
    'isLiked': isLiked,
    'amountOfReplies': amountOfReplies,
    'commentId': commentId,
  });
}
