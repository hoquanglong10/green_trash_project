import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/app_models.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/app_widgets.dart';
import 'secondary/application/customer_secondary_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  bool _isEditing = false;
  bool _isSaving = false;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();

    final user = ref.read(currentUserProvider);

    _nameController = TextEditingController(text: user?.hoTen ?? '');

    _emailController = TextEditingController(text: user?.email ?? '');

    _phoneController = TextEditingController(text: user?.soDienThoai ?? '');
    Future.microtask(_loadProfileFromFirestore);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return AppPage(
      title: 'Hồ sơ cá nhân',
      subtitle: 'Thông tin tài khoản khách hàng',
      maxWidth: 700,
      child: _isLoadingProfile
          ? const Center(child: CircularProgressIndicator())
          : user == null
          ? const Center(child: Text('Không tìm thấy thông tin người dùng'))
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
              children: [
                const HomeBrandHeader(
                  title: 'Tài khoản của bạn',
                  subtitle:
                      'Quản lý thông tin cá nhân sử dụng trong GreenTrash.',
                  trailing: Icon(
                    Icons.person_outline,
                    color: AppColors.white,
                    size: 42,
                  ),
                ),
                const SizedBox(height: AppSpacing.sectionGap),

                _ProfileHeader(user: user),

                const SizedBox(height: AppSpacing.sectionGap),

                Row(
                  children: [
                    const Expanded(
                      child: SectionHeader(
                        title: 'Thông tin cá nhân',
                        subtitle: 'Họ tên, email và số điện thoại',
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _isEditing = !_isEditing;
                        });

                        if (!_isEditing) {
                          _restoreCurrentInformation(user);
                        }
                      },
                      icon: Icon(
                        _isEditing ? Icons.close : Icons.edit_outlined,
                      ),
                      label: Text(_isEditing ? 'Hủy sửa' : 'Chỉnh sửa'),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            enabled: _isEditing,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Họ và tên',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            validator: (value) {
                              final name = value?.trim() ?? '';

                              if (name.isEmpty) {
                                return 'Vui lòng nhập họ và tên';
                              }

                              if (name.length < 2) {
                                return 'Họ tên phải có ít nhất 2 ký tự';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),

                          TextFormField(
                            controller: _emailController,
                            enabled: _isEditing,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (value) {
                              final email = value?.trim() ?? '';

                              if (email.isEmpty) {
                                return 'Vui lòng nhập email';
                              }

                              final emailRegex = RegExp(
                                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                              );

                              if (!emailRegex.hasMatch(email)) {
                                return 'Email không đúng định dạng';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),

                          TextFormField(
                            controller: _phoneController,
                            enabled: _isEditing,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                              labelText: 'Số điện thoại',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                            validator: (value) {
                              final phone = value?.trim() ?? '';

                              if (phone.isEmpty) {
                                return 'Vui lòng nhập số điện thoại';
                              }

                              final phoneRegex = RegExp(r'^[0-9]{9,11}$');

                              if (!phoneRegex.hasMatch(phone)) {
                                return 'Số điện thoại phải có từ 9 đến 11 số';
                              }

                              return null;
                            },
                          ),

                          if (_isEditing) ...[
                            const SizedBox(height: AppSpacing.lg),

                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _isSaving ? null : _saveProfile,
                                icon: _isSaving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.save_outlined),
                                label: Text(
                                  _isSaving ? 'Đang lưu...' : 'Lưu thay đổi',
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.sectionGap),

                const SectionHeader(
                  title: 'Thông tin tài khoản',
                  subtitle: 'Thông tin do hệ thống quản lý',
                ),
                const SizedBox(height: AppSpacing.sm),

                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.fingerprint,
                          color: AppColors.green,
                        ),
                        title: const Text('Mã người dùng'),
                        subtitle: Text(user.userId),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(
                          Icons.manage_accounts_outlined,
                          color: AppColors.green,
                        ),
                        title: const Text('Vai trò'),
                        subtitle: Text(user.role.label),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _restoreCurrentInformation(AppUser user) {
    _nameController.text = user.hoTen;
    _emailController.text = user.email;
    _phoneController.text = user.soDienThoai;
  }

  Future<void> _loadProfileFromFirestore() async {
    final currentUser = ref.read(currentUserProvider);

    if (currentUser == null) {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
      return;
    }

    try {
      final remoteUser = await ref
          .read(firestoreCustomerServiceProvider)
          .getProfile(fallbackUser: currentUser);

      if (!mounted) {
        return;
      }

      if (remoteUser != null) {
        _nameController.text = remoteUser.hoTen;
        _emailController.text = remoteUser.email;
        _phoneController.text = remoteUser.soDienThoai;

        final currentSession = ref.read(currentSessionProvider);

        if (currentSession != null) {
          ref.read(currentSessionProvider.notifier).state = AppSession(
            user: remoteUser,
            role: currentSession.role,
          );
        }
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải hồ sơ: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid || _isSaving) {
      return;
    }

    final currentSession = ref.read(currentSessionProvider);

    if (currentSession == null) {
      return;
    }

    final updatedUser = AppUser(
      userId: currentSession.user.userId,
      hoTen: _nameController.text.trim(),
      email: _emailController.text.trim(),
      soDienThoai: _phoneController.text.trim(),
      role: currentSession.user.role,
    );

    setState(() {
      _isSaving = true;
    });

    try {
      await ref.read(firestoreCustomerServiceProvider).saveProfile(updatedUser);

      ref.read(currentSessionProvider.notifier).state = AppSession(
        user: updatedUser,
        role: currentSession.role,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã lưu hồ sơ vào Firestore'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lưu hồ sơ thất bại: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final firstCharacter = user.hoTen.trim().isEmpty
        ? 'K'
        : user.hoTen.trim()[0].toUpperCase();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: AppColors.green,
              child: Text(
                firstCharacter,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.hoTen,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    user.soDienThoai,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
