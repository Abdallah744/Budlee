import 'dart:io';

import 'package:budlee_app/models/massages/massage_model.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/cubit/app_cubit/app_cubit.dart';
import '../../../config/cubit/app_cubit/app_states.dart';

class MassagesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        AppCubit.get(context).getMassages(
          massageReceiverId: AppCubit.get(
            context,
          ).users[AppCubit.get(context).chatItemIndex].uId,
        );
        return BlocConsumer<AppCubit, AppState>(
          listener: (context, state) {},
          builder: (context, state) {
            var cubit = AppCubit.get(context);
            return Scaffold(
              appBar: AppBar(
                leading: CircleAvatar(
                  radius: 21,
                  backgroundImage:
                      cubit.users[cubit.chatItemIndex].image
                          .toString()
                          .startsWith('http')
                      ? NetworkImage(
                          cubit.users[cubit.chatItemIndex].image.toString(),
                        )
                      : FileImage(
                          File(
                            cubit.users[cubit.chatItemIndex].image.toString(),
                          ),
                        ),
                ),
                title: Text(
                  cubit.users[cubit.chatItemIndex].name.toString(),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                actions: [
                  IconButton(onPressed: () {}, icon: Icon(Icons.video_call)),
                  IconButton(onPressed: () {}, icon: Icon(Icons.phone)),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      cubit.chatItemIndex = null;
                    },
                    icon: Icon(Icons.arrow_back),
                  ),
                ],
              ),
              body: Column(
                children: [
                  Expanded(
                    child: ConditionalBuilder(
                      condition: cubit.massages.isNotEmpty,
                      builder: (context) => Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ListView.separated(
                          itemBuilder: (context, index) {
                            var massage = cubit.massages[index];
                            if (cubit.model!.uId == massage.massageSenderId)
                              return massageMyItemBuilder(massage);
                            return massageItemBuilder(massage);
                          },
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 20),
                          itemCount: cubit.massages.length,
                        ),
                      ),
                      fallback: (context) =>
                          Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey, width: 1.0),
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: cubit.massageController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Type a message',
                              ),
                            ),
                          ),
                          Container(
                            height: 50,
                            color: Colors.grey[600],
                            child: MaterialButton(
                              onPressed: () {},
                              minWidth: 1,
                              child: Icon(
                                Icons.mic,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                          Container(
                            height: 50,
                            color: Colors.blueAccent[400],
                            child: MaterialButton(
                              onPressed: () {
                                cubit.sendMassage(
                                  massageReceiverId:
                                      cubit.users[cubit.chatItemIndex].uId,
                                  massageText: cubit.massageController.text,
                                );
                                cubit.massageController.clear();
                              },
                              minWidth: 1,
                              child: Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget massageItemBuilder(MassageModel? massageModel) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.green[500],
        borderRadius: BorderRadiusDirectional.only(
          bottomEnd: Radius.circular(10),
          topEnd: Radius.circular(10),
          topStart: Radius.circular(10),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Text(
        '${massageModel!.massageText}',
        style: TextStyle(color: Colors.white, fontSize: 16),
        textAlign: TextAlign.right,
      ),
    ),
  );

  Widget massageMyItemBuilder(MassageModel? massageModel) => Align(
    alignment: AlignmentDirectional.centerEnd,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadiusDirectional.only(
          bottomStart: Radius.circular(10),
          topEnd: Radius.circular(10),
          topStart: Radius.circular(10),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Text(
        '${massageModel!.massageText}',
        style: TextStyle(color: Colors.black, fontSize: 16),
        textAlign: TextAlign.right,
      ),
    ),
  );
}
