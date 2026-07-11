import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/components/components.dart';
import '../../cubit/app_cubit/app_cubit.dart';
import '../../cubit/app_cubit/app_states.dart';

class EditProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppState>(
      listener: (context, state) {},
      builder: (context, state) {
        AppCubit cubit = AppCubit.get(context);
        cubit.nameController.text = cubit.model!.name!;
        cubit.bioController.text = cubit.model!.bio!;
        cubit.phoneController.text = cubit.model!.phone!;
        cubit.dateController.text = cubit.model!.birthday!;
        return Scaffold(
          appBar: defaultAppBar(
            context: context,
            title: 'Edit Profile',
            actions: [
              TextButton(
                onPressed: () {
                  cubit.updateUserData(
                    name: cubit.nameController.text,
                    bio: cubit.bioController.text,
                    phone: cubit.phoneController.text,
                    date: cubit.dateController.text,
                    avatar: cubit.model!.profileImageFile == null
                        ? cubit.model!.image
                        : cubit.model!.profileImageFile!.path.toString(),
                    coverImage: cubit.model!.coverImageFile == null
                        ? cubit.model!.coverImage
                        : cubit.model!.coverImageFile!.path.toString(),
                  );
                  cubit.getUserData(cubit.model!.uId);
                  Navigator.pop(context);
                },
                child: Text(
                  'Update',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                if (state is UpdateUserDataLoadingState)
                  LinearProgressIndicator(),
                Container(
                  width: double.infinity,
                  height: 193,
                  child: Stack(
                    alignment: AlignmentDirectional.bottomCenter,
                    children: [
                      if (state is UploadCoverImageLoadingState ||
                          state is UploadProfileImageLoadingState)
                        LinearProgressIndicator(),
                      Align(
                        alignment: AlignmentDirectional.topCenter,
                        child: InkWell(
                          onTap: () {
                            cubit.getCoverImage();
                          },
                          child: Container(
                            height: 160,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                              ),
                              image: DecorationImage(
                                image: (cubit.model!.coverImageFile != null &&
                                        cubit.model!.coverImageFile!
                                            .existsSync())
                                    ? FileImage(cubit.model!.coverImageFile!)
                                    : customImageProvider(
                                        cubit.model!.coverImage),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      CircleAvatar(
                        radius: 60,
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        child: Stack(
                          alignment: AlignmentDirectional.bottomEnd,
                          children: [
                            CircleAvatar(
                              radius: 58,
                              backgroundImage: (cubit.model!.profileImageFile !=
                                          null &&
                                      cubit.model!.profileImageFile!
                                          .existsSync())
                                  ? FileImage(cubit.model!.profileImageFile!)
                                  : customImageProvider(cubit.model!.image),
                            ),
                            IconButton(
                              onPressed: () {
                                cubit.getProfileImage();
                              },
                              icon: Icon(
                                Icons.camera_alt,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25),
                nameTextFormField(
                  controller: cubit.nameController,
                  type: TextInputType.name,
                  validate: (value) {
                    return null;
                  },
                  label: 'Name',
                ),
                SizedBox(height: 10),
                nameTextFormField(
                  controller: cubit.bioController,
                  type: TextInputType.text,
                  validate: (value) {
                    return null;
                  },
                  label: 'Bio',
                ),
                SizedBox(height: 10),
                nameTextFormField(
                  controller: cubit.phoneController,
                  type: TextInputType.phone,
                  validate: (value) {
                    return null;
                  },
                  label: 'Phone',
                ),
                SizedBox(height: 10),
                dateTextFormField(
                  controller: cubit.dateController,
                  type: TextInputType.number,
                  validate: (value) {
                    if (value!.isEmpty) {
                      return 'Birthday must not be empty';
                    } else {
                      return null;
                    }
                  },
                  onTap: () {
                    print(
                      'Birthday field onTap triggered at: ${DateTime.now()}',
                    ); // <-- ADD THIS LINE
                    // Defer the entire date picker interaction to the next event loop cycle.
                    Future(() async {
                      // It's crucial to check if the widget is still in the tree (mounted)
                      // before attempting to show a dialog or interact with the context.
                      if (!context.mounted) return;

                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        // Try to use the existing date in the text field as initial, otherwise default.
                        initialDate: cubit.dateController.text.isNotEmpty
                            ? (DateFormat.yMMMd().tryParse(
                                    cubit.dateController.text,
                                  ) ??
                                  DateTime(2000, 1, 1))
                            : DateTime(2000, 1, 1),
                        firstDate: DateTime(1920, 1, 1),
                        lastDate: DateTime.now(),
                      );

                      // After showDatePicker returns (dialog is closed), check mounted status again
                      // and if a date was actually picked.
                      if (!context.mounted || pickedDate == null) return;

                      // Use WidgetsBinding.instance.addPostFrameCallback to schedule the state update
                      // for after the current frame rendering is complete. This helps avoid conflicts
                      // when the state update might trigger rebuilds during sensitive framework operations.
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        // One final check for mounted status inside the post-frame callback.
                        if (context.mounted) {
                          print(DateFormat.yMMMd().format(pickedDate));
                          cubit.dateController.text = DateFormat.yMMMd()
                              .format(pickedDate)
                              .toString();
                        }
                      });
                    }).catchError((error) {
                      // Handle potential errors from the Future chain.
                      // Check mounted status before interacting with context in error handling.
                      if (context.mounted) {
                        print(
                          'Error during date picker interaction: ${error.toString()}',
                        );
                        // Optionally: showToast(text: 'Could not select date.', state: ToastStates.ERROR);
                      } else {
                        print(
                          'Date picker error (context unmounted): ${error.toString()}',
                        );
                      }
                    });
                  },
                  label: 'birthday',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
