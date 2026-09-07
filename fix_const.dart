import 'dart:io';

void main() {
  final dir = Directory('lib');
  for (var file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart') && !file.path.contains('theme.dart')) {
      var content = file.readAsStringSync();
      var lines = content.split('\n');
      bool changed = false;
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].contains('AppColors.of(context)')) {
          if (lines[i].contains('const ')) {
            lines[i] = lines[i].replaceAll('const ', '');
            changed = true;
          }
          for (int j = 1; j <= 5; j++) {
            if (i - j >= 0) {
              if (lines[i - j].contains('const ')) {
                lines[i - j] = lines[i - j].replaceAll('const ', '');
                changed = true;
                break;
              }
              if (lines[i - j].trim().endsWith(';')) break; 
              if (lines[i - j].trim().startsWith('return')) break; 
            }
          }
        }
      }
      if (changed) {
        file.writeAsStringSync(lines.join('\n'));
      }
    }
  }
}
