// ignore_for_file: unused_import

import 'dart:io';

import 'package:budlee_app/core/components/components.dart';
import 'package:budlee_app/modules/screens/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/cubit/app_cubit/app_cubit.dart';
import '../../../config/cubit/app_cubit/app_states.dart';
import '../notifications_layout/notifications_page.dart';
import '../search_layout/search_page.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppState>(
      listener: (context, state) {
        if (state is SettingsOpenedState) {
          navigateTo(context, SettingsScreen());
        }
      },
      builder: (context, state) {
        var cubit = AppCubit.get(context);
        // Determine the backgroundImage for the CircleAvatar
        ImageProvider? backgroundImage;
        if (cubit.model != null) {
          if (cubit.model!.profileImageFile != null &&
              cubit.model!.profileImageFile!.existsSync()) {
            backgroundImage = FileImage(cubit.model!.profileImageFile!);
          } else {
            backgroundImage = customImageProvider(cubit.model!.image);
          }
        }

        return Scaffold(
          appBar: AppBar(
            leading: InkWell(
              onTap: () {
                navigateTo(context, SettingsScreen());
              },
              child: Padding(
                padding: const EdgeInsets.all(
                  8.0,
                ), // Added padding for better UI
                child: CircleAvatar(
                  radius: 21,
                  backgroundImage: backgroundImage,
                  onBackgroundImageError: backgroundImage != null
                      ? (exception, stackTrace) {}
                      : null,
                  backgroundColor: Colors.grey[200],
                  child: backgroundImage == null
                      ? Icon(Icons.account_circle, size: 42)
                      : null,
                ),
              ),
            ),
            title: Text(cubit.titles[cubit.currentIndex]),
            actions: [
              IconButton(
                onPressed: () {
                  navigateTo(context, SearchPage());
                },
                icon: Icon(Icons.search, size: 30),
              ),
              IconButton(
                onPressed: () {
                  navigateTo(context, NotificationsPage());
                },
                icon: Stack(
                  alignment: AlignmentDirectional.topEnd,
                  children: [
                    const Icon(Icons.notifications),
                    if (cubit.unreadNotificationsCount > 0)
                      CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.red,
                        child: Text(
                          '${cubit.unreadNotificationsCount}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          body: cubit.screens[cubit.currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            items: cubit.bottomNavItems,
            currentIndex: cubit.currentIndex,
            onTap: (index) {
              cubit.changeBottomNavBar(index);
            },
          ),
        );
      },
    );
  }
}
