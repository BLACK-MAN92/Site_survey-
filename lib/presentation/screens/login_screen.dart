import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    await ref
        .read(loginStateProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginStateProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4F9),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    // =====================================================
                    // BLUE HEADER
                    // =====================================================
                    Container(
                      width: double.infinity,
                      height: 430,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xFF1555A5), Color(0xFF2378D3)],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(55),
                          bottomRight: Radius.circular(55),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Space for the status bar
                          SizedBox(
                            height: MediaQuery.of(context).padding.top + 65,
                          ),

                          // -------------------------------------------------
                          // Location ICON
                          // -------------------------------------------------
                          const Icon(
                            Icons.location_searching_outlined,
                            color: Colors.white,
                            size: 78,
                          ),

                          const SizedBox(height: 20),

                          // -------------------------------------------------
                          // WELCOME BACK
                          // -------------------------------------------------
                          const Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w500,

                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),

                          const SizedBox(height: 7),

                          // -------------------------------------------------
                          // LOGIN TO CONTINUE
                          // -------------------------------------------------
                          Text(
                            'Login to continue',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white.withValues(alpha: 0.72),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // =====================================================
                    // LOGIN CARD
                    // =====================================================
                    Transform.translate(
                      offset: const Offset(0, -1),
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(34, 0, 34, 30),
                        padding: const EdgeInsets.fromLTRB(34, 30, 34, 30),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCF8FD),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 16,
                              spreadRadius: 1,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // =================================================
                              // EMAIL FIELD
                              // =================================================
                              _buildInputField(
                                controller: _emailController,
                                hintText: 'Email Address',
                                prefixIcon: Icons.email,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your email';
                                  }

                                  final emailRegex = RegExp(
                                    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                  );

                                  if (!emailRegex.hasMatch(value.trim())) {
                                    return 'Please enter a valid email';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 27),

                              // =================================================
                              // PASSWORD FIELD
                              // =================================================
                              _buildInputField(
                                controller: _passwordController,
                                hintText: 'Password',
                                prefixIcon: Icons.lock,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) {
                                  if (!loginState.isLoading) {
                                    _login();
                                  }
                                },
                                suffixIcon: IconButton(
                                  splashRadius: 22,
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: const Color(0xFF4C4A52),
                                    size: 27,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }

                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 30),

                              // =================================================
                              // ERROR MESSAGE
                              // =================================================
                              if (loginState.error != null) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  margin: const EdgeInsets.only(bottom: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    loginState.error!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],

                              // =================================================
                              // LOGIN BUTTON
                              // =================================================
                              SizedBox(
                                width: double.infinity,
                                height: 78,
                                child: ElevatedButton(
                                  onPressed: loginState.isLoading
                                      ? null
                                      : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1768C4),
                                    disabledBackgroundColor: const Color(
                                      0xFF1768C4,
                                    ),
                                    elevation: 3,
                                    shadowColor: Colors.black.withValues(
                                      alpha: 0.25,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  child: loginState.isLoading
                                      ? const SizedBox(
                                          height: 25,
                                          width: 25,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : const Text(
                                          'LOGIN',
                                          style: TextStyle(
                                            fontSize: 21,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 60),

                              // =================================================
                              // REGISTER
                              // =================================================
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Don't Have An Account",
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Color(0xFF343139),
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  GestureDetector(
                                    onTap: () {
                                      context.push('/register');
                                    },
                                    child: const Text(
                                      'Register',
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: Color(0xFF7863A8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ===============================================================
  // CUSTOM INPUT FIELD
  // ===============================================================
  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    Widget? suffixIcon,
    void Function(String)? onSubmitted,
  }) {
    return SizedBox(
      height: 78,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        validator: validator,
        onFieldSubmitted: onSubmitted,
        style: const TextStyle(fontSize: 19, color: Color(0xFF4A4750)),
        cursorColor: const Color(0xFF1768C4),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 19, color: Color(0xFF77727C)),

          // -------------------------------------------------------------
          // LEFT ICON
          // -------------------------------------------------------------
          prefixIcon: Icon(
            prefixIcon,
            color: const Color(0xFF4C4A52),
            size: 27,
          ),

          // -------------------------------------------------------------
          // RIGHT ICON
          // -------------------------------------------------------------
          suffixIcon: suffixIcon,

          // -------------------------------------------------------------
          // PADDING
          // -------------------------------------------------------------
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 20,
          ),

          // -------------------------------------------------------------
          // NORMAL BORDER
          // -------------------------------------------------------------
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFF77737A), width: 1.3),
          ),

          // -------------------------------------------------------------
          // FOCUSED BORDER
          // -------------------------------------------------------------
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFF1768C4), width: 1.8),
          ),

          // -------------------------------------------------------------
          // ERROR BORDER
          // -------------------------------------------------------------
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.red, width: 1.3),
          ),

          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.red, width: 1.8),
          ),

          // Keep the field from changing size when an error appears.
          errorStyle: const TextStyle(fontSize: 11, height: 0.8),
        ),
      ),
    );
  }
}
