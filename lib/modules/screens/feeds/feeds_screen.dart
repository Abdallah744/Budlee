import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/cubit/app_cubit/app_bloc.dart';
import '../../../config/cubit/app_cubit/app_event.dart';
import '../../../config/cubit/app_cubit/app_states.dart';
import '../../../core/components/components.dart';
import '../../../models/posts/posts_model.dart';
import '../../../modules/screens/new_posts/new_posts.dart';
import 'comments_screen.dart';

class Feeds extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppBloc, AppState>(
      listener: (context, state) {},
      builder: (context, state) {
        var bloc = AppBloc.get(context);
        ImageProvider? backgroundImage;
        if (bloc.model != null) {
          if (bloc.model!.profileImageFile != null) {
            backgroundImage = FileImage(bloc.model!.profileImageFile!);
          } else {
            backgroundImage = customImageProvider(bloc.model!.image);
          }
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    navigateTo(context, NewPosts());
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 21,
                        backgroundImage: backgroundImage,
                        onBackgroundImageError: backgroundImage != null
                            ? (exception, stackTrace) {}
                            : null,
                        backgroundColor: Colors.grey[200],
                        child: backgroundImage == null
                            ? const Icon(Icons.account_circle, size: 42)
                            : null,
                      ),
                      const SizedBox(width: 15),
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
                      const Icon(Icons.image, color: Colors.green),
                      const SizedBox(width: 5),
                      const Icon(Icons.video_call, color: Colors.red),
                      const SizedBox(width: 5),
                      const Icon(Icons.ondemand_video),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 5),
              InkWell(
                onTap: () {},
                child: Card(
                  elevation: 10,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  margin: const EdgeInsets.all(12.0),
                  child: const Stack(
                    alignment: AlignmentDirectional.bottomEnd,
                    children: [
                      Image(
                        image: AssetImage('assets/images/app_card.png'),
                        fit: BoxFit.cover,
                        height: 200,
                        width: double.infinity,
                      ),
                      Padding(
                        padding: EdgeInsets.all(4.0),
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
                condition: bloc.posts.isNotEmpty && bloc.model != null,
                builder: (context) => ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final post = bloc.posts[index];
                    return postItemBuilder(
                      index: index,
                      post,
                      context,
                      onTap: () {},
                      userId: bloc.model!.uId.toString(),
                      followingState: 'Follow',
                      postModel: post,
                      profileImageUrl: post.image?.toString(),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemCount: bloc.posts.length,
                ),
                fallback: (context) =>
                    const Center(child: CircularProgressIndicator()),
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
    var bloc = AppBloc.get(context);
    ImageProvider? commentUserImageProvider;
    if (bloc.model != null) {
      if (bloc.model!.profileImageFile != null &&
          bloc.model!.profileImageFile!.existsSync()) {
        commentUserImageProvider = FileImage(bloc.model!.profileImageFile!);
      } else {
        commentUserImageProvider = customImageProvider(bloc.model!.image);
      }
    }

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
                          Flexible(
                            child: Text(
                              postModel?.name?.toString() ?? 'Unknown User',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                height: 1.4,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 5),
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
                    onTap: () {
                      if (!bloc.myFriends.any(
                        (element) => element.uId == postModel.uId,
                      )) {
                        bloc.add(AppAddFriendEvent(postModel.uId));
                      }
                    },
                    child: Row(
                      children: [
                        bloc.myFriends.any(
                              (element) => element.uId == postModel.uId,
                            )
                            ? const Icon(
                                Icons.check_circle,
                                size: 20,
                                color: Colors.blueAccent,
                              )
                            : const Icon(
                                Icons.add_circle_outline,
                                size: 20,
                                color: Colors.blueAccent,
                              ),
                        Text(
                          bloc.myFriends.any(
                                (element) => element.uId == postModel.uId,
                              )
                              ? 'Friend'
                              : followingState,
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
                  image: customImageProvider(postModel.postImage),
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
            const SizedBox(height: 10),
            myDivider(),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 21,
                          backgroundImage: commentUserImageProvider,
                          onBackgroundImageError:
                              commentUserImageProvider != null
                              ? (exception, stackTrace) {}
                              : null,
                          backgroundColor: Colors.grey[200],
                          child: commentUserImageProvider == null
                              ? const Icon(Icons.account_circle, size: 42)
                              : null,
                        ),
                        const SizedBox(width: 15),
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
                      bloc.add(
                        AppGetPostCommentsEvent(postModel!.postId.toString()),
                      );
                      navigateTo(context, CommentsScreen());
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
