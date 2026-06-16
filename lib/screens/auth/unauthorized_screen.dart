import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/authBlocs/user_changed_bloc.dart';
import '../../bloc/authBlocs/user_logout_bloc.dart';
import '../../reusable/button.dart';
import '../../reusable/sized_box_hw.dart';

class UnAuthorizedScreen extends StatelessWidget {
  const UnAuthorizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserLogoutBloc, UserLogoutState>(
      builder: (context, uls) {
        if (uls is UserLogoutSuccess) {
          context.read<UserAuthChangesBloc>().add(StartUserChangeListener());
        }

        return Scaffold(
          backgroundColor: const Color(0xFF252525),
          body: SafeArea(
            child: Center(
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
                    child: SingleChildScrollView(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFD3D3D3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.lock_outline,
                                  size: 64,
                                  color: Colors.red.shade700,
                                ),
                              ),
                              hb20,
                              Text(
                                'Access Denied',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red.shade700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              hb12,
                              Text(
                                "You are not authorized to access this resource.",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              hb8,
                              Text(
                                "Please login with an account that has the required permissions.",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              hb30,
                              CustomCTAButton(
                                width: dialogWidth / 2,
                                title: "Logout",
                                action: () {
                                  context.read<UserLogoutBloc>().add(
                                        UserLogoutListener(context: context),
                                      );
                                },
                                icon: Icons.logout,
                              ),
                              hb20,
                              // Help Section - Integrated directly into view
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.green,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.help_outline,
                                          size: 20,
                                          color: Colors.green.shade700,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Need Help?',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Contact your administrator or support team if you believe this is an error.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
