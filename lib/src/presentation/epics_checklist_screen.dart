import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_ship_app/src/common_widgets/custom_page_route.dart';
import 'package:flutter_ship_app/src/common_widgets/responsive_center_scrollable.dart';
import 'package:flutter_ship_app/src/constants/app_sizes.dart';
import 'package:flutter_ship_app/src/data/app_database_crud.dart';
import 'package:flutter_ship_app/src/domain/app_entity.dart';
import 'package:flutter_ship_app/src/domain/epic_entity.dart';
import 'package:flutter_ship_app/src/presentation/create_edit_app_screen.dart';
import 'package:flutter_ship_app/src/common_widgets/custom_completion_list_tile.dart';
import 'package:flutter_ship_app/src/presentation/tasks_checklist_screen.dart';
import 'package:flutter_ship_app/src/utils/string_hardcoded.dart';

/// Screen used to show all the epics for a given app
class EpicsChecklistScreen extends ConsumerWidget {
  const EpicsChecklistScreen({super.key, required this.app});
  final AppEntity app;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = ScrollController();
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            // * The app name since it can change during editing, so here we
            // * watch it and rebuild the AppBar title as needed
            Consumer(
              builder: (context, ref, child) {
                final updatedApp =
                    ref.watch(watchAppByIdProvider(app.id)).valueOrNull ?? app;
                return Text(updatedApp.name);
              },
            ),
            gapH4,
            Text(
              'Release Checklist'.hardcoded,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Edit this app'.hardcoded,
            onPressed: () => Navigator.of(context).push(
              CustomPageRoute(
                fullscreenDialog: true,
                builder: (_) => CreateOrEditAppScreen(app: app),
              ),
            ),
            icon: Icon(
              Icons.edit,
              semanticLabel: 'Edit this app'.hardcoded,
            ),
          )
        ],
      ),
      body: ResponsiveCenterScrollable(
        controller: scrollController,
        child: EpicsChecklistListView(
          controller: scrollController,
          app: app,
        ),
      ),
    );
  }
}

/// The list of epics
class EpicsChecklistListView extends ConsumerWidget {
  const EpicsChecklistListView({super.key, required this.app, this.controller});
  final AppEntity app;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get list of epics from the DB and map it to the UI
    final epicsAsync = ref.watch(fetchAllEpicsAndTasksProvider);
    return epicsAsync.when(
      data: (epics) => ListView.separated(
        controller: controller,
        itemCount: epics.length,
        separatorBuilder: (context, index) => const Divider(height: 0.5),
        itemBuilder: (_, index) {
          final epic = epics[index];
          return EpicListTile(app: app, epic: epic);
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text(e.toString())),
    );
  }
}

/// A list tile for an epic
class EpicListTile extends ConsumerWidget {
  const EpicListTile({super.key, required this.app, required this.epic});
  final AppEntity app;
  final EpicEntity epic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedCountAsync = ref.watch(
        watchCompletedTasksCountProvider(projectId: app.id, epicId: epic.id));
    // * default to 0 during loading or if there is an error
    final completedCount = completedCountAsync.valueOrNull ?? 0;
    return CustomCompletionListTile(
      title: epic.epic,
      totalCount: epic.tasks.length,
      completedCount: completedCount,
      onTap: () => Navigator.of(context).push(
        CustomPageRoute(
          builder: (_) => TasksChecklistScreen(app: app, epic: epic),
        ),
      ),
    );
  }
}
