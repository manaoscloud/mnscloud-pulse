// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get language => 'Idioma';

  @override
  String get system => 'Idioma del sistema';

  @override
  String get eyebrow => 'Acceso del colaborador';

  @override
  String get title => 'Accede a tu registro horario';

  @override
  String get subtitle =>
      'Usa el código de acceso proporcionado por tu empresa.';

  @override
  String get heroTitle => 'Tu jornada.\nConectada.';

  @override
  String get heroText =>
      'Registra tus horarios y consulta tu jornada en un solo lugar.';

  @override
  String get supportLabel => '¿Necesitas acceso? Contacta con tu empresa';

  @override
  String get privacy => 'Privacidad';

  @override
  String get terms => 'Términos de uso';

  @override
  String get employeeCode => 'Código de acceso del colaborador';

  @override
  String get password => 'Contraseña';

  @override
  String get signIn => 'Entrar';

  @override
  String get signOut => 'Salir';

  @override
  String get showPassword => 'Mostrar contraseña';

  @override
  String get hidePassword => 'Ocultar contraseña';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get forgotPasswordTitle => 'Recuperar contraseña';

  @override
  String get forgotPasswordHelp =>
      'Tu empresa gestiona la contraseña de Pulse. Pide al responsable de tu acceso una nueva contraseña temporal; en el próximo acceso elegirás la tuya.';

  @override
  String get close => 'Cerrar';

  @override
  String get required => 'Este campo es obligatorio.';

  @override
  String get invalidCredentials => 'Código de acceso o contraseña incorrectos.';

  @override
  String get networkError => 'No se pudo conectar. Inténtalo de nuevo.';

  @override
  String get requestError =>
      'No se pudo completar. Inténtalo de nuevo o contacta con tu empresa.';

  @override
  String get rateLimited =>
      'Demasiados intentos. Espera antes de volver a intentarlo.';

  @override
  String get firstAccess => 'Crea tu nueva contraseña';

  @override
  String get firstAccessHelp =>
      'Sustituye tu contraseña temporal antes de registrar tu jornada.';

  @override
  String get newPassword => 'Nueva contraseña';

  @override
  String get confirmPassword => 'Confirma la contraseña';

  @override
  String get passwordLength => 'Usa al menos 10 caracteres.';

  @override
  String get passwordMismatch => 'Las contraseñas no coinciden.';

  @override
  String get changePassword => 'Guardar nueva contraseña';

  @override
  String get signedIn => 'Acceso realizado.';

  @override
  String get passwordChanged => 'Contraseña cambiada correctamente.';

  @override
  String get signedOut => 'Has cerrado sesión.';

  @override
  String get employee => 'Colaborador';

  @override
  String get clockIn => 'Entrada';

  @override
  String get breakStart => 'Inicio de la pausa';

  @override
  String get breakEnd => 'Fin de la pausa';

  @override
  String get clockOut => 'Salida';

  @override
  String get recentPunches => 'Registros recientes';

  @override
  String get punchSaved => 'Registro guardado.';

  @override
  String get punchSynced => 'Registro ya sincronizado.';

  @override
  String get importantUpdate => 'Actualización importante';

  @override
  String get newVersion => 'Nueva versión disponible';

  @override
  String get updateNow => 'Actualizar ahora';

  @override
  String get later => 'Más tarde';

  @override
  String get updateHelp =>
      'Hay una nueva versión. Deberás iniciar sesión después de actualizar.';

  @override
  String get versionUnsupported =>
      'Esta versión de la app ya no es compatible. Actualice la app desde la tienda o con su administrador para continuar.';

  @override
  String get officialTime => 'Hora oficial';

  @override
  String get nextPunch => 'Próximo registro';

  @override
  String get otherPunch => 'Otro registro';

  @override
  String get onlineStatus => 'Conectado';

  @override
  String get offlineStatus => 'Sin conexión';

  @override
  String pendingPunches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros pendientes de envío',
      one: '1 registro pendiente de envío',
    );
    return '$_temp0';
  }

  @override
  String get punchQueued =>
      'Sin conexión: el registro se guardó y se enviará automáticamente.';

  @override
  String get receipt => 'Último comprobante';

  @override
  String get punchNoLocationNotice =>
      'Registro guardado sin ubicación; RR. HH. lo verá señalado.';

  @override
  String get receiptsLast48h => 'Comprobantes de las últimas 48 horas';

  @override
  String get receiptsLast48hEmpty =>
      'Sin comprobantes en las últimas 48 horas.';

  @override
  String get receiptFieldEmployer => 'Empleador';

  @override
  String get receiptFieldEmployee => 'Trabajador';

  @override
  String get receiptFieldWhen => 'Fecha y hora';

  @override
  String get receiptFieldCollector => 'Colector';

  @override
  String get receiptFieldHash => 'Código de verificación (SHA-256)';

  @override
  String nsrLabel(String nsr) {
    return 'NSR $nsr';
  }

  @override
  String get sessionEnded => 'Tu sesión terminó. Inicia sesión de nuevo.';

  @override
  String get accountLocked =>
      'Cuenta bloqueada temporalmente. Inténtalo de nuevo en unos minutos.';

  @override
  String get temporaryPasswordExpired =>
      'Tu contraseña temporal caducó. Pide una nueva a tu empresa.';

  @override
  String get moduleUnavailable =>
      'El control horario no está disponible para tu empresa. Habla con RR. HH.';

  @override
  String get accessDenied => 'Tu acceso no está activo. Habla con RR. HH.';

  @override
  String get invalidPassword => 'La contraseña actual no es válida.';

  @override
  String get passwordUnchanged =>
      'La nueva contraseña debe ser diferente de la actual.';

  @override
  String get pendingSignOutTitle => 'Registros pendientes de envío';

  @override
  String get pendingSignOutHelp =>
      'Algunos registros aún no se enviaron. Quedan protegidos en este dispositivo y se envían automáticamente en cuanto haya conexión (o cuando vuelvas a iniciar sesión aquí).';

  @override
  String get offlineEntry =>
      'Modo sin conexión: tus registros quedan protegidos en este dispositivo y se envían automáticamente cuando vuelva la conexión.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get signOutAnyway => 'Salir';

  @override
  String get noPunchesYet => 'Aún no hay registros.';

  @override
  String get loading => 'Cargando…';

  @override
  String get locationNote =>
      'Tu ubicación se registra solo en el momento de cada registro, cuando lo permites.';

  @override
  String get sentLater => 'Enviado después';

  @override
  String get pendingSend => 'Pendiente de envío';

  @override
  String get navHome => 'Inicio';

  @override
  String get navTimesheet => 'Registro horario';

  @override
  String get today => 'Hoy';

  @override
  String get workDay => 'Día laborable';

  @override
  String get dayOff => 'Día libre';

  @override
  String get holiday => 'Festivo';

  @override
  String holidayNamed(String name) {
    return 'Festivo: $name';
  }

  @override
  String get noSchedule => 'Sin jornada definida';

  @override
  String get workedToday => 'Trabajado hoy';

  @override
  String get statusWorking => 'Trabajando';

  @override
  String get statusOnBreak => 'En pausa';

  @override
  String get statusOffDuty => 'Fuera de jornada';

  @override
  String get previousMonth => 'Mes anterior';

  @override
  String get nextMonth => 'Mes siguiente';

  @override
  String get refresh => 'Actualizar';

  @override
  String get retry => 'Reintentar';

  @override
  String get totalWorked => 'Trabajado';

  @override
  String get totalExpected => 'Previsto';

  @override
  String get totalBalance => 'Saldo';

  @override
  String get totalOvertime => 'Horas extra';

  @override
  String get totalAbsences => 'Ausencias';

  @override
  String get noPunchesDay => 'Sin marcaciones';

  @override
  String get timesheetEmpty => 'Aún no hay días en este mes.';

  @override
  String unassignedPunches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count marcaciones aún en procesamiento',
      one: '1 marcación aún en procesamiento',
    );
    return '$_temp0';
  }

  @override
  String get flagAbsence => 'Ausencia';

  @override
  String get flagMissingPunch => 'Marcación faltante';

  @override
  String get flagLate => 'Retraso';

  @override
  String get flagEarlyLeave => 'Salida anticipada';

  @override
  String get flagShortBreak => 'Pausa corta';

  @override
  String get flagRestViolation => 'Descanso entre jornadas';

  @override
  String get flagOvertimeLimit => 'Horas extra sobre el límite';

  @override
  String get flagWorkedDayOff => 'Trabajo en día libre';

  @override
  String get flagFlaggedPunch => 'Marcación señalada';

  @override
  String get flagNoSchedule => 'Sin jornada';

  @override
  String get installApp => 'Instalar app';

  @override
  String get installIosSteps =>
      'En Safari, toca Compartir y luego \"Agregar a pantalla de inicio\".';

  @override
  String get navRequests => 'Solicitudes';

  @override
  String get back => 'Volver';

  @override
  String get requestNew => 'Nueva solicitud';

  @override
  String get requestMissingPunch => 'Olvidé fichar';

  @override
  String get requestPunchContest => 'Impugnar fichaje';

  @override
  String get requestAbsence => 'Ausencia';

  @override
  String get absenceMedicalCertificate => 'Certificado médico';

  @override
  String get absenceJustified => 'Falta justificada';

  @override
  String get absenceDayOff => 'Día libre';

  @override
  String get absenceLeave => 'Licencia';

  @override
  String get requestPending => 'Pendiente';

  @override
  String get requestApproved => 'Aprobada';

  @override
  String get requestRejected => 'Rechazada';

  @override
  String get requestCancelled => 'Cancelada';

  @override
  String get requestEmpty =>
      'Aún no tiene solicitudes. Use “Nueva solicitud” si olvidó fichar, necesita impugnar un fichaje o justificar una ausencia.';

  @override
  String get requestSent => 'Solicitud enviada. La respuesta aparecerá aquí.';

  @override
  String get requestCancelTitle => '¿Cancelar la solicitud?';

  @override
  String get requestCancelText => 'La solicitud sale de la cola de su gestor.';

  @override
  String get requestCancelAction => 'Cancelar solicitud';

  @override
  String get requestDate => 'Fecha';

  @override
  String get requestTime => 'Hora';

  @override
  String get requestMark => 'Fichaje';

  @override
  String get requestChoosePunch => 'Elija el fichaje a impugnar:';

  @override
  String get requestNoPunches => 'No hay fichajes recientes.';

  @override
  String get requestAbsenceType => 'Tipo de ausencia';

  @override
  String get requestStartDate => 'Primer día';

  @override
  String get requestEndDate => 'Último día';

  @override
  String get requestAttachCertificate => 'Adjuntar certificado (foto o PDF)';

  @override
  String get requestCertificateHint =>
      'PNG, JPEG, WEBP o PDF hasta 10 MB. Solo RR. HH. y su gestor lo ven.';

  @override
  String get requestReason => 'Motivo';

  @override
  String get requestSend => 'Enviar solicitud';

  @override
  String get requestReasonRequired => 'Indique el motivo.';

  @override
  String get requestTimeRequired => 'Elija la hora del fichaje.';

  @override
  String get requestPunchRequired => 'Elija el fichaje a impugnar.';

  @override
  String get requestEndBeforeStart => 'El último día es anterior al primero.';

  @override
  String get requestFileInvalid =>
      'Envíe una foto (PNG, JPEG, WEBP) o un PDF de hasta 10 MB.';

  @override
  String get requestDuplicate => 'Ya existe una solicitud pendiente para esto.';

  @override
  String get requestPeriodClosed =>
      'Esa fecha es anterior al período abierto. Hable con RR. HH.';

  @override
  String get requestOverlap => 'Esos días ya tienen una ausencia.';

  @override
  String get requestAlreadyTreated => 'Ese fichaje ya fue descartado.';

  @override
  String get requestFutureTime => 'La hora no puede estar en el futuro.';

  @override
  String get requestAlreadyDecided => 'Esa solicitud ya fue respondida.';

  @override
  String get requestAttachmentUnavailable =>
      'No es posible enviar certificados ahora. Envíe la solicitud sin él y entréguelo a RR. HH.';

  @override
  String requestAnswer(String note) {
    return 'Respuesta: $note';
  }

  @override
  String confirmPunchTitle(String punch) {
    return '¿Confirmar $punch?';
  }

  @override
  String get confirmPunch => 'Confirmar';

  @override
  String get retakePhoto => 'Tomar otra';

  @override
  String get takePhoto => 'Tomar foto';

  @override
  String get punchPhotoNote =>
      'Tu empresa pide una foto en cada registro. Se guarda 90 días y solo RR. HH. la ve.';

  @override
  String get punchPhotoMissing =>
      'Sin foto: el registro se guarda y se señala para RR. HH.';

  @override
  String get punchPhotoFailed => 'Registro guardado, pero la foto no se envió.';

  @override
  String get punchPhotoOffline =>
      'Sin conexión: el registro se guardó y la foto se enviará cuando vuelva la conexión.';

  @override
  String get punchPhotoSaved => 'Registro guardado con foto.';

  @override
  String get withPhoto => 'Con foto';

  @override
  String get navDocuments => 'Documentos';

  @override
  String get docsTabDocuments => 'Documentos';

  @override
  String get docsTabPayslips => 'Nóminas';

  @override
  String get docsTabNotices => 'Avisos';

  @override
  String get docsTabVacation => 'Vacaciones';

  @override
  String get docKindDocument => 'Documento';

  @override
  String get docKindWarning => 'Amonestación';

  @override
  String get docKindPayslip => 'Nómina';

  @override
  String get docKindEmployee => 'Enviado por ti';

  @override
  String get docStatePending => 'Acuse pendiente';

  @override
  String docStateAcknowledged(String date) {
    return 'Recibido el $date';
  }

  @override
  String get docStateSent => 'Nuevo';

  @override
  String get docStateViewed => 'Visto';

  @override
  String get docStateReceived => 'Enviado a RR. HH.';

  @override
  String get docStateReviewed => 'Revisado por RR. HH.';

  @override
  String get docOpen => 'Abrir';

  @override
  String get docAcknowledge => 'Acusar recibo';

  @override
  String get docAckTitle => 'Confirmar acuse de recibo';

  @override
  String get docAckStatement =>
      'Declaro que leí este documento y tomo conocimiento de su contenido.';

  @override
  String get docAckDone => 'Acuse de recibo registrado.';

  @override
  String get docOpenFirst => 'Abre el documento antes de acusar recibo.';

  @override
  String get docsEmpty => 'Todavía no hay documentos.';

  @override
  String get payslipsEmpty => 'Todavía no hay nóminas.';

  @override
  String get docSend => 'Enviar documento a RR. HH.';

  @override
  String get docSendTitle => '¿Qué documento es?';

  @override
  String get docSendTitleHint => 'Ej.: comprobante de domicilio';

  @override
  String get docSendNote => 'Observación (opcional)';

  @override
  String get docPickFile => 'Elegir archivo (PDF o imagen hasta 10 MB)';

  @override
  String get docSent => 'Documento enviado a RR. HH.';

  @override
  String get docFileInvalid => 'Envía un PDF o una imagen de hasta 10 MB.';

  @override
  String get docStorageUnavailable =>
      'Los archivos no están disponibles ahora. Habla con RR. HH.';

  @override
  String get docError => 'No se pudo completar. Inténtalo de nuevo.';

  @override
  String get docOpenFailed => 'No se pudo abrir el archivo.';

  @override
  String docCompetence(String month) {
    return 'Período $month';
  }

  @override
  String get noticesEmpty => 'No hay avisos por ahora.';

  @override
  String get noticeNew => 'Nuevo';

  @override
  String get noticeRead => 'Leído';

  @override
  String get noticeAckRequired => 'Este aviso pide tu acuse de recibo.';

  @override
  String get vacationAvailable => 'Días disponibles';

  @override
  String get vacationPendingDays => 'En solicitudes';

  @override
  String get vacationAccruing => 'Proporcionales del período actual';

  @override
  String vacationDeadline(String date) {
    return 'Plazo para disfrutar: $date';
  }

  @override
  String get vacationNoHireDate =>
      'Tu fecha de ingreso no está registrada. Habla con RR. HH.';

  @override
  String get vacationPeriods => 'Períodos de adquisición';

  @override
  String vacationPeriodRange(String start, String end) {
    return '$start a $end';
  }

  @override
  String vacationPeriodUsage(int taken, int entitled) {
    return '$taken de $entitled días usados';
  }

  @override
  String get vacationAccruingStatus => 'En adquisición';

  @override
  String get vacationAvailableStatus => 'Disponible';

  @override
  String get vacationUsedStatus => 'Disfrutado';

  @override
  String get vacationOverdueStatus => 'Vencido';

  @override
  String get vacationRequest => 'Solicitar vacaciones';

  @override
  String get vacationPickDates => 'Elegir las fechas';

  @override
  String vacationDays(int days) {
    return '$days días';
  }

  @override
  String get vacationReason => 'Observación para RR. HH.';

  @override
  String get vacationSent =>
      'Solicitud de vacaciones enviada. Síguela en Solicitudes.';

  @override
  String get vacationExceeds =>
      'Los días elegidos superan tu saldo disponible.';

  @override
  String get vacationNothing =>
      'Todavía no tienes días de vacaciones para solicitar.';

  @override
  String get absenceVacation => 'Vacaciones';

  @override
  String get notificationsTitle => 'Avisos';

  @override
  String get notificationsReadAll => 'Marcar todos como leídos';

  @override
  String get notificationsEmpty => 'Aún no hay avisos.';

  @override
  String get notificationsError => 'No se pudieron cargar los avisos.';

  @override
  String get notificationApproved => 'Solicitud aprobada';

  @override
  String get notificationRejected => 'Solicitud rechazada';

  @override
  String get notificationMessage => 'Nuevo mensaje en una solicitud';

  @override
  String get notificationNotice => 'Aviso de la empresa';

  @override
  String get pushTitle => 'Notificaciones en este dispositivo';

  @override
  String get pushText =>
      'Reciba respuestas y recordatorios incluso con Pulse cerrado.';

  @override
  String get pushDenied =>
      'Las notificaciones están bloqueadas en el navegador. Permítalas en la configuración del sitio.';

  @override
  String get pushUnavailable =>
      'No se pudieron activar las notificaciones ahora.';

  @override
  String get pushUnsupported =>
      'Este navegador no recibe notificaciones. En iPhone, agregue Pulse a la pantalla de inicio.';

  @override
  String get remindersTitle => 'Recordatorios de marcación';

  @override
  String get remindersText =>
      'Un aviso cuando pase la hora de entrada o de salida sin marcación.';

  @override
  String get remindersOff =>
      'Su empresa no activó los recordatorios de marcación.';

  @override
  String requestConversation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensajes',
      one: '1 mensaje',
      zero: 'Conversación',
    );
    return '$_temp0';
  }

  @override
  String get conversationEmpty => 'Escriba a su gestor sobre esta solicitud.';

  @override
  String get conversationEmptyClosed => 'Sin mensajes.';

  @override
  String get conversationError => 'No se pudo enviar o cargar la conversación.';

  @override
  String get conversationHint => 'Mensaje';

  @override
  String get conversationSend => 'Enviar';

  @override
  String get conversationClosed =>
      'La conversación está disponible solo mientras la solicitud está pendiente.';

  @override
  String get conversationYou => 'Usted';

  @override
  String get conversationManager => 'Gestor';

  @override
  String get permissionsTitle => 'Permisos de Pulse';

  @override
  String get permissionsIntro =>
      'Para registrar la jornada con seguridad, Pulse necesita la ubicación, la cámara y las notificaciones. Las autorizas una sola vez y el navegador o el dispositivo guarda la elección.';

  @override
  String get permissionLocation => 'Ubicación (GPS)';

  @override
  String get permissionLocationHelp =>
      'Se registra solo en el momento de cada fichaje.';

  @override
  String get permissionCamera => 'Cámara';

  @override
  String get permissionCameraHelp =>
      'Foto en vivo para confirmar cada fichaje.';

  @override
  String get permissionNotifications => 'Notificaciones';

  @override
  String get permissionNotificationsHelp =>
      'Solicitudes, documentos, avisos y recordatorios.';

  @override
  String get permissionGranted => 'Permitido';

  @override
  String get permissionPending => 'Aún no permitido';

  @override
  String get permissionDenied => 'Bloqueado';

  @override
  String get permissionUnavailable => 'Apagado o no disponible';

  @override
  String get permissionUnsupported => 'No disponible en este navegador';

  @override
  String get permissionsAllow => 'Permitir todo';

  @override
  String get permissionsRecheck => 'Verificar de nuevo';

  @override
  String get permissionsAlwaysHint =>
      'Cuando el navegador pregunte, elige Permitir (no \"solo esta vez\") para que no te pregunte de nuevo.';

  @override
  String get permissionsDeniedHelp =>
      'Un permiso está bloqueado. Abre la configuración del sitio (el candado junto a la dirección) o del dispositivo, cámbialo a Permitir y toca Verificar de nuevo.';

  @override
  String get permissionsUnavailableHelp =>
      'Activa la ubicación (GPS) del dispositivo y comprueba que haya una cámara disponible.';

  @override
  String get permissionsLost =>
      'Se desactivó un permiso de Pulse. Vuelve a permitirlo para fichar.';

  @override
  String get punchPhotoRequired =>
      'Tu empresa exige la foto para confirmar el fichaje.';

  @override
  String get cameraUnavailable =>
      'No se pudo abrir la cámara. Revisa el permiso de la cámara e inténtalo de nuevo.';

  @override
  String get capturePhoto => 'Capturar';

  @override
  String get kioskUseDevice => 'Usar este dispositivo como reloj de la empresa';

  @override
  String get kioskActivationTitle => 'Activar reloj de fichaje';

  @override
  String get kioskActivationHelp =>
      'En la App, RR. HH. crea el reloj en RR. HH. › Relojes y genera un código de activación válido por 15 minutos. Escribe el código y define un PIN de administrador, necesario para salir del modo reloj en este dispositivo.';

  @override
  String get kioskActivationCode => 'Código de activación';

  @override
  String get kioskAdminPin => 'PIN de administrador (4 a 8 dígitos)';

  @override
  String get kioskAdminPinConfirm => 'Confirma el PIN de administrador';

  @override
  String get kioskAdminPinInvalid => 'Usa de 4 a 8 dígitos.';

  @override
  String get kioskPinMismatch => 'Los PIN no coinciden.';

  @override
  String get kioskActivate => 'Activar';

  @override
  String get kioskCodeInvalid =>
      'Código de activación inválido o vencido. Pide uno nuevo a RR. HH.';

  @override
  String get kioskKeyRejected =>
      'No se pudo activar este dispositivo. Inténtalo de nuevo.';

  @override
  String get kioskClockSkew =>
      'El reloj de este dispositivo difiere mucho de la hora oficial. Ajusta la fecha y la hora e inténtalo de nuevo.';

  @override
  String get kioskPinFixHint =>
      'Para usarlo como reloj, fija la app en la pantalla (Android: fijar app; iPhone/iPad: Acceso guiado).';

  @override
  String get kioskEnterCode => 'Escribe tu código de acceso';

  @override
  String get kioskEnterPin => 'Escribe tu PIN';

  @override
  String get kioskContinue => 'Continuar';

  @override
  String kioskHello(String name) {
    return 'Hola, $name';
  }

  @override
  String get kioskSuggested => 'Fichaje sugerido';

  @override
  String get kioskOtherMarks => 'Otro fichaje';

  @override
  String get kioskConfirmPunch => 'Confirmar y registrar';

  @override
  String get kioskPhotoNote =>
      'Se toma una foto en vivo para confirmar el fichaje.';

  @override
  String get kioskInvalidPin => 'Código o PIN inválido.';

  @override
  String get kioskPinLocked =>
      'PIN bloqueado por intentos fallidos. Inténtalo más tarde o habla con RR. HH.';

  @override
  String get kioskPinNotSet =>
      'Aún no tienes PIN del reloj. Defínelo en Pulse (PIN del reloj) o pídelo a RR. HH.';

  @override
  String get kioskOffline =>
      'Sin conexión: el reloj necesita internet para registrar.';

  @override
  String get kioskPhotoRequired =>
      'La foto es obligatoria para registrar el fichaje.';

  @override
  String get kioskPunchSaved => 'Fichaje registrado';

  @override
  String get kioskPhotoFailed =>
      'Fichaje registrado, pero la foto no se pudo enviar.';

  @override
  String get kioskDone => 'Listo';

  @override
  String kioskReturning(int seconds) {
    return 'Volviendo al inicio en $seconds s';
  }

  @override
  String get kioskRevoked =>
      'RR. HH. desactivó este reloj. Pide un nuevo código de activación.';

  @override
  String get kioskExit => 'Salir del modo reloj';

  @override
  String get kioskExitHelp =>
      'Escribe el PIN de administrador de este dispositivo. Pide a RR. HH. que revoque el reloj en la App si el dispositivo ya no se usa.';

  @override
  String get kioskExitWrong => 'PIN de administrador inválido.';

  @override
  String get kioskFullscreen => 'Pantalla completa';

  @override
  String get kioskMarkTime => 'Hora';

  @override
  String get kioskPinMenu => 'PIN del reloj';

  @override
  String get kioskPinHelp =>
      'Usa este PIN con tu código de acceso en los relojes de la empresa: 4 a 6 dígitos, sin secuencia ni número repetido.';

  @override
  String get kioskPinCurrentPassword => 'Contraseña actual';

  @override
  String get kioskPinNew => 'Nuevo PIN';

  @override
  String get kioskPinConfirm => 'Confirma el PIN';

  @override
  String get kioskPinInvalid =>
      'Usa de 4 a 6 dígitos, sin secuencia (1234) ni número repetido (1111).';

  @override
  String get kioskPinSaved => 'PIN del reloj guardado.';

  @override
  String get kioskPinSave => 'Guardar PIN';

  @override
  String get receiptPrint => 'Imprimir';

  @override
  String get receiptEmail => 'Enviar por correo';

  @override
  String receiptEmailSent(String recipient) {
    return 'Comprobante enviado a $recipient.';
  }

  @override
  String get receiptNoEmail =>
      'No hay correo en tu registro. Pide a RR. HH. que lo agregue.';

  @override
  String get receiptEmailDisabled =>
      'Este reloj no envía comprobantes por correo.';

  @override
  String get receiptEmailLimit =>
      'Este comprobante ya se envió varias veces. Inténtalo más tarde.';

  @override
  String get receiptFailed =>
      'No se pudo preparar el comprobante. Inténtalo de nuevo.';

  @override
  String get kioskOfflineTitle => 'Sin conexión';

  @override
  String get kioskOfflineNote =>
      'Tu fichaje queda guardado en este reloj y se envía cuando vuelva la conexión. El PIN se verifica en el envío; si es incorrecto, RR. HH. verá el fichaje como rechazado.';

  @override
  String get kioskChooseMark => 'Elige el fichaje';

  @override
  String get kioskOfflineSaved => 'Fichaje guardado en este reloj';

  @override
  String get kioskOfflineSavedNote =>
      'Se enviará en cuanto vuelva la conexión.';

  @override
  String get kioskQueueFull =>
      'Este reloj ya guardó el máximo de fichajes sin conexión. Restablece internet.';

  @override
  String kioskOfflinePending(int count) {
    return '$count fichajes esperando envío';
  }

  @override
  String kioskExitPending(int count) {
    return '$count fichajes aún no enviados se perderán al salir.';
  }
}

/// The translations for Spanish Castilian, as used in Spain (`es_ES`).
class AppLocalizationsEsEs extends AppLocalizationsEs {
  AppLocalizationsEsEs() : super('es_ES');

  @override
  String get language => 'Idioma';

  @override
  String get system => 'Idioma del sistema';

  @override
  String get eyebrow => 'Acceso del colaborador';

  @override
  String get title => 'Accede a tu registro horario';

  @override
  String get subtitle =>
      'Usa el código de acceso proporcionado por tu empresa.';

  @override
  String get heroTitle => 'Tu jornada.\nConectada.';

  @override
  String get heroText =>
      'Registra tus horarios y consulta tu jornada en un solo lugar.';

  @override
  String get supportLabel => '¿Necesitas acceso? Contacta con tu empresa';

  @override
  String get privacy => 'Privacidad';

  @override
  String get terms => 'Términos de uso';

  @override
  String get employeeCode => 'Código de acceso del colaborador';

  @override
  String get password => 'Contraseña';

  @override
  String get signIn => 'Entrar';

  @override
  String get signOut => 'Salir';

  @override
  String get showPassword => 'Mostrar contraseña';

  @override
  String get hidePassword => 'Ocultar contraseña';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get forgotPasswordTitle => 'Recuperar contraseña';

  @override
  String get forgotPasswordHelp =>
      'Tu empresa gestiona la contraseña de Pulse. Pide al responsable de tu acceso una nueva contraseña temporal; en el próximo acceso elegirás la tuya.';

  @override
  String get close => 'Cerrar';

  @override
  String get required => 'Este campo es obligatorio.';

  @override
  String get invalidCredentials => 'Código de acceso o contraseña incorrectos.';

  @override
  String get networkError => 'No se pudo conectar. Inténtalo de nuevo.';

  @override
  String get requestError =>
      'No se pudo completar. Inténtalo de nuevo o contacta con tu empresa.';

  @override
  String get rateLimited =>
      'Demasiados intentos. Espera antes de volver a intentarlo.';

  @override
  String get firstAccess => 'Crea tu nueva contraseña';

  @override
  String get firstAccessHelp =>
      'Sustituye tu contraseña temporal antes de registrar tu jornada.';

  @override
  String get newPassword => 'Nueva contraseña';

  @override
  String get confirmPassword => 'Confirma la contraseña';

  @override
  String get passwordLength => 'Usa al menos 10 caracteres.';

  @override
  String get passwordMismatch => 'Las contraseñas no coinciden.';

  @override
  String get changePassword => 'Guardar nueva contraseña';

  @override
  String get signedIn => 'Acceso realizado.';

  @override
  String get passwordChanged => 'Contraseña cambiada correctamente.';

  @override
  String get signedOut => 'Has cerrado sesión.';

  @override
  String get employee => 'Colaborador';

  @override
  String get clockIn => 'Entrada';

  @override
  String get breakStart => 'Inicio de la pausa';

  @override
  String get breakEnd => 'Fin de la pausa';

  @override
  String get clockOut => 'Salida';

  @override
  String get recentPunches => 'Registros recientes';

  @override
  String get punchSaved => 'Registro guardado.';

  @override
  String get punchSynced => 'Registro ya sincronizado.';

  @override
  String get importantUpdate => 'Actualización importante';

  @override
  String get newVersion => 'Nueva versión disponible';

  @override
  String get updateNow => 'Actualizar ahora';

  @override
  String get later => 'Más tarde';

  @override
  String get updateHelp =>
      'Hay una nueva versión. Deberás iniciar sesión después de actualizar.';

  @override
  String get versionUnsupported =>
      'Esta versión de la app ya no es compatible. Actualice la app desde la tienda o con su administrador para continuar.';

  @override
  String get officialTime => 'Hora oficial';

  @override
  String get nextPunch => 'Próximo registro';

  @override
  String get otherPunch => 'Otro registro';

  @override
  String get onlineStatus => 'Conectado';

  @override
  String get offlineStatus => 'Sin conexión';

  @override
  String pendingPunches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros pendientes de envío',
      one: '1 registro pendiente de envío',
    );
    return '$_temp0';
  }

  @override
  String get punchQueued =>
      'Sin conexión: el registro se guardó y se enviará automáticamente.';

  @override
  String get receipt => 'Último comprobante';

  @override
  String get punchNoLocationNotice =>
      'Registro guardado sin ubicación; RR. HH. lo verá señalado.';

  @override
  String get receiptsLast48h => 'Comprobantes de las últimas 48 horas';

  @override
  String get receiptsLast48hEmpty =>
      'Sin comprobantes en las últimas 48 horas.';

  @override
  String get receiptFieldEmployer => 'Empleador';

  @override
  String get receiptFieldEmployee => 'Trabajador';

  @override
  String get receiptFieldWhen => 'Fecha y hora';

  @override
  String get receiptFieldCollector => 'Colector';

  @override
  String get receiptFieldHash => 'Código de verificación (SHA-256)';

  @override
  String nsrLabel(String nsr) {
    return 'NSR $nsr';
  }

  @override
  String get sessionEnded => 'Tu sesión terminó. Inicia sesión de nuevo.';

  @override
  String get accountLocked =>
      'Cuenta bloqueada temporalmente. Inténtalo de nuevo en unos minutos.';

  @override
  String get temporaryPasswordExpired =>
      'Tu contraseña temporal caducó. Pide una nueva a tu empresa.';

  @override
  String get moduleUnavailable =>
      'El control horario no está disponible para tu empresa. Habla con RR. HH.';

  @override
  String get accessDenied => 'Tu acceso no está activo. Habla con RR. HH.';

  @override
  String get invalidPassword => 'La contraseña actual no es válida.';

  @override
  String get passwordUnchanged =>
      'La nueva contraseña debe ser diferente de la actual.';

  @override
  String get pendingSignOutTitle => 'Registros pendientes de envío';

  @override
  String get pendingSignOutHelp =>
      'Algunos registros aún no se enviaron. Quedan protegidos en este dispositivo y se envían automáticamente en cuanto haya conexión (o cuando vuelvas a iniciar sesión aquí).';

  @override
  String get offlineEntry =>
      'Modo sin conexión: tus registros quedan protegidos en este dispositivo y se envían automáticamente cuando vuelva la conexión.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get signOutAnyway => 'Salir';

  @override
  String get noPunchesYet => 'Aún no hay registros.';

  @override
  String get loading => 'Cargando…';

  @override
  String get locationNote =>
      'Tu ubicación se registra solo en el momento de cada registro, cuando lo permites.';

  @override
  String get sentLater => 'Enviado después';

  @override
  String get pendingSend => 'Pendiente de envío';

  @override
  String get navHome => 'Inicio';

  @override
  String get navTimesheet => 'Registro horario';

  @override
  String get today => 'Hoy';

  @override
  String get workDay => 'Día laborable';

  @override
  String get dayOff => 'Día libre';

  @override
  String get holiday => 'Festivo';

  @override
  String holidayNamed(String name) {
    return 'Festivo: $name';
  }

  @override
  String get noSchedule => 'Sin jornada definida';

  @override
  String get workedToday => 'Trabajado hoy';

  @override
  String get statusWorking => 'Trabajando';

  @override
  String get statusOnBreak => 'En pausa';

  @override
  String get statusOffDuty => 'Fuera de jornada';

  @override
  String get previousMonth => 'Mes anterior';

  @override
  String get nextMonth => 'Mes siguiente';

  @override
  String get refresh => 'Actualizar';

  @override
  String get retry => 'Reintentar';

  @override
  String get totalWorked => 'Trabajado';

  @override
  String get totalExpected => 'Previsto';

  @override
  String get totalBalance => 'Saldo';

  @override
  String get totalOvertime => 'Horas extra';

  @override
  String get totalAbsences => 'Ausencias';

  @override
  String get noPunchesDay => 'Sin marcaciones';

  @override
  String get timesheetEmpty => 'Aún no hay días en este mes.';

  @override
  String unassignedPunches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count marcaciones aún en procesamiento',
      one: '1 marcación aún en procesamiento',
    );
    return '$_temp0';
  }

  @override
  String get flagAbsence => 'Ausencia';

  @override
  String get flagMissingPunch => 'Marcación faltante';

  @override
  String get flagLate => 'Retraso';

  @override
  String get flagEarlyLeave => 'Salida anticipada';

  @override
  String get flagShortBreak => 'Pausa corta';

  @override
  String get flagRestViolation => 'Descanso entre jornadas';

  @override
  String get flagOvertimeLimit => 'Horas extra sobre el límite';

  @override
  String get flagWorkedDayOff => 'Trabajo en día libre';

  @override
  String get flagFlaggedPunch => 'Marcación señalada';

  @override
  String get flagNoSchedule => 'Sin jornada';

  @override
  String get installApp => 'Instalar app';

  @override
  String get installIosSteps =>
      'En Safari, toca Compartir y luego \"Agregar a pantalla de inicio\".';

  @override
  String get navRequests => 'Solicitudes';

  @override
  String get back => 'Volver';

  @override
  String get requestNew => 'Nueva solicitud';

  @override
  String get requestMissingPunch => 'Olvidé fichar';

  @override
  String get requestPunchContest => 'Impugnar fichaje';

  @override
  String get requestAbsence => 'Ausencia';

  @override
  String get absenceMedicalCertificate => 'Certificado médico';

  @override
  String get absenceJustified => 'Falta justificada';

  @override
  String get absenceDayOff => 'Día libre';

  @override
  String get absenceLeave => 'Licencia';

  @override
  String get requestPending => 'Pendiente';

  @override
  String get requestApproved => 'Aprobada';

  @override
  String get requestRejected => 'Rechazada';

  @override
  String get requestCancelled => 'Cancelada';

  @override
  String get requestEmpty =>
      'Aún no tiene solicitudes. Use “Nueva solicitud” si olvidó fichar, necesita impugnar un fichaje o justificar una ausencia.';

  @override
  String get requestSent => 'Solicitud enviada. La respuesta aparecerá aquí.';

  @override
  String get requestCancelTitle => '¿Cancelar la solicitud?';

  @override
  String get requestCancelText => 'La solicitud sale de la cola de su gestor.';

  @override
  String get requestCancelAction => 'Cancelar solicitud';

  @override
  String get requestDate => 'Fecha';

  @override
  String get requestTime => 'Hora';

  @override
  String get requestMark => 'Fichaje';

  @override
  String get requestChoosePunch => 'Elija el fichaje a impugnar:';

  @override
  String get requestNoPunches => 'No hay fichajes recientes.';

  @override
  String get requestAbsenceType => 'Tipo de ausencia';

  @override
  String get requestStartDate => 'Primer día';

  @override
  String get requestEndDate => 'Último día';

  @override
  String get requestAttachCertificate => 'Adjuntar certificado (foto o PDF)';

  @override
  String get requestCertificateHint =>
      'PNG, JPEG, WEBP o PDF hasta 10 MB. Solo RR. HH. y su gestor lo ven.';

  @override
  String get requestReason => 'Motivo';

  @override
  String get requestSend => 'Enviar solicitud';

  @override
  String get requestReasonRequired => 'Indique el motivo.';

  @override
  String get requestTimeRequired => 'Elija la hora del fichaje.';

  @override
  String get requestPunchRequired => 'Elija el fichaje a impugnar.';

  @override
  String get requestEndBeforeStart => 'El último día es anterior al primero.';

  @override
  String get requestFileInvalid =>
      'Envíe una foto (PNG, JPEG, WEBP) o un PDF de hasta 10 MB.';

  @override
  String get requestDuplicate => 'Ya existe una solicitud pendiente para esto.';

  @override
  String get requestPeriodClosed =>
      'Esa fecha es anterior al período abierto. Hable con RR. HH.';

  @override
  String get requestOverlap => 'Esos días ya tienen una ausencia.';

  @override
  String get requestAlreadyTreated => 'Ese fichaje ya fue descartado.';

  @override
  String get requestFutureTime => 'La hora no puede estar en el futuro.';

  @override
  String get requestAlreadyDecided => 'Esa solicitud ya fue respondida.';

  @override
  String get requestAttachmentUnavailable =>
      'No es posible enviar certificados ahora. Envíe la solicitud sin él y entréguelo a RR. HH.';

  @override
  String requestAnswer(String note) {
    return 'Respuesta: $note';
  }

  @override
  String confirmPunchTitle(String punch) {
    return '¿Confirmar $punch?';
  }

  @override
  String get confirmPunch => 'Confirmar';

  @override
  String get retakePhoto => 'Tomar otra';

  @override
  String get takePhoto => 'Tomar foto';

  @override
  String get punchPhotoNote =>
      'Tu empresa pide una foto en cada registro. Se guarda 90 días y solo RR. HH. la ve.';

  @override
  String get punchPhotoMissing =>
      'Sin foto: el registro se guarda y se señala para RR. HH.';

  @override
  String get punchPhotoFailed => 'Registro guardado, pero la foto no se envió.';

  @override
  String get punchPhotoOffline =>
      'Sin conexión: el registro se guardó y la foto se enviará cuando vuelva la conexión.';

  @override
  String get punchPhotoSaved => 'Registro guardado con foto.';

  @override
  String get withPhoto => 'Con foto';

  @override
  String get navDocuments => 'Documentos';

  @override
  String get docsTabDocuments => 'Documentos';

  @override
  String get docsTabPayslips => 'Nóminas';

  @override
  String get docsTabNotices => 'Avisos';

  @override
  String get docsTabVacation => 'Vacaciones';

  @override
  String get docKindDocument => 'Documento';

  @override
  String get docKindWarning => 'Amonestación';

  @override
  String get docKindPayslip => 'Nómina';

  @override
  String get docKindEmployee => 'Enviado por ti';

  @override
  String get docStatePending => 'Acuse pendiente';

  @override
  String docStateAcknowledged(String date) {
    return 'Recibido el $date';
  }

  @override
  String get docStateSent => 'Nuevo';

  @override
  String get docStateViewed => 'Visto';

  @override
  String get docStateReceived => 'Enviado a RR. HH.';

  @override
  String get docStateReviewed => 'Revisado por RR. HH.';

  @override
  String get docOpen => 'Abrir';

  @override
  String get docAcknowledge => 'Acusar recibo';

  @override
  String get docAckTitle => 'Confirmar acuse de recibo';

  @override
  String get docAckStatement =>
      'Declaro que leí este documento y tomo conocimiento de su contenido.';

  @override
  String get docAckDone => 'Acuse de recibo registrado.';

  @override
  String get docOpenFirst => 'Abre el documento antes de acusar recibo.';

  @override
  String get docsEmpty => 'Todavía no hay documentos.';

  @override
  String get payslipsEmpty => 'Todavía no hay nóminas.';

  @override
  String get docSend => 'Enviar documento a RR. HH.';

  @override
  String get docSendTitle => '¿Qué documento es?';

  @override
  String get docSendTitleHint => 'Ej.: comprobante de domicilio';

  @override
  String get docSendNote => 'Observación (opcional)';

  @override
  String get docPickFile => 'Elegir archivo (PDF o imagen hasta 10 MB)';

  @override
  String get docSent => 'Documento enviado a RR. HH.';

  @override
  String get docFileInvalid => 'Envía un PDF o una imagen de hasta 10 MB.';

  @override
  String get docStorageUnavailable =>
      'Los archivos no están disponibles ahora. Habla con RR. HH.';

  @override
  String get docError => 'No se pudo completar. Inténtalo de nuevo.';

  @override
  String get docOpenFailed => 'No se pudo abrir el archivo.';

  @override
  String docCompetence(String month) {
    return 'Período $month';
  }

  @override
  String get noticesEmpty => 'No hay avisos por ahora.';

  @override
  String get noticeNew => 'Nuevo';

  @override
  String get noticeRead => 'Leído';

  @override
  String get noticeAckRequired => 'Este aviso pide tu acuse de recibo.';

  @override
  String get vacationAvailable => 'Días disponibles';

  @override
  String get vacationPendingDays => 'En solicitudes';

  @override
  String get vacationAccruing => 'Proporcionales del período actual';

  @override
  String vacationDeadline(String date) {
    return 'Plazo para disfrutar: $date';
  }

  @override
  String get vacationNoHireDate =>
      'Tu fecha de ingreso no está registrada. Habla con RR. HH.';

  @override
  String get vacationPeriods => 'Períodos de adquisición';

  @override
  String vacationPeriodRange(String start, String end) {
    return '$start a $end';
  }

  @override
  String vacationPeriodUsage(int taken, int entitled) {
    return '$taken de $entitled días usados';
  }

  @override
  String get vacationAccruingStatus => 'En adquisición';

  @override
  String get vacationAvailableStatus => 'Disponible';

  @override
  String get vacationUsedStatus => 'Disfrutado';

  @override
  String get vacationOverdueStatus => 'Vencido';

  @override
  String get vacationRequest => 'Solicitar vacaciones';

  @override
  String get vacationPickDates => 'Elegir las fechas';

  @override
  String vacationDays(int days) {
    return '$days días';
  }

  @override
  String get vacationReason => 'Observación para RR. HH.';

  @override
  String get vacationSent =>
      'Solicitud de vacaciones enviada. Síguela en Solicitudes.';

  @override
  String get vacationExceeds =>
      'Los días elegidos superan tu saldo disponible.';

  @override
  String get vacationNothing =>
      'Todavía no tienes días de vacaciones para solicitar.';

  @override
  String get absenceVacation => 'Vacaciones';

  @override
  String get notificationsTitle => 'Avisos';

  @override
  String get notificationsReadAll => 'Marcar todos como leídos';

  @override
  String get notificationsEmpty => 'Aún no hay avisos.';

  @override
  String get notificationsError => 'No se pudieron cargar los avisos.';

  @override
  String get notificationApproved => 'Solicitud aprobada';

  @override
  String get notificationRejected => 'Solicitud rechazada';

  @override
  String get notificationMessage => 'Nuevo mensaje en una solicitud';

  @override
  String get notificationNotice => 'Aviso de la empresa';

  @override
  String get pushTitle => 'Notificaciones en este dispositivo';

  @override
  String get pushText =>
      'Reciba respuestas y recordatorios incluso con Pulse cerrado.';

  @override
  String get pushDenied =>
      'Las notificaciones están bloqueadas en el navegador. Permítalas en la configuración del sitio.';

  @override
  String get pushUnavailable =>
      'No se pudieron activar las notificaciones ahora.';

  @override
  String get pushUnsupported =>
      'Este navegador no recibe notificaciones. En iPhone, agregue Pulse a la pantalla de inicio.';

  @override
  String get remindersTitle => 'Recordatorios de marcación';

  @override
  String get remindersText =>
      'Un aviso cuando pase la hora de entrada o de salida sin marcación.';

  @override
  String get remindersOff =>
      'Su empresa no activó los recordatorios de marcación.';

  @override
  String requestConversation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensajes',
      one: '1 mensaje',
      zero: 'Conversación',
    );
    return '$_temp0';
  }

  @override
  String get conversationEmpty => 'Escriba a su gestor sobre esta solicitud.';

  @override
  String get conversationEmptyClosed => 'Sin mensajes.';

  @override
  String get conversationError => 'No se pudo enviar o cargar la conversación.';

  @override
  String get conversationHint => 'Mensaje';

  @override
  String get conversationSend => 'Enviar';

  @override
  String get conversationClosed =>
      'La conversación está disponible solo mientras la solicitud está pendiente.';

  @override
  String get conversationYou => 'Usted';

  @override
  String get conversationManager => 'Gestor';

  @override
  String get permissionsTitle => 'Permisos de Pulse';

  @override
  String get permissionsIntro =>
      'Para registrar la jornada con seguridad, Pulse necesita la ubicación, la cámara y las notificaciones. Las autorizas una sola vez y el navegador o el dispositivo guarda la elección.';

  @override
  String get permissionLocation => 'Ubicación (GPS)';

  @override
  String get permissionLocationHelp =>
      'Se registra solo en el momento de cada fichaje.';

  @override
  String get permissionCamera => 'Cámara';

  @override
  String get permissionCameraHelp =>
      'Foto en vivo para confirmar cada fichaje.';

  @override
  String get permissionNotifications => 'Notificaciones';

  @override
  String get permissionNotificationsHelp =>
      'Solicitudes, documentos, avisos y recordatorios.';

  @override
  String get permissionGranted => 'Permitido';

  @override
  String get permissionPending => 'Aún no permitido';

  @override
  String get permissionDenied => 'Bloqueado';

  @override
  String get permissionUnavailable => 'Apagado o no disponible';

  @override
  String get permissionUnsupported => 'No disponible en este navegador';

  @override
  String get permissionsAllow => 'Permitir todo';

  @override
  String get permissionsRecheck => 'Verificar de nuevo';

  @override
  String get permissionsAlwaysHint =>
      'Cuando el navegador pregunte, elige Permitir (no \"solo esta vez\") para que no te pregunte de nuevo.';

  @override
  String get permissionsDeniedHelp =>
      'Un permiso está bloqueado. Abre la configuración del sitio (el candado junto a la dirección) o del dispositivo, cámbialo a Permitir y toca Verificar de nuevo.';

  @override
  String get permissionsUnavailableHelp =>
      'Activa la ubicación (GPS) del dispositivo y comprueba que haya una cámara disponible.';

  @override
  String get permissionsLost =>
      'Se desactivó un permiso de Pulse. Vuelve a permitirlo para fichar.';

  @override
  String get punchPhotoRequired =>
      'Tu empresa exige la foto para confirmar el fichaje.';

  @override
  String get cameraUnavailable =>
      'No se pudo abrir la cámara. Revisa el permiso de la cámara e inténtalo de nuevo.';

  @override
  String get capturePhoto => 'Capturar';

  @override
  String get kioskUseDevice => 'Usar este dispositivo como reloj de la empresa';

  @override
  String get kioskActivationTitle => 'Activar reloj de fichaje';

  @override
  String get kioskActivationHelp =>
      'En la App, RR. HH. crea el reloj en RR. HH. › Relojes y genera un código de activación válido por 15 minutos. Escribe el código y define un PIN de administrador, necesario para salir del modo reloj en este dispositivo.';

  @override
  String get kioskActivationCode => 'Código de activación';

  @override
  String get kioskAdminPin => 'PIN de administrador (4 a 8 dígitos)';

  @override
  String get kioskAdminPinConfirm => 'Confirma el PIN de administrador';

  @override
  String get kioskAdminPinInvalid => 'Usa de 4 a 8 dígitos.';

  @override
  String get kioskPinMismatch => 'Los PIN no coinciden.';

  @override
  String get kioskActivate => 'Activar';

  @override
  String get kioskCodeInvalid =>
      'Código de activación inválido o vencido. Pide uno nuevo a RR. HH.';

  @override
  String get kioskKeyRejected =>
      'No se pudo activar este dispositivo. Inténtalo de nuevo.';

  @override
  String get kioskClockSkew =>
      'El reloj de este dispositivo difiere mucho de la hora oficial. Ajusta la fecha y la hora e inténtalo de nuevo.';

  @override
  String get kioskPinFixHint =>
      'Para usarlo como reloj, fija la app en la pantalla (Android: fijar app; iPhone/iPad: Acceso guiado).';

  @override
  String get kioskEnterCode => 'Escribe tu código de acceso';

  @override
  String get kioskEnterPin => 'Escribe tu PIN';

  @override
  String get kioskContinue => 'Continuar';

  @override
  String kioskHello(String name) {
    return 'Hola, $name';
  }

  @override
  String get kioskSuggested => 'Fichaje sugerido';

  @override
  String get kioskOtherMarks => 'Otro fichaje';

  @override
  String get kioskConfirmPunch => 'Confirmar y registrar';

  @override
  String get kioskPhotoNote =>
      'Se toma una foto en vivo para confirmar el fichaje.';

  @override
  String get kioskInvalidPin => 'Código o PIN inválido.';

  @override
  String get kioskPinLocked =>
      'PIN bloqueado por intentos fallidos. Inténtalo más tarde o habla con RR. HH.';

  @override
  String get kioskPinNotSet =>
      'Aún no tienes PIN del reloj. Defínelo en Pulse (PIN del reloj) o pídelo a RR. HH.';

  @override
  String get kioskOffline =>
      'Sin conexión: el reloj necesita internet para registrar.';

  @override
  String get kioskPhotoRequired =>
      'La foto es obligatoria para registrar el fichaje.';

  @override
  String get kioskPunchSaved => 'Fichaje registrado';

  @override
  String get kioskPhotoFailed =>
      'Fichaje registrado, pero la foto no se pudo enviar.';

  @override
  String get kioskDone => 'Listo';

  @override
  String kioskReturning(int seconds) {
    return 'Volviendo al inicio en $seconds s';
  }

  @override
  String get kioskRevoked =>
      'RR. HH. desactivó este reloj. Pide un nuevo código de activación.';

  @override
  String get kioskExit => 'Salir del modo reloj';

  @override
  String get kioskExitHelp =>
      'Escribe el PIN de administrador de este dispositivo. Pide a RR. HH. que revoque el reloj en la App si el dispositivo ya no se usa.';

  @override
  String get kioskExitWrong => 'PIN de administrador inválido.';

  @override
  String get kioskFullscreen => 'Pantalla completa';

  @override
  String get kioskMarkTime => 'Hora';

  @override
  String get kioskPinMenu => 'PIN del reloj';

  @override
  String get kioskPinHelp =>
      'Usa este PIN con tu código de acceso en los relojes de la empresa: 4 a 6 dígitos, sin secuencia ni número repetido.';

  @override
  String get kioskPinCurrentPassword => 'Contraseña actual';

  @override
  String get kioskPinNew => 'Nuevo PIN';

  @override
  String get kioskPinConfirm => 'Confirma el PIN';

  @override
  String get kioskPinInvalid =>
      'Usa de 4 a 6 dígitos, sin secuencia (1234) ni número repetido (1111).';

  @override
  String get kioskPinSaved => 'PIN del reloj guardado.';

  @override
  String get kioskPinSave => 'Guardar PIN';

  @override
  String get receiptPrint => 'Imprimir';

  @override
  String get receiptEmail => 'Enviar por correo';

  @override
  String receiptEmailSent(String recipient) {
    return 'Comprobante enviado a $recipient.';
  }

  @override
  String get receiptNoEmail =>
      'No hay correo en tu registro. Pide a RR. HH. que lo agregue.';

  @override
  String get receiptEmailDisabled =>
      'Este reloj no envía comprobantes por correo.';

  @override
  String get receiptEmailLimit =>
      'Este comprobante ya se envió varias veces. Inténtalo más tarde.';

  @override
  String get receiptFailed =>
      'No se pudo preparar el comprobante. Inténtalo de nuevo.';

  @override
  String get kioskOfflineTitle => 'Sin conexión';

  @override
  String get kioskOfflineNote =>
      'Tu fichaje queda guardado en este reloj y se envía cuando vuelva la conexión. El PIN se verifica en el envío; si es incorrecto, RR. HH. verá el fichaje como rechazado.';

  @override
  String get kioskChooseMark => 'Elige el fichaje';

  @override
  String get kioskOfflineSaved => 'Fichaje guardado en este reloj';

  @override
  String get kioskOfflineSavedNote =>
      'Se enviará en cuanto vuelva la conexión.';

  @override
  String get kioskQueueFull =>
      'Este reloj ya guardó el máximo de fichajes sin conexión. Restablece internet.';

  @override
  String kioskOfflinePending(int count) {
    return '$count fichajes esperando envío';
  }

  @override
  String kioskExitPending(int count) {
    return '$count fichajes aún no enviados se perderán al salir.';
  }
}
