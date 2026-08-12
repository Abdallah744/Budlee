// ignore_for_file: use_key_in_widget_constructors

import 'package:budlee_app/config/cubit/register/register_bloc.dart';
import 'package:budlee_app/config/cubit/register/register_event.dart';
import 'package:budlee_app/config/cubit/register/register_states.dart';
import 'package:budlee_app/config/user/login_and_register/login_screen.dart';
import 'package:budlee_app/core/components/components.dart';
import 'package:budlee_app/core/constants/constants.dart';
import 'package:budlee_app/core/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => RegisterBloc(),
      child: BlocConsumer<RegisterBloc, RegisterStates>(
        listener: (context, state) {
          if (state is CreateUserSuccessState) {
            showToast(
              text: 'Register Successfully',
              state: ToastStates.SUCCESS,
            );
            navigateToAndFinish(context, Login());
          } else if (state is CreateUserErrorState) {
            showToast(text: state.error, state: ToastStates.ERROR);
          }
        },
        builder: (context, state) {
          var bloc = RegisterBloc.get(context);
          return Scaffold(
            backgroundColor: Colors.purple[50],
            appBar: AppBar(
              title: const Text(
                'Register Page',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurpleAccent,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.purple[50],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 20.0,
                  end: 20.0,
                  top: 15.0,
                  bottom: 10.0,
                ),
                child: Form(
                  key: bloc.registerFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 26.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.blueAccent,
                        ),
                      ),
                      Text(
                        'Login now to meet your friends and family',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      nameTextFormField(
                        controller: bloc.nameController,
                        type: TextInputType.emailAddress,
                        validate: (value) {
                          if (value!.isEmpty) {
                            return 'name must not be empty';
                          } else if (RegExp(r'^[0-9]').hasMatch(value)) {
                            return 'please enter a valid name';
                          } else {
                            return null;
                          }
                        },
                        label: 'UserName',
                      ),
                      const SizedBox(height: 20.0),
                      emailTextFormField(
                        controller: bloc.emailController,
                        type: TextInputType.emailAddress,
                        validate: (value) {
                          if (value!.isEmpty) {
                            return 'email must not be empty';
                          } else if (!value.contains('@')) {
                            return 'please enter a valid email';
                          } else {
                            return null;
                          }
                        },
                        label: 'Email Address',
                        prefix: const Icon(Icons.email_outlined),
                      ),
                      const SizedBox(height: 20.0),
                      passwordTextFormField(
                        controller: bloc.passwordController,
                        type: TextInputType.visiblePassword,
                        isPassword: bloc.visibleOff,
                        validate: (value) {
                          if (value!.isEmpty) {
                            return 'password must not be empty';
                          } else if (value.length < 6) {
                            return 'password is too short';
                          } else {
                            return null;
                          }
                        },
                        label: 'Password',
                        prefix: const Icon(Icons.lock),
                        suffix: bloc.redEyeIcon,
                        suffixPressed: () {
                          bloc.add(RegisterChangeVisibilityOneEvent());
                        },
                      ),
                      const SizedBox(height: 20.0),
                      dateTextFormField(
                        controller: bloc.birthdayController,
                        type: TextInputType.number,
                        validate: (value) {
                          if (value!.isEmpty) {
                            return 'Birthday must not be empty';
                          } else {
                            return null;
                          }
                        },
                        onTap: () {
                          // Defer the entire date picker interaction to the next event loop cycle.
                          Future(() async {
                            if (!context.mounted) return;

                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate:
                                  bloc.birthdayController.text.isNotEmpty
                                  ? (DateFormat.yMMMd().tryParse(
                                          bloc.birthdayController.text,
                                        ) ??
                                        DateTime(2000, 1, 1))
                                  : DateTime(2000, 1, 1),
                              firstDate: DateTime(1920, 1, 1),
                              lastDate: DateTime.now(),
                            );

                            if (!context.mounted || pickedDate == null) return;

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (context.mounted) {
                                bloc.birthdayController.text =
                                    DateFormat.yMMMd()
                                        .format(pickedDate)
                                        .toString();
                              }
                            });
                          });
                        },
                        label: 'birthday',
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        controller: bloc.phonController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'phone number must not be empty';
                          } else if (value.length < 11 || value.length > 11) {
                            return 'phone number must be 11 digits';
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(textFormRadius),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Row(
                        children: [
                          Checkbox(
                            value: bloc.rightsChecked,
                            onChanged: (value) {
                              bloc.add(RegisterChangeRightsCheckedEvent());
                            },
                            visualDensity: const VisualDensity(
                              horizontal: -4,
                              vertical: -4,
                            ),
                          ),
                          const Text(
                            'I Totally have the right to use my personal data \n for the purpose of this app.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      Row(
                        children: [
                          Checkbox(
                            value: bloc.termsChecked,
                            onChanged: (value) {
                              bloc.add(RegisterChangeTermsCheckedEvent());
                            },
                            visualDensity: const VisualDensity(
                              horizontal: -4,
                              vertical: -4,
                            ),
                          ),
                          const Text(
                            'I read and accept the terms and conditions \n to use this app.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30.0),
                      defaultButton(
                        function: () {
                          if (bloc.registerFormKey.currentState!.validate() &&
                              bloc.rightsChecked &&
                              bloc.termsChecked) {
                            bloc.add(UserRegisterEvent(
                              email: bloc.emailController.text,
                              password: bloc.passwordController.text,
                              name: bloc.nameController.text,
                              phone: bloc.phonController.text,
                              birthday: bloc.birthdayController.text,
                            ));
                          } else {
                            showToast(
                              text: 'Please check the terms and conditions',
                              state: ToastStates.ERROR,
                            );
                          }
                        },
                        background: secondaryColor,
                        text: 'Create Account',
                      ),
                      const SizedBox(height: 20.0),
                      Center(
                        child: Text(
                          'OR REGISTER WITH',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              bloc.add(RegisterWithGoogleEvent());
                            },
                            child: const CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.white,
                              child: Image(
                                image: NetworkImage(
                                  'https://cdn1.iconfinder.com/data/icons/google-s-logo/150/Google_Icons-09-512.png',
                                ),
                                width: 35,
                                height: 35,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          InkWell(
                            onTap: () {
                              bloc.add(RegisterWithFacebookEvent());
                            },
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.facebook,
                                color: Colors.blue[900],
                                size: 40,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
