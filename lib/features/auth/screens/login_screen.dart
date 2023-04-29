import 'package:flutter/material.dart';
import 'package:ShareSphere/core/common/loader.dart';
import 'package:ShareSphere/core/common/sign_in_button.dart';
import 'package:ShareSphere/core/constants/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ShareSphere/features/auth/controller/auth_controller.dart';
import 'package:ShareSphere/responsive/responsive.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  void signInAsGuest(WidgetRef ref, BuildContext context) {
    ref.read(authControllerProvider.notifier).signInAsGuest(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: ClipRRect(
          borderRadius: BorderRadius.circular(100.0),
          child: Image.asset(
            Constants.logoPath,
            height: 60,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => signInAsGuest(ref, context),
              child: const Text(
                'Skip',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ))
        ],
      ),
      body: isLoading
          ? const Loader()
          : Center(
              child: ListView(
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 30),
                      const Text(
                        'Dive into anything',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(200.0),
                          child: Image.asset(
                            Constants.loginEmotePath,
                            height: 370,
                          ),
                        ),
                      ),
                      const Responsive(child: SignInButton()),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
