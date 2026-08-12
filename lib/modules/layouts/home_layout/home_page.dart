// ignore_for_file: unused_import

import 'dart:io';

import 'package:budlee_app/core/components/components.dart';
import 'package:budlee_app/modules/screens/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/cubit/app_cubit/app_bloc.dart';
import '../../../config/cubit/app_cubit/app_event.dart';
import '../../../config/cubit/app_cubit/app_states.dart';
import '../search_layout/search_page.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppBloc, AppState>(
      listener: (context, state) {
        if (state is SettingsOpenedState) {
          navigateTo(context, SettingsScreen());
        }
      },
      builder: (context, state) {
        var bloc = AppBloc.get(context);
        // Determine the backgroundImage for the CircleAvatar
        ImageProvider? backgroundImage;
        if (bloc.model != null) {
          if (bloc.model!.profileImageFile != null &&
              bloc.model!.profileImageFile!.existsSync()) {
            backgroundImage = FileImage(bloc.model!.profileImageFile!);
          } else {
            backgroundImage = customImageProvider(bloc.model!.image);
          }
        }

        return Scaffold(
          appBar: AppBar(
            leading: InkWell(
              onTap: () {
                navigateTo(context, SettingsScreen());
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
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
              ),
            ),
            title: Text(bloc.titles[bloc.currentIndex]),
            actions: [
              IconButton(
                onPressed: () {
                  navigateTo(context, SearchPage());
                },
                icon: const Icon(Icons.search, size: 30),
              ),
            ],
          ),
          body: bloc.screens[bloc.currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            items: bloc.bottomNavItems,
            currentIndex: bloc.currentIndex,
            onTap: (index) {
              bloc.add(AppChangeBottomNavBarEvent(index));
            },
          ),
        );
      },
    );
  }
}
