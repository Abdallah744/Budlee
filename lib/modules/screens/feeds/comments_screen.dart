import 'dart:io';

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/cubit/app_cubit/app_bloc.dart';
import '../../../config/cubit/app_cubit/app_event.dart';
import '../../../config/cubit/app_cubit/app_states.dart';
import '../../../core/components/components.dart';
import '../../../models/comments/comments_model.dart';
import '../../../models/posts/posts_model.dart';

class CommentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppBloc, AppState>(
      listener: (context, state) {
        if (state is CreateCommentSuccessState) {
          showToast(
            text: 'Comment created successfully',
            state: ToastStates.SUCCESS,
          );
        }
      },
      builder: (context, state) {
        var bloc = AppBloc.get(context);
        return Scaffold(
          appBar: AppBar(),
          body: bloc.model == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    postItemBuilder(
                      index: bloc.index,
                      bloc.posts[bloc.index],
                      context,
                      onTap: () {},
                      userId: bloc.model!.uId.toString(),
                      followingState: 'Follow',
                      postModel: bloc.posts[bloc.index],
                      profileImageUrl: bloc.posts[bloc.index].image?.toString(),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConditionalBuilder(
                          condition: bloc.postComments.isNotEmpty,
                          builder: (context) => ListView.separated(
                            itemBuilder: (context, index) => commentItemBuilder(
                              bloc.postComments[index],
                              context,
                              index: index,
                            ),
                            separatorBuilder: (context, index) => myDivider(),
                            itemCount: bloc.postComments.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                          ),
                          fallback: (context) =>
                              const Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    ),
                    if (bloc.replyToComment != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          children: [
                            Text(
                              'Replying to ${bloc.replyToComment!.userName}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                bloc.add(AppSetReplyToEvent(null));
                              },
                              icon: const Icon(Icons.close, size: 16),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: bloc.commentController,
                            decoration: InputDecoration(
                              hintText: bloc.replyToComment == null
                                  ? 'Write a comment...'
                                  : 'Write a reply...',
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (bloc.replyToComment == null) {
                              bloc.add(
                                AppCreateCommentEvent(
                                  postId: bloc.posts[bloc.index].postId,
                                  commentText: bloc.commentController.text,
                                ),
                              );
                            } else {
                              bloc.add(
                                AppCreateReplyEvent(
                                  postId: bloc.posts[bloc.index].postId!,
                                  commentId: bloc.replyToComment!.commentId!,
                                  replyText: bloc.commentController.text,
                                ),
                              );
                              bloc.add(AppSetReplyToEvent(null));
                            }
                            bloc.commentController.clear();
                          },
                          icon: const Icon(Icons.send),
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
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 5,
      margin: const EdgeInsets.all(8.0),
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
                  onBackgroundImageError:
                      customImageProvider(profileImageUrl) != null
                      ? (exception, stackTrace) {}
                      : null,
                  backgroundColor: Colors.grey[200],
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            postModel?.name?.toString() ?? 'Unknown User',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              height: 1.4,
                            ),
                          ),
                          const Icon(
                            Icons.check_circle_sharp,
                            color: Colors.blue,
                            size: 18,
                          ),
                        ],
                      ),
                      Text(
                        'Published At: ${postModel?.dateTime?.toString() ?? 'Unknown Date'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                if (postModel != null && userId != postModel.uId)
                  InkWell(
                    onTap: () {},
                    child: Row(
                      children: [
                        const Icon(
                          Icons.add,
                          size: 20,
                          color: Colors.blueAccent,
                        ),
                        Text(
                          followingState,
                          style: const TextStyle(
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
                  icon: const Icon(
                    Icons.more_vert,
                    size: 20,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            myDivider(),
            const SizedBox(height: 15),
            if (postModel?.text?.isNotEmpty == true)
              Text(
                postModel!.text!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 10),
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
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    );
                  },
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '${postModel?.amountOfLikes ?? 0}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    var bloc = AppBloc.get(context);
                    bloc.add(
                      AppChangeLikeStateEvent(
                        postId: postModel!.postId,
                        userId: bloc.model!.uId,
                      ),
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
                const Spacer(),
                Text(
                  '${postModel?.amountOfComments ?? 0}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.mode_comment_outlined,
                  size: 20,
                  color: Colors.grey,
                ),
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
    var bloc = AppBloc.get(context);
    comment = bloc.postComments[index];
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 21,
            backgroundImage: comment.userImage != null
                ? (comment.userImage!.startsWith('http')
                      ? NetworkImage(comment.userImage.toString())
                      : FileImage(File(comment.userImage.toString())))
                : null,
            onBackgroundImageError: comment.userImage != null
                ? (exception, stackTrace) {}
                : null,
            backgroundColor: Colors.grey[200],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.userName.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  comment.commentText.toString(),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    height: 1.4,
                  ),
                ),
                if (comment.amountOfReplies != null &&
                    comment.amountOfReplies! > 0)
                  InkWell(
                    onTap: () {
                      bloc.add(
                        AppGetRepliesEvent(
                          postId: comment.postId!,
                          commentId: comment.commentId!,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Text(
                        'View ${comment.amountOfReplies} replies',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                if (bloc.commentReplies[comment.commentId] != null)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) => replyItemBuilder(
                      bloc.commentReplies[comment.commentId]![index],
                      context,
                    ),
                    itemCount: bloc.commentReplies[comment.commentId]!.length,
                  ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.thumb_up_alt_outlined, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              IconButton(
                onPressed: () {
                  bloc.add(AppSetReplyToEvent(comment));
                },
                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
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
            onBackgroundImageError: customImageProvider(reply.userImage) != null
                ? (exception, stackTrace) {}
                : null,
            backgroundColor: Colors.grey[200],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reply.userName.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  reply.commentText.toString(),
                  style: const TextStyle(fontSize: 13, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
