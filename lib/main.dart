// ignore_for_file: prefer_const_constructors, const_with_non_const, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const NeoLoopApp());

const Color bg = Color(0xFFF5F7F4);
const Color panel = Color(0xFFFFFFFF);
const Color accent = Color(0xFF6B9B7A);
const Color accentGreen = Color(0xFF4CAF7A);
const Color textPrimary = Color(0xFF2C3E50);
const Color textSecondary = Color(0xFF6B7C8A);
const int totalLevels = 130;

class AppPrefs {
  static const languages = [
    'ru', 'uz', 'en', 'uk', 'kk', 'ja', 'de', 'fr', 'es', 'zh'
  ];
  static String language = 'ru';
  static bool sound = true;
  static bool effects = true;
  static bool music = true;
  static int level = 1;
  static int completed = 0;
  static int hints = 3;
  static int totalWins = 0;
  static int lastWheelDay = 0; // yyyyMMdd

  static Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    language = p.getString('language') ?? 'ru';
    if (!languages.contains(language)) language = 'ru';
    sound = p.getBool('sound') ?? true;
    effects = p.getBool('effects') ?? true;
    music = p.getBool('music') ?? true;
    level = (p.getInt('level') ?? 1).clamp(1, totalLevels);
    completed = (p.getInt('completed') ?? 0).clamp(0, totalLevels);
    hints = (p.getInt('hints') ?? 3).clamp(0, 999);
    totalWins = p.getInt('totalWins') ?? 0;
    lastWheelDay = p.getInt('lastWheelDay') ?? 0;
  }

  static Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('language', language);
    await p.setBool('sound', sound);
    await p.setBool('effects', effects);
    await p.setBool('music', music);
    await p.setInt('level', level);
    await p.setInt('completed', completed);
    await p.setInt('hints', hints);
    await p.setInt('totalWins', totalWins);
    await p.setInt('lastWheelDay', lastWheelDay);
  }

  static int todayKey() {
    final n = DateTime.now();
    return n.year * 10000 + n.month * 100 + n.day;
  }

  static bool canSpinWheel() => lastWheelDay != todayKey();
}
class AdService {
  static bool adsEnabled = true;

  static Future<bool> showRewarded() async {
    if (!adsEnabled) return false;
    // TODO: реальная реклама (AdMob и т.д.)
    await Future.delayed(const Duration(milliseconds: 800));
    return true; // для теста считаем, что реклама просмотрена
  }

  static Future<void> showInterstitial() async {
    if (!adsEnabled) return;
  }
}

class MusicService {
  static bool _playing = false;

  static Future<void> start() async {
    if (!AppPrefs.music || _playing) return;
    _playing = true;
    // TODO: audioplayers + assets/music/calm.mp3
  }

  static Future<void> stop() async {
    _playing = false;
  }

  static Future<void> setEnabled(bool v) async {
    AppPrefs.music = v;
    await AppPrefs.save();
    if (v) await start(); else await stop();
  }
}

class LevelStats {
  final int level;
  final int seconds;
  final int hintsUsed;
  final double avgDecisionMs; // средняя скорость решения пути

  LevelStats({
    required this.level,
    required this.seconds,
    required this.hintsUsed,
    required this.avgDecisionMs,
  });

  Map<String, dynamic> toJson() => {
        'l': level,
        's': seconds,
        'h': hintsUsed,
        'd': avgDecisionMs,
      };

  static LevelStats fromJson(Map<String, dynamic> j) => LevelStats(
        level: j['l'] ?? 0,
        seconds: j['s'] ?? 0,
        hintsUsed: j['h'] ?? 0,
        avgDecisionMs: (j['d'] ?? 0).toDouble(),
      );
}

class StatsStore {
  static final List<LevelStats> history = [];

  static Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getStringList('stats') ?? [];
    history.clear();
    for (final s in raw) {
      try {
        final parts = s.split('|');
        history.add(LevelStats(
          level: int.parse(parts[0]),
          seconds: int.parse(parts[1]),
          hintsUsed: int.parse(parts[2]),
          avgDecisionMs: double.parse(parts[3]),
        ));
      } catch (_) {}
    }
  }

  static Future<void> add(LevelStats st) async {
    history.removeWhere((e) => e.level == st.level);
    history.add(st);
    history.sort((a, b) => a.level.compareTo(b.level));
    final p = await SharedPreferences.getInstance();
    await p.setStringList(
      'stats',
      history
          .map((e) => '${e.level}|${e.seconds}|${e.hintsUsed}|${e.avgDecisionMs}')
          .toList(),
    );
  }
}
const Map<String, Map<String, String>> strings = {
  'ru': {
    'tagline': 'Спокойная логическая головоломка',
    'play': 'ИГРАТЬ',
    'settings': 'Настройки',
    'levels': 'Уровни',
    'leaderboard': 'Таблица лидеров',
    'duel': 'Дуэль 1 на 1',
    'level': 'УРОВЕНЬ',
    'connect': 'Соедини пары и заполни всё поле',
    'connected': 'Соединено',
    'filled': 'Заполнено',
    'hint': 'Подсказка',
    'reset': 'Сначала',
    'next': 'На следующий уровень',
    'toMenu': 'В меню',
    'won': 'Уровень пройден!',
    'moves': 'Ходов',
    'hintsUsed': 'Подсказок',
    'timeSpent': 'Время',
    'decisionSpeed': 'Скорость решения',
    'language': 'Язык',
    'sound': 'Звук',
    'effects': 'Эффекты',
    'music': 'Музыка',
    'done': 'Пройдено',
    'offline': 'Офлайн • Прогресс сохраняется',
    'noHints': 'Подсказки закончились',
    'hintShown': 'Показан правильный путь',
    'developer': 'Разработчик',
    'country': 'Страна',
    'description':
        'NeoLoop — спокойная логическая головоломка. Соединяй пары цветных точек и заполняй поле.',
    'coming': 'Скоро в обновлениях.',
    'levelSelect': 'Выбери уровень',
    'about': 'О приложении',
    'timerHint': 'Автовозврат в меню через',
    'hintsShop': 'Подсказки',
    'results': 'Результаты',
    'sellHints': 'Продать подсказки',
    'buyHints': 'Купить подсказки',
    'adHints': 'За рекламу (+3)',
    'wheel': 'Колесо фортуны',
    'spin': 'Крутить',
    'wheelDone': 'Уже крутили сегодня',
    'wheelAvailable': 'Колесо фортуны доступно!',
    'sec': 'сек',
    'ms': 'мс',
  },
  'en': {
    'tagline': 'A calm logic puzzle',
    'play': 'PLAY',
    'settings': 'Settings',
    'levels': 'Levels',
    'leaderboard': 'Leaderboard',
    'duel': '1 vs 1 Duel',
    'level': 'LEVEL',
    'connect': 'Connect pairs and fill the board',
    'connected': 'Connected',
    'filled': 'Filled',
    'hint': 'Hint',
    'reset': 'Restart',
    'next': 'Next level',
    'toMenu': 'To menu',
    'won': 'Level complete!',
    'moves': 'Moves',
    'hintsUsed': 'Hints',
    'timeSpent': 'Time',
    'decisionSpeed': 'Decision speed',
    'language': 'Language',
    'sound': 'Sound',
    'effects': 'Effects',
    'music': 'Music',
    'done': 'Completed',
    'offline': 'Offline • Progress saved',
    'noHints': 'No hints left',
    'hintShown': 'Correct path revealed',
    'developer': 'Developer',
    'country': 'Country',
    'description': 'NeoLoop is a calm logic puzzle. Connect dots and fill the board.',
    'coming': 'Coming soon.',
    'levelSelect': 'Choose a level',
    'about': 'About',
    'timerHint': 'Return to menu in',
    'hintsShop': 'Hints',
    'results': 'Results',
    'sellHints': 'Sell hints',
    'buyHints': 'Buy hints',
    'adHints': 'Watch ad (+3)',
    'wheel': 'Fortune wheel',
    'spin': 'Spin',
    'wheelDone': 'Already spun today',
    'wheelAvailable': 'Fortune wheel is ready!',
    'sec': 'sec',
    'ms': 'ms',
  },
};
// продолжение строк (остальные языки — краткие)
void _addLang(String code, Map<String, String> base) {
  // helper не нужен в runtime, строки добавим прямо
}

// Добавляем остальные языки упрощённо (чтобы файл не раздувался)
final Map<String, Map<String, String>> _extra = {
  'uz': {
    'play': 'O‘YNASH', 'settings': 'Sozlamalar', 'levels': 'Bosqichlar',
    'next': 'Keyingi bosqich', 'toMenu': 'Menyu', 'won': 'Bosqich tugadi!',
    'hint': 'Maslahat', 'hintsShop': 'Maslahatlar', 'results': 'Natijalar',
    'about': 'Ilova haqida', 'music': 'Musiqa', 'language': 'Til',
  },
  'uk': {
    'play': 'ГРАТИ', 'settings': 'Налаштування', 'levels': 'Рівні',
    'next': 'Наступний рівень', 'toMenu': 'В меню', 'won': 'Рівень пройдено!',
    'hint': 'Підказка', 'hintsShop': 'Підказки', 'results': 'Результати',
    'about': 'Про застосунок', 'music': 'Музика', 'language': 'Мова',
  },
  'kk': {
    'play': 'ОЙНАУ', 'settings': 'Баптаулар', 'levels': 'Деңгейлер',
    'next': 'Келесі деңгей', 'toMenu': 'Мәзір', 'won': 'Деңгей аяқталды!',
    'hint': 'Кеңес', 'hintsShop': 'Кеңестер', 'results': 'Нәтижелер',
    'about': 'Қосымша туралы', 'music': 'Музыка', 'language': 'Тіл',
  },
  'ja': {
    'play': 'プレイ', 'settings': '設定', 'levels': 'レベル',
    'next': '次のレベル', 'toMenu': 'メニューへ', 'won': 'クリア！',
    'hint': 'ヒント', 'hintsShop': 'ヒント', 'results': '成績',
    'about': 'アプリについて', 'music': '音楽', 'language': '言語',
  },
  'de': {
    'play': 'SPIELEN', 'settings': 'Einstellungen', 'levels': 'Level',
    'next': 'Nächstes Level', 'toMenu': 'Zum Menü', 'won': 'Level geschafft!',
    'hint': 'Hinweis', 'hintsShop': 'Hinweise', 'results': 'Ergebnisse',
    'about': 'Über die App', 'music': 'Musik', 'language': 'Sprache',
  },
  'fr': {
    'play': 'JOUER', 'settings': 'Paramètres', 'levels': 'Niveaux',
    'next': 'Niveau suivant', 'toMenu': 'Menu', 'won': 'Niveau terminé !',
    'hint': 'Indice', 'hintsShop': 'Indices', 'results': 'Résultats',
    'about': 'À propos', 'music': 'Musique', 'language': 'Langue',
  },
  'es': {
    'play': 'JUGAR', 'settings': 'Ajustes', 'levels': 'Niveles',
    'next': 'Siguiente nivel', 'toMenu': 'Al menú', 'won': '¡Nivel completado!',
    'hint': 'Pista', 'hintsShop': 'Pistas', 'results': 'Resultados',
    'about': 'Acerca de', 'music': 'Música', 'language': 'Idioma',
  },
  'zh': {
    'play': '开始', 'settings': '设置', 'levels': '关卡',
    'next': '下一关', 'toMenu': '返回菜单', 'won': '过关！',
    'hint': '提示', 'hintsShop': '提示', 'results': '成绩',
    'about': '关于', 'music': '音乐', 'language': '语言',
  },
};

String tr(String key) {
  final lang = AppPrefs.language;
  if (strings.containsKey(lang) && strings[lang]!.containsKey(key)) {
    return strings[lang]![key]!;
  }
  if (_extra.containsKey(lang) && _extra[lang]!.containsKey(key)) {
    return _extra[lang]![key]!;
  }
  return strings['en']?[key] ?? strings['ru']?[key] ?? key;
}
class LevelData {
  final int width, height, colors;
  final Map<int, int> endpoints;
  final List<List<int>> solution;
  const LevelData(this.width, this.height, this.colors, this.endpoints, this.solution);
  int get size => width; // совместимость
  int get cells => width * height;
}

class LevelGenerator {
  /// Ширина: растёт до 15 и останавливается
  static int widthFor(int level) {
    if (level <= 11) return (4 + level).clamp(5, 15);
    return 15;
  }

  /// Высота: после 15×15 растёт до 30
  static int heightFor(int level) {
    if (level <= 11) return widthFor(level);
    if (level <= 30) return 15;
    return (15 + (level - 30)).clamp(15, 30);
  }

  static double _t(int level) =>
      ((level.clamp(1, totalLevels) - 1) / (totalLevels - 1)).toDouble();

  static int colorCount(int level) {
    final cells = widthFor(level) * heightFor(level);
    final maxC = (cells / 4).floor();
    return (3 + 10 * _t(level)).round().clamp(3, maxC);
  }

  static LevelData generate(int level) {
    final w = widthFor(level);
    final h = heightFor(level);
    final rnd = Random(level * 7919 + 104729);
    final n = w * h;
    final path = <int>[];
    for (int y = 0; y < h; y++) {
      for (int i = 0; i < w; i++) {
        final x = y.isEven ? i : w - 1 - i;
        path.add(y * w + x);
      }
    }
    final pos = List<int>.filled(n, 0);
    for (int i = 0; i < n; i++) pos[path[i]] = i;

    void reverse(int a, int b) {
      while (a < b) {
        final x = path[a], y = path[b];
        path[a] = y; path[b] = x;
        pos[y] = a; pos[x] = b;
        a++; b--;
      }
    }

    final iters = (40 + 12000 * _t(level)).round();
    for (int it = 0; it < iters; it++) {
      final head = rnd.nextBool();
      final e = head ? path.first : path.last;
      final x = e % w, y = e ~/ w;
      final nbs = <int>[
        if (x > 0) e - 1,
        if (x < w - 1) e + 1,
        if (y > 0) e - w,
        if (y < h - 1) e + w,
      ];
      if (nbs.isEmpty) continue;
      final j = pos[nbs[rnd.nextInt(nbs.length)]];
      if (head) {
        if (j != 1) reverse(0, j - 1);
      } else {
        if (j != n - 2) reverse(j + 1, n - 1);
      }
    }

    final k = colorCount(level);
    final minSeg = (w <= 8) ? 3 : 4;
    final weights = List<double>.generate(k, (_) => 0.4 + rnd.nextDouble() * 1.6);
    final sum = weights.fold<double>(0, (a, b) => a + b);
    final rest = n - k * minSeg;
    final lengths = List<int>.generate(k, (i) => minSeg + (rest * weights[i] / sum).floor());
    var left = n - lengths.fold<int>(0, (a, b) => a + b);
    while (left-- > 0) lengths[rnd.nextInt(k)]++;

    final solutions = <List<int>>[];
    final endpoints = <int, int>{};
    var start = 0;
    for (int i = 0; i < k; i++) {
      final seg = path.sublist(start, start + lengths[i]);
      start += lengths[i];
      solutions.add(seg);
      endpoints[seg.first] = i;
      endpoints[seg.last] = i;
    }
    return LevelData(w, h, k, endpoints, solutions);
  }
}

List<Color> buildPalette(int n) => List.generate(
      n,
      (i) => HSVColor.fromAHSV(1, (i * 137.508) % 360, 0.45, 0.78).toColor(),
    );

Color glassColorForLevel(int level) {
  final hue = 90 + (level * 3) % 40;
  return HSVColor.fromAHSV(1, hue.toDouble(), 0.12, 0.94).toColor();
}
class NeoLoopApp extends StatelessWidget {
  const NeoLoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeoLoop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(seedColor: accent, brightness: Brightness.light),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: bg,
          foregroundColor: textPrimary,
          elevation: 0,
        ),
      ),
      home: const SplashPage(),
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 5200))..forward();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const BootPage(),
            transitionDuration: const Duration(milliseconds: 400),
            transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => CustomPaint(
          painter: _SplashPainter(t: _c.value),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _SplashPainter extends CustomPainter {
  final double t;
  _SplashPainter({required this.t});

  double get progress {
    final v = ((t - 0.05) / 0.8).clamp(0.0, 1.0);
    return 0.75 * v + 0.25 * (0.5 - 0.5 * cos(pi * v));
  }

  double get gain {
    if (t < 0.05) return t / 0.05;
    if (t > 0.9) return 1 - (t - 0.9) / 0.1;
    return 1;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height, s = w / 390;
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    final p = progress, g = gain;

    const text = 'VOSITA';
    final style = TextStyle(fontSize: 56 * s, fontWeight: FontWeight.w800, letterSpacing: 3 * s, color: const Color(0xFF0A0C0B));
    final tp = TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr)..layout();
    final dx = (w - tp.width) / 2;
    final dy = h * 0.36 - tp.height / 2;
    tp.paint(canvas, Offset(dx, dy));

    if (g > 0.02) {
      final beamX = dx + p * tp.width;
      final ray = Paint()
        ..shader = LinearGradient(colors: [
          Colors.transparent,
          Color.fromRGBO(0, 240, 90, 0.3 * g),
          Color.fromRGBO(0, 240, 90, 0.95 * g),
          Color.fromRGBO(230, 255, 240, 0.95 * g),
          Color.fromRGBO(0, 240, 90, 0.95 * g),
          Color.fromRGBO(0, 240, 90, 0.3 * g),
          Colors.transparent,
        ]).createShader(Rect.fromLTWH(beamX - 60 * s, dy, 120 * s, tp.height));
      canvas.drawRect(Rect.fromLTWH(beamX - 60 * s, dy - 6 * s, 120 * s, tp.height + 12 * s), ray);
      canvas.drawCircle(Offset(beamX, dy + tp.height * 0.55), 6 * s,
          Paint()..color = Color.fromRGBO(230, 255, 242, 0.95 * g)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    }

    final bw = 260.0 * s, bh = 20.0 * s, bx = (w - bw) / 2, by = h * 0.62;
    final outer = RRect.fromRectAndRadius(Rect.fromLTWH(bx, by, bw, bh), Radius.circular(bh / 2));
    canvas.drawRRect(outer, Paint()..color = const Color(0xFFE8EEEA));
    final fw = (bw - 6 * s) * p;
    if (fw > 1) {
      final fill = RRect.fromRectAndRadius(Rect.fromLTWH(bx + 3 * s, by + 3 * s, fw, bh - 6 * s), Radius.circular(bh / 2 - 3 * s));
      canvas.drawRRect(fill, Paint()..shader = const LinearGradient(colors: [Color(0xFF7DFFB0), Color(0xFF00C749)]).createShader(fill.outerRect));
    }
    final pct = TextPainter(
      text: TextSpan(text: '${(p * 100).round()}%', style: TextStyle(fontSize: 11 * s, fontWeight: FontWeight.w600, color: p > 0.4 ? Colors.white : const Color(0xFF14532D))),
      textDirection: TextDirection.ltr,
    )..layout();
    pct.paint(canvas, Offset((w - pct.width) / 2, by + (bh - pct.height) / 2));

    final lab = TextPainter(
      text: TextSpan(text: 'VOSITA STUDIOS', style: TextStyle(fontSize: 11 * s, fontWeight: FontWeight.w500, letterSpacing: 2 * s, color: const Color(0xFF1A1A1A))),
      textDirection: TextDirection.ltr,
    )..layout();
    lab.paint(canvas, Offset((w - lab.width) / 2, h * 0.74));
  }

  @override
  bool shouldRepaint(covariant _SplashPainter old) => old.t != t;
}
class BootPage extends StatefulWidget {
  const BootPage({super.key});
  @override
  State<BootPage> createState() => _BootPageState();
}

class _BootPageState extends State<BootPage> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await AppPrefs.load();
    await StatsStore.load();
    await MusicService.start();
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: accent)));
    }
    return const HomePage();
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> _play([int? num]) async {
    final level = num ?? AppPrefs.level;
    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => GamePage(number: level)),
    );
    if (result != null && mounted) {
      AppPrefs.completed = max(AppPrefs.completed, result);
      AppPrefs.level = min(totalLevels, result + 1);
      AppPrefs.totalWins++;
      await AppPrefs.save();
      setState(() {});
    } else if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = LevelGenerator.widthFor(AppPrefs.level);
    final h = LevelGenerator.heightFor(AppPrefs.level);
    final colors = LevelGenerator.colorCount(AppPrefs.level);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.hub_rounded, color: accent, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('NeoLoop', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: textPrimary)),
                        Text(tr('tagline'), style: const TextStyle(color: textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
                      setState(() {});
                    },
                    icon: const Icon(Icons.settings_outlined, color: textSecondary),
                  ),
                ],
              ),
              if (AppPrefs.canSpinWheel())
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Material(
                    color: accentGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => _openHintsShop(openWheel: true),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.casino, color: accentGreen, size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(tr('wheelAvailable'), style: const TextStyle(color: accentGreen, fontWeight: FontWeight.w600, fontSize: 13))),
                            const Icon(Icons.chevron_right, color: accentGreen, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              const Spacer(),
                            Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: panel,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 18, offset: const Offset(0, 5))],
                ),
                child: Column(
                  children: [
                    Icon(Icons.grid_4x4_rounded, size: 52, color: accent.withValues(alpha: 0.9)),
                    const SizedBox(height: 8),
                    Text('${tr('level')} ${AppPrefs.level}', style: const TextStyle(color: accent, letterSpacing: 1.2, fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    Text(tr('connect'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: textPrimary)),
                    const SizedBox(height: 8),
                    Text('$w×$h  •  $colors', style: const TextStyle(color: textSecondary)),
                    Text('${tr('done')}: ${AppPrefs.completed}/$totalLevels', style: const TextStyle(color: textSecondary)),
                    Text('${tr('hint')}: ${AppPrefs.hints}', style: const TextStyle(color: textSecondary)),
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: () => _play(),
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(tr('play'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _MenuBtn(icon: Icons.grid_view_rounded, label: tr('levels'), onTap: () async {
                final sel = await Navigator.push<int>(context, MaterialPageRoute(builder: (_) => const LevelsPage()));
                if (sel != null) {
                  AppPrefs.level = sel;
                  await AppPrefs.save();
                  setState(() {});
                }
              }),
              _MenuBtn(icon: Icons.lightbulb_outline, label: tr('hintsShop'), onTap: () => _openHintsShop()),
              _MenuBtn(icon: Icons.bar_chart_rounded, label: tr('results'), onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ResultsPage()));
              }),
              _MenuBtn(icon: Icons.emoji_events_outlined, label: tr('leaderboard'), onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => InfoPage(titleKey: 'leaderboard', icon: Icons.emoji_events_outlined, bodyKey: 'coming')));
              }),
              const Spacer(),
              Text(tr('offline'), textAlign: TextAlign.center, style: TextStyle(color: textSecondary.withValues(alpha: 0.7), fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  void _openHintsShop({bool openWheel = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: panel,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => HintsShopSheet(openWheel: openWheel, onChanged: () => setState(() {})),
    );
  }
}

class _MenuBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20, color: textSecondary),
        label: Text(label, style: const TextStyle(color: textPrimary)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
          minimumSize: const Size.fromHeight(44),
          alignment: Alignment.centerLeft,
          backgroundColor: panel,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
        ),
      ),
    );
  }
}
class LevelsPage extends StatelessWidget {
  const LevelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('levelSelect'))),
      body: GridView.builder(
        padding: const EdgeInsets.all(14),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 7, mainAxisSpacing: 7),
        itemCount: totalLevels,
        itemBuilder: (_, i) {
          final n = i + 1;
          final unlocked = n <= AppPrefs.completed + 1;
          return FilledButton(
            onPressed: unlocked ? () => Navigator.pop(context, n) : null,
            style: FilledButton.styleFrom(
              backgroundColor: n == AppPrefs.level ? accent : panel,
              foregroundColor: n == AppPrefs.level ? Colors.white : textPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
            ),
            child: Text('$n', style: const TextStyle(fontSize: 13)),
          );
        },
      ),
    );
  }
}

class HintsShopSheet extends StatefulWidget {
  final bool openWheel;
  final VoidCallback onChanged;
  const HintsShopSheet({super.key, this.openWheel = false, required this.onChanged});

  @override
  State<HintsShopSheet> createState() => _HintsShopSheetState();
}

class _HintsShopSheetState extends State<HintsShopSheet> {
  bool spinning = false;
  int? wheelResult;

  Future<void> _watchAd() async {
    final ok = await AdService.showRewarded();
    if (ok) {
      AppPrefs.hints += 3;
      await AppPrefs.save();
      widget.onChanged();
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('+3 ${tr('hint')}')));
      }
    }
  }

  Future<void> _spin() async {
    if (!AppPrefs.canSpinWheel() || spinning) return;
    setState(() { spinning = true; wheelResult = null; });
    await Future.delayed(const Duration(milliseconds: 1400));
    final r = Random().nextInt(16); // 0..15
    AppPrefs.hints += r;
    AppPrefs.lastWheelDay = AppPrefs.todayKey();
    await AppPrefs.save();
    widget.onChanged();
    if (mounted) setState(() { spinning = false; wheelResult = r; });
  }

  @override
  void initState() {
    super.initState();
    if (widget.openWheel && AppPrefs.canSpinWheel()) {
      Future.delayed(const Duration(milliseconds: 300), _spin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 14),
          Text(tr('hintsShop'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary)),
          Text('${tr('hint')}: ${AppPrefs.hints}', style: const TextStyle(color: textSecondary)),
          const SizedBox(height: 16),
          _shopTile(Icons.storefront_outlined, tr('sellHints'), tr('coming'), null),
          _shopTile(Icons.shopping_bag_outlined, tr('buyHints'), tr('coming'), null),
          _shopTile(Icons.ondemand_video, tr('adHints'), null, _watchAd),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accentGreen.withValues(alpha: 0.25)),
            ),
            child: Column(
              children: [
                Text(tr('wheel'), style: const TextStyle(fontWeight: FontWeight.w700, color: textPrimary)),
                const SizedBox(height: 6),
                if (wheelResult != null)
                  Text('+$wheelResult', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: accentGreen))
                else
                  Text(AppPrefs.canSpinWheel() ? '0 – 15' : tr('wheelDone'), style: const TextStyle(color: textSecondary)),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: AppPrefs.canSpinWheel() && !spinning ? _spin : null,
                  style: FilledButton.styleFrom(backgroundColor: accentGreen, foregroundColor: Colors.white),
                  child: Text(spinning ? '...' : tr('spin')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shopTile(IconData icon, String title, String? subtitle, VoidCallback? onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: accent),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }
}
class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final list = StatsStore.history;
    return Scaffold(
      appBar: AppBar(title: Text(tr('results'))),
      body: list.isEmpty
          ? Center(child: Text(tr('coming'), style: const TextStyle(color: textSecondary)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _card('Всего уровней', '${AppPrefs.completed}'),
                _card('Побед', '${AppPrefs.totalWins}'),
                _card('Подсказки сейчас', '${AppPrefs.hints}'),
                const SizedBox(height: 12),
                const Text('По уровням', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 8),
                ...list.map((s) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text('${tr('level')} ${s.level}'),
                        subtitle: Text(
                          '${tr('timeSpent')}: ${s.seconds} ${tr('sec')}\n'
                          '${tr('hintsUsed')}: ${s.hintsUsed}\n'
                          '${tr('decisionSpeed')}: ${s.avgDecisionMs.toStringAsFixed(0)} ${tr('ms')}',
                        ),
                        isThreeLine: true,
                      ),
                    )),
              ],
            ),
    );
  }

  Widget _card(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(12), boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
      ]),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(color: textSecondary))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: textPrimary)),
        ],
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('settings'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(tr('language')),
            leading: const Icon(Icons.language, color: accent),
            trailing: DropdownButton<String>(
              value: AppPrefs.language,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'ru', child: Text('🇷🇺 RU')),
                DropdownMenuItem(value: 'uz', child: Text('🇺🇿 UZ')),
                DropdownMenuItem(value: 'en', child: Text('🇬🇧 EN')),
                DropdownMenuItem(value: 'uk', child: Text('🇺🇦 UK')),
                DropdownMenuItem(value: 'kk', child: Text('🇰🇿 KK')),
                DropdownMenuItem(value: 'ja', child: Text('🇯🇵 JA')),
                DropdownMenuItem(value: 'de', child: Text('🇩🇪 DE')),
                DropdownMenuItem(value: 'fr', child: Text('🇫🇷 FR')),
                DropdownMenuItem(value: 'es', child: Text('🇪🇸 ES')),
                DropdownMenuItem(value: 'zh', child: Text('🇨🇳 ZH')),
              ],
              onChanged: (v) async {
                if (v != null) {
                  AppPrefs.language = v;
                  await AppPrefs.save();
                  setState(() {});
                }
              },
            ),
          ),
          SwitchListTile(
            title: Text(tr('sound')),
            value: AppPrefs.sound,
            activeThumbColor: accent,
            onChanged: (v) async {
              setState(() => AppPrefs.sound = v);
              await AppPrefs.save();
            },
          ),
          SwitchListTile(
            title: Text(tr('effects')),
            value: AppPrefs.effects,
            activeThumbColor: accent,
            onChanged: (v) async {
              setState(() => AppPrefs.effects = v);
              await AppPrefs.save();
            },
          ),
          SwitchListTile(
            title: Text(tr('music')),
            value: AppPrefs.music,
            activeThumbColor: accent,
            onChanged: (v) async {
              await MusicService.setEnabled(v);
              setState(() {});
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline, color: accent),
            title: Text(tr('about')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage())),
          ),
        ],
      ),
    );
  }
}
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('about'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              width: 72, height: 72,
              decoration: BoxDecoration(color: accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.hub_rounded, size: 40, color: accent),
            ),
          ),
          const SizedBox(height: 16),
          const Center(child: Text('NeoLoop', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary))),
          const SizedBox(height: 20),
          Text(tr('description'), style: const TextStyle(height: 1.5, color: textPrimary)),
          const SizedBox(height: 20),
          ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.person_outline, color: accent), title: Text(tr('developer')), subtitle: const Text('VOSITA STUDIOS')),
          ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.public, color: accent), title: Text(tr('country')), subtitle: const Text('Uzbekistan')),
        ],
      ),
    );
  }
}

class InfoPage extends StatelessWidget {
  final String titleKey, bodyKey;
  final IconData icon;
  const InfoPage({super.key, required this.titleKey, required this.icon, required this.bodyKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr(titleKey))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 56, color: accent.withValues(alpha: 0.7)),
            const SizedBox(height: 14),
            Text(tr(bodyKey), textAlign: TextAlign.center, style: const TextStyle(color: textSecondary, fontSize: 15)),
          ]),
        ),
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  final int number;
  const GamePage({super.key, required this.number});
  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late LevelData data;
  late List<Color> colors;
  late List<int?> owner;
  final Map<int, List<int>> paths = {};
  int? active;
  List<int> draft = [];
  int moves = 0;
  int hintsLeft = 0;
  int hintsUsed = 0;
  bool won = false;
  DateTime? startedAt;
  final List<int> decisionTimes = [];
  DateTime? pathStartAt;

  int get n => data.width * data.height;
  Map<int, int> get endpoints => data.endpoints;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    data = LevelGenerator.generate(widget.number);
    colors = buildPalette(data.colors);
    owner = List<int?>.filled(n, null);
    paths.clear();
    active = null;
    draft = [];
    moves = 0;
    hintsLeft = min(3, AppPrefs.hints);
    hintsUsed = 0;
    won = false;
    startedAt = DateTime.now();
    decisionTimes.clear();
    pathStartAt = null;
    setState(() {});
  }
  void _rebuild() {
    owner = List<int?>.filled(n, null);
    for (final e in paths.entries) {
      for (final c in e.value) owner[c] = e.key;
    }
  }

  void begin(int cell) {
    if (won) return;
    final color = endpoints[cell];
    if (color == null) return;
    pathStartAt = DateTime.now();
    if (paths.containsKey(color)) {
      for (final c in paths[color]!) owner[c] = null;
      paths.remove(color);
    }
    active = color;
    draft = [cell];
    owner[cell] = color;
    setState(() {});
  }

  void moveTo(int cell) {
    if (active == null || draft.isEmpty || won) return;
    final last = draft.last;
    if (cell == last) return;
    final w = data.width;
    final ax = last % w, ay = last ~/ w;
    final bx = cell % w, by = cell ~/ w;
    if ((ax - bx).abs() + (ay - by).abs() != 1) return;

    final idx = draft.indexOf(cell);
    if (idx >= 0) {
      for (final c in draft.sublist(idx + 1)) owner[c] = null;
      draft = draft.sublist(0, idx + 1);
      setState(() {});
      return;
    }

    final occ = owner[cell];
    if (occ != null && occ != active) return;
    if (endpoints.containsKey(cell) && endpoints[cell] != active) return;

    if (endpoints[cell] == active && cell != draft.first) {
      draft.add(cell);
      owner[cell] = active;
      paths[active!] = List.from(draft);
      if (pathStartAt != null) {
        decisionTimes.add(DateTime.now().difference(pathStartAt!).inMilliseconds);
      }
      pathStartAt = null;
      active = null;
      draft = [];
      moves++;
      setState(() {});
      _checkWin();
      return;
    }

    draft.add(cell);
    owner[cell] = active;
    setState(() {});
  }

  void endDrag() {
    if (active == null) return;
    if (draft.length < 2 || endpoints[draft.last] != active) {
      for (final c in draft) owner[c] = null;
    }
    active = null;
    draft = [];
    pathStartAt = null;
    setState(() {});
  }

  void _checkWin() {
    if (paths.length != data.colors) return;
    if (owner.any((o) => o == null)) return;
    won = true;
    final seconds = DateTime.now().difference(startedAt!).inSeconds;
    final avgDecision = decisionTimes.isEmpty
        ? 0.0
        : decisionTimes.reduce((a, b) => a + b) / decisionTimes.length;

    StatsStore.add(LevelStats(
      level: widget.number,
      seconds: seconds,
      hintsUsed: hintsUsed,
      avgDecisionMs: avgDecision,
    ));

    AppPrefs.completed = max(AppPrefs.completed, widget.number);
    AppPrefs.totalWins++;
    if (widget.number >= AppPrefs.level) {
      AppPrefs.level = min(totalLevels, widget.number + 1);
    }
    AppPrefs.save();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _WinDialog(
        level: widget.number,
        seconds: seconds,
        hintsUsed: hintsUsed,
        avgDecisionMs: avgDecision,
        onNext: () {
          Navigator.pop(context);
          if (widget.number < totalLevels) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => GamePage(number: widget.number + 1)),
            );
          } else {
            Navigator.pop(context);
          }
        },
        onMenu: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }
  Future<void> useHint() async {
    if (hintsLeft <= 0 || AppPrefs.hints <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('noHints'))));
      return;
    }
    for (int i = 0; i < data.colors; i++) {
      if (!paths.containsKey(i)) {
        paths[i] = List.from(data.solution[i]);
        hintsLeft--;
        hintsUsed++;
        AppPrefs.hints = max(0, AppPrefs.hints - 1);
        await AppPrefs.save();
        _rebuild();
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('hintShown'))));
        _checkWin();
        return;
      }
    }
  }

  int? _cellAt(Offset local, double cellW, double cellH) {
    final x = (local.dx / cellW).floor();
    final y = (local.dy / cellH).floor();
    if (x < 0 || y < 0 || x >= data.width || y >= data.height) return null;
    return y * data.width + x;
  }

  @override
  Widget build(BuildContext context) {
    final glass = glassColorForLevel(widget.number);
    final connected = paths.length;
    final filled = owner.where((o) => o != null).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${tr('level')} ${widget.number}'),
        actions: [
          TextButton.icon(
            onPressed: useHint,
            icon: const Icon(Icons.lightbulb_outline, size: 18),
            label: Text('$hintsLeft'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Expanded(child: Text('${tr('connected')}: $connected/${data.colors}', style: const TextStyle(color: textSecondary, fontSize: 13))),
                Expanded(child: Text('${tr('filled')}: $filled/$n', textAlign: TextAlign.center, style: const TextStyle(color: textSecondary, fontSize: 13))),
                Expanded(child: Text('${tr('hint')}: ${AppPrefs.hints}', textAlign: TextAlign.right, style: const TextStyle(color: textSecondary, fontSize: 13))),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: AspectRatio(
                aspectRatio: data.width / data.height,
                child: LayoutBuilder(
                  builder: (context, box) {
                    final cw = box.maxWidth / data.width;
                    final ch = box.maxHeight / data.height;
                    return GestureDetector(
                      onPanStart: (d) {
                        final c = _cellAt(d.localPosition, cw, ch);
                        if (c != null) begin(c);
                      },
                      onPanUpdate: (d) {
                        final c = _cellAt(d.localPosition, cw, ch);
                        if (c != null) moveTo(c);
                      },
                      onPanEnd: (_) => endDrag(),
                      onPanCancel: endDrag,
                      child: CustomPaint(
                        painter: GridPainter(
                          width: data.width,
                          height: data.height,
                          endpoints: endpoints,
                          paths: paths,
                          draft: draft,
                          active: active,
                          owner: owner,
                          colors: colors,
                          glassColor: glass,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
                    Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh),
                    label: Text(tr('reset')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textPrimary,
                      side: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: useHint,
                    icon: const Icon(Icons.lightbulb, size: 18),
                    label: Text(tr('hint')),
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WinDialog extends StatefulWidget {
  final int level, seconds, hintsUsed;
  final double avgDecisionMs;
  final VoidCallback onNext, onMenu;

  const _WinDialog({
    required this.level,
    required this.seconds,
    required this.hintsUsed,
    required this.avgDecisionMs,
    required this.onNext,
    required this.onMenu,
  });

  @override
  State<_WinDialog> createState() => _WinDialogState();
}

class _WinDialogState extends State<_WinDialog> {
  int left = 5;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => left--);
      if (left <= 0) {
        t.cancel();
        widget.onMenu(); // автоматически «В меню»
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: panel,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(tr('won'), textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${tr('level')} ${widget.level}', style: const TextStyle(color: textSecondary)),
          const SizedBox(height: 12),
          _stat(tr('timeSpent'), '${widget.seconds} ${tr('sec')}'),
          _stat(tr('hintsUsed'), '${widget.hintsUsed}'),
          _stat(tr('decisionSpeed'), '${widget.avgDecisionMs.toStringAsFixed(0)} ${tr('ms')}'),
          const SizedBox(height: 10),
          Text('${tr('timerHint')} $left', style: const TextStyle(color: textSecondary, fontSize: 12)),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  timer?.cancel();
                  widget.onNext();
                },
                style: FilledButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.white),
                child: Text(tr('next')),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  timer?.cancel();
                  widget.onMenu();
                },
                child: Text(tr('toMenu')),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _stat(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(k, style: const TextStyle(color: textSecondary))),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
class GridPainter extends CustomPainter {
  final int width, height;
  final Map<int, int> endpoints;
  final Map<int, List<int>> paths;
  final List<int> draft;
  final int? active;
  final List<int?> owner;
  final List<Color> colors;
  final Color glassColor;

  GridPainter({
    required this.width,
    required this.height,
    required this.endpoints,
    required this.paths,
    required this.draft,
    required this.active,
    required this.owner,
    required this.colors,
    required this.glassColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cw = size.width / width;
    final ch = size.height / height;
    final cell = min(cw, ch);

    // Молочно-зелёное стекло
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          glassColor,
          Color.lerp(glassColor, const Color(0xFFD4E8D8), 0.35)!,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)),
      bgPaint,
    );

    // Сетка
    final grid = Paint()
      ..color = Colors.black.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        canvas.drawRect(Rect.fromLTWH(x * cw, y * ch, cw, ch), grid);
      }
    }

    void drawPath(List<int> p, Color color) {
      if (p.isEmpty) return;
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = cell * 0.55
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final glow = Paint()
        ..color = color.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = cell * 0.85
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      final path = Path();
      Offset center(int c) => Offset((c % width + 0.5) * cw, (c ~/ width + 0.5) * ch);
      path.moveTo(center(p.first).dx, center(p.first).dy);
      for (final c in p.skip(1)) {
        final pt = center(c);
        path.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(path, glow);
      canvas.drawPath(path, paint);
    }

    for (final e in paths.entries) {
      drawPath(e.value, colors[e.key]);
    }
    if (active != null && draft.isNotEmpty) {
      drawPath(draft, colors[active!]);
    }

    // Точки
    for (final e in endpoints.entries) {
      final c = e.key;
      final color = colors[e.value];
      final center = Offset((c % width + 0.5) * cw, (c ~/ width + 0.5) * ch);
      canvas.drawCircle(center, cell * 0.36, Paint()..color = color.withValues(alpha: 0.2));
      canvas.drawCircle(center, cell * 0.27, Paint()..color = color);
      canvas.drawCircle(center, cell * 0.11, Paint()..color = bg);
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter old) => true;
}
// ─── Конец основного кода игры ───────────────────────────────────────────
// Если компилятор ругается на отсутствующие методы MusicService.start —
// они уже есть в блоке 2. Ничего дополнительно в конец файла добавлять
// не нужно. Файл должен заканчиваться закрывающей скобкой GridPainter.
