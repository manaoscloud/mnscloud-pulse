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

  /// No description provided for @versionUnsupported.
  ///
  /// In en_US, this message translates to:
  /// **'This app version is no longer supported. Update the app from the store or with your administrator to continue.'**
  String get versionUnsupported;

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

  /// No description provided for @punchNoLocationNotice.
  ///
  /// In en_US, this message translates to:
  /// **'Punch recorded without location; HR will see it flagged.'**
  String get punchNoLocationNotice;

  /// No description provided for @receiptsLast48h.
  ///
  /// In en_US, this message translates to:
  /// **'Receipts of the last 48 hours'**
  String get receiptsLast48h;

  /// No description provided for @receiptsLast48hEmpty.
  ///
  /// In en_US, this message translates to:
  /// **'No receipts in the last 48 hours.'**
  String get receiptsLast48hEmpty;

  /// No description provided for @receiptFieldEmployer.
  ///
  /// In en_US, this message translates to:
  /// **'Employer'**
  String get receiptFieldEmployer;

  /// No description provided for @receiptFieldEmployee.
  ///
  /// In en_US, this message translates to:
  /// **'Employee'**
  String get receiptFieldEmployee;

  /// No description provided for @receiptFieldWhen.
  ///
  /// In en_US, this message translates to:
  /// **'Date and time'**
  String get receiptFieldWhen;

  /// No description provided for @receiptFieldCollector.
  ///
  /// In en_US, this message translates to:
  /// **'Collector'**
  String get receiptFieldCollector;

  /// No description provided for @receiptFieldHash.
  ///
  /// In en_US, this message translates to:
  /// **'Verification code (SHA-256)'**
  String get receiptFieldHash;

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
  /// **'Some punches were not sent yet. They stay protected on this device and are sent automatically as soon as there is a connection (or when you sign in here again).'**
  String get pendingSignOutHelp;

  /// No description provided for @offlineEntry.
  ///
  /// In en_US, this message translates to:
  /// **'Offline mode: your punches stay protected on this device and are sent automatically when the connection is back.'**
  String get offlineEntry;

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

  /// Button that installs the web app (PWA).
  ///
  /// In en_US, this message translates to:
  /// **'Install app'**
  String get installApp;

  /// How to install on iPhone/iPad, where browsers have no install prompt.
  ///
  /// In en_US, this message translates to:
  /// **'In Safari, tap Share and then \"Add to Home Screen\".'**
  String get installIosSteps;

  /// No description provided for @navRequests.
  ///
  /// In en_US, this message translates to:
  /// **'Requests'**
  String get navRequests;

  /// No description provided for @back.
  ///
  /// In en_US, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @requestNew.
  ///
  /// In en_US, this message translates to:
  /// **'New request'**
  String get requestNew;

  /// No description provided for @requestMissingPunch.
  ///
  /// In en_US, this message translates to:
  /// **'Forgot a mark'**
  String get requestMissingPunch;

  /// No description provided for @requestPunchContest.
  ///
  /// In en_US, this message translates to:
  /// **'Contest a mark'**
  String get requestPunchContest;

  /// No description provided for @requestAbsence.
  ///
  /// In en_US, this message translates to:
  /// **'Absence'**
  String get requestAbsence;

  /// No description provided for @absenceMedicalCertificate.
  ///
  /// In en_US, this message translates to:
  /// **'Medical certificate'**
  String get absenceMedicalCertificate;

  /// No description provided for @absenceJustified.
  ///
  /// In en_US, this message translates to:
  /// **'Justified absence'**
  String get absenceJustified;

  /// No description provided for @absenceDayOff.
  ///
  /// In en_US, this message translates to:
  /// **'Day off'**
  String get absenceDayOff;

  /// No description provided for @absenceLeave.
  ///
  /// In en_US, this message translates to:
  /// **'Leave'**
  String get absenceLeave;

  /// No description provided for @requestPending.
  ///
  /// In en_US, this message translates to:
  /// **'Pending'**
  String get requestPending;

  /// No description provided for @requestApproved.
  ///
  /// In en_US, this message translates to:
  /// **'Approved'**
  String get requestApproved;

  /// No description provided for @requestRejected.
  ///
  /// In en_US, this message translates to:
  /// **'Rejected'**
  String get requestRejected;

  /// No description provided for @requestCancelled.
  ///
  /// In en_US, this message translates to:
  /// **'Cancelled'**
  String get requestCancelled;

  /// No description provided for @requestEmpty.
  ///
  /// In en_US, this message translates to:
  /// **'You have no requests yet. Use “New request” if you forgot a mark, need to contest one or have to justify an absence.'**
  String get requestEmpty;

  /// No description provided for @requestSent.
  ///
  /// In en_US, this message translates to:
  /// **'Request sent. You will see the answer here.'**
  String get requestSent;

  /// No description provided for @requestCancelTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Cancel request?'**
  String get requestCancelTitle;

  /// No description provided for @requestCancelText.
  ///
  /// In en_US, this message translates to:
  /// **'The request leaves the queue of your manager.'**
  String get requestCancelText;

  /// No description provided for @requestCancelAction.
  ///
  /// In en_US, this message translates to:
  /// **'Cancel request'**
  String get requestCancelAction;

  /// No description provided for @requestDate.
  ///
  /// In en_US, this message translates to:
  /// **'Date'**
  String get requestDate;

  /// No description provided for @requestTime.
  ///
  /// In en_US, this message translates to:
  /// **'Time'**
  String get requestTime;

  /// No description provided for @requestMark.
  ///
  /// In en_US, this message translates to:
  /// **'Mark'**
  String get requestMark;

  /// No description provided for @requestChoosePunch.
  ///
  /// In en_US, this message translates to:
  /// **'Choose the mark to contest:'**
  String get requestChoosePunch;

  /// No description provided for @requestNoPunches.
  ///
  /// In en_US, this message translates to:
  /// **'No recent marks.'**
  String get requestNoPunches;

  /// No description provided for @requestAbsenceType.
  ///
  /// In en_US, this message translates to:
  /// **'Kind of absence'**
  String get requestAbsenceType;

  /// No description provided for @requestStartDate.
  ///
  /// In en_US, this message translates to:
  /// **'First day'**
  String get requestStartDate;

  /// No description provided for @requestEndDate.
  ///
  /// In en_US, this message translates to:
  /// **'Last day'**
  String get requestEndDate;

  /// No description provided for @requestAttachCertificate.
  ///
  /// In en_US, this message translates to:
  /// **'Attach certificate (photo or PDF)'**
  String get requestAttachCertificate;

  /// No description provided for @requestCertificateHint.
  ///
  /// In en_US, this message translates to:
  /// **'PNG, JPEG, WEBP or PDF up to 10 MB. Only HR and your manager see it.'**
  String get requestCertificateHint;

  /// No description provided for @requestReason.
  ///
  /// In en_US, this message translates to:
  /// **'Reason'**
  String get requestReason;

  /// No description provided for @requestSend.
  ///
  /// In en_US, this message translates to:
  /// **'Send request'**
  String get requestSend;

  /// No description provided for @requestReasonRequired.
  ///
  /// In en_US, this message translates to:
  /// **'Write the reason.'**
  String get requestReasonRequired;

  /// No description provided for @requestTimeRequired.
  ///
  /// In en_US, this message translates to:
  /// **'Choose the time of the mark.'**
  String get requestTimeRequired;

  /// No description provided for @requestPunchRequired.
  ///
  /// In en_US, this message translates to:
  /// **'Choose the mark to contest.'**
  String get requestPunchRequired;

  /// No description provided for @requestEndBeforeStart.
  ///
  /// In en_US, this message translates to:
  /// **'The last day is before the first day.'**
  String get requestEndBeforeStart;

  /// No description provided for @requestFileInvalid.
  ///
  /// In en_US, this message translates to:
  /// **'Send a photo (PNG, JPEG, WEBP) or a PDF up to 10 MB.'**
  String get requestFileInvalid;

  /// No description provided for @requestDuplicate.
  ///
  /// In en_US, this message translates to:
  /// **'There is already a pending request for this.'**
  String get requestDuplicate;

  /// No description provided for @requestPeriodClosed.
  ///
  /// In en_US, this message translates to:
  /// **'This date is before the open period. Talk to HR.'**
  String get requestPeriodClosed;

  /// No description provided for @requestOverlap.
  ///
  /// In en_US, this message translates to:
  /// **'These days already have an absence.'**
  String get requestOverlap;

  /// No description provided for @requestAlreadyTreated.
  ///
  /// In en_US, this message translates to:
  /// **'This mark was already disregarded.'**
  String get requestAlreadyTreated;

  /// No description provided for @requestFutureTime.
  ///
  /// In en_US, this message translates to:
  /// **'The time cannot be in the future.'**
  String get requestFutureTime;

  /// No description provided for @requestAlreadyDecided.
  ///
  /// In en_US, this message translates to:
  /// **'This request was already answered.'**
  String get requestAlreadyDecided;

  /// No description provided for @requestAttachmentUnavailable.
  ///
  /// In en_US, this message translates to:
  /// **'Certificates cannot be sent right now. Send the request without it and give it to HR.'**
  String get requestAttachmentUnavailable;

  /// No description provided for @requestAnswer.
  ///
  /// In en_US, this message translates to:
  /// **'Answer: {note}'**
  String requestAnswer(String note);

  /// No description provided for @confirmPunchTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Confirm {punch}?'**
  String confirmPunchTitle(String punch);

  /// No description provided for @confirmPunch.
  ///
  /// In en_US, this message translates to:
  /// **'Confirm'**
  String get confirmPunch;

  /// No description provided for @retakePhoto.
  ///
  /// In en_US, this message translates to:
  /// **'Take again'**
  String get retakePhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en_US, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @punchPhotoNote.
  ///
  /// In en_US, this message translates to:
  /// **'Your company asks for a photo at each punch. It is kept for 90 days and seen only by HR.'**
  String get punchPhotoNote;

  /// No description provided for @punchPhotoMissing.
  ///
  /// In en_US, this message translates to:
  /// **'No photo: the punch is recorded and flagged for HR.'**
  String get punchPhotoMissing;

  /// No description provided for @punchPhotoFailed.
  ///
  /// In en_US, this message translates to:
  /// **'Punch saved, but the photo could not be sent.'**
  String get punchPhotoFailed;

  /// No description provided for @punchPhotoOffline.
  ///
  /// In en_US, this message translates to:
  /// **'No connection: the punch was kept and the photo will be sent when the connection returns.'**
  String get punchPhotoOffline;

  /// No description provided for @punchPhotoSaved.
  ///
  /// In en_US, this message translates to:
  /// **'Punch saved with photo.'**
  String get punchPhotoSaved;

  /// No description provided for @withPhoto.
  ///
  /// In en_US, this message translates to:
  /// **'With photo'**
  String get withPhoto;

  /// No description provided for @navDocuments.
  ///
  /// In en_US, this message translates to:
  /// **'Documents'**
  String get navDocuments;

  /// No description provided for @docsTabDocuments.
  ///
  /// In en_US, this message translates to:
  /// **'Documents'**
  String get docsTabDocuments;

  /// No description provided for @docsTabPayslips.
  ///
  /// In en_US, this message translates to:
  /// **'Payslips'**
  String get docsTabPayslips;

  /// No description provided for @docsTabNotices.
  ///
  /// In en_US, this message translates to:
  /// **'Notices'**
  String get docsTabNotices;

  /// No description provided for @docsTabVacation.
  ///
  /// In en_US, this message translates to:
  /// **'Vacation'**
  String get docsTabVacation;

  /// No description provided for @docKindDocument.
  ///
  /// In en_US, this message translates to:
  /// **'Document'**
  String get docKindDocument;

  /// No description provided for @docKindWarning.
  ///
  /// In en_US, this message translates to:
  /// **'Warning'**
  String get docKindWarning;

  /// No description provided for @docKindPayslip.
  ///
  /// In en_US, this message translates to:
  /// **'Payslip'**
  String get docKindPayslip;

  /// No description provided for @docKindEmployee.
  ///
  /// In en_US, this message translates to:
  /// **'Sent by you'**
  String get docKindEmployee;

  /// No description provided for @docStatePending.
  ///
  /// In en_US, this message translates to:
  /// **'Acknowledgement pending'**
  String get docStatePending;

  /// No description provided for @docStateAcknowledged.
  ///
  /// In en_US, this message translates to:
  /// **'Acknowledged on {date}'**
  String docStateAcknowledged(String date);

  /// No description provided for @docStateSent.
  ///
  /// In en_US, this message translates to:
  /// **'New'**
  String get docStateSent;

  /// No description provided for @docStateViewed.
  ///
  /// In en_US, this message translates to:
  /// **'Viewed'**
  String get docStateViewed;

  /// No description provided for @docStateReceived.
  ///
  /// In en_US, this message translates to:
  /// **'Sent to HR'**
  String get docStateReceived;

  /// No description provided for @docStateReviewed.
  ///
  /// In en_US, this message translates to:
  /// **'Checked by HR'**
  String get docStateReviewed;

  /// No description provided for @docOpen.
  ///
  /// In en_US, this message translates to:
  /// **'Open'**
  String get docOpen;

  /// No description provided for @docAcknowledge.
  ///
  /// In en_US, this message translates to:
  /// **'Acknowledge'**
  String get docAcknowledge;

  /// No description provided for @docAckTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Confirm acknowledgement'**
  String get docAckTitle;

  /// No description provided for @docAckStatement.
  ///
  /// In en_US, this message translates to:
  /// **'I declare that I read this document and acknowledge it.'**
  String get docAckStatement;

  /// No description provided for @docAckDone.
  ///
  /// In en_US, this message translates to:
  /// **'Acknowledgement recorded.'**
  String get docAckDone;

  /// No description provided for @docOpenFirst.
  ///
  /// In en_US, this message translates to:
  /// **'Open the document before acknowledging it.'**
  String get docOpenFirst;

  /// No description provided for @docsEmpty.
  ///
  /// In en_US, this message translates to:
  /// **'No documents yet.'**
  String get docsEmpty;

  /// No description provided for @payslipsEmpty.
  ///
  /// In en_US, this message translates to:
  /// **'No payslips yet.'**
  String get payslipsEmpty;

  /// No description provided for @docSend.
  ///
  /// In en_US, this message translates to:
  /// **'Send a document to HR'**
  String get docSend;

  /// No description provided for @docSendTitle.
  ///
  /// In en_US, this message translates to:
  /// **'What is this document?'**
  String get docSendTitle;

  /// No description provided for @docSendTitleHint.
  ///
  /// In en_US, this message translates to:
  /// **'E.g. proof of address'**
  String get docSendTitleHint;

  /// No description provided for @docSendNote.
  ///
  /// In en_US, this message translates to:
  /// **'Note (optional)'**
  String get docSendNote;

  /// No description provided for @docPickFile.
  ///
  /// In en_US, this message translates to:
  /// **'Choose file (PDF or image up to 10 MB)'**
  String get docPickFile;

  /// No description provided for @docSent.
  ///
  /// In en_US, this message translates to:
  /// **'Document sent to HR.'**
  String get docSent;

  /// No description provided for @docFileInvalid.
  ///
  /// In en_US, this message translates to:
  /// **'Send a PDF or an image up to 10 MB.'**
  String get docFileInvalid;

  /// No description provided for @docStorageUnavailable.
  ///
  /// In en_US, this message translates to:
  /// **'Files are not available right now. Talk to HR.'**
  String get docStorageUnavailable;

  /// No description provided for @docError.
  ///
  /// In en_US, this message translates to:
  /// **'It could not be done. Try again.'**
  String get docError;

  /// No description provided for @docOpenFailed.
  ///
  /// In en_US, this message translates to:
  /// **'The file could not be opened.'**
  String get docOpenFailed;

  /// No description provided for @docCompetence.
  ///
  /// In en_US, this message translates to:
  /// **'Competence {month}'**
  String docCompetence(String month);

  /// No description provided for @noticesEmpty.
  ///
  /// In en_US, this message translates to:
  /// **'No notices right now.'**
  String get noticesEmpty;

  /// No description provided for @noticeNew.
  ///
  /// In en_US, this message translates to:
  /// **'New'**
  String get noticeNew;

  /// No description provided for @noticeRead.
  ///
  /// In en_US, this message translates to:
  /// **'Read'**
  String get noticeRead;

  /// No description provided for @noticeAckRequired.
  ///
  /// In en_US, this message translates to:
  /// **'This notice asks for your acknowledgement.'**
  String get noticeAckRequired;

  /// No description provided for @vacationAvailable.
  ///
  /// In en_US, this message translates to:
  /// **'Days available'**
  String get vacationAvailable;

  /// No description provided for @vacationPendingDays.
  ///
  /// In en_US, this message translates to:
  /// **'In requests'**
  String get vacationPendingDays;

  /// No description provided for @vacationAccruing.
  ///
  /// In en_US, this message translates to:
  /// **'Accruing in the current period'**
  String get vacationAccruing;

  /// No description provided for @vacationDeadline.
  ///
  /// In en_US, this message translates to:
  /// **'Take by {date}'**
  String vacationDeadline(String date);

  /// No description provided for @vacationNoHireDate.
  ///
  /// In en_US, this message translates to:
  /// **'Your hire date is not registered. Talk to HR.'**
  String get vacationNoHireDate;

  /// No description provided for @vacationPeriods.
  ///
  /// In en_US, this message translates to:
  /// **'Acquisition periods'**
  String get vacationPeriods;

  /// No description provided for @vacationPeriodRange.
  ///
  /// In en_US, this message translates to:
  /// **'{start} to {end}'**
  String vacationPeriodRange(String start, String end);

  /// No description provided for @vacationPeriodUsage.
  ///
  /// In en_US, this message translates to:
  /// **'{taken} of {entitled} days taken'**
  String vacationPeriodUsage(int taken, int entitled);

  /// No description provided for @vacationAccruingStatus.
  ///
  /// In en_US, this message translates to:
  /// **'Accruing'**
  String get vacationAccruingStatus;

  /// No description provided for @vacationAvailableStatus.
  ///
  /// In en_US, this message translates to:
  /// **'Available'**
  String get vacationAvailableStatus;

  /// No description provided for @vacationUsedStatus.
  ///
  /// In en_US, this message translates to:
  /// **'Taken'**
  String get vacationUsedStatus;

  /// No description provided for @vacationOverdueStatus.
  ///
  /// In en_US, this message translates to:
  /// **'Overdue'**
  String get vacationOverdueStatus;

  /// No description provided for @vacationRequest.
  ///
  /// In en_US, this message translates to:
  /// **'Request vacation'**
  String get vacationRequest;

  /// No description provided for @vacationPickDates.
  ///
  /// In en_US, this message translates to:
  /// **'Choose the dates'**
  String get vacationPickDates;

  /// No description provided for @vacationDays.
  ///
  /// In en_US, this message translates to:
  /// **'{days} days'**
  String vacationDays(int days);

  /// No description provided for @vacationReason.
  ///
  /// In en_US, this message translates to:
  /// **'Note to HR'**
  String get vacationReason;

  /// No description provided for @vacationSent.
  ///
  /// In en_US, this message translates to:
  /// **'Vacation request sent. Follow it in Requests.'**
  String get vacationSent;

  /// No description provided for @vacationExceeds.
  ///
  /// In en_US, this message translates to:
  /// **'The chosen days go beyond your available balance.'**
  String get vacationExceeds;

  /// No description provided for @vacationNothing.
  ///
  /// In en_US, this message translates to:
  /// **'You have no vacation days to request yet.'**
  String get vacationNothing;

  /// No description provided for @absenceVacation.
  ///
  /// In en_US, this message translates to:
  /// **'Vacation'**
  String get absenceVacation;

  /// No description provided for @notificationsTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsReadAll.
  ///
  /// In en_US, this message translates to:
  /// **'Mark all as read'**
  String get notificationsReadAll;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en_US, this message translates to:
  /// **'No notifications yet.'**
  String get notificationsEmpty;

  /// No description provided for @notificationsError.
  ///
  /// In en_US, this message translates to:
  /// **'Notifications could not be loaded.'**
  String get notificationsError;

  /// No description provided for @notificationApproved.
  ///
  /// In en_US, this message translates to:
  /// **'Request approved'**
  String get notificationApproved;

  /// No description provided for @notificationRejected.
  ///
  /// In en_US, this message translates to:
  /// **'Request rejected'**
  String get notificationRejected;

  /// No description provided for @notificationMessage.
  ///
  /// In en_US, this message translates to:
  /// **'New message on a request'**
  String get notificationMessage;

  /// No description provided for @notificationNotice.
  ///
  /// In en_US, this message translates to:
  /// **'Company notice'**
  String get notificationNotice;

  /// No description provided for @pushTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Notifications on this device'**
  String get pushTitle;

  /// No description provided for @pushText.
  ///
  /// In en_US, this message translates to:
  /// **'Get answers and reminders even when Pulse is closed.'**
  String get pushText;

  /// No description provided for @pushDenied.
  ///
  /// In en_US, this message translates to:
  /// **'Notifications are blocked in the browser. Allow them in the site settings.'**
  String get pushDenied;

  /// No description provided for @pushUnavailable.
  ///
  /// In en_US, this message translates to:
  /// **'Notifications could not be turned on right now.'**
  String get pushUnavailable;

  /// No description provided for @pushUnsupported.
  ///
  /// In en_US, this message translates to:
  /// **'This browser does not receive notifications. On iPhone, add Pulse to the Home Screen.'**
  String get pushUnsupported;

  /// No description provided for @remindersTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Mark reminders'**
  String get remindersTitle;

  /// No description provided for @remindersText.
  ///
  /// In en_US, this message translates to:
  /// **'A reminder when your clock-in or clock-out time passes without a mark.'**
  String get remindersText;

  /// No description provided for @remindersOff.
  ///
  /// In en_US, this message translates to:
  /// **'Your company has not turned on mark reminders.'**
  String get remindersOff;

  /// No description provided for @requestConversation.
  ///
  /// In en_US, this message translates to:
  /// **'{count, plural, =0{Conversation} =1{1 message} other{{count} messages}}'**
  String requestConversation(int count);

  /// No description provided for @conversationEmpty.
  ///
  /// In en_US, this message translates to:
  /// **'Write to your manager about this request.'**
  String get conversationEmpty;

  /// No description provided for @conversationEmptyClosed.
  ///
  /// In en_US, this message translates to:
  /// **'No messages.'**
  String get conversationEmptyClosed;

  /// No description provided for @conversationError.
  ///
  /// In en_US, this message translates to:
  /// **'The conversation could not be sent or loaded.'**
  String get conversationError;

  /// No description provided for @conversationHint.
  ///
  /// In en_US, this message translates to:
  /// **'Message'**
  String get conversationHint;

  /// No description provided for @conversationSend.
  ///
  /// In en_US, this message translates to:
  /// **'Send'**
  String get conversationSend;

  /// No description provided for @conversationClosed.
  ///
  /// In en_US, this message translates to:
  /// **'The conversation is available only while the request is pending.'**
  String get conversationClosed;

  /// No description provided for @conversationYou.
  ///
  /// In en_US, this message translates to:
  /// **'You'**
  String get conversationYou;

  /// No description provided for @conversationManager.
  ///
  /// In en_US, this message translates to:
  /// **'Manager'**
  String get conversationManager;

  /// No description provided for @permissionsTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Allow Pulse to work'**
  String get permissionsTitle;

  /// No description provided for @permissionsIntro.
  ///
  /// In en_US, this message translates to:
  /// **'To record your time safely, Pulse needs your location, camera and notifications. You allow them once and the browser or device keeps your choice.'**
  String get permissionsIntro;

  /// No description provided for @permissionLocation.
  ///
  /// In en_US, this message translates to:
  /// **'Location (GPS)'**
  String get permissionLocation;

  /// No description provided for @permissionLocationHelp.
  ///
  /// In en_US, this message translates to:
  /// **'Recorded only at the moment of each punch.'**
  String get permissionLocationHelp;

  /// No description provided for @permissionCamera.
  ///
  /// In en_US, this message translates to:
  /// **'Camera'**
  String get permissionCamera;

  /// No description provided for @permissionCameraHelp.
  ///
  /// In en_US, this message translates to:
  /// **'Live photo to confirm each punch.'**
  String get permissionCameraHelp;

  /// No description provided for @permissionNotifications.
  ///
  /// In en_US, this message translates to:
  /// **'Notifications'**
  String get permissionNotifications;

  /// No description provided for @permissionNotificationsHelp.
  ///
  /// In en_US, this message translates to:
  /// **'Requests, documents, notices and reminders.'**
  String get permissionNotificationsHelp;

  /// No description provided for @permissionGranted.
  ///
  /// In en_US, this message translates to:
  /// **'Allowed'**
  String get permissionGranted;

  /// No description provided for @permissionPending.
  ///
  /// In en_US, this message translates to:
  /// **'Not allowed yet'**
  String get permissionPending;

  /// No description provided for @permissionDenied.
  ///
  /// In en_US, this message translates to:
  /// **'Blocked'**
  String get permissionDenied;

  /// No description provided for @permissionUnavailable.
  ///
  /// In en_US, this message translates to:
  /// **'Turned off or not available'**
  String get permissionUnavailable;

  /// No description provided for @permissionUnsupported.
  ///
  /// In en_US, this message translates to:
  /// **'Not available in this browser'**
  String get permissionUnsupported;

  /// No description provided for @permissionsAllow.
  ///
  /// In en_US, this message translates to:
  /// **'Allow all'**
  String get permissionsAllow;

  /// No description provided for @permissionsRecheck.
  ///
  /// In en_US, this message translates to:
  /// **'Check again'**
  String get permissionsRecheck;

  /// No description provided for @permissionsAlwaysHint.
  ///
  /// In en_US, this message translates to:
  /// **'When the browser asks, choose Allow (not \"only this time\") so you are not asked again.'**
  String get permissionsAlwaysHint;

  /// No description provided for @permissionsDeniedHelp.
  ///
  /// In en_US, this message translates to:
  /// **'A permission is blocked. Open the site settings (the lock next to the address) or the device settings, switch it to Allow and tap Check again.'**
  String get permissionsDeniedHelp;

  /// No description provided for @permissionsUnavailableHelp.
  ///
  /// In en_US, this message translates to:
  /// **'Turn on the device location (GPS) and make sure a camera is available.'**
  String get permissionsUnavailableHelp;

  /// No description provided for @permissionsLost.
  ///
  /// In en_US, this message translates to:
  /// **'A permission of Pulse was turned off. Allow it again to punch.'**
  String get permissionsLost;

  /// No description provided for @punchPhotoRequired.
  ///
  /// In en_US, this message translates to:
  /// **'Your company requires the photo to confirm the punch.'**
  String get punchPhotoRequired;

  /// No description provided for @cameraUnavailable.
  ///
  /// In en_US, this message translates to:
  /// **'The camera could not be opened. Check the camera permission and try again.'**
  String get cameraUnavailable;

  /// No description provided for @capturePhoto.
  ///
  /// In en_US, this message translates to:
  /// **'Capture'**
  String get capturePhoto;

  /// No description provided for @kioskUseDevice.
  ///
  /// In en_US, this message translates to:
  /// **'Use this device as the company time clock'**
  String get kioskUseDevice;

  /// No description provided for @kioskActivationTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Activate time clock'**
  String get kioskActivationTitle;

  /// No description provided for @kioskActivationHelp.
  ///
  /// In en_US, this message translates to:
  /// **'In the App, HR creates the time clock in HR › Time clocks and generates an activation code valid for 15 minutes. Type the code and set an administrator PIN, needed to leave the time clock mode on this device.'**
  String get kioskActivationHelp;

  /// No description provided for @kioskActivationCode.
  ///
  /// In en_US, this message translates to:
  /// **'Activation code'**
  String get kioskActivationCode;

  /// No description provided for @kioskAdminPin.
  ///
  /// In en_US, this message translates to:
  /// **'Administrator PIN (4 to 8 digits)'**
  String get kioskAdminPin;

  /// No description provided for @kioskAdminPinConfirm.
  ///
  /// In en_US, this message translates to:
  /// **'Confirm the administrator PIN'**
  String get kioskAdminPinConfirm;

  /// No description provided for @kioskAdminPinInvalid.
  ///
  /// In en_US, this message translates to:
  /// **'Use 4 to 8 digits.'**
  String get kioskAdminPinInvalid;

  /// No description provided for @kioskPinMismatch.
  ///
  /// In en_US, this message translates to:
  /// **'The PINs do not match.'**
  String get kioskPinMismatch;

  /// No description provided for @kioskActivate.
  ///
  /// In en_US, this message translates to:
  /// **'Activate'**
  String get kioskActivate;

  /// No description provided for @kioskCodeInvalid.
  ///
  /// In en_US, this message translates to:
  /// **'Invalid or expired activation code. Ask HR for a new one.'**
  String get kioskCodeInvalid;

  /// No description provided for @kioskKeyRejected.
  ///
  /// In en_US, this message translates to:
  /// **'This device could not be activated. Try again.'**
  String get kioskKeyRejected;

  /// No description provided for @kioskClockSkew.
  ///
  /// In en_US, this message translates to:
  /// **'This device\'s clock is far from the official time. Fix the date and time and try again.'**
  String get kioskClockSkew;

  /// No description provided for @kioskPinFixHint.
  ///
  /// In en_US, this message translates to:
  /// **'For use as a time clock, pin the app to the screen (Android: pin app; iPhone/iPad: Guided Access).'**
  String get kioskPinFixHint;

  /// No description provided for @kioskEnterCode.
  ///
  /// In en_US, this message translates to:
  /// **'Type your access code'**
  String get kioskEnterCode;

  /// No description provided for @kioskEnterPin.
  ///
  /// In en_US, this message translates to:
  /// **'Type your PIN'**
  String get kioskEnterPin;

  /// No description provided for @kioskContinue.
  ///
  /// In en_US, this message translates to:
  /// **'Continue'**
  String get kioskContinue;

  /// No description provided for @kioskHello.
  ///
  /// In en_US, this message translates to:
  /// **'Hello, {name}'**
  String kioskHello(String name);

  /// No description provided for @kioskSuggested.
  ///
  /// In en_US, this message translates to:
  /// **'Suggested mark'**
  String get kioskSuggested;

  /// No description provided for @kioskOtherMarks.
  ///
  /// In en_US, this message translates to:
  /// **'Other mark'**
  String get kioskOtherMarks;

  /// No description provided for @kioskConfirmPunch.
  ///
  /// In en_US, this message translates to:
  /// **'Confirm and record'**
  String get kioskConfirmPunch;

  /// No description provided for @kioskPhotoNote.
  ///
  /// In en_US, this message translates to:
  /// **'A live photo is taken to confirm the mark.'**
  String get kioskPhotoNote;

  /// No description provided for @kioskInvalidPin.
  ///
  /// In en_US, this message translates to:
  /// **'Invalid code or PIN.'**
  String get kioskInvalidPin;

  /// No description provided for @kioskPinLocked.
  ///
  /// In en_US, this message translates to:
  /// **'PIN locked after wrong attempts. Try later or talk to HR.'**
  String get kioskPinLocked;

  /// No description provided for @kioskPinNotSet.
  ///
  /// In en_US, this message translates to:
  /// **'You have no time clock PIN yet. Set it in Pulse (Time clock PIN) or ask HR.'**
  String get kioskPinNotSet;

  /// No description provided for @kioskOffline.
  ///
  /// In en_US, this message translates to:
  /// **'No connection: the time clock needs internet to record.'**
  String get kioskOffline;

  /// No description provided for @kioskPhotoRequired.
  ///
  /// In en_US, this message translates to:
  /// **'The photo is required to record the mark.'**
  String get kioskPhotoRequired;

  /// No description provided for @kioskPunchSaved.
  ///
  /// In en_US, this message translates to:
  /// **'Mark recorded'**
  String get kioskPunchSaved;

  /// No description provided for @kioskPhotoFailed.
  ///
  /// In en_US, this message translates to:
  /// **'Mark recorded, but the photo could not be sent.'**
  String get kioskPhotoFailed;

  /// No description provided for @kioskDone.
  ///
  /// In en_US, this message translates to:
  /// **'Done'**
  String get kioskDone;

  /// No description provided for @kioskReturning.
  ///
  /// In en_US, this message translates to:
  /// **'Back to start in {seconds} s'**
  String kioskReturning(int seconds);

  /// No description provided for @kioskRevoked.
  ///
  /// In en_US, this message translates to:
  /// **'This time clock was deactivated by HR. Ask for a new activation code.'**
  String get kioskRevoked;

  /// No description provided for @kioskExit.
  ///
  /// In en_US, this message translates to:
  /// **'Leave time clock mode'**
  String get kioskExit;

  /// No description provided for @kioskExitHelp.
  ///
  /// In en_US, this message translates to:
  /// **'Type the administrator PIN of this device. Ask HR to revoke the time clock in the App if the device is no longer used.'**
  String get kioskExitHelp;

  /// No description provided for @kioskExitWrong.
  ///
  /// In en_US, this message translates to:
  /// **'Invalid administrator PIN.'**
  String get kioskExitWrong;

  /// No description provided for @kioskFullscreen.
  ///
  /// In en_US, this message translates to:
  /// **'Full screen'**
  String get kioskFullscreen;

  /// No description provided for @kioskMarkTime.
  ///
  /// In en_US, this message translates to:
  /// **'Time'**
  String get kioskMarkTime;

  /// No description provided for @kioskPinMenu.
  ///
  /// In en_US, this message translates to:
  /// **'Time clock PIN'**
  String get kioskPinMenu;

  /// No description provided for @kioskPinHelp.
  ///
  /// In en_US, this message translates to:
  /// **'Use this PIN with your access code on the company time clocks: 4 to 6 digits, no sequence or repeated digit.'**
  String get kioskPinHelp;

  /// No description provided for @kioskPinCurrentPassword.
  ///
  /// In en_US, this message translates to:
  /// **'Current password'**
  String get kioskPinCurrentPassword;

  /// No description provided for @kioskPinNew.
  ///
  /// In en_US, this message translates to:
  /// **'New PIN'**
  String get kioskPinNew;

  /// No description provided for @kioskPinConfirm.
  ///
  /// In en_US, this message translates to:
  /// **'Confirm the PIN'**
  String get kioskPinConfirm;

  /// No description provided for @kioskPinInvalid.
  ///
  /// In en_US, this message translates to:
  /// **'Use 4 to 6 digits, no sequence (1234) or repeated digit (1111).'**
  String get kioskPinInvalid;

  /// No description provided for @kioskPinSaved.
  ///
  /// In en_US, this message translates to:
  /// **'Time clock PIN saved.'**
  String get kioskPinSaved;

  /// No description provided for @kioskPinSave.
  ///
  /// In en_US, this message translates to:
  /// **'Save PIN'**
  String get kioskPinSave;

  /// No description provided for @receiptPrint.
  ///
  /// In en_US, this message translates to:
  /// **'Print'**
  String get receiptPrint;

  /// No description provided for @receiptEmail.
  ///
  /// In en_US, this message translates to:
  /// **'Send by e-mail'**
  String get receiptEmail;

  /// No description provided for @receiptEmailSent.
  ///
  /// In en_US, this message translates to:
  /// **'Receipt sent to {recipient}.'**
  String receiptEmailSent(String recipient);

  /// No description provided for @receiptNoEmail.
  ///
  /// In en_US, this message translates to:
  /// **'There is no e-mail in your registry. Ask HR to add it.'**
  String get receiptNoEmail;

  /// No description provided for @receiptEmailDisabled.
  ///
  /// In en_US, this message translates to:
  /// **'This time clock does not send receipts by e-mail.'**
  String get receiptEmailDisabled;

  /// No description provided for @receiptEmailLimit.
  ///
  /// In en_US, this message translates to:
  /// **'This receipt was already sent several times. Try again later.'**
  String get receiptEmailLimit;

  /// No description provided for @receiptFailed.
  ///
  /// In en_US, this message translates to:
  /// **'The receipt could not be prepared. Try again.'**
  String get receiptFailed;

  /// No description provided for @kioskOfflineTitle.
  ///
  /// In en_US, this message translates to:
  /// **'No connection'**
  String get kioskOfflineTitle;

  /// No description provided for @kioskOfflineNote.
  ///
  /// In en_US, this message translates to:
  /// **'Your mark stays on this time clock and is sent when the connection is back. The PIN is checked then; if it is wrong, HR sees the mark as refused.'**
  String get kioskOfflineNote;

  /// No description provided for @kioskChooseMark.
  ///
  /// In en_US, this message translates to:
  /// **'Choose the mark'**
  String get kioskChooseMark;

  /// No description provided for @kioskOfflineSaved.
  ///
  /// In en_US, this message translates to:
  /// **'Mark kept on this time clock'**
  String get kioskOfflineSaved;

  /// No description provided for @kioskOfflineSavedNote.
  ///
  /// In en_US, this message translates to:
  /// **'It is sent as soon as the connection is back.'**
  String get kioskOfflineSavedNote;

  /// No description provided for @kioskQueueFull.
  ///
  /// In en_US, this message translates to:
  /// **'This time clock already keeps the maximum of marks without connection. Restore the internet.'**
  String get kioskQueueFull;

  /// No description provided for @kioskOfflinePending.
  ///
  /// In en_US, this message translates to:
  /// **'{count} marks waiting to be sent'**
  String kioskOfflinePending(int count);

  /// No description provided for @kioskExitPending.
  ///
  /// In en_US, this message translates to:
  /// **'{count} marks not sent yet are lost when leaving.'**
  String kioskExitPending(int count);

  /// No description provided for @tspPrint.
  ///
  /// In en_US, this message translates to:
  /// **'Print / PDF'**
  String get tspPrint;

  /// No description provided for @tspTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Timesheet'**
  String get tspTitle;

  /// No description provided for @tspEmployer.
  ///
  /// In en_US, this message translates to:
  /// **'Employer (legal name)'**
  String get tspEmployer;

  /// No description provided for @tspEmployerDocument.
  ///
  /// In en_US, this message translates to:
  /// **'Tax ID'**
  String get tspEmployerDocument;

  /// No description provided for @tspEmployee.
  ///
  /// In en_US, this message translates to:
  /// **'Employee'**
  String get tspEmployee;

  /// No description provided for @tspCpf.
  ///
  /// In en_US, this message translates to:
  /// **'CPF'**
  String get tspCpf;

  /// No description provided for @tspHireDate.
  ///
  /// In en_US, this message translates to:
  /// **'Hire date'**
  String get tspHireDate;

  /// No description provided for @tspPosition.
  ///
  /// In en_US, this message translates to:
  /// **'Position'**
  String get tspPosition;

  /// No description provided for @tspDepartment.
  ///
  /// In en_US, this message translates to:
  /// **'Department'**
  String get tspDepartment;

  /// No description provided for @tspPeriod.
  ///
  /// In en_US, this message translates to:
  /// **'Period'**
  String get tspPeriod;

  /// No description provided for @tspSchedules.
  ///
  /// In en_US, this message translates to:
  /// **'Contractual schedules'**
  String get tspSchedules;

  /// No description provided for @tspKindWeekly.
  ///
  /// In en_US, this message translates to:
  /// **'Weekly'**
  String get tspKindWeekly;

  /// No description provided for @tspKindCycle.
  ///
  /// In en_US, this message translates to:
  /// **'Cycle'**
  String get tspKindCycle;

  /// No description provided for @tspCycleDay.
  ///
  /// In en_US, this message translates to:
  /// **'Cycle day'**
  String get tspCycleDay;

  /// No description provided for @tspWeekdays.
  ///
  /// In en_US, this message translates to:
  /// **'Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday'**
  String get tspWeekdays;

  /// No description provided for @tspDays.
  ///
  /// In en_US, this message translates to:
  /// **'Marks per day'**
  String get tspDays;

  /// No description provided for @tspDate.
  ///
  /// In en_US, this message translates to:
  /// **'Date'**
  String get tspDate;

  /// No description provided for @tspDayCol.
  ///
  /// In en_US, this message translates to:
  /// **'Day'**
  String get tspDayCol;

  /// No description provided for @tspMarks.
  ///
  /// In en_US, this message translates to:
  /// **'Marks (NSR)'**
  String get tspMarks;

  /// No description provided for @tspExpected.
  ///
  /// In en_US, this message translates to:
  /// **'Expected'**
  String get tspExpected;

  /// No description provided for @tspWorked.
  ///
  /// In en_US, this message translates to:
  /// **'Worked'**
  String get tspWorked;

  /// No description provided for @tspOvertime.
  ///
  /// In en_US, this message translates to:
  /// **'Overtime'**
  String get tspOvertime;

  /// No description provided for @tspAbsence.
  ///
  /// In en_US, this message translates to:
  /// **'Absence'**
  String get tspAbsence;

  /// No description provided for @tspLate.
  ///
  /// In en_US, this message translates to:
  /// **'Late'**
  String get tspLate;

  /// No description provided for @tspNight.
  ///
  /// In en_US, this message translates to:
  /// **'Night'**
  String get tspNight;

  /// No description provided for @tspBalance.
  ///
  /// In en_US, this message translates to:
  /// **'Balance'**
  String get tspBalance;

  /// No description provided for @tspIssues.
  ///
  /// In en_US, this message translates to:
  /// **'Issues'**
  String get tspIssues;

  /// No description provided for @tspTotals.
  ///
  /// In en_US, this message translates to:
  /// **'Totals'**
  String get tspTotals;

  /// No description provided for @tspLegend.
  ///
  /// In en_US, this message translates to:
  /// **'Treatment legend'**
  String get tspLegend;

  /// No description provided for @tspLegendText.
  ///
  /// In en_US, this message translates to:
  /// **'I = mark included by a treatment; D = disregarded mark (struck through).'**
  String get tspLegendText;

  /// No description provided for @tspTime.
  ///
  /// In en_US, this message translates to:
  /// **'Time'**
  String get tspTime;

  /// No description provided for @tspType.
  ///
  /// In en_US, this message translates to:
  /// **'Type'**
  String get tspType;

  /// No description provided for @tspReason.
  ///
  /// In en_US, this message translates to:
  /// **'Reason'**
  String get tspReason;

  /// No description provided for @tspIssuedAt.
  ///
  /// In en_US, this message translates to:
  /// **'Issued at'**
  String get tspIssuedAt;

  /// No description provided for @tspIncluded.
  ///
  /// In en_US, this message translates to:
  /// **'Included'**
  String get tspIncluded;

  /// No description provided for @tspDisregarded.
  ///
  /// In en_US, this message translates to:
  /// **'Disregarded'**
  String get tspDisregarded;
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
