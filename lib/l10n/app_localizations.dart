import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

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
    Locale('en'),
    Locale('en', 'US'),
    Locale('es'),
    Locale('es', 'ES'),
    Locale('pt'),
    Locale('pt', 'BR'),
  ];

  /// No description provided for @language.
  ///
  /// In en_US, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @system.
  ///
  /// In en_US, this message translates to:
  /// **'System language'**
  String get system;

  /// No description provided for @eyebrow.
  ///
  /// In en_US, this message translates to:
  /// **'Employee access'**
  String get eyebrow;

  /// No description provided for @title.
  ///
  /// In en_US, this message translates to:
  /// **'Access your time clock'**
  String get title;

  /// No description provided for @subtitle.
  ///
  /// In en_US, this message translates to:
  /// **'Use the access code provided by your company.'**
  String get subtitle;

  /// No description provided for @heroTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Your workday.\nConnected.'**
  String get heroTitle;

  /// No description provided for @heroText.
  ///
  /// In en_US, this message translates to:
  /// **'Record your working hours and follow your workday in one place.'**
  String get heroText;

  /// No description provided for @supportLabel.
  ///
  /// In en_US, this message translates to:
  /// **'Need access? Contact your company'**
  String get supportLabel;

  /// No description provided for @privacy.
  ///
  /// In en_US, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @terms.
  ///
  /// In en_US, this message translates to:
  /// **'Terms of use'**
  String get terms;

  /// No description provided for @employeeCode.
  ///
  /// In en_US, this message translates to:
  /// **'Employee access code'**
  String get employeeCode;

  /// No description provided for @password.
  ///
  /// In en_US, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en_US, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en_US, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @showPassword.
  ///
  /// In en_US, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en_US, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @required.
  ///
  /// In en_US, this message translates to:
  /// **'This field is required.'**
  String get required;

  /// No description provided for @invalidCredentials.
  ///
  /// In en_US, this message translates to:
  /// **'Invalid access code or password.'**
  String get invalidCredentials;

  /// No description provided for @networkError.
  ///
  /// In en_US, this message translates to:
  /// **'Unable to connect. Please try again.'**
  String get networkError;

  /// No description provided for @requestError.
  ///
  /// In en_US, this message translates to:
  /// **'Unable to complete the request. Please try again or contact your company.'**
  String get requestError;

  /// No description provided for @rateLimited.
  ///
  /// In en_US, this message translates to:
  /// **'Too many attempts. Wait before trying again.'**
  String get rateLimited;

  /// No description provided for @firstAccess.
  ///
  /// In en_US, this message translates to:
  /// **'Create your new password'**
  String get firstAccess;

  /// No description provided for @firstAccessHelp.
  ///
  /// In en_US, this message translates to:
  /// **'Replace your temporary password before recording your time.'**
  String get firstAccessHelp;

  /// No description provided for @newPassword.
  ///
  /// In en_US, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en_US, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @passwordLength.
  ///
  /// In en_US, this message translates to:
  /// **'Use at least 10 characters.'**
  String get passwordLength;

  /// No description provided for @passwordMismatch.
  ///
  /// In en_US, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordMismatch;

  /// No description provided for @changePassword.
  ///
  /// In en_US, this message translates to:
  /// **'Save new password'**
  String get changePassword;

  /// No description provided for @signedIn.
  ///
  /// In en_US, this message translates to:
  /// **'Signed in successfully.'**
  String get signedIn;

  /// No description provided for @passwordChanged.
  ///
  /// In en_US, this message translates to:
  /// **'Password changed successfully.'**
  String get passwordChanged;

  /// No description provided for @signedOut.
  ///
  /// In en_US, this message translates to:
  /// **'Signed out.'**
  String get signedOut;

  /// No description provided for @employee.
  ///
  /// In en_US, this message translates to:
  /// **'Employee'**
  String get employee;

  /// No description provided for @clockIn.
  ///
  /// In en_US, this message translates to:
  /// **'Clock in'**
  String get clockIn;

  /// No description provided for @breakStart.
  ///
  /// In en_US, this message translates to:
  /// **'Break start'**
  String get breakStart;

  /// No description provided for @breakEnd.
  ///
  /// In en_US, this message translates to:
  /// **'Break end'**
  String get breakEnd;

  /// No description provided for @clockOut.
  ///
  /// In en_US, this message translates to:
  /// **'Clock out'**
  String get clockOut;

  /// No description provided for @recentPunches.
  ///
  /// In en_US, this message translates to:
  /// **'Recent punches'**
  String get recentPunches;

  /// No description provided for @punchSaved.
  ///
  /// In en_US, this message translates to:
  /// **'Punch saved.'**
  String get punchSaved;

  /// No description provided for @punchSynced.
  ///
  /// In en_US, this message translates to:
  /// **'Punch already synced.'**
  String get punchSynced;

  /// No description provided for @importantUpdate.
  ///
  /// In en_US, this message translates to:
  /// **'Important update'**
  String get importantUpdate;

  /// No description provided for @newVersion.
  ///
  /// In en_US, this message translates to:
  /// **'New version available'**
  String get newVersion;

  /// No description provided for @updateNow.
  ///
  /// In en_US, this message translates to:
  /// **'Update now'**
  String get updateNow;

  /// No description provided for @later.
  ///
  /// In en_US, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @updateHelp.
  ///
  /// In en_US, this message translates to:
  /// **'A new version is ready. You will sign in again after updating.'**
  String get updateHelp;
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
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en':
      {
        switch (locale.countryCode) {
          case 'US':
            return AppLocalizationsEnUs();
        }
        break;
      }
    case 'es':
      {
        switch (locale.countryCode) {
          case 'ES':
            return AppLocalizationsEsEs();
        }
        break;
      }
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
