import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/app_toast.dart';
import '../../state/profile_settings_state.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/primary_button.dart';

class ProviderAvailabilityPage extends StatefulWidget {
  const ProviderAvailabilityPage({super.key});

  @override
  State<ProviderAvailabilityPage> createState() => _ProviderAvailabilityPageState();
}

class _ProviderAvailabilityPageState extends State<ProviderAvailabilityPage> {
  static const List<String> _weekdayLabels = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  late List<DateTime> _blockedDates;
  late final DateTime _firstDay;
  late final DateTime _lastDay;
  bool _loading = false;
  bool _saving = false;
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final normalizedNow = DateTime(now.year, now.month, now.day);
    _firstDay = normalizedNow;
    _lastDay = DateTime(now.year + 1, now.month, now.day);
    _focusedDay = normalizedNow;
    _blockedDates = _normalizedBlockedDates(
      ProfileSettingsState.providerProfession.value.blockedDates,
    );
    _loadLatestAvailability();
  }

  void _toggleDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    setState(() {
      final index = _blockedDates.indexWhere((d) => isSameDay(d, normalized));
      if (index >= 0) {
        _blockedDates.removeAt(index);
      } else {
        _blockedDates.add(normalized);
      }
      _blockedDates = _normalizedBlockedDates(_blockedDates);
    });
  }

  List<DateTime> _normalizedBlockedDates(Iterable<DateTime> source) {
    final unique = <String, DateTime>{};
    for (final date in source) {
      final normalized = DateTime(date.year, date.month, date.day);
      unique['${normalized.year}-${normalized.month}-${normalized.day}'] =
          normalized;
    }
    final values = unique.values.toList(growable: true)
      ..sort((a, b) => a.compareTo(b));
    return values;
  }

  bool _sameBlockedDates(Iterable<DateTime> left, Iterable<DateTime> right) {
    final normalizedLeft = _normalizedBlockedDates(left);
    final normalizedRight = _normalizedBlockedDates(right);
    if (normalizedLeft.length != normalizedRight.length) return false;
    for (var index = 0; index < normalizedLeft.length; index++) {
      if (!isSameDay(normalizedLeft[index], normalizedRight[index])) {
        return false;
      }
    }
    return true;
  }

  Future<void> _loadLatestAvailability() async {
    setState(() => _loading = true);
    try {
      await ProfileSettingsState.syncProviderProfessionFromBackend();
      if (!mounted) return;
      setState(() {
        _blockedDates = _normalizedBlockedDates(
          ProfileSettingsState.providerProfession.value.blockedDates,
        );
      });
    } catch (_) {
      // Keep last known local availability if refresh fails.
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final current = ProfileSettingsState.providerProfession.value;
      final updated = current.copyWith(blockedDates: _blockedDates);
      await ProfileSettingsState.saveProviderProfession(updated);
      final synced = await ProfileSettingsState.syncProviderProfessionFromBackend();
      if (!synced) {
        throw Exception('Could not reload saved availability from backend.');
      }
      final persistedDates = ProfileSettingsState.providerProfession.value.blockedDates;
      if (!_sameBlockedDates(persistedDates, _blockedDates)) {
        throw Exception('Blocked dates were not stored on backend.');
      }
      if (!mounted) return;
      AppToast.success(context, 'Availability updated successfully.');
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      final raw = error.toString().replaceFirst('Exception: ', '').trim();
      final message = raw.isEmpty ? 'Failed to update availability.' : raw;
      AppToast.error(context, message);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const AppTopBar(title: 'Availability'),
              const SizedBox(height: 16),
              Text(
                'Tap a date once to block it. Tap it again to unblock it. Blocked dates are hidden from customers.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: LinearProgressIndicator(minHeight: 2),
                ),
              Expanded(
                child: TableCalendar(
                  firstDay: _firstDay,
                  lastDay: _lastDay,
                  focusedDay: _focusedDay,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  daysOfWeekHeight: 28,
                  rowHeight: 52,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() => _focusedDay = focusedDay);
                    _toggleDate(selectedDay);
                  },
                  onPageChanged: (focusedDay) {
                    setState(() => _focusedDay = focusedDay);
                  },
                  selectedDayPredicate: (day) => _blockedDates.any((d) => isSameDay(d, day)),
                  calendarBuilders: CalendarBuilders(
                    dowBuilder: (context, day) {
                      final label = _weekdayLabels[day.weekday - 1];
                      return Center(
                        child: Text(
                          label,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    },
                  ),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: const TextStyle(color: Colors.white),
                    todayDecoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: const TextStyle(color: AppColors.primary),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    weekendStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_blockedDates.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Blocked Dates (${_blockedDates.length})',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _blockedDates.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final date = _blockedDates[index];
                      return Chip(
                        label: Text('${date.day}/${date.month}'),
                        onDeleted: () => _toggleDate(date),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        backgroundColor: AppColors.danger.withValues(alpha: 0.1),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
              PrimaryButton(
                label: _saving ? 'Saving...' : 'Save Changes',
                onPressed: (_saving || _loading) ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
