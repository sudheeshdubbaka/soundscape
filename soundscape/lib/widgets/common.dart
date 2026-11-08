import 'package:flutter/material.dart';

/// Animation duration that collapses to zero when the OS asks for reduced motion.
Duration motion(BuildContext context, [int ms = 250]) =>
    MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : Duration(milliseconds: ms);

EdgeInsets pagePadding(double w) => EdgeInsets.symmetric(
      horizontal: w < 600 ? 16 : (w < 1000 ? 24 : 32),
      vertical: 16,
    );

/// Centers content and caps its width on very wide screens.
class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.child, this.maxWidth = 1200});
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      );
}

/// Gradient + icon artwork; needs no image assets.
class Artwork extends StatelessWidget {
  const Artwork({
    super.key,
    required this.colors,
    required this.icon,
    this.size,
    this.radius = 12,
  });
  final List<Color> colors;
  final IconData icon;
  final double? size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final s = size ?? (box.hasBoundedWidth ? box.maxWidth : 120.0);
        return ExcludeSemantics(
          child: Container(
            width: size,
            height: size,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -s * .1,
                  bottom: -s * .1,
                  child: Icon(icon, size: s * .65, color: Colors.white24),
                ),
                Center(
                  child: Icon(icon, size: s * .36, color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });
  final IconData icon;
  final String title, message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: scheme.outline),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});
  @override
  Widget build(BuildContext context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(semanticsLabel: 'Loading'),
            SizedBox(height: 16),
            Text('Loading your music…'),
          ],
        ),
      );
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key});
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Semantics(
          header: true,
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      );
}
