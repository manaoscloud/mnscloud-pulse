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
}
