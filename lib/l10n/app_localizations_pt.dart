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
      'Algumas marcações ainda não foram enviadas. Elas ficam neste aparelho e serão enviadas quando você entrar novamente aqui.';

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
      'Algumas marcações ainda não foram enviadas. Elas ficam neste aparelho e serão enviadas quando você entrar novamente aqui.';

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
}
