class NotificationModel {
  String? notificationId;
  String? senderId;
  String? receiverId;
  String? senderName;
  String? senderImage;
  String? type;
  String? postId;
  String? messageId;
  String? dateTime;
  bool? isRead;

  NotificationModel({
    this.notificationId,
    this.senderId,
    this.receiverId,
    this.senderName,
    this.senderImage,
    this.type,
    this.postId,
    this.messageId,
    this.dateTime,
    this.isRead,
  });

  NotificationModel.fromJson(Map<String, dynamic> json) {
    notificationId = json['notificationId'];
    senderId = json['senderId'];
    receiverId = json['receiverId'];
    senderName = json['senderName'];
    senderImage = json['senderImage'];
    type = json['type'];
    postId = json['postId'];
    messageId = json['messageId'];
    dateTime = json['dateTime'];
    isRead = json['isRead'];
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'senderId': senderId,
      'receiverId': receiverId,
      'senderName': senderName,
      'senderImage': senderImage,
      'type': type,
      'postId': postId,
      'messageId': messageId,
      'dateTime': dateTime,
      'isRead': isRead,
    };
  }
}
