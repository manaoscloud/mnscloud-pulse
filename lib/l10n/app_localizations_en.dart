// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get language => 'Language';

  @override
  String get system => 'System language';

  @override
  String get eyebrow => 'Employee access';

  @override
  String get title => 'Access your time clock';

  @override
  String get subtitle => 'Use the access code provided by your company.';

  @override
  String get heroTitle => 'Your workday.\nConnected.';

  @override
  String get heroText =>
      'Record your working hours and follow your workday in one place.';

  @override
  String get supportLabel => 'Need access? Contact your company';

  @override
  String get privacy => 'Privacy';

  @override
  String get terms => 'Terms of use';

  @override
  String get employeeCode => 'Employee access code';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get forgotPasswordTitle => 'Reset your password';

  @override
  String get forgotPasswordHelp =>
      'Your Pulse password is managed by your company. Ask the person in charge of your access for a new temporary password; on your next sign-in you will choose your own.';

  @override
  String get close => 'Close';

  @override
  String get required => 'This field is required.';

  @override
  String get invalidCredentials => 'Invalid access code or password.';

  @override
  String get networkError => 'Unable to connect. Please try again.';

  @override
  String get requestError =>
      'Unable to complete the request. Please try again or contact your company.';

  @override
  String get rateLimited => 'Too many attempts. Wait before trying again.';

  @override
  String get firstAccess => 'Create your new password';

  @override
  String get firstAccessHelp =>
      'Replace your temporary password before recording your time.';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get passwordLength => 'Use at least 10 characters.';

  @override
  String get passwordMismatch => 'Passwords do not match.';

  @override
  String get changePassword => 'Save new password';

  @override
  String get signedIn => 'Signed in successfully.';

  @override
  String get passwordChanged => 'Password changed successfully.';

  @override
  String get signedOut => 'Signed out.';

  @override
  String get employee => 'Employee';

  @override
  String get clockIn => 'Clock in';

  @override
  String get breakStart => 'Break start';

  @override
  String get breakEnd => 'Break end';

  @override
  String get clockOut => 'Clock out';

  @override
  String get recentPunches => 'Recent punches';

  @override
  String get punchSaved => 'Punch saved.';

  @override
  String get punchSynced => 'Punch already synced.';

  @override
  String get importantUpdate => 'Important update';

  @override
  String get newVersion => 'New version available';

  @override
  String get updateNow => 'Update now';

  @override
  String get later => 'Later';

  @override
  String get updateHelp =>
      'A new version is ready. You will sign in again after updating.';

  @override
  String get officialTime => 'Official time';

  @override
  String get nextPunch => 'Next punch';

  @override
  String get otherPunch => 'Other punch';

  @override
  String get onlineStatus => 'Online';

  @override
  String get offlineStatus => 'Offline';

  @override
  String pendingPunches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count punches waiting to be sent',
      one: '1 punch waiting to be sent',
    );
    return '$_temp0';
  }

  @override
  String get punchQueued =>
      'No connection: the punch was kept and will be sent automatically.';

  @override
  String get receipt => 'Last receipt';

  @override
  String nsrLabel(String nsr) {
    return 'NSR $nsr';
  }

  @override
  String get sessionEnded => 'Your session ended. Sign in again.';

  @override
  String get accountLocked =>
      'Account temporarily locked. Try again in a few minutes.';

  @override
  String get temporaryPasswordExpired =>
      'Your temporary password expired. Ask your company for a new one.';

  @override
  String get moduleUnavailable =>
      'The time clock is not available for your company. Contact HR.';

  @override
  String get accessDenied => 'Your access is not active. Contact HR.';

  @override
  String get invalidPassword => 'Current password is invalid.';

  @override
  String get passwordUnchanged =>
      'The new password must be different from the current one.';

  @override
  String get pendingSignOutTitle => 'Punches waiting to be sent';

  @override
  String get pendingSignOutHelp =>
      'Some punches were not sent yet. They stay protected on this device and are sent automatically as soon as there is a connection (or when you sign in here again).';

  @override
  String get offlineEntry =>
      'Offline mode: your punches stay protected on this device and are sent automatically when the connection is back.';

  @override
  String get cancel => 'Cancel';

  @override
  String get signOutAnyway => 'Sign out';

  @override
  String get noPunchesYet => 'No punches yet.';

  @override
  String get loading => 'Loading…';

  @override
  String get locationNote =>
      'Your location is recorded only at the moment of each punch, when allowed.';

  @override
  String get sentLater => 'Sent later';

  @override
  String get pendingSend => 'Waiting to be sent';

  @override
  String get navHome => 'Home';

  @override
  String get navTimesheet => 'Timesheet';

  @override
  String get today => 'Today';

  @override
  String get workDay => 'Workday';

  @override
  String get dayOff => 'Day off';

  @override
  String get holiday => 'Holiday';

  @override
  String holidayNamed(String name) {
    return 'Holiday: $name';
  }

  @override
  String get noSchedule => 'No schedule set';

  @override
  String get workedToday => 'Worked today';

  @override
  String get statusWorking => 'Working';

  @override
  String get statusOnBreak => 'On break';

  @override
  String get statusOffDuty => 'Off duty';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get refresh => 'Refresh';

  @override
  String get retry => 'Try again';

  @override
  String get totalWorked => 'Worked';

  @override
  String get totalExpected => 'Expected';

  @override
  String get totalBalance => 'Balance';

  @override
  String get totalOvertime => 'Overtime';

  @override
  String get totalAbsences => 'Absences';

  @override
  String get noPunchesDay => 'No punches';

  @override
  String get timesheetEmpty => 'No days in this month yet.';

  @override
  String unassignedPunches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count punches still being processed',
      one: '1 punch still being processed',
    );
    return '$_temp0';
  }

  @override
  String get flagAbsence => 'Absence';

  @override
  String get flagMissingPunch => 'Missing punch';

  @override
  String get flagLate => 'Late';

  @override
  String get flagEarlyLeave => 'Left early';

  @override
  String get flagShortBreak => 'Short break';

  @override
  String get flagRestViolation => 'Rest between shifts';

  @override
  String get flagOvertimeLimit => 'Overtime above limit';

  @override
  String get flagWorkedDayOff => 'Worked on a day off';

  @override
  String get flagFlaggedPunch => 'Flagged punch';

  @override
  String get flagNoSchedule => 'No schedule';

  @override
  String get installApp => 'Install app';

  @override
  String get installIosSteps =>
      'In Safari, tap Share and then \"Add to Home Screen\".';

  @override
  String get navRequests => 'Requests';

  @override
  String get back => 'Back';

  @override
  String get requestNew => 'New request';

  @override
  String get requestMissingPunch => 'Forgot a mark';

  @override
  String get requestPunchContest => 'Contest a mark';

  @override
  String get requestAbsence => 'Absence';

  @override
  String get absenceMedicalCertificate => 'Medical certificate';

  @override
  String get absenceJustified => 'Justified absence';

  @override
  String get absenceDayOff => 'Day off';

  @override
  String get absenceLeave => 'Leave';

  @override
  String get requestPending => 'Pending';

  @override
  String get requestApproved => 'Approved';

  @override
  String get requestRejected => 'Rejected';

  @override
  String get requestCancelled => 'Cancelled';

  @override
  String get requestEmpty =>
      'You have no requests yet. Use “New request” if you forgot a mark, need to contest one or have to justify an absence.';

  @override
  String get requestSent => 'Request sent. You will see the answer here.';

  @override
  String get requestCancelTitle => 'Cancel request?';

  @override
  String get requestCancelText =>
      'The request leaves the queue of your manager.';

  @override
  String get requestCancelAction => 'Cancel request';

  @override
  String get requestDate => 'Date';

  @override
  String get requestTime => 'Time';

  @override
  String get requestMark => 'Mark';

  @override
  String get requestChoosePunch => 'Choose the mark to contest:';

  @override
  String get requestNoPunches => 'No recent marks.';

  @override
  String get requestAbsenceType => 'Kind of absence';

  @override
  String get requestStartDate => 'First day';

  @override
  String get requestEndDate => 'Last day';

  @override
  String get requestAttachCertificate => 'Attach certificate (photo or PDF)';

  @override
  String get requestCertificateHint =>
      'PNG, JPEG, WEBP or PDF up to 10 MB. Only HR and your manager see it.';

  @override
  String get requestReason => 'Reason';

  @override
  String get requestSend => 'Send request';

  @override
  String get requestReasonRequired => 'Write the reason.';

  @override
  String get requestTimeRequired => 'Choose the time of the mark.';

  @override
  String get requestPunchRequired => 'Choose the mark to contest.';

  @override
  String get requestEndBeforeStart => 'The last day is before the first day.';

  @override
  String get requestFileInvalid =>
      'Send a photo (PNG, JPEG, WEBP) or a PDF up to 10 MB.';

  @override
  String get requestDuplicate => 'There is already a pending request for this.';

  @override
  String get requestPeriodClosed =>
      'This date is before the open period. Talk to HR.';

  @override
  String get requestOverlap => 'These days already have an absence.';

  @override
  String get requestAlreadyTreated => 'This mark was already disregarded.';

  @override
  String get requestFutureTime => 'The time cannot be in the future.';

  @override
  String get requestAlreadyDecided => 'This request was already answered.';

  @override
  String get requestAttachmentUnavailable =>
      'Certificates cannot be sent right now. Send the request without it and give it to HR.';

  @override
  String requestAnswer(String note) {
    return 'Answer: $note';
  }

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsReadAll => 'Mark all as read';

  @override
  String get notificationsEmpty => 'No notifications yet.';

  @override
  String get notificationsError => 'Notifications could not be loaded.';

  @override
  String get notificationApproved => 'Request approved';

  @override
  String get notificationRejected => 'Request rejected';

  @override
  String get notificationMessage => 'New message on a request';

  @override
  String get pushTitle => 'Notifications on this device';

  @override
  String get pushText => 'Get answers and reminders even when Pulse is closed.';

  @override
  String get pushDenied =>
      'Notifications are blocked in the browser. Allow them in the site settings.';

  @override
  String get pushUnavailable =>
      'Notifications could not be turned on right now.';

  @override
  String get pushUnsupported =>
      'This browser does not receive notifications. On iPhone, add Pulse to the Home Screen.';

  @override
  String get remindersTitle => 'Mark reminders';

  @override
  String get remindersText =>
      'A reminder when your clock-in or clock-out time passes without a mark.';

  @override
  String get remindersOff => 'Your company has not turned on mark reminders.';

  @override
  String requestConversation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages',
      one: '1 message',
      zero: 'Conversation',
    );
    return '$_temp0';
  }

  @override
  String get conversationEmpty => 'Write to your manager about this request.';

  @override
  String get conversationEmptyClosed => 'No messages.';

  @override
  String get conversationError =>
      'The conversation could not be sent or loaded.';

  @override
  String get conversationHint => 'Message';

  @override
  String get conversationSend => 'Send';

  @override
  String get conversationClosed =>
      'The conversation is available only while the request is pending.';

  @override
  String get conversationYou => 'You';

  @override
  String get conversationManager => 'Manager';
}

/// The translations for English, as used in the United States (`en_US`).
class AppLocalizationsEnUs extends AppLocalizationsEn {
  AppLocalizationsEnUs() : super('en_US');

  @override
  String get language => 'Language';

  @override
  String get system => 'System language';

  @override
  String get eyebrow => 'Employee access';

  @override
  String get title => 'Access your time clock';

  @override
  String get subtitle => 'Use the access code provided by your company.';

  @override
  String get heroTitle => 'Your workday.\nConnected.';

  @override
  String get heroText =>
      'Record your working hours and follow your workday in one place.';

  @override
  String get supportLabel => 'Need access? Contact your company';

  @override
  String get privacy => 'Privacy';

  @override
  String get terms => 'Terms of use';

  @override
  String get employeeCode => 'Employee access code';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get forgotPasswordTitle => 'Reset your password';

  @override
  String get forgotPasswordHelp =>
      'Your Pulse password is managed by your company. Ask the person in charge of your access for a new temporary password; on your next sign-in you will choose your own.';

  @override
  String get close => 'Close';

  @override
  String get required => 'This field is required.';

  @override
  String get invalidCredentials => 'Invalid access code or password.';

  @override
  String get networkError => 'Unable to connect. Please try again.';

  @override
  String get requestError =>
      'Unable to complete the request. Please try again or contact your company.';

  @override
  String get rateLimited => 'Too many attempts. Wait before trying again.';

  @override
  String get firstAccess => 'Create your new password';

  @override
  String get firstAccessHelp =>
      'Replace your temporary password before recording your time.';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get passwordLength => 'Use at least 10 characters.';

  @override
  String get passwordMismatch => 'Passwords do not match.';

  @override
  String get changePassword => 'Save new password';

  @override
  String get signedIn => 'Signed in successfully.';

  @override
  String get passwordChanged => 'Password changed successfully.';

  @override
  String get signedOut => 'Signed out.';

  @override
  String get employee => 'Employee';

  @override
  String get clockIn => 'Clock in';

  @override
  String get breakStart => 'Break start';

  @override
  String get breakEnd => 'Break end';

  @override
  String get clockOut => 'Clock out';

  @override
  String get recentPunches => 'Recent punches';

  @override
  String get punchSaved => 'Punch saved.';

  @override
  String get punchSynced => 'Punch already synced.';

  @override
  String get importantUpdate => 'Important update';

  @override
  String get newVersion => 'New version available';

  @override
  String get updateNow => 'Update now';

  @override
  String get later => 'Later';

  @override
  String get updateHelp =>
      'A new version is ready. You will sign in again after updating.';

  @override
  String get officialTime => 'Official time';

  @override
  String get nextPunch => 'Next punch';

  @override
  String get otherPunch => 'Other punch';

  @override
  String get onlineStatus => 'Online';

  @override
  String get offlineStatus => 'Offline';

  @override
  String pendingPunches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count punches waiting to be sent',
      one: '1 punch waiting to be sent',
    );
    return '$_temp0';
  }

  @override
  String get punchQueued =>
      'No connection: the punch was kept and will be sent automatically.';

  @override
  String get receipt => 'Last receipt';

  @override
  String nsrLabel(String nsr) {
    return 'NSR $nsr';
  }

  @override
  String get sessionEnded => 'Your session ended. Sign in again.';

  @override
  String get accountLocked =>
      'Account temporarily locked. Try again in a few minutes.';

  @override
  String get temporaryPasswordExpired =>
      'Your temporary password expired. Ask your company for a new one.';

  @override
  String get moduleUnavailable =>
      'The time clock is not available for your company. Contact HR.';

  @override
  String get accessDenied => 'Your access is not active. Contact HR.';

  @override
  String get invalidPassword => 'Current password is invalid.';

  @override
  String get passwordUnchanged =>
      'The new password must be different from the current one.';

  @override
  String get pendingSignOutTitle => 'Punches waiting to be sent';

  @override
  String get pendingSignOutHelp =>
      'Some punches were not sent yet. They stay protected on this device and are sent automatically as soon as there is a connection (or when you sign in here again).';

  @override
  String get offlineEntry =>
      'Offline mode: your punches stay protected on this device and are sent automatically when the connection is back.';

  @override
  String get cancel => 'Cancel';

  @override
  String get signOutAnyway => 'Sign out';

  @override
  String get noPunchesYet => 'No punches yet.';

  @override
  String get loading => 'Loading…';

  @override
  String get locationNote =>
      'Your location is recorded only at the moment of each punch, when allowed.';

  @override
  String get sentLater => 'Sent later';

  @override
  String get pendingSend => 'Waiting to be sent';

  @override
  String get navHome => 'Home';

  @override
  String get navTimesheet => 'Timesheet';

  @override
  String get today => 'Today';

  @override
  String get workDay => 'Workday';

  @override
  String get dayOff => 'Day off';

  @override
  String get holiday => 'Holiday';

  @override
  String holidayNamed(String name) {
    return 'Holiday: $name';
  }

  @override
  String get noSchedule => 'No schedule set';

  @override
  String get workedToday => 'Worked today';

  @override
  String get statusWorking => 'Working';

  @override
  String get statusOnBreak => 'On break';

  @override
  String get statusOffDuty => 'Off duty';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get refresh => 'Refresh';

  @override
  String get retry => 'Try again';

  @override
  String get totalWorked => 'Worked';

  @override
  String get totalExpected => 'Expected';

  @override
  String get totalBalance => 'Balance';

  @override
  String get totalOvertime => 'Overtime';

  @override
  String get totalAbsences => 'Absences';

  @override
  String get noPunchesDay => 'No punches';

  @override
  String get timesheetEmpty => 'No days in this month yet.';

  @override
  String unassignedPunches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count punches still being processed',
      one: '1 punch still being processed',
    );
    return '$_temp0';
  }

  @override
  String get flagAbsence => 'Absence';

  @override
  String get flagMissingPunch => 'Missing punch';

  @override
  String get flagLate => 'Late';

  @override
  String get flagEarlyLeave => 'Left early';

  @override
  String get flagShortBreak => 'Short break';

  @override
  String get flagRestViolation => 'Rest between shifts';

  @override
  String get flagOvertimeLimit => 'Overtime above limit';

  @override
  String get flagWorkedDayOff => 'Worked on a day off';

  @override
  String get flagFlaggedPunch => 'Flagged punch';

  @override
  String get flagNoSchedule => 'No schedule';

  @override
  String get installApp => 'Install app';

  @override
  String get installIosSteps =>
      'In Safari, tap Share and then \"Add to Home Screen\".';

  @override
  String get navRequests => 'Requests';

  @override
  String get back => 'Back';

  @override
  String get requestNew => 'New request';

  @override
  String get requestMissingPunch => 'Forgot a mark';

  @override
  String get requestPunchContest => 'Contest a mark';

  @override
  String get requestAbsence => 'Absence';

  @override
  String get absenceMedicalCertificate => 'Medical certificate';

  @override
  String get absenceJustified => 'Justified absence';

  @override
  String get absenceDayOff => 'Day off';

  @override
  String get absenceLeave => 'Leave';

  @override
  String get requestPending => 'Pending';

  @override
  String get requestApproved => 'Approved';

  @override
  String get requestRejected => 'Rejected';

  @override
  String get requestCancelled => 'Cancelled';

  @override
  String get requestEmpty =>
      'You have no requests yet. Use “New request” if you forgot a mark, need to contest one or have to justify an absence.';

  @override
  String get requestSent => 'Request sent. You will see the answer here.';

  @override
  String get requestCancelTitle => 'Cancel request?';

  @override
  String get requestCancelText =>
      'The request leaves the queue of your manager.';

  @override
  String get requestCancelAction => 'Cancel request';

  @override
  String get requestDate => 'Date';

  @override
  String get requestTime => 'Time';

  @override
  String get requestMark => 'Mark';

  @override
  String get requestChoosePunch => 'Choose the mark to contest:';

  @override
  String get requestNoPunches => 'No recent marks.';

  @override
  String get requestAbsenceType => 'Kind of absence';

  @override
  String get requestStartDate => 'First day';

  @override
  String get requestEndDate => 'Last day';

  @override
  String get requestAttachCertificate => 'Attach certificate (photo or PDF)';

  @override
  String get requestCertificateHint =>
      'PNG, JPEG, WEBP or PDF up to 10 MB. Only HR and your manager see it.';

  @override
  String get requestReason => 'Reason';

  @override
  String get requestSend => 'Send request';

  @override
  String get requestReasonRequired => 'Write the reason.';

  @override
  String get requestTimeRequired => 'Choose the time of the mark.';

  @override
  String get requestPunchRequired => 'Choose the mark to contest.';

  @override
  String get requestEndBeforeStart => 'The last day is before the first day.';

  @override
  String get requestFileInvalid =>
      'Send a photo (PNG, JPEG, WEBP) or a PDF up to 10 MB.';

  @override
  String get requestDuplicate => 'There is already a pending request for this.';

  @override
  String get requestPeriodClosed =>
      'This date is before the open period. Talk to HR.';

  @override
  String get requestOverlap => 'These days already have an absence.';

  @override
  String get requestAlreadyTreated => 'This mark was already disregarded.';

  @override
  String get requestFutureTime => 'The time cannot be in the future.';

  @override
  String get requestAlreadyDecided => 'This request was already answered.';

  @override
  String get requestAttachmentUnavailable =>
      'Certificates cannot be sent right now. Send the request without it and give it to HR.';

  @override
  String requestAnswer(String note) {
    return 'Answer: $note';
  }

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsReadAll => 'Mark all as read';

  @override
  String get notificationsEmpty => 'No notifications yet.';

  @override
  String get notificationsError => 'Notifications could not be loaded.';

  @override
  String get notificationApproved => 'Request approved';

  @override
  String get notificationRejected => 'Request rejected';

  @override
  String get notificationMessage => 'New message on a request';

  @override
  String get pushTitle => 'Notifications on this device';

  @override
  String get pushText => 'Get answers and reminders even when Pulse is closed.';

  @override
  String get pushDenied =>
      'Notifications are blocked in the browser. Allow them in the site settings.';

  @override
  String get pushUnavailable =>
      'Notifications could not be turned on right now.';

  @override
  String get pushUnsupported =>
      'This browser does not receive notifications. On iPhone, add Pulse to the Home Screen.';

  @override
  String get remindersTitle => 'Mark reminders';

  @override
  String get remindersText =>
      'A reminder when your clock-in or clock-out time passes without a mark.';

  @override
  String get remindersOff => 'Your company has not turned on mark reminders.';

  @override
  String requestConversation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages',
      one: '1 message',
      zero: 'Conversation',
    );
    return '$_temp0';
  }

  @override
  String get conversationEmpty => 'Write to your manager about this request.';

  @override
  String get conversationEmptyClosed => 'No messages.';

  @override
  String get conversationError =>
      'The conversation could not be sent or loaded.';

  @override
  String get conversationHint => 'Message';

  @override
  String get conversationSend => 'Send';

  @override
  String get conversationClosed =>
      'The conversation is available only while the request is pending.';

  @override
  String get conversationYou => 'You';

  @override
  String get conversationManager => 'Manager';
}
