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
