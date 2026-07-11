class MassageModel {
  String? massageText;
  String? massageSenderId;
  String? massageReceiverId;
  String? massageDate;
  String? voiceMassage;

  MassageModel({
    this.massageText,
    this.massageSenderId,
    this.massageReceiverId,
    this.massageDate,
    this.voiceMassage,
  });

  MassageModel.fromJson(Map<String, dynamic> json) {
    massageText = json['massageText'];
    massageSenderId = json['massageSender'];
    massageReceiverId = json['massageReceiver'];
    massageDate = json['massageDate'];
    voiceMassage = json['voiceMassage'];
  }

  Map<String, dynamic> toMap() {
    return {
      'massageText': massageText,
      'massageSender': massageSenderId,
      'massageReceiver': massageReceiverId,
      'massageDate': massageDate,
      'voiceMassage': voiceMassage,
    };
  }
}
