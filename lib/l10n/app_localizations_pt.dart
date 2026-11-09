// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get language => 'Idioma';

  @override
  String get system => 'Idioma do sistema';

  @override
  String get eyebrow => 'Acesso do colaborador';

  @override
  String get title => 'Acesse seu ponto';

  @override
  String get subtitle => 'Use o código de acesso fornecido pela sua empresa.';

  @override
  String get heroTitle => 'Sua jornada.\nConectada.';

  @override
  String get heroText =>
      'Registre seus horários e acompanhe sua jornada em um só lugar.';

  @override
  String get supportLabel => 'Precisa de acesso? Fale com sua empresa';

  @override
  String get privacy => 'Privacidade';

  @override
  String get terms => 'Termos de uso';

  @override
  String get employeeCode => 'Código de acesso do colaborador';

  @override
  String get password => 'Senha';

  @override
  String get signIn => 'Entrar';

  @override
  String get signOut => 'Sair';

  @override
  String get showPassword => 'Mostrar senha';

  @override
  String get hidePassword => 'Ocultar senha';

  @override
  String get forgotPassword => 'Esqueceu sua senha?';

  @override
  String get forgotPasswordTitle => 'Recuperar senha';

  @override
  String get forgotPasswordHelp =>
      'A senha do Pulse é gerenciada pela sua empresa. Peça ao responsável pelo seu acesso uma nova senha temporária; no próximo acesso você define a sua.';

  @override
  String get close => 'Fechar';

  @override
  String get required => 'Este campo é obrigatório.';

  @override
  String get invalidCredentials => 'Código de acesso ou senha inválidos.';

  @override
  String get networkError => 'Não foi possível conectar. Tente novamente.';

  @override
  String get requestError =>
      'Não foi possível concluir. Tente novamente ou fale com sua empresa.';

  @override
  String get rateLimited =>
      'Muitas tentativas. Aguarde antes de tentar novamente.';

  @override
  String get firstAccess => 'Crie sua nova senha';

  @override
  String get firstAccessHelp =>
      'Substitua sua senha temporária antes de registrar o ponto.';

  @override
  String get newPassword => 'Nova senha';

  @override
  String get confirmPassword => 'Confirme a senha';

  @override
  String get passwordLength => 'Use pelo menos 10 caracteres.';

  @override
  String get passwordMismatch => 'As senhas não coincidem.';

  @override
  String get changePassword => 'Salvar nova senha';

  @override
  String get signedIn => 'Acesso realizado.';

  @override
  String get passwordChanged => 'Senha alterada com sucesso.';

  @override
  String get signedOut => 'Você saiu da conta.';

  @override
  String get employee => 'Colaborador';

  @override
  String get clockIn => 'Entrada';

  @override
  String get breakStart => 'Início do intervalo';

  @override
  String get breakEnd => 'Fim do intervalo';

  @override
  String get clockOut => 'Saída';

  @override
  String get recentPunches => 'Registros recentes';

  @override
  String get punchSaved => 'Ponto registrado.';

  @override
  String get punchSynced => 'Ponto já sincronizado.';

  @override
  String get importantUpdate => 'Atualização importante';

  @override
  String get newVersion => 'Nova versão disponível';

  @override
  String get updateNow => 'Atualizar agora';

  @override
  String get later => 'Depois';

  @override
  String get updateHelp =>
      'Uma nova versão está pronta. Você entrará novamente após atualizar.';

  @override
  String get versionUnsupported =>
      'Esta versão do app não é mais aceita. Atualize o app pela loja ou com o administrador para continuar.';

  @override
  String get officialTime => 'Horário oficial';

  @override
  String get nextPunch => 'Próxima marcação';

  @override
  String get otherPunch => 'Outra marcação';

  @override
  String get onlineStatus => 'Conectado';

  @override
  String get offlineStatus => 'Sem conexão';

  @override
  String pendingPunches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count marcações aguardando envio',
      one: '1 marcação aguardando envio',
    );
    return '$_temp0';
  }

  @override
  String get punchQueued =>
      'Sem conexão: a marcação foi guardada e será enviada automaticamente.';

  @override
  String get receipt => 'Último comprovante';

  @override
  String nsrLabel(String nsr) {
    return 'NSR $nsr';
  }

  @override
  String get sessionEnded => 'Sua sessão terminou. Entre novamente.';

  @override
  String get accountLocked =>
      'Conta bloqueada temporariamente. Tente novamente em alguns minutos.';

  @override
  String get temporaryPasswordExpired =>
      'Sua senha temporária expirou. Peça uma nova à sua empresa.';

  @override
  String get moduleUnavailable =>
      'O ponto não está disponível para sua empresa. Fale com o RH.';

  @override
  String get accessDenied => 'Seu acesso não está ativo. Fale com o RH.';

  @override
  String get invalidPassword => 'Senha atual inválida.';

  @override
  String get passwordUnchanged =>
      'A nova senha precisa ser diferente da atual.';

  @override
  String get pendingSignOutTitle => 'Marcações aguardando envio';

  @override
  String get pendingSignOutHelp =>
      'Algumas marcações ainda não foram enviadas. Elas ficam protegidas neste aparelho e são enviadas automaticamente assim que houver conexão (ou quando você entrar novamente aqui).';

  @override
  String get offlineEntry =>
      'Modo offline: suas marcações ficam protegidas neste aparelho e são enviadas automaticamente quando a conexão voltar.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get signOutAnyway => 'Sair';

  @override
  String get noPunchesYet => 'Nenhuma marcação ainda.';

  @override
  String get loading => 'Carregando…';

  @override
  String get locationNote =>
      'Sua localização é registrada somente no momento de cada marcação, quando permitido.';

  @override
  String get sentLater => 'Enviada depois';

  @override
  String get pendingSend => 'Aguardando envio';

  @override
  String get navHome => 'Início';

  @override
  String get navTimesheet => 'Espelho';

  @override
  String get today => 'Hoje';

  @override
  String get workDay => 'Dia de trabalho';

  @override
  String get dayOff => 'Folga';

  @override
  String get holiday => 'Feriado';

  @override
  String holidayNamed(String name) {
    return 'Feriado: $name';
  }

  @override
  String get noSchedule => 'Sem jornada definida';

  @override
  String get workedToday => 'Trabalhado hoje';

  @override
  String get statusWorking => 'Trabalhando';

  @override
  String get statusOnBreak => 'Em intervalo';

  @override
  String get statusOffDuty => 'Fora do expediente';

  @override
  String get previousMonth => 'Mês anterior';

  @override
  String get nextMonth => 'Próximo mês';

  @override
  String get refresh => 'Atualizar';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get totalWorked => 'Trabalhado';

  @override
  String get totalExpected => 'Previsto';

  @override
  String get totalBalance => 'Saldo';

  @override
  String get totalOvertime => 'Horas extras';

  @override
  String get totalAbsences => 'Faltas';

  @override
  String get noPunchesDay => 'Sem marcações';

  @override
  String get timesheetEmpty => 'Nenhum dia neste mês ainda.';

  @override
  String unassignedPunches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count marcações ainda em processamento',
      one: '1 marcação ainda em processamento',
    );
    return '$_temp0';
  }

  @override
  String get flagAbsence => 'Falta';

  @override
  String get flagMissingPunch => 'Marcação faltando';

  @override
  String get flagLate => 'Atraso';

  @override
  String get flagEarlyLeave => 'Saída antecipada';

  @override
  String get flagShortBreak => 'Intervalo curto';

  @override
  String get flagRestViolation => 'Descanso entre jornadas';

  @override
  String get flagOvertimeLimit => 'Hora extra acima do limite';

  @override
  String get flagWorkedDayOff => 'Trabalho em folga';

  @override
  String get flagFlaggedPunch => 'Batida sinalizada';

  @override
  String get flagNoSchedule => 'Sem jornada';

  @override
  String get installApp => 'Instalar app';

  @override
  String get installIosSteps =>
      'No Safari, toque em Compartilhar e depois em \"Adicionar à Tela de Início\".';

  @override
  String get navRequests => 'Solicitações';

  @override
  String get back => 'Voltar';

  @override
  String get requestNew => 'Nova solicitação';

  @override
  String get requestMissingPunch => 'Esqueci de marcar';

  @override
  String get requestPunchContest => 'Contestar marcação';

  @override
  String get requestAbsence => 'Ausência';

  @override
  String get absenceMedicalCertificate => 'Atestado médico';

  @override
  String get absenceJustified => 'Falta justificada';

  @override
  String get absenceDayOff => 'Folga';

  @override
  String get absenceLeave => 'Licença';

  @override
  String get requestPending => 'Pendente';

  @override
  String get requestApproved => 'Aprovada';

  @override
  String get requestRejected => 'Recusada';

  @override
  String get requestCancelled => 'Cancelada';

  @override
  String get requestEmpty =>
      'Você ainda não tem solicitações. Use “Nova solicitação” se esqueceu de marcar, precisa contestar uma marcação ou justificar uma ausência.';

  @override
  String get requestSent => 'Solicitação enviada. A resposta aparece aqui.';

  @override
  String get requestCancelTitle => 'Cancelar a solicitação?';

  @override
  String get requestCancelText => 'A solicitação sai da fila do seu gestor.';

  @override
  String get requestCancelAction => 'Cancelar solicitação';

  @override
  String get requestDate => 'Data';

  @override
  String get requestTime => 'Horário';

  @override
  String get requestMark => 'Marcação';

  @override
  String get requestChoosePunch => 'Escolha a marcação a contestar:';

  @override
  String get requestNoPunches => 'Nenhuma marcação recente.';

  @override
  String get requestAbsenceType => 'Tipo de ausência';

  @override
  String get requestStartDate => 'Primeiro dia';

  @override
  String get requestEndDate => 'Último dia';

  @override
  String get requestAttachCertificate => 'Anexar atestado (foto ou PDF)';

  @override
  String get requestCertificateHint =>
      'PNG, JPEG, WEBP ou PDF até 10 MB. Só o RH e seu gestor veem.';

  @override
  String get requestReason => 'Motivo';

  @override
  String get requestSend => 'Enviar solicitação';

  @override
  String get requestReasonRequired => 'Informe o motivo.';

  @override
  String get requestTimeRequired => 'Escolha o horário da marcação.';

  @override
  String get requestPunchRequired => 'Escolha a marcação a contestar.';

  @override
  String get requestEndBeforeStart => 'O último dia é anterior ao primeiro.';

  @override
  String get requestFileInvalid =>
      'Envie uma foto (PNG, JPEG, WEBP) ou um PDF de até 10 MB.';

  @override
  String get requestDuplicate =>
      'Já existe uma solicitação pendente para isso.';

  @override
  String get requestPeriodClosed =>
      'Essa data é anterior ao período aberto. Fale com o RH.';

  @override
  String get requestOverlap => 'Esses dias já têm uma ausência.';

  @override
  String get requestAlreadyTreated => 'Essa marcação já foi desconsiderada.';

  @override
  String get requestFutureTime => 'O horário não pode estar no futuro.';

  @override
  String get requestAlreadyDecided => 'Essa solicitação já foi respondida.';

  @override
  String get requestAttachmentUnavailable =>
      'Não é possível enviar atestados agora. Envie a solicitação sem ele e entregue ao RH.';

  @override
  String requestAnswer(String note) {
    return 'Resposta: $note';
  }

  @override
  String confirmPunchTitle(String punch) {
    return 'Confirmar $punch?';
  }

  @override
  String get confirmPunch => 'Confirmar';

  @override
  String get retakePhoto => 'Tirar outra';

  @override
  String get takePhoto => 'Tirar foto';

  @override
  String get punchPhotoNote =>
      'Sua empresa pede uma foto em cada marcação. Ela fica guardada por 90 dias e só o RH vê.';

  @override
  String get punchPhotoMissing =>
      'Sem foto: a marcação é registrada e sinalizada para o RH.';

  @override
  String get punchPhotoFailed =>
      'Ponto registrado, mas a foto não foi enviada.';

  @override
  String get punchPhotoOffline =>
      'Sem conexão: a marcação foi guardada; a foto só é enviada com conexão.';

  @override
  String get punchPhotoSaved => 'Ponto registrado com foto.';

  @override
  String get withPhoto => 'Com foto';

  @override
  String get navDocuments => 'Documentos';

  @override
  String get docsTabDocuments => 'Documentos';

  @override
  String get docsTabPayslips => 'Holerites';

  @override
  String get docsTabNotices => 'Avisos';

  @override
  String get docsTabVacation => 'Férias';

  @override
  String get docKindDocument => 'Documento';

  @override
  String get docKindWarning => 'Advertência';

  @override
  String get docKindPayslip => 'Holerite';

  @override
  String get docKindEmployee => 'Enviado por você';

  @override
  String get docStatePending => 'Ciência pendente';

  @override
  String docStateAcknowledged(String date) {
    return 'Ciente em $date';
  }

  @override
  String get docStateSent => 'Novo';

  @override
  String get docStateViewed => 'Visualizado';

  @override
  String get docStateReceived => 'Enviado ao RH';

  @override
  String get docStateReviewed => 'Conferido pelo RH';

  @override
  String get docOpen => 'Abrir';

  @override
  String get docAcknowledge => 'Dar ciência';

  @override
  String get docAckTitle => 'Confirmar ciência';

  @override
  String get docAckStatement =>
      'Declaro que li este documento e tomei ciência do seu conteúdo.';

  @override
  String get docAckDone => 'Ciência registrada.';

  @override
  String get docOpenFirst => 'Abra o documento antes de dar ciência.';

  @override
  String get docsEmpty => 'Nenhum documento por aqui.';

  @override
  String get payslipsEmpty => 'Nenhum holerite por aqui.';

  @override
  String get docSend => 'Enviar documento ao RH';

  @override
  String get docSendTitle => 'Que documento é este?';

  @override
  String get docSendTitleHint => 'Ex.: comprovante de endereço';

  @override
  String get docSendNote => 'Observação (opcional)';

  @override
  String get docPickFile => 'Escolher arquivo (PDF ou imagem até 10 MB)';

  @override
  String get docSent => 'Documento enviado ao RH.';

  @override
  String get docFileInvalid => 'Envie um PDF ou uma imagem de até 10 MB.';

  @override
  String get docStorageUnavailable =>
      'Os arquivos não estão disponíveis agora. Fale com o RH.';

  @override
  String get docError => 'Não foi possível concluir. Tente novamente.';

  @override
  String get docOpenFailed => 'Não foi possível abrir o arquivo.';

  @override
  String docCompetence(String month) {
    return 'Competência $month';
  }

  @override
  String get noticesEmpty => 'Nenhum aviso no momento.';

  @override
  String get noticeNew => 'Novo';

  @override
  String get noticeRead => 'Lido';

  @override
  String get noticeAckRequired => 'Este aviso pede a sua ciência.';

  @override
  String get vacationAvailable => 'Dias disponíveis';

  @override
  String get vacationPendingDays => 'Em solicitação';

  @override
  String get vacationAccruing => 'Proporcionais do período atual';

  @override
  String vacationDeadline(String date) {
    return 'Prazo para tirar: $date';
  }

  @override
  String get vacationNoHireDate =>
      'Sua data de admissão não está cadastrada. Fale com o RH.';

  @override
  String get vacationPeriods => 'Períodos aquisitivos';

  @override
  String vacationPeriodRange(String start, String end) {
    return '$start a $end';
  }

  @override
  String vacationPeriodUsage(int taken, int entitled) {
    return '$taken de $entitled dias usados';
  }

  @override
  String get vacationAccruingStatus => 'Em aquisição';

  @override
  String get vacationAvailableStatus => 'Disponível';

  @override
  String get vacationUsedStatus => 'Usufruído';

  @override
  String get vacationOverdueStatus => 'Vencido';

  @override
  String get vacationRequest => 'Solicitar férias';

  @override
  String get vacationPickDates => 'Escolher as datas';

  @override
  String vacationDays(int days) {
    return '$days dias';
  }

  @override
  String get vacationReason => 'Observação para o RH';

  @override
  String get vacationSent =>
      'Solicitação de férias enviada. Acompanhe em Solicitações.';

  @override
  String get vacationExceeds =>
      'Os dias escolhidos passam do seu saldo disponível.';

  @override
  String get vacationNothing =>
      'Você ainda não tem dias de férias para solicitar.';

  @override
  String get absenceVacation => 'Férias';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get language => 'Idioma';

  @override
  String get system => 'Idioma do sistema';

  @override
  String get eyebrow => 'Acesso do colaborador';

  @override
  String get title => 'Acesse seu ponto';

  @override
  String get subtitle => 'Use o código de acesso fornecido pela sua empresa.';

  @override
  String get heroTitle => 'Sua jornada.\nConectada.';

  @override
  String get heroText =>
      'Registre seus horários e acompanhe sua jornada em um só lugar.';

  @override
  String get supportLabel => 'Precisa de acesso? Fale com sua empresa';

  @override
  String get privacy => 'Privacidade';

  @override
  String get terms => 'Termos de uso';

  @override
  String get employeeCode => 'Código de acesso do colaborador';

  @override
  String get password => 'Senha';

  @override
  String get signIn => 'Entrar';

  @override
  String get signOut => 'Sair';

  @override
  String get showPassword => 'Mostrar senha';

  @override
  String get hidePassword => 'Ocultar senha';

  @override
  String get forgotPassword => 'Esqueceu sua senha?';

  @override
  String get forgotPasswordTitle => 'Recuperar senha';

  @override
  String get forgotPasswordHelp =>
      'A senha do Pulse é gerenciada pela sua empresa. Peça ao responsável pelo seu acesso uma nova senha temporária; no próximo acesso você define a sua.';

  @override
  String get close => 'Fechar';

  @override
  String get required => 'Este campo é obrigatório.';

  @override
  String get invalidCredentials => 'Código de acesso ou senha inválidos.';

  @override
  String get networkError => 'Não foi possível conectar. Tente novamente.';

  @override
  String get requestError =>
      'Não foi possível concluir. Tente novamente ou fale com sua empresa.';

  @override
  String get rateLimited =>
      'Muitas tentativas. Aguarde antes de tentar novamente.';

  @override
  String get firstAccess => 'Crie sua nova senha';

  @override
  String get firstAccessHelp =>
      'Substitua sua senha temporária antes de registrar o ponto.';

  @override
  String get newPassword => 'Nova senha';

  @override
  String get confirmPassword => 'Confirme a senha';

  @override
  String get passwordLength => 'Use pelo menos 10 caracteres.';

  @override
  String get passwordMismatch => 'As senhas não coincidem.';

  @override
  String get changePassword => 'Salvar nova senha';

  @override
  String get signedIn => 'Acesso realizado.';

  @override
  String get passwordChanged => 'Senha alterada com sucesso.';

  @override
  String get signedOut => 'Você saiu da conta.';

  @override
  String get employee => 'Colaborador';

  @override
  String get clockIn => 'Entrada';

  @override
  String get breakStart => 'Início do intervalo';

  @override
  String get breakEnd => 'Fim do intervalo';

  @override
  String get clockOut => 'Saída';

  @override
  String get recentPunches => 'Registros recentes';

  @override
  String get punchSaved => 'Ponto registrado.';

  @override
  String get punchSynced => 'Ponto já sincronizado.';

  @override
  String get importantUpdate => 'Atualização importante';

  @override
  String get newVersion => 'Nova versão disponível';

  @override
  String get updateNow => 'Atualizar agora';

  @override
  String get later => 'Depois';

  @override
  String get updateHelp =>
      'Uma nova versão está pronta. Você entrará novamente após atualizar.';

  @override
  String get versionUnsupported =>
      'Esta versão do app não é mais aceita. Atualize o app pela loja ou com o administrador para continuar.';

  @override
  String get officialTime => 'Horário oficial';

  @override
  String get nextPunch => 'Próxima marcação';

  @override
  String get otherPunch => 'Outra marcação';

  @override
  String get onlineStatus => 'Conectado';

  @override
  String get offlineStatus => 'Sem conexão';

  @override
  String pendingPunches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count marcações aguardando envio',
      one: '1 marcação aguardando envio',
    );
    return '$_temp0';
  }

  @override
  String get punchQueued =>
      'Sem conexão: a marcação foi guardada e será enviada automaticamente.';

  @override
  String get receipt => 'Último comprovante';

  @override
  String nsrLabel(String nsr) {
    return 'NSR $nsr';
  }

  @override
  String get sessionEnded => 'Sua sessão terminou. Entre novamente.';

  @override
  String get accountLocked =>
      'Conta bloqueada temporariamente. Tente novamente em alguns minutos.';

  @override
  String get temporaryPasswordExpired =>
      'Sua senha temporária expirou. Peça uma nova à sua empresa.';

  @override
  String get moduleUnavailable =>
      'O ponto não está disponível para sua empresa. Fale com o RH.';

  @override
  String get accessDenied => 'Seu acesso não está ativo. Fale com o RH.';

  @override
  String get invalidPassword => 'Senha atual inválida.';

  @override
  String get passwordUnchanged =>
      'A nova senha precisa ser diferente da atual.';

  @override
  String get pendingSignOutTitle => 'Marcações aguardando envio';

  @override
  String get pendingSignOutHelp =>
      'Algumas marcações ainda não foram enviadas. Elas ficam protegidas neste aparelho e são enviadas automaticamente assim que houver conexão (ou quando você entrar novamente aqui).';

  @override
  String get offlineEntry =>
      'Modo offline: suas marcações ficam protegidas neste aparelho e são enviadas automaticamente quando a conexão voltar.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get signOutAnyway => 'Sair';

  @override
  String get noPunchesYet => 'Nenhuma marcação ainda.';

  @override
  String get loading => 'Carregando…';

  @override
  String get locationNote =>
      'Sua localização é registrada somente no momento de cada marcação, quando permitido.';

  @override
  String get sentLater => 'Enviada depois';

  @override
  String get pendingSend => 'Aguardando envio';

  @override
  String get navHome => 'Início';

  @override
  String get navTimesheet => 'Espelho';

  @override
  String get today => 'Hoje';

  @override
  String get workDay => 'Dia de trabalho';

  @override
  String get dayOff => 'Folga';

  @override
  String get holiday => 'Feriado';

  @override
  String holidayNamed(String name) {
    return 'Feriado: $name';
  }

  @override
  String get noSchedule => 'Sem jornada definida';

  @override
  String get workedToday => 'Trabalhado hoje';

  @override
  String get statusWorking => 'Trabalhando';

  @override
  String get statusOnBreak => 'Em intervalo';

  @override
  String get statusOffDuty => 'Fora do expediente';

  @override
  String get previousMonth => 'Mês anterior';

  @override
  String get nextMonth => 'Próximo mês';

  @override
  String get refresh => 'Atualizar';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get totalWorked => 'Trabalhado';

  @override
  String get totalExpected => 'Previsto';

  @override
  String get totalBalance => 'Saldo';

  @override
  String get totalOvertime => 'Horas extras';

  @override
  String get totalAbsences => 'Faltas';

  @override
  String get noPunchesDay => 'Sem marcações';

  @override
  String get timesheetEmpty => 'Nenhum dia neste mês ainda.';

  @override
  String unassignedPunches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count marcações ainda em processamento',
      one: '1 marcação ainda em processamento',
    );
    return '$_temp0';
  }

  @override
  String get flagAbsence => 'Falta';

  @override
  String get flagMissingPunch => 'Marcação faltando';

  @override
  String get flagLate => 'Atraso';

  @override
  String get flagEarlyLeave => 'Saída antecipada';

  @override
  String get flagShortBreak => 'Intervalo curto';

  @override
  String get flagRestViolation => 'Descanso entre jornadas';

  @override
  String get flagOvertimeLimit => 'Hora extra acima do limite';

  @override
  String get flagWorkedDayOff => 'Trabalho em folga';

  @override
  String get flagFlaggedPunch => 'Batida sinalizada';

  @override
  String get flagNoSchedule => 'Sem jornada';

  @override
  String get installApp => 'Instalar app';

  @override
  String get installIosSteps =>
      'No Safari, toque em Compartilhar e depois em \"Adicionar à Tela de Início\".';

  @override
  String get navRequests => 'Solicitações';

  @override
  String get back => 'Voltar';

  @override
  String get requestNew => 'Nova solicitação';

  @override
  String get requestMissingPunch => 'Esqueci de marcar';

  @override
  String get requestPunchContest => 'Contestar marcação';

  @override
  String get requestAbsence => 'Ausência';

  @override
  String get absenceMedicalCertificate => 'Atestado médico';

  @override
  String get absenceJustified => 'Falta justificada';

  @override
  String get absenceDayOff => 'Folga';

  @override
  String get absenceLeave => 'Licença';

  @override
  String get requestPending => 'Pendente';

  @override
  String get requestApproved => 'Aprovada';

  @override
  String get requestRejected => 'Recusada';

  @override
  String get requestCancelled => 'Cancelada';

  @override
  String get requestEmpty =>
      'Você ainda não tem solicitações. Use “Nova solicitação” se esqueceu de marcar, precisa contestar uma marcação ou justificar uma ausência.';

  @override
  String get requestSent => 'Solicitação enviada. A resposta aparece aqui.';

  @override
  String get requestCancelTitle => 'Cancelar a solicitação?';

  @override
  String get requestCancelText => 'A solicitação sai da fila do seu gestor.';

  @override
  String get requestCancelAction => 'Cancelar solicitação';

  @override
  String get requestDate => 'Data';

  @override
  String get requestTime => 'Horário';

  @override
  String get requestMark => 'Marcação';

  @override
  String get requestChoosePunch => 'Escolha a marcação a contestar:';

  @override
  String get requestNoPunches => 'Nenhuma marcação recente.';

  @override
  String get requestAbsenceType => 'Tipo de ausência';

  @override
  String get requestStartDate => 'Primeiro dia';

  @override
  String get requestEndDate => 'Último dia';

  @override
  String get requestAttachCertificate => 'Anexar atestado (foto ou PDF)';

  @override
  String get requestCertificateHint =>
      'PNG, JPEG, WEBP ou PDF até 10 MB. Só o RH e seu gestor veem.';

  @override
  String get requestReason => 'Motivo';

  @override
  String get requestSend => 'Enviar solicitação';

  @override
  String get requestReasonRequired => 'Informe o motivo.';

  @override
  String get requestTimeRequired => 'Escolha o horário da marcação.';

  @override
  String get requestPunchRequired => 'Escolha a marcação a contestar.';

  @override
  String get requestEndBeforeStart => 'O último dia é anterior ao primeiro.';

  @override
  String get requestFileInvalid =>
      'Envie uma foto (PNG, JPEG, WEBP) ou um PDF de até 10 MB.';

  @override
  String get requestDuplicate =>
      'Já existe uma solicitação pendente para isso.';

  @override
  String get requestPeriodClosed =>
      'Essa data é anterior ao período aberto. Fale com o RH.';

  @override
  String get requestOverlap => 'Esses dias já têm uma ausência.';

  @override
  String get requestAlreadyTreated => 'Essa marcação já foi desconsiderada.';

  @override
  String get requestFutureTime => 'O horário não pode estar no futuro.';

  @override
  String get requestAlreadyDecided => 'Essa solicitação já foi respondida.';

  @override
  String get requestAttachmentUnavailable =>
      'Não é possível enviar atestados agora. Envie a solicitação sem ele e entregue ao RH.';

  @override
  String requestAnswer(String note) {
    return 'Resposta: $note';
  }

  @override
  String confirmPunchTitle(String punch) {
    return 'Confirmar $punch?';
  }

  @override
  String get confirmPunch => 'Confirmar';

  @override
  String get retakePhoto => 'Tirar outra';

  @override
  String get takePhoto => 'Tirar foto';

  @override
  String get punchPhotoNote =>
      'Sua empresa pede uma foto em cada marcação. Ela fica guardada por 90 dias e só o RH vê.';

  @override
  String get punchPhotoMissing =>
      'Sem foto: a marcação é registrada e sinalizada para o RH.';

  @override
  String get punchPhotoFailed =>
      'Ponto registrado, mas a foto não foi enviada.';

  @override
  String get punchPhotoOffline =>
      'Sem conexão: a marcação foi guardada; a foto só é enviada com conexão.';

  @override
  String get punchPhotoSaved => 'Ponto registrado com foto.';

  @override
  String get withPhoto => 'Com foto';

  @override
  String get navDocuments => 'Documentos';

  @override
  String get docsTabDocuments => 'Documentos';

  @override
  String get docsTabPayslips => 'Holerites';

  @override
  String get docsTabNotices => 'Avisos';

  @override
  String get docsTabVacation => 'Férias';

  @override
  String get docKindDocument => 'Documento';

  @override
  String get docKindWarning => 'Advertência';

  @override
  String get docKindPayslip => 'Holerite';

  @override
  String get docKindEmployee => 'Enviado por você';

  @override
  String get docStatePending => 'Ciência pendente';

  @override
  String docStateAcknowledged(String date) {
    return 'Ciente em $date';
  }

  @override
  String get docStateSent => 'Novo';

  @override
  String get docStateViewed => 'Visualizado';

  @override
  String get docStateReceived => 'Enviado ao RH';

  @override
  String get docStateReviewed => 'Conferido pelo RH';

  @override
  String get docOpen => 'Abrir';

  @override
  String get docAcknowledge => 'Dar ciência';

  @override
  String get docAckTitle => 'Confirmar ciência';

  @override
  String get docAckStatement =>
      'Declaro que li este documento e tomei ciência do seu conteúdo.';

  @override
  String get docAckDone => 'Ciência registrada.';

  @override
  String get docOpenFirst => 'Abra o documento antes de dar ciência.';

  @override
  String get docsEmpty => 'Nenhum documento por aqui.';

  @override
  String get payslipsEmpty => 'Nenhum holerite por aqui.';

  @override
  String get docSend => 'Enviar documento ao RH';

  @override
  String get docSendTitle => 'Que documento é este?';

  @override
  String get docSendTitleHint => 'Ex.: comprovante de endereço';

  @override
  String get docSendNote => 'Observação (opcional)';

  @override
  String get docPickFile => 'Escolher arquivo (PDF ou imagem até 10 MB)';

  @override
  String get docSent => 'Documento enviado ao RH.';

  @override
  String get docFileInvalid => 'Envie um PDF ou uma imagem de até 10 MB.';

  @override
  String get docStorageUnavailable =>
      'Os arquivos não estão disponíveis agora. Fale com o RH.';

  @override
  String get docError => 'Não foi possível concluir. Tente novamente.';

  @override
  String get docOpenFailed => 'Não foi possível abrir o arquivo.';

  @override
  String docCompetence(String month) {
    return 'Competência $month';
  }

  @override
  String get noticesEmpty => 'Nenhum aviso no momento.';

  @override
  String get noticeNew => 'Novo';

  @override
  String get noticeRead => 'Lido';

  @override
  String get noticeAckRequired => 'Este aviso pede a sua ciência.';

  @override
  String get vacationAvailable => 'Dias disponíveis';

  @override
  String get vacationPendingDays => 'Em solicitação';

  @override
  String get vacationAccruing => 'Proporcionais do período atual';

  @override
  String vacationDeadline(String date) {
    return 'Prazo para tirar: $date';
  }

  @override
  String get vacationNoHireDate =>
      'Sua data de admissão não está cadastrada. Fale com o RH.';

  @override
  String get vacationPeriods => 'Períodos aquisitivos';

  @override
  String vacationPeriodRange(String start, String end) {
    return '$start a $end';
  }

  @override
  String vacationPeriodUsage(int taken, int entitled) {
    return '$taken de $entitled dias usados';
  }

  @override
  String get vacationAccruingStatus => 'Em aquisição';

  @override
  String get vacationAvailableStatus => 'Disponível';

  @override
  String get vacationUsedStatus => 'Usufruído';

  @override
  String get vacationOverdueStatus => 'Vencido';

  @override
  String get vacationRequest => 'Solicitar férias';

  @override
  String get vacationPickDates => 'Escolher as datas';

  @override
  String vacationDays(int days) {
    return '$days dias';
  }

  @override
  String get vacationReason => 'Observação para o RH';

  @override
  String get vacationSent =>
      'Solicitação de férias enviada. Acompanhe em Solicitações.';

  @override
  String get vacationExceeds =>
      'Os dias escolhidos passam do seu saldo disponível.';

  @override
  String get vacationNothing =>
      'Você ainda não tem dias de férias para solicitar.';

  @override
  String get absenceVacation => 'Férias';
}
