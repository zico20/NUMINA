import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Calc'**
  String get appTitle;

  /// No description provided for @tabCalculator.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get tabCalculator;

  /// No description provided for @tabAiSolver.
  ///
  /// In en, this message translates to:
  /// **'AI Solver'**
  String get tabAiSolver;

  /// No description provided for @tabGraphing.
  ///
  /// In en, this message translates to:
  /// **'Graphing'**
  String get tabGraphing;

  /// No description provided for @tabConverter.
  ///
  /// In en, this message translates to:
  /// **'Converter'**
  String get tabConverter;

  /// No description provided for @tabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tabHistory;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @deg.
  ///
  /// In en, this message translates to:
  /// **'DEG'**
  String get deg;

  /// No description provided for @rad.
  ///
  /// In en, this message translates to:
  /// **'RAD'**
  String get rad;

  /// No description provided for @grad.
  ///
  /// In en, this message translates to:
  /// **'GRAD'**
  String get grad;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @equals.
  ///
  /// In en, this message translates to:
  /// **'='**
  String get equals;

  /// No description provided for @errorInvalidExpression.
  ///
  /// In en, this message translates to:
  /// **'Invalid expression'**
  String get errorInvalidExpression;

  /// No description provided for @captureFromCamera.
  ///
  /// In en, this message translates to:
  /// **'Capture from camera'**
  String get captureFromCamera;

  /// No description provided for @pickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Pick from gallery'**
  String get pickFromGallery;

  /// No description provided for @solveQuick.
  ///
  /// In en, this message translates to:
  /// **'Quick answer'**
  String get solveQuick;

  /// No description provided for @solveDetailed.
  ///
  /// In en, this message translates to:
  /// **'Step-by-step'**
  String get solveDetailed;

  /// No description provided for @solving.
  ///
  /// In en, this message translates to:
  /// **'Solving…'**
  String get solving;

  /// No description provided for @solveAction.
  ///
  /// In en, this message translates to:
  /// **'Solve'**
  String get solveAction;

  /// No description provided for @extractedEquation.
  ///
  /// In en, this message translates to:
  /// **'Extracted equation'**
  String get extractedEquation;

  /// No description provided for @editEquation.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editEquation;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No saved calculations yet'**
  String get noHistory;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @graphingTitle.
  ///
  /// In en, this message translates to:
  /// **'Graph a function'**
  String get graphingTitle;

  /// No description provided for @graphingHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. sin(x) + 0.5*x'**
  String get graphingHint;

  /// No description provided for @converterTitle.
  ///
  /// In en, this message translates to:
  /// **'Unit Converter'**
  String get converterTitle;

  /// No description provided for @fromValue.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromValue;

  /// No description provided for @toValue.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toValue;

  /// No description provided for @categoryLength.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get categoryLength;

  /// No description provided for @categoryWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get categoryWeight;

  /// No description provided for @categoryTemperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get categoryTemperature;

  /// No description provided for @categoryTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get categoryTime;

  /// No description provided for @categoryAngle.
  ///
  /// In en, this message translates to:
  /// **'Angle'**
  String get categoryAngle;

  /// No description provided for @categorySpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get categorySpeed;

  /// No description provided for @aiSolverIntro.
  ///
  /// In en, this message translates to:
  /// **'Snap a math problem and let AI solve it.'**
  String get aiSolverIntro;

  /// No description provided for @needsBackendUrl.
  ///
  /// In en, this message translates to:
  /// **'Set BACKEND_URL in your build to enable AI solving.'**
  String get needsBackendUrl;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
