// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Smart Calc';

  @override
  String get tabCalculator => 'Calculator';

  @override
  String get tabAiSolver => 'AI Solver';

  @override
  String get tabGraphing => 'Graphing';

  @override
  String get tabConverter => 'Converter';

  @override
  String get tabHistory => 'History';

  @override
  String get tabSettings => 'Settings';

  @override
  String get deg => 'DEG';

  @override
  String get rad => 'RAD';

  @override
  String get grad => 'GRAD';

  @override
  String get clear => 'Clear';

  @override
  String get equals => '=';

  @override
  String get errorInvalidExpression => 'Invalid expression';

  @override
  String get captureFromCamera => 'Capture from camera';

  @override
  String get pickFromGallery => 'Pick from gallery';

  @override
  String get solveQuick => 'Quick answer';

  @override
  String get solveDetailed => 'Step-by-step';

  @override
  String get solving => 'Solving…';

  @override
  String get solveAction => 'Solve';

  @override
  String get extractedEquation => 'Extracted equation';

  @override
  String get editEquation => 'Edit';

  @override
  String get retry => 'Retry';

  @override
  String get share => 'Share';

  @override
  String get copy => 'Copy';

  @override
  String get noHistory => 'No saved calculations yet';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get graphingTitle => 'Graph a function';

  @override
  String get graphingHint => 'e.g. sin(x) + 0.5*x';

  @override
  String get converterTitle => 'Unit Converter';

  @override
  String get fromValue => 'From';

  @override
  String get toValue => 'To';

  @override
  String get categoryLength => 'Length';

  @override
  String get categoryWeight => 'Weight';

  @override
  String get categoryTemperature => 'Temperature';

  @override
  String get categoryTime => 'Time';

  @override
  String get categoryAngle => 'Angle';

  @override
  String get categorySpeed => 'Speed';

  @override
  String get aiSolverIntro => 'Snap a math problem and let AI solve it.';

  @override
  String get needsBackendUrl =>
      'Set BACKEND_URL in your build to enable AI solving.';
}
