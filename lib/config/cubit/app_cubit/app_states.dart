import 'dart:io';

abstract class AppState {}

class AppInitialStat extends AppState {}

class GetUserDataLoadingState extends AppState {}

class GetUserDataSuccessState extends AppState {}

class GetUserDataErrorState extends AppState {
  final String error;
  GetUserDataErrorState(this.error);
}

class UpdateUserDataLoadingState extends AppState {}

class UpdateUserDataSuccessState extends AppState {}

class UpdateUserDataErrorState extends AppState {
  final String error;
  UpdateUserDataErrorState(this.error);
}

class UploadProfileImageLoadingState extends AppState {}

class UploadProfileImageSuccessState extends AppState {}

class UploadProfileImageErrorState extends AppState {
  final String error;
  UploadProfileImageErrorState(this.error);
}

class UploadCoverImageLoadingState extends AppState {}

class UploadCoverImageSuccessState extends AppState {}

class UploadCoverImageErrorState extends AppState {
  final String error;
  UploadCoverImageErrorState(this.error);
}

class EmailVerificationState extends AppState {}

class ChangeBottomNavBarState extends AppState {}

class MoveBetweenPostsAndMainScreenState extends AppState {}

class SettingsOpenedState extends AppState {}

class NewPostsState extends AppState {}

class LikeChangeState extends AppState {}

class CommentChangeState extends AppState {}

class CreateCommentLoadingState extends AppState {}

class CreateCommentSuccessState extends AppState {}

class CreateCommentErrorState extends AppState {
  final String error;
  CreateCommentErrorState(this.error);
}

class GetPostCommentsLoadingState extends AppState {}

class GetPostCommentsSuccessState extends AppState {}

class GetPostCommentsErrorState extends AppState {
  final String error;
  GetPostCommentsErrorState(this.error);
}

class CreateReplyLoadingState extends AppState {}

class CreateReplySuccessState extends AppState {}

class CreateReplyErrorState extends AppState {
  final String error;
  CreateReplyErrorState(this.error);
}

class GetRepliesLoadingState extends AppState {}

class GetRepliesSuccessState extends AppState {}

class GetRepliesErrorState extends AppState {
  final String error;
  GetRepliesErrorState(this.error);
}

class ChangeReplyToState extends AppState {}

// Chat States
class SendMessageLoadingState extends AppState {}

class SendMessageSuccessState extends AppState {}

class SendMessageErrorState extends AppState {
  final String error;
  SendMessageErrorState(this.error);
}

class GetMessagesLoadingState extends AppState {}

class GetMessagesSuccessState extends AppState {}

class GetMessagesErrorState extends AppState {
  final String error;
  GetMessagesErrorState(this.error);
}

class GetLastMessagesSuccessState extends AppState {}

class StartRecordingState extends AppState {}

class StopRecordingState extends AppState {}

class RecordingTimerUpdateState extends AppState {}

class UploadVoiceMessageLoadingState extends AppState {}

class UploadVoiceMessageSuccessState extends AppState {}

class UploadVoiceMessageErrorState extends AppState {
  final String error;
  UploadVoiceMessageErrorState(this.error);
}

class ShareChangeState extends AppState {}

class UploadToGalleryLoadingState extends AppState {}

class UploadToGallerySuccessState extends AppState {}

class UploadToGalleryErrorState extends AppState {
  final String error;
  UploadToGalleryErrorState(this.error);
}

//Create Posts States
class CreatePostLoadingState extends AppState {}

class CreatePostSuccessState extends AppState {}

class CreatePostErrorState extends AppState {
  final String error;
  CreatePostErrorState(this.error);
}

// Upload Posts Image States
class UploadPostsImageLoadingState extends AppState {}

class UploadPostsImageSuccessState extends AppState {}

class UploadPostsImageErrorState extends AppState {
  final String error;
  UploadPostsImageErrorState(this.error);
}

// Remove Post Image States
class RemovePostImageState extends AppState {}

// Get Posts States
class GetPostsLoadingState extends AppState {}

class GetPostsSuccessState extends AppState {}

class GetPostsErrorState extends AppState {
  final String error;
  GetPostsErrorState(this.error);
}

class PostAmountChangeState extends AppState {}

class GalleryAmountChangeState extends AppState {}

class GetAllUsersLoadingState extends AppState {}

class GetAllUsersSuccessState extends AppState {}

class GetAllUsersErrorState extends AppState {
  final String error;
  GetAllUsersErrorState(this.error);
}

// log out States
class LogOutLoadingState extends AppState {}

class LogOutSuccessState extends AppState {}

// Add Friend
class AddFriendLoadingState extends AppState {}

class AddFriendSuccessState extends AppState {}

class AddFriendErrorState extends AppState {
  final String error;
  AddFriendErrorState(this.error);
}

// remove Friend
class RemoveFriendLoadingState extends AppState {}

class RemoveFriendSuccessState extends AppState {}

class RemoveFriendErrorState extends AppState {
  final String error;
  RemoveFriendErrorState(this.error);
}

// Get Friends
class GetFriendsLoadingState extends AppState {}

class GetFriendsSuccessState extends AppState {}

class GetFriendsErrorState extends AppState {
  final String error;
  GetFriendsErrorState(this.error);
}

// profile

class ProfileLoading extends AppState {}

class ProfileError extends AppState {
  final String error;
  ProfileError(this.error);
}

class ProfileSuccess extends AppState {
  final File imageFile;
  ProfileSuccess(this.imageFile);
}

// upload to supabase

class UploadToSupabaseLoadingState extends AppState {}

class UploadToSupabaseErrorState extends AppState {
  final String error;

  UploadToSupabaseErrorState(this.error);
}

class UploadToSupabaseSuccessState extends AppState {}

class SearchState extends AppState {}
