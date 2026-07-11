// ignore_for_file: unnecessary_import, unused_import, unused_local_variable, unnecessary_null_comparison

import 'dart:async';
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
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
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
  Map<String, MassageModel> lastMessagesMap = {};
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

  CommentsModel? replyToComment;
  Map<String, List<CommentsModel>> commentReplies = {};

  IconData shareIcon = FlutterIcons.share_ent;
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var bioController = TextEditingController();
  var avatarController = TextEditingController();
  var dateController = TextEditingController();
  var phoneController = TextEditingController();
  final AudioRecorder audioRecorder = AudioRecorder();
  bool isRecording = false;
  String? audioPath;
  int recordingDuration = 0;
  Timer? recordingTimer;
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
  List<String> titles = ['News Feed', 'Friends', 'Messages', 'Settings'];
  List<PostsModel> posts = [];

  List<userModel> searchResult = [];

  void search(String text) {
    searchResult = users.where((element) {
      return element.name!.toLowerCase().contains(text.toLowerCase());
    }).toList();
    emit(SearchState());
  }

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
              updateUserPostsData(avatar: imageUrl);
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
          updateUserPostsData(
            name: name ?? model!.name,
            avatar: avatar ?? model!.image,
          );
          getUserData(model!.uId);
          emit(UpdateUserDataSuccessState());
        })
        .catchError((error) {
          emit(UpdateUserDataErrorState(error.toString()));
        });
  }

  void updateUserPostsData({String? name, String? avatar}) {
    FirebaseFirestore.instance
        .collection('posts')
        .where('uId', isEqualTo: model!.uId)
        .get()
        .then((value) {
          value.docs.forEach((element) {
            element.reference.update({
              'name': name ?? model!.name,
              'image': avatar ?? model!.image,
            });
          });
        })
        .catchError((error) {
          print(error.toString());
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
        .orderBy('dateTime', descending: true)
        .snapshots()
        .listen((event) {
          posts = [];
          for (var element in event.docs) {
            var post = PostsModel.fromJson(element.data());
            posts.add(post);

            // Check if the current user has liked this post
            String? currentUid = model?.uId ?? uId;
            if (currentUid != null && currentUid.isNotEmpty) {
              FirebaseFirestore.instance
                  .collection('posts')
                  .doc(post.postId)
                  .collection('likes')
                  .doc(currentUid)
                  .get()
                  .then((value) {
                    if (value.exists) {
                      post.isLiked = true;
                    } else {
                      post.isLiked = false;
                    }
                    emit(GetPostsSuccessState());
                  })
                  .catchError((error) {
                    print('Error checking like: $error');
                  });
            }
          }
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
            var comment = CommentsModel.fromJson(element.data());
            comment.commentId = element.id;
            postComments.add(comment);
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
          updateUserPostsData(name: data['name'], avatar: data['avatar']);
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
    FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((value) {
          users = [];
          value.docs.forEach((element) {
            if (element.id != (model?.uId ?? uId)) {
              users.add(userModel.fromJson(element.data()));
            }
          });
          String? currentUid = model?.uId ?? uId;
          if (currentUid != null && currentUid.isNotEmpty) {
            getFriends();
            getAllLastMessages();
          }
          emit(GetAllUsersSuccessState());
        })
        .catchError((error) {
          emit(GetAllUsersErrorState(error.toString()));
        });
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
      FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('likes')
          .doc(userId)
          .set({'like': true})
          .then((value) {
            emit(LikeChangeState());
          })
          .catchError((error) {
            print(error.toString());
          });
    } else {
      post.amountOfLikes = (post.amountOfLikes ?? 0) - 1;
      FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('likes')
          .doc(userId)
          .delete()
          .then((value) {
            emit(LikeChangeState());
          })
          .catchError((error) {
            print(error.toString());
          });
    }

    emit(LikeChangeState());

    FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .update({'amountOfLikes': post.amountOfLikes})
        .catchError((error) {
          print('Error updating like count: $error');
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
    if (commentText == null || commentText.trim().isEmpty) return;
    emit(CreateCommentLoadingState());

    DocumentReference commentRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc();

    CommentsModel newComment = CommentsModel(
      userId: model!.uId,
      userName: model!.name,
      userImage: model!.image,
      postId: postId,
      commentText: commentText,
      amountOfLikes: 0,
      amountOfReplies: 0,
      isLiked: false,
      commentId: commentRef.id,
    );

    commentRef
        .set(newComment.toMap())
        .then((value) {
          postComments.add(newComment);
          changeCommentState(postId: postId);
          emit(CreateCommentSuccessState());
        })
        .catchError((error) {
          emit(CreateCommentErrorState(error.toString()));
        });
  }

  void setReplyTo(CommentsModel? comment) {
    replyToComment = comment;
    emit(ChangeReplyToState());
  }

  void createReply({
    required String postId,
    required String commentId,
    required String replyText,
  }) {
    if (replyText.trim().isEmpty) return;
    emit(CreateReplyLoadingState());

    DocumentReference replyRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .collection('replies')
        .doc();

    CommentsModel newReply = CommentsModel(
      userId: model!.uId,
      userName: model!.name,
      userImage: model!.image,
      postId: postId,
      commentText: replyText,
      amountOfLikes: 0,
      amountOfReplies: 0,
      isLiked: false,
      commentId: replyRef.id,
    );

    replyRef
        .set(newReply.toMap())
        .then((value) {
          FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
              .collection('comments')
              .doc(commentId)
              .update({'amountOfReplies': FieldValue.increment(1)});

          if (commentReplies[commentId] == null) {
            commentReplies[commentId] = [];
          }
          commentReplies[commentId]!.add(newReply);

          emit(CreateReplySuccessState());
        })
        .catchError((error) {
          emit(CreateReplyErrorState(error.toString()));
        });
  }

  void getReplies({required String postId, required String commentId}) {
    emit(GetRepliesLoadingState());
    FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .collection('replies')
        .get()
        .then((value) {
          commentReplies[commentId] = [];
          value.docs.forEach((element) {
            var reply = CommentsModel.fromJson(element.data());
            reply.commentId = element.id;
            commentReplies[commentId]!.add(reply);
          });
          emit(GetRepliesSuccessState());
        })
        .catchError((error) {
          emit(GetRepliesErrorState(error.toString()));
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
    String? currentUid = model?.uId ?? uId;
    if (currentUid == null || currentUid.isEmpty) {
      emit(GetFriendsErrorState("User ID is null or empty"));
      return;
    }
    emit(GetFriendsLoadingState());
    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid)
        .collection('friends')
        .get()
        .then((value) {
          myFriends = [];
          if (value.docs.isEmpty) {
            emit(GetFriendsSuccessState());
            return;
          }
          List<Future> futures = [];
          for (var doc in value.docs) {
            String friendId = doc.id;
            futures.add(
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(friendId)
                  .get()
                  .then((userDoc) {
                    if (userDoc.exists && userDoc.data() != null) {
                      myFriends.add(userModel.fromJson(userDoc.data()!));
                    }
                  }),
            );
          }
          Future.wait(futures).then((_) {
            emit(GetFriendsSuccessState());
          });
        })
        .catchError((error) {
          emit(GetFriendsErrorState(error.toString()));
        });
  }

  void addFriend(String? friendId) {
    String? currentUid = model?.uId ?? uId;
    if (currentUid == null || currentUid.isEmpty) return;

    if (myFriends.any((element) => element.uId == friendId)) {
      return;
    }
    emit(AddFriendLoadingState());
    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid)
        .collection('friends')
        .doc(friendId)
        .set({'friendId': friendId})
        .then((value) {
          final friend = users.firstWhere(
            (element) => element.uId == friendId,
            orElse: () => userModel(isEmailVerified: false),
          );

          if (myFriends.contains(friend)) {
            return;
          } else {
            if (friend.uId != null) {
              myFriends.add(friend);
            }
          }

          FirebaseFirestore.instance
              .collection('users')
              .doc(friendId)
              .collection('friends')
              .doc(currentUid)
              .set({'friendId': currentUid});

          emit(AddFriendSuccessState());
        })
        .catchError((error) {
          emit(AddFriendErrorState(error.toString()));
        });
  }

  void removeFriend(String? friendId) {
    String? currentUid = model?.uId ?? uId;
    if (currentUid == null || currentUid.isEmpty) return;

    emit(RemoveFriendLoadingState());
    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid)
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
                  .doc(currentUid)
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

  void sendMassage({
    String? massageReceiverId,
    String? massageText,
    String? voiceMassage,
  }) {
    bool isTextEmpty = massageText == null || massageText.trim().isEmpty;
    bool isVoiceEmpty = voiceMassage == null || voiceMassage.isEmpty;

    if (isTextEmpty && isVoiceEmpty) {
      print('Attempted to send empty message - returning');
      return;
    }
    emit(SendMessageLoadingState());
    MassageModel massageModel = MassageModel(
      massageText: massageText,
      massageSenderId: model!.uId,
      massageReceiverId: massageReceiverId,
      massageDate: DateTime.now().toString(),
      voiceMassage: voiceMassage,
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
    String? currentUid = model?.uId ?? uId;
    if (currentUid == null || currentUid.isEmpty) {
      emit(GetMessagesErrorState("User ID is null or empty"));
      return;
    }
    emit(GetMessagesLoadingState());
    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid)
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
          });
          if (massages.isNotEmpty && massageReceiverId != null) {
            lastMessagesMap[massageReceiverId] = massages.last;
          }
          emit(GetMessagesSuccessState());
        });
  }

  void getAllLastMessages() {
    String? currentUid = model?.uId ?? uId;
    if (currentUid == null || currentUid.isEmpty) return;

    users.forEach((user) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUid)
          .collection('chats')
          .doc(user.uId)
          .collection('messages')
          .orderBy('massageDate', descending: true)
          .limit(1)
          .get()
          .then((value) {
            if (value.docs.isNotEmpty) {
              lastMessagesMap[user.uId!] = MassageModel.fromJson(
                value.docs.first.data(),
              );
              emit(GetLastMessagesSuccessState());
            }
          });
    });
  }

  Future<void> startRecording() async {
    if (isRecording) return;
    try {
      if (await audioRecorder.hasPermission()) {
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String path =
            '${appDocDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

        const config = RecordConfig();

        print('Starting recording at: $path');
        await audioRecorder.start(config, path: path);
        isRecording = true;
        audioPath = path;
        recordingDuration = 0;
        recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
          recordingDuration++;
          emit(RecordingTimerUpdateState());
        });
        emit(StartRecordingState());
      } else {
        emit(UploadVoiceMessageErrorState('Audio recording permission denied'));
      }
    } catch (e) {
      print('Error starting recording: $e');
      emit(UploadVoiceMessageErrorState('Failed to start recording: $e'));
    }
  }

  Future<void> stopRecording({required String receiverId}) async {
    if (!isRecording) return;
    try {
      print('Stopping recording for receiver: $receiverId');
      final path = await audioRecorder.stop();
      isRecording = false;
      recordingTimer?.cancel();
      emit(StopRecordingState());
      if (path != null) {
        File audioFile = File(path);
        if (await audioFile.exists()) {
          final stats = await audioFile.stat();
          print('Recording stopped. File size: ${stats.size} bytes');

          if (stats.size < 100) {
            print('Recording file too small, discarding');
            return;
          }

          uploadVoiceMessage(audioFile: audioFile, receiverId: receiverId);
        } else {
          print('Audio file does not exist at path: $path');
          showToast(
            text: 'Error: Recording file not found',
            state: ToastStates.ERROR,
          );
        }
      } else {
        print('audioRecorder.stop() returned null');
      }
      recordingDuration = 0;
    } catch (e) {
      isRecording = false;
      recordingTimer?.cancel();
      recordingDuration = 0;
      print('Error stopping recording: $e');
      emit(UploadVoiceMessageErrorState('Failed to stop recording: $e'));
    }
  }

  Future<void> uploadVoiceMessage({
    required File audioFile,
    required String receiverId,
  }) async {
    if (receiverId.isEmpty) {
      print('Receiver ID is empty');
      return;
    }
    emit(UploadVoiceMessageLoadingState());

    // Use FirebaseAuth UID, or fallback to the loaded model UID
    final String? currentUid = auth.currentUser?.uid ?? model?.uId;

    if (currentUid == null || currentUid.isEmpty) {
      emit(
        UploadVoiceMessageErrorState('User not logged in or session expired'),
      );
      return;
    }

    try {
      final SupabaseClient supabaseClient = Supabase.instance.client;
      final String voicePath =
          'users/$currentUid/voices/voice_${DateTime.now().microsecondsSinceEpoch}.m4a';

      print('Uploading voice to Supabase: $voicePath');
      await supabaseClient.storage
          .from('images')
          .upload(
            voicePath,
            audioFile,
            fileOptions: const FileOptions(contentType: 'audio/x-m4a'),
          );
      final String voiceUrl = supabaseClient.storage
          .from('images')
          .getPublicUrl(voicePath);

      print('Voice uploaded, sending message to: $receiverId');
      sendMassage(massageReceiverId: receiverId, voiceMassage: voiceUrl);
      emit(UploadVoiceMessageSuccessState());
      showToast(text: 'Voice message sent', state: ToastStates.SUCCESS);
    } catch (error) {
      print('Voice upload error details: $error');
      emit(UploadVoiceMessageErrorState('Upload failed: ${error.toString()}'));
    }
  }
}
