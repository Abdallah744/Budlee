// ignore_for_file: use_key_in_widget_constructors, must_be_immutable

import 'package:budlee_app/config/user/login_and_register/register_screen.dart';
import 'package:budlee_app/core/components/components.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/cubit/login/login_cubit.dart';
import '../../../config/cubit/login/login_states.dart';
import '../../../core/styles/colors.dart';
import '../../../modules/layouts/home_layout/home_page.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginStates>(
      listener: (context, state) {
        if (state is LoginSuccessAppState) {
          showToast(text: 'Login Successfully', state: ToastStates.SUCCESS);
          navigateToAndFinish(context, HomeScreen());
        } else if (state is LoginErrorAppState) {
          showToast(text: state.error, state: ToastStates.ERROR);
        }
      },
      builder: (context, state) {
        var cubit = LoginCubit.get(context);
        return Scaffold(
          backgroundColor: Colors.purple[50],
          appBar: AppBar(
            title: Text(
              'Budlee ;)',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.purple[50],
            elevation: 0,
          ),
          body: Form(
            key: cubit.formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 120),
                    Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 40,
                        color: defaultColor,
                        fontWeight: FontWeight.bold,
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
                    SizedBox(height: 35),
                    emailTextFormField(
                      controller: cubit.emailController,
                      type: TextInputType.emailAddress,
                      validate: (value) {
                        if (value!.isEmpty) {
                          return 'email address must not be empty';
                        } else if (!value.contains('@')) {
                          return 'email address must be valid';
                        } else {
                          return null;
                        }
                      },
                      label: 'Email Address',
                      prefix: Icon(Icons.email),
                    ),
                    SizedBox(height: 15),
                    passwordTextFormField(
                      controller: cubit.passwordController,
                      type: TextInputType.visiblePassword,
                      isPassword: cubit.visibleOff,
                      validate: (value) {
                        if (value!.isEmpty) {
                          return 'password must not be empty';
                        } else if (value.length < 6) {
                          return 'password must be at least 6 characters';
                        } else {
                          return null;
                        }
                      },
                      label: 'Password',
                      prefix: Icon(Icons.lock),
                      suffixPressed: () {
                        cubit.changeVisibilityOne();
                      },
                      suffix: cubit.redEyeIcon,
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Checkbox(
                          value: cubit.checked,
                          activeColor: Colors.blueAccent,
                          onChanged: (value) {
                            cubit.changeChecked();
                          },
                        ),
                        Text('Remember Me', style: TextStyle(fontSize: 16.0)),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Forgot Password?',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Rest Password',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: defaultColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    ConditionalBuilder(
                      condition: state is! LoginLoadingAppState,
                      builder: (context) => defaultButton(
                        function: () {
                          if (cubit.formKey.currentState!.validate() &&
                              cubit.checked) {
                            cubit.userLogin(
                              cubit.emailController.text,
                              cubit.passwordController.text,
                            );
                          }
                        },
                        text: 'Login',
                        background: secondaryColor,
                        radius: 25,
                      ),
                      fallback: (context) =>
                          Center(child: CircularProgressIndicator()),
                    ),

                    SizedBox(height: 10.0),
                    Row(
                      children: [
                        Text(
                          'Don\'t have an account?',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        TextButton(
                          onPressed: () {
                            navigateTo(context, RegisterScreen());
                          },
                          child: Text(
                            'Register Now',
                            style: TextStyle(
                              color: defaultColor,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     CircleAvatar(
                    //       radius: 25,
                    //       child: Icon(
                    //         Icons.facebook,
                    //         color: Colors.blueAccent,
                    //         size: 50,
                    //       ),
                    //     ),
                    //     SizedBox(width: 10),
                    //     CircleAvatar(
                    //       radius: 25,
                    //       child: Icon(
                    //         Icons.phone_android_outlined,
                    //         color: Colors.blueGrey,
                    //         size: 45,
                    //       ),
                    //     ),
                    //     SizedBox(width: 10),
                    //     CircleAvatar(
                    //       radius: 25,
                    //       child: IconButton(
                    //         onPressed: (){},
                    //         icon: Icon(
                    //           Icons.email_outlined,
                    //           color: Colors.red[500],
                    //           size: 45,
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
