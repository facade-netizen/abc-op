import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/authBlocs/change_password_bloc.dart';
import '../../bloc/authBlocs/user_changed_bloc.dart';
import '../../bloc/authBlocs/user_logout_bloc.dart';
import '../../constants/app_constant.dart';
import '../../reusable/colors.dart';
import '../../reusable/highlighted_text_widget.dart';
import '../../reusable/loader.dart';
import '../../reusable/snack_bar.dart';
import '../../reusable/style.dart';
import '../riskView/riskManagement/riskManagementWidgets/risk_management_custom_widget.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController newPassController = TextEditingController();
  final TextEditingController cfmPasswordController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    newPassController.dispose();
    cfmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserLogoutBloc, UserLogoutState>(
      listener: (context, state) {
        if (state is UserLogoutSuccess) {
          context.read<UserAuthChangesBloc>().add(StartUserChangeListener());
        }
      },
      builder: (context, state) {
        return BlocConsumer<ChangePasswordBloc, ChangePasswordState>(
          listener: (context, cps) {
            if (cps is ChangePasswordSuccess) {
              context.read<UserLogoutBloc>().add(UserLogoutListener(context: context));
              showSnackBar(context, "Password updated successfully");
              passwordController.clear();
              newPassController.clear();
              cfmPasswordController.clear();
            }
            if (cps is ChangePasswordFailure) {
              showSnackBar(context, cps.error, error: true);
            }
          },
          builder: (context, cps) {
            return SizedBox(
              width: cpw(context),
              child: cps is ChangePasswordProgress
                  ? const LoaderContainerWithMessage(message: "Loading...")
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const RiskHeader(type: 1, title: "Change Password"),
                            const PasswordTile(
                              title: "Change Password",
                              isHeader: true,
                            ),

                            /// OLD PASSWORD
                            PasswordTile(
                              title: "Password",
                              child: TextField(
                                obscureText: true,
                                obscuringCharacter: '*',
                                controller: passwordController,
                                textInputAction: TextInputAction.next,
                                decoration: tfInputDecoration.copyWith(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                ),
                              ),
                            ),

                            /// NEW PASSWORD
                            PasswordTile(
                              title: "New Password",
                              child: TextField(
                                obscureText: true,
                                obscuringCharacter: '*',
                                controller: newPassController,
                                textInputAction: TextInputAction.next,
                                decoration: tfInputDecoration.copyWith(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                ),
                              ),
                            ),

                            /// CONFIRM PASSWORD
                            PasswordTile(
                              title: "Confirm Password",
                              child: TextField(
                                obscureText: true,
                                obscuringCharacter: '*',
                                controller: cfmPasswordController,
                                textInputAction: TextInputAction.done,
                                decoration: tfInputDecoration.copyWith(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                ),
                              ),
                            ),

                            /// UPDATE BUTTON
                            Container(
                              height: 60,
                              width: cpw(context),
                              decoration: BoxDecoration(
                                color: white,
                                border: Border(
                                  bottom: BorderSide(color: about, width: 0.5),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 40,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: blue,
                                            foregroundColor: white,
                                            side: const BorderSide(color: blue, width: 2),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            elevation: 0,
                                          ),
                                          onPressed: () {
                                            Map<String, dynamic> changePasswordMap = {
                                              "oldPassword": passwordController.text.trim(),
                                              "newPassword": newPassController.text.trim(),
                                              "confirmPassword": cfmPasswordController.text.trim(),
                                              "ip": ip.value,
                                              "isp": isp.value,
                                            };
                                            context.read<ChangePasswordBloc>().add(ChangePassword(changePassword: changePasswordMap));
                                          },
                                          child: const HighlightText(
                                            'Update',
                                            style: TextStyle(fontWeight: FontWeight.w600),
                                          ),
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
                    ),
            );
          },
        );
      },
    );
  }
}

class PasswordTile extends StatelessWidget {
  const PasswordTile({
    super.key,
    required this.title,
    this.child,
    this.error,
    this.isHeader = false,
  });

  final String title;
  final Widget? child;
  final bool isHeader;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isHeader ? 30 : 45,
      width: cpw(context),
      decoration: BoxDecoration(
        color: isHeader ? about : white,
        border: Border(bottom: BorderSide(color: about, width: 0.5)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 170,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: HighlightText(
                title,
                style: TextStyle(
                  color: isHeader ? white : black,
                  fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
          SizedBox(height: 30, width: 230, child: child),
          if (error != null) ...[
            const SizedBox(width: 20),
            Expanded(
              child: HighlightText(
                error!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: red, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
          ]
        ],
      ),
    );
  }
}

double cpw(BuildContext context) {
  return MediaQuery.sizeOf(context).width / 2;
}
