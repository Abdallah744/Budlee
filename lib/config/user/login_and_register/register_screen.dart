// ignore_for_file: use_key_in_widget_constructors

import 'package:budlee_app/config/user/login_and_register/login_screen.dart';
import 'package:budlee_app/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../config/cubit/register/register_cubit.dart';
import '../../../config/cubit/register/register_states.dart';
import '../../../core/components/components.dart';
import '../../../core/styles/colors.dart';

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => RegisterCubit(),
      child: BlocConsumer<RegisterCubit, RegisterStates>(
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
          var cubit = RegisterCubit.get(context);
          return Scaffold(
            backgroundColor: Colors.purple[50],
            appBar: AppBar(
              title: Text(
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
                  key: cubit.registerFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
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
                      SizedBox(height: 40.0),
                      nameTextFormField(
                        controller: cubit.nameController,
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
                      SizedBox(height: 20.0),
                      emailTextFormField(
                        controller: cubit.emailController,
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
                        prefix: Icon(Icons.email_outlined),
                      ),
                      SizedBox(height: 20.0),
                      passwordTextFormField(
                        controller: cubit.passwordController,
                        type: TextInputType.visiblePassword,
                        isPassword: cubit.visibleOff,
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
                        prefix: Icon(Icons.lock),
                        suffix: cubit.redEyeIcon,
                        suffixPressed: () {
                          cubit.changeVisibilityOne();
                        },
                      ),
                      SizedBox(height: 20.0),
                      dateTextFormField(
                        controller: cubit.birthdayController,
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
                              initialDate:
                                  cubit.birthdayController.text.isNotEmpty
                                  ? (DateFormat.yMMMd().tryParse(
                                          cubit.birthdayController.text,
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
                                cubit.birthdayController.text =
                                    DateFormat.yMMMd()
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
                      SizedBox(height: 20.0),
                      TextFormField(
                        controller: cubit.phonController,
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
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(textFormRadius),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.length < 11 || value.length > 11) {
                            print('Phone number is valid');
                          }
                        },
                      ),
                      SizedBox(height: 20.0),
                      Row(
                        children: [
                          Checkbox(
                            value: cubit.rightsChecked,
                            onChanged: (value) {
                              cubit.changeRightsChecked();
                            },
                            visualDensity: VisualDensity(
                              horizontal: -4,
                              vertical: -4,
                            ),
                          ),
                          Text(
                            'I Totally have the right to use my personal data \n for the purpose of this app.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.0),
                      Row(
                        children: [
                          Checkbox(
                            value: cubit.termsChecked,
                            onChanged: (value) {
                              cubit.changeTermsChecked();
                            },
                            visualDensity: VisualDensity(
                              horizontal: -4,
                              vertical: -4,
                            ),
                          ),
                          Text(
                            'I read and accept the terms and conditions \n to use this app.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30.0),
                      defaultButton(
                        function: () {
                          if (cubit.registerFormKey.currentState!.validate() &&
                              cubit.rightsChecked &&
                              cubit.termsChecked) {
                            cubit.userRegister(
                              email: cubit.emailController.text,
                              password: cubit.passwordController.text,
                              name: cubit.nameController.text,
                              phone: cubit.phonController.text,
                              birthday: cubit.birthdayController.text,
                            );
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
