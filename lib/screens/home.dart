import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../providers/provider.dart';
import '../models/quest.dart';
import '../widgets/add_quest.dart';
import '../utils/style.dart';
import '../utils/pixel_ui.dart';
import 'profile.dart';

class QuestLogScreen extends StatefulWidget {
  const QuestLogScreen({super.key});

  @override
  State<QuestLogScreen> createState() => _QuestLogScreenState();
}

class _QuestLogScreenState extends State<QuestLogScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuestProvider>().fetchQuests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'List',
          style: withBorder(const TextStyle(fontWeight: FontWeight.bold)),
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
                    backgroundColor: Theme.of(context).colorScheme.primary,
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
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                              ) ??
                              const TextStyle(),
                          outlineWidth: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.quests.length,
                itemBuilder: (context, index) {
                  final quest = provider.quests[index];
                  return QuestCard(quest: quest);
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: PixelButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => const AddQuestSheet(),
        ),
        padding: const EdgeInsets.all(12),
        label: const Icon(Icons.add, color: Colors.white, size: 28),
        color: Theme.of(context).floatingActionButtonTheme.backgroundColor!,
      ),
    );
  }
}

class QuestCard extends StatelessWidget {
  final Quest quest;

  const QuestCard({super.key, required this.quest});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM HH:mm');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child:
          PixelContainer(
                pixelSize: 3,
                borderColor: Colors.black,
                backgroundColor: quest.isCompleted
                    ? Colors.grey[300]!
                    : Theme.of(context).colorScheme.surface,
                padding: EdgeInsets.zero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                              maxLines: 3,
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
                              if (quest.dueDate != null) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.access_time_filled,
                                  size: 14,
                                  color: Colors.red[800],
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    dateFormat.format(quest.dueDate!),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red[800],
                                    ),
                                  ),
                                ),
                              ],
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
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) {
                              if (value == 'edit') {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) =>
                                      AddQuestSheet(quest: quest),
                                );
                              } else if (value == 'delete') {
                                context.read<QuestProvider>().deleteQuest(
                                  quest.id,
                                );
                              }
                            },
                            itemBuilder: (BuildContext context) {
                              return [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 20),
                                      SizedBox(width: 8),
                                      Text('Edit Misi'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        size: 20,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Hapus',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ];
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .animate(target: quest.isCompleted ? 1 : 0)
              .shake(hz: 4, curve: Curves.easeInOut),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final QuestDifficulty difficulty;
  const _DifficultyBadge({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          outlineColor: Colors.black12,
          outlineWidth: 0.5,
        ),
      ),
    );
  }
}
