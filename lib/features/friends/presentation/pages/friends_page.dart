import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../soulie/data/soulie_repository.dart';
import '../bloc/friends_bloc.dart';
import '../bloc/friends_event.dart';
import '../bloc/friends_state.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FriendsBloc(
        soulieRepository: context.read<SoulieRepository>(),
      )..add(const FriendsLoadRequested()),
      child: const _FriendsView(),
    );
  }
}

class _FriendsView extends StatelessWidget {
  const _FriendsView();

  Future<void> _openManageFriendsSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ManageFriendsSheet(
        onFriendsChanged: () {
          context.read<FriendsBloc>().add(const FriendsLoadRequested());
        },
      ),
    );
    if (context.mounted) {
      context.read<FriendsBloc>().add(const FriendsLoadRequested());
    }
  }

  void _showShareCode(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final email = authState.email?.trim() ?? '';
    final displayName = authState.displayName?.trim() ?? 'Soulie user';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Your Soulie ID',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                email.isEmpty ? 'Chưa có email để chia sẻ' : email,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Circle',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _openManageFriendsSheet(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: const Icon(
                            Icons.person_add_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _showShareCode(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: const Icon(
                            Icons.qr_code_scanner,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder, width: 0.5),
                ),
                child: TextField(
                  onChanged: (value) =>
                      context.read<FriendsBloc>().add(FriendsSearchChanged(value)),
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Search friends...',
                    hintStyle: TextStyle(
                      color: AppColors.textTertiary.withValues(alpha: 0.6),
                      fontSize: 15,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Section: Recent Activity
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Recent Activity',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            // Friends list
            Expanded(
              child: BlocBuilder<FriendsBloc, FriendsState>(
                builder: (context, state) {
                  if (state.status == FriendsStatus.loading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  if (state.status == FriendsStatus.error) {
                    return Center(
                      child: Text(
                        'Không thể tải danh sách bạn bè',
                        style: TextStyle(
                          color: AppColors.textTertiary.withValues(alpha: 0.8),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: state.filteredFriends.length,
                    itemBuilder: (context, index) {
                      return _FriendListItem(
                        friend: state.filteredFriends[index],
                        onChanged: () {
                          context.read<FriendsBloc>().add(
                            const FriendsLoadRequested(),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _FriendListItem extends StatelessWidget {
  final Friend friend;
  final VoidCallback onChanged;

  const _FriendListItem({required this.friend, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColors.primary,
      AppColors.accentPink,
      AppColors.accentCyan,
      AppColors.accentPurple,
      AppColors.accentOrange,
    ];
    final colorIndex = friend.name.hashCode.abs() % colors.length;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: () => context.pushNamed(
          'chat',
          pathParameters: {'friendKey': friend.id},
          queryParameters: {'name': friend.name},
        ),
        leading: Stack(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors[colorIndex].withValues(alpha: 0.15),
              ),
              child: Center(
                child: Text(
                  friend.name[0],
                  style: TextStyle(
                    color: colors[colorIndex],
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            if (friend.isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.online,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          friend.name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          friend.status,
          style: TextStyle(
            color: friend.status == 'Typing...'
                ? AppColors.primary
                : AppColors.textTertiary,
            fontSize: 13,
          ),
        ),
        trailing: PopupMenuButton<String>(
          color: AppColors.surfaceElevated,
          icon: Icon(
            Icons.more_horiz_rounded,
            color: AppColors.primary.withValues(alpha: 0.7),
          ),
          onSelected: (value) async {
            if (value != 'remove') {
              return;
            }

            final confirmed = await showDialog<bool>(
              context: context,
              builder: (dialogContext) {
                return AlertDialog(
                  backgroundColor: AppColors.surfaceElevated,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Text(
                    'Remove friend',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  content: Text(
                    'Ngừng kết nối với ${friend.name}?',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: const Text(
                        'Remove',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                );
              },
            );

            if (confirmed != true || !context.mounted) {
              return;
            }

            try {
              await context.read<SoulieRepository>().removeFriend(friend.id);
              onChanged();
              if (!context.mounted) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã xóa ${friend.name} khỏi danh sách bạn bè')),
              );
            } on SoulieRepositoryException catch (error) {
              if (!context.mounted) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error.message)),
              );
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem<String>(
              value: 'remove',
              child: Text('Remove friend'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManageFriendsSheet extends StatefulWidget {
  const _ManageFriendsSheet({required this.onFriendsChanged});

  final VoidCallback onFriendsChanged;

  @override
  State<_ManageFriendsSheet> createState() => _ManageFriendsSheetState();
}

class _ManageFriendsSheetState extends State<_ManageFriendsSheet> {
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  bool _isActing = false;
  String _query = '';
  List<SoulieUserSuggestion> _suggestions = const [];
  List<SoulieFriendRequestData> _incoming = const [];
  List<SoulieFriendRequestData> _outgoing = const [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final repository = context.read<SoulieRepository>();
      final results = await Future.wait<dynamic>([
        repository.discoverUsers(query: _query),
        repository.fetchFriendRequests(),
      ]);
      final requests = results[1] as SoulieFriendRequestsData;
      if (!mounted) {
        return;
      }
      setState(() {
        _suggestions = results[0] as List<SoulieUserSuggestion>;
        _incoming = requests.incoming;
        _outgoing = requests.outgoing;
        _isLoading = false;
      });
    } on SoulieRepositoryException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể tải danh sách kết nối')),
      );
    }
  }

  Future<void> _runAction(Future<void> Function() action) async {
    if (_isActing) {
      return;
    }

    setState(() => _isActing = true);
    try {
      await action();
      widget.onFriendsChanged();
      await _loadData();
    } on SoulieRepositoryException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể hoàn thành thao tác')),
      );
    } finally {
      if (mounted) {
        setState(() => _isActing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manage Friends',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            onChanged: (value) {
              _query = value.trim();
              _loadData();
            },
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search by name, username, email',
              hintStyle: TextStyle(
                color: AppColors.textTertiary.withValues(alpha: 0.6),
              ),
              prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
              filled: true,
              fillColor: AppColors.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_incoming.isNotEmpty) ...[
                      const _SectionTitle('Incoming Requests'),
                      ..._incoming.map(
                        (request) => _RequestTile(
                          request: request,
                          isActing: _isActing,
                          onAccept: () => _runAction(
                            () => context.read<SoulieRepository>().acceptFriendRequest(
                              request.id,
                            ),
                          ),
                          onReject: () => _runAction(
                            () => context.read<SoulieRepository>().rejectFriendRequest(
                              request.id,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_outgoing.isNotEmpty) ...[
                      const _SectionTitle('Sent Requests'),
                      ..._outgoing.map(
                        (request) => _OutgoingRequestTile(request: request),
                      ),
                      const SizedBox(height: 16),
                    ],
                    const _SectionTitle('Discover'),
                    if (_suggestions.isEmpty)
                      Text(
                        'Không tìm thấy gợi ý phù hợp',
                        style: TextStyle(
                          color: AppColors.textTertiary.withValues(alpha: 0.7),
                        ),
                      )
                    else
                      ..._suggestions.map(
                        (suggestion) => _SuggestionTile(
                          suggestion: suggestion,
                          isActing: _isActing,
                          onAdd: suggestion.relation == 'none'
                              ? () => _runAction(
                                  () => context
                                      .read<SoulieRepository>()
                                      .createFriendRequest(
                                        targetUserId: suggestion.id,
                                      ),
                                )
                              : null,
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.suggestion,
    required this.isActing,
    this.onAdd,
  });

  final SoulieUserSuggestion suggestion;
  final bool isActing;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
        child: Text(
          suggestion.name.isNotEmpty ? suggestion.name[0].toUpperCase() : '?',
          style: const TextStyle(color: AppColors.primary),
        ),
      ),
      title: Text(
        suggestion.name,
        style: const TextStyle(color: AppColors.textPrimary),
      ),
      subtitle: Text(
        '@${suggestion.username}',
        style: const TextStyle(color: AppColors.textTertiary),
      ),
      trailing: onAdd == null
          ? Text(
              _relationLabel(suggestion.relation),
              style: TextStyle(
                color: AppColors.textTertiary.withValues(alpha: 0.8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            )
          : TextButton(
              onPressed: isActing ? null : onAdd,
              child: const Text('Add'),
            ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({
    required this.request,
    required this.isActing,
    required this.onAccept,
    required this.onReject,
  });

  final SoulieFriendRequestData request;
  final bool isActing;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColors.accentCyan.withValues(alpha: 0.15),
        child: Text(
          request.user.name.isNotEmpty
              ? request.user.name[0].toUpperCase()
              : '?',
          style: const TextStyle(color: AppColors.accentCyan),
        ),
      ),
      title: Text(
        request.user.name,
        style: const TextStyle(color: AppColors.textPrimary),
      ),
      subtitle: Text(
        '@${request.user.username}',
        style: const TextStyle(color: AppColors.textTertiary),
      ),
      trailing: Wrap(
        spacing: 8,
        children: [
          TextButton(
            onPressed: isActing ? null : onReject,
            child: const Text(
              'Reject',
              style: TextStyle(color: AppColors.error),
            ),
          ),
          ElevatedButton(
            onPressed: isActing ? null : onAccept,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }
}

class _OutgoingRequestTile extends StatelessWidget {
  const _OutgoingRequestTile({required this.request});

  final SoulieFriendRequestData request;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColors.accentPurple.withValues(alpha: 0.15),
        child: Text(
          request.user.name.isNotEmpty
              ? request.user.name[0].toUpperCase()
              : '?',
          style: const TextStyle(color: AppColors.accentPurple),
        ),
      ),
      title: Text(
        request.user.name,
        style: const TextStyle(color: AppColors.textPrimary),
      ),
      subtitle: Text(
        '@${request.user.username}',
        style: const TextStyle(color: AppColors.textTertiary),
      ),
      trailing: Text(
        'Pending',
        style: TextStyle(
          color: AppColors.textTertiary.withValues(alpha: 0.8),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

String _relationLabel(String relation) {
  switch (relation) {
    case 'friend':
      return 'Friends';
    case 'incoming_request':
      return 'Incoming';
    case 'outgoing_request':
      return 'Sent';
    default:
      return 'Add';
  }
}
