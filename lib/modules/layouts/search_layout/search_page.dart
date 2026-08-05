import 'package:budlee_app/config/cubit/app_cubit/app_cubit.dart';
import 'package:budlee_app/config/cubit/app_cubit/app_states.dart';
import 'package:budlee_app/core/components/components.dart';
import 'package:budlee_app/models/users/user_model.dart';
import 'package:budlee_app/modules/screens/friends/friend_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchPage extends StatefulWidget {
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  void initState() {
    super.initState();
    // Initialize search results when the page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppCubit.get(context).getUsers();
      AppCubit.get(context).search('');
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppState>(
      listener: (context, state) {
        if (state is GetAllUsersSuccessState) {
          AppCubit.get(context).search('');
        }
      },
      builder: (context, state) {
        var cubit = AppCubit.get(context);

        return Scaffold(
          appBar: AppBar(title: Text('Search Users')),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Autocomplete<userModel>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return const Iterable<userModel>.empty();
                    }
                    return cubit.users.where((userModel option) {
                      return option.name!.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      );
                    });
                  },
                  displayStringForOption: (userModel option) => option.name!,
                  onSelected: (userModel selection) {
                    navigateTo(context, FriendProfile(friendModel: selection));
                  },
                  fieldViewBuilder:
                      (
                        context,
                        textEditingController,
                        focusNode,
                        onFieldSubmitted,
                      ) {
                        return TextFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            labelText: 'Search',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            cubit.search(value);
                          },
                          onFieldSubmitted: (value) {
                            cubit.search(value);
                          },
                        );
                      },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        child: Container(
                          width: MediaQuery.of(context).size.width - 40,
                          child: ListView.builder(
                            padding: EdgeInsets.all(8.0),
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final userModel option = options.elementAt(index);
                              return GestureDetector(
                                onTap: () {
                                  onSelected(option);
                                },
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: customImageProvider(
                                      option.image,
                                    ),
                                    onBackgroundImageError:
                                        customImageProvider(option.image) !=
                                            null
                                        ? (exception, stackTrace) {}
                                        : null,
                                    backgroundColor: Colors.grey[200],
                                  ),
                                  title: Text(option.name!),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) => buildSearchItem(
                      cubit.searchResult[index],
                      context,
                      cubit,
                    ),
                    separatorBuilder: (context, index) => myDivider2(),
                    itemCount: cubit.searchResult.length,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildSearchItem(userModel model, context, AppCubit cubit) => InkWell(
    onTap: () {
      navigateTo(context, FriendProfile(friendModel: model));
    },
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: customImageProvider(model.image),
            onBackgroundImageError: customImageProvider(model.image) != null
                ? (exception, stackTrace) {}
                : null,
            backgroundColor: Colors.grey[200],
          ),
          SizedBox(width: 20),
          Text(
            '${model.name}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Spacer(),
          if (!cubit.myFriends.any((element) => element.uId == model.uId))
            IconButton(
              onPressed: () {
                cubit.addFriend(model.uId);
              },
              icon: Icon(Icons.person_add, color: Colors.blue),
            )
          else
            Icon(Icons.check_circle, color: Colors.green),
        ],
      ),
    ),
  );
}
