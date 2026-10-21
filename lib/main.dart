// ignore_for_file: prefer_const_constructors, const_with_non_const
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const NeoLoopApp());

const Color bg = Color(0xFF0B1426);
const Color panel = Color(0xFF152238);
const Color accent = Color(0xFF7EC8E3);
const int totalLevels = 30;

class AppPrefs {
  static const languages = ['ru', 'uz', 'en', 'uk', 'kk'];
  static String language = 'ru';
  static bool sound = true;
  static bool effects = true;
  static int level = 1;
  static int completed = 0;

  static Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    language = p.getString('language') ?? 'ru';
    if (!languages.contains(language)) language = 'ru';
    sound = p.getBool('sound') ?? true;
    effects = p.getBool('effects') ?? true;
    level = (p.getInt('level') ?? 1).clamp(1, totalLevels).toInt();
    completed = (p.getInt('completed') ?? 0).clamp(0, totalLevels).toInt();
  }

  static Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('language', language);
    await p.setBool('sound', sound);
    await p.setBool('effects', effects);
    await p.setInt('level', level);
    await p.setInt('completed', completed);
  }
}

const Map<String, Map<String, String>> strings = {
  'ru': {
    'tagline': 'Соединяй цвета. Заполняй поле.',
    'play': 'ИГРАТЬ',
    'settings': 'Настройки',
    'levels': 'Уровни',
    'leaderboard': 'Таблица лидеров',
    'duel': 'Дуэль 1 на 1',
    'level': 'УРОВЕНЬ',
    'connect': 'Соедини пары и заполни все клетки',
    'connected': 'Соединено',
    'filled': 'Заполнено',
    'hint': 'Подсказка',
    'reset': 'Сначала',
    'next': 'ДАЛЕЕ',
    'won': 'Уровень пройден!',
    'moves': 'Ходов',
    'hintsUsed': 'Подсказок использовано',
    'language': 'Язык',
    'sound': 'Звук',
    'effects': 'Эффекты',
    'done': 'Пройдено уровней',
    'offline': 'Офлайн • Прогресс сохраняется',
    'noHints': 'Подсказки закончились',
    'hintShown': 'Показан правильный путь',
    'developer': 'Разработчик',
    'country': 'Страна разработки',
    'description':
        'NeoLoop — логическая головоломка, в которой игрок соединяет пары цветных точек непрерывными линиями и заполняет всё поле. Уровни создаются автоматически, а сложность растёт по мере прохождения.',
    'coming': 'Скоро появится в следующих обновлениях.',
    'levelSelect': 'Выбери уровень',
    'about': 'О проекте',
    'timerHint': 'Нажми, чтобы перейти дальше',
  },
  'uz': {
    'tagline': 'Ranglarni ulang. Maydonni to‘ldiring.',
    'play': 'O‘YNASH',
    'settings': 'Sozlamalar',
    'levels': 'Bosqichlar',
    'leaderboard': 'Yetakchilar jadvali',
    'duel': '1 ga 1 duel',
    'level': 'BOSQICH',
    'connect': 'Juft ranglarni ulang va barcha kataklarni to‘ldiring',
    'connected': 'Ulangan',
    'filled': 'To‘ldirilgan',
    'hint': 'Maslahat',
    'reset': 'Qayta boshlash',
    'next': 'KEYINGI',
    'won': 'Bosqich tugadi!',
    'moves': 'Yurishlar',
    'hintsUsed': 'Ishlatilgan maslahatlar',
    'language': 'Til',
    'sound': 'Ovoz',
    'effects': 'Effektlar',
    'done': 'Tugatilgan bosqichlar',
    'offline': 'Oflayn • Jarayon saqlanadi',
    'noHints': 'Maslahatlar tugadi',
    'hintShown': 'To‘g‘ri yo‘l ko‘rsatildi',
    'developer': 'Dasturchi',
    'country': 'Ishlab chiqilgan mamlakat',
    'description':
        'NeoLoop — mantiqiy boshqotirma: o‘yinchi bir xil rangdagi nuqtalarni uzluksiz chiziqlar bilan ulab, butun maydonni to‘ldiradi.',
    'coming': 'Keyingi yangilanishlarda paydo bo‘ladi.',
    'levelSelect': 'Bosqichni tanlang',
    'about': 'Loyiha haqida',
    'timerHint': 'Davom etish uchun bosing',
  },
  'en': {
    'tagline': 'Connect colors. Fill the board.',
    'play': 'PLAY',
    'settings': 'Settings',
    'levels': 'Levels',
    'leaderboard': 'Leaderboard',
    'duel': '1 vs 1 Duel',
    'level': 'LEVEL',
    'connect': 'Connect pairs and fill every cell',
    'connected': 'Connected',
    'filled': 'Filled',
    'hint': 'Hint',
    'reset': 'Restart',
    'next': 'NEXT',
    'won': 'Level complete!',
    'moves': 'Moves',
    'hintsUsed': 'Hints used',
    'language': 'Language',
    'sound': 'Sound',
    'effects': 'Effects',
    'done': 'Levels completed',
    'offline': 'Offline • Progress saved',
    'noHints': 'No hints left',
    'hintShown': 'A correct path was revealed',
    'developer': 'Developer',
    'country': 'Country of development',
    'description':
        'NeoLoop is a logic puzzle where players connect matching colored dots with continuous paths and fill the entire board.',
    'coming': 'Coming in a future update.',
    'levelSelect': 'Choose a level',
    'about': 'About',
    'timerHint': 'Tap to continue',
  },
  'uk': {
    'tagline': 'З’єднуй кольори. Заповнюй поле.',
    'play': 'ГРАТИ',
    'settings': 'Налаштування',
    'levels': 'Рівні',
    'leaderboard': 'Таблиця лідерів',
    'duel': 'Дуель 1 на 1',
    'level': 'РІВЕНЬ',
    'connect': 'З’єднай пари та заповни всі клітинки',
    'connected': 'З’єднано',
    'filled': 'Заповнено',
    'hint': 'Підказка',
    'reset': 'Спочатку',
    'next': 'ДАЛІ',
    'won': 'Рівень пройдено!',
    'moves': 'Ходів',
    'hintsUsed': 'Використано підказок',
    'language': 'Мова',
    'sound': 'Звук',
    'effects': 'Ефекти',
    'done': 'Пройдено рівнів',
    'offline': 'Офлайн • Прогрес збережено',
    'noHints': 'Підказки закінчилися',
    'hintShown': 'Показано правильний шлях',
    'developer': 'Розробник',
    'country': 'Країна розробки',
    'description':
        'NeoLoop — логічна головоломка, у якій гравець з’єднує пари кольорових точок безперервними лініями та заповнює все поле.',
    'coming': 'З’явиться в майбутніх оновленнях.',
    'levelSelect': 'Оберіть рівень',
    'about': 'Про проєкт',
    'timerHint': 'Натисни, щоб продовжити',
  },
  'kk': {
    'tagline': 'Түстерді қос. Өрісті толтыр.',
    'play': 'ОЙНАУ',
    'settings': 'Баптаулар',
    'levels': 'Деңгейлер',
    'leaderboard': 'Көшбасшылар кестесі',
    'duel': '1-ге 1 жекпе-жек',
    'level': 'ДЕҢГЕЙ',
    'connect': 'Жұптарды қосып, барлық ұяшықты толтыр',
    'connected': 'Қосылды',
    'filled': 'Толтырылды',
    'hint': 'Кеңес',
    'reset': 'Қайта бастау',
    'next': 'КЕЛЕСІ',
    'won': 'Деңгей аяқталды!',
    'moves': 'Жүрістер',
    'hintsUsed': 'Қолданылған кеңестер',
    'language': 'Тіл',
    'sound': 'Дыбыс',
    'effects': 'Әсерлер',
    'done': 'Өтілген деңгейлер',
    'offline': 'Офлайн • Үдеріс сақталады',
    'noHints': 'Кеңестер таусылды',
    'hintShown': 'Дұрыс жол көрсетілді',
    'developer': 'Әзірлеуші',
    'country': 'Әзірленген ел',
    'description':
        'NeoLoop — ойыншы бір түсті нүктелерді үздіксіз сызықтармен қосып, бүкіл өрісті толтыратын логикалық басқатырғыш.',
    'coming': 'Келесі жаңартуларда қосылады.',
    'levelSelect': 'Деңгейді таңдаңыз',
    'about': 'Жоба туралы',
    'timerHint': 'Жалғастыру үшін басыңыз',
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
  static int sizeFor(int level) => (4 + level).clamp(5, 30);

  static double _t(int level) =>
      ((level.clamp(1, totalLevels) - 1) / (totalLevels - 1)).toDouble();

  static int colorCount(int level) {
    final size = sizeFor(level);
    final maxColors = (size * size / 4).floor();
    final raw = (3 + 9 * _t(level)).round();
    return raw.clamp(3, maxColors);
  }

  static int shuffleIterations(int level) =>
      (60 + 22000 * _t(level)).round();

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
        0.55,
        0.92,
      ).toColor(),
    );

Color glassColorForLevel(int level) {
  final hue = (level * 27.0) % 360;
  return HSVColor.fromAHSV(1, hue, 0.25, 0.35).toColor();
}
class NeoLoopApp extends StatelessWidget {
  const NeoLoopApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'NeoLoop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: bg,
          colorScheme: ColorScheme.fromSeed(
            seedColor: accent,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          accent.withValues(alpha: 0.9),
                          const Color(0xFF9B8CFF).withValues(alpha: 0.85),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.25),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.hub_rounded,
                      size: 30,
                      color: Colors.white,
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
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                        Text(
                          tr('tagline'),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 12,
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
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: panel,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.grid_4x4_rounded,
                        size: 64, color: accent.withValues(alpha: 0.9)),
                    const SizedBox(height: 8),
                    Text(
                      '${tr('level')} ${AppPrefs.level}',
                      style: TextStyle(
                        color: accent,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tr('connect'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$size×$size  •  $colors',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                    Text(
                      '${tr('done')}: ${AppPrefs.completed}/$totalLevels',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _play,
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: bg,
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
                  color: Colors.white.withValues(alpha: 0.3),
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
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white.withValues(alpha: 0.9),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          minimumSize: const Size.fromHeight(46),
          alignment: Alignment.centerLeft,
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
                  n == AppPrefs.level ? bg : Colors.white70,
              shape:const RoundedRectangleBorder(
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
            leading: const Icon(Icons.language),
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
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          Text(
            tr('about'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            tr('description'),
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.person_outline, size: 22),
            title: Text(tr('developer')),
            subtitle: const Text('Saidov Islom'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.flag_outlined, size: 22),
            title: Text(tr('country')),
            subtitle: const Text('Uzbekistan'),
          ),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.info_outline, size: 22),
            title: Text('Version'),
            subtitle: Text('1.2.0'),
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
              Icon(icon, size: 64, color: accent.withValues(alpha: 0.9)),
              const SizedBox(height: 18),
              Text(
                tr(bodyKey),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.75),
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
        onTimeout: () {
          Navigator.pop(ctx);
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
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: const EdgeInsets.all(10),
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
                      foregroundColor: Colors.white70,
                      side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.15)),
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
                      backgroundColor: accent.withValues(alpha: 0.9),
                      foregroundColor: bg,
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

class _WinDialog extends StatefulWidget {
  final int moves;
  final int hintsUsed;
  final VoidCallback onContinue;
  final VoidCallback onTimeout;

  const _WinDialog({
    required this.moves,
    required this.hintsUsed,
    required this.onContinue,
    required this.onTimeout,
  });

  @override
  State<_WinDialog> createState() => _WinDialogState();
}

class _WinDialogState extends State<_WinDialog> {
  int _secondsLeft = 3;
  Timer? _timer;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        t.cancel();
        if (!_pressed) widget.onTimeout();
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
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${tr('moves')}: ${widget.moves}\n'
            '${tr('hintsUsed')}: ${widget.hintsUsed}',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Text(
            '$_secondsLeft',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w300,
              color: accent.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            tr('timerHint'),
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton(
          onPressed: _secondsLeft > 0
              ? () {
                  _pressed = true;
                  _timer?.cancel();
                  widget.onContinue();
                }
              : null,
          style: FilledButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: bg,
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

    final bgPaint = Paint()..color = glassColor.withValues(alpha: 0.22);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(12),
      ),
      bgPaint,
    );

    final checker = Paint()..style = PaintingStyle.fill;
    for (int y = 0; y < n; y++) {
      for (int x = 0; x < n; x++) {
        if ((x + y).isEven) {
          checker.color = Colors.white.withValues(alpha: 0.04);
        } else {
          checker.color = Colors.black.withValues(alpha: 0.06);
        }
        canvas.drawRect(
          Rect.fromLTWH(x * cell, y * cell, cell, cell),
          checker,
        );
      }
    }

    final grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (int i = 0; i <= n; i++) {
      final pos = i * cell;
      canvas.drawLine(Offset(pos, 0), Offset(pos, size.height), grid);
      canvas.drawLine(Offset(0, pos), Offset(size.width, pos), grid);
    }

    void drawPath(List<int> p, Color color) {
      if (p.isEmpty) return;
      final paint = Paint()
        ..color = color.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = cell * 0.52
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final glow = Paint()
        ..color = color.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = cell * 0.8
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

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

    for (final e in endpoints.entries) {
      final c = e.key;
      final color = colors[e.value];
      final center = Offset((c % n + 0.5) * cell, (c ~/ n + 0.5) * cell);

      canvas.drawCircle(
        center,
        cell * 0.36,
        Paint()..color = color.withValues(alpha: 0.18),
      );
      canvas.drawCircle(center, cell * 0.27, Paint()..color = color);
      canvas.drawCircle(
        center,
        cell * 0.11,
        Paint()..color = bg.withValues(alpha: 0.7),
      );
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter old) => true;
}

