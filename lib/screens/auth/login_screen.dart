import 'dart:async';
import 'dart:math';

import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/authBlocs/user_login_bloc.dart';
import '../../bloc/authBlocs/user_changed_bloc.dart';
import '../../constants/app_asset_constants.dart';
import '../../localDb/login/login_credentials_box.dart';
import '../../localDb/login/login_credentials_model.dart';
import '../../reusable/button.dart';
import '../../reusable/colors.dart';
import '../../reusable/snack_bar.dart';
import '../../router/token_expiry_notifier.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController validationCodeController = TextEditingController();

  Timer? codeTimer;
  String validationCode = "";
  String? formError;
  late LoginCredentialsModel loginDetails;

  @override
  void initState() {
    super.initState();
    LoginCredentialsModel? savedData = LoginCredentialsBox.loginCredentialsBox.fetchLoginCredentials;
    if (savedData != null && savedData.userId != null) {
      userNameController.text = savedData.userId!;
      passwordController.text = savedData.password!;
      loginDetails = savedData;
    } else {
      loginDetails = LoginCredentialsModel();
    }
    _startValidationCodeTimer();
  }

  void _startValidationCodeTimer() {
    _generateNewCode();
    codeTimer = Timer.periodic(const Duration(seconds: 30), (_) => _generateNewCode());
  }

  void _generateNewCode() {
    setState(() {
      validationCode = (1000 + Random().nextInt(9000)).toString();
    });
  }

  @override
  void dispose() {
    codeTimer?.cancel();
    userNameController.dispose();
    passwordController.dispose();
    validationCodeController.dispose();
    super.dispose();
  }

  String? _validateForm() {
    if (userNameController.text.trim().isEmpty) return "Username is required";
    if (passwordController.text.isEmpty) return "Password is required";
    if (validationCodeController.text.isEmpty) return "Validation code is required";
    if (validationCodeController.text != validationCode) return "Invalid validation code";
    return null;
  }

  void _handleLogin() {
    setState(() => formError = null);
    final error = _validateForm();
    if (error != null) {
      setState(() => formError = error);
      _generateNewCode();
      return;
    }
    context.read<UserLoginBloc>().add(UserLogin(username: userNameController.text.trim(), password: passwordController.text));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserLoginBloc, UserLoginState>(
      listener: (context, state) {
        if (state is UserLoginFailure) {
          showSnackBar(context, state.error, error: true);
        }
        if (state is UserLoginSuccess) {
          context.read<TokenExpiryNotifier>().initFromStorage();
          context.read<UserAuthChangesBloc>().add(StartUserChangeListener());
        }
        if (state is UserLoginResetPasswordRequiredSuccess) {
          context.go('/reset-password/${state.userName}');
        }
      },
      builder: (context, state) {
        bool isProcessing = state is UserLoginProgress;

        return Scaffold(
          backgroundColor: const Color(0xFF252525),
          body: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Responsive sizing based on screen size
                final maxWidth = constraints.maxWidth * 0.4;
                final maxHeight = constraints.maxHeight * 0.7;

                // Set reasonable min/max dimensions
                final dialogWidth = maxWidth.clamp(600.0, 1000.0);
                final dialogHeight = maxHeight.clamp(400.0, 600.0);

                return SizedBox(
                  width: dialogWidth,
                  height: dialogHeight,
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            // Left side - Image
                            Expanded(
                              flex: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD3D3D3),
                                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                                  image: DecorationImage(image: AssetImage(AppAssetConstants.loginBg1), fit: BoxFit.cover),
                                ),
                              ),
                            ),

                            // Right side - Form
                            Expanded(
                              flex: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD3D3D3),
                                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                                ),
                                child: Form(
                                  key: loginFormKey,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 25),
                                    child: Center(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "OP Sign In",
                                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.normal, color: black),
                                            ),
                                            const SizedBox(height: 20),
                                            _buildTextField(readOnly: isProcessing, controller: userNameController, hintText: "Username", keyboardType: TextInputType.text),
                                            const SizedBox(height: 10),
                                            _buildTextField(readOnly: isProcessing, controller: passwordController, hintText: "Password", obscureText: true),
                                            const SizedBox(height: 10),
                                            _buildValidationCodeField(dialogWidth / 2, isProcessing),
                                            const SizedBox(height: 25),
                                            CustomCTAButton(
                                              isDisabled: isProcessing,
                                              isProcessing: isProcessing,
                                              width: dialogWidth / 2,
                                              title: "Login",
                                              action: _handleLogin,
                                              icon: Icons.logout,
                                            ),
                                            if (formError != null)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 10),
                                                child: Text(
                                                  formError!,
                                                  style: const TextStyle(color: red, fontSize: 16, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildFooter(),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      obscuringCharacter: '*',
      decoration: _inputDecoration(hintText),
    );
  }

  Widget _buildValidationCodeField(double formWidth, bool readOnly) {
    return TextFormField(
      readOnly: readOnly,
      controller: validationCodeController,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), LengthLimitingTextInputFormatter(4)],
      decoration: _inputDecoration(
        "Validation Code",
        suffix: Padding(
          padding: const EdgeInsets.only(top: 4, right: 8),
          child: Text(
            validationCode,
            style: const TextStyle(color: black, fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      onFieldSubmitted: (_) => _handleLogin(),
    );
  }

  InputDecoration _inputDecoration(String hintText, {Widget? suffix}) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      suffixIcon: suffix,
      fillColor: white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      errorBorder: border(color: red),
      focusedBorder: border(),
      enabledBorder: border(color: transparent),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(AppAssetConstants.chrome, fit: BoxFit.cover, color: Colors.grey[500]),
              const SizedBox(width: 8),
              Image.asset(AppAssetConstants.firefox, fit: BoxFit.cover, color: Colors.grey[500]),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Text(
              'Our website works best in the newest and last prior version of these browsers: Google Chrome, Firefox',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ),
        ],
      ),
    );
  }
}

InputBorder? border({Color color = black}) {
  return OutlineInputBorder(
    borderSide: BorderSide(color: color, width: 2),
    borderRadius: const BorderRadius.all(Radius.circular(8)),
  );
}
