import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';
import 'pulse_api.dart';

/// Remembers, per account, the employment last chosen for a punch (a local preference only).
class EmploymentChoice {
  static String _key(String accountUUID) => 'pulse.employment.$accountUUID';

  static Future<String?> read(String accountUUID) async {
    try {
      return (await SharedPreferences.getInstance()).getString(
        _key(accountUUID),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> write(String accountUUID, String employmentUUID) async {
    try {
      await (await SharedPreferences.getInstance()).setString(
        _key(accountUUID),
        employmentUUID,
      );
    } catch (_) {
      // The choice is just a convenience; without storage it is asked again next time.
    }
  }

  /// The remembered employment while it is still in force, otherwise the first one.
  static String? resolve(List<PulseEmployment> employments, String? saved) {
    if (employments.isEmpty) return null;
    for (final employment in employments) {
      if (employment.employmentUUID == saved) return saved;
    }
    return employments.first.employmentUUID;
  }
}

/// Dropdown of the employments in force: company, location and registration number.
class EmploymentSelector extends StatelessWidget {
  const EmploymentSelector({
    super.key,
    required this.employments,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  final List<PulseEmployment> employments;
  final String? selected;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return DropdownButtonFormField<String>(
      key: ValueKey('employment-$selected'),
      initialValue: selected,
      isExpanded: true,
      decoration: InputDecoration(labelText: l.employmentLabel),
      items: [
        for (final employment in employments)
          DropdownMenuItem(
            value: employment.employmentUUID,
            child: Text(
              employment.label(l.employmentRegistrationShort),
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: enabled
          ? (value) {
              if (value != null) onChanged(value);
            }
          : null,
    );
  }
}
