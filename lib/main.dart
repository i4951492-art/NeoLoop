// ignore_for_file: prefer_const_constructors, const_with_non_const
import 'splash.dart';
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Раскомментируй, когда добавишь пакет и музыку:
// import 'package:audioplayers/audioplayers.dart';

void main() => runApp(const NeoLoopApp());

const Color bg = Color(0xFFF7F4EF);           // мягкий молочный фон
const Color panel = Color(0xFFFFFFFF);        // белые карточки
const Color accent = Color(0xFF7BA3B8);       // спокойный голубовато-серый
const Color textPrimary = Color(0xFF2C3E50);
const Color textSecondary = Color(0xFF6B7C8A);
const int totalLevels = 60;

class AppPrefs {
  static const languages = ['ru', 'uz', 'en', 'uk', 'kk'];
  static String language = 'ru';
  static bool sound = true;
  static bool effects = true;
  static bool music = true;
  static int level = 1;
  static int completed = 0;

  static Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    language = p.getString('language') ?? 'ru';
    if (!languages.contains(language)) language = 'ru';
    sound = p.getBool('sound') ?? true;
    effects = p.getBool('effects') ?? true;
    music = p.getBool('music') ?? true;
    level = (p.getInt('level') ?? 1).clamp(1, totalLevels).toInt();
    completed = (p.getInt('completed') ?? 0).clamp(0, totalLevels).toInt();
  }

  static Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('language', language);
    await p.setBool('sound', sound);
    await p.setBool('effects', effects);
    await p.setBool('music', music);
    await p.setInt('level', level);
    await p.setInt('completed', completed);
  }
}

/// Простой сервис рекламы.
/// Здесь можно легко подключить AdMob, AppLovin, Yandex и т.д.
class AdService {
  static bool adsEnabled = true;

  /// Показать межстраничную рекламу (после уровня и т.п.)
  static Future<void> showInterstitial() async {
    if (!adsEnabled) return;
    // TODO: здесь вставь код своей рекламной сети
    // Пример для AdMob:
    // await InterstitialAd.load(...);
  }

  /// Показать баннер (если нужно)
  static Widget? banner() {
    if (!adsEnabled) return null;
    // TODO: верни виджет баннера своей сети
    return null;
  }
}

/// Фоновая музыка (спокойная).
/// Чтобы включить настоящую музыку:
/// 1. Добавь в pubspec.yaml: audioplayers: ^6.1.0
/// 2. Положи файл assets/music/calm.mp3
/// 3. Раскомментируй код ниже
class MusicService {
  // static final AudioPlayer _player = AudioPlayer();
  static bool _playing = false;

  static Future<void> start() async {
    if (!AppPrefs.music || _playing) return;
    // await _player.setReleaseMode(ReleaseMode.loop);
    // await _player.play(AssetSource('music/calm.mp3'));
    _playing = true;
  }
  class NeoLoopApp extends StatelessWidget {
  const NeoLoopApp({super.key});

  

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
    await MusicService.start();
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: accent)),
      );
    }
    return const HomePage();
  }
}

  static Future<void> stop() async {
    // await _player.stop();
    _playing = false;
  }

  static Future<void> setEnabled(bool value) async {
    AppPrefs.music = value;
    await AppPrefs.save();
    if (value) {
      await start();
    } else {
      await stop();
    }
  }
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const SplashPage(),   // ← загрузочный экран
    );
  }
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
    await MusicService.start();
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: accent)),
      );
    }
    return const HomePage();
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
    'next': 'ДАЛЕЕ',
    'won': 'Уровень пройден!',
    'moves': 'Ходов',
    'hintsUsed': 'Подсказок',
    'language': 'Язык',
    'sound': 'Звук',
    'effects': 'Эффекты',
    'music': 'Музыка',
    'done': 'Пройдено уровней',
    'offline': 'Офлайн • Прогресс сохраняется',
    'noHints': 'Подсказки закончились',
    'hintShown': 'Показан правильный путь',
    'developer': 'Разработчик',
    'country': 'Страна',
    'description':
        'NeoLoop — спокойная логическая головоломка. Соединяй пары цветных точек непрерывными линиями и заполняй всё поле. Уровни генерируются автоматически, сложность растёт постепенно.',
    'coming': 'Скоро в следующих обновлениях.',
    'levelSelect': 'Выбери уровень',
    'about': 'О приложении',
    'timerHint': 'Переход через',
  },
  'uz': {
    'tagline': 'Tinch mantiqiy boshqotirma',
    'play': 'O‘YNASH',
    'settings': 'Sozlamalar',
    'levels': 'Bosqichlar',
    'leaderboard': 'Yetakchilar',
    'duel': '1 ga 1 duel',
    'level': 'BOSQICH',
    'connect': 'Juftlarni ulang va maydonni to‘ldiring',
    'connected': 'Ulangan',
    'filled': 'To‘ldirilgan',
    'hint': 'Maslahat',
    'reset': 'Qayta',
    'next': 'KEYINGI',
    'won': 'Bosqich tugadi!',
    'moves': 'Yurishlar',
    'hintsUsed': 'Maslahatlar',
    'language': 'Til',
    'sound': 'Ovoz',
    'effects': 'Effektlar',
    'music': 'Musiqa',
    'done': 'Tugatilgan',
    'offline': 'Oflayn • Saqlanadi',
    'noHints': 'Maslahatlar tugadi',
    'hintShown': 'To‘g‘ri yo‘l ko‘rsatildi',
    'developer': 'Dasturchi',
    'country': 'Mamlakat',
    'description':
        'NeoLoop — tinch mantiqiy o‘yin. Rangli nuqtalarni chiziqlar bilan ulang va butun maydonni to‘ldiring.',
    'coming': 'Tez orada.',
    'levelSelect': 'Bosqichni tanlang',
    'about': 'Ilova haqida',
    'timerHint': 'O‘tish',
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
    'next': 'NEXT',
    'won': 'Level complete!',
    'moves': 'Moves',
    'hintsUsed': 'Hints',
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
    'description':
        'NeoLoop is a calm logic puzzle. Connect matching colored dots with continuous paths and fill the entire board.',
    'coming': 'Coming soon.',
    'levelSelect': 'Choose a level',
    'about': 'About',
    'timerHint': 'Continuing in',
  },
  'uk': {
    'tagline': 'Спокійна логічна головоломка',
    'play': 'ГРАТИ',
    'settings': 'Налаштування',
    'levels': 'Рівні',
    'leaderboard': 'Таблиця лідерів',
    'duel': 'Дуель 1 на 1',
    'level': 'РІВЕНЬ',
    'connect': 'З’єднай пари та заповни поле',
    'connected': 'З’єднано',
    'filled': 'Заповнено',
    'hint': 'Підказка',
    'reset': 'Спочатку',
    'next': 'ДАЛІ',
    'won': 'Рівень пройдено!',
    'moves': 'Ходів',
    'hintsUsed': 'Підказок',
    'language': 'Мова',
    'sound': 'Звук',
    'effects': 'Ефекти',
    'music': 'Музика',
    'done': 'Пройдено',
    'offline': 'Офлайн • Прогрес збережено',
    'noHints': 'Підказки закінчилися',
    'hintShown': 'Показано правильний шлях',
    'developer': 'Розробник',
    'country': 'Країна',
    'description':
        'NeoLoop — спокійна логічна головоломка. З’єднуй пари кольорових точок і заповнюй усе поле.',
    'coming': 'Незабаром.',
    'levelSelect': 'Оберіть рівень',
    'about': 'Про застосунок',
    'timerHint': 'Перехід через',
  },
  'kk': {
    'tagline': 'Тыныш логикалық ойын',
    'play': 'ОЙНАУ',
    'settings': 'Баптаулар',
    'levels': 'Деңгейлер',
    'leaderboard': 'Көшбасшылар',
    'duel': '1-ге 1',
    'level': 'ДЕҢГЕЙ',
    'connect': 'Жұптарды қосып, өрісті толтыр',
    'connected': 'Қосылды',
    'filled': 'Толтырылды',
    'hint': 'Кеңес',
    'reset': 'Қайта',
    'next': 'КЕЛЕСІ',
    'won': 'Деңгей аяқталды!',
    'moves': 'Жүрістер',
    'hintsUsed': 'Кеңестер',
    'language': 'Тіл',
    'sound': 'Дыбыс',
    'effects': 'Әсерлер',
    'music': 'Музыка',
    'done': 'Өтілген',
    'offline': 'Офлайн • Сақталады',
    'noHints': 'Кеңестер таусылды',
    'hintShown': 'Дұрыс жол көрсетілді',
    'developer': 'Әзірлеуші',
    'country': 'Ел',
    'description':
        'NeoLoop — тыныш логикалық ойын. Түсті нүктелерді сызықтармен қосып, бүкіл өрісті толтырыңыз.',
    'coming': 'Жақында.',
    'levelSelect': 'Деңгейді таңдаңыз',
    'about': 'Қосымша туралы',
    'timerHint': 'Өту',
  },
};

String tr(String key) =>
    strings[AppPrefs.language]?[key] ?? strings['en']![key] ?? key;
class LevelData {
  final int size, colors;
  final Map<int, int> endpoints;
  final List<List<int>> solution;
  const LevelData(this.size, this.colors, this.endpoints, this.solution);
}

class LevelGenerator {
  /// 1 уровень = 5×5, постепенно растёт, максимум 16×16
  static int sizeFor(int level) {
    final raw = 4 + ((level - 1) * 0.22).round();
    return raw.clamp(5, 16);
  }

  static double _t(int level) =>
      ((level.clamp(1, totalLevels) - 1) / (totalLevels - 1)).toDouble();

  static int colorCount(int level) {
    final size = sizeFor(level);
    final maxColors = (size * size / 4).floor();
    final raw = (3 + 8 * _t(level)).round();
    return raw.clamp(3, maxColors);
  }

  static int shuffleIterations(int level) =>
      (50 + 18000 * _t(level)).round();

  static LevelData generate(int level) {
    final size = sizeFor(level);
    final rnd = Random(level * 7919 + 104729);
    final n = size * size;
    final path = <int>[];
    for (int y = 0; y < size; y++) {
      for (int i = 0; i < size; i++) {
        final x = y.isEven ? i : size - 1 - i;
        path.add(y * size + x);
      }
    }
    final pos = List<int>.filled(n, 0);
    for (int i = 0; i < n; i++) {
      pos[path[i]] = i;
    }

    void reverse(int a, int b) {
      while (a < b) {
        final x = path[a], y = path[b];
        path[a] = y;
        path[b] = x;
        pos[y] = a;
        pos[x] = b;
        a++;
        b--;
      }
    }

    for (int it = 0; it < shuffleIterations(level); it++) {
      final head = rnd.nextBool();
      final e = head ? path.first : path.last;
      final x = e % size, y = e ~/ size;
      final nbs = <int>[
        if (x > 0) e - 1,
        if (x < size - 1) e + 1,
        if (y > 0) e - size,
        if (y < size - 1) e + size,
      ];
      final j = pos[nbs[rnd.nextInt(nbs.length)]];
      if (head) {
        if (j != 1) reverse(0, j - 1);
      } else {
        if (j != n - 2) reverse(j + 1, n - 1);
      }
    }

    final k = colorCount(level);
    final minSeg = size <= 8 ? 3 : 4;
    final weights =
        List<double>.generate(k, (_) => 0.4 + rnd.nextDouble() * 1.6);
    final sum = weights.fold<double>(0, (a, b) => a + b);
    final rest = n - k * minSeg;
    final lengths = List<int>.generate(
        k, (i) => minSeg + (rest * weights[i] / sum).floor());
    var left = n - lengths.fold<int>(0, (a, b) => a + b);
    while (left-- > 0) {
      lengths[rnd.nextInt(k)]++;
    }

    final solutions = <List<int>>[];
    final endpoints = <int, int>{};
    var start = 0;
    for (int i = 0; i < k; i++) {
      final segment = path.sublist(start, start + lengths[i]);
      start += lengths[i];
      solutions.add(segment);
      endpoints[segment.first] = i;
      endpoints[segment.last] = i;
    }
    return LevelData(size, k, endpoints, solutions);
  }
}

List<Color> buildPalette(int n) => List.generate(
      n,
      (i) => HSVColor.fromAHSV(
        1,
        (i * 137.508) % 360,
        0.42,
        0.78,
      ).toColor(),
    );

Color glassColorForLevel(int level) {
  // мягкий молочный оттенок, слегка меняется
  final hue = (level * 11.0) % 40 + 30;
  return HSVColor.fromAHSV(1, hue, 0.08, 0.96).toColor();
}
class NeoLoopApp extends StatelessWidget {
  const NeoLoopApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'NeoLoop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: bg,
          colorScheme: ColorScheme.fromSeed(
            seedColor: accent,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: bg,
            foregroundColor: textPrimary,
            elevation: 0,
          ),
        ),
        home: const BootPage(),
      );
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
    await MusicService.start();
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: accent)),
      );
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
  Future<void> _play() async {
    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => GamePage(number: AppPrefs.level)),
    );
    if (result != null && mounted) {
      AppPrefs.completed = max(AppPrefs.completed, result);
      AppPrefs.level = min(totalLevels, result + 1);
      await AppPrefs.save();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = LevelGenerator.sizeFor(AppPrefs.level);
    final colors = LevelGenerator.colorCount(AppPrefs.level);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.hub_rounded,
                      size: 28,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NeoLoop',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          tr('tagline'),
                          style: const TextStyle(
                            color: textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsPage(),
                        ),
                      );
                      setState(() {});
                    },
                    icon: const Icon(Icons.settings_outlined, color: textSecondary),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: panel,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(Icons.grid_4x4_rounded,
                        size: 56, color: accent.withValues(alpha: 0.85)),
                    const SizedBox(height: 10),
                    Text(
                      '${tr('level')} ${AppPrefs.level}',
                      style: const TextStyle(
                        color: accent,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      tr('connect'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$size×$size  •  $colors',
                      style: const TextStyle(color: textSecondary),
                    ),
                    Text(
                      '${tr('done')}: ${AppPrefs.completed}/$totalLevels',
                      style: const TextStyle(color: textSecondary),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _play,
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        tr('play'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _MenuButton(
                icon: Icons.grid_view_rounded,
                label: tr('levels'),
                onTap: () async {
                  final selected = await Navigator.push<int>(
                    context,
                    MaterialPageRoute(builder: (_) => const LevelsPage()),
                  );
                  if (selected != null) {
                    AppPrefs.level = selected;
                    await AppPrefs.save();
                    setState(() {});
                  }
                },
              ),
              _MenuButton(
                icon: Icons.emoji_events_outlined,
                label: tr('leaderboard'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InfoPage(
                      titleKey: 'leaderboard',
                      icon: Icons.emoji_events_outlined,
                      bodyKey: 'coming',
                    ),
                  ),
                ),
              ),
              _MenuButton(
                icon: Icons.sports_esports_outlined,
                label: tr('duel'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InfoPage(
                      titleKey: 'duel',
                      icon: Icons.bolt_outlined,
                      bodyKey: 'coming',
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                tr('offline'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textSecondary.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20, color: textSecondary),
        label: Text(label, style: const TextStyle(color: textPrimary)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
          minimumSize: const Size.fromHeight(46),
          alignment: Alignment.centerLeft,
          backgroundColor: panel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: totalLevels,
        itemBuilder: (context, i) {
          final n = i + 1;
          final unlocked = n <= AppPrefs.completed + 1;
          return FilledButton(
            onPressed: unlocked ? () => Navigator.pop(context, n) : null,
            style: FilledButton.styleFrom(
              backgroundColor:
                  n == AppPrefs.level ? accent : panel,
              foregroundColor:
                  n == AppPrefs.level ? Colors.white : textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('$n'),
          );
        },
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
                DropdownMenuItem(value: 'ru', child: Text('🇷🇺 Русский')),
                DropdownMenuItem(value: 'uz', child: Text('🇺🇿 O‘zbekcha')),
                DropdownMenuItem(value: 'en', child: Text('🇬🇧 English')),
                DropdownMenuItem(value: 'uk', child: Text('🇺🇦 Українська')),
                DropdownMenuItem(value: 'kk', child: Text('🇰🇿 Қазақша')),
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
          const SizedBox(height: 12),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline, color: accent),
            title: Text(tr('about')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutPage()),
              );
            },
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
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.hub_rounded, size: 42, color: accent),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'NeoLoop',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            tr('description'),
            style: const TextStyle(
              fontSize: 15,
              height: 1.55,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 28),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.person_outline, color: accent),
            title: Text(tr('developer')),
            subtitle: const Text('Saidov Islom'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.flag_outlined, color: accent),
            title: Text(tr('country')),
            subtitle: const Text('Uzbekistan'),
          ),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.info_outline, color: accent),
            title: Text('Version'),
            subtitle: Text('1.3.0'),
          ),
        ],
      ),
    );
  }
}
class InfoPage extends StatelessWidget {
  final String titleKey;
  final String bodyKey;
  final IconData icon;

  const InfoPage({
    super.key,
    required this.titleKey,
    required this.icon,
    required this.bodyKey,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr(titleKey))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 60, color: accent.withValues(alpha: 0.85)),
              const SizedBox(height: 18),
              Text(
                tr(bodyKey),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: textSecondary,
                ),
              ),
            ],
          ),
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
  static const maxHints = 3;

  late final LevelData data = LevelGenerator.generate(widget.number);
  late final List<Color> colors = buildPalette(data.colors);
  late final int n = data.size;
  late final List<int> owner = List<int>.filled(n * n, -1);
  late final Color glassColor = glassColorForLevel(widget.number);

  final Map<int, List<int>> paths = {};
  int? active;
  List<int> draft = [];
  int moves = 0;
  int hintsLeft = maxHints;
  bool won = false;

  Map<int, int> get endpoints => data.endpoints;

  void _rebuild() {
    owner.fillRange(0, owner.length, -1);
    for (final entry in paths.entries) {
      for (final c in entry.value) {
        owner[c] = entry.key;
      }
    }
    if (active != null) {
      for (final c in draft) {
        owner[c] = active!;
      }
    }
  }

  bool _connected(int k) {
    final p = paths[k];
    return p != null &&
        p.length >= 2 &&
        endpoints[p.first] == k &&
        endpoints[p.last] == k;
  }

  int get connectedCount =>
      List.generate(data.colors, (i) => i).where(_connected).length;

  int get filledPercent =>
      (owner.where((v) => v >= 0).length * 100 / (n * n)).floor();

  void _cut(int k, int cell) {
    final p = paths[k];
    if (p == null) return;
    final i = p.indexOf(cell);
    if (i < 2) {
      paths.remove(k);
    } else {
      paths[k] = p.sublist(0, i);
    }
  }

  void begin(int c) {
    if (won) return;
    if (endpoints.containsKey(c)) {
      setState(() {
        final k = endpoints[c]!;
        paths.remove(k);
        active = k;
        draft = [c];
        moves++;
        _rebuild();
      });
    } else if (owner[c] >= 0 && paths.containsKey(owner[c])) {
      setState(() {
        final k = owner[c];
        final p = paths[k]!;
        final i = p.indexOf(c);
        draft = p.sublist(0, i + 1);
        paths.remove(k);
        active = k;
        moves++;
        _rebuild();
      });
    }
  }

  void moveTo(int c) {
    if (won || active == null || draft.isEmpty) return;
    final last = draft.last;
    if (c == last) return;

    if (draft.length >= 2 && c == draft[draft.length - 2]) {
      setState(() {
        draft.removeLast();
        _rebuild();
      });
      return;
    }

    if (draft.contains(c)) return;

    final distance =
        (last % n - c % n).abs() + (last ~/ n - c ~/ n).abs();
    if (distance != 1) return;
    if (endpoints.containsKey(c) && endpoints[c] != active) return;

    var finished = false;
    setState(() {
      final other = owner[c];
      if (other >= 0 && other != active) _cut(other, c);
      draft.add(c);
      if (endpoints[c] == active) {
        paths[active!] = List.of(draft);
        active = null;
        draft = [];
        finished = true;
      }
      _rebuild();
    });
    if (finished) _checkWin();
  }

  void endDrag() {
    if (active == null) return;
    setState(() {
      if (draft.length >= 2) paths[active!] = List.of(draft);
      active = null;
      draft = [];
      _rebuild();
    });
  }

  bool _matchesSolution(int k) {
    final p = paths[k];
    if (p == null) return false;
    final s = data.solution[k];
    if (p.length != s.length) return false;

    bool same(List<int> a, List<int> b) {
      for (int i = 0; i < a.length; i++) {
        if (a[i] != b[i]) return false;
      }
      return true;
    }

    return same(p, s) || same(p, s.reversed.toList());
  }

  void hint() {
    if (won) return;
    if (hintsLeft <= 0) {
      _snack(tr('noHints'));
      return;
    }
    final missing = [
      for (int k = 0; k < data.colors; k++)
        if (!_matchesSolution(k)) k
    ];
    if (missing.isEmpty) return;

    final k = missing[Random().nextInt(missing.length)];
    final sol = data.solution[k];
    final set = sol.toSet();

    setState(() {
      active = null;
      draft = [];
      for (final other in paths.keys.toList()) {
        if (other == k) continue;
        final p = paths[other]!;
        final i = p.indexWhere(set.contains);
        if (i >= 0) {
          if (i < 2) {
            paths.remove(other);
          } else {
            paths[other] = p.sublist(0, i);
          }
        }
      }
      paths[k] = List.of(sol);
      hintsLeft--;
      _rebuild();
    });
    _snack('${tr('hintShown')} • $hintsLeft');
    _checkWin();
  }

  void _snack(String s) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(s)));
  }

  void reset() {
    setState(() {
      paths.clear();
      active = null;
      draft = [];
      moves = 0;
      hintsLeft = maxHints;
      _rebuild();
    });
  }
    void _checkWin() {
    if (won) return;
    if (!List.generate(data.colors, (i) => i).every(_connected) ||
        owner.contains(-1)) {
      return;
    }
    won = true;

    // Можно показать рекламу перед переходом
    AdService.showInterstitial();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _WinDialog(
        moves: moves,
        hintsUsed: maxHints - hintsLeft,
        onContinue: () {
          Navigator.pop(ctx);
          Navigator.pop(context, widget.number);
        },
      ),
    );
  }

  int? _cellAt(Offset p, double cell) {
    final x = (p.dx / cell).floor();
    final y = (p.dy / cell).floor();
    if (x < 0 || x >= n || y < 0 || y >= n) return null;
    return y * n + x;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${tr('level')} ${widget.number}'),
        actions: [
          IconButton(
            tooltip: tr('hint'),
            onPressed: hint,
            icon: const Icon(Icons.lightbulb_outline),
          ),
          IconButton(
            tooltip: tr('reset'),
            onPressed: reset,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Text(
              '${tr('connect')}\n'
              '${tr('connected')}: $connectedCount/${data.colors} • '
              '${tr('filled')}: $filledPercent%',
              textAlign: TextAlign.center,
              style: const TextStyle(color: textSecondary),
            ),
          ),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: LayoutBuilder(
                    builder: (context, box) {
                      final cell = box.maxWidth / n;
                      return GestureDetector(
                        onPanStart: (d) {
                          final c = _cellAt(d.localPosition, cell);
                          if (c != null) begin(c);
                        },
                        onPanUpdate: (d) {
                          final c = _cellAt(d.localPosition, cell);
                          if (c != null) moveTo(c);
                        },
                        onPanEnd: (_) => endDrag(),
                        onPanCancel: endDrag,
                        child: CustomPaint(
                          painter: GridPainter(
                            n: n,
                            endpoints: endpoints,
                            paths: paths,
                            draft: draft,
                            active: active,
                            owner: owner,
                            colors: colors,
                            glassColor: glassColor,
                          ),
                          child: const SizedBox.expand(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: reset,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: Text(tr('reset')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textSecondary,
                      side: BorderSide(
                          color: Colors.black.withValues(alpha: 0.08)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: hint,
                    icon: const Icon(Icons.lightbulb_outline, size: 18),
                    label: Text('${tr('hint')} ($hintsLeft)'),
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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

/// Диалог победы: после 3 секунд автоматически переходит дальше
class _WinDialog extends StatefulWidget {
  final int moves;
  final int hintsUsed;
  final VoidCallback onContinue;

  const _WinDialog({
    required this.moves,
    required this.hintsUsed,
    required this.onContinue,
  });

  @override
  State<_WinDialog> createState() => _WinDialogState();
}

class _WinDialogState extends State<_WinDialog> {
  int _secondsLeft = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        t.cancel();
        widget.onContinue(); // автоматический переход
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: panel,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        tr('won'),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${tr('moves')}: ${widget.moves}\n'
            '${tr('hintsUsed')}: ${widget.hintsUsed}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: textSecondary),
          ),
          const SizedBox(height: 18),
          Text(
            '$_secondsLeft',
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w300,
              color: accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${tr('timerHint')} $_secondsLeft',
            style: TextStyle(
              fontSize: 13,
              color: textSecondary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton(
          onPressed: () {
            _timer?.cancel();
            widget.onContinue();
          },
          style: FilledButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            minimumSize: const Size(140, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(tr('next')),
        ),
      ],
    );
  }
}
class GridPainter extends CustomPainter {
  final int n;
  final Map<int, int> endpoints;
  final Map<int, List<int>> paths;
  final List<int> draft;
  final int? active;
  final List<int> owner;
  final List<Color> colors;
  final Color glassColor;

  GridPainter({
    required this.n,
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
    final cell = size.width / n;

    // Молочное полупрозрачное стекло
    final bgPaint = Paint()..color = glassColor.withValues(alpha: 0.55);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(14),
      ),
      bgPaint,
    );

    // Лёгкая клетчатость
    final checker = Paint()..style = PaintingStyle.fill;
    for (int y = 0; y < n; y++) {
      for (int x = 0; x < n; x++) {
        checker.color = (x + y).isEven
            ? Colors.white.withValues(alpha: 0.25)
            : Colors.black.withValues(alpha: 0.03);
        canvas.drawRect(
          Rect.fromLTWH(x * cell, y * cell, cell, cell),
          checker,
        );
      }
    }

    // Более толстые и мягкие линии сетки
    final grid = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    for (int i = 0; i <= n; i++) {
      final pos = i * cell;
      canvas.drawLine(Offset(pos, 0), Offset(pos, size.height), grid);
      canvas.drawLine(Offset(0, pos), Offset(size.width, pos), grid);
    }

    void drawPath(List<int> p, Color color) {
      if (p.isEmpty) return;
      final paint = Paint()
        ..color = color.withValues(alpha: 0.88)
        ..style = PaintingStyle.stroke
        ..strokeWidth = cell * 0.58   // чуть шире
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final glow = Paint()
        ..color = color.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = cell * 0.85
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      final path = Path();
      Offset center(int c) =>
          Offset((c % n + 0.5) * cell, (c ~/ n + 0.5) * cell);

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
      final center = Offset((c % n + 0.5) * cell, (c ~/ n + 0.5) * cell);

      canvas.drawCircle(
        center,
        cell * 0.38,
        Paint()..color = color.withValues(alpha: 0.18),
      );
      canvas.drawCircle(center, cell * 0.29, Paint()..color = color);
      canvas.drawCircle(
        center,
        cell * 0.12,
        Paint()..color = Colors.white.withValues(alpha: 0.7),
      );
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter old) => true;
}
