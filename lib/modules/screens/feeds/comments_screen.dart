// ignore_for_file: unused_local_variable

import 'dart:io';

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
          body: cubit.model == null
              ? Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    postItemBuilder(
                      index: cubit.index,
                      cubit.posts[cubit.index],
                      context,
                      onTap: () {},
                      userId: cubit.model!.uId.toString(),
                      followingState: 'Follow',
                      postModel: cubit.posts[cubit.index],
                      profileImageUrl: cubit.posts[cubit.index].image
                          ?.toString(),
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
                    if (cubit.replyToComment != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          children: [
                            Text(
                              'Replying to ${cubit.replyToComment!.userName}',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Spacer(),
                            IconButton(
                              onPressed: () {
                                cubit.setReplyTo(null);
                              },
                              icon: Icon(Icons.close, size: 16),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: cubit.commentController,
                            decoration: InputDecoration(
                              hintText: cubit.replyToComment == null
                                  ? 'Write a comment...'
                                  : 'Write a reply...',
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (cubit.replyToComment == null) {
                              cubit.createComment(
                                postId: cubit.posts[cubit.index].postId,
                                commentText: cubit.commentController.text,
                              );
                            } else {
                              cubit.createReply(
                                postId: cubit.posts[cubit.index].postId!,
                                commentId: cubit.replyToComment!.commentId!,
                                replyText: cubit.commentController.text,
                              );
                              cubit.setReplyTo(null);
                            }
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
  }) {
    // Determine the backgroundImage for the CircleAvatar
    var cubit = AppCubit.get(context);
    ImageProvider? commentUserImageProvider;
    if (cubit.model != null) {
      if (cubit.model!.profileImageFile != null &&
          cubit.model!.profileImageFile!.existsSync()) {
        commentUserImageProvider = FileImage(cubit.model!.profileImageFile!);
      } else {
        commentUserImageProvider = customImageProvider(cubit.model!.image);
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
                  backgroundImage: customImageProvider(profileImageUrl),
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
                  child: Icon(
                    postModel?.isLiked == true
                        ? Icons.favorite
                        : Icons.favorite_border_outlined,
                    size: 20,
                    color: postModel?.isLiked == true
                        ? Colors.red
                        : Colors.grey,
                  ),
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
                SizedBox(height: 5),
                Text(
                  comment.commentText.toString(),
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    height: 1.4,
                  ),
                ),
                if (comment.amountOfReplies != null &&
                    comment.amountOfReplies! > 0)
                  InkWell(
                    onTap: () {
                      cubit.getReplies(
                        postId: comment.postId!,
                        commentId: comment.commentId!,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Text(
                        'View ${comment.amountOfReplies} replies',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  ),
                if (cubit.commentReplies[comment.commentId] != null)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) => replyItemBuilder(
                      cubit.commentReplies[comment.commentId]![index],
                      context,
                    ),
                    itemCount: cubit.commentReplies[comment.commentId]!.length,
                  ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.thumb_up_alt_outlined, size: 18),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
              IconButton(
                onPressed: () {
                  cubit.setReplyTo(comment);
                },
                icon: Icon(Icons.chat_bubble_outline, size: 18),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget replyItemBuilder(CommentsModel reply, context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundImage: customImageProvider(reply.userImage),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reply.userName.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  reply.commentText.toString(),
                  style: TextStyle(fontSize: 13, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
