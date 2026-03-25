import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/support_ticket_options.dart';
import '../../../core/theme/app_theme_tokens.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/utils/page_transition.dart';
import '../../../domain/entities/pagination.dart';
import '../../../domain/entities/profile_settings.dart';
import '../../state/profile_settings_state.dart';
import '../../widgets/app_state_panel.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/pagination_bar.dart';
import '../../widgets/primary_button.dart';
import 'help_support_chat_page.dart';

class HelpSupportPage extends StatefulWidget {
  static const String routeName = '/profile/help';

  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  Timer? _pollTimer;
  int _activePage = 1;
  bool _paging = false;

  @override
  void initState() {
    super.initState();
    unawaited(
      ProfileSettingsState.refreshCurrentHelpTickets(page: _activePage),
    );
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticketListenable = ProfileSettingsState.isProvider
        ? ProfileSettingsState.providerHelpTickets
        : ProfileSettingsState.finderHelpTickets;
    final loadingListenable = ProfileSettingsState.isProvider
        ? ProfileSettingsState.providerHelpTicketsLoading
        : ProfileSettingsState.finderHelpTicketsLoading;
    final paginationListenable = ProfileSettingsState.isProvider
        ? ProfileSettingsState.providerHelpTicketsPagination
        : ProfileSettingsState.finderHelpTicketsPagination;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FBFF), Color(0xFFF1F5FC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -70,
              right: -40,
              child: _BackgroundGlow(size: 200, color: const Color(0x332563EB)),
            ),
            Positioned(
              top: 260,
              left: -50,
              child: _BackgroundGlow(size: 150, color: const Color(0x1A14B8A6)),
            ),
            SafeArea(
              child: ValueListenableBuilder<List<HelpSupportTicket>>(
                valueListenable: ticketListenable,
                builder: (context, tickets, _) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: loadingListenable,
                    builder: (context, loading, _) {
                      return ValueListenableBuilder<PaginationMeta>(
                        valueListenable: paginationListenable,
                        builder: (context, pagination, _) {
                          return RefreshIndicator(
                            onRefresh: () =>
                                ProfileSettingsState.refreshCurrentHelpTickets(
                                  page: _activePage,
                                ),
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.lg,
                                10,
                                AppSpacing.lg,
                                AppSpacing.xl,
                              ),
                              children: [
                                const AppTopBar(
                                  title: 'Help & support',
                                  actions: [],
                                ),
                                const SizedBox(height: 14),
                                _buildHeroCard(context),
                                const SizedBox(height: 18),
                                _buildCreateRequestCard(context),
                                const SizedBox(height: 18),
                                _buildInboxSection(
                                  context,
                                  tickets: tickets,
                                  loading: loading,
                                  pagination: pagination,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF0D5BD4), Color(0xFF4F8EFF), Color(0xFF9BC3FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F2563EB),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            child: const Text(
              'Support center',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Professional support, clearly organized',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreateRequestCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface(context),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppThemeTokens.outline(context)),
        boxShadow: AppThemeTokens.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('New request'),
          const SizedBox(height: 12),
          Text(
            'Start a support thread',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose a category and subcategory, then continue the conversation directly with admin support.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _SupportFeaturePill(
                      icon: Icons.category_outlined,
                      label: 'Topic-based',
                    ),
                    _SupportFeaturePill(
                      icon: Icons.forum_outlined,
                      label: 'Direct chat',
                    ),
                    _SupportFeaturePill(
                      icon: Icons.support_agent_rounded,
                      label: 'Admin follow-up',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _openCreateRequestDialog,
            icon: const Icon(Icons.add_comment_rounded),
            label: const Text('Create support request'),
          ),
        ],
      ),
    );
  }

  Widget _buildInboxSection(
    BuildContext context, {
    required List<HelpSupportTicket> tickets,
    required bool loading,
    required PaginationMeta pagination,
  }) {
    Widget content;
    if (loading && tickets.isEmpty) {
      content = const SizedBox(
        height: 320,
        child: Center(
          child: AppStatePanel.loading(title: 'Loading support tickets'),
        ),
      );
    } else if (tickets.isEmpty) {
      content = const AppStatePanel.empty(
        title: 'No support tickets yet',
        message: 'Your submitted support requests will appear here.',
      );
    } else {
      content = Column(
        children: [
          for (var index = 0; index < tickets.length; index++) ...[
            _buildTicketCard(tickets[index]),
            if (index < tickets.length - 1) const SizedBox(height: 12),
          ],
          if (pagination.totalPages > 1)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: PaginationBar(
                currentPage: _normalizedPage(pagination.page),
                totalPages: pagination.totalPages,
                loading: _paging,
                onPageSelected: _goToPage,
              ),
            ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFDCE4F2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Your tickets'),
          const SizedBox(height: 12),
          Text(
            'Support inbox',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppThemeTokens.textPrimary(context),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Open any thread below to continue the conversation with admin support.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppThemeTokens.textSecondary(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: content,
          ),
        ],
      ),
    );
  }

  Future<void> _openCreateRequestDialog() async {
    final created = await showDialog<HelpSupportTicket>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => const _CreateSupportRequestDialog(),
    );
    if (created == null || !mounted) return;
    _activePage = 1;
    await ProfileSettingsState.refreshCurrentHelpTickets(page: _activePage);
    if (!mounted) return;
    AppToast.success(context, 'Your request has been saved.');
    await _openChat(created);
  }

  Future<void> _goToPage(int page) async {
    final targetPage = _normalizedPage(page);
    final currentPage = ProfileSettingsState.isProvider
        ? ProfileSettingsState.providerHelpTicketsPagination.value.page
        : ProfileSettingsState.finderHelpTicketsPagination.value.page;
    if (_paging || targetPage == currentPage) return;
    setState(() => _paging = true);
    try {
      _activePage = targetPage;
      await ProfileSettingsState.refreshCurrentHelpTickets(page: targetPage);
    } finally {
      if (mounted) {
        setState(() => _paging = false);
      }
    }
  }

  int _normalizedPage(int page) {
    if (page < 1) return 1;
    return page;
  }

  Widget _buildTicketCard(HelpSupportTicket ticket) {
    final normalized = ticket.status.toLowerCase();
    final statusColor = switch (normalized) {
      'resolved' => AppColors.success,
      'closed' => AppColors.textSecondary,
      'waiting_on_user' => const Color(0xFF7C3AED),
      _ => const Color(0xFFF59E0B),
    };
    final latestText = ticket.lastMessageText.isEmpty
        ? ticket.message
        : ticket.lastMessageText;
    final displayTitle = ticket.title.trim().isEmpty
        ? supportTicketSubcategoryLabel(
            categoryId: ticket.category,
            subcategoryId: ticket.subcategory,
          )
        : ticket.title;
    final statusIcon = switch (normalized) {
      'resolved' => Icons.check_circle_outline_rounded,
      'closed' => Icons.lock_outline_rounded,
      'waiting_on_user' => Icons.mark_chat_unread_rounded,
      _ => Icons.support_agent_rounded,
    };
    final lastActivity = _formatDate(ticket.lastMessageAt ?? ticket.createdAt);
    final topicLabel = ticket.subcategory.isNotEmpty
        ? supportTicketSubcategoryLabel(
            categoryId: ticket.category,
            subcategoryId: ticket.subcategory,
          )
        : supportTicketCategoryLabel(ticket.category);
    final ticketType = supportTicketRequestTypeFromId(ticket.ticketType);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _openChat(ticket),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 430;
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppThemeTokens.surface(context),
                  AppThemeTokens.mutedSurface(context),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppThemeTokens.outline(context)),
              boxShadow: AppThemeTokens.cardShadow(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                compact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 52,
                                width: 52,
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Icon(statusIcon, color: statusColor),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  displayTitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppThemeTokens.textPrimary(context),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 17,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _ticketArrowButton(),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _ticketMetaPill(
                                supportTicketRequestTypeLabel(ticketType),
                                ticketType == SupportTicketRequestType.support
                                    ? AppColors.primary
                                    : const Color(0xFF0F766E),
                              ),
                              _ticketMetaPill(
                                _prettySupportStatus(normalized),
                                statusColor,
                              ),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 52,
                            width: 52,
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(statusIcon, color: statusColor),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    _ticketMetaPill(
                                      supportTicketRequestTypeLabel(ticketType),
                                      ticketType ==
                                              SupportTicketRequestType.support
                                          ? AppColors.primary
                                          : const Color(0xFF0F766E),
                                    ),
                                    Text(
                                      displayTitle,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppThemeTokens.textPrimary(
                                          context,
                                        ),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 17,
                                        height: 1.2,
                                      ),
                                    ),
                                    _ticketMetaPill(
                                      _prettySupportStatus(normalized),
                                      statusColor,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                _ticketMetaPanel(
                                  ticket: ticket,
                                  topicLabel: topicLabel,
                                  compact: false,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          _ticketArrowButton(),
                        ],
                      ),
                if (compact) ...[
                  const SizedBox(height: 12),
                  _ticketMetaPanel(
                    ticket: ticket,
                    topicLabel: topicLabel,
                    compact: true,
                  ),
                ],
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppThemeTokens.mutedSurface(context),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppThemeTokens.outline(context)),
                  ),
                  child: Text(
                    latestText,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppThemeTokens.textPrimary(context),
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppThemeTokens.surface(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppThemeTokens.outline(context)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Last activity $lastActivity',
                          style: TextStyle(
                            color: AppThemeTokens.textSecondary(context),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Open conversation',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _ticketArrowButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppThemeTokens.mutedSurface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeTokens.outline(context)),
      ),
      child: const Icon(
        Icons.arrow_forward_rounded,
        color: AppColors.primary,
        size: 18,
      ),
    );
  }

  Widget _ticketMetaPanel({
    required HelpSupportTicket ticket,
    required String topicLabel,
    required bool compact,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppThemeTokens.mutedSurface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeTokens.outline(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ticketInfoLine(
            label: 'Category',
            value: supportTicketCategoryLabel(ticket.category),
            compact: compact,
          ),
          const SizedBox(height: 8),
          _ticketInfoLine(
            label: 'Subcategory',
            value: topicLabel,
            compact: compact,
          ),
        ],
      ),
    );
  }

  Future<void> _openChat(HelpSupportTicket ticket) async {
    if (ticket.id.isEmpty) {
      AppToast.info(
        context,
        'Ticket is syncing. Pull to refresh then open chat.',
      );
      return;
    }
    await Navigator.of(
      context,
    ).push(slideFadeRoute(HelpSupportChatPage(ticket: ticket)));
    if (!mounted) return;
    unawaited(
      ProfileSettingsState.refreshCurrentHelpTickets(page: _activePage),
    );
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) async {
      if (!mounted || _paging) return;
      final isLoading = ProfileSettingsState.isProvider
          ? ProfileSettingsState.providerHelpTicketsLoading.value
          : ProfileSettingsState.finderHelpTicketsLoading.value;
      if (isLoading) return;
      try {
        await ProfileSettingsState.refreshCurrentHelpTickets(page: _activePage);
      } catch (_) {
        // Background refresh failure should not interrupt typing.
      }
    });
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
  }

  Widget _ticketMetaPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _ticketInfoLine({
    required String label,
    required String value,
    bool compact = false,
  }) {
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppThemeTokens.textSecondary(context),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: AppThemeTokens.textPrimary(context),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 84,
          child: Text(
            label,
            style: TextStyle(
              color: AppThemeTokens.textSecondary(context),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: AppThemeTokens.textPrimary(context),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppThemeTokens.softAccent(context, AppColors.primary),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _prettySupportStatus(String value) {
    switch (value.toLowerCase()) {
      case 'waiting_on_admin':
        return 'Waiting for admin';
      case 'waiting_on_user':
        return 'Waiting for your reply';
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      default:
        return 'Open';
    }
  }
}

class _CreateSupportRequestDialog extends StatefulWidget {
  const _CreateSupportRequestDialog();

  @override
  State<_CreateSupportRequestDialog> createState() =>
      _CreateSupportRequestDialogState();
}

class _CreateSupportRequestDialogState
    extends State<_CreateSupportRequestDialog> {
  bool _sending = false;
  late SupportTicketRequestType _selectedRequestType;
  late String _selectedCategoryId;
  late String _selectedSubcategoryId;

  @override
  void initState() {
    super.initState();
    _selectedRequestType = SupportTicketRequestType.help;
    final categories = _availableCategories();
    _selectedCategoryId = categories.first.id;
    _selectedSubcategoryId = categories.first.subcategories.first.id;
  }

  List<SupportTicketCategoryOption> _availableCategories() {
    final filtered = supportTicketCategoriesFor(
      isProvider: ProfileSettingsState.isProvider,
      requestType: _selectedRequestType,
    );
    return filtered.isNotEmpty ? filtered : supportTicketCategories;
  }

  @override
  Widget build(BuildContext context) {
    final categories = _availableCategories();
    final category = categories.firstWhere(
      (item) => item.id == _selectedCategoryId,
      orElse: () => categories.first,
    );
    final subcategory = supportTicketSubcategoryById(
      categoryId: _selectedCategoryId,
      subcategoryId: _selectedSubcategoryId,
    );

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920, maxHeight: 760),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppThemeTokens.surface(context),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppThemeTokens.outline(context)),
            boxShadow: AppThemeTokens.cardShadow(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppThemeTokens.mutedSurface(context),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppThemeTokens.outline(context)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        color: AppThemeTokens.softAccent(
                          context,
                          AppColors.primary,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.support_agent_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppThemeTokens.surface(context),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: AppThemeTokens.outline(context),
                              ),
                            ),
                            child: const Text(
                              'New request',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Create help or support request',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: AppThemeTokens.textPrimary(context),
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pick a request type first, then choose a topic that matches your role.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppThemeTokens.textSecondary(context),
                                  height: 1.45,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: _sending ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final selector = _buildTopicPanel(
                        context,
                        category: category,
                        subcategory: subcategory,
                      );

                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 560),
                          child: selector,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 560;
                  final button = PrimaryButton(
                    label: _sending ? 'Creating...' : 'Start support thread',
                    onPressed: _sending ? null : _sendTicket,
                  );
                  final note = Text(
                    'Support replies continue in chat after the thread is created.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  );

                  if (compact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [note, const SizedBox(height: 12), button],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: note),
                      const SizedBox(width: 16),
                      SizedBox(width: 240, child: button),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicPanel(
    BuildContext context, {
    required SupportTicketCategoryOption category,
    required SupportTicketSubcategoryOption subcategory,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDCE6F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFDCE6F7)),
            ),
            child: const Text(
              'Choose topic',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildRequestTypeToggle(context),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFDCE6F7)),
            ),
            child: Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(category.icon, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.label,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildSelectField(
            context,
            label: 'Category',
            value: _selectedCategoryId,
            items: _availableCategories()
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item.id,
                    child: Text(
                      item.label,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value == null) return;
              final next = supportTicketCategoryById(value);
              setState(() {
                _selectedCategoryId = value;
                _selectedSubcategoryId = next.subcategories.first.id;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildSelectField(
            context,
            label: 'Subcategory',
            value: _selectedSubcategoryId,
            items: category.subcategories
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item.id,
                    child: Text(
                      item.label,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _selectedSubcategoryId = value;
              });
            },
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFD9E6FA)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Support assistant preview',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subcategory.autoReply,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestTypeToggle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Request type',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: SupportTicketRequestType.values.map((type) {
            final active = _selectedRequestType == type;
            final label = supportTicketRequestTypeLabel(type);
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: type == SupportTicketRequestType.help ? 8 : 0,
                ),
                child: InkWell(
                  onTap: () {
                    final nextCategories = supportTicketCategoriesFor(
                      isProvider: ProfileSettingsState.isProvider,
                      requestType: type,
                    );
                    if (nextCategories.isEmpty) return;
                    setState(() {
                      _selectedRequestType = type;
                      _selectedCategoryId = nextCategories.first.id;
                      _selectedSubcategoryId =
                          nextCategories.first.subcategories.first.id;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xFFEAF1FF)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: active
                            ? AppColors.primary
                            : const Color(0xFFDCE6F7),
                      ),
                    ),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: active
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(growable: false),
        ),
      ],
    );
  }

  Widget _buildSelectField(
    BuildContext context, {
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          key: ValueKey<String>('dialog_select_${label}_$value'),
          initialValue: value,
          isExpanded: true,
          items: items,
          selectedItemBuilder: (context) => items
              .map(
                (item) => Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _dropdownItemLabel(item),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(growable: false),
          onChanged: onChanged,
          decoration: const InputDecoration(
            suffixIcon: Icon(Icons.keyboard_arrow_down_rounded),
          ),
        ),
      ],
    );
  }

  String _dropdownItemLabel(DropdownMenuItem<String> item) {
    final child = item.child;
    if (child is Text && child.data != null) {
      return child.data!;
    }
    return item.value ?? '';
  }

  Future<void> _sendTicket() async {
    setState(() => _sending = true);

    try {
      final categoryLabel = supportTicketCategoryLabel(_selectedCategoryId);
      final subcategoryLabel = supportTicketSubcategoryLabel(
        categoryId: _selectedCategoryId,
        subcategoryId: _selectedSubcategoryId,
      );
      final created = await ProfileSettingsState.addCurrentHelpTicket(
        HelpSupportTicket(
          ticketType: supportTicketRequestTypeId(_selectedRequestType),
          title: subcategoryLabel,
          message:
              '${supportTicketRequestTypeLabel(_selectedRequestType)} request created for $categoryLabel / $subcategoryLabel.',
          category: _selectedCategoryId,
          subcategory: _selectedSubcategoryId,
          priority: supportTicketPriority(
            categoryId: _selectedCategoryId,
            subcategoryId: _selectedSubcategoryId,
          ),
          createdAt: DateTime.now(),
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(created);
    } catch (error) {
      if (!mounted) return;
      AppToast.error(context, _supportThreadErrorMessage(error));
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  String _supportThreadErrorMessage(Object error) {
    final text = error.toString().toLowerCase();
    if (text.contains('401') || text.contains('403')) {
      return 'Your session expired. Please sign in again and retry.';
    }
    if (text.contains('timeout')) {
      return 'Support is taking too long to respond. Please try again.';
    }
    return 'Unable to start the support thread. Please try again.';
  }
}

class _SupportFeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SupportFeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FE),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFDCE6F7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  final double size;
  final Color color;

  const _BackgroundGlow({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
