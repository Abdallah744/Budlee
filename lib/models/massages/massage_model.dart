class MassageModel {
  String? massageText;
  String? massageSenderId;
  String? massageReceiverId;
  String? massageDate;

  MassageModel({
    this.massageText,
    this.massageSenderId,
    this.massageReceiverId,
    this.massageDate,
  });

  MassageModel.fromJson(Map<String, dynamic> json) {
    massageText = json['massageText'];
    massageSenderId = json['massageSender'];
    massageReceiverId = json['massageReceiver'];
    massageDate = json['massageDate'];
  }

  Map<String, dynamic> toMap() {
    return {
      'massageText': massageText,
      'massageSender': massageSenderId,
      'massageReceiver': massageReceiverId,
      'massageDate': massageDate,
    };
  }
}
