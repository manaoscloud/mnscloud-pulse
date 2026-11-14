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
  String get versionUnsupported =>
      'This app version is no longer supported. Update the app from the store or with your administrator to continue.';

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
  String get punchNoLocationNotice =>
      'Punch recorded without location; HR will see it flagged.';

  @override
  String get receiptsLast48h => 'Receipts of the last 48 hours';

  @override
  String get receiptsLast48hEmpty => 'No receipts in the last 48 hours.';

  @override
  String get receiptFieldEmployer => 'Employer';

  @override
  String get receiptFieldEmployee => 'Employee';

  @override
  String get receiptFieldWhen => 'Date and time';

  @override
  String get receiptFieldCollector => 'Collector';

  @override
  String get receiptFieldHash => 'Verification code (SHA-256)';

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
  String confirmPunchTitle(String punch) {
    return 'Confirm $punch?';
  }

  @override
  String get confirmPunch => 'Confirm';

  @override
  String get retakePhoto => 'Take again';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get punchPhotoNote =>
      'Your company asks for a photo at each punch. It is kept for 90 days and seen only by HR.';

  @override
  String get punchPhotoMissing =>
      'No photo: the punch is recorded and flagged for HR.';

  @override
  String get punchPhotoFailed =>
      'Punch saved, but the photo could not be sent.';

  @override
  String get punchPhotoOffline =>
      'No connection: the punch was kept and the photo will be sent when the connection returns.';

  @override
  String get punchPhotoSaved => 'Punch saved with photo.';

  @override
  String get withPhoto => 'With photo';

  @override
  String get navDocuments => 'Documents';

  @override
  String get docsTabDocuments => 'Documents';

  @override
  String get docsTabPayslips => 'Payslips';

  @override
  String get docsTabNotices => 'Notices';

  @override
  String get docsTabVacation => 'Vacation';

  @override
  String get docKindDocument => 'Document';

  @override
  String get docKindWarning => 'Warning';

  @override
  String get docKindPayslip => 'Payslip';

  @override
  String get docKindEmployee => 'Sent by you';

  @override
  String get docStatePending => 'Acknowledgement pending';

  @override
  String docStateAcknowledged(String date) {
    return 'Acknowledged on $date';
  }

  @override
  String get docStateSent => 'New';

  @override
  String get docStateViewed => 'Viewed';

  @override
  String get docStateReceived => 'Sent to HR';

  @override
  String get docStateReviewed => 'Checked by HR';

  @override
  String get docOpen => 'Open';

  @override
  String get docAcknowledge => 'Acknowledge';

  @override
  String get docAckTitle => 'Confirm acknowledgement';

  @override
  String get docAckStatement =>
      'I declare that I read this document and acknowledge it.';

  @override
  String get docAckDone => 'Acknowledgement recorded.';

  @override
  String get docOpenFirst => 'Open the document before acknowledging it.';

  @override
  String get docsEmpty => 'No documents yet.';

  @override
  String get payslipsEmpty => 'No payslips yet.';

  @override
  String get docSend => 'Send a document to HR';

  @override
  String get docSendTitle => 'What is this document?';

  @override
  String get docSendTitleHint => 'E.g. proof of address';

  @override
  String get docSendNote => 'Note (optional)';

  @override
  String get docPickFile => 'Choose file (PDF or image up to 10 MB)';

  @override
  String get docSent => 'Document sent to HR.';

  @override
  String get docFileInvalid => 'Send a PDF or an image up to 10 MB.';

  @override
  String get docStorageUnavailable =>
      'Files are not available right now. Talk to HR.';

  @override
  String get docError => 'It could not be done. Try again.';

  @override
  String get docOpenFailed => 'The file could not be opened.';

  @override
  String docCompetence(String month) {
    return 'Competence $month';
  }

  @override
  String get noticesEmpty => 'No notices right now.';

  @override
  String get noticeNew => 'New';

  @override
  String get noticeRead => 'Read';

  @override
  String get noticeAckRequired => 'This notice asks for your acknowledgement.';

  @override
  String get vacationAvailable => 'Days available';

  @override
  String get vacationPendingDays => 'In requests';

  @override
  String get vacationAccruing => 'Accruing in the current period';

  @override
  String vacationDeadline(String date) {
    return 'Take by $date';
  }

  @override
  String get vacationNoHireDate =>
      'Your hire date is not registered. Talk to HR.';

  @override
  String get vacationPeriods => 'Acquisition periods';

  @override
  String vacationPeriodRange(String start, String end) {
    return '$start to $end';
  }

  @override
  String vacationPeriodUsage(int taken, int entitled) {
    return '$taken of $entitled days taken';
  }

  @override
  String get vacationAccruingStatus => 'Accruing';

  @override
  String get vacationAvailableStatus => 'Available';

  @override
  String get vacationUsedStatus => 'Taken';

  @override
  String get vacationOverdueStatus => 'Overdue';

  @override
  String get vacationRequest => 'Request vacation';

  @override
  String get vacationPickDates => 'Choose the dates';

  @override
  String vacationDays(int days) {
    return '$days days';
  }

  @override
  String get vacationReason => 'Note to HR';

  @override
  String get vacationSent => 'Vacation request sent. Follow it in Requests.';

  @override
  String get vacationExceeds =>
      'The chosen days go beyond your available balance.';

  @override
  String get vacationNothing => 'You have no vacation days to request yet.';

  @override
  String get absenceVacation => 'Vacation';

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
  String get notificationNotice => 'Company notice';

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

  @override
  String get permissionsTitle => 'Allow Pulse to work';

  @override
  String get permissionsIntro =>
      'To record your time safely, Pulse needs your location, camera and notifications. You allow them once and the browser or device keeps your choice.';

  @override
  String get permissionLocation => 'Location (GPS)';

  @override
  String get permissionLocationHelp =>
      'Recorded only at the moment of each punch.';

  @override
  String get permissionCamera => 'Camera';

  @override
  String get permissionCameraHelp => 'Live photo to confirm each punch.';

  @override
  String get permissionNotifications => 'Notifications';

  @override
  String get permissionNotificationsHelp =>
      'Requests, documents, notices and reminders.';

  @override
  String get permissionGranted => 'Allowed';

  @override
  String get permissionPending => 'Not allowed yet';

  @override
  String get permissionDenied => 'Blocked';

  @override
  String get permissionUnavailable => 'Turned off or not available';

  @override
  String get permissionUnsupported => 'Not available in this browser';

  @override
  String get permissionsAllow => 'Allow all';

  @override
  String get permissionsRecheck => 'Check again';

  @override
  String get permissionsAlwaysHint =>
      'When the browser asks, choose Allow (not \"only this time\") so you are not asked again.';

  @override
  String get permissionsDeniedHelp =>
      'A permission is blocked. Open the site settings (the lock next to the address) or the device settings, switch it to Allow and tap Check again.';

  @override
  String get permissionsUnavailableHelp =>
      'Turn on the device location (GPS) and make sure a camera is available.';

  @override
  String get permissionsLost =>
      'A permission of Pulse was turned off. Allow it again to punch.';

  @override
  String get punchPhotoRequired =>
      'Your company requires the photo to confirm the punch.';

  @override
  String get cameraUnavailable =>
      'The camera could not be opened. Check the camera permission and try again.';

  @override
  String get capturePhoto => 'Capture';

  @override
  String get kioskUseDevice => 'Use this device as the company time clock';

  @override
  String get kioskActivationTitle => 'Activate time clock';

  @override
  String get kioskActivationHelp =>
      'In the App, HR creates the time clock in HR › Time clocks and generates an activation code valid for 15 minutes. Type the code and set an administrator PIN, needed to leave the time clock mode on this device.';

  @override
  String get kioskActivationCode => 'Activation code';

  @override
  String get kioskAdminPin => 'Administrator PIN (4 to 8 digits)';

  @override
  String get kioskAdminPinConfirm => 'Confirm the administrator PIN';

  @override
  String get kioskAdminPinInvalid => 'Use 4 to 8 digits.';

  @override
  String get kioskPinMismatch => 'The PINs do not match.';

  @override
  String get kioskActivate => 'Activate';

  @override
  String get kioskCodeInvalid =>
      'Invalid or expired activation code. Ask HR for a new one.';

  @override
  String get kioskKeyRejected =>
      'This device could not be activated. Try again.';

  @override
  String get kioskClockSkew =>
      'This device\'s clock is far from the official time. Fix the date and time and try again.';

  @override
  String get kioskPinFixHint =>
      'For use as a time clock, pin the app to the screen (Android: pin app; iPhone/iPad: Guided Access).';

  @override
  String get kioskEnterCode => 'Type your access code';

  @override
  String get kioskEnterPin => 'Type your PIN';

  @override
  String get kioskContinue => 'Continue';

  @override
  String kioskHello(String name) {
    return 'Hello, $name';
  }

  @override
  String get kioskSuggested => 'Suggested mark';

  @override
  String get kioskOtherMarks => 'Other mark';

  @override
  String get kioskConfirmPunch => 'Confirm and record';

  @override
  String get kioskPhotoNote => 'A live photo is taken to confirm the mark.';

  @override
  String get kioskInvalidPin => 'Invalid code or PIN.';

  @override
  String get kioskPinLocked =>
      'PIN locked after wrong attempts. Try later or talk to HR.';

  @override
  String get kioskPinNotSet =>
      'You have no time clock PIN yet. Set it in Pulse (Time clock PIN) or ask HR.';

  @override
  String get kioskOffline =>
      'No connection: the time clock needs internet to record.';

  @override
  String get kioskPhotoRequired => 'The photo is required to record the mark.';

  @override
  String get kioskPunchSaved => 'Mark recorded';

  @override
  String get kioskPhotoFailed =>
      'Mark recorded, but the photo could not be sent.';

  @override
  String get kioskDone => 'Done';

  @override
  String kioskReturning(int seconds) {
    return 'Back to start in $seconds s';
  }

  @override
  String get kioskRevoked =>
      'This time clock was deactivated by HR. Ask for a new activation code.';

  @override
  String get kioskExit => 'Leave time clock mode';

  @override
  String get kioskExitHelp =>
      'Type the administrator PIN of this device. Ask HR to revoke the time clock in the App if the device is no longer used.';

  @override
  String get kioskExitWrong => 'Invalid administrator PIN.';

  @override
  String get kioskFullscreen => 'Full screen';

  @override
  String get kioskMarkTime => 'Time';

  @override
  String get kioskPinMenu => 'Time clock PIN';

  @override
  String get kioskPinHelp =>
      'Use this PIN with your access code on the company time clocks: 4 to 6 digits, no sequence or repeated digit.';

  @override
  String get kioskPinCurrentPassword => 'Current password';

  @override
  String get kioskPinNew => 'New PIN';

  @override
  String get kioskPinConfirm => 'Confirm the PIN';

  @override
  String get kioskPinInvalid =>
      'Use 4 to 6 digits, no sequence (1234) or repeated digit (1111).';

  @override
  String get kioskPinSaved => 'Time clock PIN saved.';

  @override
  String get kioskPinSave => 'Save PIN';

  @override
  String get receiptPrint => 'Print';

  @override
  String get receiptEmail => 'Send by e-mail';

  @override
  String receiptEmailSent(String recipient) {
    return 'Receipt sent to $recipient.';
  }

  @override
  String get receiptNoEmail =>
      'There is no e-mail in your registry. Ask HR to add it.';

  @override
  String get receiptEmailDisabled =>
      'This time clock does not send receipts by e-mail.';

  @override
  String get receiptEmailLimit =>
      'This receipt was already sent several times. Try again later.';

  @override
  String get receiptFailed => 'The receipt could not be prepared. Try again.';

  @override
  String get kioskOfflineTitle => 'No connection';

  @override
  String get kioskOfflineNote =>
      'Your mark stays on this time clock and is sent when the connection is back. The PIN is checked then; if it is wrong, HR sees the mark as refused.';

  @override
  String get kioskChooseMark => 'Choose the mark';

  @override
  String get kioskOfflineSaved => 'Mark kept on this time clock';

  @override
  String get kioskOfflineSavedNote =>
      'It is sent as soon as the connection is back.';

  @override
  String get kioskQueueFull =>
      'This time clock already keeps the maximum of marks without connection. Restore the internet.';

  @override
  String kioskOfflinePending(int count) {
    return '$count marks waiting to be sent';
  }

  @override
  String kioskExitPending(int count) {
    return '$count marks not sent yet are lost when leaving.';
  }

  @override
  String get tspPrint => 'Print / PDF';

  @override
  String get tspTitle => 'Timesheet';

  @override
  String get tspEmployer => 'Employer (legal name)';

  @override
  String get tspEmployerDocument => 'Tax ID';

  @override
  String get tspEmployee => 'Employee';

  @override
  String get tspCpf => 'CPF';

  @override
  String get tspHireDate => 'Hire date';

  @override
  String get tspPosition => 'Position';

  @override
  String get tspDepartment => 'Department';

  @override
  String get tspPeriod => 'Period';

  @override
  String get tspSchedules => 'Contractual schedules';

  @override
  String get tspKindWeekly => 'Weekly';

  @override
  String get tspKindCycle => 'Cycle';

  @override
  String get tspCycleDay => 'Cycle day';

  @override
  String get tspWeekdays =>
      'Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday';

  @override
  String get tspDays => 'Marks per day';

  @override
  String get tspDate => 'Date';

  @override
  String get tspDayCol => 'Day';

  @override
  String get tspMarks => 'Marks (NSR)';

  @override
  String get tspExpected => 'Expected';

  @override
  String get tspWorked => 'Worked';

  @override
  String get tspOvertime => 'Overtime';

  @override
  String get tspAbsence => 'Absence';

  @override
  String get tspLate => 'Late';

  @override
  String get tspNight => 'Night';

  @override
  String get tspBalance => 'Balance';

  @override
  String get tspIssues => 'Issues';

  @override
  String get tspTotals => 'Totals';

  @override
  String get tspLegend => 'Treatment legend';

  @override
  String get tspLegendText =>
      'I = mark included by a treatment; D = disregarded mark (struck through).';

  @override
  String get tspTime => 'Time';

  @override
  String get tspType => 'Type';

  @override
  String get tspReason => 'Reason';

  @override
  String get tspIssuedAt => 'Issued at';

  @override
  String get tspIncluded => 'Included';

  @override
  String get tspDisregarded => 'Disregarded';

  @override
  String get employmentLabel => 'Employment';

  @override
  String get employmentRegistrationShort => 'Reg.';

  @override
  String get employmentRequired =>
      'You have more than one employment. Choose the employment of this punch and punch again.';

  @override
  String get employmentInvalid =>
      'This employment is not valid for you now. Choose another one and punch again.';

  @override
  String get outsideGeofence => 'Outside the geofence';

  @override
  String get tspLocation => 'Location';

  @override
  String get tspRegistration => 'Registration no.';

  @override
  String get tspTermination => 'Termination';

  @override
  String get kioskEmploymentRequired =>
      'You have more than one employment. Punch on a time clock of your company or in the Pulse app.';

  @override
  String employmentWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count punches are waiting for an employment',
      one: '1 punch is waiting for an employment',
    );
    return '$_temp0';
  }

  @override
  String get employmentAssign => 'Assign employment and send';

  @override
  String get tspTotalsOmitted =>
      'Totals per employment are not available yet: you have another employment this month.';

  @override
  String get employmentAll => 'All employments';

  @override
  String punchTooOld(String when) {
    return 'Punch of $when not sent: more than 7 days without connection. Contact HR.';
  }

  @override
  String get punchNoticeDismiss => 'OK';

  @override
  String get closingTitle => 'Closing';

  @override
  String closingClosedAt(String when) {
    return 'Closed on $when';
  }

  @override
  String get closingAck => 'Acknowledge';

  @override
  String closingAcked(String when) {
    return 'Acknowledged on $when';
  }

  @override
  String get closingAwaiting => 'Waiting for your acknowledgement';

  @override
  String get closingAckConfirmTitle => 'Acknowledge the closing';

  @override
  String closingAckConfirmBody(String month) {
    return 'I confirm that I saw the closed timesheet of $month.';
  }

  @override
  String get closingWorked => 'Worked';

  @override
  String get closingOvertime50 => 'Overtime 50%';

  @override
  String get closingOvertime100 => 'Overtime 100%';

  @override
  String get closingAbsences => 'Absences (days)';

  @override
  String get closingDsrLost => 'Weeks without paid rest';

  @override
  String closingNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count closed months waiting for your acknowledgement',
      one: '1 closed month waiting for your acknowledgement',
    );
    return '$_temp0';
  }

  @override
  String get closingNoticeOpen => 'View';

  @override
  String get bankTitle => 'Hour bank';

  @override
  String get bankBalance => 'Balance';

  @override
  String get bankCredit => 'Credit';

  @override
  String get bankDebit => 'Debit';

  @override
  String get bankPaid => 'Paid';

  @override
  String get bankExpires => 'Expires on';

  @override
  String get bankEntries => 'Latest entries';

  @override
  String get bankNoEntries => 'No entries.';

  @override
  String get bankKindCredit => 'Credit';

  @override
  String get bankKindDebit => 'Debit';

  @override
  String get bankKindExpirePaid => 'Paid (expired)';

  @override
  String get bankKindManualPaid => 'Paid';
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
  String get versionUnsupported =>
      'This app version is no longer supported. Update the app from the store or with your administrator to continue.';

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
  String get punchNoLocationNotice =>
      'Punch recorded without location; HR will see it flagged.';

  @override
  String get receiptsLast48h => 'Receipts of the last 48 hours';

  @override
  String get receiptsLast48hEmpty => 'No receipts in the last 48 hours.';

  @override
  String get receiptFieldEmployer => 'Employer';

  @override
  String get receiptFieldEmployee => 'Employee';

  @override
  String get receiptFieldWhen => 'Date and time';

  @override
  String get receiptFieldCollector => 'Collector';

  @override
  String get receiptFieldHash => 'Verification code (SHA-256)';

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
  String confirmPunchTitle(String punch) {
    return 'Confirm $punch?';
  }

  @override
  String get confirmPunch => 'Confirm';

  @override
  String get retakePhoto => 'Take again';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get punchPhotoNote =>
      'Your company asks for a photo at each punch. It is kept for 90 days and seen only by HR.';

  @override
  String get punchPhotoMissing =>
      'No photo: the punch is recorded and flagged for HR.';

  @override
  String get punchPhotoFailed =>
      'Punch saved, but the photo could not be sent.';

  @override
  String get punchPhotoOffline =>
      'No connection: the punch was kept and the photo will be sent when the connection returns.';

  @override
  String get punchPhotoSaved => 'Punch saved with photo.';

  @override
  String get withPhoto => 'With photo';

  @override
  String get navDocuments => 'Documents';

  @override
  String get docsTabDocuments => 'Documents';

  @override
  String get docsTabPayslips => 'Payslips';

  @override
  String get docsTabNotices => 'Notices';

  @override
  String get docsTabVacation => 'Vacation';

  @override
  String get docKindDocument => 'Document';

  @override
  String get docKindWarning => 'Warning';

  @override
  String get docKindPayslip => 'Payslip';

  @override
  String get docKindEmployee => 'Sent by you';

  @override
  String get docStatePending => 'Acknowledgement pending';

  @override
  String docStateAcknowledged(String date) {
    return 'Acknowledged on $date';
  }

  @override
  String get docStateSent => 'New';

  @override
  String get docStateViewed => 'Viewed';

  @override
  String get docStateReceived => 'Sent to HR';

  @override
  String get docStateReviewed => 'Checked by HR';

  @override
  String get docOpen => 'Open';

  @override
  String get docAcknowledge => 'Acknowledge';

  @override
  String get docAckTitle => 'Confirm acknowledgement';

  @override
  String get docAckStatement =>
      'I declare that I read this document and acknowledge it.';

  @override
  String get docAckDone => 'Acknowledgement recorded.';

  @override
  String get docOpenFirst => 'Open the document before acknowledging it.';

  @override
  String get docsEmpty => 'No documents yet.';

  @override
  String get payslipsEmpty => 'No payslips yet.';

  @override
  String get docSend => 'Send a document to HR';

  @override
  String get docSendTitle => 'What is this document?';

  @override
  String get docSendTitleHint => 'E.g. proof of address';

  @override
  String get docSendNote => 'Note (optional)';

  @override
  String get docPickFile => 'Choose file (PDF or image up to 10 MB)';

  @override
  String get docSent => 'Document sent to HR.';

  @override
  String get docFileInvalid => 'Send a PDF or an image up to 10 MB.';

  @override
  String get docStorageUnavailable =>
      'Files are not available right now. Talk to HR.';

  @override
  String get docError => 'It could not be done. Try again.';

  @override
  String get docOpenFailed => 'The file could not be opened.';

  @override
  String docCompetence(String month) {
    return 'Competence $month';
  }

  @override
  String get noticesEmpty => 'No notices right now.';

  @override
  String get noticeNew => 'New';

  @override
  String get noticeRead => 'Read';

  @override
  String get noticeAckRequired => 'This notice asks for your acknowledgement.';

  @override
  String get vacationAvailable => 'Days available';

  @override
  String get vacationPendingDays => 'In requests';

  @override
  String get vacationAccruing => 'Accruing in the current period';

  @override
  String vacationDeadline(String date) {
    return 'Take by $date';
  }

  @override
  String get vacationNoHireDate =>
      'Your hire date is not registered. Talk to HR.';

  @override
  String get vacationPeriods => 'Acquisition periods';

  @override
  String vacationPeriodRange(String start, String end) {
    return '$start to $end';
  }

  @override
  String vacationPeriodUsage(int taken, int entitled) {
    return '$taken of $entitled days taken';
  }

  @override
  String get vacationAccruingStatus => 'Accruing';

  @override
  String get vacationAvailableStatus => 'Available';

  @override
  String get vacationUsedStatus => 'Taken';

  @override
  String get vacationOverdueStatus => 'Overdue';

  @override
  String get vacationRequest => 'Request vacation';

  @override
  String get vacationPickDates => 'Choose the dates';

  @override
  String vacationDays(int days) {
    return '$days days';
  }

  @override
  String get vacationReason => 'Note to HR';

  @override
  String get vacationSent => 'Vacation request sent. Follow it in Requests.';

  @override
  String get vacationExceeds =>
      'The chosen days go beyond your available balance.';

  @override
  String get vacationNothing => 'You have no vacation days to request yet.';

  @override
  String get absenceVacation => 'Vacation';

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
  String get notificationNotice => 'Company notice';

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

  @override
  String get permissionsTitle => 'Allow Pulse to work';

  @override
  String get permissionsIntro =>
      'To record your time safely, Pulse needs your location, camera and notifications. You allow them once and the browser or device keeps your choice.';

  @override
  String get permissionLocation => 'Location (GPS)';

  @override
  String get permissionLocationHelp =>
      'Recorded only at the moment of each punch.';

  @override
  String get permissionCamera => 'Camera';

  @override
  String get permissionCameraHelp => 'Live photo to confirm each punch.';

  @override
  String get permissionNotifications => 'Notifications';

  @override
  String get permissionNotificationsHelp =>
      'Requests, documents, notices and reminders.';

  @override
  String get permissionGranted => 'Allowed';

  @override
  String get permissionPending => 'Not allowed yet';

  @override
  String get permissionDenied => 'Blocked';

  @override
  String get permissionUnavailable => 'Turned off or not available';

  @override
  String get permissionUnsupported => 'Not available in this browser';

  @override
  String get permissionsAllow => 'Allow all';

  @override
  String get permissionsRecheck => 'Check again';

  @override
  String get permissionsAlwaysHint =>
      'When the browser asks, choose Allow (not \"only this time\") so you are not asked again.';

  @override
  String get permissionsDeniedHelp =>
      'A permission is blocked. Open the site settings (the lock next to the address) or the device settings, switch it to Allow and tap Check again.';

  @override
  String get permissionsUnavailableHelp =>
      'Turn on the device location (GPS) and make sure a camera is available.';

  @override
  String get permissionsLost =>
      'A permission of Pulse was turned off. Allow it again to punch.';

  @override
  String get punchPhotoRequired =>
      'Your company requires the photo to confirm the punch.';

  @override
  String get cameraUnavailable =>
      'The camera could not be opened. Check the camera permission and try again.';

  @override
  String get capturePhoto => 'Capture';

  @override
  String get kioskUseDevice => 'Use this device as the company time clock';

  @override
  String get kioskActivationTitle => 'Activate time clock';

  @override
  String get kioskActivationHelp =>
      'In the App, HR creates the time clock in HR › Time clocks and generates an activation code valid for 15 minutes. Type the code and set an administrator PIN, needed to leave the time clock mode on this device.';

  @override
  String get kioskActivationCode => 'Activation code';

  @override
  String get kioskAdminPin => 'Administrator PIN (4 to 8 digits)';

  @override
  String get kioskAdminPinConfirm => 'Confirm the administrator PIN';

  @override
  String get kioskAdminPinInvalid => 'Use 4 to 8 digits.';

  @override
  String get kioskPinMismatch => 'The PINs do not match.';

  @override
  String get kioskActivate => 'Activate';

  @override
  String get kioskCodeInvalid =>
      'Invalid or expired activation code. Ask HR for a new one.';

  @override
  String get kioskKeyRejected =>
      'This device could not be activated. Try again.';

  @override
  String get kioskClockSkew =>
      'This device\'s clock is far from the official time. Fix the date and time and try again.';

  @override
  String get kioskPinFixHint =>
      'For use as a time clock, pin the app to the screen (Android: pin app; iPhone/iPad: Guided Access).';

  @override
  String get kioskEnterCode => 'Type your access code';

  @override
  String get kioskEnterPin => 'Type your PIN';

  @override
  String get kioskContinue => 'Continue';

  @override
  String kioskHello(String name) {
    return 'Hello, $name';
  }

  @override
  String get kioskSuggested => 'Suggested mark';

  @override
  String get kioskOtherMarks => 'Other mark';

  @override
  String get kioskConfirmPunch => 'Confirm and record';

  @override
  String get kioskPhotoNote => 'A live photo is taken to confirm the mark.';

  @override
  String get kioskInvalidPin => 'Invalid code or PIN.';

  @override
  String get kioskPinLocked =>
      'PIN locked after wrong attempts. Try later or talk to HR.';

  @override
  String get kioskPinNotSet =>
      'You have no time clock PIN yet. Set it in Pulse (Time clock PIN) or ask HR.';

  @override
  String get kioskOffline =>
      'No connection: the time clock needs internet to record.';

  @override
  String get kioskPhotoRequired => 'The photo is required to record the mark.';

  @override
  String get kioskPunchSaved => 'Mark recorded';

  @override
  String get kioskPhotoFailed =>
      'Mark recorded, but the photo could not be sent.';

  @override
  String get kioskDone => 'Done';

  @override
  String kioskReturning(int seconds) {
    return 'Back to start in $seconds s';
  }

  @override
  String get kioskRevoked =>
      'This time clock was deactivated by HR. Ask for a new activation code.';

  @override
  String get kioskExit => 'Leave time clock mode';

  @override
  String get kioskExitHelp =>
      'Type the administrator PIN of this device. Ask HR to revoke the time clock in the App if the device is no longer used.';

  @override
  String get kioskExitWrong => 'Invalid administrator PIN.';

  @override
  String get kioskFullscreen => 'Full screen';

  @override
  String get kioskMarkTime => 'Time';

  @override
  String get kioskPinMenu => 'Time clock PIN';

  @override
  String get kioskPinHelp =>
      'Use this PIN with your access code on the company time clocks: 4 to 6 digits, no sequence or repeated digit.';

  @override
  String get kioskPinCurrentPassword => 'Current password';

  @override
  String get kioskPinNew => 'New PIN';

  @override
  String get kioskPinConfirm => 'Confirm the PIN';

  @override
  String get kioskPinInvalid =>
      'Use 4 to 6 digits, no sequence (1234) or repeated digit (1111).';

  @override
  String get kioskPinSaved => 'Time clock PIN saved.';

  @override
  String get kioskPinSave => 'Save PIN';

  @override
  String get receiptPrint => 'Print';

  @override
  String get receiptEmail => 'Send by e-mail';

  @override
  String receiptEmailSent(String recipient) {
    return 'Receipt sent to $recipient.';
  }

  @override
  String get receiptNoEmail =>
      'There is no e-mail in your registry. Ask HR to add it.';

  @override
  String get receiptEmailDisabled =>
      'This time clock does not send receipts by e-mail.';

  @override
  String get receiptEmailLimit =>
      'This receipt was already sent several times. Try again later.';

  @override
  String get receiptFailed => 'The receipt could not be prepared. Try again.';

  @override
  String get kioskOfflineTitle => 'No connection';

  @override
  String get kioskOfflineNote =>
      'Your mark stays on this time clock and is sent when the connection is back. The PIN is checked then; if it is wrong, HR sees the mark as refused.';

  @override
  String get kioskChooseMark => 'Choose the mark';

  @override
  String get kioskOfflineSaved => 'Mark kept on this time clock';

  @override
  String get kioskOfflineSavedNote =>
      'It is sent as soon as the connection is back.';

  @override
  String get kioskQueueFull =>
      'This time clock already keeps the maximum of marks without connection. Restore the internet.';

  @override
  String kioskOfflinePending(int count) {
    return '$count marks waiting to be sent';
  }

  @override
  String kioskExitPending(int count) {
    return '$count marks not sent yet are lost when leaving.';
  }

  @override
  String get tspPrint => 'Print / PDF';

  @override
  String get tspTitle => 'Timesheet';

  @override
  String get tspEmployer => 'Employer (legal name)';

  @override
  String get tspEmployerDocument => 'Tax ID';

  @override
  String get tspEmployee => 'Employee';

  @override
  String get tspCpf => 'CPF';

  @override
  String get tspHireDate => 'Hire date';

  @override
  String get tspPosition => 'Position';

  @override
  String get tspDepartment => 'Department';

  @override
  String get tspPeriod => 'Period';

  @override
  String get tspSchedules => 'Contractual schedules';

  @override
  String get tspKindWeekly => 'Weekly';

  @override
  String get tspKindCycle => 'Cycle';

  @override
  String get tspCycleDay => 'Cycle day';

  @override
  String get tspWeekdays =>
      'Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday';

  @override
  String get tspDays => 'Marks per day';

  @override
  String get tspDate => 'Date';

  @override
  String get tspDayCol => 'Day';

  @override
  String get tspMarks => 'Marks (NSR)';

  @override
  String get tspExpected => 'Expected';

  @override
  String get tspWorked => 'Worked';

  @override
  String get tspOvertime => 'Overtime';

  @override
  String get tspAbsence => 'Absence';

  @override
  String get tspLate => 'Late';

  @override
  String get tspNight => 'Night';

  @override
  String get tspBalance => 'Balance';

  @override
  String get tspIssues => 'Issues';

  @override
  String get tspTotals => 'Totals';

  @override
  String get tspLegend => 'Treatment legend';

  @override
  String get tspLegendText =>
      'I = mark included by a treatment; D = disregarded mark (struck through).';

  @override
  String get tspTime => 'Time';

  @override
  String get tspType => 'Type';

  @override
  String get tspReason => 'Reason';

  @override
  String get tspIssuedAt => 'Issued at';

  @override
  String get tspIncluded => 'Included';

  @override
  String get tspDisregarded => 'Disregarded';

  @override
  String get employmentLabel => 'Employment';

  @override
  String get employmentRegistrationShort => 'Reg.';

  @override
  String get employmentRequired =>
      'You have more than one employment. Choose the employment of this punch and punch again.';

  @override
  String get employmentInvalid =>
      'This employment is not valid for you now. Choose another one and punch again.';

  @override
  String get outsideGeofence => 'Outside the geofence';

  @override
  String get tspLocation => 'Location';

  @override
  String get tspRegistration => 'Registration no.';

  @override
  String get tspTermination => 'Termination';

  @override
  String get kioskEmploymentRequired =>
      'You have more than one employment. Punch on a time clock of your company or in the Pulse app.';

  @override
  String employmentWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count punches are waiting for an employment',
      one: '1 punch is waiting for an employment',
    );
    return '$_temp0';
  }

  @override
  String get employmentAssign => 'Assign employment and send';

  @override
  String get tspTotalsOmitted =>
      'Totals per employment are not available yet: you have another employment this month.';

  @override
  String get employmentAll => 'All employments';

  @override
  String punchTooOld(String when) {
    return 'Punch of $when not sent: more than 7 days without connection. Contact HR.';
  }

  @override
  String get punchNoticeDismiss => 'OK';

  @override
  String get closingTitle => 'Closing';

  @override
  String closingClosedAt(String when) {
    return 'Closed on $when';
  }

  @override
  String get closingAck => 'Acknowledge';

  @override
  String closingAcked(String when) {
    return 'Acknowledged on $when';
  }

  @override
  String get closingAwaiting => 'Waiting for your acknowledgement';

  @override
  String get closingAckConfirmTitle => 'Acknowledge the closing';

  @override
  String closingAckConfirmBody(String month) {
    return 'I confirm that I saw the closed timesheet of $month.';
  }

  @override
  String get closingWorked => 'Worked';

  @override
  String get closingOvertime50 => 'Overtime 50%';

  @override
  String get closingOvertime100 => 'Overtime 100%';

  @override
  String get closingAbsences => 'Absences (days)';

  @override
  String get closingDsrLost => 'Weeks without paid rest';

  @override
  String closingNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count closed months waiting for your acknowledgement',
      one: '1 closed month waiting for your acknowledgement',
    );
    return '$_temp0';
  }

  @override
  String get closingNoticeOpen => 'View';

  @override
  String get bankTitle => 'Hour bank';

  @override
  String get bankBalance => 'Balance';

  @override
  String get bankCredit => 'Credit';

  @override
  String get bankDebit => 'Debit';

  @override
  String get bankPaid => 'Paid';

  @override
  String get bankExpires => 'Expires on';

  @override
  String get bankEntries => 'Latest entries';

  @override
  String get bankNoEntries => 'No entries.';

  @override
  String get bankKindCredit => 'Credit';

  @override
  String get bankKindDebit => 'Debit';

  @override
  String get bankKindExpirePaid => 'Paid (expired)';

  @override
  String get bankKindManualPaid => 'Paid';
}
