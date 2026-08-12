import 'dart:async';
import 'dart:io';

import 'package:budlee_app/models/users/friends_model.dart';
import 'package:budlee_app/models/users/user_model.dart';
import 'package:budlee_app/modules/screens/chats/chats.dart';
import 'package:budlee_app/modules/screens/feeds/feeds_screen.dart';
import 'package:budlee_app/modules/screens/friends/friends.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import '../../../modules/screens/settings/settings.dart';
import 'app_event.dart';
import 'app_states.dart';

class AppBloc extends Bloc<AppEvents, AppState> {
  AppBloc() : super(AppInitialStat()) {
    on<AppSearchEvent>((event, emit) {
      searchResult = users.where((element) {
        return element.name!.toLowerCase().contains(event.text.toLowerCase());
      }).toList();
      emit(SearchState());
    });

    on<AppChangeBottomNavBarEvent>((event, emit) {
      if (event.index == 4) {
        emit(SettingsOpenedState());
      } else if (event.index == 3) {
        add(AppGetUsersEvent());
        emit(ChangeBottomNavBarState());
        currentIndex = 3;
      } else {
        currentIndex = event.index;
        emit(ChangeBottomNavBarState());
      }
    });

    on<AppGetCoverImageEvent>((event, emit) async {
      final pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        emit(UploadCoverImageLoadingState());
        File imageFile = File(pickedFile.path);

        String? imageUrl = await uploadToSubabase(
          imagefile: imageFile,
          emit: emit,
        );

        if (imageUrl != null) {
          if (model!.imagesOfGallery == null) {
            model!.imagesOfGallery = [];
          }

          List<String> galleryPaths = model!.imagesOfGallery!
              .map((file) => file.path)
              .toList();
          galleryPaths.add(imageUrl);

          try {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(model!.uId)
                .update({'coverImage': imageUrl, 'gallery': galleryPaths});
            add(AppGetUserDataEvent(model!.uId));
            emit(UploadCoverImageSuccessState());
          } catch (error) {
            emit(UploadCoverImageErrorState(error.toString()));
          }
        } else {
          emit(UploadCoverImageErrorState('Failed to upload image'));
        }
      } else {
        emit(UploadCoverImageErrorState('No image selected'));
      }
    });

    on<AppGetProfileImageEvent>((event, emit) async {
      final pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        emit(UploadProfileImageLoadingState());
        File imageFile = File(pickedFile.path);

        String? imageUrl = await uploadToSubabase(
          imagefile: imageFile,
          emit: emit,
        );

        if (imageUrl != null) {
          if (model!.imagesOfGallery == null) {
            model!.imagesOfGallery = [];
          }

          List<String> galleryPaths = model!.imagesOfGallery!
              .map((file) => file.path)
              .toList();
          galleryPaths.add(imageUrl);

          try {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(model!.uId)
                .update({'avatar': imageUrl, 'gallery': galleryPaths});
            updateUserPostsData(avatar: imageUrl);
            add(AppGetUserDataEvent(model!.uId));
            emit(UploadProfileImageSuccessState());
          } catch (error) {
            emit(UploadProfileImageErrorState(error.toString()));
          }
        } else {
          emit(UploadProfileImageErrorState('Failed to upload image'));
        }
      } else {
        emit(UploadProfileImageErrorState('No image selected'));
      }
    });

    on<AppGetPostsImageEvent>((event, emit) async {
      final pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        emit(UploadPostsImageLoadingState());
        postImageFile = File(pickedFile.path);

        String? imageUrl = await uploadToSubabase(
          imagefile: postImageFile!,
          emit: emit,
        );

        if (imageUrl != null) {
          postImageUrl = imageUrl;
          if (model!.imagesOfGallery == null) {
            model!.imagesOfGallery = [];
          }

          List<String> galleryPaths = model!.imagesOfGallery!
              .map((file) => file.path)
              .toList();
          galleryPaths.add(imageUrl);

          try {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(model!.uId)
                .update({'gallery': galleryPaths});
            add(AppGetUserDataEvent(model!.uId));
            emit(UploadPostsImageSuccessState());
            emit(UploadToGallerySuccessState());
          } catch (error) {
            emit(UploadToGalleryErrorState(error.toString()));
            emit(UploadPostsImageErrorState(error.toString()));
          }
        } else {
          emit(UploadPostsImageErrorState('Failed to upload image'));
        }
      } else {
        emit(UploadPostsImageErrorState('No image selected'));
      }
    });

    on<AppLogOutEvent>((event, emit) async {
      emit(LogOutLoadingState());
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(model!.uId)
            .update({'isOnline': false});
        await FirebaseAuth.instance.signOut();
        model = null;
        emit(LogOutSuccessState());
      } catch (error) {
      }
    });

    on<AppUpdateUserDataEvent>((event, emit) async {
      emit(UpdateUserDataLoadingState());
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(model!.uId)
            .update({
              'name': event.name ?? model!.name,
              'bio': event.bio ?? model!.bio,
              'avatar': event.avatar ?? model!.image,
              'birthday': event.date ?? model!.birthday,
              'phone': event.phone ?? model!.phone,
              'coverImage': event.coverImage ?? model!.coverImage,
            });
        updateUserPostsData(
          name: event.name ?? model!.name,
          avatar: event.avatar ?? model!.image,
        );
        add(AppGetUserDataEvent(model!.uId));
        emit(UpdateUserDataSuccessState());
      } catch (error) {
        emit(UpdateUserDataErrorState(error.toString()));
      }
    });

    on<AppRemovePostImageEvent>((event, emit) {
      postImageFile = null;
      postImageUrl = null;
      emit(RemovePostImageState());
    });

    on<AppCreatePostEvent>((event, emit) async {
      emit(CreatePostLoadingState());

      DocumentReference newPostRef = FirebaseFirestore.instance
          .collection('posts')
          .doc();

      PostsModel newPostModel = PostsModel(
        name: model!.name,
        image: event.profileImage,
        uId: model!.uId,
        amountOfLikes: 0,
        amountOfComments: 0,
        isLiked: false,
        amountOfShares: 0,
        dateTime: event.dateTime,
        text: event.text,
        postImage: event.postImage ?? '',
        postId: newPostRef.id,
      );
      try {
        await newPostRef.set(newPostModel.toMap());
        add(AppGetPostsEvent());
        postImageFile = null;
        postImageUrl = null;
        emit(CreatePostSuccessState());
      } catch (error) {
        emit(CreatePostErrorState(error.toString()));
      }
    });

    on<AppGetPostsEvent>((event, emit) async {
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
                    });
              }
            }
            add(InternalUpdateUIEvent());
          });
    });

    on<InternalUpdateUIEvent>((event, emit) {
      emit(GetPostsSuccessState());
    });

    on<AppGetPostCommentsEvent>((event, emit) async {
      emit(GetPostCommentsLoadingState());
      try {
        final value = await FirebaseFirestore.instance
            .collection('posts')
            .doc(event.postId)
            .collection('comments')
            .get();
        postComments.clear();
        for (var element in value.docs) {
          var comment = CommentsModel.fromJson(element.data());
          comment.commentId = element.id;
          postComments.add(comment);
        }
        emit(GetPostCommentsSuccessState());
      } catch (error) {
        emit(GetPostCommentsErrorState(error.toString()));
      }
    });

    on<AppPickImageEvent>((event, emit) async {
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
    });

    on<AppUpdateDataAndGetUrlEvent>((event, emit) async {
      final User? current = auth.currentUser;
      if (current == null) {
        emit(ProfileError('User data not available'));
        return;
      }
      final Map<String, dynamic> data = {};
      if (event.name.trim().isNotEmpty) {
        data['name'] = event.name.trim();
      }
      final String? imageUrl = await uploadToSubabase(
        imagefile: event.imageFile,
        emit: emit,
      );
      if (imageUrl != null) {
        data[event.type] = imageUrl;
      }

      if (data.isEmpty) {
        emit(ProfileError('No data to update'));
        return;
      }
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(current.uid)
            .update(data);
        updateUserPostsData(name: data['name'], avatar: data['avatar']);
        add(AppGetUserDataEvent(current.uid));
        emit(UpdateUserDataSuccessState());
      } catch (error) {
        emit(UpdateUserDataErrorState(error.toString()));
      }
    });

    on<AppUploadGalleryImageEvent>((event, emit) async {
      final XFile? pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile == null) {
        emit(UploadToGalleryErrorState('No image selected'));
        return;
      }
      File imageFile = File(pickedFile.path);

      final User? current = auth.currentUser;
      if (current == null) {
        emit(UploadToGalleryErrorState('User data not available'));
        return;
      }

      final String? imageUrl = await uploadToSubabase(
        imagefile: imageFile,
        emit: emit,
      );
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

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(model!.uId)
            .update({'gallery': galleryPaths});
        add(AppGetUserDataEvent(model!.uId));
        emit(UploadToGallerySuccessState());
      } catch (error) {
        emit(UploadToGalleryErrorState(error.toString()));
      }
    });

    on<AppGetUsersEvent>((event, emit) async {
      emit(GetAllUsersLoadingState());
      try {
        final value = await FirebaseFirestore.instance
            .collection('users')
            .get();
        users = [];
        for (var element in value.docs) {
          if (element.id != (model?.uId ?? uId)) {
            users.add(userModel.fromJson(element.data()));
          }
        }
        String? currentUid = model?.uId ?? uId;
        if (currentUid != null && currentUid.isNotEmpty) {
          add(AppGetFriendsEvent());
          add(AppGetAllLastMessagesEvent());
        }
        emit(GetAllUsersSuccessState());
      } catch (error) {
        emit(GetAllUsersErrorState(error.toString()));
      }
    });

    on<AppChangeLikeStateEvent>((event, emit) async {
      final postIndex = posts.indexWhere((p) => p.postId == event.postId);
      if (postIndex == -1) return;

      final post = posts[postIndex];
      post.isLiked = !(post.isLiked ?? false);

      if (post.isLiked!) {
        post.amountOfLikes = (post.amountOfLikes ?? 0) + 1;
        try {
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(event.postId)
              .collection('likes')
              .doc(event.userId)
              .set({'like': true});
          emit(LikeChangeState());
        } catch (error) {
          print(error.toString());
        }
      } else {
        post.amountOfLikes = (post.amountOfLikes ?? 0) - 1;
        try {
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(event.postId)
              .collection('likes')
              .doc(event.userId)
              .delete();
          emit(LikeChangeState());
        } catch (error) {
          print(error.toString());
        }
      }

      emit(LikeChangeState());

      FirebaseFirestore.instance.collection('posts').doc(event.postId).update({
        'amountOfLikes': post.amountOfLikes,
      });
    });

    on<AppCreateCommentEvent>((event, emit) async {
      if (event.commentText == null || event.commentText!.trim().isEmpty)
        return;
      emit(CreateCommentLoadingState());

      DocumentReference commentRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(event.postId)
          .collection('comments')
          .doc();

      CommentsModel newComment = CommentsModel(
        userId: model!.uId,
        userName: model!.name,
        userImage: model!.image,
        postId: event.postId,
        commentText: event.commentText,
        amountOfLikes: 0,
        amountOfReplies: 0,
        isLiked: false,
        commentId: commentRef.id,
      );

      try {
        await commentRef.set(newComment.toMap());
        postComments.add(newComment);

        await FirebaseFirestore.instance
            .collection('posts')
            .doc(event.postId)
            .update({'amountOfComments': FieldValue.increment(1)});

        emit(CommentChangeState());
        emit(CreateCommentSuccessState());
      } catch (error) {
        emit(CreateCommentErrorState(error.toString()));
      }
    });

    on<AppSetReplyToEvent>((event, emit) {
      replyToComment = event.comment;
      emit(ChangeReplyToState());
    });

    on<AppCreateReplyEvent>((event, emit) async {
      if (event.replyText.trim().isEmpty) return;
      emit(CreateReplyLoadingState());

      DocumentReference replyRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(event.postId)
          .collection('comments')
          .doc(event.commentId)
          .collection('replies')
          .doc();

      CommentsModel newReply = CommentsModel(
        userId: model!.uId,
        userName: model!.name,
        userImage: model!.image,
        postId: event.postId,
        commentText: event.replyText,
        amountOfLikes: 0,
        amountOfReplies: 0,
        isLiked: false,
        commentId: replyRef.id,
      );

      try {
        await replyRef.set(newReply.toMap());
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(event.postId)
            .collection('comments')
            .doc(event.commentId)
            .update({'amountOfReplies': FieldValue.increment(1)});

        if (commentReplies[event.commentId] == null) {
          commentReplies[event.commentId] = [];
        }
        commentReplies[event.commentId]!.add(newReply);

        emit(CreateReplySuccessState());
      } catch (error) {
        emit(CreateReplyErrorState(error.toString()));
      }
    });

    on<AppGetRepliesEvent>((event, emit) async {
      emit(GetRepliesLoadingState());
      try {
        final value = await FirebaseFirestore.instance
            .collection('posts')
            .doc(event.postId)
            .collection('comments')
            .doc(event.commentId)
            .collection('replies')
            .get();
        commentReplies[event.commentId] = [];
        for (var element in value.docs) {
          var reply = CommentsModel.fromJson(element.data());
          reply.commentId = element.id;
          commentReplies[event.commentId]!.add(reply);
        }
        emit(GetRepliesSuccessState());
      } catch (error) {
        emit(GetRepliesErrorState(error.toString()));
      }
    });

    on<AppGetUserDataEvent>((event, emit) async {
      if (event.uId == null || event.uId!.isEmpty) {
        emit(GetUserDataErrorState("User ID is null or empty"));
        return;
      }
      emit(GetUserDataLoadingState());

      try {
        final value = await FirebaseFirestore.instance
            .collection('users')
            .doc(event.uId)
            .get();
        if (value.exists && value.data() != null) {
          model = userModel.fromJson(value.data()!);
          emit(GetUserDataSuccessState());
        } else {
          emit(
            GetUserDataErrorState("User data not found for ID: ${event.uId}"),
          );
        }
      } catch (error) {
        emit(GetUserDataErrorState(error.toString()));
      }
    });

    on<AppGetFriendsEvent>((event, emit) async {
      String? currentUid = model?.uId ?? uId;
      if (currentUid == null || currentUid.isEmpty) {
        emit(GetFriendsErrorState("User ID is null or empty"));
        return;
      }
      emit(GetFriendsLoadingState());
      try {
        final value = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUid)
            .collection('friends')
            .get();
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
        await Future.wait(futures);
        emit(GetFriendsSuccessState());
      } catch (error) {
        emit(GetFriendsErrorState(error.toString()));
      }
    });

    on<AppAddFriendEvent>((event, emit) async {
      String? currentUid = model?.uId ?? uId;
      if (currentUid == null || currentUid.isEmpty) return;

      if (myFriends.any((element) => element.uId == event.friendId)) return;

      emit(AddFriendLoadingState());
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUid)
            .collection('friends')
            .doc(event.friendId)
            .set({'friendId': event.friendId});

        final friend = users.firstWhere(
          (element) => element.uId == event.friendId,
          orElse: () => userModel(isEmailVerified: false),
        );

        if (!myFriends.contains(friend)) {
          if (friend.uId != null) {
            myFriends.add(friend);
          }
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(event.friendId)
            .collection('friends')
            .doc(currentUid)
            .set({'friendId': currentUid});

        emit(AddFriendSuccessState());
      } catch (error) {
        emit(AddFriendErrorState(error.toString()));
      }
    });

    on<AppRemoveFriendEvent>((event, emit) async {
      String? currentUid = model?.uId ?? uId;
      if (currentUid == null || currentUid.isEmpty) return;

      emit(RemoveFriendLoadingState());
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUid)
            .collection('friends')
            .doc(event.friendId)
            .delete();

        users.forEach((element) {
          if (element.uId == event.friendId) {
            myFriends.remove(element);
            FirebaseFirestore.instance
                .collection('users')
                .doc(event.friendId)
                .collection('friends')
                .doc(currentUid)
                .delete();
          }
        });
        isFriend = false;
        emit(RemoveFriendSuccessState());
      } catch (error) {
        emit(RemoveFriendErrorState(error.toString()));
      }
    });

    on<AppSendMassageEvent>((event, emit) async {
      bool isTextEmpty =
          event.massageText == null || event.massageText!.trim().isEmpty;
      bool isVoiceEmpty =
          event.voiceMassage == null || event.voiceMassage!.isEmpty;

      if (isTextEmpty && isVoiceEmpty) return;

      MassageModel massageModel = MassageModel(
        massageText: event.massageText,
        massageSenderId: model!.uId,
        massageReceiverId: event.massageReceiverId,
        massageDate: DateTime.now().toString(),
        voiceMassage: event.voiceMassage,
      );

      massages.add(massageModel);
      emit(SendMessageSuccessState());

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(model!.uId)
            .collection('chats')
            .doc(event.massageReceiverId)
            .collection('messages')
            .add(massageModel.toMap());

        await FirebaseFirestore.instance
            .collection('users')
            .doc(event.massageReceiverId)
            .collection('chats')
            .doc(model!.uId)
            .collection('messages')
            .add(massageModel.toMap());
      } catch (error) {
        emit(SendMessageErrorState(error.toString()));
      }
    });

    on<AppGetMassagesEvent>((event, emit) async {
      String? currentUid = model?.uId ?? uId;
      if (currentUid == null || currentUid.isEmpty) {
        emit(GetMessagesErrorState("User ID is null or empty"));
        return;
      }
      emit(GetMessagesLoadingState());

      messagesSubscription?.cancel();

      messagesSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUid)
          .collection('chats')
          .doc(event.massageReceiverId)
          .collection('messages')
          .orderBy('massageDate')
          .snapshots()
          .listen((eventSnap) {
            massages = [];
            eventSnap.docs.forEach((element) {
              massages.add(MassageModel.fromJson(element.data()));
            });
            if (massages.isNotEmpty && event.massageReceiverId != null) {
              lastMessagesMap[event.massageReceiverId!] = massages.last;
            }
            add(InternalUpdateUIEvent());
          });
    });

    on<AppGetAllLastMessagesEvent>((event, emit) async {
      String? currentUid = model?.uId ?? uId;
      if (currentUid == null || currentUid.isEmpty) return;

      for (var user in users) {
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
                add(InternalUpdateUIEvent());
              }
            });
      }
    });

    on<AppStartRecordingEvent>((event, emit) async {
      if (isRecording) return;
      try {
        if (await audioRecorder.hasPermission()) {
          final Directory appDocDir = await getApplicationDocumentsDirectory();
          final String path =
              '${appDocDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

          const config = RecordConfig();

          await audioRecorder.start(config, path: path);
          isRecording = true;
          audioPath = path;
          recordingDuration = 0;
          recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
            recordingDuration++;
            add(InternalUpdateUIEvent());
          });
          emit(StartRecordingState());
        } else {
          emit(
            UploadVoiceMessageErrorState('Audio recording permission denied'),
          );
        }
      } catch (e) {
        emit(UploadVoiceMessageErrorState('Failed to start recording: $e'));
      }
    });

    on<AppStopRecordingEvent>((event, emit) async {
      if (!isRecording) return;
      try {
        final path = await audioRecorder.stop();
        isRecording = false;
        recordingTimer?.cancel();
        emit(StopRecordingState());
        if (path != null) {
          File audioFile = File(path);
          if (await audioFile.exists()) {
            add(
              AppUploadVoiceMessageEvent(
                audioFile: audioFile,
                receiverId: event.receiverId,
              ),
            );
          } else {
            showToast(
              text: 'Error: Recording file not found',
              state: ToastStates.ERROR,
            );
          }
        }
        recordingDuration = 0;
      } catch (e) {
        isRecording = false;
        recordingTimer?.cancel();
        recordingDuration = 0;
        emit(UploadVoiceMessageErrorState('Failed to stop recording: $e'));
      }
    });

    on<AppUploadVoiceMessageEvent>((event, emit) async {
      emit(UploadVoiceMessageLoadingState());

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

        await supabaseClient.storage
            .from('images')
            .upload(
              voicePath,
              event.audioFile,
              fileOptions: const FileOptions(contentType: 'audio/x-m4a'),
            );
        final String voiceUrl = supabaseClient.storage
            .from('images')
            .getPublicUrl(voicePath);

        add(
          AppSendMassageEvent(
            massageReceiverId: event.receiverId,
            voiceMassage: voiceUrl,
          ),
        );
        emit(UploadVoiceMessageSuccessState());
        showToast(text: 'Voice message sent', state: ToastStates.SUCCESS);
      } catch (error) {
        emit(
          UploadVoiceMessageErrorState('Upload failed: ${error.toString()}'),
        );
      }
    });
  }

  static AppBloc get(context) => BlocProvider.of(context);

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

  StreamSubscription? messagesSubscription;

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
        });
  }

  Future<String?> uploadToSubabase({
    required File imagefile,
    required Emitter<AppState> emit,
  }) async {
    emit(UploadToSupabaseLoadingState());
    final User? current = auth.currentUser;
    if (current == null) return null;

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
      emit(UploadToSupabaseErrorState(error.toString()));
      return null;
    }
  }

  int myPostsCalculation() {
    myPosts = posts.where((element) => element.uId == model?.uId).toList();
    return myPosts.length;
  }
}

class InternalUpdateUIEvent extends AppEvents {}
