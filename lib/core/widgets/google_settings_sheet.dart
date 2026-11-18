import 'package:flutter/material.dart';

/// Modal bottom sheet for application preferences.
class GoogleSettingsSheet extends StatefulWidget {
  const GoogleSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      builder: (_) => const GoogleSettingsSheet(),
    );
  }

  @override
  State<GoogleSettingsSheet> createState() => _GoogleSettingsSheetState();
}

class _GoogleSettingsSheetState extends State<GoogleSettingsSheet> {
  bool _dynamicColorEnabled = true;
  bool _autoCalculateEnabled = true;
  bool _pinPriorityEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Settings',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 4.0),
                child: Text(
                  'APPEARANCE & THEME',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.palette_outlined),
                title: Text(
                  'Dynamic Color (Material You)',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Sample theme colors from system wallpaper',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                value: _dynamicColorEnabled,
                onChanged: (val) {
                  setState(() {
                    _dynamicColorEnabled = val;
                  });
                },
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 4.0),
                child: Text(
                  'SHOPPING PREFERENCES',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.checklist_rounded),
                title: Text(
                  'Instant Item Counter',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Keep shopping item counts updated automatically',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                value: _autoCalculateEnabled,
                onChanged: (val) {
                  setState(() {
                    _autoCalculateEnabled = val;
                  });
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.push_pin_outlined),
                title: Text(
                  'Pinned Stores at Top',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Keep favorite stores prioritized in date groups',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                value: _pinPriorityEnabled,
                onChanged: (val) {
                  setState(() {
                    _pinPriorityEnabled = val;
                  });
                },
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 4.0),
                child: Text(
                  'ABOUT',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: Text(
                  'HandCart v1.0.0',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Shopping list & store planner',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(
                  'Open Source Licenses',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationName: 'HandCart',
                    applicationVersion: '1.0.0',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
