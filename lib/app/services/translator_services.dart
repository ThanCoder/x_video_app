import 'package:translator/translator.dart';

class TranslatorServices {
  static final TranslatorServices instance = TranslatorServices._();
  TranslatorServices._();
  factory TranslatorServices() => instance;

  final translator = GoogleTranslator();

  Future<String> translate(String input,
      {String from = 'auto', String to = 'en'}) async {
    final res = await translator.translate(input, from: from, to: to);
    return res.text;
  }
}
