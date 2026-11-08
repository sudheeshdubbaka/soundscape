import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/catalog.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

class CreatePlaylistScreen extends StatefulWidget {
  const CreatePlaylistScreen({super.key});
  @override
  State<CreatePlaylistScreen> createState() => _CreatePlaylistScreenState();
}

class _CreatePlaylistScreenState extends State<CreatePlaylistScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _desc = TextEditingController();
  int _palette = 0;
  bool _submitted = false;

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    super.dispose();
  }

  String? _validateName(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Enter a playlist name.';
    if (t.length < 3) return 'Use at least 3 characters.';
    if (t.length > 40) return 'Keep the name under 40 characters.';
    final taken = context
        .read<AppState>()
        .playlists
        .any((p) => p.name.toLowerCase() == t.toLowerCase());
    return taken ? 'You already have a playlist with that name.' : null;
  }

  String? _validateDesc(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Add a short description.';
    if (t.length < 10) return 'Use at least 10 characters.';
    if (t.length > 120) return 'Keep it under 120 characters.';
    return null;
  }

  void _submit() {
    setState(() => _submitted = true);
    if (!_form.currentState!.validate()) return;
    final p = context.read<AppState>().createPlaylist(
          name: _name.text,
          description: _desc.text,
          paletteIndex: _palette,
        );
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Created “${p.name}”')));
    Navigator.pushReplacementNamed(context, '/playlist', arguments: p.id);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final mode = _submitted
        ? AutovalidateMode.onUserInteraction
        : AutovalidateMode.disabled;
    return Scaffold(
      appBar: AppBar(title: const Text('New playlist')),
      body: SingleChildScrollView(
        padding: pagePadding(MediaQuery.sizeOf(context).width),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Form(
              key: _form,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListenableBuilder(
                      listenable: _name,
                      builder: (context, _) => Row(children: [
                        Artwork(
                            colors: artPalettes[_palette],
                            icon: Icons.queue_music,
                            size: 96,
                            radius: 16),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _name.text.trim().isEmpty
                                ? 'Untitled playlist'
                                : _name.text.trim(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: text.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _name,
                      autovalidateMode: mode,
                      maxLength: 40,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                          labelText: 'Playlist name',
                          border: OutlineInputBorder()),
                      validator: _validateName,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _desc,
                      autovalidateMode: mode,
                      maxLength: 120,
                      maxLines: 3,
                      decoration: const InputDecoration(
                          labelText: 'Description',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder()),
                      validator: _validateDesc,
                    ),
                    const SizedBox(height: 12),
                    Text('Cover colour', style: text.titleSmall),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      for (var i = 0; i < artPalettes.length; i++)
                        Semantics(
                          button: true,
                          selected: i == _palette,
                          label: 'Cover colour ${i + 1}',
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => setState(() => _palette = i),
                            child: AnimatedContainer(
                              duration: motion(context, 150),
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient:
                                    LinearGradient(colors: artPalettes[i]),
                                border: Border.all(
                                    color: i == _palette
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: 3),
                              ),
                              child: i == _palette
                                  ? const Icon(Icons.check, color: Colors.white)
                                  : null,
                            ),
                          ),
                        ),
                    ]),
                    const SizedBox(height: 24),
                    Row(children: [
                      FilledButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.check),
                          label: const Text('Create playlist')),
                      const SizedBox(width: 12),
                      TextButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          child: const Text('Cancel')),
                    ]),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
