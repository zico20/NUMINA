// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'الحاسبة الذكية';

  @override
  String get tabCalculator => 'الحاسبة';

  @override
  String get tabAiSolver => 'الحل بالذكاء';

  @override
  String get tabGraphing => 'الرسم البياني';

  @override
  String get tabConverter => 'محول الوحدات';

  @override
  String get tabHistory => 'السجل';

  @override
  String get tabSettings => 'الإعدادات';

  @override
  String get deg => 'درجة';

  @override
  String get rad => 'راديان';

  @override
  String get grad => 'غراد';

  @override
  String get clear => 'مسح';

  @override
  String get equals => '=';

  @override
  String get errorInvalidExpression => 'صيغة غير صحيحة';

  @override
  String get captureFromCamera => 'التقاط بالكاميرا';

  @override
  String get pickFromGallery => 'اختيار من المعرض';

  @override
  String get solveQuick => 'حل سريع';

  @override
  String get solveDetailed => 'حل تفصيلي';

  @override
  String get solving => 'جارٍ الحل…';

  @override
  String get solveAction => 'حلّ';

  @override
  String get extractedEquation => 'المعادلة المستخرجة';

  @override
  String get editEquation => 'تعديل';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get share => 'مشاركة';

  @override
  String get copy => 'نسخ';

  @override
  String get noHistory => 'لا توجد عمليات محفوظة بعد';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsTheme => 'المظهر';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeSystem => 'حسب النظام';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get graphingTitle => 'ارسم دالة';

  @override
  String get graphingHint => 'مثال: sin(x) + 0.5*x';

  @override
  String get converterTitle => 'محول الوحدات';

  @override
  String get fromValue => 'من';

  @override
  String get toValue => 'إلى';

  @override
  String get categoryLength => 'الطول';

  @override
  String get categoryWeight => 'الوزن';

  @override
  String get categoryTemperature => 'درجة الحرارة';

  @override
  String get categoryTime => 'الوقت';

  @override
  String get categoryAngle => 'الزاوية';

  @override
  String get categorySpeed => 'السرعة';

  @override
  String get aiSolverIntro => 'صوّر مسألتك ودع الذكاء الاصطناعي يحلها.';

  @override
  String get needsBackendUrl =>
      'حدّد BACKEND_URL في build لتفعيل الحل بالذكاء الاصطناعي.';
}
