import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: camel_case_types
// ignore_for_file: prefer_single_quotes
// ignore_for_file: unnecessary_brace_in_string_interps

//WARNING: This file is automatically generated. DO NOT EDIT, all your changes would be lost.

typedef void LocaleChangeCallback(Locale locale);

class I18n implements WidgetsLocalizations {
  const I18n();
  static Locale _locale;
  static bool _shouldReload = false;

  static set locale(Locale _newLocale) {
    _shouldReload = true;
    I18n._locale = _newLocale;
  }

  static const GeneratedLocalizationsDelegate delegate =
    const GeneratedLocalizationsDelegate();

  /// function to be invoked when changing the language
  static LocaleChangeCallback onLocaleChanged;

  static I18n of(BuildContext context) =>
    Localizations.of<I18n>(context, WidgetsLocalizations);

  @override
  TextDirection get textDirection => TextDirection.ltr;

  /// "Welcome"
  String get welcome => "Welcome";
  /// "Balance"
  String get balance => "Balance";
  /// "You have no transactions yet"
  String get noTransactions => "You have no transactions yet";
  /// "Receive coins"
  String get receiveCoins => "Receive coins";
  /// "Receive"
  String get receive => "Receive";
  /// "Buy"
  String get buy => "Buy";
  /// "Send"
  String get send => "Send";
  /// "Scan an QR code to send money"
  String get sendDescription => "Scan an QR code to send money";
  /// "Address"
  String get address => "Address";
  /// "Amount"
  String get amount => "Amount";
  /// "Scan the QR code to receive money"
  String get receiveDescription => "Scan the QR code to receive money";
  /// "Copy to clipboard"
  String get copyToClipboard => "Copy to clipboard";
  /// "Transaction sent successfully"
  String get transactionSent => "Transaction sent successfully";
}

class _I18n_en_US extends I18n {
  const _I18n_en_US();

  @override
  TextDirection get textDirection => TextDirection.ltr;
}

class _I18n_he_IL extends I18n {
  const _I18n_he_IL();

  /// "שלום"
  @override
  String get welcome => "שלום";
  /// "מאזן"
  @override
  String get balance => "מאזן";
  /// "אין לך פעולות עדיין"
  @override
  String get noTransactions => "אין לך פעולות עדיין";
  /// "קבל מטבעות"
  @override
  String get receiveCoins => "קבל מטבעות";
  /// "קבל"
  @override
  String get receive => "קבל";
  /// "עסקים"
  @override
  String get buy => "עסקים";
  /// "שלח"
  @override
  String get send => "שלח";

  @override
  TextDirection get textDirection => TextDirection.rtl;
}

class _I18n_es_ES extends I18n {
  const _I18n_es_ES();

  /// "Bienvenido"
  @override
  String get welcome => "Bienvenido";
  /// "Equilibrar"
  @override
  String get balance => "Equilibrar";
  /// "Aún no tienes transacciones"
  @override
  String get noTransactions => "Aún no tienes transacciones";
  /// "Recibir monedas"
  @override
  String get receiveCoins => "Recibir monedas";
  /// "Recibir"
  @override
  String get receive => "Recibir";
  /// "Comprar"
  @override
  String get buy => "Comprar";
  /// "Enviar"
  @override
  String get send => "Enviar";

  @override
  TextDirection get textDirection => TextDirection.ltr;
}

class GeneratedLocalizationsDelegate extends LocalizationsDelegate<WidgetsLocalizations> {
  const GeneratedLocalizationsDelegate();
  List<Locale> get supportedLocales {
    return const <Locale>[
      const Locale("en", "US"),
      const Locale("he", "IL"),
      const Locale("es", "ES")
    ];
  }

  LocaleResolutionCallback resolution({Locale fallback}) {
    return (Locale locale, Iterable<Locale> supported) {
      if (this.isSupported(locale)) {
        return locale;
      }
      final Locale fallbackLocale = fallback ?? supported.first;
      return fallbackLocale;
    };
  }

  @override
  Future<WidgetsLocalizations> load(Locale _locale) {
    I18n._locale ??= _locale;
    I18n._shouldReload = false;
    final Locale locale = I18n._locale;
    final String lang = locale != null ? locale.toString() : "";
    final String languageCode = locale != null ? locale.languageCode : "";
    if ("en_US" == lang) {
      return new SynchronousFuture<WidgetsLocalizations>(const _I18n_en_US());
    }
    else if ("he_IL" == lang) {
      return new SynchronousFuture<WidgetsLocalizations>(const _I18n_he_IL());
    }
    else if ("es_ES" == lang) {
      return new SynchronousFuture<WidgetsLocalizations>(const _I18n_es_ES());
    }
    else if ("en" == languageCode) {
      return new SynchronousFuture<WidgetsLocalizations>(const _I18n_en_US());
    }
    else if ("he" == languageCode) {
      return new SynchronousFuture<WidgetsLocalizations>(const _I18n_he_IL());
    }
    else if ("es" == languageCode) {
      return new SynchronousFuture<WidgetsLocalizations>(const _I18n_es_ES());
    }

    return new SynchronousFuture<WidgetsLocalizations>(const I18n());
  }

  @override
  bool isSupported(Locale locale) {
    for (var i = 0; i < supportedLocales.length && locale != null; i++) {
      final l = supportedLocales[i];
      if (l.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }

  @override
  bool shouldReload(GeneratedLocalizationsDelegate old) => I18n._shouldReload;
}