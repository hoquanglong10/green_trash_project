import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import 'data/firebase_authentication_service.dart';
import '../../models/app_models.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/app_widgets.dart';
import '../admin/admin_dashboard_screen.dart';
import '../customer/customer_home_screen.dart';
import '../staff/staff_home_screen.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  bool _restoring = true;
  String? _restoreError;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_restoreSession);
  }

  Future<void> _restoreSession() async {
    if (!ref.read(firebaseEnabledProvider)) {
      if (mounted) setState(() => _restoring = false);
      return;
    }
    try {
      final session = await ref
          .read(firebaseAuthenticationServiceProvider)
          .restoreSession();
      if (mounted) {
        ref.read(currentSessionProvider.notifier).state = session;
      }
    } on AuthenticationException catch (error) {
      await ref.read(firebaseAuthenticationServiceProvider).signOut();
      if (mounted) _restoreError = error.message;
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(currentSessionProvider);
    final firebaseEnabled = ref.watch(firebaseEnabledProvider);
    if (_restoring && firebaseEnabled) {
      return const Scaffold(body: AppLoadingView(message: 'Đang xác thực...'));
    }
    if (session == null) return LoginScreen(initialMessage: _restoreError);

    return switch (session.role) {
      UserRole.customer => const CustomerHomeScreen(),
      UserRole.staff => const StaffHomeScreen(),
      UserRole.admin => const AdminDashboardScreen(),
    };
  }
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.initialMessage});

  final String? initialMessage;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const _testAccounts = <_TestAccount>[
    _TestAccount(
      label: 'Admin',
      email: 'admin@greentrash.vn',
      password: 'Admin@123456',
      icon: Icons.admin_panel_settings_outlined,
    ),
    _TestAccount(
      label: 'Nhân viên',
      email: 'nhanvien01@greentrash.vn',
      password: 'Nhanvien@123456',
      icon: Icons.badge_outlined,
    ),
    _TestAccount(
      label: 'Khách hàng',
      email: 'khachhang01@gmail.com',
      password: 'Khachhang@123456',
      icon: Icons.person_outline,
    ),
  ];

  bool _rememberMe = true;
  bool _submitting = false;
  String? _selectedTestEmail;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: '',
      subtitle: '',
      panel: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chào mừng trở lại',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Đăng nhập để tiếp tục quản lý hoạt động thu gom.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xxl),
          if (widget.initialMessage != null) ...[
            Text(
              widget.initialMessage!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.warning),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          AppTextInput(
            controller: _emailController,
            icon: Icons.mail_outline,
            label: 'Email',
            hint: 'Nhập email của bạn',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.fieldGap),
          AppTextInput(
            controller: _passwordController,
            icon: Icons.lock_outline,
            label: 'Mật khẩu',
            hint: 'Nhập mật khẩu',
            obscureText: true,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: _rememberMe,
                        activeColor: AuthRefColors.controlIcon,
                        checkColor: AppColors.surface,
                        onChanged: (value) =>
                            setState(() => _rememberMe = value ?? false),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: Text(
                        'Ghi nhớ tôi',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AuthRefColors.controlText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AuthRefColors.controlText,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordScreen(),
                    ),
                  );
                },
                child: const Text('Quên mật khẩu?'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Tài khoản test',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AuthRefColors.controlText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _TestAccountSelector(
            accounts: _testAccounts,
            selectedEmail: _selectedTestEmail,
            onSelected: (account) {
              setState(() {
                _selectedTestEmail = account.email;
                _emailController.text = account.email;
                _passwordController.text = account.password;
              });
            },
          ),
          const SizedBox(height: AppSpacing.buttonTopGap),
          PrimaryActionButton(
            label: _submitting ? 'Dang dang nhap...' : 'Đăng nhập',
            onPressed: _submitting ? null : _submit,
          ),
          const SizedBox(height: AppSpacing.lg),
          const DividerLabel(label: 'Hoặc'),
          const SizedBox(height: AppSpacing.lg),
          SocialAuthButton(
            label: 'Tiếp tục với Google',
            icon: const _GoogleLogo(size: 18),
            onPressed: () {},
          ),
          const SizedBox(height: AppSpacing.sm),
          SocialAuthButton(
            label: 'Tiếp tục với Facebook',
            icon: const _FacebookLogo(size: 18),
            onPressed: () {},
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Chưa có tài khoản?',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AuthRefColors.linkBlue,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text('Đăng ký'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final session = await ref
          .read(firebaseAuthenticationServiceProvider)
          .signIn(
            email: _emailController.text,
            password: _passwordController.text,
          );
      if (mounted) {
        ref.read(currentSessionProvider.notifier).state = session;
      }
    } on AuthenticationException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _acceptedTerms = true;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBack: true,
      title: 'Đăng ký',
      subtitle: 'Tạo tài khoản khách hàng',
      panel: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextInput(
            controller: _nameController,
            icon: Icons.person_outline,
            label: 'Họ tên',
            hint: 'Nhập họ tên',
          ),
          const SizedBox(height: AppSpacing.fieldGap),
          AppTextInput(
            controller: _phoneController,
            icon: Icons.phone_outlined,
            label: 'Số điện thoại',
            hint: 'Nhập số điện thoại',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: AppSpacing.fieldGap),
          AppTextInput(
            controller: _emailController,
            icon: Icons.mail_outline,
            label: 'Email',
            hint: 'Nhập email',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.fieldGap),
          AppTextInput(
            controller: _passwordController,
            icon: Icons.lock_outline,
            label: 'Mật khẩu',
            hint: 'Nhập mật khẩu',
            obscureText: true,
          ),
          const SizedBox(height: AppSpacing.fieldGap),
          AppTextInput(
            controller: _confirmPasswordController,
            icon: Icons.lock_reset_outlined,
            label: 'Xác nhận mật khẩu',
            hint: 'Nhập lại mật khẩu',
            obscureText: true,
          ),
          const SizedBox(height: AppSpacing.md),
          InkWell(
            borderRadius: BorderRadius.circular(AppRadius.md),
            onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
            child: Row(
              children: [
                Checkbox(
                  value: _acceptedTerms,
                  activeColor: AuthRefColors.controlIcon,
                  checkColor: AppColors.surface,
                  onChanged: (value) {
                    setState(() => _acceptedTerms = value ?? false);
                  },
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                Expanded(
                  child: Text(
                    'Tôi đồng ý với điều khoản sử dụng',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.buttonTopGap),
          PrimaryActionButton(
            label: _submitting ? 'Dang tao tai khoan...' : 'Đăng ký',
            onPressed: _acceptedTerms && !_submitting ? _register : null,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Đã có tài khoản?',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đăng nhập'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mat khau nhap lai chua khop.')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final session = await ref
          .read(firebaseAuthenticationServiceProvider)
          .registerCustomer(
            fullName: _nameController.text,
            phone: _phoneController.text,
            email: _emailController.text,
            password: _passwordController.text,
          );
      if (mounted) {
        ref.read(currentSessionProvider.notifier).state = session;
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on AuthenticationException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBack: true,
      title: 'Quên mật khẩu',
      subtitle: 'Khôi phục tài khoản',
      panel: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nhập email đã liên kết với tài khoản. GreenTrash sẽ gửi mã xác thực để đặt lại mật khẩu.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppTextInput(
            controller: _emailController,
            icon: Icons.mail_outline,
            label: 'Email',
            hint: 'Nhập email của bạn',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.buttonTopGap),
          PrimaryActionButton(label: 'Xác nhận', onPressed: _sendResetEmail),
        ],
      ),
    );
  }

  Future<void> _sendResetEmail() async {
    try {
      await ref
          .read(firebaseAuthenticationServiceProvider)
          .sendPasswordResetEmail(_emailController.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Da gui email dat lai mat khau.')),
      );
      Navigator.of(context).pop();
    } on AuthenticationException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }
}

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _controllers = List.generate(4, (_) => TextEditingController());
  final _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBack: true,
      title: 'Xác thực OTP',
      subtitle: 'Nhập mã bảo mật',
      panel: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mã OTP đã được gửi đến email của bạn. Vui lòng nhập đủ 4 số để tiếp tục.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            children: [
              for (var index = 0; index < _controllers.length; index++) ...[
                Expanded(
                  child: _OtpCell(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    onChanged: (value) {
                      if (value.isNotEmpty && index < _controllers.length - 1) {
                        _focusNodes[index + 1].requestFocus();
                      }
                    },
                  ),
                ),
                if (index < _controllers.length - 1)
                  const SizedBox(width: AppSpacing.sm),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Text(
              'Gửi lại mã sau 00:57',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
          ),
          const SizedBox(height: AppSpacing.buttonTopGap),
          PrimaryActionButton(
            label: 'Xác nhận',
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
          ),
        ],
      ),
    );
  }
}

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.panel,
    this.showBack = false,
  });

  final String title;
  final String subtitle;
  final Widget panel;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxl,
                vertical: AppSpacing.xxxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showBack)
                    _AuthBackHeader(title: title, subtitle: subtitle)
                  else
                    const Center(child: BrandLogo(stacked: true, logoSize: 96)),
                  SizedBox(height: showBack ? AppSpacing.xxl : AppSpacing.xxxl),
                  panel,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthBackHeader extends StatelessWidget {
  const _AuthBackHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton.outlined(
          tooltip: 'Quay lại',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, size: 18),
          color: AppColors.primary,
          style: IconButton.styleFrom(
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OtpCell extends StatelessWidget {
  const _OtpCell({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.inputHeight,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        maxLength: 1,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        decoration: const InputDecoration(counterText: ''),
        onChanged: onChanged,
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.18;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );

    Paint arcPaint(Color color) {
      return Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;
    }

    canvas.drawArc(
      rect,
      -0.08 * math.pi,
      0.55 * math.pi,
      false,
      arcPaint(AuthRefColors.googleBlue),
    );
    canvas.drawArc(
      rect,
      0.45 * math.pi,
      0.54 * math.pi,
      false,
      arcPaint(AuthRefColors.googleGreen),
    );
    canvas.drawArc(
      rect,
      0.97 * math.pi,
      0.39 * math.pi,
      false,
      arcPaint(AuthRefColors.googleYellow),
    );
    canvas.drawArc(
      rect,
      1.33 * math.pi,
      0.57 * math.pi,
      false,
      arcPaint(AuthRefColors.googleRed),
    );

    final crossbarPaint = Paint()
      ..color = AuthRefColors.googleBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(
      Offset(size.width * 0.53, size.height * 0.52),
      Offset(size.width * 0.87, size.height * 0.52),
      crossbarPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FacebookLogo extends StatelessWidget {
  const _FacebookLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.facebook, size: size, color: AuthRefColors.facebookBlue);
  }
}

class _TestAccount {
  const _TestAccount({
    required this.label,
    required this.email,
    required this.password,
    required this.icon,
  });

  final String label;
  final String email;
  final String password;
  final IconData icon;
}

class _TestAccountSelector extends StatelessWidget {
  const _TestAccountSelector({
    required this.accounts,
    required this.selectedEmail,
    required this.onSelected,
  });

  final List<_TestAccount> accounts;
  final String? selectedEmail;
  final ValueChanged<_TestAccount> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < accounts.length; index++) ...[
          Expanded(
            child: _TestAccountButton(
              account: accounts[index],
              selected: accounts[index].email == selectedEmail,
              onTap: () => onSelected(accounts[index]),
            ),
          ),
          if (index < accounts.length - 1) const SizedBox(width: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _TestAccountButton extends StatelessWidget {
  const _TestAccountButton({
    required this.account,
    required this.selected,
    required this.onTap,
  });

  final _TestAccount account;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Điền tài khoản test ${account.label}',
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: selected
                ? AuthRefColors.controlSelectedSurface
                : AuthRefColors.controlSurface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected
                  ? AuthRefColors.controlSelectedBorder
                  : AuthRefColors.controlBorder,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(account.icon, size: 16, color: AuthRefColors.controlIcon),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  account.label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: selected
                        ? AppColors.text
                        : AuthRefColors.controlText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _RoleSelector extends StatelessWidget {
  const _RoleSelector({required this.selectedRole, required this.onChanged});

  final UserRole selectedRole;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RolePill(
          label: 'Khách',
          icon: Icons.person_outline,
          selected: selectedRole == UserRole.customer,
          onTap: () => onChanged(UserRole.customer),
        ),
        const SizedBox(width: AppSpacing.sm),
        _RolePill(
          label: 'Nhân viên',
          icon: Icons.badge_outlined,
          selected: selectedRole == UserRole.staff,
          onTap: () => onChanged(UserRole.staff),
        ),
        const SizedBox(width: AppSpacing.sm),
        _RolePill(
          label: 'Admin',
          icon: Icons.dashboard_outlined,
          selected: selectedRole == UserRole.admin,
          onTap: () => onChanged(UserRole.admin),
        ),
      ],
    );
  }
}

class _RolePill extends StatelessWidget {
  const _RolePill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: selected
                ? AuthRefColors.controlSelectedSurface
                : AuthRefColors.controlSurface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected
                  ? AuthRefColors.controlSelectedBorder
                  : AuthRefColors.controlBorder,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: AuthRefColors.controlIcon),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected
                        ? AppColors.text
                        : AuthRefColors.controlText,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _DemoAccountSelector extends StatelessWidget {
  const _DemoAccountSelector({
    required this.users,
    required this.selectedUserId,
    required this.onChanged,
  });

  final List<AppUser> users;
  final String selectedUserId;
  final ValueChanged<AppUser> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final user in users)
          ChoiceChip(
            selected: user.userId == selectedUserId,
            showCheckmark: false,
            avatar: Icon(
              Icons.badge_outlined,
              size: 16,
              color: AuthRefColors.controlIcon,
            ),
            label: Text(user.hoTen),
            backgroundColor: AuthRefColors.controlSurface,
            selectedColor: AuthRefColors.controlSelectedSurface,
            labelStyle: TextStyle(
              color: user.userId == selectedUserId
                  ? AppColors.text
                  : AuthRefColors.controlText,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              side: BorderSide(
                color: user.userId == selectedUserId
                    ? AuthRefColors.controlSelectedBorder
                    : AuthRefColors.controlBorder,
              ),
            ),
            onSelected: (_) => onChanged(user),
          ),
      ],
    );
  }
}
