// ignore_for_file: prefer_const_constructors, const_with_non_const, prefer_const_literals_to_create_immutables, curly_braces_in_flow_control_structures, unused_element, use_build_context_synchronously

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const NeoLoopApp());

// Детская яркая палитра
const Color bg = Color(0xFFFFF8E7);
const Color panel = Color(0xFFFFFFFF);
const Color accent = Color(0xFFFF6B9D);
const Color accent2 = Color(0xFF7C4DFF);
const Color accent3 = Color(0xFF00C853);
const Color accent4 = Color(0xFFFF9100);
const Color accent5 = Color(0xFF00B0FF);
const Color textPrimary = Color(0xFF3E2723);
const Color textSecondary = Color(0xFF6D4C41);
const int totalLevels = 130;

class AppPrefs {
  static const languages = ['ru', 'uz', 'en', 'uk', 'kk', 'ja', 'de', 'fr', 'es', 'zh'];
  static String language = 'ru';
  static bool sound = true;
  static bool effects = true;
  static bool music = true;
  static int level = 1;
  static int completed = 0;
  static int hints = 3;
  static int totalWins = 0;
  static int lastWheelDay = 0;

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
    await Future.delayed(const Duration(milliseconds: 700));
    return true;
  }
}

class MusicService {
  static bool _playing = false;
  static Future<void> start() async {
    if (!AppPrefs.music || _playing) return;
    _playing = true;
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
  final int level, seconds, hintsUsed;
  final double avgDecisionMs;
  LevelStats({required this.level, required this.seconds, required this.hintsUsed, required this.avgDecisionMs});
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
        history.add(LevelStats(level: int.parse(parts[0]), seconds: int.parse(parts[1]), hintsUsed: int.parse(parts[2]), avgDecisionMs: double.parse(parts[3])));
      } catch (_) {}
    }
  }
  static Future<void> add(LevelStats st) async {
    history.removeWhere((e) => e.level == st.level);
    history.add(st);
    history.sort((a, b) => a.level.compareTo(b.level));
    final p = await SharedPreferences.getInstance();
    await p.setStringList('stats', history.map((e) => '${e.level}|${e.seconds}|${e.hintsUsed}|${e.avgDecisionMs}').toList());
  }
}
const Map<String, Map<String, String>> strings = {
  'ru': {
    'tagline': 'Яркая логическая головоломка для детей',
    'play': 'ИГРАТЬ', 'settings': 'Настройки', 'levels': 'Уровни',
    'level': 'УРОВЕНЬ', 'connect': 'Соедини одинаковые цвета!',
    'connected': 'Соединено', 'filled': 'Заполнено', 'hint': 'Подсказка',
    'reset': 'Заново', 'next': 'Следующий уровень', 'toMenu': 'В меню',
    'won': 'Ура! Уровень пройден!', 'moves': 'Ходов', 'hintsUsed': 'Подсказок',
    'timeSpent': 'Время', 'decisionSpeed': 'Скорость', 'language': 'Язык',
    'sound': 'Звук', 'effects': 'Эффекты', 'music': 'Музыка', 'done': 'Пройдено',
    'offline': 'Офлайн • Прогресс сохраняется', 'noHints': 'Подсказки закончились',
    'hintShown': 'Вот правильный путь!', 'developer': 'Студия', 'country': 'Страна',
    'description': 'NeoLoop — весёлая игра для детей. Соединяй цветные точки линиями и заполни всё поле. Чем дальше — тем интереснее!',
    'coming': 'Скоро появится!', 'levelSelect': 'Выбери уровень', 'about': 'О игре',
    'timerHint': 'В меню через', 'hintsShop': 'Подсказки', 'results': 'Мои результаты',
    'sellHints': 'Продать подсказки', 'buyHints': 'Купить подсказки',
    'adHints': 'За рекламу (+3)', 'wheel': 'Колесо удачи', 'spin': 'Крутить!',
    'wheelDone': 'Уже крутили сегодня', 'wheelAvailable': 'Колесо удачи готово!',
    'sec': 'сек', 'ms': 'мс', 'howTo': 'Как играть',
    'howToBody': '1. Нажми на цветную точку.\n2. Веди палец к такой же точке.\n3. Линия не должна пересекать другие.\n4. Заполни все клетки.\n5. Подсказка показывает один правильный путь.\n\nУдачи!',
  },
  'en': {
    'tagline': 'A bright logic puzzle for kids',
    'play': 'PLAY', 'settings': 'Settings', 'levels': 'Levels',
    'level': 'LEVEL', 'connect': 'Connect matching colors!',
    'connected': 'Connected', 'filled': 'Filled', 'hint': 'Hint',
    'reset': 'Restart', 'next': 'Next level', 'toMenu': 'Menu',
    'won': 'Yay! Level complete!', 'moves': 'Moves', 'hintsUsed': 'Hints',
    'timeSpent': 'Time', 'decisionSpeed': 'Speed', 'language': 'Language',
    'sound': 'Sound', 'effects': 'Effects', 'music': 'Music', 'done': 'Done',
    'offline': 'Offline • Progress saved', 'noHints': 'No hints left',
    'hintShown': 'Here is the path!', 'developer': 'Studio', 'country': 'Country',
    'description': 'NeoLoop is a fun puzzle for kids. Connect colored dots with lines and fill the whole board. The further you go, the more exciting it gets!',
    'coming': 'Coming soon!', 'levelSelect': 'Choose a level', 'about': 'About',
    'timerHint': 'Back to menu in', 'hintsShop': 'Hints', 'results': 'My results',
    'sellHints': 'Sell hints', 'buyHints': 'Buy hints',
    'adHints': 'Watch ad (+3)', 'wheel': 'Lucky wheel', 'spin': 'Spin!',
    'wheelDone': 'Already spun today', 'wheelAvailable': 'Lucky wheel is ready!',
    'sec': 'sec', 'ms': 'ms', 'howTo': 'How to play',
    'howToBody': '1. Tap a colored dot.\n2. Drag to the matching dot.\n3. Paths must not cross.\n4. Fill every cell.\n5. A hint shows one correct path.\n\nHave fun!',
  },
};
final Map<String, Map<String, String>> _extra = {
  'uz': {
    'tagline': 'Bolalar uchun yorqin o‘yin', 'play': 'O‘YNASH', 'settings': 'Sozlamalar',
    'levels': 'Bosqichlar', 'level': 'BOSQICH', 'connect': 'Bir xil ranglarni ulang!',
    'hint': 'Maslahat', 'reset': 'Qayta', 'next': 'Keyingi', 'toMenu': 'Menyu',
    'won': 'Tabriklaymiz!', 'about': 'O‘yin haqida', 'howTo': 'Qanday o‘ynash',
    'description': 'NeoLoop — bolalar uchun quvnoq o‘yin. Rangli nuqtalarni chiziq bilan ulang va maydonni to‘ldiring!',
    'howToBody': '1. Rangli nuqtaga bosing.\n2. Xuddi shunday nuqtaga torting.\n3. Chiziqlar kesishmasin.\n4. Barcha kataklarni to‘ldiring.\n5. Maslahat to‘g‘ri yo‘lni ko‘rsatadi.',
    'hintsShop': 'Maslahatlar', 'results': 'Natijalar', 'wheel': 'Omad g‘ildiragi', 'spin': 'Aylantirish',
    'music': 'Musiqa', 'language': 'Til', 'coming': 'Tez orada!',
  },
  'uk': {
    'tagline': 'Яскрава головоломка для дітей', 'play': 'ГРАТИ', 'settings': 'Налаштування',
    'levels': 'Рівні', 'level': 'РІВЕНЬ', 'connect': 'З’єднай однакові кольори!',
    'hint': 'Підказка', 'reset': 'Спочатку', 'next': 'Далі', 'toMenu': 'В меню',
    'won': 'Ура! Рівень пройдено!', 'about': 'Про гру', 'howTo': 'Як грати',
    'description': 'NeoLoop — весела гра для дітей. З’єднуй кольорові точки лініями і заповнюй усе поле!',
    'howToBody': '1. Натисни на кольорову точку.\n2. Веди до такої ж точки.\n3. Лінії не повинні перетинатися.\n4. Заповни всі клітинки.\n5. Підказка показує правильний шлях.',
    'hintsShop': 'Підказки', 'results': 'Результати', 'wheel': 'Колесо удачі', 'spin': 'Крутити',
    'music': 'Музика', 'language': 'Мова', 'coming': 'Незабаром!',
  },
  'kk': {
    'tagline': 'Балаларға арналған жарқын ойын', 'play': 'ОЙНАУ', 'settings': 'Баптаулар',
    'levels': 'Деңгейлер', 'level': 'ДЕҢГЕЙ', 'connect': 'Бірдей түстерді қос!',
    'hint': 'Кеңес', 'reset': 'Қайта', 'next': 'Келесі', 'toMenu': 'Мәзір',
    'won': 'Жарайсың!', 'about': 'Ойын туралы', 'howTo': 'Қалай ойнау',
    'description': 'NeoLoop — балаларға арналған көңілді ойын. Түсті нүктелерді сызықпен қосып, бүкіл өрісті толтыр!',
    'howToBody': '1. Түсті нүктені бас.\n2. Сол түске қарай сыз.\n3. Сызықтар қиылыспасын.\n4. Барлық ұяшықтарды толтыр.\n5. Кеңес дұрыс жолды көрсетеді.',
    'hintsShop': 'Кеңестер', 'results': 'Нәтижелер', 'wheel': 'Сәттік дөңгелек', 'spin': 'Айналдыру',
    'music': 'Музыка', 'language': 'Тіл', 'coming': 'Жақында!',
  },
};
final Map<String, Map<String, String>> _extra2 = {
  'ja': {
    'tagline': '子ども向けのかわいいパズル', 'play': 'プレイ', 'settings': '設定',
    'levels': 'レベル', 'level': 'レベル', 'connect': '同じ色をつなげて！',
    'hint': 'ヒント', 'reset': 'リセット', 'next': '次のレベル', 'toMenu': 'メニュー',
    'won': 'クリア！すごい！', 'about': 'このアプリについて', 'howTo': '遊び方',
    'description': 'NeoLoopは子ども向けの楽しいパズルです。色の点をつないで、マスを全部うめましょう！',
    'howToBody': '1. 色の点をタッチ\n2. 同じ色までなぞる\n3. 線はクロスしない\n4. 全部うめる\n5. ヒントで正しい道がわかるよ',
    'hintsShop': 'ヒント', 'results': 'せいせき', 'wheel': 'ラッキールーレット', 'spin': 'まわす',
    'music': 'おんがく', 'language': 'ことば', 'coming': 'もうすぐ！',
  },
  'de': {
    'tagline': 'Buntes Logikspiel für Kinder', 'play': 'SPIELEN', 'settings': 'Einstellungen',
    'levels': 'Level', 'level': 'LEVEL', 'connect': 'Gleiche Farben verbinden!',
    'hint': 'Tipp', 'reset': 'Neu', 'next': 'Nächstes Level', 'toMenu': 'Menü',
    'won': 'Super! Level geschafft!', 'about': 'Über das Spiel', 'howTo': 'So spielt man',
    'description': 'NeoLoop ist ein fröhliches Puzzle für Kinder. Verbinde bunte Punkte und fülle das ganze Feld!',
    'howToBody': '1. Tippe auf einen Punkt.\n2. Ziehe zum gleichen Punkt.\n3. Linien dürfen sich nicht kreuzen.\n4. Fülle alle Felder.\n5. Ein Tipp zeigt den richtigen Weg.',
    'hintsShop': 'Tipps', 'results': 'Ergebnisse', 'wheel': 'Glücksrad', 'spin': 'Drehen',
    'music': 'Musik', 'language': 'Sprache', 'coming': 'Bald!',
  },
  'fr': {
    'tagline': 'Puzzle coloré pour enfants', 'play': 'JOUER', 'settings': 'Réglages',
    'levels': 'Niveaux', 'level': 'NIVEAU', 'connect': 'Relie les mêmes couleurs !',
    'hint': 'Indice', 'reset': 'Recommencer', 'next': 'Niveau suivant', 'toMenu': 'Menu',
    'won': 'Bravo ! Niveau terminé !', 'about': 'À propos', 'howTo': 'Comment jouer',
    'description': 'NeoLoop est un puzzle amusant pour enfants. Relie les points de couleur et remplis tout le plateau !',
    'howToBody': '1. Touche un point coloré.\n2. Glisse jusqu’au même point.\n3. Les lignes ne se croisent pas.\n4. Remplis toutes les cases.\n5. Un indice montre le bon chemin.',
    'hintsShop': 'Indices', 'results': 'Résultats', 'wheel': 'Roue de la chance', 'spin': 'Tourner',
    'music': 'Musique', 'language': 'Langue', 'coming': 'Bientôt !',
  },
  'es': {
    'tagline': 'Puzzle brillante para niños', 'play': 'JUGAR', 'settings': 'Ajustes',
    'levels': 'Niveles', 'level': 'NIVEL', 'connect': '¡Conecta los mismos colores!',
    'hint': 'Pista', 'reset': 'Reiniciar', 'next': 'Siguiente', 'toMenu': 'Menú',
    'won': '¡Bien! Nivel completado', 'about': 'Acerca de', 'howTo': 'Cómo jugar',
    'description': 'NeoLoop es un puzzle divertido para niños. Conecta los puntos de colores y llena todo el tablero.',
    'howToBody': '1. Toca un punto de color.\n2. Arrastra hasta el mismo color.\n3. Las líneas no se cruzan.\n4. Llena todas las casillas.\n5. Una pista muestra el camino correcto.',
    'hintsShop': 'Pistas', 'results': 'Resultados', 'wheel': 'Ruleta de la suerte', 'spin': 'Girar',
    'music': 'Música', 'language': 'Idioma', 'coming': '¡Pronto!',
  },
  'zh': {
    'tagline': '给孩子们的彩色益智游戏', 'play': '开始', 'settings': '设置',
    'levels': '关卡', 'level': '关卡', 'connect': '连接相同的颜色！',
    'hint': '提示', 'reset': '重来', 'next': '下一关', 'toMenu': '菜单',
    'won': '太棒了！过关啦！', 'about': '关于游戏', 'howTo': '怎么玩',
    'description': 'NeoLoop 是一款适合孩子的趣味拼图。用线连接彩色点，填满整个棋盘吧！',
    'howToBody': '1. 点击彩色点。\n2. 拖到相同颜色。\n3. 线条不能交叉。\n4. 填满所有格子。\n5. 提示会显示正确路线。',
    'hintsShop': '提示', 'results': '成绩', 'wheel': '幸运转盘', 'spin': '旋转',
    'music': '音乐', 'language': '语言', 'coming': '即将推出！',
  },
};

String tr(String key) {
  final lang = AppPrefs.language;
  if (strings[lang]?[key] != null) return strings[lang]![key]!;
  if (_extra[lang]?[key] != null) return _extra[lang]![key]!;
  if (_extra2[lang]?[key] != null) return _extra2[lang]![key]!;
  return strings['en']?[key] ?? strings['ru']?[key] ?? key;
}
class LevelData {
  final int width, height, colors;
  final Map<int, int> endpoints;
  final List<List<int>> solution;
  const LevelData(this.width, this.height, this.colors, this.endpoints, this.solution);
  int get cells => width * height;
}

class LevelGenerator {
  static int widthFor(int level) {
    if (level <= 11) return (4 + level).clamp(5, 15);
    return 15;
  }

  static int heightFor(int level) {
    if (level <= 11) return widthFor(level);
    if (level <= 30) return 15;
    return (15 + (level - 30)).clamp(15, 30);
  }

  static double _t(int level) => ((level.clamp(1, totalLevels) - 1) / (totalLevels - 1)).toDouble();

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
    for (int i = 0; i < n; i++) {
      pos[path[i]] = i;
    }

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
    while (left-- > 0) {
      lengths[rnd.nextInt(k)]++;
    }

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

List<Color> buildPalette(int n) {
  const base = [
    Color(0xFFFF5252), Color(0xFFFF9100), Color(0xFFFFD600),
    Color(0xFF69F0AE), Color(0xFF40C4FF), Color(0xFF7C4DFF),
    Color(0xFFFF4081), Color(0xFF18FFFF), Color(0xFFB2FF59),
    Color(0xFFFF6E40), Color(0xFFEA80FC), Color(0xFF64FFDA),
  ];
  return List.generate(n, (i) => base[i % base.length]);
}

Color boardColorForLevel(int level) {
  final hues = [20.0, 45.0, 90.0, 160.0, 200.0, 280.0, 320.0];
  final h = hues[level % hues.length];
  return HSVColor.fromAHSV(1, h, 0.25, 0.97).toColor();
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
        appBarTheme: const AppBarTheme(backgroundColor: bg, foregroundColor: textPrimary, elevation: 0),
        fontFamily: null,
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
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 5500))..forward();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        Navigator.of(context).pushReplacement(PageRouteBuilder(
          pageBuilder: (_, __, ___) => const BootPage(),
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
        ));
      }
    });
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => CustomPaint(painter: _SplashPainter(t: _c.value), child: const SizedBox.expand()),
      ),
    );
  }
}

class _SplashPainter extends CustomPainter {
  final double t;
  _SplashPainter({required this.t});
  double get progress {
    final v = ((t - 0.06) / 0.78).clamp(0.0, 1.0);
    return 0.75 * v + 0.25 * (0.5 - 0.5 * cos(pi * v));
  }
  double get gain {
    if (t < 0.06) return t / 0.06;
    if (t > 0.9) return 1 - (t - 0.9) / 0.1;
    return 1;
  }
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height, s = w / 390;
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    final p = progress, g = gain;
    const text = 'VOSITA';
    final style = TextStyle(fontSize: 58 * s, fontWeight: FontWeight.w900, letterSpacing: 4 * s, color: const Color(0xFF0A0C0B));
    final tp = TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr)..layout();
    final dx = (w - tp.width) / 2, dy = h * 0.35 - tp.height / 2;
    tp.paint(canvas, Offset(dx, dy));
    if (g > 0.02) {
      final beamX = dx + p * tp.width;
      final ray = Paint()..shader = LinearGradient(colors: [
        Colors.transparent,
        Color.fromRGBO(0, 240, 90, 0.25 * g),
        Color.fromRGBO(0, 240, 90, 0.95 * g),
        Color.fromRGBO(230, 255, 240, 0.98 * g),
        Color.fromRGBO(0, 240, 90, 0.95 * g),
        Color.fromRGBO(0, 240, 90, 0.25 * g),
        Colors.transparent,
      ]).createShader(Rect.fromLTWH(beamX - 70 * s, dy, 140 * s, tp.height));
      canvas.drawRect(Rect.fromLTWH(beamX - 70 * s, dy - 8 * s, 140 * s, tp.height + 16 * s), ray);
      canvas.drawCircle(Offset(beamX, dy + tp.height * 0.55), 7 * s,
        Paint()..color = Color.fromRGBO(230, 255, 242, 0.95 * g)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
    }
    final bw = 270.0 * s, bh = 22.0 * s, bx = (w - bw) / 2, by = h * 0.62;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(bx, by, bw, bh), Radius.circular(bh / 2)), Paint()..color = const Color(0xFFE8EEEA));
    final fw = (bw - 6 * s) * p;
    if (fw > 1) {
      final fill = RRect.fromRectAndRadius(Rect.fromLTWH(bx + 3 * s, by + 3 * s, fw, bh - 6 * s), Radius.circular(bh / 2 - 3));
      canvas.drawRRect(fill, Paint()..shader = const LinearGradient(colors: [Color(0xFF7DFFB0), Color(0xFF00C749)]).createShader(fill.outerRect));
    }
    final pct = TextPainter(text: TextSpan(text: '${(p * 100).round()}%', style: TextStyle(fontSize: 12 * s, fontWeight: FontWeight.w700, color: p > 0.4 ? Colors.white : const Color(0xFF14532D))), textDirection: TextDirection.ltr)..layout();
    pct.paint(canvas, Offset((w - pct.width) / 2, by + (bh - pct.height) / 2));
    final lab = TextPainter(text: TextSpan(text: 'VOSITA STUDIOS', style: TextStyle(fontSize: 12 * s, fontWeight: FontWeight.w600, letterSpacing: 2 * s, color: const Color(0xFF1A1A1A))), textDirection: TextDirection.ltr)..layout();
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
    if (!_ready) return const Scaffold(body: Center(child: CircularProgressIndicator(color: accent)));
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
    await Navigator.push(context, MaterialPageRoute(builder: (_) => GamePage(number: level)));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final w = LevelGenerator.widthFor(AppPrefs.level);
    final h = LevelGenerator.heightFor(AppPrefs.level);
    final colors = LevelGenerator.colorCount(AppPrefs.level);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF8E7), Color(0xFFE8F5E9), Color(0xFFE3F2FD), Color(0xFFFCE4EC)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [accent, accent2]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: const Icon(Icons.hub_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('NeoLoop', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textPrimary)),
                    Text(tr('tagline'), style: const TextStyle(color: textSecondary, fontSize: 12)),
                  ])),
                  IconButton(onPressed: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
                    setState(() {});
                  }, icon: const Icon(Icons.settings_rounded, color: accent2)),
                ]),
                if (AppPrefs.canSpinWheel())
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Material(
                      color: accent4.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _openHintsShop(openWheel: true),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(children: [
                            const Icon(Icons.casino, color: accent4, size: 22),
                            const SizedBox(width: 8),
                            Expanded(child: Text(tr('wheelAvailable'), style: const TextStyle(color: accent4, fontWeight: FontWeight.w800, fontSize: 13))),
                            const Icon(Icons.chevron_right, color: accent4),
                          ]),
                        ),
                      ),
                    ),
                  ),
                const Spacer(),
                                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: panel,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 8))],
                    border: Border.all(color: accent.withValues(alpha: 0.2), width: 3),
                  ),
                  child: Column(children: [
                    const Text('🎮', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 6),
                    Text('${tr('level')} ${AppPrefs.level}', style: const TextStyle(color: accent, fontWeight: FontWeight.w800, letterSpacing: 1)),
                    const SizedBox(height: 6),
                    Text(tr('connect'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
                    const SizedBox(height: 8),
                    Text('$w×$h  •  $colors  🎨', style: const TextStyle(color: textSecondary, fontWeight: FontWeight.w600)),
                    Text('${tr('done')}: ${AppPrefs.completed}/$totalLevels', style: const TextStyle(color: textSecondary)),
                    Text('💡 ${AppPrefs.hints}', style: const TextStyle(color: textSecondary, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => _play(),
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 4,
                      ),
                      child: Text(tr('play'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                    ),
                  ]),
                ),
                const SizedBox(height: 12),
                _kidsBtn(Icons.grid_view_rounded, tr('levels'), accent5, () async {
                  final sel = await Navigator.push<int>(context, MaterialPageRoute(builder: (_) => const LevelsPage()));
                  if (sel != null) {
                    AppPrefs.level = sel;
                    await AppPrefs.save();
                    setState(() {});
                  }
                }),
                _kidsBtn(Icons.lightbulb_rounded, tr('hintsShop'), accent4, () => _openHintsShop()),
                _kidsBtn(Icons.bar_chart_rounded, tr('results'), accent3, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ResultsPage()));
                }),
                const Spacer(),
                Text(tr('offline'), textAlign: TextAlign.center, style: TextStyle(color: textSecondary.withValues(alpha: 0.7), fontSize: 11)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _kidsBtn(IconData icon, String label, Color c, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Material(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(children: [
              Icon(icon, color: c, size: 22),
              const SizedBox(width: 10),
              Expanded(child: Text(label, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700))),
              Icon(Icons.chevron_right, color: c),
            ]),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => HintsShopSheet(openWheel: openWheel, onChanged: () => setState(() {})),
    );
  }
}
class LevelsPage extends StatelessWidget {
  const LevelsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final cols = [accent, accent2, accent3, accent4, accent5];
    return Scaffold(
      appBar: AppBar(title: Text(tr('levelSelect'), style: const TextStyle(fontWeight: FontWeight.w800))),
      body: GridView.builder(
        padding: const EdgeInsets.all(14),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 8, mainAxisSpacing: 8),
        itemCount: totalLevels,
        itemBuilder: (_, i) {
          final n = i + 1;
          final unlocked = n <= AppPrefs.completed + 1;
          final c = cols[i % cols.length];
          return Material(
            color: unlocked ? c : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: unlocked ? () => Navigator.pop(context, n) : null,
              child: Center(child: Text('$n', style: TextStyle(color: unlocked ? Colors.white : Colors.grey, fontWeight: FontWeight.w900, fontSize: 14))),
            ),
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

class _HintsShopSheetState extends State<HintsShopSheet> with SingleTickerProviderStateMixin {
  late AnimationController _wheelCtrl;
  bool spinning = false;
  int? wheelResult;

  @override
  void initState() {
    super.initState();
    _wheelCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800));
    if (widget.openWheel && AppPrefs.canSpinWheel()) {
      Future.delayed(const Duration(milliseconds: 400), _spin);
    }
  }

  @override
  void dispose() {
    _wheelCtrl.dispose();
    super.dispose();
  }

  Future<void> _watchAd() async {
    final ok = await AdService.showRewarded();
    if (ok) {
      AppPrefs.hints += 3;
      await AppPrefs.save();
      widget.onChanged();
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('+3 ${tr('hint')} 💡'), backgroundColor: accent3));
      }
    }
  }

  Future<void> _spin() async {
    if (!AppPrefs.canSpinWheel() || spinning) return;
    setState(() { spinning = true; wheelResult = null; });
    final result = Random().nextInt(16);
    final turns = 4 + Random().nextDouble() * 2;
    final end = turns + result / 16.0;
    await _wheelCtrl.animateTo(end, duration: const Duration(milliseconds: 2800), curve: Curves.easeOutCubic);
    AppPrefs.hints += result;
    AppPrefs.lastWheelDay = AppPrefs.todayKey();
    await AppPrefs.save();
    widget.onChanged();
    if (mounted) setState(() { spinning = false; wheelResult = result; });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(3))),
        const SizedBox(height: 12),
        Text('🎁 ${tr('hintsShop')}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textPrimary)),
        Text('💡 ${AppPrefs.hints}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: accent4)),
        const SizedBox(height: 12),
        ListTile(leading: const Icon(Icons.storefront, color: accent), title: Text(tr('sellHints')), subtitle: Text(tr('coming')), onTap: null),
        ListTile(leading: const Icon(Icons.shopping_bag, color: accent2), title: Text(tr('buyHints')), subtitle: Text(tr('coming')), onTap: null),
        ListTile(leading: const Icon(Icons.ondemand_video, color: accent5), title: Text(tr('adHints')), onTap: _watchAd),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [accent4.withValues(alpha: 0.15), accent.withValues(alpha: 0.12)]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent4.withValues(alpha: 0.35), width: 2),
          ),
          child: Column(children: [
            Text('🎡 ${tr('wheel')}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            const SizedBox(height: 12),
            SizedBox(
              width: 180, height: 180,
              child: AnimatedBuilder(
                animation: _wheelCtrl,
                builder: (_, __) => Transform.rotate(
                  angle: _wheelCtrl.value * 2 * pi,
                  child: CustomPaint(painter: _WheelPainter()),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (wheelResult != null)
              Text('+$wheelResult 💡', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: accent3))
            else
              Text(AppPrefs.canSpinWheel() ? '0 – 15' : tr('wheelDone'), style: const TextStyle(color: textSecondary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: AppPrefs.canSpinWheel() && !spinning ? _spin : null,
              style: FilledButton.styleFrom(backgroundColor: accent4, foregroundColor: Colors.white, minimumSize: const Size(140, 44), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: Text(spinning ? '...' : tr('spin'), style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _WheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    const cols = [Color(0xFFFF5252), Color(0xFFFF9100), Color(0xFFFFD600), Color(0xFF69F0AE), Color(0xFF40C4FF), Color(0xFF7C4DFF), Color(0xFFFF4081), Color(0xFF18FFFF)];
    for (int i = 0; i < 16; i++) {
      final a0 = i * pi / 8 - pi / 2;
      final a1 = (i + 1) * pi / 8 - pi / 2;
      final path = Path()
        ..moveTo(c.dx, c.dy)
        ..arcTo(Rect.fromCircle(center: c, radius: r), a0, a1 - a0, false)
        ..close();
      canvas.drawPath(path, Paint()..color = cols[i % cols.length]);
      final mid = a0 + (a1 - a0) / 2;
      final tp = TextPainter(text: TextSpan(text: '$i', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)), textDirection: TextDirection.ltr)..layout();
      final ox = c.dx + cos(mid) * r * 0.7 - tp.width / 2;
      final oy = c.dy + sin(mid) * r * 0.7 - tp.height / 2;
      tp.paint(canvas, Offset(ox, oy));
    }
    canvas.drawCircle(c, 12, Paint()..color = Colors.white);
    canvas.drawCircle(c, 8, Paint()..color = accent);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final list = StatsStore.history;
    return Scaffold(
      appBar: AppBar(title: Text(tr('results'), style: const TextStyle(fontWeight: FontWeight.w800))),
      body: list.isEmpty
          ? Center(child: Text('⭐ ${tr('coming')}', style: const TextStyle(color: textSecondary, fontSize: 16)))
          : ListView(padding: const EdgeInsets.all(16), children: [
              _card('🏆 ${tr('done')}', '${AppPrefs.completed}'),
              _card('🎯 ${tr('won')}', '${AppPrefs.totalWins}'),
              _card('💡 ${tr('hint')}', '${AppPrefs.hints}'),
              const SizedBox(height: 10),
              ...list.map((s) => Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      title: Text('${tr('level')} ${s.level}', style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text('${tr('timeSpent')}: ${s.seconds} ${tr('sec')}\n${tr('hintsUsed')}: ${s.hintsUsed}\n${tr('decisionSpeed')}: ${s.avgDecisionMs.toStringAsFixed(0)} ${tr('ms')}'),
                      isThreeLine: true,
                    ),
                  )),
            ]),
    );
  }
  Widget _card(String t, String v) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(16), border: Border.all(color: accent.withValues(alpha: 0.2))),
        child: Row(children: [
          Expanded(child: Text(t, style: const TextStyle(fontWeight: FontWeight.w700))),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: accent)),
        ]),
      );
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
      appBar: AppBar(title: Text(tr('settings'), style: const TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        ListTile(
          title: Text(tr('language'), style: const TextStyle(fontWeight: FontWeight.w700)),
          leading: const Icon(Icons.language, color: accent2),
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
        SwitchListTile(title: Text(tr('sound')), value: AppPrefs.sound, activeThumbColor: accent, onChanged: (v) async {
          setState(() => AppPrefs.sound = v);
          await AppPrefs.save();
        }),
        SwitchListTile(title: Text(tr('effects')), value: AppPrefs.effects, activeThumbColor: accent2, onChanged: (v) async {
          setState(() => AppPrefs.effects = v);
          await AppPrefs.save();
        }),
        SwitchListTile(title: Text(tr('music')), value: AppPrefs.music, activeThumbColor: accent3, onChanged: (v) async {
          await MusicService.setEnabled(v);
          setState(() {});
        }),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.info_outline, color: accent5),
          title: Text(tr('about'), style: const TextStyle(fontWeight: FontWeight.w700)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage())),
        ),
      ]),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('about'), style: const TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Center(child: Container(
          width: 80, height: 80,
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [accent, accent2]), borderRadius: BorderRadius.circular(24)),
          child: const Icon(Icons.hub_rounded, size: 44, color: Colors.white),
        )),
        const SizedBox(height: 14),
        const Center(child: Text('NeoLoop', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900))),
        const SizedBox(height: 16),
        Text(tr('description'), style: const TextStyle(height: 1.5, fontSize: 15, color: textPrimary)),
        const SizedBox(height: 20),
        ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.apartment, color: accent), title: Text(tr('developer')), subtitle: const Text('VOSITA STUDIOS')),
        ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.public, color: accent2), title: Text(tr('country')), subtitle: const Text('Uzbekistan')),
      ]),
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
  bool paused = false;
  DateTime? startedAt;
  Duration pausedTotal = Duration.zero;
  DateTime? pauseStarted;
  final List<int> decisionTimes = [];
  DateTime? pathStartAt;

  int get n => data.width * data.height;
  Map<int, int> get endpoints => data.endpoints;

  int get elapsedSeconds {
    if (startedAt == null) return 0;
    var total = DateTime.now().difference(startedAt!);
    total -= pausedTotal;
    if (paused && pauseStarted != null) {
      total -= DateTime.now().difference(pauseStarted!);
    }
    return total.inSeconds.clamp(0, 99999);
  }

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
    paused = false;
    startedAt = DateTime.now();
    pausedTotal = Duration.zero;
    pauseStarted = null;
    decisionTimes.clear();
    pathStartAt = null;
    setState(() {});
  }

  void _pause() {
    if (paused || won) return;
    paused = true;
    pauseStarted = DateTime.now();
    setState(() {});
  }

  void _resume() {
    if (!paused) return;
    if (pauseStarted != null) {
      pausedTotal += DateTime.now().difference(pauseStarted!);
    }
    pauseStarted = null;
    paused = false;
    setState(() {});
  }

  void _showHowTo() {
    _pause();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: panel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('📖 ${tr('howTo')}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900)),
        content: SingleChildScrollView(child: Text(tr('howToBody'), style: const TextStyle(height: 1.5, fontSize: 15))),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _resume();
            },
            style: FilledButton.styleFrom(backgroundColor: accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _rebuild() {
    owner = List<int?>.filled(n, null);
    for (final e in paths.entries) {
      for (final c in e.value) {
        owner[c] = e.key;
      }
    }
  }
    void begin(int cell) {
    if (won || paused) return;
    final color = endpoints[cell];
    if (color == null) return;
    pathStartAt = DateTime.now();
    if (paths.containsKey(color)) {
      for (final c in paths[color]!) {
        owner[c] = null;
      }
      paths.remove(color);
    }
    active = color;
    draft = [cell];
    owner[cell] = color;
    setState(() {});
  }

  void moveTo(int cell) {
    if (active == null || draft.isEmpty || won || paused) return;
    final last = draft.last;
    if (cell == last) return;
    final w = data.width;
    final ax = last % w, ay = last ~/ w;
    final bx = cell % w, by = cell ~/ w;
    if ((ax - bx).abs() + (ay - by).abs() != 1) return;

    final idx = draft.indexOf(cell);
    if (idx >= 0) {
      for (final c in draft.sublist(idx + 1)) {
        owner[c] = null;
      }
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
      for (final c in draft) {
        owner[c] = null;
      }
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
    final seconds = elapsedSeconds;
    final avgDecision = decisionTimes.isEmpty ? 0.0 : decisionTimes.reduce((a, b) => a + b) / decisionTimes.length;

    StatsStore.add(LevelStats(level: widget.number, seconds: seconds, hintsUsed: hintsUsed, avgDecisionMs: avgDecision));
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
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => GamePage(number: widget.number + 1)));
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
    if (paused) return;
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('hintShown')), backgroundColor: accent3));
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
    final boardColor = boardColorForLevel(widget.number);
    final connected = paths.length;
    final filled = owner.where((o) => o != null).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${tr('level')} ${widget.number}', style: const TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(onPressed: _showHowTo, icon: const Icon(Icons.help_outline_rounded), tooltip: tr('howTo')),
          TextButton.icon(onPressed: useHint, icon: const Icon(Icons.lightbulb, size: 18), label: Text('$hintsLeft')),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFFFF8E7), Color(0xFFE8F5E9), Color(0xFFE3F2FD)]),
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(children: [
              Expanded(child: Text('${tr('connected')}: $connected/${data.colors}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
              Expanded(child: Text('${tr('filled')}: $filled/$n', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
              Expanded(child: Text('⏱ $elapsedSeconds ${tr('sec')}', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
            ]),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: AspectRatio(
                aspectRatio: data.width / data.height,
                child: LayoutBuilder(builder: (context, box) {
                  final cw = box.maxWidth / data.width;
                  final ch = box.maxHeight / data.height;
                  return GestureDetector(
                    onPanStart: (d) {
                      if (paused) return;
                      final c = _cellAt(d.localPosition, cw, ch);
                      if (c != null) begin(c);
                    },
                    onPanUpdate: (d) {
                      if (paused) return;
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
                        boardColor: boardColor,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  );
                }),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh),
                  label: Text(tr('reset')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textPrimary,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: BorderSide(color: accent2.withValues(alpha: 0.4), width: 2),
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
                    backgroundColor: accent4,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
class _WinDialog extends StatefulWidget {
  final int level, seconds, hintsUsed;
  final double avgDecisionMs;
  final VoidCallback onNext, onMenu;
  const _WinDialog({required this.level, required this.seconds, required this.hintsUsed, required this.avgDecisionMs, required this.onNext, required this.onMenu});
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
        widget.onMenu();
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text('🎉 ${tr('won')}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('${tr('level')} ${widget.level}', style: const TextStyle(color: textSecondary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _stat('⏱ ${tr('timeSpent')}', '${widget.seconds} ${tr('sec')}'),
        _stat('💡 ${tr('hintsUsed')}', '${widget.hintsUsed}'),
        _stat('⚡ ${tr('decisionSpeed')}', '${widget.avgDecisionMs.toStringAsFixed(0)} ${tr('ms')}'),
        const SizedBox(height: 10),
        Text('${tr('timerHint')} $left', style: const TextStyle(color: textSecondary, fontSize: 12)),
      ]),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Column(children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () { timer?.cancel(); widget.onNext(); },
              style: FilledButton.styleFrom(backgroundColor: accent3, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: Text(tr('next'), style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () { timer?.cancel(); widget.onMenu(); },
              style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: Text(tr('toMenu'), style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ],
    );
  }

  Widget _stat(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          Expanded(child: Text(k, style: const TextStyle(color: textSecondary))),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w800)),
        ]),
      );
}

class GridPainter extends CustomPainter {
  final int width, height;
  final Map<int, int> endpoints;
  final Map<int, List<int>> paths;
  final List<int> draft;
  final int? active;
  final List<int?> owner;
  final List<Color> colors;
  final Color boardColor;

  GridPainter({
    required this.width, required this.height, required this.endpoints,
    required this.paths, required this.draft, required this.active,
    required this.owner, required this.colors, required this.boardColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cw = size.width / width;
    final ch = size.height / height;
    final cell = min(cw, ch);

    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)),
      Paint()..color = boardColor,
    );

    final grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(x * cw + 1, y * ch + 1, cw - 2, ch - 2), const Radius.circular(4)),
          grid,
        );
      }
    }

    void drawPath(List<int> p, Color color) {
      if (p.isEmpty) return;
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = cell * 0.52
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final glow = Paint()
        ..color = color.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = cell * 0.8
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
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

    for (final e in endpoints.entries) {
      final c = e.key;
      final color = colors[e.value];
      final center = Offset((c % width + 0.5) * cw, (c ~/ width + 0.5) * ch);
      canvas.drawCircle(center, cell * 0.38, Paint()..color = color.withValues(alpha: 0.25));
      canvas.drawCircle(center, cell * 0.28, Paint()..color = color);
      canvas.drawCircle(center, cell * 0.12, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter old) => true;
}
