import 'dart:io';

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';

import '../../../config/cubit/app_cubit/app_cubit.dart';
import '../../../config/cubit/app_cubit/app_states.dart';
import '../../../core/components/components.dart';
import '../../../models/comments/comments_model.dart';
import '../../../models/posts/posts_model.dart';

class CommentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppState>(
      listener: (context, state) {
        if (state is CreateCommentSuccessState) {
          showToast(
            text: 'Comment created successfully',
            state: ToastStates.SUCCESS,
          );
        }
      },
      builder: (context, state) {
        var cubit = AppCubit.get(context);
        return Scaffold(
          appBar: AppBar(),
          body: Column(
            children: [
              postItemBuilder(
                index: cubit.index,
                post,
                context,
                onTap: () {},
                userId: cubit.model!.uId.toString(),
                followingState: 'Follow',
                postModel: cubit.posts[cubit.index],
                profileImageUrl: cubit.posts[cubit.index].image?.toString(),
                likeIcon: cubit.likeIcon,
                likeIconColor: cubit.likeIconColor,
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: ConditionalBuilder(
                    condition: cubit.postComments.isNotEmpty,
                    builder: (context) => ListView.separated(
                      itemBuilder: (context, index) => commentItemBuilder(
                        cubit.postComments[index],
                        context,
                        index: index,
                      ),
                      separatorBuilder: (context, index) => myDivider(),
                      itemCount: cubit.postComments.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                    ),
                    fallback: (context) =>
                        Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: cubit.commentController,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // cubit.getPostComments(cubit.posts[cubit.index].postId!);
                      cubit.createComment(
                        postId: cubit.posts[cubit.index].postId,
                        commentText: cubit.commentController.text,
                      );
                      cubit.changeCommentState();
                      cubit.commentController.clear();
                    },
                    icon: Icon(Icons.send),
                  ),
                ],
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
    if (cubit.model != null) {
      if (cubit.model!.profileImageFile != null) {
      } else if (cubit.model!.image != null &&
          cubit.model!.image!.toString().isNotEmpty) {
        if (cubit.model!.image!.toString().startsWith('http')) {
        } else {}
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
                    onTap: () {},
                    child: Row(
                      children: [
                        Icon(Icons.add, size: 20, color: Colors.blueAccent),
                        Text(
                          followingState,
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize:
                                14, // Restored missing attribute from original context
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
                  image: FileImage(File(postModel.postImage!)),
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
          ],
        ),
      ),
    );
  }

  Widget commentItemBuilder(
    CommentsModel comment,
    context, {
    required int index,
  }) {
    var cubit = AppCubit.get(context);
    comment = cubit.postComments[index];
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 21,
            backgroundImage: comment.userImage != null
                ? (comment.userImage!.startsWith('http')
                      ? NetworkImage(comment.userImage.toString())
                      : FileImage(
                          File(comment.userImage.toString()),
                        ) /*as ImageProvider*/ )
                : null,
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.userName.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  comment.commentText.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.thumb_up_alt_outlined),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.chat_bubble_outline),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
