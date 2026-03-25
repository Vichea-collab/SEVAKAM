import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../constants/app_colors.dart';

Future<DateTime?> showAppCalendarDatePicker(
  BuildContext context, {
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  String? helpText,
  String confirmText = 'Apply',
  String cancelText = 'Cancel',
  SelectableDayPredicate? selectableDayPredicate,
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (context) => _AdvancedCalendarDialog(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: helpText,
      confirmText: confirmText,
      cancelText: cancelText,
      selectableDayPredicate: selectableDayPredicate,
    ),
  );
}

class _AdvancedCalendarDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String? helpText;
  final String confirmText;
  final String cancelText;
  final SelectableDayPredicate? selectableDayPredicate;

  const _AdvancedCalendarDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.helpText,
    required this.confirmText,
    required this.cancelText,
    this.selectableDayPredicate,
  });

  @override
  State<_AdvancedCalendarDialog> createState() => _AdvancedCalendarDialogState();
}

class _AdvancedCalendarDialogState extends State<_AdvancedCalendarDialog> {
  static const List<String> _weekdayLabels = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  late DateTime _focusedDay;
  late DateTime _selectedDay;

  bool _isSelectable(DateTime day) {
    return widget.selectableDayPredicate?.call(day) ?? true;
  }

  DateTime _firstSelectableDate({
    required DateTime start,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    var candidate = DateTime(start.year, start.month, start.day);
    if (candidate.isBefore(firstDate)) {
      candidate = DateTime(firstDate.year, firstDate.month, firstDate.day);
    }
    if (candidate.isAfter(lastDate)) {
      candidate = DateTime(lastDate.year, lastDate.month, lastDate.day);
    }
    for (
      var day = candidate;
      !day.isAfter(lastDate);
      day = day.add(const Duration(days: 1))
    ) {
      if (_isSelectable(day)) return day;
    }
    return candidate;
  }

  @override
  void initState() {
    super.initState();
    // Clamp initialDate within range to prevent TableCalendar crash
    final safeDate = widget.initialDate.isBefore(widget.firstDate)
        ? widget.firstDate
        : widget.initialDate.isAfter(widget.lastDate)
            ? widget.lastDate
            : widget.initialDate;

    final resolvedDate = _isSelectable(safeDate)
        ? safeDate
        : _firstSelectableDate(
            start: safeDate,
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
          );

    _focusedDay = resolvedDate;
    _selectedDay = resolvedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.helpText != null) ...[
              Text(
                widget.helpText!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
            ],
            TableCalendar(
              firstDay: widget.firstDate,
              lastDay: widget.lastDate,
              focusedDay: _focusedDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              daysOfWeekHeight: 28,
              rowHeight: 52,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                if (widget.selectableDayPredicate != null &&
                    !widget.selectableDayPredicate!(selectedDay)) {
                  return;
                }
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              enabledDayPredicate: widget.selectableDayPredicate,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: const TextStyle(color: AppColors.primary),
                disabledTextStyle: const TextStyle(color: AppColors.danger),
              ),
              calendarBuilders: CalendarBuilders(
                dowBuilder: (context, day) {
                  final label = _weekdayLabels[day.weekday - 1];
                  return Center(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  );
                },
                disabledBuilder: (context, day, focusedDay) {
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEE2E2),
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            '${day.day}',
                            style: const TextStyle(color: AppColors.danger),
                          ),
                          Transform.rotate(
                            angle: -0.5,
                            child: Container(
                              width: 20,
                              height: 1,
                              color: AppColors.danger.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(widget.cancelText),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isSelectable(_selectedDay)
                      ? () => Navigator.pop(context, _selectedDay)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(widget.confirmText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
