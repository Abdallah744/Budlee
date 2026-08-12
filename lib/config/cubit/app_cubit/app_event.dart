import 'dart:io';
import 'package:budlee_app/models/comments/comments_model.dart';

abstract class AppEvents {}

class AppSearchEvent extends AppEvents {
  final String text;
  AppSearchEvent(this.text);
}

class AppChangeBottomNavBarEvent extends AppEvents {
  final int index;
  AppChangeBottomNavBarEvent(this.index);
}

class AppGetCoverImageEvent extends AppEvents {}

class AppGetProfileImageEvent extends AppEvents {}

class AppGetPostsImageEvent extends AppEvents {}

class AppLogOutEvent extends AppEvents {}

class AppUpdateUserDataEvent extends AppEvents {
  final String? name;
  final String? bio;
  final String? avatar;
  final String? date;
  final String? phone;
  final String? coverImage;

  AppUpdateUserDataEvent({
    this.name,
    this.bio,
    this.avatar,
    this.date,
    this.phone,
    this.coverImage,
  });
}

class AppRemovePostImageEvent extends AppEvents {}

class AppCreatePostEvent extends AppEvents {
  final String? dateTime;
  final String? text;
  final String? postImage;
  final String? profileImage;

  AppCreatePostEvent({
    this.dateTime,
    this.text,
    this.postImage,
    this.profileImage,
  });
}

class AppGetPostsEvent extends AppEvents {}

class AppGetPostCommentsEvent extends AppEvents {
  final String postId;
  AppGetPostCommentsEvent(this.postId);
}

class AppPickImageEvent extends AppEvents {}

class AppUpdateDataAndGetUrlEvent extends AppEvents {
  final String name;
  final File imageFile;
  final String type;

  AppUpdateDataAndGetUrlEvent({
    required this.name,
    required this.imageFile,
    required this.type,
  });
}

class AppUploadGalleryImageEvent extends AppEvents {}

class AppGetUsersEvent extends AppEvents {}

class AppChangeLikeStateEvent extends AppEvents {
  final String? postId;
  final String? userId;

  AppChangeLikeStateEvent({this.postId, this.userId});
}

class AppCreateCommentEvent extends AppEvents {
  final String? postId;
  final String? commentText;

  AppCreateCommentEvent({this.postId, this.commentText});
}

class AppSetReplyToEvent extends AppEvents {
  final CommentsModel? comment;
  AppSetReplyToEvent(this.comment);
}

class AppCreateReplyEvent extends AppEvents {
  final String postId;
  final String commentId;
  final String replyText;

  AppCreateReplyEvent({
    required this.postId,
    required this.commentId,
    required this.replyText,
  });
}

class AppGetRepliesEvent extends AppEvents {
  final String postId;
  final String commentId;

  AppGetRepliesEvent({required this.postId, required this.commentId});
}

class AppGetUserDataEvent extends AppEvents {
  final String? uId;
  AppGetUserDataEvent(this.uId);
}

class AppGetFriendsEvent extends AppEvents {}

class AppAddFriendEvent extends AppEvents {
  final String? friendId;
  AppAddFriendEvent(this.friendId);
}

class AppRemoveFriendEvent extends AppEvents {
  final String? friendId;
  AppRemoveFriendEvent(this.friendId);
}

class AppSendMassageEvent extends AppEvents {
  final String? massageReceiverId;
  final String? massageText;
  final String? voiceMassage;

  AppSendMassageEvent({
    this.massageReceiverId,
    this.massageText,
    this.voiceMassage,
  });
}

class AppGetMassagesEvent extends AppEvents {
  final String? massageReceiverId;
  AppGetMassagesEvent({this.massageReceiverId});
}

class AppGetAllLastMessagesEvent extends AppEvents {}

class AppStartRecordingEvent extends AppEvents {}

class AppStopRecordingEvent extends AppEvents {
  final String receiverId;
  AppStopRecordingEvent(this.receiverId);
}

class AppUploadVoiceMessageEvent extends AppEvents {
  final File audioFile;
  final String receiverId;

  AppUploadVoiceMessageEvent({
    required this.audioFile,
    required this.receiverId,
  });
}
