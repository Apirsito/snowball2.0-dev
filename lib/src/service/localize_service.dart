
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowball/lang/en_us.dart';
import 'package:snowball/lang/es_es.dart';

class LocalizationService extends Translations {
  // Default locale
  static final locale = Locale('en', 'US');

  // fallbackLocale saves the day when the locale gets in trouble
  static final fallbackLocale = Locale('es', 'CO');

  // Supported languages
  // Needs to be same order with locales
  static final langs = [
    'English',
    'Español'
  ];

  // Supported locales
  // Needs to be same order with langs
  static final locales = [
    Locale('en', 'US'),
    Locale('es', 'CO'),
  ];

  // Keys and their translations
  // Translations are separated maps in `lang` file
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': enUS, // lang/en_us.dart
    'es_CO': esES, // lang/es_es.dart
  };

  // Gets locale from language, and updates the locale
  void changeLocale(String lang) {
    final locale = getLocaleFromLanguage(lang);
    Get.updateLocale(locale);
  }

  // Finds language in `langs` list and returns it as Locale
  Locale getLocaleFromLanguage(String lang) {
    for (int i = 0; i < langs.length; i++) {
      if (lang == langs[i]) return locales[i];
    }
    return Get.locale;
  }
}