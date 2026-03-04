import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/page_transition.dart';
import '../../../domain/entities/chat.dart';
import '../../../domain/entities/pagination.dart';
import '../../state/chat_state.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_state_panel.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/pagination_bar.dart';
import '../../widgets/pressable_scale.dart';
import 'chat_conversation_page.dart';

class ChatListPage extends StatefulWidget {
  static const String routeName = '/chat';

  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  static const Duration _doublePullWindow = Duration(seconds: 2);
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _isPaging = false;
  bool _refreshInProgress = false;
  DateTime? _lastPullAt;

  @override
  void initState() {
    super.initState();
    ChatState.refresh(page: 1);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ChatThread>>(
      valueListenable: ChatState.threads,
      builder: (context, threads, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: ChatState.loading,
          builder: (context, isLoading, _) {
            return ValueListenableBuilder<PaginationMeta>(
              valueListenable: ChatState.threadPagination,
              builder: (context, pagination, _) {
                final query = _query.trim().toLowerCase();
                final filtered = query.isEmpty
                    ? threads
                    : threads
                          .where(
                            (chat) =>
                                chat.title.toLowerCase().contains(query) ||
                                chat.subtitle.toLowerCase().contains(query),
                          )
                          .toList();
                final resultCount = query.isEmpty
                    ? pagination.totalItems
                    : filtered.length;
                final currentPage = _normalizedPage(pagination.page);

                final Widget body;
                if (isLoading && threads.isEmpty) {
                  body = _pullablePlaceholder(
                    const AppStatePanel.loading(title: 'Loading conversations'),
                  );
                } else if (filtered.isEmpty) {
                  body = _pullablePlaceholder(
                    AppStatePanel.empty(
                      title: 'No conversation yet',
                      message: query.isEmpty
                          ? 'Start chatting with a provider or customer.'
                          : 'No messages matched your search.',
                    ),
                  );
                } else {
                  body = ListView.separated(
                    key: ValueKey<String>(
                      'chat_list_${filtered.length}_${currentPage}_$query',
                    ),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final thread = filtered[index];
                      return _ChatThreadTile(thread: thread);
                    },
                  );
                }

                return Scaffold(
                  body: SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
                          child: AppTopBar(title: 'Chats'),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) =>
                                setState(() => _query = value),
                            decoration: InputDecoration(
                              hintText: 'Search for messages or users',
                              prefixIcon: const Icon(Icons.search),
                              suffixText: '$resultCount',
                              isDense: true,
                            ),
                          ),
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _handleRefresh,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              child: body,
                            ),
                          ),
                        ),
                        if (pagination.totalPages > 1 && query.isEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                            child: PaginationBar(
                              currentPage: currentPage,
                              totalPages: pagination.totalPages,
                              loading: _isPaging,
                              onPageSelected: _goToPage,
                            ),
                          ),
                      ],
                    ),
                  ),
                  bottomNavigationBar: const AppBottomNav(
                    current: AppBottomTab.home,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _goToPage(int page) async {
    final targetPage = _normalizedPage(page);
    if (_isPaging || targetPage == ChatState.threadPagination.value.page) {
      return;
    }
    setState(() => _isPaging = true);
    try {
      await ChatState.refresh(page: targetPage);
    } finally {
      if (mounted) {
        setState(() => _isPaging = false);
      }
    }
  }

  Future<void> _handleRefresh() async {
    final now = DateTime.now();
    final last = _lastPullAt;
    final isSecondPull =
        last != null && now.difference(last) <= _doublePullWindow;
    if (!isSecondPull) {
      _lastPullAt = now;
      return;
    }

    _lastPullAt = null;
    if (_refreshInProgress) return;
    _refreshInProgress = true;
    try {
      await ChatState.refresh(page: 1);
      await ChatState.refreshUnreadCount();
    } catch (_) {
      // Keep current chat list when refresh fails.
    } finally {
      _refreshInProgress = false;
    }
  }

  Widget _pullablePlaceholder(Widget child) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: <Widget>[
        const SizedBox(height: 160),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: child,
        ),
      ],
    );
  }

  int _normalizedPage(int page) {
    if (page < 1) return 1;
    return page;
  }
}

class _ChatThreadTile extends StatelessWidget {
  final ChatThread thread;

  const _ChatThreadTile({required this.thread});

  @override
  Widget build(BuildContext context) {
    final hasUnread = thread.unreadCount > 0;

    Future<void> openConversation() async {
      final currentPage = ChatState.threadPagination.value.page;
      await ChatState.markThreadAsRead(thread.id, syncThreads: true);
      if (!context.mounted) return;
      await Navigator.push(
        context,
        slideFadeRoute(ChatConversationPage(thread: thread)),
      );
      if (!context.mounted) return;
      await ChatState.refresh(page: currentPage < 1 ? 1 : currentPage);
      await ChatState.refreshUnreadCount();
    }

    return PressableScale(
      onTap: openConversation,
      child: InkWell(
        onTap: openConversation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage(thread.avatarPath),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            thread.title,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  fontWeight: hasUnread
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                ),
                          ),
                        ),
                        Text(
                          _timeLabel(thread.updatedAt),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      thread.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: hasUnread
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: hasUnread
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (hasUnread)
                Container(
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.all(Radius.circular(11)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    thread.unreadCount > 99 ? '99+' : '${thread.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
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

  String _timeLabel(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final suffix = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }
}
