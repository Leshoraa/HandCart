import 'dart:async';
import 'dart:io';

/// Developer tool to run Flutter with automatic hot-reload on file changes.
///
/// Watches the `lib/` directory and sends 'r' to flutter run whenever a
/// Dart file is modified, while preserving interactive terminal controls
/// (e.g. manual 'r', 'R' hot restart, 'q' quit).
void main(List<String> args) async {
  stdout.writeln('\x1B[32m====================================================\x1B[0m');
  stdout.writeln('\x1B[32m   HandCart Flutter Auto Hot-Reload Watcher         \x1B[0m');
  stdout.writeln('\x1B[32m====================================================\x1B[0m');
  stdout.writeln('Watching "lib/" for file changes. Hot reload will trigger automatically.');
  stdout.writeln('Interactive controls remain active ("R" = restart, "q" = quit, "h" = help).\n');

  final flutterExecutable = Platform.isWindows ? 'flutter.bat' : 'flutter';

  final process = await Process.start(
    flutterExecutable,
    ['run', ...args],
    mode: ProcessStartMode.normal,
  );

  // Pipe stdout and stderr directly to console
  unawaited(stdout.addStream(process.stdout));
  unawaited(stderr.addStream(process.stderr));

  // Forward manual terminal input to Flutter process
  try {
    if (stdin.hasTerminal) {
      stdin.lineMode = false;
      stdin.echoMode = false;
    }
  } catch (_) {
    // Ignore terminal mode errors on non-standard consoles
  }

  stdin.listen(
    (data) {
      process.stdin.add(data);
    },
    onError: (_) {},
  );

  // Watch the lib directory for any changes
  final libDir = Directory('lib');
  Timer? debounceTimer;
  DateTime lastReload = DateTime.now();

  if (libDir.existsSync()) {
    libDir.watch(recursive: true).listen(
      (event) {
        if (!event.path.endsWith('.dart')) return;

        debounceTimer?.cancel();
        debounceTimer = Timer(const Duration(milliseconds: 600), () async {
          final now = DateTime.now();
          if (now.difference(lastReload).inMilliseconds < 1000) return;
          lastReload = now;

          stdout.writeln('\n\x1B[33m[Auto-Reload] Change detected: ${event.path}. Triggering hot reload...\x1B[0m');
          process.stdin.writeln('r');
          try {
            await process.stdin.flush();
          } catch (_) {}
        });
      },
      onError: (_) {},
    );
  }

  final exitCode = await process.exitCode;
  exit(exitCode);
}
