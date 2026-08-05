import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/cubit/app_cubit/app_cubit.dart';
import '../../../config/cubit/app_cubit/app_states.dart';
import '../../../core/components/components.dart';

class NewPosts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppState>(
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
        var cubit = AppCubit.get(context);

        const double avatarDiameter = 42.0;
        const Icon fallbackIcon = Icon(
          Icons.account_circle,
          size: avatarDiameter,
        );
        Widget avatarContentWidget;

        if (cubit.model != null) {
          // Case 1: cubit.model.profileImageFile (File object)
          if (cubit.model!.profileImageFile != null) {
            final imageFile = cubit.model!.profileImageFile!;
            avatarContentWidget = Image.file(
              imageFile,
              width: avatarDiameter,
              height: avatarDiameter,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Optionally log error: print('Error loading profileImageFile ${imageFile.path}: $error');
                return fallbackIcon;
              },
            );
          }
          // Case 2: cubit.model.image (String: URL or local path)
          else if (cubit.model!.image != null &&
              cubit.model!.image!.toString().isNotEmpty) {
            final imagePathOrUrl = cubit.model!.image!.toString();
            if (imagePathOrUrl.startsWith('http')) {
              avatarContentWidget = Image.network(
                imagePathOrUrl,
                width: avatarDiameter,
                height: avatarDiameter,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Optionally log error: print('Error loading network image $imagePathOrUrl: $error');
                  return fallbackIcon;
                },
              );
            } else {
              // Local file path as a String
              final localImageFile = File(imagePathOrUrl);
              avatarContentWidget = Image.file(
                localImageFile,
                width: avatarDiameter,
                height: avatarDiameter,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Optionally log error: print('Error loading local image file $localImageFile: $error');
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
                  cubit.createPost(
                    postImage: cubit.postImageUrl ?? '',
                    profileImage: cubit.model?.image ?? '',
                    dateTime: DateTime.now().toString(),
                    text: cubit.postTextController.text,
                  );
                  cubit.postTextController.clear();
                },
                child: Text(
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
                if (state is CreatePostLoadingState) LinearProgressIndicator(),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 21, // This means diameter is 42
                      backgroundColor:
                          Colors.grey[200], // Placeholder background
                      child: ClipOval(
                        child: SizedBox(
                          width: avatarDiameter,
                          height: avatarDiameter,
                          child: avatarContentWidget,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${cubit.model?.name ?? "User Name"}',
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
                          'Public', // Placeholder
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
                SizedBox(height: 20),
                Expanded(
                  child: TextFormField(
                    controller: cubit.postTextController,
                    decoration: InputDecoration(
                      hintText: 'What\'s on your mind?',
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      return null;
                    },
                  ),
                ),
                if (cubit.postImageFile != null)
                  Container(
                    height: 250,
                    width: double.infinity,
                    child: Stack(
                      alignment: AlignmentDirectional.topEnd,
                      children: [
                        FutureBuilder<bool>(
                          future: cubit.postImageFile!
                              .exists(), // Asynchronously check if file exists
                          builder:
                              (
                                BuildContext context,
                                AsyncSnapshot<bool> snapshot,
                              ) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  if (snapshot.hasData &&
                                      snapshot.data == true) {
                                    // File exists, display it
                                    return Container(
                                      height: 250,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(6),
                                          topRight: Radius.circular(6),
                                        ),
                                        image: DecorationImage(
                                          image: FileImage(
                                            cubit.postImageFile!,
                                          ),
                                          fit: BoxFit.cover,
                                          onError: (exception, stackTrace) {},
                                        ),
                                      ),
                                    );
                                  } else {
                                    // File does not exist or error in checking
                                    return Container(
                                      height: 250,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(6),
                                          topRight: Radius.circular(6),
                                        ),
                                        color: Colors
                                            .grey[200], // Placeholder color
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
                                  // Still checking, show a loader
                                  return Container(
                                    height: 250,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(6),
                                        topRight: Radius.circular(6),
                                      ),
                                      color: Colors.grey[200],
                                    ),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                              },
                        ),
                        IconButton(
                          onPressed: () {
                            cubit.removePostImage();
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
                  LinearProgressIndicator(),
                Row(
                  children: [
                    SizedBox(width: 35),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          cubit.getPostsImage();
                        },
                        child: Row(
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
                          cubit.getPostsImage();
                        },
                        child: Row(
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
