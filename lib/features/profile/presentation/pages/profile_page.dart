import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../soulie/data/soulie_repository.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc(
        soulieRepository: context.read<SoulieRepository>(),
      )..add(const ProfileLoadRequested()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state.status == ProfileStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state.status == ProfileStatus.error) {
            return Center(
              child: Text(
                state.errorMessage ?? 'Không thể tải hồ sơ',
                style: TextStyle(
                  color: AppColors.textTertiary.withValues(alpha: 0.8),
                ),
              ),
            );
          }

          final authState = context.watch<AuthBloc>().state;
          final displayName = state.displayName.trim().isNotEmpty
              ? state.displayName.trim()
              : (authState.displayName?.trim().isNotEmpty == true
                    ? authState.displayName!.trim()
                    : '');
          final username = state.username.trim().isNotEmpty
              ? _formatUsername(state.username)
              : (authState.email?.trim().isNotEmpty == true
                    ? '@${authState.email!.split('@').first}'
                    : '');
          final avatarText = displayName.isNotEmpty
              ? displayName.characters.first.toUpperCase()
              : 'S';

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Avatar
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      avatarText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Name
                Text(
                  displayName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  username,
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 24),

                // Stats row
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder, width: 0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatColumn(
                        value: state.totalSent.toString(),
                        label: 'Sent',
                      ),
                      _divider(),
                      _StatColumn(
                        value: state.totalReceived.toString(),
                        label: 'Received',
                      ),
                      _divider(),
                      _StatColumn(
                        value: state.friendCount.toString(),
                        label: 'Friends',
                      ),
                      _divider(),
                      _StatColumn(
                        value: '${state.streakDays}d',
                        label: 'Streak',
                        color: AppColors.accentOrange,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Menu items
                _MenuItem(
                  icon: Icons.edit_outlined,
                  label: 'Edit Profile',
                  onTap: () => _showEditProfileSheet(context, state),
                ),
                _MenuItem(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thông báo mới hiển thị ở màn Home'),
                      ),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.lock_outline,
                  label: 'Privacy',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.palette_outlined,
                  label: 'Appearance',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.help_outline,
                  label: 'Help & Support',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.info_outline,
                  label: 'About Soulie',
                  onTap: () {},
                ),
                const SizedBox(height: 16),

                // Logout button
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.surfaceElevated,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: const Text(
                          'Logout',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                        content: const Text(
                          'Are you sure you want to logout?',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: AppColors.textTertiary),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              context.read<AuthBloc>().add(
                                const AuthLogoutRequested(),
                              );
                            },
                            child: const Text(
                              'Logout',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Version
                Text(
                  'Soulie v1.0.0',
                  style: TextStyle(
                    color: AppColors.textTertiary.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 36, color: AppColors.cardBorder);
  }
}

String _formatUsername(String username) {
  final normalized = username.trim().replaceFirst('@', '');
  if (normalized.isEmpty) {
    return '';
  }
  return '@$normalized';
}

Future<void> _showEditProfileSheet(
  BuildContext parentContext,
  ProfileState state,
) async {
  final nameController = TextEditingController(text: state.displayName);
  final usernameController = TextEditingController(
    text: state.username.trim().replaceFirst('@', ''),
  );

  await showModalBottomSheet<void>(
    context: parentContext,
    isScrollControlled: true,
    backgroundColor: AppColors.surfaceElevated,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      var isSaving = false;

      return StatefulBuilder(
        builder: (_, setModalState) {
          Future<void> submit() async {
            if (isSaving) {
              return;
            }

            setModalState(() => isSaving = true);
            try {
              await parentContext.read<SoulieRepository>().updateProfile(
                displayName: nameController.text.trim(),
                username: usernameController.text.trim(),
              );
              if (!sheetContext.mounted) {
                return;
              }
              Navigator.of(sheetContext).pop();
              if (!parentContext.mounted) {
                return;
              }
              parentContext.read<ProfileBloc>().add(const ProfileLoadRequested());
              ScaffoldMessenger.of(parentContext).showSnackBar(
                const SnackBar(content: Text('Đã cập nhật hồ sơ')),
              );
            } on SoulieRepositoryException catch (error) {
              if (!sheetContext.mounted) {
                return;
              }
              ScaffoldMessenger.of(sheetContext).showSnackBar(
                SnackBar(content: Text(error.message)),
              );
              setModalState(() => isSaving = false);
            } catch (_) {
              if (!sheetContext.mounted) {
                return;
              }
              ScaffoldMessenger.of(sheetContext).showSnackBar(
                const SnackBar(content: Text('Không thể cập nhật hồ sơ')),
              );
              setModalState(() => isSaving = false);
            }
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(sheetContext).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                _EditField(
                  controller: nameController,
                  label: 'Display name',
                  hint: 'Your display name',
                ),
                const SizedBox(height: 12),
                _EditField(
                  controller: usernameController,
                  label: 'Username',
                  hint: 'username',
                  prefixText: '@',
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  final Color? color;

  const _StatColumn({required this.value, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color ?? AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.textSecondary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.controller,
    required this.label,
    required this.hint,
    this.prefixText,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String? prefixText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textTertiary.withValues(alpha: 0.6),
            ),
            prefixText: prefixText,
            prefixStyle: const TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
