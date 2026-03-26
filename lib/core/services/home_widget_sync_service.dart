import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';

import '../../features/home/presentation/bloc/home_state.dart';
import '../../features/home/presentation/widgets/home_widget_preview.dart';

class HomeWidgetSyncService {
  const HomeWidgetSyncService();

  static const String iOSAppGroupId = 'group.com.soulie.soulie';
  static const String androidProviderName = 'SoulieHomeWidgetProvider';
  static const String iOSWidgetName = 'SoulieHomeWidget';
  static const String imageKey = 'soulie_widget_image';

  Future<void> configure() async {
    if (Platform.isIOS) {
      await HomeWidget.setAppGroupId(iOSAppGroupId);
    }
  }

  Future<void> syncHome(HomeState state) async {
    if (!_isSupportedPlatform) {
      return;
    }

    final title = state.recentlyShared.isEmpty
        ? 'Soulie'
        : '${state.recentlyShared.length} recent moments';
    final subtitle = state.recentlyShared.isEmpty
        ? 'Your close-friends camera is waiting.'
        : 'Catch up with ${state.recentlyShared.first.name} and your inner circle.';
    final highlight =
        (state.liveFeedMessage == null || state.liveFeedMessage!.trim().isEmpty)
        ? 'Share a tiny window into your day.'
        : state.liveFeedMessage!.trim();
    final friendNames = state.friendsGrid
        .take(3)
        .map((friend) => friend.name)
        .toList(growable: false);

    await Future.wait([
      HomeWidget.saveWidgetData<String>('title', title),
      HomeWidget.saveWidgetData<String>('subtitle', subtitle),
      HomeWidget.saveWidgetData<String>('highlight', highlight),
      HomeWidget.saveWidgetData<String>('friends', friendNames.join(' • ')),
      HomeWidget.saveWidgetData<int>(
        'notificationCount',
        state.notificationCount,
      ),
      HomeWidget.saveWidgetData<bool>(
        'hasMoments',
        state.recentlyShared.isNotEmpty,
      ),
    ]);

    await HomeWidget.renderFlutterWidget(
      HomeWidgetPreview(
        title: title,
        subtitle: subtitle,
        highlight: highlight,
        friendNames: friendNames,
      ),
      key: imageKey,
      logicalSize: const Size(320, 320),
    );

    await HomeWidget.updateWidget(
      name: androidProviderName,
      androidName: androidProviderName,
      iOSName: iOSWidgetName,
    );
  }

  bool get _isSupportedPlatform =>
      !Platform.isMacOS && !Platform.isLinux && !Platform.isWindows;
}
