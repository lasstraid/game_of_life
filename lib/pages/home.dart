import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  static const int rows = 30;
  static const int cols = 30;

  late List<List<bool>> grid;
  Timer? timer;
  Random random = Random();
  bool isRunning = false;

  @override
  void initState() {
    super.initState();
    grid = List.generate(
      rows,
      (_) => List.generate(cols, (_) => random.nextBool()),
    );
  }

  void toggleCell(int r, int c) {
    setState(() {
      grid[r][c] = !grid[r][c];
    });
  }

  int aliveNeighbors(int r, int c) {
    int count = 0;
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr != 0 || dc != 0) {
          int nr = r + dr;
          int nc = c + dc;
          if (nr >= 0 && nr < rows && nc >= 0 && nc < cols) {
            if (grid[nr][nc]) count++;
          }
        }
      }
    }
    return count;
  }

  void nextGeneration() {
    final newGrid = List.generate(
      rows,
      (_) => List.generate(cols, (_) => false),
    );
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        int neighbors = aliveNeighbors(r, c);
        if (grid[r][c]) {
          newGrid[r][c] = neighbors == 2 || neighbors == 3;
        } else {
          newGrid[r][c] = neighbors == 3;
        }
      }
    }
    setState(() {
      grid = newGrid;
    });
  }

  void start() {
    timer ??= Timer.periodic(
      const Duration(milliseconds: 2000),
      (_) => nextGeneration(),
    );
    setState(() {
      isRunning = true;
    });
  }

  void stop() {
    timer?.cancel();
    timer = null;
    setState(() {
      isRunning = false;
    });
  }

  void clear() {
    stop();
    setState(() {
      grid = List.generate(rows, (_) => List.generate(cols, (_) => random.nextBool()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'GAME OF LIFE',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Hello world :)'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: Icon(Icons.info),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
              ),
              itemCount: rows * cols,
              itemBuilder: (context, index) {
                int r = index ~/ cols;
                int c = index % cols;
                return GestureDetector(
                  onTap: () => toggleCell(r, c),
                  child: Container(
                    margin: const EdgeInsets.all(1),
                    color: grid[r][c] ? Colors.black : Colors.white,
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: isRunning ? null : start,
                child: const Text('iniciar'),
              ),
              ElevatedButton(
                onPressed: isRunning ? stop : null,
                child: const Text('pausar'),
              ),
              ElevatedButton(onPressed: clear, child: const Text('reiniciar')),
            ],
          ),
        ],
      ),
    );
  }
}
