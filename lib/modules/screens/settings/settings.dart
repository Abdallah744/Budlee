import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/cubit/app_cubit/app_cubit.dart';
import '../../../config/cubit/app_cubit/app_states.dart';
import '../../../config/user/login_and_register/login_screen.dart';
import '../../../config/user/profile/edit_profile_screen.dart';
import '../../../core/components/components.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppState>(
      listener: (context, state) {
        if (state is UploadToGalleryErrorState) {
          showToast(text: state.error, state: ToastStates.ERROR);
        }
        if (state is UploadToGallerySuccessState) {
          showToast(
            text: 'Image uploaded successfully',
            state: ToastStates.SUCCESS,
          );
        }
      },
      builder: (context, state) {
        var cubit = AppCubit.get(context);
        var model = cubit.model;

        if (model == null) {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null && state is! GetUserDataLoadingState) {
            cubit.getUserData(user.uid);
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: defaultAppBar(
            context: context,
            title: '${model.name}\'s Profile',
            titleTextStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            actions: [
              IconButton(
                onPressed: () {
                  cubit.logOut();
                  navigateToAndFinish(context, Login());
                },
                icon: Icon(Icons.logout_sharp, color: Colors.red[700]),
              ),
            ],
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 193,
                  child: Stack(
                    alignment: AlignmentDirectional.bottomCenter,
                    children: [
                      Align(
                        alignment: AlignmentDirectional.topCenter,
                        child: Container(
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(6),
                              topRight: Radius.circular(6),
                            ),
                            image: DecorationImage(
                              image: model.coverImageFile == null
                                  ? (model.coverImage.toString().startsWith(
                                          'http',
                                        )
                                        ? NetworkImage(
                                            model.coverImage.toString(),
                                          )
                                        : FileImage(
                                                File(
                                                  model.coverImage.toString(),
                                                ),
                                              )
                                              as ImageProvider)
                                  : FileImage(model.coverImageFile!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Theme.of(
                          context,
                        ).scaffoldBackgroundColor,
                        child: CircleAvatar(
                          radius: 58,
                          backgroundImage: model.profileImageFile == null
                              ? (model.image.toString().startsWith('http')
                                    ? NetworkImage(model.image.toString())
                                    : FileImage(File(model.image.toString()))
                                          as ImageProvider)
                              : FileImage(model.profileImageFile!),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${model.name}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  '${model.bio}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {},
                        child: Column(
                          children: [
                            Text(
                              '${cubit.myPostsCalculation()}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              'Posts',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {},
                        child: Column(
                          children: [
                            Text(
                              '${model.imagesOfGallery?.length ?? 0}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              'Gallery',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {},
                        child: Column(
                          children: [
                            Text(
                              '${cubit.amountOfFollowers}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              'Followers',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {},
                        child: Column(
                          children: [
                            Text(
                              '${cubit.amountOfFollowing}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              'Following',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          cubit.uploadToGallery();
                        },
                        child: const Text(
                          'Add To Gallery',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () {
                        navigateTo(context, EditProfileScreen());
                      },
                      child: const Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        FirebaseMessaging.instance.subscribeToTopic(
                          'announcements',
                        );
                      },
                      child: Text(
                        'Subscribe',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () {
                        FirebaseMessaging.instance.unsubscribeFromTopic(
                          'announcements',
                        );
                      },
                      child: Text(
                        'Unsubscribe',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                if (state is UploadToGalleryLoadingState)
                  const LinearProgressIndicator(),
                model.imagesOfGallery == null
                    ? const LinearProgressIndicator()
                    : galleryItemBuilder(model.imagesOfGallery!, context),
              ],
            ),
          ),
        );
      },
    );
  }
}
