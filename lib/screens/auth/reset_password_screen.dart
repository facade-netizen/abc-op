import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_asset_constants.dart';
import '../../bloc/authBlocs/reset_password_bloc.dart';
import '../../bloc/authBlocs/user_changed_bloc.dart';
import '../../bloc/authBlocs/user_login_bloc.dart';
import '../../constants/app_constant.dart';
import '../../reusable/button.dart';
import '../../router/route_paths.dart';
import '../../reusable/colors.dart';
import '../../reusable/snack_bar.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key, required this.userName});
  final String userName;
  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController oldPasswordController = TextEditingController();

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    oldPasswordController.dispose();
    super.dispose();
  }

  String? validatePassword(String value) {
    if (value.isEmpty) return "Password is required";
    if (value.length < 6 || value.length > 15) return "Password must be 6-15 characters";
    if (value.contains(" ")) return "No spaces allowed";
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return "Must include upper, lower & number";
    }
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return "No special characters allowed";
    }
    if (value.toLowerCase().contains(widget.userName.toLowerCase())) {
      return "Password cannot contain your username";
    }
    if (value == oldPasswordController.text) return "New & Old password cannot be same";
    return null;
  }

  void onChangePassword() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      Map<String, dynamic> resetPasswordMap = {
        "username": widget.userName,
        "oldPassword": oldPasswordController.text.trim(),
        "newPassword": newPasswordController.text.trim(),
        "confirmPassword": confirmPasswordController.text.trim(),
        "ip": ip.value,
        "isp": isp.value,
      };
      context.read<ResetPasswordBloc>().add(ResetPassword(resetPassword: resetPasswordMap));
    } else {
      final newPasswordError = validatePassword(newPasswordController.text);
      if (newPasswordError != null) {
        showSnackBar(context, newPasswordError, error: true);
      } else if (confirmPasswordController.text != newPasswordController.text) {
        showSnackBar(context, "Passwords do not match", error: true);
      } else if (newPasswordController.text.toLowerCase().contains(widget.userName.toLowerCase())) {
        showSnackBar(context, "Password cannot contain your username", error: true);
      } else if (oldPasswordController.text.isEmpty) {
        showSnackBar(context, "Old password required", error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return BlocConsumer<UserLoginBloc, UserLoginState>(
      listener: (context, state) {
        if (state is UserLoginSuccess) {
          context.read<UserAuthChangesBloc>().add(StartUserChangeListener());
          context.go(RoutePaths.manage);
        }
      },
      builder: (context, state) {
        return BlocConsumer<ResetPasswordBloc, ResetPasswordState>(
          listener: (context, rps) {
            if (rps is ResetPasswordSuccess) {
              context.read<UserLoginBloc>().add(UserLogin(username: rps.userName, password: rps.password));
            }
            if (rps is ResetPasswordFailure) {
              showSnackBar(context, rps.error, error: true);
            }
          },
          builder: (context, rps) {
            bool isLoading = rps is ResetPasswordProgress;

            return Scaffold(
              body: SafeArea(
                child: Container(
                  width: size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                    image: const DecorationImage(image: AssetImage(AppAssetConstants.loginBg2), fit: BoxFit.fill),
                    gradient: gradientClr,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 600,
                      height: 500,
                      child: Column(
                        children: [
                          Container(
                            width: 600,
                            height: 400,
                            decoration: BoxDecoration(
                              color: white,
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "",
                                              style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 20),
                                            const PasswordInstruction(title: 'Password must have 6 to 15 alphanumeric without white space'),
                                            const PasswordInstruction(title: 'Password cannot be the same as username'),
                                            const PasswordInstruction(title: 'Must contain at least 1 capital letter, 1 small letter and 1 number'),
                                            const PasswordInstruction(title: 'Password must not contain any special characters (!,@,#,etc..)'),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Flexible(
                                        child: Form(
                                          key: _formKey,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Change Password",
                                                style: TextStyle(color: black, fontSize: 25, fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(height: 20),
                                              _inputField("New Password", controller: newPasswordController, validator: (val) => validatePassword(val!)),
                                              _inputField(
                                                "Confirm Password",
                                                controller: confirmPasswordController,
                                                validator: (val) {
                                                  if (val == null || val.isEmpty) return "Confirm password required";
                                                  if (val != newPasswordController.text) return "Passwords do not match";
                                                  return null;
                                                },
                                              ),
                                              _inputField(
                                                "Old Password",
                                                controller: oldPasswordController,
                                                validator: (val) {
                                                  if (val == null || val.isEmpty) return "Old password required";
                                                  return null;
                                                },
                                              ),
                                              const SizedBox(height: 10),
                                              ColouredElevatedButton(
                                                onCLick: () {
                                                  if (isLoading) return;
                                                  onChangePassword();
                                                },
                                                width: double.infinity,
                                                height: 50,
                                                gradientColor: bottomBarGradient,
                                                child: Center(
                                                  child: Text(
                                                    isLoading ? 'Please wait..' : "Change",
                                                    style: TextStyle(color: yellowTextColor, fontWeight: FontWeight.bold, fontSize: 18),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _inputField(String hint, {required TextEditingController controller, required String? Function(String?) validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        obscureText: true,
        validator: validator,
        obscuringCharacter: '*',
        style: TextStyle(color: secondaryTextClr),
        decoration: InputDecoration(
          filled: true,
          hintText: hint,
          hintStyle: TextStyle(color: grey),
          fillColor: white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }
}

class PasswordInstruction extends StatelessWidget {
  const PasswordInstruction({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: secondaryTextClr),
          ),
          Expanded(
            child: Text(title, style: TextStyle(fontSize: 15, height: 1.4, color: secondaryTextClr)),
          ),
        ],
      ),
    );
  }
}
