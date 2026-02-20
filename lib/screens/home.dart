import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/provider.dart';
import '../models/quest.dart';
import '../widgets/add_quest.dart';
import '../utils/style.dart';
import '../utils/pixel_ui.dart';
import 'profile.dart';
import 'note.dart';

enum QuestViewLayout { list, card, grid }

class QuestLogScreen extends StatefulWidget {
  const QuestLogScreen({super.key});

  @override
  State<QuestLogScreen> createState() => _QuestLogScreenState();
}

class _QuestLogScreenState extends State<QuestLogScreen> {
  QuestViewLayout _viewLayout = QuestViewLayout.card;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuestProvider>().fetchQuests();
      context.read<QuestProvider>().fetchNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              leading: PopupMenuButton<QuestViewLayout>(
                icon: const Icon(Icons.grid_view, color: Colors.white),
                onSelected: (layout) => setState(() => _viewLayout = layout),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: QuestViewLayout.list,
                    child: Row(
                      children: [
                        Icon(Icons.list, color: Colors.blue),
                        SizedBox(width: 12),
                        Text('Tampilan Daftar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: QuestViewLayout.card,
                    child: Row(
                      children: [
                        Icon(Icons.view_agenda, color: Colors.blue),
                        SizedBox(width: 12),
                        Text('Tampilan Kartu'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: QuestViewLayout.grid,
                    child: Row(
                      children: [
                        Icon(Icons.grid_on, color: Colors.blue),
                        SizedBox(width: 12),
                        Text('Tampilan Kisi'),
                      ],
                    ),
                  ),
                ],
              ),
              title: Container(
                height: 40,
                width: 280, // Increased width for "Catatan" clarity
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  labelColor: const Color.fromARGB(255, 249, 249, 249),
                  unselectedLabelColor: const Color.fromARGB(
                    255,
                    255,
                    255,
                    255,
                  ),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(text: 'Catatan'),
                    Tab(text: 'Tugas'),
                  ],
                ),
              ),
              actions: [
                Consumer<QuestProvider>(
                  builder: (context, provider, child) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          backgroundImage: provider.avatarUrl != null
                              ? NetworkImage(provider.avatarUrl!)
                              : null,
                          child: provider.avatarUrl == null
                              ? const Icon(
                                  Icons.person,
                                  size: 20,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: Stack(
              children: [
                // Background Image
                Positioned.fill(
                  child: Image.asset(
                    'assets/background/background1.gif',
                    fit: BoxFit.cover,
                  ),
                ),
                // Dark overlay to improve readability
                Positioned.fill(
                  child: Container(color: Colors.black.withValues(alpha: 0.3)),
                ),
                // Content
                Positioned.fill(
                  child: TabBarView(
                    children: [
                      // Catatan Tab
                      Consumer<QuestProvider>(
                        builder: (context, provider, child) {
                          if (provider.notes.isEmpty) {
                            return const Center(
                              child: Text(
                                'Belum ada catatan!',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: provider.notes.length,
                            itemBuilder: (context, index) {
                              final note = provider.notes[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: PixelContainer(
                                  pixelSize: 2,
                                  borderColor: Colors.black,
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.9,
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      note.title.isEmpty
                                          ? 'Tanpa Judul'
                                          : note.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      note.content,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            NoteEditorScreen(note: note),
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            backgroundColor: Colors.transparent,
                                            contentPadding: EdgeInsets.zero,
                                            content: PixelContainer(
                                              pixelSize: 2,
                                              borderColor: Colors.black,
                                              backgroundColor: Colors.white,
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  20.0,
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Text(
                                                      'Yakin hapus?',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                context,
                                                              ),
                                                          child: const Text(
                                                            'Batal',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                        ),
                                                        ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors.red,
                                                            foregroundColor:
                                                                Colors.white,
                                                            shape:
                                                                const BeveledRectangleBorder(),
                                                          ),
                                                          onPressed: () {
                                                            provider.deleteNote(
                                                              note.id,
                                                            );
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          },
                                                          child: const Text(
                                                            'Hapus',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      // Tugas Tab
                      Consumer<QuestProvider>(
                        builder: (context, provider, child) {
                          if (provider.quests.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.explore,
                                    size: 64,
                                    color: Colors.white54,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Belum ada Misi!',
                                    style: withBorder(
                                      Theme.of(context).textTheme.headlineSmall
                                              ?.copyWith(color: Colors.white) ??
                                          const TextStyle(),
                                      outlineWidth: 1.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }

                          if (_viewLayout == QuestViewLayout.grid) {
                            return GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio:
                                        0.85, // More compact aspect ratio
                                  ),
                              itemCount: provider.quests.length,
                              itemBuilder: (context, index) {
                                final quest = provider.quests[index];
                                return QuestCard(quest: quest, isCompact: true);
                              },
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: provider.quests.length,
                            itemBuilder: (context, index) {
                              final quest = provider.quests[index];
                              return QuestCard(
                                quest: quest,
                                isList: _viewLayout == QuestViewLayout.list,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (value) =>
                            context.read<QuestProvider>().setSearchQuery(value),
                        decoration: InputDecoration(
                          hintText: 'Cari misi...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  PixelButton(
                    onPressed: () {
                      final tabController = DefaultTabController.of(context);
                      if (tabController.index == 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NoteEditorScreen(),
                          ),
                        );
                      } else {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => const AddQuestSheet(),
                        );
                      }
                    },
                    padding: const EdgeInsets.all(12),
                    label: const Icon(Icons.add, color: Colors.white, size: 28),
                    color: Theme.of(
                      context,
                    ).floatingActionButtonTheme.backgroundColor!,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class QuestCard extends StatelessWidget {
  final Quest quest;
  final bool isList;
  final bool isCompact;

  const QuestCard({
    super.key,
    required this.quest,
    this.isList = false,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
          padding: EdgeInsets.only(bottom: isCompact ? 0 : 16),
          child: PixelContainer(
            pixelSize: 3,
            borderColor: Colors.black,
            backgroundColor: quest.isCompleted
                ? Colors.grey[300]!
                : Theme.of(context).colorScheme.surface,
            padding: EdgeInsets.zero,
            child: isList
                ? ListTile(
                    dense: true,
                    title: Text(
                      quest.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: withBorder(
                        TextStyle(
                          fontSize: 14,
                          decoration: quest.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900],
                        ),
                        outlineColor: Colors.transparent,
                      ),
                    ),
                    subtitle: Text(
                      quest.difficulty.label,
                      style: const TextStyle(fontSize: 10),
                    ),
                    trailing: Checkbox(
                      value: quest.isCompleted,
                      onChanged: (_) => context
                          .read<QuestProvider>()
                          .toggleCompleteQuest(quest.id),
                    ),
                  )
                : isCompact
                ? Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 10.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize:
                              MainAxisSize.min, // Fill content naturally
                          children: [
                            Text(
                              quest.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: withBorder(
                                TextStyle(
                                  fontSize: 15,
                                  decoration: quest.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[900],
                                  height: 1.1,
                                ),
                                outlineColor: Colors.transparent,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              quest.description,
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 11,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 4,
                              runSpacing: 2,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                _DifficultyBadge(
                                  difficulty: quest.difficulty,
                                  isMin: true,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: _buildPopupMenu(context),
                      ),
                      Positioned(
                        bottom: 6,
                        right: 10,
                        child: IconButton(
                          icon: Icon(
                            quest.isCompleted
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            size: 24,
                          ),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          color: Theme.of(context).colorScheme.primary,
                          onPressed: () => context
                              .read<QuestProvider>()
                              .toggleCompleteQuest(quest.id),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                        title: Text(
                          quest.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: withBorder(
                            TextStyle(
                              fontSize: 18,
                              decoration: quest.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900],
                            ),
                            outlineColor: Colors.transparent,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (quest.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                quest.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _DifficultyBadge(difficulty: quest.difficulty),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                quest.isCompleted
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                size: 32,
                              ),
                              color: Theme.of(context).colorScheme.primary,
                              onPressed: () => context
                                  .read<QuestProvider>()
                                  .toggleCompleteQuest(quest.id),
                            ),
                            _buildPopupMenu(context),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        )
        .animate(target: quest.isCompleted ? 1 : 0)
        .shake(hz: 4, curve: Curves.easeInOut);
  }

  Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        size: isCompact ? 20 : 24,
        color: Colors.blue[800],
      ),
      padding: isCompact ? EdgeInsets.zero : const EdgeInsets.all(8),
      constraints: isCompact ? const BoxConstraints() : null,
      onSelected: (value) {
        if (value == 'edit') {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => AddQuestSheet(quest: quest),
          );
        } else if (value == 'delete') {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              content: PixelContainer(
                pixelSize: 2,
                borderColor: Colors.black,
                backgroundColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Yakin hapus?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Batal',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: const BeveledRectangleBorder(),
                            ),
                            onPressed: () {
                              context.read<QuestProvider>().deleteQuest(
                                quest.id,
                              );
                              Navigator.pop(context);
                            },
                            child: const Text('Hapus'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 20, color: Colors.blue),
                SizedBox(width: 8),
                Text('Edit Misi'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: 20, color: Colors.red),
                SizedBox(width: 8),
                Text('Hapus', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ];
      },
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final QuestDifficulty difficulty;
  final bool isMin;
  const _DifficultyBadge({required this.difficulty, this.isMin = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMin ? 4 : 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.lightBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.lightBlue[700]!),
      ),
      child: Text(
        difficulty.label,
        style: withBorder(
          TextStyle(
            color: Colors.lightBlue[800],
            fontSize: isMin ? 10 : 12,
            fontWeight: FontWeight.bold,
          ),
          outlineColor: Colors.black12,
          outlineWidth: 0.5,
        ),
      ),
    );
  }
}
