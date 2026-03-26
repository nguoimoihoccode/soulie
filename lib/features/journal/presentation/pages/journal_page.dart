import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../soulie/data/soulie_repository.dart';
import '../bloc/journal_bloc.dart';
import '../bloc/journal_event.dart';
import '../bloc/journal_state.dart';

class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => JournalBloc(
        soulieRepository: context.read<SoulieRepository>(),
      )..add(const JournalLoadRequested()),
      child: const _JournalView(),
    );
  }
}

class _JournalView extends StatefulWidget {
  const _JournalView();

  @override
  State<_JournalView> createState() => _JournalViewState();
}

class _JournalViewState extends State<_JournalView> {
  String? _lastOpenedMomentId;

  void _markOpenedIfNeeded(String momentId) {
    if (_lastOpenedMomentId == momentId) {
      return;
    }
    _lastOpenedMomentId = momentId;
    context.read<SoulieRepository>().markMomentOpened(momentId).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<JournalBloc, JournalState>(
        builder: (context, state) {
          if (state.status == JournalStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state.status == JournalStatus.error) {
            return Center(
              child: Text(
                state.errorMessage ?? 'Không thể tải lịch sử',
                style: TextStyle(
                  color: AppColors.textTertiary.withValues(alpha: 0.8),
                ),
              ),
            );
          }

          final entries = state.selectedTab == 0
              ? state.sentEntries
              : state.receivedEntries;

          if (state.selectedTab == 1 && entries.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _markOpenedIfNeeded(entries.first.id);
              }
            });
          }

          if (entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_outlined,
                      size: 48,
                      color: AppColors.textTertiary.withValues(alpha: 0.3)),
                  const SizedBox(height: 12),
                  Text(
                    'No photos yet',
                    style: TextStyle(
                      color: AppColors.textTertiary.withValues(alpha: 0.5),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              // Full-screen vertical swipe (TikTok-style navigation)
              PageView.builder(
                scrollDirection: Axis.vertical,
                itemCount: entries.length,
                onPageChanged: (index) {
                  if (state.selectedTab == 1 && index < entries.length) {
                    _markOpenedIfNeeded(entries[index].id);
                  }
                },
                itemBuilder: (context, index) {
                  return _LocketHistoryEntry(
                    entry: entries[index],
                    index: index,
                    totalCount: entries.length,
                  );
                },
              ),

              // Top bar: "History" title + tab selector
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 8,
                    bottom: 12,
                    left: 20,
                    right: 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.background,
                        AppColors.background.withValues(alpha: 0.8),
                        AppColors.background.withValues(alpha: 0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'History',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Sent / Received toggle
                      Container(
                        height: 36,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _TabButton(
                              label: 'Received',
                              isSelected: state.selectedTab == 1,
                              onTap: () => context
                                  .read<JournalBloc>()
                                  .add(const JournalTabChanged(1)),
                            ),
                            _TabButton(
                              label: 'Sent',
                              isSelected: state.selectedTab == 0,
                              onTap: () => context
                                  .read<JournalBloc>()
                                  .add(const JournalTabChanged(0)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textTertiary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// Locket-style history entry: clean, minimal, photo-centric
class _LocketHistoryEntry extends StatefulWidget {
  final JournalEntry entry;
  final int index;
  final int totalCount;

  const _LocketHistoryEntry({
    required this.entry,
    required this.index,
    required this.totalCount,
  });

  @override
  State<_LocketHistoryEntry> createState() => _LocketHistoryEntryState();
}

class _LocketHistoryEntryState extends State<_LocketHistoryEntry>
    with TickerProviderStateMixin {
  bool _showHeart = false;
  bool _showReactionBar = false;
  AnimationController? _heartController;

  void _onDoubleTap() {
    _heartController?.dispose();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    setState(() => _showHeart = true);
    _heartController!.forward().then((_) {
      if (mounted) setState(() => _showHeart = false);
      _heartController?.dispose();
      _heartController = null;
    });
  }

  @override
  void dispose() {
    _heartController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final topPad = MediaQuery.of(context).padding.top;
    final colors = [
      AppColors.accentPink,
      AppColors.accentCyan,
      AppColors.accentPurple,
      AppColors.primary,
      AppColors.accentOrange,
      AppColors.accentRose,
    ];
    final color = colors[widget.index % colors.length];

    return GestureDetector(
      onDoubleTap: _onDoubleTap,
      onLongPress: () => setState(() => _showReactionBar = !_showReactionBar),
      child: Container(
        height: screenH,
        color: AppColors.background,
        child: Stack(
          children: [
            // Main content in Column so nothing gets clipped
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(top: topPad > 0 ? 60 : 72),
                child: Column(
                  children: [
                    // Photo card - SQUARE with rounded corners (Locket style)
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: AspectRatio(
                            aspectRatio: 1.0, // Square
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                gradient: LinearGradient(
                                  colors: [
                                    color.withValues(alpha: 0.08),
                                    AppColors.surfaceLight,
                                    color.withValues(alpha: 0.04),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: color.withValues(alpha: 0.1),
                                  width: 0.5,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(32),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_rounded,
                                        size: 56,
                                        color: color.withValues(alpha: 0.15),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${widget.index + 1} / ${widget.totalCount}',
                                        style: TextStyle(
                                          color: color.withValues(alpha: 0.3),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Friend info row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [color, color.withValues(alpha: 0.6)],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              widget.entry.friendName[0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.entry.friendName,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '· ${widget.entry.timeLabel}',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),

                    if (widget.entry.caption != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.entry.caption!,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const SizedBox(height: 10),

                    // Message input + action buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          // Message input
                          Expanded(
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.cardBorder,
                                  width: 0.5,
                                ),
                              ),
                              child: TextField(
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Send a message...',
                                  hintStyle: TextStyle(
                                    color: AppColors.textTertiary
                                        .withValues(alpha: 0.5),
                                    fontSize: 13,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Like
                          _SimpleAction(
                            icon: Icons.favorite_border_rounded,
                            onTap: _onDoubleTap,
                          ),
                          const SizedBox(width: 6),
                          // Download
                          _SimpleAction(
                            icon: Icons.download_outlined,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // Double-tap heart animation
            if (_showHeart && _heartController != null)
              Center(
                child: AnimatedBuilder(
                  animation: _heartController!,
                  builder: (context, child) {
                    final scale = 1.0 +
                        Curves.elasticOut
                                .transform(_heartController!.value) *
                            0.5;
                    final opacity = _heartController!.value < 0.7
                        ? 1.0
                        : 1.0 -
                            ((_heartController!.value - 0.7) / 0.3);
                    return Opacity(
                      opacity: opacity.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: scale,
                        child: Icon(
                          Icons.favorite_rounded,
                          color: AppColors.primary,
                          size: 80,
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Reaction bar (long press to show)
            if (_showReactionBar)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: ['❤️', '😂', '😍', '🔥', '😢', '👏']
                        .map((emoji) => GestureDetector(
                              onTap: () =>
                                  setState(() => _showReactionBar = false),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8),
                                child: Text(emoji,
                                    style: const TextStyle(fontSize: 32)),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SimpleAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SimpleAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.cardBorder,
            width: 0.5,
          ),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
    );
  }
}
