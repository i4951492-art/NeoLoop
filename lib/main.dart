name: neoloop
description: NeoLoop - logic puzzle game
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.3.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
    import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const NeoLoopApp());

const Color bg = Color(0xFF061226);
const Color panel = Color(0xFF0C1E39);
const Color cyan = Color(0xFF38D8FF);
const int totalLevels = 30;
const int boardSize = 15;

class AppPrefs {
  static const languages = ['ru', 'uz', 'en', 'uk', 'kk'];
  static String language = 'ru';
  static bool sound = true;
  static bool effects = true;
  static bool adsEnabled = true;
  static int level = 1;
  static int completed = 0;

  static Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    language = p.getString('language') ?? 'ru';
    if (!languages.contains(language)) language = 'ru';
    sound = p.getBool('sound') ?? true;
    effects = p.getBool('effects') ?? true;
    adsEnabled = p.getBool('adsEnabled') ?? true;
    level = (p.getInt('level') ?? 1).clamp(1, totalLevels).toInt();
    completed = (p.getInt('completed') ?? 0).clamp(0, totalLevels).toInt();
  }

  static Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('language', language);
    await p.setBool('sound', sound);
    await p.setBool('effects', effects);
    await p.setBool('adsEnabled', adsEnabled);
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
    'about': 'О проекте',
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
    'ads': 'Реклама включена',
    'done': 'Пройдено уровней',
    'offline': 'Офлайн • Прогресс сохраняется',
    'noHints': 'Подсказки закончились',
    'hintShown': 'Показан правильный путь',
    'developer': 'Разработчик',
    'country': 'Страна разработки',
    'description':
        'NeoLoop — логическая головоломка, в которой игрок соединяет пары цветных точек непрерывными линиями и заполняет всё поле. Уровни создаются автоматически, а сложность растёт по мере прохождения. Игра включает подсказки, сохранение прогресса и подготовку к соревновательным режимам.',
    'coming': 'Скоро появится в следующих обновлениях.',
    'levelSelect': 'Выбери уровень',
    'admin': 'Администратор',
    'adminInfo':
        'Административные инструменты будут доступны после безопасной серверной настройки.',
    'adInfo':
        'Рекламная интеграция ещё не подключена. Здесь пока нет реальных объявлений или дохода.',
  },
  'uz': {
    'tagline': 'Ranglarni ulang. Maydonni to‘ldiring.',
    'play': 'O‘YNASH',
    'settings': 'Sozlamalar',
    'levels': 'Bosqichlar',
    'about': 'Loyiha haqida',
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
    'ads': 'Reklama yoqilgan',
    'done': 'Tugatilgan bosqichlar',
    'offline': 'Oflayn • Jarayon saqlanadi',
    'noHints': 'Maslahatlar tugadi',
    'hintShown': 'To‘g‘ri yo‘l ko‘rsatildi',
    'developer': 'Dasturchi',
    'country': 'Ishlab chiqilgan mamlakat',
    'description':
        'NeoLoop — mantiqiy boshqotirma: o‘yinchi bir xil rangdagi nuqtalarni uzluksiz chiziqlar bilan ulab, butun maydonni to‘ldiradi. Bosqichlar avtomatik yaratiladi va qiyinlik oshib boradi. O‘yinda maslahatlar va jarayonni saqlash mavjud.',
    'coming': 'Keyingi yangilanishlarda paydo bo‘ladi.',
    'levelSelect': 'Bosqichni tanlang',
    'admin': 'Administrator',
    'adminInfo':
        'Administrator vositalari xavfsiz server sozlamasidan keyin qo‘shiladi.',
    'adInfo':
        'Reklama hali ulanmagan. Hozircha haqiqiy reklama yoki daromad yo‘q.',
  },
  'en': {
    'tagline': 'Connect colors. Fill the board.',
    'play': 'PLAY',
    'settings': 'Settings',
    'levels': 'Levels',
    'about': 'About',
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
    'ads': 'Ads enabled',
    'done': 'Levels completed',
    'offline': 'Offline • Progress saved',
    'noHints': 'No hints left',
    'hintShown': 'A correct path was revealed',
    'developer': 'Developer',
    'country': 'Country of development',
    'description':
        'NeoLoop is a logic puzzle where players connect matching colored dots with continuous paths and fill the entire board. Levels are generated automatically and become more challenging over time. The game includes hints and local progress saving, with competitive modes planned.',
    'coming': 'Coming in a future update.',
    'levelSelect': 'Choose a level',
    'admin': 'Administrator',
    'adminInfo':
        'Admin tools will be available after secure server configuration.',
    'adInfo':
        'Ads are not integrated yet. No live ads or revenue are active at this stage.',
  },
  'uk': {
    'tagline': 'З’єднуй кольори. Заповнюй поле.',
    'play': 'ГРАТИ',
    'settings': 'Налаштування',
    'levels': 'Рівні',
    'about': 'Про проєкт',
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
    'ads': 'Рекламу ввімкнено',
    'done': 'Пройдено рівнів',
    'offline': 'Офлайн • Прогрес збережено',
    'noHints': 'Підказки закінчилися',
    'hintShown': 'Показано правильний шлях',
    'developer': 'Розробник',
    'country': 'Країна розробки',
    'description':
        'NeoLoop — логічна головоломка, у якій гравець з’єднує пари кольорових точок безперервними лініями та заповнює все поле. Рівні генеруються автоматично, а складність поступово зростає. Є підказки та збереження прогресу.',
    'coming': 'З’явиться в майбутніх оновленнях.',
    'levelSelect': 'Оберіть рівень',
    'admin': 'Адміністратор',
    'adminInfo':
        'Інструменти адміністратора з’являться після безпечного налаштування сервера.',
    'adInfo':
        'Рекламу ще не підключено. Наразі немає реальних оголошень або доходу.',
  },
  'kk': {
    'tagline': 'Түстерді қос. Өрісті толтыр.',
    'play': 'ОЙНАУ',
    'settings': 'Баптаулар',
    'levels': 'Деңгейлер',
    'about': 'Жоба туралы',
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
    'ads': 'Жарнама қосулы',
    'done': 'Өтілген деңгейлер',
    'offline': 'Офлайн • Үдеріс сақталады',
    'noHints': 'Кеңестер таусылды',
    'hintShown': 'Дұрыс жол көрсетілді',
    'developer': 'Әзірлеуші',
    'country': 'Әзірленген ел',
    'description':
        'NeoLoop — ойыншы бір түсті нүктелерді үздіксіз сызықтармен қосып, бүкіл өрісті толтыратын логикалық басқатырғыш. Деңгейлер автоматты түрде жасалады, ал қиындық біртіндеп артады. Кеңестер мен прогресті сақтау мүмкіндігі бар.',
    'coming': 'Келесі жаңартуларда қосылады.',
    'levelSelect': 'Деңгейді таңдаңыз',
    'admin': 'Әкімші',
    'adminInfo':
        'Әкімші құралдары қауіпсіз сервер бапталғаннан кейін қосылады.',
    'adInfo':
        'Жарнама әлі қосылған жоқ. Қазір нақты жарнама да, табыс та жоқ.',
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
  static const int size = boardSize;

  static double _t(int level) =>
      ((level.clamp(1, totalLevels) - 1) / (totalLevels - 1)).toDouble();

  static int colorCount(int level) => (6 + 12 * _t(level)).round();

  static int shuffleIterations(int level) =>
      (150 + 30000 * _t(level)).round();

  static LevelData generate(int level) {
    final rnd = Random(level * 7919 + 104729);
    const n = size * size;
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
    final weights =
        List<double>.generate(k, (_) => 0.4 + rnd.nextDouble() * 1.6);
    final sum = weights.fold<double>(0, (a, b) => a + b);
    final rest = n - k * 4;
    final lengths =
        List<int>.generate(k, (i) => 4 + (rest * weights[i] / sum).floor());
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
        i.isEven ? 0.78 : 0.55,
        i % 3 == 0 ? 1.0 : 0.88,
      ).toColor(),
    );

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
            seedColor: cyan,
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
        body: Center(child: CircularProgressIndicator(color: cyan)),
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
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [cyan, Color(0xFF8B5CFF)],
                      ),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: const Icon(Icons.all_inclusive, size: 35),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NeoLoop',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          tr('tagline'),
                          style: const TextStyle(
                            color: Colors.white70,
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
                    icon: const Icon(Icons.settings),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: panel,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: cyan.withValues(alpha: 0.35)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.blur_circular, size: 72, color: cyan),
                    Text(
                      '${tr('level')} ${AppPrefs.level}',
                      style: const TextStyle(
                        color: cyan,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tr('connect'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '15×15 • ${LevelGenerator.colorCount(AppPrefs.level)}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      '${tr('done')}: ${AppPrefs.completed}/$totalLevels',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: _play,
                      style: FilledButton.styleFrom(
                        backgroundColor: cyan,
                        foregroundColor: bg,
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: Text(
                        tr('play'),
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _MenuButton(
                icon: Icons.grid_view,
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
                      icon: Icons.emoji_events,
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
                      icon: Icons.bolt,
                      bodyKey: 'coming',
                    ),
                  ),
                ),
              ),
              _MenuButton(
                icon: Icons.info_outline,
                label: tr('about'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutPage()),
                ),
              ),
              const Spacer(),
              Text(
                tr('offline'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
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
      paddi
