import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../brand/brand.dart';
import 'access_preferences.dart';

String accessText(BuildContext context, String key, String fallback) {
  final locale = Localizations.localeOf(context);
  final language =
      '${locale.languageCode}-${locale.countryCode ?? (locale.languageCode == 'pt'
              ? 'BR'
              : locale.languageCode == 'es'
              ? 'ES'
              : 'US')}';
  final texts = pulseBrand.value?.login['texts'];
  final value = texts is Map && texts[language] is Map
      ? texts[language][key]
      : null;
  return value is String && value.trim().isNotEmpty ? value.trim() : fallback;
}

class AccessLanguageButton extends StatelessWidget {
  const AccessLanguageButton({super.key});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return PopupMenuButton<String>(
      tooltip: l.language,
      initialValue: accessLocale.value?.toLanguageTag() ?? 'auto',
      onSelected: setAccessLocale,
      itemBuilder: (_) => [
        PopupMenuItem(value: 'auto', child: Text(l.system)),
        const PopupMenuItem(value: 'pt-BR', child: Text('Português (BR)')),
        const PopupMenuItem(value: 'en-US', child: Text('English (US)')),
        const PopupMenuItem(value: 'es-ES', child: Text('Español (ES)')),
      ],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, size: 19),
            const SizedBox(width: 8),
            Text(switch (Localizations.localeOf(context).languageCode) {
              'pt' => 'Português (BR)',
              'es' => 'Español (ES)',
              _ => 'English (US)',
            }),
            const Icon(Icons.expand_more, size: 18),
          ],
        ),
      ),
    );
  }
}

class AccessBrand extends StatelessWidget {
  const AccessBrand({super.key, this.onDark = false});
  final bool onDark;
  @override
  Widget build(BuildContext context) {
    final brand = pulseBrand.value;
    final color = brand?.primaryColor ?? const Color(0xff1264ed);
    final mark = Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'M',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w900,
          color: color.computeLuminance() > .179 ? Colors.black : Colors.white,
        ),
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (brand?.logoUrl != null)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120, maxHeight: 48),
            child: Image.network(
              brand!.logoUrl!,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => mark,
            ),
          )
        else
          mark,
        const SizedBox(width: 14),
        Flexible(
          child: Text(
            brand?.title ?? 'MNSCloud Pulse',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: onDark ? Colors.white : null,
            ),
          ),
        ),
      ],
    );
  }
}

class AccessShell extends StatelessWidget {
  const AccessShell({super.key, required this.child, this.onSignOut});
  final Widget child;
  final VoidCallback? onSignOut;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final brand = pulseBrand.value;
    final color = brand?.primaryColor ?? const Color(0xff1264ed);
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final split =
                constraints.maxWidth >= 900 &&
                brand?.login['layout'] != 'compact';
            final main = SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.all(split ? 40 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 16,
                        runSpacing: 12,
                        children: [
                          if (!split)
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 270),
                              child: AccessBrand(),
                            ),
                          const AccessLanguageButton(),
                          if (onSignOut != null)
                            IconButton(
                              tooltip: l.signOut,
                              onPressed: onSignOut,
                              icon: const Icon(Icons.logout),
                            ),
                        ],
                      ),
                      SizedBox(height: split ? 76 : 48),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 460),
                          child: child,
                        ),
                      ),
                      const SizedBox(height: 36),
                      _footer(context, l),
                    ],
                  ),
                ),
              ),
            );
            if (!split) return main;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xff071a37),
                          Color.lerp(const Color(0xff06142b), color, .35)!,
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        if (Brand.safeLink(brand?.login['heroImageUrl'])
                            case final String image)
                          Positioned.fill(
                            child: Opacity(
                              opacity: .16,
                              child: Image.network(
                                image,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    const SizedBox.shrink(),
                              ),
                            ),
                          ),
                        const Positioned.fill(
                          child: CustomPaint(painter: _Orbits()),
                        ),
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(56),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AccessBrand(onDark: true),
                              const SizedBox(height: 110),
                              Text(
                                accessText(
                                  context,
                                  'eyebrow',
                                  l.eyebrow,
                                ).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                accessText(context, 'heroTitle', l.heroTitle),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 52,
                                  fontWeight: FontWeight.w800,
                                  height: 1.12,
                                  letterSpacing: -2,
                                ),
                              ),
                              const SizedBox(height: 28),
                              Text(
                                accessText(context, 'heroText', l.heroText),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(child: main),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _footer(BuildContext context, AppLocalizations l) {
    final login = pulseBrand.value?.login ?? {};
    Widget? link(String key, String label) {
      final url = Brand.safeLink(login[key]);
      return url == null
          ? null
          : TextButton(
              onPressed: () async {
                try {
                  if (!await launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      ) &&
                      context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(l.requestError)));
                  }
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(l.requestError)));
                  }
                }
              },
              child: Text(label, textAlign: TextAlign.center),
            );
    }

    return Column(
      children: [
        if (link(
              'supportUrl',
              accessText(context, 'supportLabel', l.supportLabel),
            )
            case final Widget support)
          support,
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          children: [
            if (link('privacyUrl', l.privacy) case final Widget privacy)
              privacy,
            if (link('termsUrl', l.terms) case final Widget terms) terms,
          ],
        ),
      ],
    );
  }
}

class _Orbits extends CustomPainter {
  const _Orbits();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final scale in [1.0, 1.3, 1.6]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * .2, size.height * 1.2),
          width: size.width * 1.7 * scale,
          height: size.height * .8 * scale,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
