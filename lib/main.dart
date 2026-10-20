import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const NeoLoopApp());

const bg = Color(0xFF061226);
const panel = Color(0xFF0C1E39);
const cyan = Color(0xFF38D8FF);

const int totalLevels = 30;

// ───────────────────────── Генератор уровней ─────────────────────────
//
// Принцип:
// 1. Берём «змейку», проходящую по всем клеткам поля 15x15 (гамильтонов путь).
// 2. Случайно перемешиваем её алгоритмом backbite: путь остаётся гамильтоновым,
//    но становится всё более запутанным. Чем выше уровень, тем больше итераций.
// 3. Режем путь на k кусков. Концы кусков — цветные точки, куски — готовое решение.
//
// Поэтому уровень ВСЕГДА решаем: решение известно заранее (оно же используется
// для подсказок). Уровень детерминирован: один номер = одно и то же поле.

class LevelData {
  final int size;
  final int colors;
  final Map<int, int> endpoints; // клетка -> индекс цвета
  final List<List<int>> solution; // решение: путь для каждого цвета

  const LevelData(this.size, this.colors, this.endpoints, this.solution);
}

class LevelGenerator {
  static const int size = 15;
  static const int minSegment = 4;

  /// 0.0 на первом уровне ... 1.0 на последнем.
  static double _t(int level) =>
      ((level - 1) / (totalLevels - 1)).clamp(0.0, 1.0).toDouble();

  /// Количество цветов: от 6 до 18.
  static int colorCount(int level) => (6 + 12 * _t(level)).round();

  /// Количество «перемешиваний»: от почти ровной змейки до хаотичного пути.
  static int shuffleIterations(int level) => (150 + 30000 * _t(level)).round();

  static LevelData generate(int level) {
    final rnd = Random(level * 7919 + 104729);
    const n = size * size;

    // 1. Змейка по всему полю.
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

    // 2. Перемешивание (backbite).
    final iterations = shuffleIterations(level);
    for (int it = 0; it < iterations; it++) {
      final head = rnd.nextBool();
      final e = head ? path.first : path.last;
      final ex = e % size, ey = e ~/ size;
      final nbs = <int>[
        if (ex > 0) e - 1,
        if (ex < size - 1) e + 1,
        if (ey > 0) e - size,
        if (ey < size - 1) e + size,
      ];
      final nb = nbs[rnd.nextInt(nbs.length)];
      final j = pos[nb];
      if (head) {
        if (j == 1) continue;
        reverse(0, j - 1);
      } else {
        if (j == n - 2) continue;
        reverse(j + 1, n - 1);
      }
    }

    // 3. Нарезка на k кусков разной длины.
    final k = colorCount(level);
    final weights = List<double>.generate(k, (_) => 0.4 + rnd.nextDouble() * 1.6);
    final wSum = weights.reduce((a, b) => a + b);
    final rest = n - k * minSegment;
    final lens = List<int>.generate(
      k,
      (i) => minSegment + (rest * weights[i] / wSum).floor(),
    );
    var left = n - lens.reduce((a, b) => a + b);
    while (left > 0) {
      lens[rnd.nextInt(k)]++;
      left--;
    }

    final solution = <List<int>>[];
    final endpoints = <int, int>{};
    var start = 0;
    for (int i = 0; i < k; i++) {
      final seg = path.sublist(start, start + lens[i]);
      start += lens[i];
      solution.add(seg);
      endpoints[seg.first] = i;
      endpoints[seg.last] = i;
    }
    return LevelData(size, k, endpoints, solution);
  }
}

/// Палитра нужного размера: золотой угол даёт максимально разные соседние цвета.
List<Color> buildPalette(int n) => List.generate(
      n,
      (i) => HSVColor.fromAHSV(
        1,
        (i * 137.508) % 360,
        i.isEven ? 0.78 : 0.55,
        i % 3 == 0 ? 1.0 : 0.88,
      ).toColor(),
    );

// ───────────────────────── Приложение ─────────────────────────

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
        home: const HomePage(),
      );
}

// ───────────────────────── Главный экран ─────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int level = 1, completed = 0;
  bool music = true, effects = true, ads = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      level = p.getInt('level') ?? 1;
      completed = p.getInt('completed') ?? 0;
      music = p.getBool('music') ?? true;
      effects = p.getBool('effects') ?? true;
      ads = p.getBool('ads') ?? true;
    });
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('level', level);
    await p.setInt('completed', completed);
    await p.setBool('music', music);
    await p.setBool('effects', effects);
    await p.setBool('ads', ads);
  }

  Future<void> _play() async {
    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => GamePage(number: level)),
    );
    if (result != null && mounted) {
      setState(() {
        if (completed < result) completed = result;
        level = result < totalLevels ? result + 1 : totalLevels;
      });
      await _save();
    }
  }

  Future<void> _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsPage(
          music: music,
          effects: effects,
          ads: ads,
          onSave: (m, e, a) async {
            setState(() {
              music = m;
              effects = e;
              ads = a;
            });
            await _save();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = LevelGenerator.size;
    final colors = LevelGenerator.colorCount(level);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 25),
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NeoLoop',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Простые ходы. Бесконечное удовольствие.',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: panel,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: cyan.withOpacity(.35)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.blur_circular, size: 75, color: cyan),
                    Text(
                      'УРОВЕНЬ $level',
                      style: const TextStyle(
                        color: cyan,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Соедини цвета и заполни всё поле',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Поле $size×$size • цветов: $colors',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      'Пройдено уровней: $completed из $totalLevels',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _play,
                      style: FilledButton.styleFrom(
                        backgroundColor: cyan,
                        foregroundColor: bg,
                        minimumSize: const Size.fromHeight(54),
                      ),
                      child: const Text(
                        'ИГРАТЬ',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: _openSettings,
                icon: const Icon(Icons.settings),
                label: const Text('Настройки'),
              ),
              const Spacer(),
              const Text(
                'Офлайн • Сохранение прогресса',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Игровой экран ─────────────────────────

class GamePage extends StatefulWidget {
  final int number;
  const GamePage({super.key, required this.number});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  static const int maxHints = 3;

  late final LevelData data = LevelGenerator.generate(widget.number);
  late final List<Color> colors = buildPalette(data.colors);
  late final int n = data.size;
  late final List<int> owner = List<int>.filled(n * n, -1);

  /// Готовые/частично проведённые пути: цвет -> клетки (от одной точки к другой).
  final Map<int, List<int>> paths = {};
  int? active;
  List<int> draft = [];
  int moves = 0;
  int hintsLeft = maxHints;
  bool _won = false;

  Map<int, int> get endpoints => data.endpoints;

  // ---- вспомогательное ----

  void _rebuild() {
    owner.fillRange(0, owner.length, -1);
    paths.forEach((k, p) {
      for (final c in p) {
        owner[c] = k;
      }
    });
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
        p.first != p.last &&
        endpoints[p.first] == k &&
        endpoints[p.last] == k;
  }

  int get connectedCount =>
      List.generate(data.colors, (i) => i).where(_connected).length;

  int get filledPercent =>
      (owner.where((e) => e >= 0).length * 100 / (n * n)).floor();

  /// Обрезает путь цвета [k] перед клеткой [c] (чужая линия «прорезана»).
  void _cut(int k, int c) {
    final p = paths[k];
    if (p == null) return;
    final i = p.indexOf(c);
    if (i < 2) {
      paths.remove(k);
    } else {
      paths[k] = p.sublist(0, i);
    }
  }

  // ---- жесты ----

  void begin(int c) {
    if (_won) return;
    if (endpoints.containsKey(c)) {
      // Старт с цветной точки: путь этого цвета рисуется заново.
      setState(() {
        final k = endpoints[c]!;
        paths.remove(k);
        active = k;
        draft = [c];
        moves++;
        _rebuild();
      });
    } else if (owner[c] >= 0 && paths.containsKey(owner[c])) {
      // Старт с середины готовой линии: продолжаем с этого места.
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
    if (_won || active == null || draft.isEmpty) return;

    final last = draft.last;
    if (c == last) return;

    // Шаг назад: возвращаемся в предыдущую клетку — линия укорачивается.
    if (draft.length >= 2 && c == draft[draft.length - 2]) {
      setState(() {
        draft.removeLast();
        _rebuild();
      });
      return;
    }

    if (draft.contains(c)) return;

    // Только соседние клетки.
    final dist = (last % n - c % n).abs() + (last ~/ n - c ~/ n).abs();
    if (dist != 1) return;

    // Чужие цветные точки трогать нельзя.
    if (endpoints.containsKey(c) && endpoints[c] != active) return;

    var done = false;
    setState(() {
      final o = owner[c];
      if (o >= 0 && o != active) _cut(o, c);
      draft.add(c);
      if (endpoints[c] == active) {
        paths[active!] = List.of(draft);
        active = null;
        draft = [];
        done = true;
      }
      _rebuild();
    });
    if (done) _checkWin();
  }

  void endDrag() {
    if (active == null) return;
    setState(() {
      // Незаконченная линия остаётся на поле, её можно продолжить.
      if (draft.length >= 2) paths[active!] = List.of(draft);
      active = null;
      draft = [];
      _rebuild();
    });
  }

  // ---- победа ----

  void _checkWin() {
    if (_won) return;
    final allConnected = List.generate(data.colors, (i) => i).every(_connected);
    final allFilled = !owner.contains(-1);
    if (!allConnected || !allFilled) return;
    _won = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: panel,
        title: const Text('Уровень пройден! ✨'),
        content: Text(
          'Ходов: $moves\nПодсказок использовано: ${maxHints - hintsLeft}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, widget.number);
            },
            child: const Text('ДАЛЕЕ'),
          ),
        ],
      ),
    );
  }

  // ---- кнопки ----

  void reset() => setState(() {
        paths.clear();
        active = null;
        draft = [];
        moves = 0;
        _rebuild();
      });

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

  /// Подсказка: ставит на поле правильный путь для одного из цветов.
  void hint() {
    if (_won) return;
    if (hintsLeft <= 0) {
      _snack('Подсказки закончились.');
      return;
    }
    final bad = [
      for (int k = 0; k < data.colors; k++)
        if (!_matchesSolution(k)) k
    ];
    if (bad.isEmpty) return;

    final k = bad[Random().nextInt(bad.length)];
    final sol = data.solution[k];
    final solSet = sol.toSet();

    setState(() {
      active = null;
      draft = [];
      for (final o in paths.keys.toList()) {
        if (o == k) continue;
        final p = paths[o]!;
        final i = p.indexWhere(solSet.contains);
        if (i >= 0) {
          if (i < 2) {
            paths.remove(o);
          } else {
            paths[o] = p.sublist(0, i);
          }
        }
      }
      paths[k] = List.of(sol);
      hintsLeft--;
      _rebuild();
    });
    _snack('Показан путь одного цвета. Осталось подсказок: $hintsLeft');
    _checkWin();
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  int? _cellAt(Offset p, double cw) {
    final x = (p.dx / cw).floor();
    final y = (p.dy / cw).floor();
    if (x < 0 || x >= n || y < 0 || y >= n) return null;
    return y * n + x;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Уровень ${widget.number}'),
          actions: [
            IconButton(
              tooltip: 'Подсказка',
              onPressed: hint,
              icon: const Icon(Icons.lightbulb_outline),
            ),
            IconButton(
              tooltip: 'Сначала',
              onPressed: reset,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                'Соедини пары и заполни ВСЕ клетки.\n'
                'Соединено: $connectedCount/${data.colors} • '
                'Заполнено: $filledPercent%',
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: LayoutBuilder(
                      builder: (context, box) {
                        final cw = box.maxWidth / n;
                        return GestureDetector(
                          onPanStart: (d) {
                            final c = _cellAt(d.localPosition, cw);
                            if (c != null) begin(c);
                          },
                          onPanUpdate: (d) {
                            final c = _cellAt(d.localPosition, cw);
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
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
     
