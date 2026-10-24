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

  /// No description provided for @forgotPassword.
  ///
  /// In en_US, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Reset your password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordHelp.
  ///
  /// In en_US, this message translates to:
  /// **'Your Pulse password is managed by your company. Ask the person in charge of your access for a new temporary password; on your next sign-in you will choose your own.'**
  String get forgotPasswordHelp;

  /// No description provided for @close.
  ///
  /// In en_US, this message translates to:
  /// **'Close'**
  String get close;

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

  /// No description provided for @officialTime.
  ///
  /// In en_US, this message translates to:
  /// **'Official time'**
  String get officialTime;

  /// No description provided for @nextPunch.
  ///
  /// In en_US, this message translates to:
  /// **'Next punch'**
  String get nextPunch;

  /// No description provided for @otherPunch.
  ///
  /// In en_US, this message translates to:
  /// **'Other punch'**
  String get otherPunch;

  /// No description provided for @onlineStatus.
  ///
  /// In en_US, this message translates to:
  /// **'Online'**
  String get onlineStatus;

  /// No description provided for @offlineStatus.
  ///
  /// In en_US, this message translates to:
  /// **'Offline'**
  String get offlineStatus;

  /// No description provided for @pendingPunches.
  ///
  /// In en_US, this message translates to:
  /// **'{count, plural, =1{1 punch waiting to be sent} other{{count} punches waiting to be sent}}'**
  String pendingPunches(int count);

  /// No description provided for @punchQueued.
  ///
  /// In en_US, this message translates to:
  /// **'No connection: the punch was kept and will be sent automatically.'**
  String get punchQueued;

  /// No description provided for @receipt.
  ///
  /// In en_US, this message translates to:
  /// **'Last receipt'**
  String get receipt;

  /// No description provided for @nsrLabel.
  ///
  /// In en_US, this message translates to:
  /// **'NSR {nsr}'**
  String nsrLabel(String nsr);

  /// No description provided for @sessionEnded.
  ///
  /// In en_US, this message translates to:
  /// **'Your session ended. Sign in again.'**
  String get sessionEnded;

  /// No description provided for @accountLocked.
  ///
  /// In en_US, this message translates to:
  /// **'Account temporarily locked. Try again in a few minutes.'**
  String get accountLocked;

  /// No description provided for @temporaryPasswordExpired.
  ///
  /// In en_US, this message translates to:
  /// **'Your temporary password expired. Ask your company for a new one.'**
  String get temporaryPasswordExpired;

  /// No description provided for @moduleUnavailable.
  ///
  /// In en_US, this message translates to:
  /// **'The time clock is not available for your company. Contact HR.'**
  String get moduleUnavailable;

  /// No description provided for @accessDenied.
  ///
  /// In en_US, this message translates to:
  /// **'Your access is not active. Contact HR.'**
  String get accessDenied;

  /// No description provided for @invalidPassword.
  ///
  /// In en_US, this message translates to:
  /// **'Current password is invalid.'**
  String get invalidPassword;

  /// No description provided for @passwordUnchanged.
  ///
  /// In en_US, this message translates to:
  /// **'The new password must be different from the current one.'**
  String get passwordUnchanged;

  /// No description provided for @pendingSignOutTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Punches waiting to be sent'**
  String get pendingSignOutTitle;

  /// No description provided for @pendingSignOutHelp.
  ///
  /// In en_US, this message translates to:
  /// **'Some punches were not sent yet. They stay on this device and are sent when you sign in again here.'**
  String get pendingSignOutHelp;

  /// No description provided for @cancel.
  ///
  /// In en_US, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @signOutAnyway.
  ///
  /// In en_US, this message translates to:
  /// **'Sign out'**
  String get signOutAnyway;

  /// No description provided for @noPunchesYet.
  ///
  /// In en_US, this message translates to:
  /// **'No punches yet.'**
  String get noPunchesYet;

  /// No description provided for @loading.
  ///
  /// In en_US, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @locationNote.
  ///
  /// In en_US, this message translates to:
  /// **'Your location is recorded only at the moment of each punch, when allowed.'**
  String get locationNote;

  /// No description provided for @sentLater.
  ///
  /// In en_US, this message translates to:
  /// **'Sent later'**
  String get sentLater;

  /// No description provided for @pendingSend.
  ///
  /// In en_US, this message translates to:
  /// **'Waiting to be sent'**
  String get pendingSend;

  /// No description provided for @navHome.
  ///
  /// In en_US, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navTimesheet.
  ///
  /// In en_US, this message translates to:
  /// **'Timesheet'**
  String get navTimesheet;

  /// No description provided for @today.
  ///
  /// In en_US, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @workDay.
  ///
  /// In en_US, this message translates to:
  /// **'Workday'**
  String get workDay;

  /// No description provided for @dayOff.
  ///
  /// In en_US, this message translates to:
  /// **'Day off'**
  String get dayOff;

  /// No description provided for @holiday.
  ///
  /// In en_US, this message translates to:
  /// **'Holiday'**
  String get holiday;

  /// No description provided for @holidayNamed.
  ///
  /// In en_US, this message translates to:
  /// **'Holiday: {name}'**
  String holidayNamed(String name);

  /// No description provided for @noSchedule.
  ///
  /// In en_US, this message translates to:
  /// **'No schedule set'**
  String get noSchedule;

  /// No description provided for @workedToday.
  ///
  /// In en_US, this message translates to:
  /// **'Worked today'**
  String get workedToday;

  /// No description provided for @statusWorking.
  ///
  /// In en_US, this message translates to:
  /// **'Working'**
  String get statusWorking;

  /// No description provided for @statusOnBreak.
  ///
  /// In en_US, this message translates to:
  /// **'On break'**
  String get statusOnBreak;

  /// No description provided for @statusOffDuty.
  ///
  /// In en_US, this message translates to:
  /// **'Off duty'**
  String get statusOffDuty;

  /// No description provided for @previousMonth.
  ///
  /// In en_US, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en_US, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @refresh.
  ///
  /// In en_US, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @retry.
  ///
  /// In en_US, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @totalWorked.
  ///
  /// In en_US, this message translates to:
  /// **'Worked'**
  String get totalWorked;

  /// No description provided for @totalExpected.
  ///
  /// In en_US, this message translates to:
  /// **'Expected'**
  String get totalExpected;

  /// No description provided for @totalBalance.
  ///
  /// In en_US, this message translates to:
  /// **'Balance'**
  String get totalBalance;

  /// No description provided for @totalOvertime.
  ///
  /// In en_US, this message translates to:
  /// **'Overtime'**
  String get totalOvertime;

  /// No description provided for @totalAbsences.
  ///
  /// In en_US, this message translates to:
  /// **'Absences'**
  String get totalAbsences;

  /// No description provided for @noPunchesDay.
  ///
  /// In en_US, this message translates to:
  /// **'No punches'**
  String get noPunchesDay;

  /// No description provided for @timesheetEmpty.
  ///
  /// In en_US, this message translates to:
  /// **'No days in this month yet.'**
  String get timesheetEmpty;

  /// No description provided for @unassignedPunches.
  ///
  /// In en_US, this message translates to:
  /// **'{count, plural, =1{1 punch still being processed} other{{count} punches still being processed}}'**
  String unassignedPunches(int count);

  /// No description provided for @flagAbsence.
  ///
  /// In en_US, this message translates to:
  /// **'Absence'**
  String get flagAbsence;

  /// No description provided for @flagMissingPunch.
  ///
  /// In en_US, this message translates to:
  /// **'Missing punch'**
  String get flagMissingPunch;

  /// No description provided for @flagLate.
  ///
  /// In en_US, this message translates to:
  /// **'Late'**
  String get flagLate;

  /// No description provided for @flagEarlyLeave.
  ///
  /// In en_US, this message translates to:
  /// **'Left early'**
  String get flagEarlyLeave;

  /// No description provided for @flagShortBreak.
  ///
  /// In en_US, this message translates to:
  /// **'Short break'**
  String get flagShortBreak;

  /// No description provided for @flagRestViolation.
  ///
  /// In en_US, this message translates to:
  /// **'Rest between shifts'**
  String get flagRestViolation;

  /// No description provided for @flagOvertimeLimit.
  ///
  /// In en_US, this message translates to:
  /// **'Overtime above limit'**
  String get flagOvertimeLimit;

  /// No description provided for @flagWorkedDayOff.
  ///
  /// In en_US, this message translates to:
  /// **'Worked on a day off'**
  String get flagWorkedDayOff;

  /// No description provided for @flagFlaggedPunch.
  ///
  /// In en_US, this message translates to:
  /// **'Flagged punch'**
  String get flagFlaggedPunch;

  /// No description provided for @flagNoSchedule.
  ///
  /// In en_US, this message translates to:
  /// **'No schedule'**
  String get flagNoSchedule;
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
