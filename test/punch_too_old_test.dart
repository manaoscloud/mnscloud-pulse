import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mnscloud_pulse/l10n/app_localizations_en.dart';
import 'package:mnscloud_pulse/l10n/app_localizations_es.dart';
import 'package:mnscloud_pulse/l10n/app_localizations_pt.dart';
import 'package:mnscloud_pulse/src/core/ids.dart';
import 'package:mnscloud_pulse/src/core/pulse_api.dart';
import 'package:mnscloud_pulse/src/core/punch_queue.dart';
import 'package:mnscloud_pulse/src/core/server_clock.dart';
import 'package:mnscloud_pulse/src/offline/device_grant.dart';
import 'package:mnscloud_pulse/src/offline/device_lock.dart';
import 'package:mnscloud_pulse/src/offline/p256.dart';
import 'package:mnscloud_pulse/src/offline/punch_sync.dart';
import 'package:mnscloud_pulse/src/offline/secret_vault.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart';

http.Response json(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status);

QueuedPunch mark(String type, int minutesAgo) => QueuedPunch(
  idempotencyKey: uuidV4(),
  type: type,
  occurredAt: DateTime.now().toUtc().subtract(Duration(minutes: minutesAgo)),
);

void main() {
  late MemoryVault vault;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    vault = MemoryVault();
    SecretVault.instance = vault;
    PunchStore.use(PunchStore.memory(sqlite3.openInMemory()));
    resetDeviceLock();
  });

  Future<PunchSync> syncWith(
    http.Response Function(http.Request) answer,
  ) async {
    final api = PulseApi(
      client: MockClient((request) async => answer(request)),
      baseUrl: 'https://pulse.test/api/v1',
    );
    await vault.write(
      'pulse.device.account-1',
      jsonEncode(
        DeviceGrantState(
          deviceUUID: 'device-1',
          privateKey: P256Key.generate().privateBase64,
          counter: 0,
          expiresAt: DateTime.now().toUtc().add(const Duration(days: 3)),
        ).toJson(),
      ),
    );
    final grants = DeviceGrants(api: api, clock: ServerClock(), vault: vault);
    return PunchSync(api: api, grants: grants, source: 'mobile');
  }

  test(
    'a mark refused as too old leaves the queue and leaves a notice',
    () async {
      final sync = await syncWith(
        (_) => json({'code': 'PULSE_PUNCH_TOO_OLD'}, 422),
      );
      final old = mark('clock_in', 10);
      final queue = PunchQueue('account-1');
      await queue.add(old);
      var notified = 0;
      sync.addListener(() => notified++);
      final result = await sync.flush('account-1');
      expect(result.sent, 0);
      expect(await queue.load(), isEmpty);
      final notices = await queue.notices();
      expect(notices, hasLength(1));
      expect(notices.single.code, punchTooOldCode);
      expect(notices.single.occurredAt, old.occurredAt.toUtc());
      expect(notified, 1);
      // A second pass has nothing to send and the notice stays until acknowledged.
      await sync.flush('account-1');
      expect(await queue.notices(), hasLength(1));
      await queue.dismissNotice(old.idempotencyKey);
      expect(await queue.notices(), isEmpty);
    },
  );

  test('only the too old mark is dropped; the next one is sent', () async {
    var calls = 0;
    final sync = await syncWith((_) {
      calls++;
      if (calls == 1) return json({'code': 'PULSE_PUNCH_TOO_OLD'}, 422);
      return json({
        'data': {
          'item': {'Duplicate': 0},
        },
      });
    });
    final queue = PunchQueue('account-1');
    await queue.add(mark('clock_in', 50));
    await queue.add(mark('clock_out', 5));
    final result = await sync.flush('account-1');
    expect(result.sent, 1);
    expect(await queue.load(), isEmpty);
    expect(await queue.notices(), hasLength(1));
  });

  test('other refusals keep the mark and leave no notice', () async {
    final sync = await syncWith(
      (_) => json({'code': 'PULSE_INTERNAL_ERROR'}, 500),
    );
    final queue = PunchQueue('account-1');
    await queue.add(mark('clock_in', 5));
    await sync.flush('account-1');
    expect(await queue.load(), hasLength(1));
    expect(await queue.notices(), isEmpty);
  });

  test('the notice text exists in pt-BR, en and es', () {
    expect(
      AppLocalizationsPt().punchTooOld('12/11 08:30'),
      'Marcação de 12/11 08:30 não enviada: ficou mais de 7 dias sem conexão. Procure o RH.',
    );
    expect(AppLocalizationsEn().punchTooOld('12/11 08:30'), contains('7 days'));
    expect(AppLocalizationsEs().punchTooOld('12/11 08:30'), contains('7 días'));
  });
}
