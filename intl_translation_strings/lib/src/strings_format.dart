import 'package:intl_translation/generate_localized.dart';
import 'package:intl_translation/src/intl_message.dart';

import 'package:intl_translation_format/intl_translation_format.dart';

import 'strings_parser.dart';

class StringsFormat extends SingleLanguageFormat {
  static const key = 'strings';

  @override
  String get supportedFileExtension => 'strings';

  @override
  String buildTemplateFileContent(
    TranslationTemplate catalog,
  ) {
    final messages = catalog.messages;
    var json = '\n';
    messages.forEach((key, value) {
      final message = ICUParser().icuMessageToString(value);
      json += '"$key"= "$message";\n';
    });
    return json;
  }



  @override
  List<TranslationFile> buildTemplate(
    TranslationTemplate catalog,
  ) {
    final file = TranslationFile(
      content: buildTemplateFileContent(catalog),
      name: '${catalog.projectName}_${catalog.defaultLocal}',
      fileExtension: supportedFileExtension,
    );

    final pluralFakeFile = TranslationFile(
      content: fakePluralFile,
      name: '${catalog.projectName}_${catalog.defaultLocal}',
      fileExtension: 'stringsdict',
    );

    return [file, pluralFakeFile];
  }

  @override
  Map<String, TranslatedMessage> parseFile(
    String content, {
    MessageGeneration generation,
  }) {
    final values = SimpleStringsParser().parser.parse(content);

    if (values.isFailure) throw BadFormatException(values.message);
    return values.value.map((key, value) {
      final message = BasicTranslatedMessage(key, Message.from(value, null));
      return MapEntry(key, message);
    });
  }
}

class BadFormatException implements Exception {
  String message;
  BadFormatException(this.message);
  @override
  String toString() {
    return message;
  }
}

final fakePluralFile = '''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>%d tasks waiting for action</key>
        <dict>
            <key>NSStringLocalizedFormatKey</key>
            <string>%#@tasks@ waiting for action</string>
            <key>tasks</key>
            <dict>
                <key>NSStringFormatSpecTypeKey</key>
                <string>NSStringPluralRuleType</string>
                <key>NSStringFormatValueTypeKey</key>
                <string>d</string>
                <key>one</key>
                <string>A task is</string>
                <key>two</key>
                <string>Two tasks are</string>
                <key>other</key>
                <string>%d tasks are</string>
            </dict>
        </dict>
    </dict>
</plist>
''';