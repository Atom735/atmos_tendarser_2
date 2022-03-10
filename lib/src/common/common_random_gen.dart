import 'dart:math';

/// Собственный ГПСЧ
class RandomGen implements Random {
  RandomGen(this.seed);
  int seed;

  @override
  int nextInt(int max) {
    seed = seed * 1103515245 + 12345;
    return (seed ~/ 65536) % max;
  }

  @override
  bool nextBool() => nextInt(2) == 1;

  @override
  double nextDouble() => nextInt(1 << 30) / (1 << 30);
}
