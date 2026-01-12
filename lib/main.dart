import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const LandoltPuzzleApp());

class LandoltPuzzleApp extends StatelessWidget {
  const LandoltPuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lanpuzz',
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: const MainMenuPage(),
    );
  }
}

/// 0: Up, 1: Right, 2: Down, 3: Left
int rotateCW(int v) => (v + 1) % 4;

enum Difficulty { one, two, three }

extension DifficultyX on Difficulty {
  String get label {
    switch (this) {
      case Difficulty.one:
        return '難易度1';
      case Difficulty.two:
        return '難易度2';
      case Difficulty.three:
        return '難易度3';
    }
  }

  int get boardSize {
    switch (this) {
      case Difficulty.one:
        return 4;
      case Difficulty.two:
        return 5;
      case Difficulty.three:
        return 6;
    }
  }

  // 体感に合わせてここだけ調整すればOK
  int get shuffleMoves {
    switch (this) {
      case Difficulty.one:
        return 6; // 4x4
      case Difficulty.two:
        return 18; // 5x5
      case Difficulty.three:
        return 35; // 6x6
    }
  }
}

// =======================
//  Main Menu
// =======================
class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w800,
        );

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
               SizedBox(
  height: 160,
  child: Center(
    child: Container(
      width: 480,
      height: 140,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Image.asset(
        'assets/logo_web.jpg',
        fit: BoxFit.contain,
        frameBuilder: (context, child, frame, _) {
          if (frame == null) {
            return const Center(child: Text('loading logo...'));
          }
          return child;
        },
        errorBuilder: (context, error, _) => Text('logo error: $error'),
      ),
    ),
  ),
),
const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('スタート'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DifficultySelectPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.menu_book),
                    label: const Text('遊び方'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HowToPlayPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.help_outline),
                    label: const Text('ヘルプ'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HelpPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =======================
//  Difficulty Select
// =======================
class DifficultySelectPage extends StatelessWidget {
  const DifficultySelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget card(Difficulty d) {
      return Card(
        child: ListTile(
          title: Text('${d.label}（${d.boardSize}×${d.boardSize}）'),
          subtitle: Text('シャッフル: ${d.shuffleMoves}手'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => LandoltPuzzlePage(difficulty: d),
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('難易度を選択')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text(
                  '盤面サイズで難易度が変わります',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                card(Difficulty.one),
                card(Difficulty.two),
                card(Difficulty.three),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =======================
//  How to Play
// =======================
class HowToPlayPage extends StatelessWidget {
  const HowToPlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('遊び方')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('ルール', style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Text(
            '1) マスをタップすると、そのマスと上下左右のマスが回転します。\n'
            '2) 回転は「上 → 右 → 下 → 左 → 上 …」の順に進みます。\n'
            '3) 盤面のランドルト環が「全て同じ向き」になればクリアです（向きの指定はなく、どの向きでもOK）。',
            style: t.bodyLarge,
          ),
          const SizedBox(height: 18),
          Text('操作', style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Text(
            '・リセット：同じシャッフル状態に戻します。\n'
            '・新規（シャッフル）：新しい問題を作ります。\n'
            '・難易度変更：ゲーム中でも難易度選択に戻せます。\n'
            '・ヒント：右上の電球から最大3回まで使えます（次に押すべきマスが光ります。光ったマスを1回押すだけでOK）。',
            style: t.bodyLarge,
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

// =======================
//  Help
// =======================
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('ヘルプ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('よくある質問', style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Text(
            'Q. 途中でわからなくなった\n'
            'A. 「リセット」で最初のシャッフルに戻せます。別問題にしたいなら「新規（シャッフル）」です。\n\n'
            'Q. 難易度を変えたい\n'
            'A. パズル画面の右上メニューから「難易度変更」で戻れます。\n\n'
            'Q. ヒントは何回まで？\n'
            'A. 3回までです。次に押すべきマスが光ります。\n',
            style: t.bodyLarge,
          ),
        ],
      ),
    );
  }
}

// =======================
//  Puzzle Page
// =======================
class LandoltPuzzlePage extends StatefulWidget {
  const LandoltPuzzlePage({
    super.key,
    required this.difficulty,
  });

  final Difficulty difficulty;

  @override
  State<LandoltPuzzlePage> createState() => _LandoltPuzzlePageState();
}

class _LandoltPuzzlePageState extends State<LandoltPuzzlePage>
    with SingleTickerProviderStateMixin {
  final _rng = Random();

  late Difficulty _difficulty;
  late int _size;

  int _moves = 0;
  late List<List<int>> _board;
  late List<List<int>> _initialBoard;

  // --- ヒント：次に押すべきマスを光らせる（3回制限） ---
  Point<int>? _hintCell; // 光らせるマス（r,c）
  int _hintLeft = 3; // 残り回数

  // タイマー
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;
  Duration _elapsed = Duration.zero;

  // クリア演出
  late AnimationController _clearCtrl;
  bool _showClearOverlay = false;
  Duration _clearTime = Duration.zero;
  List<_ConfettiPiece> _confetti = const [];

  @override
  void initState() {
    super.initState();
    _difficulty = widget.difficulty;
    _size = _difficulty.boardSize;

    _clearCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _newGame();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _clearCtrl.dispose();
    super.dispose();
  }

  // ---------- Board ----------
  List<List<int>> _clone(List<List<int>> src) =>
      List.generate(src.length, (r) => List<int>.from(src[r]));

  bool _inBounds(int r, int c) => r >= 0 && r < _size && c >= 0 && c < _size;

  void _applyMove(int r, int c, {required bool countMove}) {
    // 自身 + 上下左右 を CW 回転
    const deltas = [
      (0, 0),
      (-1, 0),
      (1, 0),
      (0, -1),
      (0, 1),
    ];

    for (final (dr, dc) in deltas) {
      final rr = r + dr;
      final cc = c + dc;
      if (_inBounds(rr, cc)) {
        _board[rr][cc] = rotateCW(_board[rr][cc]);
      }
    }
    if (countMove) _moves++;
  }

  /// 「全て同じ向きならどの向きでもOK」
  bool _isSolved() {
    final target = _board[0][0];
    for (int r = 0; r < _size; r++) {
      for (int c = 0; c < _size; c++) {
        if (_board[r][c] != target) return false;
      }
    }
    return true;
  }

  // ---------- Timer ----------
  void _startTimer() {
    _ticker?.cancel();
    _stopwatch
      ..reset()
      ..start();
    _elapsed = Duration.zero;

    _ticker = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!_stopwatch.isRunning) return;
      setState(() => _elapsed = _stopwatch.elapsed);
    });
  }

  void _stopTimer() {
    if (_stopwatch.isRunning) _stopwatch.stop();
    _ticker?.cancel();
  }

  String _format(Duration d) {
    final ms = d.inMilliseconds;
    final minutes = (ms ~/ 60000);
    final seconds = (ms % 60000) ~/ 1000;
    final centi = (ms % 1000) ~/ 10; // 1/100秒
    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    final cc = centi.toString().padLeft(2, '0');
    return '$mm:$ss.$cc';
  }

  // =======================
  //  Hint solver (mod 4)
  // =======================
  int _mod4(int v) => (v % 4 + 4) % 4;

  bool _moveAffects(int moveR, int moveC, int cellR, int cellC) {
    final dr = (cellR - moveR).abs();
    final dc = (cellC - moveC).abs();
    if (dr == 0 && dc == 0) return true;
    if (dr == 1 && dc == 0) return true;
    if (dr == 0 && dc == 1) return true;
    return false;
  }

  /// GF(2)（mod2）で A x = rhs を解く。解がなければ null。
  /// n<=36 なので Dart int のビットマスクで行列を持つ。
  List<int>? _solveMod2(List<int> rhs) {
    final n = _size * _size;
    final rows = List<int>.filled(n, 0);

    // row i = 係数bit(0..n-1) + 右辺bit(n)
    for (int cell = 0; cell < n; cell++) {
      final cr = cell ~/ _size;
      final cc = cell % _size;

      int mask = 0;
      for (int mv = 0; mv < n; mv++) {
        final mr = mv ~/ _size;
        final mc = mv % _size;
        if (_moveAffects(mr, mc, cr, cc)) {
          mask |= (1 << mv);
        }
      }
      if ((rhs[cell] & 1) == 1) {
        mask |= (1 << n); // augmented
      }
      rows[cell] = mask;
    }

    final where = List<int>.filled(n, -1);
    int r = 0;

    for (int c = 0; c < n && r < n; c++) {
      int pivot = -1;
      for (int i = r; i < n; i++) {
        if (((rows[i] >> c) & 1) == 1) {
          pivot = i;
          break;
        }
      }
      if (pivot == -1) continue;

      // swap
      final tmp = rows[pivot];
      rows[pivot] = rows[r];
      rows[r] = tmp;

      where[c] = r;

      // eliminate all other rows
      for (int i = 0; i < n; i++) {
        if (i == r) continue;
        if (((rows[i] >> c) & 1) == 1) {
          rows[i] ^= rows[r];
        }
      }

      r++;
    }

    // inconsistency: 係数0で rhs=1 の行があれば解なし
    final coeffMask = (1 << n) - 1;
    for (int i = 0; i < n; i++) {
      final coeff = rows[i] & coeffMask;
      final b = (rows[i] >> n) & 1;
      if (coeff == 0 && b == 1) return null;
    }

    // solution（自由変数は0）
    final x = List<int>.filled(n, 0);
    for (int c = 0; c < n; c++) {
      final rr = where[c];
      if (rr != -1) {
        x[c] = (rows[rr] >> n) & 1;
      }
    }
    return x;
  }

  /// 現在盤面 -> 「全マス同一向き」への解（押す回数 0..3）
  /// 押下総量が最小の解を返す
  List<int>? _bestSolutionToUniform() {
    final n = _size * _size;

    // 現在盤面を1次元化
    final cur = List<int>.filled(n, 0);
    for (int rr = 0; rr < _size; rr++) {
      for (int cc = 0; cc < _size; cc++) {
        cur[rr * _size + cc] = _board[rr][cc];
      }
    }

    List<int>? bestX;
    int bestCost = 1 << 30;

    for (int target = 0; target < 4; target++) {
      // b = target - cur (mod4)
      final b = List<int>.filled(n, 0);
      final b0 = List<int>.filled(n, 0);
      for (int i = 0; i < n; i++) {
        b[i] = _mod4(target - cur[i]);
        b0[i] = b[i] & 1;
      }

      // 1) mod2: A x0 = b0
      final x0 = _solveMod2(b0);
      if (x0 == null) continue;

      // 2) d = (b - A x0) mod4 は {0,2} になるので、t = d/2 (mod2)
      final t = List<int>.filled(n, 0);
      for (int cell = 0; cell < n; cell++) {
        final cr = cell ~/ _size;
        final cc = cell % _size;

        int sumMod4 = 0;
        for (int mv = 0; mv < n; mv++) {
          if (x0[mv] == 0) continue;
          final mr = mv ~/ _size;
          final mc = mv % _size;
          if (_moveAffects(mr, mc, cr, cc)) {
            sumMod4 = (sumMod4 + 1) & 3; // mod4
          }
        }

        final d = _mod4(b[cell] - sumMod4); // 0 or 2
        t[cell] = (d >> 1) & 1; // 0 or 1
      }

      // 3) mod2: A x1 = t
      final x1 = _solveMod2(t);
      if (x1 == null) continue;

      // 合成：x = x0 + 2*x1（0..3）
      final x = List<int>.filled(n, 0);
      int cost = 0;
      for (int i = 0; i < n; i++) {
        x[i] = x0[i] + 2 * x1[i];
        cost += x[i];
      }

      if (cost < bestCost) {
        bestCost = cost;
        bestX = x;
      }
    }

    return bestX;
  }

  /// 「次に押すべきマス」を1つ返す（押すのは1回でOK）
  Point<int>? _computeHintCell() {
    final x = _bestSolutionToUniform();
    if (x == null) return null;

    // 押す必要があるセル（x[i] > 0）のうち、必要回数が最大のものを選ぶ
    int bestIdx = -1;
    int bestNeed = 0;
    for (int i = 0; i < x.length; i++) {
      if (x[i] > bestNeed) {
        bestNeed = x[i];
        bestIdx = i;
      }
    }
    if (bestIdx == -1 || bestNeed == 0) return null;

    return Point<int>(bestIdx ~/ _size, bestIdx % _size);
  }

  void _showHint() {
    if (_showClearOverlay) return;
    if (_hintLeft <= 0) return;

    final cell = _computeHintCell();
    if (cell == null) return;

    setState(() {
      _hintCell = cell;
      _hintLeft--;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('光ったマスを1回押してください')),
    );
  }

  // ---------- Clear handling ----------
  void _handleSolved() {
    _stopTimer();
    _clearTime = _elapsed;

    _confetti = List.generate(120, (_) {
      return _ConfettiPiece(
        x: _rng.nextDouble(),
        y: -_rng.nextDouble() * 0.6,
        size: 4 + _rng.nextDouble() * 8,
        drift: (_rng.nextDouble() * 2 - 1) * 0.25,
        speed: 0.7 + _rng.nextDouble() * 1.4,
        rot: _rng.nextDouble() * pi * 2,
        rotSpeed: (_rng.nextDouble() * 2 - 1) * 2.0,
        colorIndex: _rng.nextInt(6),
      );
    });

    setState(() => _showClearOverlay = true);
    _clearCtrl.forward(from: 0);
  }

  // ---------- Game control ----------
  void _newGame() {
    _showClearOverlay = false;
    _clearCtrl.reset();

    _size = _difficulty.boardSize;

    // 開始即クリアを確実に避ける：解状態→シャッフルを「解けてない状態になるまで」繰り返す
    do {
      _board = List.generate(_size, (_) => List.filled(_size, 0));
      final n = _difficulty.shuffleMoves;

      for (int k = 0; k < n; k++) {
        final r = _rng.nextInt(_size);
        final c = _rng.nextInt(_size);
        _applyMove(r, c, countMove: false);
      }
    } while (_isSolved());

    _moves = 0;
    _initialBoard = _clone(_board);

    _hintCell = null;
    _hintLeft = 3;

    _startTimer();
    setState(() {});
  }

  void _reset() {
    _showClearOverlay = false;
    _clearCtrl.reset();

    _board = _clone(_initialBoard);
    _moves = 0;

    // リセットは「最初の状態に戻る」のでヒントも復活
    _hintCell = null;
    _hintLeft = 3;

    _startTimer();
    setState(() {});
  }

  void _onTapCell(int r, int c) {
    if (_showClearOverlay) return;

    setState(() {
      _hintCell = null; // 光ったマスを押したら消える（仕様）
      _applyMove(r, c, countMove: true);
    });

    if (_isSolved()) {
      _handleSolved();
    }
  }

  void _goDifficultySelect() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DifficultySelectPage()),
    );
  }

  void _goHowToPlay() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HowToPlayPage()),
    );
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_difficulty.label}（${_size}×${_size}）'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'difficulty') _goDifficultySelect();
              if (v == 'howto') _goHowToPlay();
              if (v == 'menu') Navigator.of(context).popUntil((r) => r.isFirst);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'difficulty', child: Text('難易度変更')),
              PopupMenuItem(value: 'howto', child: Text('遊び方')),
              PopupMenuDivider(),
              PopupMenuItem(value: 'menu', child: Text('メインに戻る')),
            ],
          ),

          // ヒント（3回まで）
          IconButton(
            tooltip: 'ヒント（残り $_hintLeft）',
            onPressed: (_hintLeft > 0 && !_showClearOverlay) ? _showHint : null,
            icon: const Icon(Icons.lightbulb_outline),
          ),

          IconButton(
            tooltip: 'リセット',
            onPressed: _reset,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: '新規（シャッフル）',
            onPressed: _newGame,
            icon: const Icon(Icons.shuffle),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _TopBar(
                moves: _moves,
                elapsed: _format(_elapsed),
                size: _size,
                shuffleMoves: _difficulty.shuffleMoves,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cellSize = min(
                        constraints.maxWidth / _size,
                        constraints.maxHeight / _size,
                      );

                      return Center(
                        child: SizedBox(
                          width: cellSize * _size,
                          height: cellSize * _size,
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: _size,
                            ),
                            itemCount: _size * _size,
                            itemBuilder: (_, i) {
                              final r = i ~/ _size;
                              final c = i % _size;
                              final dir = _board[r][c];
                              final isHint = (_hintCell != null &&
                                  _hintCell!.x == r &&
                                  _hintCell!.y == c);

                              return InkWell(
                                onTap: () => _onTapCell(r, c),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  margin: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isHint
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .outlineVariant,
                                      width: isHint ? 3 : 1,
                                    ),
                                    boxShadow: isHint
                                        ? [
                                            BoxShadow(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.25),
                                              blurRadius: 10,
                                              spreadRadius: 1,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: CustomPaint(
                                      size: Size(cellSize * 0.72, cellSize * 0.72),
                                      painter: LandoltPainter(
                                        direction: dir,
                                        strokeWidth: max(3, cellSize * 0.08),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),

          // ---- Clear Overlay (Confetti + Popup) ----
          if (_showClearOverlay) ...[
            Positioned.fill(
              child: IgnorePointer(
                ignoring: false,
                child: AnimatedBuilder(
                  animation: _clearCtrl,
                  builder: (context, _) {
                    final t = Curves.easeOut.transform(_clearCtrl.value);

                    return Stack(
                      children: [
                        Opacity(
                          opacity: 0.35 * t,
                          child: Container(color: Colors.black),
                        ),
                        CustomPaint(
                          painter: ConfettiPainter(
                            t: t,
                            pieces: _confetti,
                          ),
                          child: const SizedBox.expand(),
                        ),
                        Center(
                          child: Transform.scale(
                            scale: 0.85 + 0.15 * t,
                            child: Opacity(
                              opacity: t,
                              child: _ClearCard(
                                timeText: _format(_clearTime),
                                moves: _moves,
                                difficultyLabel:
                                    '${_difficulty.label}（${_size}×${_size}）',
                                onNew: _newGame,
                                onClose: () {
                                  setState(() => _showClearOverlay = false);
                                },
                                onMenu: () {
                                  Navigator.of(context).popUntil((r) => r.isFirst);
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.moves,
    required this.elapsed,
    required this.size,
    required this.shuffleMoves,
  });

  final int moves;
  final String elapsed;
  final int size;
  final int shuffleMoves;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Chip(label: Text('盤面: ${size}×$size')),
          Chip(label: Text('手数: $moves')),
          Chip(label: Text('タイム: $elapsed')),
          Chip(label: Text('シャッフル: ${shuffleMoves}手')),
        ],
      ),
    );
  }
}

class _ClearCard extends StatelessWidget {
  const _ClearCard({
    required this.timeText,
    required this.moves,
    required this.difficultyLabel,
    required this.onNew,
    required this.onClose,
    required this.onMenu,
  });

  final String timeText;
  final int moves;
  final String difficultyLabel;
  final VoidCallback onNew;
  final VoidCallback onClose;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380),
      child: Card(
        elevation: 12,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CLEAR!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 10),
              Text(difficultyLabel),
              const SizedBox(height: 6),
              Text('クリアタイム: $timeText'),
              Text('手数: $moves'),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton(
                    onPressed: onNew,
                    child: const Text('新しいゲーム'),
                  ),
                  OutlinedButton(
                    onPressed: onMenu,
                    child: const Text('メインへ'),
                  ),
                  OutlinedButton(
                    onPressed: onClose,
                    child: const Text('閉じる'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ランドルト環（C環）を描画
class LandoltPainter extends CustomPainter {
  LandoltPainter({
    required this.direction,
    required this.strokeWidth, // 互換のため残す（実際はsize基準で決める）
  });

  final int direction; // 0 Up, 1 Right, 2 Down, 3 Left
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final s = min(size.width, size.height);
    final center = Offset(size.width / 2, size.height / 2);

    // ---- 形状パラメータ（ここだけ調整すればOK）----
    final outerR = s * 0.46;

    // 線幅（ランドルト環の太さ）
    final thickness = (outerR * 0.38).clamp(8.0, s * 0.28).toDouble();
    final innerR = max(outerR - thickness, 1.0);

    // 開口幅（“狭めたい”なら係数を下げる：0.60〜0.80）
    final gapLinear = thickness * 0.70;

    // ---- ドーナツ（外円−内円）----
    final ring = Path()
      ..fillType = PathFillType.evenOdd
      ..addOval(Rect.fromCircle(center: center, radius: outerR))
      ..addOval(Rect.fromCircle(center: center, radius: innerR));

    // ---- 開口部：方向に応じた長方形で「切り欠く」----
    const eps = 1.0; // 端の欠け防止の微小マージン
    late Rect cutRect;

    switch (direction) {
      case 1: // Right
        cutRect = Rect.fromLTRB(
          center.dx + innerR - eps,
          center.dy - gapLinear / 2,
          center.dx + outerR + eps,
          center.dy + gapLinear / 2,
        );
        break;
      case 3: // Left
        cutRect = Rect.fromLTRB(
          center.dx - outerR - eps,
          center.dy - gapLinear / 2,
          center.dx - innerR + eps,
          center.dy + gapLinear / 2,
        );
        break;
      case 0: // Up
        cutRect = Rect.fromLTRB(
          center.dx - gapLinear / 2,
          center.dy - outerR - eps,
          center.dx + gapLinear / 2,
          center.dy - innerR + eps,
        );
        break;
      case 2: // Down
        cutRect = Rect.fromLTRB(
          center.dx - gapLinear / 2,
          center.dy + innerR - eps,
          center.dx + gapLinear / 2,
          center.dy + outerR + eps,
        );
        break;
      default:
        cutRect = Rect.zero;
    }

    final cut = Path()..addRect(cutRect);

    // ring から cut を引いてランドルト環完成
    final landolt = Path.combine(PathOperation.difference, ring, cut);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true
      ..color = Colors.black;

    canvas.drawPath(landolt, paint);
  }

  @override
  bool shouldRepaint(covariant LandoltPainter oldDelegate) {
    return oldDelegate.direction != direction ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

// ---------------- Clear Confetti ----------------

class _ConfettiPiece {
  _ConfettiPiece({
    required this.x,
    required this.y,
    required this.size,
    required this.drift,
    required this.speed,
    required this.rot,
    required this.rotSpeed,
    required this.colorIndex,
  });

  final double x; // 0..1
  final double y; // -..1
  final double size;
  final double drift;
  final double speed;
  final double rot;
  final double rotSpeed;
  final int colorIndex;
}

class ConfettiPainter extends CustomPainter {
  ConfettiPainter({
    required this.t,
    required this.pieces,
  });

  final double t; // 0..1
  final List<_ConfettiPiece> pieces;

  static const _palette = <Color>[
    Color(0xFFE53935),
    Color(0xFF1E88E5),
    Color(0xFF43A047),
    Color(0xFFFDD835),
    Color(0xFF8E24AA),
    Color(0xFFFB8C00),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (pieces.isEmpty) return;

    for (final p in pieces) {
      final px = (p.x + p.drift * t) * size.width;
      final py = (p.y + p.speed * t) * size.height;

      if (py < -50 || py > size.height + 50) continue;

      final c = _palette[p.colorIndex % _palette.length];
      final paint = Paint()..color = c.withOpacity(0.9);

      final angle = p.rot + p.rotSpeed * t;
      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(angle);

      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: p.size,
        height: p.size * 0.6,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(p.size * 0.2)),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.pieces != pieces;
  }
}
