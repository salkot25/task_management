import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../provider/notes_provider.dart';
import '../../domain/entities/note.dart';
import 'package:clarity/utils/design_system/design_system.dart';
import 'package:clarity/presentation/widgets/standard_app_bar.dart';
import 'package:clarity/utils/navigation_helper_v2.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  // Indonesian date formatters
  final DateFormat _indonesianTimeFormat = DateFormat('HH:mm', 'id_ID');
  final DateFormat _indonesianShortDateFormat = DateFormat(
    'd MMM yyyy',
    'id_ID',
  );

  @override
  void initState() {
    super.initState();
    _setupScrollListener();

    // Load notes after the first frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotes();
    });
  }

  void _setupScrollListener() {
    // No FAB animation needed anymore
  }

  Future<void> _loadNotes() async {
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    await notesProvider.init();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        title: 'Notes',
        subtitle: 'Manage your important notes & ideas',
        actions: [
          IconButton(
            icon: Icon(
              Icons.search_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onPressed: _showSearchDialog,
            tooltip: 'Cari Catatan',
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'categories',
                child: Row(
                  children: [
                    Icon(Icons.category_outlined, size: 18),
                    SizedBox(width: 12),
                    Text('Kategori'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_filters',
                child: Row(
                  children: [
                    Icon(Icons.clear_all_rounded, size: 18),
                    SizedBox(width: 12),
                    Text('Hapus Filter'),
                  ],
                ),
              ),
            ],
          ),
          ActionButton(
            icon: Icons.add_rounded,
            onPressed: _showAddNoteDialog,
            tooltip: 'Catatan Baru',
            color: AppColors.primaryColor,
          ),
        ],
      ),
      body: Consumer<NotesProvider>(
        builder: (context, notesProvider, child) {
          if (notesProvider.isLoading) {
            return _buildLoadingState();
          }

          if (notesProvider.error != null) {
            return _buildErrorState(notesProvider.error!);
          }

          return RefreshIndicator(
            onRefresh: () => notesProvider.init(),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Statistics Header
                SliverToBoxAdapter(
                  child: _buildStatisticsHeader(notesProvider),
                ),

                // Search and Filter Bar
                if (notesProvider.searchQuery.isNotEmpty ||
                    notesProvider.selectedCategory != null)
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        _buildActiveFilters(notesProvider),
                      ],
                    ),
                  ),

                // Notes List
                _buildNotesList(notesProvider),
              ],
            ),
          );
        },
      ),
      // FloatingActionButton removed, replaced by AppBar button
    );
  }

  Widget _buildStatisticsHeader(NotesProvider notesProvider) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: AppSpacing.getPagePadding(
        MediaQuery.of(context).size.width,
      ).copyWith(bottom: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
          borderRadius: BorderRadius.circular(AppComponents.largeRadius),
          border: Border.all(
            color: isDarkMode
                ? Colors.grey.withOpacity(0.15)
                : Theme.of(context).colorScheme.outline.withOpacity(0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.10)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: _buildCompactStatCard(
                notesProvider.totalNotes.toString(),
                'Total',
                Icons.note_outlined,
                AppColors.primaryColor,
              ),
            ),
            Container(
              width: 1,
              height: 32,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.12),
            ),
            Expanded(
              child: _buildCompactStatCard(
                notesProvider.pinnedNotes.toString(),
                'Pin',
                Icons.push_pin_outlined,
                AppColors.warningColor,
              ),
            ),
            Container(
              width: 1,
              height: 32,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.12),
            ),
            Expanded(
              child: _buildCompactStatCard(
                notesProvider.categories.length.toString(),
                'Kategori',
                Icons.category_outlined,
                AppColors.infoColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    final isActive = int.tryParse(value) != null && int.parse(value) > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: isActive ? color.withOpacity(0.13) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 14,
              color: isActive
                  ? color
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: AppTypography.labelLarge.copyWith(
              color: isActive
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters(NotesProvider notesProvider) {
    return Container(
      margin: AppSpacing.getPagePadding(
        MediaQuery.of(context).size.width,
      ).copyWith(bottom: 0, top: 0),
      child: Wrap(
        spacing: AppSpacing.sm,
        children: [
          if (notesProvider.searchQuery.isNotEmpty)
            Chip(
              label: Text('Pencarian: "${notesProvider.searchQuery}"'),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () => notesProvider.setSearchQuery(''),
              backgroundColor: AppColors.primaryColor.withOpacity(0.1),
              labelStyle: TextStyle(color: AppColors.primaryColor),
            ),
          if (notesProvider.selectedCategory != null)
            Chip(
              label: Text('Kategori: ${notesProvider.selectedCategory}'),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () => notesProvider.setSelectedCategory(null),
              backgroundColor: AppColors.infoColor.withOpacity(0.1),
              labelStyle: TextStyle(color: AppColors.infoColor),
            ),
        ],
      ),
    );
  }

  Widget _buildNotesList(NotesProvider notesProvider) {
    final notes = notesProvider.notes;

    if (notes.isEmpty) {
      return SliverFillRemaining(child: _buildEmptyState());
    }

    return SliverPadding(
      padding: AppSpacing.getPagePadding(MediaQuery.of(context).size.width),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final note = notes[index];
          return _buildNoteCard(note);
        }, childCount: notes.length),
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showNoteDetail(note),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: note.isPinned
                    ? AppColors.warningColor.withOpacity(0.3)
                    : (isDarkMode
                          ? Colors.grey.withOpacity(0.2)
                          : Theme.of(
                              context,
                            ).colorScheme.outline.withOpacity(0.1)),
                width: note.isPinned ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withOpacity(0.3)
                      : Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (note.isPinned)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.warningColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.push_pin,
                          size: 16,
                          color: AppColors.warningColor,
                        ),
                      ),
                    if (note.isPinned) const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        note.title.isEmpty ? 'Tanpa Judul' : note.title,
                        style: AppTypography.titleMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      onSelected: (value) => _handleNoteAction(value, note),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'pin',
                          child: Row(
                            children: [
                              Icon(
                                note.isPinned
                                    ? Icons.push_pin
                                    : Icons.push_pin_outlined,
                                size: 18,
                                color: AppColors.warningColor,
                              ),
                              const SizedBox(width: 12),
                              Text(note.isPinned ? 'Hapus Pin' : 'Sematkan'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 12),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                                color: AppColors.errorColor,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Hapus',
                                style: TextStyle(color: AppColors.errorColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                if (note.content.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    note.content,
                    style: AppTypography.bodyMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: AppSpacing.md),

                Row(
                  children: [
                    if (note.category != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.infoColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          note.category!,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.infoColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Expanded(
                      child: Text(
                        _getRelativeTime(note.updatedAt),
                        style: AppTypography.labelSmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
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
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Container(
        margin: AppSpacing.getPagePadding(MediaQuery.of(context).size.width),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor.withOpacity(0.1),
                    AppColors.infoColor.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.note_add_outlined,
                    size: 32,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Belum Ada Catatan',
              style: AppTypography.headlineSmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Mulai menambahkan catatan untuk menyimpan ide, pemikiran, dan informasi penting Anda.',
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: _showAddNoteDialog,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Buat Catatan Pertama'),
              style: AppComponents.primaryButtonStyle(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Container(
        margin: AppSpacing.getPagePadding(MediaQuery.of(context).size.width),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppColors.primaryColor,
              strokeWidth: 3,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Memuat catatan Anda...',
              style: AppTypography.bodyLarge.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Container(
        margin: AppSpacing.getPagePadding(MediaQuery.of(context).size.width),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.errorColor,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Terjadi Kesalahan',
              style: AppTypography.headlineMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error,
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: _loadNotes,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: AppComponents.primaryButtonStyle(),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddNoteDialog() {
    _showNoteDialog();
  }

  void _showNoteDialog({Note? note}) {
    final isEdit = note != null;
    final titleController = TextEditingController(text: note?.title ?? '');
    final contentController = TextEditingController(text: note?.content ?? '');
    final categoryController = TextEditingController(
      text: note?.category ?? '',
    );
    bool isPinned = note?.isPinned ?? false;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    NavigationHelper.safeShowModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          isEdit ? 'Edit Catatan' : 'Catatan Baru',
                          style: AppTypography.headlineSmall.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        // Title Field
                        TextField(
                          controller: titleController,
                          decoration: AppComponents.inputDecoration(
                            labelText: 'Judul Catatan',
                            hintText: 'Masukkan judul catatan',
                            prefixIcon: Icon(
                              Icons.title_rounded,
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                            colorScheme: Theme.of(context).colorScheme,
                          ),
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Category Field
                        TextField(
                          controller: categoryController,
                          decoration: AppComponents.inputDecoration(
                            labelText: 'Kategori (Opsional)',
                            hintText: 'Masukkan kategori',
                            prefixIcon: Icon(
                              Icons.category_outlined,
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                            colorScheme: Theme.of(context).colorScheme,
                          ),
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Pin Toggle
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDarkMode
                                  ? Colors.grey.withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Icon(
                              isPinned
                                  ? Icons.push_pin
                                  : Icons.push_pin_outlined,
                              color: isPinned ? AppColors.warningColor : null,
                            ),
                            title: const Text('Sematkan Catatan'),
                            subtitle: const Text(
                              'Catatan yang disematkan akan muncul di atas',
                            ),
                            trailing: Switch(
                              value: isPinned,
                              onChanged: (value) {
                                setState(() {
                                  isPinned = value;
                                });
                              },
                              activeColor: AppColors.warningColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Content Field
                        Expanded(
                          child: TextField(
                            controller: contentController,
                            decoration:
                                AppComponents.inputDecoration(
                                  labelText: 'Isi Catatan',
                                  hintText: 'Tulis catatan Anda di sini...',
                                  colorScheme: Theme.of(context).colorScheme,
                                ).copyWith(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: isDarkMode
                                          ? Colors.grey.withOpacity(0.3)
                                          : Colors.grey.withOpacity(0.3),
                                    ),
                                  ),
                                  alignLabelWithHint: true,
                                ),
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Action Buttons
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () => _saveNote(
                            context,
                            isEdit ? note : null,
                            titleController.text,
                            contentController.text,
                            categoryController.text.isEmpty
                                ? null
                                : categoryController.text,
                            isPinned,
                          ),
                          style: AppComponents.primaryButtonStyle().copyWith(
                            padding: const WidgetStatePropertyAll(
                              EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                          child: Text(isEdit ? 'Perbarui' : 'Simpan'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSearchDialog() {
    NavigationHelper.safeShowModalBottomSheet<void>(
      context: context,
      builder: (context) {
        final searchController = TextEditingController();
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cari Catatan',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: searchController,
                decoration: AppComponents.inputDecoration(
                  labelText: 'Kata kunci',
                  hintText: 'Cari berdasarkan judul, isi, atau tag',
                  prefixIcon: const Icon(Icons.search_rounded),
                  colorScheme: Theme.of(context).colorScheme,
                ),
                autofocus: true,
                onSubmitted: (query) {
                  Provider.of<NotesProvider>(
                    context,
                    listen: false,
                  ).setSearchQuery(query);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Provider.of<NotesProvider>(
                          context,
                          listen: false,
                        ).setSearchQuery(searchController.text);
                        Navigator.pop(context);
                      },
                      style: AppComponents.primaryButtonStyle(),
                      child: const Text('Cari'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNoteDetail(Note note) {
    NavigationHelper.safeShowModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.1),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    if (note.isPinned) ...[
                      Icon(
                        Icons.push_pin,
                        color: AppColors.warningColor,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Expanded(
                      child: Text(
                        note.title.isEmpty ? 'Tanpa Judul' : note.title,
                        style: AppTypography.headlineSmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showNoteDialog(note: note);
                      },
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Metadata
                      Row(
                        children: [
                          if (note.category != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.infoColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                note.category!,
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.infoColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
                          ],
                          Text(
                            _getDetailDateTime(note.updatedAt),
                            style: AppTypography.labelSmall.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Content
                      Text(
                        note.content.isEmpty
                            ? 'Tidak ada isi catatan.'
                            : note.content,
                        style: AppTypography.bodyLarge.copyWith(
                          color: note.content.isEmpty
                              ? Theme.of(context).colorScheme.onSurfaceVariant
                              : Theme.of(context).colorScheme.onSurface,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveNote(
    BuildContext context,
    Note? existingNote,
    String title,
    String content,
    String? category,
    bool isPinned,
  ) async {
    if (title.trim().isEmpty && content.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul atau isi catatan harus diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final notesProvider = Provider.of<NotesProvider>(context, listen: false);

      if (existingNote != null) {
        // Update existing note
        final updatedNote = existingNote.copyWith(
          title: title.trim(),
          content: content.trim(),
          category: category?.trim(),
          isPinned: isPinned,
        );
        await notesProvider.updateNote(existingNote.id, updatedNote);
      } else {
        // Create new note
        final newNote = Note(
          title: title.trim(),
          content: content.trim(),
          category: category?.trim(),
          isPinned: isPinned,
        );
        await notesProvider.addNote(newNote);
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existingNote != null
                ? 'Catatan berhasil diperbarui'
                : 'Catatan berhasil disimpan',
          ),
          backgroundColor: AppColors.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan catatan: $e'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  void _handleMenuAction(String action) {
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);

    switch (action) {
      case 'categories':
        _showCategoriesDialog();
        break;
      case 'clear_filters':
        notesProvider.clearFilters();
        break;
    }
  }

  void _showCategoriesDialog() {
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    final categories = notesProvider.categories;

    NavigationHelper.safeShowModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pilih Kategori',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (categories.isEmpty)
                Text(
                  'Belum ada kategori',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                )
              else
                ...categories.map(
                  (category) => ListTile(
                    leading: Icon(
                      Icons.category_outlined,
                      color: AppColors.infoColor,
                    ),
                    title: Text(category),
                    onTap: () {
                      notesProvider.setSelectedCategory(category);
                      Navigator.pop(context);
                    },
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleNoteAction(String action, Note note) async {
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);

    switch (action) {
      case 'pin':
        await notesProvider.togglePin(note.id);
        break;
      case 'edit':
        _showNoteDialog(note: note);
        break;
      case 'delete':
        _showDeleteConfirmation(note);
        break;
    }
  }

  void _showDeleteConfirmation(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Catatan'),
        content: Text(
          'Apakah Anda yakin ingin menghapus catatan "${note.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await Provider.of<NotesProvider>(
                  context,
                  listen: false,
                ).deleteNote(note.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Catatan berhasil dihapus'),
                    backgroundColor: AppColors.successColor,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal menghapus catatan: $e'),
                    backgroundColor: AppColors.errorColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  String _getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }

  String _getDetailDateTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hari ini, ${_indonesianTimeFormat.format(date)}';
    } else if (difference.inDays == 1) {
      return 'Kemarin, ${_indonesianTimeFormat.format(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return _indonesianShortDateFormat.format(date);
    }
  }
}
