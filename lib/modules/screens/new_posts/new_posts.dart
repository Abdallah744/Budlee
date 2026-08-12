import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/cubit/app_cubit/app_bloc.dart';
import '../../../config/cubit/app_cubit/app_event.dart';
import '../../../config/cubit/app_cubit/app_states.dart';
import '../../../core/components/components.dart';

class NewPosts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppBloc, AppState>(
      listener: (context, state) {
        if (state is CreatePostSuccessState) {
          showToast(
            text: 'Post Created Successfully',
            state: ToastStates.SUCCESS,
          );
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        var bloc = AppBloc.get(context);

        const double avatarDiameter = 42.0;
        const Icon fallbackIcon = Icon(
          Icons.account_circle,
          size: avatarDiameter,
        );
        Widget avatarContentWidget;

        if (bloc.model != null) {
          if (bloc.model!.profileImageFile != null) {
            final imageFile = bloc.model!.profileImageFile!;
            avatarContentWidget = Image.file(
              imageFile,
              width: avatarDiameter,
              height: avatarDiameter,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return fallbackIcon;
              },
            );
          } else if (bloc.model!.image != null &&
              bloc.model!.image!.toString().isNotEmpty) {
            final imagePathOrUrl = bloc.model!.image!.toString();
            if (imagePathOrUrl.startsWith('http')) {
              avatarContentWidget = Image.network(
                imagePathOrUrl,
                width: avatarDiameter,
                height: avatarDiameter,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return fallbackIcon;
                },
              );
            } else {
              final localImageFile = File(imagePathOrUrl);
              avatarContentWidget = Image.file(
                localImageFile,
                width: avatarDiameter,
                height: avatarDiameter,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return fallbackIcon;
                },
              );
            }
          } else {
            avatarContentWidget = fallbackIcon;
          }
        } else {
          avatarContentWidget = fallbackIcon;
        }

        return Scaffold(
          appBar: defaultAppBar(
            title: 'Create New Post',
            context: context,
            actions: [
              TextButton(
                onPressed: () {
                  bloc.add(
                    AppCreatePostEvent(
                      postImage: bloc.postImageUrl ?? '',
                      profileImage: bloc.model?.image ?? '',
                      dateTime: DateTime.now().toString(),
                      text: bloc.postTextController.text,
                    ),
                  );
                  bloc.postTextController.clear();
                },
                child: const Text(
                  'Post',
                  style: TextStyle(color: Colors.blue, fontSize: 18),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                if (state is CreatePostLoadingState)
                  const LinearProgressIndicator(),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 21,
                      backgroundColor: Colors.grey[200],
                      child: ClipOval(
                        child: SizedBox(
                          width: avatarDiameter,
                          height: avatarDiameter,
                          child: avatarContentWidget,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              bloc.model?.name ?? "User Name",
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
                        const Text(
                          'Public',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: TextFormField(
                    controller: bloc.postTextController,
                    decoration: const InputDecoration(
                      hintText: 'What\'s on your mind?',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (bloc.postImageFile != null)
                  SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: Stack(
                      alignment: AlignmentDirectional.topEnd,
                      children: [
                        FutureBuilder<bool>(
                          future: bloc.postImageFile!.exists(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasData && snapshot.data == true) {
                                return Container(
                                  height: 250,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(6),
                                      topRight: Radius.circular(6),
                                    ),
                                    image: DecorationImage(
                                      image: FileImage(bloc.postImageFile!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              } else {
                                return Container(
                                  height: 250,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(6),
                                      topRight: Radius.circular(6),
                                    ),
                                    color: Colors.grey[200],
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 50,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                );
                              }
                            } else {
                              return Container(
                                height: 250,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(6),
                                    topRight: Radius.circular(6),
                                  ),
                                  color: Colors.grey[200],
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                          },
                        ),
                        IconButton(
                          onPressed: () {
                            bloc.add(AppRemovePostImageEvent());
                          },
                          icon: Icon(
                            Icons.close_outlined,
                            color: Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                if (state is UploadPostsImageLoadingState)
                  const LinearProgressIndicator(),
                Row(
                  children: [
                    const SizedBox(width: 35),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          bloc.add(AppGetPostsImageEvent());
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.image, color: Colors.blue, size: 18),
                            SizedBox(width: 5),
                            Text(
                              'add image',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          bloc.add(AppGetPostsImageEvent());
                        },
                        child: const Row(
                          children: [
                            Icon(
                              Icons.video_collection_outlined,
                              color: Colors.red,
                              size: 18,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'add video',
                              style: TextStyle(color: Colors.red, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
