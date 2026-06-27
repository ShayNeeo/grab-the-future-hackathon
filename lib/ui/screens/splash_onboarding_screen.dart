import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scamshield/core/theme/app_colors.dart';
import 'package:scamshield/ui/widgets/shield_logo.dart';
import 'package:scamshield/ui/widgets/shield_button.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6)),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF006D72), // shield-teal
              Color(0xFF1A9DAA), // shield-teal-light
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  // Shield logo with animated pulse ring
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(
                                alpha: 0.15 + (_pulseController.value * 0.15)),
                            width: 3 + (_pulseController.value * 2),
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                            child: const Center(
                              child: ShieldLogo(size: 90, color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  // App name
                  Text(
                    'Lá Chắn Lừa Đảo',
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  Text(
                    'Người bạn đồng hành an toàn',
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const Spacer(flex: 2),
                  // Tagline
                  Padding(
                    padding: const EdgeInsets.only(bottom: 60),
                    child: Text(
                      'Bảo vệ bạn khỏi lừa đảo',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Onboarding ───

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      icon: Icons.mark_email_unread_rounded,
      heading: 'Nhận được tin nhắn lạ?',
      body:
          'Chỉ cần chụp ảnh hoặc gửi nội dung — ScamShield sẽ kiểm tra ngay cho bạn. Không cần lo lắng!',
      buttonLabel: 'Tiếp theo',
    ),
    _OnboardingData(
      icon: Icons.radar_rounded,
      heading: 'Phát hiện dấu hiệu lừa đảo',
      body:
          'AI sẽ tìm ra dấu hiệu nguy hiểm trong hợp đồng, voucher, và lời mời. Bạn không đơn độc!',
      buttonLabel: 'Tiếp theo',
    ),
    _OnboardingData(
      icon: Icons.family_restroom_rounded,
      heading: 'Chia sẻ với người thân ngay',
      body:
          'Kết nối với con cái hoặc người thân để cùng bảo vệ nhau. An toàn hơn khi có người bên cạnh.',
      buttonLabel: 'Bắt đầu',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: SafeArea(
        child: Column(
          children: [
            // Illustration area (top 45%)
            Expanded(
              flex: 45,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.shieldTealBg,
                          AppColors.surfaceLight,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: AppColors.shieldTeal.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.shieldTeal.withValues(alpha: 0.12),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          page.icon,
                          size: 80,
                          color: AppColors.shieldTeal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // White card (bottom 55%)
            Expanded(
              flex: 55,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heading
                    Text(
                      _pages[_currentPage].heading,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Body
                    Text(
                      _pages[_currentPage].body,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const Spacer(),
                    // Progress dots (larger for elderly visibility)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: i == _currentPage ? 28 : 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: i == _currentPage
                                ? AppColors.shieldTeal
                                : AppColors.divider,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Button
                    ShieldButton(
                      label: _pages[_currentPage].buttonLabel,
                      onPressed: _nextPage,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final String heading;
  final String body;
  final String buttonLabel;

  const _OnboardingData({
    required this.icon,
    required this.heading,
    required this.body,
    required this.buttonLabel,
  });
}
