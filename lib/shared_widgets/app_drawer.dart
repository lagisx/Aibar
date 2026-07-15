import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/utils/error_translator.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../features/chat/controllers/chat_controller.dart';
import '../features/subscription/controllers/subscription_controller.dart';
import 'account_menu_sheet.dart';
import 'avatar_placeholder.dart';
import 'shimmer_box.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final subscriptionAsync = ref.watch(subscriptionControllerProvider);
    final sessionsAsync = ref.watch(chatSessionsProvider);
    ref.watch(chatControllerProvider); // чтобы подсветка активного чата обновлялась
    final activeSessionId = ref.read(chatControllerProvider.notifier).currentSessionId;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Чаты', style: Theme.of(context).textTheme.titleLarge),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: sessionsAsync.when(
                data: (sessions) {
                  if (sessions.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Здесь появятся ваши чаты, как только вы отправите первое сообщение.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      return Dismissible(
                        key: ValueKey(session.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          color: Theme.of(context).colorScheme.errorContainer,
                          child: Icon(
                            Icons.delete_outline,
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                        confirmDismiss: (_) => _confirmDeleteSession(context, session.displayTitle),
                        onDismissed: (_) =>
                            ref.read(chatControllerProvider.notifier).deleteSession(session.id),
                        child: ListTile(
                          leading: const Icon(Icons.chat_bubble_outline),
                          title: Text(
                            session.displayTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            DateFormat('d MMM, HH:mm', 'ru').format(session.lastMessageAt),
                          ),
                          selected: session.id == activeSessionId,
                          trailing: PopupMenuButton<_SessionAction>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (action) async {
                              switch (action) {
                                case _SessionAction.rename:
                                  final newTitle = await _promptRenameSession(
                                    context,
                                    session.displayTitle,
                                  );
                                  if (newTitle != null && newTitle.isNotEmpty) {
                                    ref
                                        .read(chatControllerProvider.notifier)
                                        .renameSession(session.id, newTitle);
                                  }
                                case _SessionAction.delete:
                                  final confirmed = await _confirmDeleteSession(
                                    context,
                                    session.displayTitle,
                                  );
                                  if (confirmed) {
                                    ref
                                        .read(chatControllerProvider.notifier)
                                        .deleteSession(session.id);
                                  }
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: _SessionAction.rename,
                                child: ListTile(
                                  leading: Icon(Icons.edit_outlined),
                                  title: Text('Переименовать'),
                                ),
                              ),
                              PopupMenuItem(
                                value: _SessionAction.delete,
                                child: ListTile(
                                  leading: Icon(Icons.delete_outline),
                                  title: Text('Удалить'),
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                            ref.read(chatControllerProvider.notifier).openSession(session.id);
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () => const _SessionsSkeletonList(),
                error: (error, stackTrace) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(friendlyErrorMessage(error, context: 'sessions', stackTrace: stackTrace)),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref.invalidate(chatSessionsProvider),
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: AvatarPlaceholder(email: user?.email, radius: 20),
              title: Text(
                user?.email ?? 'Гость',
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: subscriptionAsync.when(
                data: (subscription) =>
                    Text('Тариф: ${subscription.tier.name.toUpperCase()}'),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              onTap: () => showAccountMenu(context, ref),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

enum _SessionAction { rename, delete }

Future<String?> _promptRenameSession(BuildContext context, String currentTitle) {
  final controller = TextEditingController(text: currentTitle);
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Переименовать чат'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Название чата'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(controller.text.trim()),
          child: const Text('Сохранить'),
        ),
      ],
    ),
  );
}

Future<bool> _confirmDeleteSession(BuildContext context, String title) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Удалить чат?'),
      content: Text('«$title» и все сообщения в нём будут удалены безвозвратно.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Удалить'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

class _SessionsSkeletonList extends StatelessWidget {
  const _SessionsSkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) => const ListTile(
        leading: ShimmerBox(
          width: 24,
          height: 24,
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        title: Padding(
          padding: EdgeInsets.only(bottom: 6),
          child: ShimmerBox(width: 160, height: 14),
        ),
        subtitle: ShimmerBox(width: 100, height: 11),
      ),
    );
  }
}
