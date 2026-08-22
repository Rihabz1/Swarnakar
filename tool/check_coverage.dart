import 'dart:io';

void main(List<String> arguments) {
  final minimum = arguments.isEmpty ? 10.0 : double.parse(arguments.first);
  final file = File('coverage/lcov.info');
  if (!file.existsSync()) {
    stderr.writeln('Coverage file not found: ${file.path}');
    exitCode = 2;
    return;
  }
  var found = 0;
  var hit = 0;
  for (final line in file.readAsLinesSync()) {
    if (line.startsWith('LF:')) found += int.parse(line.substring(3));
    if (line.startsWith('LH:')) hit += int.parse(line.substring(3));
  }
  final percentage = found == 0 ? 0.0 : hit * 100 / found;
  stdout.writeln(
    'Line coverage: ${percentage.toStringAsFixed(2)}% '
    '($hit/$found); required: ${minimum.toStringAsFixed(2)}%',
  );
  if (percentage < minimum) exitCode = 1;
}
