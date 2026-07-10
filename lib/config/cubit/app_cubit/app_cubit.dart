// ignore_for_file: unnecessary_import, unused_import, unused_local_variable, unnecessary_null_comparison

import 'dart:io';

import 'package:budlee_app/models/users/friends_model.dart';
import 'package:budlee_app/models/users/user_model.dart';
import 'package:budlee_app/modules/screens/chats/chats.dart';
import 'package:budlee_app/modules/screens/feeds/feeds_screen.dart';
import 'package:budlee_app/modules/screens/friends/friends.dart';
import 'package:budlee_app/utils/shared/network/local/cash_helper.dart';
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
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../../../core/components/components.dart';
import '../../../core/constants/constants.dart';
import '../../../models/comments/comments_model.dart';
import '../../../models/massages/massage_model.dart';
import '../../../models/posts/posts_model.dart';
import '../../../modules/screens/feeds/comments_screen.dart';
import '../../../modules/screens/new_posts/new_posts.dart';
import '../../../modules/screens/settings/settings.dart';
import 'app_states.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppInitialStat());
  static AppCubit get(context) => BlocProvider.of(context);

  int index = 0;

  userModel? model;
  PostsModel? postModel;
  CommentsModel? commentModel;
  MassageModel? massageModel;
  FriendsModel? friendModel;
  File? selectedImage;
  FirebaseAuth auth = FirebaseAuth.instance;

  final ImagePicker imagePicker = ImagePicker();
  var currentIndex = 0;
  File? postImageFile;
  String? postImageUrl;
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
  bool isFriend = false;
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
    const BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Messages'),
    const BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];
  List<Widget> screens = [Feeds(), Friends(), Chats(), SettingsScreen()];
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
    myPosts = posts.where((element) => element.uId == model?.uId).toList();
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
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      emit(UploadCoverImageLoadingState());
      File imageFile = File(pickedFile.path);

      String? imageUrl = await uploadToSubabase(imagefile: imageFile);

      if (imageUrl != null) {
        if (model!.imagesOfGallery == null) {
          model!.imagesOfGallery = [];
        }

        List<String> galleryPaths = model!.imagesOfGallery!
            .map((file) => file.path)
            .toList();
        galleryPaths.add(imageUrl);

        FirebaseFirestore.instance
            .collection('users')
            .doc(model!.uId)
            .update({'coverImage': imageUrl, 'gallery': galleryPaths})
            .then((value) {
              getUserData(model!.uId);
              emit(UploadCoverImageSuccessState());
            })
            .catchError((error) {
              emit(UploadCoverImageErrorState(error.toString()));
            });
      } else {
        emit(UploadCoverImageErrorState('Failed to upload image'));
      }
    } else {
      emit(UploadCoverImageErrorState('No image selected'));
    }
  }

  Future<void> getProfileImage() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      emit(UploadProfileImageLoadingState());
      File imageFile = File(pickedFile.path);

      String? imageUrl = await uploadToSubabase(imagefile: imageFile);

      if (imageUrl != null) {
        if (model!.imagesOfGallery == null) {
          model!.imagesOfGallery = [];
        }

        List<String> galleryPaths = model!.imagesOfGallery!
            .map((file) => file.path)
            .toList();
        galleryPaths.add(imageUrl);

        FirebaseFirestore.instance
            .collection('users')
            .doc(model!.uId)
            .update({'avatar': imageUrl, 'gallery': galleryPaths})
            .then((value) {
              getUserData(model!.uId);
              emit(UploadProfileImageSuccessState());
            })
            .catchError((error) {
              emit(UploadProfileImageErrorState(error.toString()));
            });
      } else {
        emit(UploadProfileImageErrorState('Failed to upload image'));
      }
    } else {
      emit(UploadProfileImageErrorState('No image selected'));
    }
  }

  Future<void> getPostsImage() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      emit(UploadPostsImageLoadingState());
      postImageFile = File(pickedFile.path);

      String? imageUrl = await uploadToSubabase(imagefile: postImageFile!);

      if (imageUrl != null) {
        postImageUrl = imageUrl; // Store URL for createPost
        if (model!.imagesOfGallery == null) {
          model!.imagesOfGallery = [];
        }

        List<String> galleryPaths = model!.imagesOfGallery!
            .map((file) => file.path)
            .toList();
        galleryPaths.add(imageUrl);

        FirebaseFirestore.instance
            .collection('users')
            .doc(model!.uId)
            .update({'gallery': galleryPaths})
            .then((value) {
              getUserData(model!.uId);
              emit(UploadPostsImageSuccessState());
              emit(UploadToGallerySuccessState());
            })
            .catchError((error) {
              emit(UploadToGalleryErrorState(error.toString()));
              emit(UploadPostsImageErrorState(error.toString()));
            });
      } else {
        emit(UploadPostsImageErrorState('Failed to upload image'));
      }
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
    postImageUrl = null;
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
          postImageFile = null;
          postImageUrl = null;
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

  Future<void> pickImage() async {
    emit(ProfileLoading());
    try {
      final XFile? pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile == null) {
        emit(ProfileError('No image selected'));
        return;
      }
      selectedImage = File(pickedFile.path);
      emit(ProfileSuccess(selectedImage!));
    } on Exception catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<String?> uploadToSubabase({required File imagefile}) async {
    emit(UploadToSupabaseLoadingState());
    final User? current = auth.currentUser;
    if (current == null) {
      emit(UploadToSupabaseErrorState('User data not available'));
      return null;
    }

    try {
      final SupabaseClient supabaseClient = Supabase.instance.client;
      final String imagePath =
          'users/${current.uid}/profile_${DateTime.now().microsecondsSinceEpoch}.jpg';

      await supabaseClient.storage.from('images').upload(imagePath, imagefile);
      final String imageUrl = supabaseClient.storage
          .from('images')
          .getPublicUrl(imagePath);
      emit(UploadToSupabaseSuccessState());
      return imageUrl;
    } catch (error) {
      print('Supabase error check: Have you restarted the app? $error');
      emit(
        UploadToSupabaseErrorState(
          'Upload failed. Please restart the app. Details: $error',
        ),
      );
      return null;
    }
  }

  updateDataAndGetUrl({
    required String name,
    required File imageFile,
    required String type,
  }) async {
    final User? current = auth.currentUser;
    if (current == null) {
      emit(ProfileError('User data not available'));
      return;
    }
    final Map<String, dynamic> data = {};
    if (name.trim().isNotEmpty) {
      data['name'] = name.trim();
    }
    if (imageFile != null) {
      final String? imageUrl = await uploadToSubabase(imagefile: imageFile);
      if (imageUrl != null) {
        data[type] = imageUrl;
      }
    }
    if (data.isEmpty) {
      emit(ProfileError('No data to update'));
      return;
    }
    FirebaseFirestore.instance
        .collection('users')
        .doc(current.uid)
        .update(data)
        .then((value) {
          getUserData(current.uid);
          emit(UpdateUserDataSuccessState());
        })
        .catchError((error) {
          emit(UpdateUserDataErrorState(error.toString()));
        });
  }

  updateDataAndGetGalleryUrl({required File imageFile}) async {
    final User? current = auth.currentUser;
    if (current == null) {
      emit(UploadToGalleryErrorState('User data not available'));
      return;
    }

    final String? imageUrl = await uploadToSubabase(imagefile: imageFile);
    if (imageUrl == null) {
      emit(UploadToGalleryErrorState('Failed to upload image'));
      return;
    }

    if (model!.imagesOfGallery == null) {
      model!.imagesOfGallery = [];
    }

    List<String> galleryPaths = model!.imagesOfGallery!
        .map((file) => file.path)
        .toList();
    galleryPaths.add(imageUrl);

    FirebaseFirestore.instance
        .collection('users')
        .doc(model!.uId)
        .update({'gallery': galleryPaths})
        .then((value) {
          getUserData(model!.uId);
          emit(UploadToGallerySuccessState());
        })
        .catchError((error) {
          emit(UploadToGalleryErrorState(error.toString()));
        });
  }

  Future<void> uploadGalleryImage() async {
    final XFile? pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) {
      emit(UploadToGalleryErrorState('No image selected'));
      return;
    }
    await updateDataAndGetGalleryUrl(imageFile: File(pickedFile.path));
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
            getFriends();
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

  void getFriends() {
    emit(GetFriendsLoadingState());
    FirebaseFirestore.instance
        .collection('users')
        .doc(model?.uId ?? uId)
        .collection('friends')
        .get()
        .then((value) {
          myFriends = [];
          value.docs.forEach((doc) {
            String friendId = doc.id;
            // Try to find the friend in the users list
            final friend = users.firstWhere(
              (element) => element.uId == friendId,
              orElse: () => userModel(isEmailVerified: false),
            );
            if (friend.uId != null) {
              myFriends.add(friend);
            }
          });
          emit(GetFriendsSuccessState());
        })
        .catchError((error) {
          emit(GetFriendsErrorState(error.toString()));
        });
  }

  void addFriend(String? friendId) {
    if (myFriends.any((element) => element.uId == friendId)) {
      return;
    }
    emit(AddFriendLoadingState());
    FirebaseFirestore.instance
        .collection('users')
        .doc(model!.uId)
        .collection('friends')
        .doc(friendId)
        .set({'friendId': friendId})
        .then((value) {
          final friend = users.firstWhere(
            (element) => element.uId == friendId,
            orElse: () => userModel(isEmailVerified: false),
          );

          if (friend.uId != null) {
            myFriends.add(friend);
          }

          FirebaseFirestore.instance
              .collection('users')
              .doc(friendId)
              .collection('friends')
              .doc(model!.uId)
              .set({'friendId': model!.uId});

          emit(AddFriendSuccessState());
        })
        .catchError((error) {
          emit(AddFriendErrorState(error.toString()));
        });
  }

  void removeFriend(String? friendId) {
    emit(RemoveFriendLoadingState());
    FirebaseFirestore.instance
        .collection('users')
        .doc(model!.uId)
        .collection('friends')
        .doc(friendId)
        .delete()
        .then((value) {
          users.forEach((element) {
            if (element.uId == friendId) {
              myFriends.remove(element);
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(friendId)
                  .collection('friends')
                  .doc(model!.uId)
                  .delete();
            }
          });
          isFriend = false;
          emit(RemoveFriendSuccessState());
        })
        .catchError((error) {
          emit(RemoveFriendErrorState(error.toString()));
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
