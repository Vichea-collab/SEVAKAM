import 'package:flutter/material.dart';
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
  late List<DateTime> _blockedDates;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _blockedDates = List<DateTime>.from(
      ProfileSettingsState.providerProfession.value.blockedDates,
    );
  }

  void _toggleDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    setState(() {
      if (_blockedDates.any((d) => d.year == normalized.year && d.month == normalized.month && d.day == normalized.day)) {
        _blockedDates.removeWhere((d) => d.year == normalized.year && d.month == normalized.month && d.day == normalized.day);
      } else {
        _blockedDates.add(normalized);
      }
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final current = ProfileSettingsState.providerProfession.value;
      final updated = current.copyWith(blockedDates: _blockedDates);
      await ProfileSettingsState.saveProviderProfession(updated);
      if (!mounted) return;
      AppToast.success(context, 'Availability updated successfully.');
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      AppToast.error(context, 'Failed to update availability.');
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
                'Select dates to block your availability. Customers won\'t be able to book you on these days.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: CalendarDatePicker(
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  onDateChanged: _toggleDate,
                  selectableDayPredicate: (date) => true,
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
                onPressed: _saving ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
