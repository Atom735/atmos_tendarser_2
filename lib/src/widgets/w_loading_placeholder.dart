import 'package:flutter/material.dart';

class WLoadingPlaceholder extends StatelessWidget {
  const WLoadingPlaceholder(this.text, {Key? key}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: FittedBox(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 128,
                  height: 128,
                  child: CircularProgressIndicator(strokeWidth: 8),
                ),
                Text(
                  text,
                  style: Theme.of(context).typography.englishLike.displayLarge,
                ),
              ],
            ),
          ),
        ),
      );
}
