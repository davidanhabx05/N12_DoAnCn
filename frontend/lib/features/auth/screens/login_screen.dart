import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../viewmodels/profile_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  void _handleGoogleLogin() async {
    setState(() {
      _isLoading = true;
    });

    final profileVm = context.read<ProfileViewModel>();
    final messenger = ScaffoldMessenger.of(context);

    final result = await profileVm.loginWithGoogle();

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    switch (result) {
      case LoginResult.success:
        messenger.showSnackBar(SnackBar(content: Text('Xin chào, ${profileVm.displayName}!')));
        Navigator.pushReplacementNamed(context, AppConstants.routeHome);
        break;
      case LoginResult.demo:
        messenger.showSnackBar(const SnackBar(
          content: Text('Chưa cấu hình Firebase cho nền tảng này – đang dùng tài khoản demo trên máy chủ.'),
        ));
        Navigator.pushReplacementNamed(context, AppConstants.routeHome);
        break;
      case LoginResult.cancelled:
        messenger.showSnackBar(const SnackBar(content: Text('Bạn đã huỷ đăng nhập.')));
        break;
      case LoginResult.failed:
        messenger.showSnackBar(SnackBar(
          content: Text('Đăng nhập Google thất bại. Bạn có thể bấm "Bỏ qua" để dùng thử.\n${profileVm.lastError ?? ''}'),
          duration: const Duration(seconds: 5),
        ));
        break;
    }
  }

  void _continueAsGuest() async {
    setState(() {
      _isLoading = true;
    });
    final profileVm = context.read<ProfileViewModel>();
    final ok = await profileVm.continueAsGuest();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
    if (ok) {
      Navigator.pushReplacementNamed(context, AppConstants.routeHome);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(profileVm.lastError ?? 'Không kết nối được máy chủ.'),
        duration: const Duration(seconds: 5),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              // App Logo / Illustration Placeholder
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  size: 80,
                  color: AppTheme.primaryOrange,
                ),
              ),
              const SizedBox(height: 40),
              
              const Text(
                'Hôm Nay Ăn Gì?',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              
              const Text(
                'Khám phá hàng ngàn công thức nấu ăn và gợi ý quán ngon xung quanh bạn.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.textGrey,
                  height: 1.5,
                ),
              ),
              
              const Spacer(),
              
              // Google Login Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.textDark,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleGoogleLogin,
                  child: _isLoading 
                    ? const SizedBox(
                        height: 24, 
                        width: 24, 
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryOrange, 
                          strokeWidth: 2
                        )
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Google Icon using a standard Flutter icon or Image
                          Image.network(
                            'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                            height: 24,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, size: 32, color: Colors.red),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Tiếp tục với Google',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                ),
              ),
              const SizedBox(height: 24),
              
              TextButton(
                onPressed: _isLoading ? null : _continueAsGuest,
                child: const Text(
                  'Bỏ qua, tôi muốn khám phá ngay',
                  style: TextStyle(
                    color: AppTheme.primaryOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
