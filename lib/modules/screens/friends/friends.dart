import 'dart:io';

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/cubit/app_cubit/app_cubit.dart';
import '../../../config/cubit/app_cubit/app_states.dart';
import '../../../core/components/components.dart';
import '../chats/massages_screen.dart';

class Friends extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppState>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = AppCubit.get(context);
        return SingleChildScrollView(
          child: ConditionalBuilder(
            condition: cubit.users.isNotEmpty,
            builder: (context) => Column(),
            fallback: (context) => Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }

  Widget friendsItemBuilder({context, index}) {
    var cubit = AppCubit.get(context);
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundImage: cubit.model!.profileImageFile == null
                  ? (cubit.model!.image.toString().startsWith('http')
                        ? NetworkImage(cubit.model!.image.toString())
                        : FileImage(File(cubit.model!.image.toString()))
                              as ImageProvider)
                  : FileImage(cubit.model!.profileImageFile!),
            ),
            SizedBox(width: 20),
            Text(
              '${cubit.model!.name}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Spacer(),
            IconButton(
              onPressed: () {
                cubit.chatItemIndex = index;
                navigateTo(context, MassagesScreen());
              },
              icon: Icon(Icons.message),
            ),
          ],
        ),
      ),
    );
  }
}
