// ignore_for_file: unnecessary_import, unused_import, unused_local_variable

import 'dart:io';

import 'package:budlee_app/models/users/user_model.dart';
import 'package:budlee_app/modules/screens/chats/chats.dart';
import 'package:budlee_app/modules/screens/feeds/feeds_screen.dart';
import 'package:budlee_app/modules/screens/friends/friends.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/components/components.dart';
import '../../../models/comments/comments_model.dart';
import '../../../models/massages/massage_model.dart';
import '../../../models/posts/posts_model.dart';
import '../../../modules/screens/feeds/comments_screen.dart';
import '../../../modules/screens/new_posts/new_posts.dart';
import '../../../modules/screens/settings/settings.dart';
import '../../../modules/screens/users/users.dart';
import 'app_states.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppInitialStat());
  static AppCubit get(context) => BlocProvider.of(context);

  int index = 0;

  userModel? model;
  PostsModel? postModel;
  CommentsModel? commentModel;
  MassageModel? massageModel;

  final ImagePicker imagePicker = ImagePicker();
  var currentIndex = 0;
  File? postImageFile;
  var avatar = '';
  List<userModel> myFriends = [];
  List<userModel> users = [];
  var massageController = TextEditingController();
  List<String> lastMessages = [];
  var commentController = TextEditingController();
  var postTextController = TextEditingController();
  var amountOfLikes = 0;
  var amountOfPosts = 0;
  var amountOfFollowers = 0;
  var chatItemIndex;
  var amountOfFollowing = 0;
  var amountOfViews = 0;
  var myPosts = [];
  List<CommentsModel> postComments = [];
  var myFollowers = [];
  List<MassageModel> massages = [];
  var myFollowing = [];
  var amountOfShares = 0;
  var amountOfImages = 0;
  var amountOfComments = 0;
  var amountOfPostsShares = 0;
  bool isLike = false;
  IconData likeIcon = Icons.favorite_border_outlined;
  Color likeIconColor = Colors.grey;
  IconData shareIcon = FlutterIcons.share_ent;
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var bioController = TextEditingController();
  var avatarController = TextEditingController();
  var dateController = TextEditingController();
  var phoneController = TextEditingController();
  IconData commentIcon = Icons.mode_comment_outlined;
  List<BottomNavigationBarItem> bottomNavItems = [
    const BottomNavigationBarItem(icon: Icon(FontAwesome.home), label: 'Home'),
    const BottomNavigationBarItem(
      icon: Icon(Icons.people_alt_outlined),
      label: 'Friends',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.location_on_outlined),
      label: 'Users Nearby',
    ),
    const BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Messages'),
    const BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];
  List<Widget> screens = [
    Feeds(),
    Friends(),
    UsersNearby(),
    Chats(),
    SettingsScreen(),
  ];
  List<String> titles = [
    'News Feed',
    'Friends',
    'Users Nearby',
    'Messages',
    'Profile',
    'Settings',
  ];
  List<PostsModel> posts = [];

  void changeBottomNavBar(int index) {
    if (index == 4) {
      emit(SettingsOpenedState());
    } else if (index == 3) {
      getUsers();
      emit(ChangeBottomNavBarState());
      currentIndex = 3;
    } else {
      currentIndex = index;
      emit(ChangeBottomNavBarState());
    }
  }

  int myPostsCalculation() {
    for (var element in posts) {
      if (element.uId == model!.uId) {
        myPosts.add(element);
      }
    }
    return myPosts.length;
  }

  void changePostAmount() {
    amountOfPosts = posts.length;
    emit(PostAmountChangeState());
  }

  void changeGalleryAmount() {
    amountOfImages = model!.imagesOfGallery!.length;
    emit(GalleryAmountChangeState());
  }

  Future<void> getCoverImage() async {
    emit(UploadCoverImageLoadingState());
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      model!.coverImageFile = File(pickedFile.path);
      model!.imagesOfGallery!.add(model!.coverImageFile!);
      emit(UploadCoverImageSuccessState());
    } else {
      emit(UploadCoverImageErrorState('No image selected'));
    }
  }

  Future<void> getProfileImage() async {
    emit(UploadProfileImageLoadingState());
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      model!.profileImageFile = File(pickedFile.path);
      model!.imagesOfGallery!.add(model!.coverImageFile!);
      emit(UploadProfileImageSuccessState());
    } else {
      emit(UploadProfileImageErrorState('No image selected'));
    }
  }

  Future<void> getPostsImage() async {
    emit(UploadPostsImageLoadingState());
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      postImageFile = File(pickedFile.path);
      model!.imagesOfGallery!.add(postImageFile!);
      FirebaseFirestore.instance
          .collection('users')
          .doc(model!.uId)
          .update({
            'gallery': model!.imagesOfGallery!
                .map((file) => file.path)
                .toList(),
          })
          .then((value) {
            getUserData(model!.uId);
            emit(UploadToGallerySuccessState());
          })
          .catchError((error) {
            emit(UploadToGalleryErrorState(error.toString()));
          });
      emit(UploadPostsImageSuccessState());
    } else {
      emit(UploadPostsImageErrorState('No image selected'));
    }
  }

  void logOut() {
    emit(LogOutLoadingState());
    FirebaseFirestore.instance
        .collection('users')
        .doc(model!.uId)
        .update({'isOnline': false})
        .then((value) {
          FirebaseAuth.instance.signOut();
          model = null;
          emit(LogOutSuccessState());
        });
  }

  // Future<void> uploadProfileImage() async {
  //   emit(UploadProfileImageLoadingState());
  //   firebase_storage.FirebaseStorage.instance
  //       .ref()
  //       .child(
  //         'users/${Uri.file(model!.profileImageFile!.path).pathSegments.last}',
  //       )
  //       .putFile(model!.profileImageFile!)
  //       .then((value) {
  //         value.ref
  //             .getDownloadURL()
  //             .then((value) {
  //               emit(UploadProfileImageSuccessState());
  //               updateUserData(avatar: value);
  //             })
  //             .catchError((error) {
  //               emit(UploadProfileImageErrorState(error.toString()));
  //             });
  //       })
  //       .catchError((error) {
  //         emit(UploadProfileImageErrorState(error.toString()));
  //       });
  // }

  void updateUserData({
    String? name,
    String? bio,
    String? avatar,
    String? date,
    String? postId,
    String? phone,
    String? coverImage,
  }) {
    emit(UpdateUserDataLoadingState());
    FirebaseFirestore.instance
        .collection('users')
        .doc(model!.uId) // Assuming model and model.uId will be valid here
        .update({
          'name': name ?? model!.name,
          'bio': bio ?? model!.bio,
          'avatar': avatar ?? model!.image,
          'birthday': date ?? model!.birthday,
          'phone': phone ?? model!.phone,
          'coverImage': coverImage ?? model!.coverImage,
        })
        .then((value) {
          getUserData(model!.uId);
          FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
              .update({
                'name': name ?? model!.name,
                'avatar': avatar ?? model!.image,
              })
              .then((value) {})
              .catchError((error) {});
          emit(UpdateUserDataSuccessState());
        })
        .catchError((error) {
          emit(UpdateUserDataErrorState(error.toString()));
        });
  }

  void removePostImage() {
    postImageFile = null;
    emit(RemovePostImageState());
  }

  void createPost({
    String? dateTime,
    String? text,
    String? postImage,
    String? profileImage,
  }) {
    emit(CreatePostLoadingState());

    DocumentReference newPostRef = FirebaseFirestore.instance
        .collection('posts')
        .doc();

    PostsModel newPostModel = PostsModel(
      name: model!.name,
      image: profileImage,
      uId: model!.uId,
      amountOfLikes: 0,
      amountOfComments: 0,
      isLiked: false,
      amountOfShares: 0,
      dateTime: dateTime,
      text: text,
      postImage: postImage ?? '',
      postId: newPostRef.id,
    );
    newPostRef
        .set(newPostModel.toMap())
        .then((value) {
          getPosts();
          emit(CreatePostSuccessState());
        })
        .catchError((error) {
          emit(CreatePostErrorState(error.toString()));
        });
  }

  void getPosts() {
    emit(GetPostsLoadingState());
    FirebaseFirestore.instance
        .collection('posts')
        .orderBy('dateTime')
        .snapshots()
        .listen((event) {
          posts.clear();
          event.docs.forEach((element) {
            posts.add(PostsModel.fromJson(element.data()));
          });
          emit(GetPostsSuccessState());
        })
        .onError((error) {
          emit(GetPostsErrorState(error.toString()));
        });
  }

  void getPostComments(String postId) {
    emit(GetPostCommentsLoadingState());
    FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .get()
        .then((value) {
          postComments.clear();
          value.docs.forEach((element) {
            postComments.add(CommentsModel.fromJson(element.data()));
          });
          print(postComments);
          emit(GetPostCommentsSuccessState());
        })
        .catchError((error) {
          emit(GetPostCommentsErrorState(error.toString()));
        });
  }

  Future<void> uploadToGallery() async {
    emit(UploadToGalleryLoadingState());
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (model == null) {
        emit(UploadToGalleryErrorState('User data not available'));
        return;
      }
      model!.imagesOfGallery ??= [
        model!.coverImageFile == null
            ? (model!.coverImage.toString().startsWith('http')
                  ? NetworkImage(model!.coverImage.toString())
                  : FileImage(File(model!.coverImage.toString()))
                        as ImageProvider) // Added 'as ImageProvider' for clarity
            : FileImage(model!.coverImageFile!),
        model!.profileImageFile == null
            ? (model!.image.toString().startsWith('http')
                  ? NetworkImage(model!.image.toString())
                  : FileImage(File(model!.image.toString()))
                        as ImageProvider) // Added 'as ImageProvider' for clarity
            : FileImage(model!.profileImageFile!),
      ]; // Initialize if null
      model!.imagesOfGallery!.add(File(pickedFile.path));
      FirebaseFirestore.instance
          .collection('users')
          .doc(model!.uId)
          .update({
            'gallery': model!.imagesOfGallery!
                .map((file) => file.path)
                .toList(),
          })
          .then((value) {
            getUserData(model!.uId);
            emit(UploadToGallerySuccessState());
          })
          .catchError((error) {
            emit(UploadToGalleryErrorState(error.toString()));
          });
    } else {
      emit(UploadToGalleryErrorState('No image selected'));
    }
  }

  void moveBetweenPostsAndMainScreen(context) {
    navigateTo(context, NewPosts());
    emit(MoveBetweenPostsAndMainScreenState());
  }

  void getUsers() {
    emit(GetAllUsersLoadingState());
    if (users.isEmpty) {
      FirebaseFirestore.instance
          .collection('users')
          .get()
          .then((value) {
            users.clear();
            value.docs.forEach((element) {
              if (element.id != model!.uId) {
                users.add(userModel.fromJson(element.data()));
              }
            });
            emit(GetAllUsersSuccessState());
          })
          .catchError((error) {
            emit(GetAllUsersErrorState(error.toString()));
          });
    }
  }

  void changeLikeState({String? postId, String? userId}) {
    final postIndex = posts.indexWhere((p) => p.postId == postId);
    if (postIndex == -1) {
      return;
    }

    final post = posts[postIndex];
    post.isLiked = !(post.isLiked ?? false);

    if (post.isLiked!) {
      post.amountOfLikes = (post.amountOfLikes ?? 0) + 1;
    } else {
      post.amountOfLikes = (post.amountOfLikes ?? 0) - 1;
    }

    emit(LikeChangeState());

    FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .update({'isLiked': post.isLiked, 'amountOfLikes': post.amountOfLikes})
        .catchError((error) {
          print('Error updating like: $error');
          // Not reverting for simplicity, but in a real app you might want to.
        });
  }

  void changeCommentState({String? postId}) {
    FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .update({'amountOfComments': FieldValue.increment(1)})
        .then((value) {
          emit(CommentChangeState());
        })
        .catchError((error) {
          print(error.toString());
        });
  }

  void createComment({String? postId, String? commentText}) {
    emit(CreateCommentLoadingState());
    final postIndex = posts.indexWhere((p) => p.postId == postId);
    if (postIndex == -1) {
      return;
    }

    final post = posts[postIndex];
    FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add({
          'userId': model!.uId,
          'userName': model!.name,
          'userImage': model!.image,
          'postId': postId,
          'commentText': commentText,
          'amountOfLikes': 0,
          'amountOfReplies': 0,
          'isLiked': false,
        })
        .then((value) {
          value.get().then((value) {
            postComments.add(CommentsModel.fromJson(value.data()!));
          });
          changeCommentState(postId: postId);
          emit(CreateCommentSuccessState());
        })
        .catchError((error) {
          emit(CreateCommentErrorState(error.toString()));
        });
  }

  void getUserData(String? uId) {
    if (uId == null || uId.isEmpty) {
      emit(GetUserDataErrorState("User ID is null or empty"));
      return;
    }
    emit(GetUserDataLoadingState());

    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .get()
        .then((value) {
          if (value.exists && value.data() != null) {
            model = userModel.fromJson(value.data()!);
            print(value.data()!);
            print(model);
            emit(GetUserDataSuccessState());
          } else {
            emit(GetUserDataErrorState("User data not found for ID: $uId"));
          }
        })
        .catchError((error) {
          emit(GetUserDataErrorState(error.toString()));
        });
  }

  void addFriend(String? friendId) {
    emit(AddFriendLoadingState());
    FirebaseFirestore.instance
        .collection('users')
        .doc(model!.uId)
        .collection('friends')
        .doc(friendId)
        .set({'friendId': friendId})
        .then((value) {
          emit(AddFriendSuccessState());
        })
        .catchError((error) {
          emit(AddFriendErrorState(error.toString()));
        });
  }

  void toCommentScreen(context, postIndex) {
    index = postIndex;
    getPostComments(posts[index].postId!);
    navigateTo(context, CommentsScreen());
  }

  void sendMassage({String? massageReceiverId, String? massageText}) {
    emit(SendMessageLoadingState());
    MassageModel massageModel = MassageModel(
      massageText: massageText,
      massageSenderId: model!.uId,
      massageReceiverId: massageReceiverId,
      massageDate: DateTime.now().toString(),
    );
    FirebaseFirestore.instance
        .collection('users')
        .doc(model!.uId)
        .collection('chats')
        .doc(massageReceiverId)
        .collection('messages')
        .add(massageModel.toMap())
        .then((value) {
          emit(SendMessageSuccessState());
        })
        .catchError((error) {
          emit(SendMessageErrorState(error.toString()));
        });
    FirebaseFirestore.instance
        .collection('users')
        .doc(massageReceiverId)
        .collection('chats')
        .doc(model!.uId)
        .collection('messages')
        .add(massageModel.toMap())
        .then((value) {
          emit(SendMessageSuccessState());
        })
        .catchError((error) {
          emit(SendMessageErrorState(error.toString()));
        });
  }

  void getMassages({String? massageReceiverId}) {
    emit(GetMessagesLoadingState());
    FirebaseFirestore.instance
        .collection('users')
        .doc(model!.uId)
        .collection('chats')
        .doc(massageReceiverId)
        .collection('messages')
        .orderBy('massageDate')
        .snapshots()
        .listen((event) {
          massages.clear();
          event.docs.forEach((element) {
            massageModel = MassageModel.fromJson(element.data());
            massages.add(massageModel!);
            lastMessages.add(massageModel!.massageText!);
          });
          emit(GetMessagesSuccessState());
        });
  }
}
