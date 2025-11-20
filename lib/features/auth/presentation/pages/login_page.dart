import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/core/constants/app_routes.dart';
import 'package:dentist_ms/features/auth/presentation/widgets/recognized.dart';
import 'package:dentist_ms/features/auth/presentation/widgets/scanning.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool rememberMe = false;
  bool _obscurePassword = true;
  bool _showScanningDialog = false;
  bool _showRecognizedDialog = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _startFacialRecognition() {
    setState(() => _showScanningDialog = true);

    // Simulate scanning for 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _showScanningDialog = false;
          _showRecognizedDialog = true;
        });
      }
    });
  }

  void _continueToDashboard() {
    Navigator.pushReplacementNamed(context, AppRoutes.dashboardShell);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F172B),
                  Color(0xFF1D293D),
                  Color(0xFF0F172B),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: isDesktop
                ? Row(
                    children: [
                      Expanded(flex: 5, child: _buildLeftSection()),
                      Expanded(flex: 4, child: _buildRightSection()),
                    ],
                  )
                : _buildRightSection(),
          ),

          // Scanning Dialog
          if (_showScanningDialog)
            FaceScanningOverlay(
              onClose: () => setState(() => _showScanningDialog = false),
            ),

          // Recognized Dialog
          if (_showRecognizedDialog)
            FaceRecognitionOverlay(
              onClose: () {
                setState(() => _showRecognizedDialog = false);
              },
              onContinue: () {
                setState(() => _showRecognizedDialog = false);
                _continueToDashboard();
              },
              onTryAgain: () {
                setState(() {
                  _showRecognizedDialog = false;
                  _showScanningDialog = true;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLeftSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 20),
              // Logo
              Row(
                children: [
                  Container(
                    decoration: AppColors.selectedPage.copyWith(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: SvgPicture.asset(
                      "assets/icons/pfp.svg",
                      width: 35,
                      height: 35,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Khelil's dental center",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Heading
              const Text(
                'Next-Generation Dental\nPractice Management',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),

              // Description
              Text(
                'Streamline your practice with AI-powered patient management,\nseamless scheduling, and advanced analytics.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 30),

              // Feature Cards
              Row(
                children: [
                  Expanded(
                    child: _buildFeatureCard(
                      icon: "assets/icons/security.svg",
                      title: 'Secure',
                      subtitle: 'HIPAA Compliant',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFeatureCard(
                      icon: "assets/icons/flash.svg",
                      title: 'Fast',
                      subtitle: 'Cloud-Based',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              Row(
                children: [
                  SvgPicture.asset(
                    "assets/icons/security.svg", // your SVG path
                    width: 14, // adjust size
                    height: 14,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF00B8DB), // matches opacity 0.5
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 4), // spacing between icon and text
                  Text(
                    'Protected by enterprise-grade encryption',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureCard({
    required String icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            icon,
            width: 28,
            height: 28,
            colorFilter: const ColorFilter.mode(
              Color(0xFF00B8DB),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightSection() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2530),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 40,
                spreadRadius: 0,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTabBar(),
              const SizedBox(height: 24),
              SizedBox(
                height: 360,
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildFacialRecognitionTab(), _buildPasswordTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF2A3441),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        height: 40,
        child: TabBar(
          controller: _tabController,
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.5),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/icons/facial.svg",
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Face ID',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/icons/lock.svg",
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Email',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacialRecognitionTab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            const Text(
              'Connexion sécurisée',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Utilisez la reconnaissance faciale pour un accès\ninstantané et sécurisé',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF4F7EFF).withOpacity(0.2),
                const Color(0xFF9D6CFF).withOpacity(0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: Center(
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF4F7EFF), width: 3),
              ),
              child: const Center(
                child: Icon(
                  Icons.center_focus_strong_rounded,
                  size: 45,
                  color: Color(0xFF4F7EFF),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        _buildGradientButton(
          text: 'Démarrer la reconnaissance faciale',
          onPressed: _startFacialRecognition,
        ),
      ],
    );
  }

  Widget _buildPasswordTab() {
    return Column(
      children: [
        const Text(
          'Content de te revoir',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Saisissez vos identifiants pour accéder à votre compte',
          style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        _buildEmailField(),
        const SizedBox(height: 30),
        _buildPasswordField(),
        const SizedBox(height: 20),
        _buildRememberForgot(),
        Spacer(),
        _buildGradientButton(
          text: 'Se connecter',
          onPressed: _continueToDashboard,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextField(
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.email_outlined,
          color: Colors.white.withOpacity(0.5),
          size: 18,
        ),
        hintText: 'dr.smith@dentalai.com',
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.3),
          fontSize: 13,
        ),
        filled: true,
        fillColor: const Color(0xFF2A3441),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4F7EFF), width: 2),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      obscureText: _obscurePassword,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.lock_outline,
          color: Colors.white.withOpacity(0.5),
          size: 18,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.white.withOpacity(0.5),
            size: 18,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        hintText: 'Mot de passe',
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.3),
          fontSize: 13,
        ),
        filled: true,
        fillColor: const Color(0xFF2A3441),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4F7EFF), width: 2),
        ),
      ),
    );
  }

  Widget _buildRememberForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: Checkbox(
                value: rememberMe,
                onChanged: (val) {
                  setState(() => rememberMe = val ?? false);
                },
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFF4F7EFF);
                  }
                  return Colors.transparent;
                }),
                side: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Souviens-toi de moi',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Mot de passe oublié?',
            style: TextStyle(color: Color(0xFF4F7EFF), fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
