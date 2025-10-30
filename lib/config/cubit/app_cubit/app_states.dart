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
