// lib/src/ui/login_screen_custom.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../domain/login_controller.dart';

class LoginScreenCustom extends StatefulWidget {
  final LoginController controller;

  const LoginScreenCustom({super.key, required this.controller});

  @override
  State<LoginScreenCustom> createState() => _LoginScreenCustomState();
}

class _LoginScreenCustomState extends State<LoginScreenCustom>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();

  // Colors used across the screen
  static const Color _pageBackground = Color(0xFFF7F9FF); // page bg
  static const Color _cardColor = Color(0xFFFFFFFF);
  static const Color _softGray = Color(0xFF9AA3B2);
  static const Color _primaryBlue = Color(0xFF0B66FF);

  @override
  void initState() {
    super.initState();

    // Make status & navigation bars blend with app background and enable edge-to-edge.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: _pageBackground,
      systemNavigationBarColor: _pageBackground,
      systemNavigationBarDividerColor: _pageBackground,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemStatusBarContrastEnforced: false,
      systemNavigationBarContrastEnforced: false,
    ));
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    _otpCtrl.dispose();
    // Optionally leave overlays as-is (consistent app-wide). If you want to revert,
    // uncomment and set defaults here.
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _pageBackground,
        systemNavigationBarColor: _pageBackground,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        // Extend behind status/navigation to give a true full-screen canvas
        extendBody: true,
        extendBodyBehindAppBar: true,
        backgroundColor: _pageBackground,
        body: SafeArea(
          top: false,
          bottom: false,
          child: Container(
            // Make entire screen the page background (top & bottom system bars match it)
            width: double.infinity,
            height: double.infinity,
            color: _pageBackground,
            child: Column(
              children: [
                // Top bar region (same bg color) - to ensure visual continuity with status bar
                SizedBox(
                  height: mq.padding.top,
                  width: double.infinity,
                ),

                // Main content fills remaining area; not a floating card
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: mq.size.height - mq.padding.vertical - 40),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Optional logo / illustration at top
                            SizedBox(height: 24),
                            SizedBox(
                              height: 120,
                              child: Image.asset(
                                'assets/illustration.png',
                                fit: BoxFit.contain,
                                errorBuilder: (c, o, s) => const SizedBox.shrink(),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Sign In',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Enter valid user name & password to continue',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, color: _softGray),
                            ),
                            const SizedBox(height: 20),

                            // Input fields - full width, no floating card
                            _buildTextField(
                              controller: _emailCtrl,
                              label: 'User name',
                              prefix: const Icon(Icons.person_outline),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: _pwdCtrl,
                              label: 'Password',
                              prefix: const Icon(Icons.lock_outline),
                              obscureText: true,
                              suffix: IconButton(
                                icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                                onPressed: () {
                                  // If you want toggle visibility add a boolean state _obscurePwd
                                },
                              ),
                            ),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: const Text(
                                  'Forget password',
                                  style: TextStyle(color: _primaryBlue),
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Primary action - full width and visually integrated
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primaryBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: widget.controller.state.value.loading
                                    ? null
                                    : () {
                                  widget.controller.signInWithEmail(
                                    _emailCtrl.text.trim(),
                                    _pwdCtrl.text,
                                  );
                                },
                                child: widget.controller.state.value.loading
                                    ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                    : const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            Row(
                              children: [
                                Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Text('Or Continue with', style: TextStyle(color: _softGray, fontSize: 12)),
                                ),
                                Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                              ],
                            ),

                            const SizedBox(height: 14),

                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      side: BorderSide(color: Colors.grey.shade200),
                                      backgroundColor: Colors.transparent,
                                    ),
                                    onPressed: () async {
                                      try {
                                        final googleUser = await GoogleSignIn(scopes: ['email']).signIn();
                                        if (googleUser == null) return;
                                        final googleAuth = await googleUser.authentication;
                                        final idToken = googleAuth.idToken;
                                        if (idToken == null) return;
                                        widget.controller.signInWithOAuth("google", idToken);
                                      } catch (e) {
                                        // controller/state should surface errors
                                      }
                                    },
                                    icon: _googleIcon(),
                                    label: const Text('Google', style: TextStyle(fontWeight: FontWeight.w600)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      side: BorderSide(color: Colors.grey.shade200),
                                      backgroundColor: Colors.transparent,
                                    ),
                                    onPressed: () {
                                      widget.controller.signInWithOAuth('apple', '');
                                    },
                                    icon: const Icon(Icons.apple, size: 20, color: Colors.black),
                                    label: const Text('Apple', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Haven't any account? "),
                                GestureDetector(
                                  onTap: () {},
                                  child: const Text('Sign up', style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // OTP block (if requested)
                            if (widget.controller.state.value.otpRequested) ...[
                              _buildTextField(
                                controller: _otpCtrl,
                                label: 'Enter OTP',
                                keyboardType: TextInputType.number,
                                prefix: const Icon(Icons.confirmation_number_outlined),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 180,
                                child: ElevatedButton(
                                  onPressed: () {
                                    widget.controller.verifyOtp(_emailCtrl.text, _otpCtrl.text);
                                  },
                                  child: const Text('Verify OTP'),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Error / status messages
                            if (widget.controller.state.value.error != null) ...[
                              Text(widget.controller.state.value.error!, style: const TextStyle(color: Colors.red)),
                              const SizedBox(height: 8),
                            ],
                            if (widget.controller.state.value.authenticated) ...[
                              Text('✔ Logged In', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                            ],

                            // push remaining content to bottom so the bottom safe area is visible
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom bar region (same bg color) - ensures nav bar appears integrated
                SizedBox(height: mq.padding.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    Widget? prefix,
    Widget? suffix,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefix,
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        filled: true,
        fillColor: const Color(0xFFECEFF1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  static Widget _googleIcon() {
    return Padding(
      padding: const EdgeInsets.only(left: 6, right: 4),
      child: Image.asset(
        'assets/google_logo.png',
        height: 18,
        width: 18,
        errorBuilder: (c, o, s) => const Icon(Icons.g_mobiledata, size: 18),
      ),
    );
  }
}
