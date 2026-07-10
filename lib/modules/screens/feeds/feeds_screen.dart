import 'dart:io'; // Added for FileImage

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/cubit/app_cubit/app_cubit.dart';
import '../../../config/cubit/app_cubit/app_states.dart';
import '../../../core/components/components.dart';
import '../../../models/posts/posts_model.dart';

class Feeds extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppState>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = AppCubit.get(context);
        // Determine the backgroundImage for the CircleAvatar
        ImageProvider? backgroundImage;
        if (cubit.model != null) {
          if (cubit.model!.profileImageFile != null) {
            backgroundImage = FileImage(cubit.model!.profileImageFile!);
          } else if (cubit.model!.image != null &&
              cubit.model!.image!.toString().isNotEmpty) {
            if (cubit.model!.image!.toString().startsWith('http')) {
              backgroundImage = NetworkImage(cubit.model!.image!.toString());
            } else {
              backgroundImage = FileImage(File(cubit.model!.image!.toString()));
            }
          }
        }

        return SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    cubit.moveBetweenPostsAndMainScreen(context);
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 21,
                        backgroundImage:
                            backgroundImage, // Use the determined background image
                        child: backgroundImage == null
                            ? Icon(
                                Icons.account_circle,
                                size: 42,
                              ) // Fallback icon
                            : null,
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          'Post Something...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                      ),
                      Icon(Icons.image, color: Colors.green),
                      SizedBox(width: 5),
                      Icon(Icons.video_call, color: Colors.red),
                      SizedBox(width: 5),
                      Icon(Icons.ondemand_video),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 5),
              InkWell(
                onTap: () {
                  // navigateTo(context, UsersNearby());
                },
                child: Card(
                  elevation: 10,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  margin: EdgeInsets.all(12.0),
                  child: Stack(
                    alignment: AlignmentDirectional.bottomEnd,
                    children: [
                      Image(
                        image: AssetImage('assets/images/app_card.png'),
                        fit: BoxFit.cover,
                        height: 200,
                        width: double.infinity,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          'Meet New Friends At Budlee',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ConditionalBuilder(
                condition: cubit.posts.isNotEmpty,
                builder: (context) => ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final post = cubit.posts[index];
                    return postItemBuilder(
                      index: index,
                      post,
                      context,
                      onTap: () {},
                      userId: cubit.model!.uId.toString(),
                      followingState: 'Follow',
                      postModel: post,
                      profileImageUrl: post.image?.toString(),
                      likeIcon: cubit.likeIcon,
                      likeIconColor: cubit.likeIconColor,
                    );
                  },
                  separatorBuilder: (context, index) => SizedBox(height: 8),
                  itemCount: cubit.posts.length,
                ),
                fallback: (context) =>
                    Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget postItemBuilder(
    post,
    context, {
    required int index,
    required String userId,
    String? profileImageUrl,
    PostsModel? postModel,
    required String followingState,
    required Function onTap,
    required var likeIcon,
    required var likeIconColor,
  }) {
    // Determine the backgroundImage for the CircleAvatar
    var cubit = AppCubit.get(context);
    ImageProvider? commentUserImageProvider;
    if (cubit.model != null) {
      if (cubit.model!.profileImageFile != null) {
        commentUserImageProvider = FileImage(cubit.model!.profileImageFile!);
      } else if (cubit.model!.image != null &&
          cubit.model!.image!.toString().isNotEmpty) {
        if (cubit.model!.image!.toString().startsWith('http')) {
          commentUserImageProvider = NetworkImage(
            cubit.model!.image!.toString(),
          );
        } else {
          commentUserImageProvider = FileImage(
            File(cubit.model!.image!.toString()),
          );
        }
      }
    }

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 5,
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 21,
                  backgroundImage: profileImageUrl != null
                      ? (profileImageUrl.startsWith('http')
                            ? NetworkImage(profileImageUrl)
                            : FileImage(File(profileImageUrl)) as ImageProvider)
                      : null,
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            postModel?.name?.toString() ??
                                'Unknown User', // Updated
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              height: 1.4,
                            ),
                          ),
                          Icon(
                            Icons.check_circle_sharp,
                            color: Colors.blue,
                            size: 18,
                          ),
                        ],
                      ),
                      Text(
                        'Published At: ${postModel?.dateTime?.toString() ?? 'Unknown Date'}', // Updated
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                if (postModel != null && userId != postModel.uId) // Updated
                  InkWell(
                    onTap: () {
                      if (!cubit.myFriends.any(
                        (element) => element.uId == postModel.uId,
                      )) {
                        cubit.addFriend(postModel.uId);
                      }
                    },
                    child: Row(
                      children: [
                        cubit.myFriends.any(
                              (element) => element.uId == postModel.uId,
                            )
                            ? Icon(
                                Icons.check_circle,
                                size: 20,
                                color: Colors.blueAccent,
                              )
                            : Icon(
                                Icons.add_circle_outline,
                                size: 20,
                                color: Colors.blueAccent,
                              ),
                        Text(
                          cubit.myFriends.any(
                                (element) => element.uId == postModel.uId,
                              )
                              ? 'Friend'
                              : followingState,
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.more_vert, size: 20, color: Colors.black),
                ),
              ],
            ),
            SizedBox(height: 15),
            myDivider(),
            SizedBox(height: 15),
            if (postModel?.text?.isNotEmpty == true) // Updated
              Text(
                postModel!.text!, // Updated (safe due to isNotEmpty check)
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            SizedBox(height: 10),
            if (postModel != null &&
                postModel.postImage != null &&
                postModel.postImage!.isNotEmpty)
              Card(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                elevation: 1,
                margin: EdgeInsets.zero,
                child: Image(
                  image: postModel.postImage!.startsWith('http')
                      ? NetworkImage(postModel.postImage!)
                      : FileImage(File(postModel.postImage!)) as ImageProvider,
                  fit: BoxFit.fitWidth,
                  height: 200,
                  width: double.infinity,
                ),
              ),
            SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '${postModel?.amountOfLikes ?? 0}', // Updated
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    cubit.changeLikeState(
                      postId: postModel!.postId,
                      userId: cubit.model!.uId,
                    );
                  },
                  child: Icon(likeIcon, size: 20, color: likeIconColor),
                ),
                Spacer(),
                Text(
                  '${postModel?.amountOfComments ?? 0}', // Updated
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 10),
                Icon(Icons.mode_comment_outlined, size: 20, color: Colors.grey),
              ],
            ),
            SizedBox(height: 10),
            myDivider(),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 21,
                          backgroundImage: commentUserImageProvider,
                          child: commentUserImageProvider == null
                              ? Icon(
                                  Icons.account_circle,
                                  size: 42,
                                ) // Fallback icon
                              : null,
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            'Write a comment...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      cubit.getPostComments(postModel!.postId.toString());
                      cubit.toCommentScreen(context, index);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
