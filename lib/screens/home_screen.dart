import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tarefas_projetocrescer/models/project_category_model.dart';
import 'package:tarefas_projetocrescer/providers/auth_provider.dart';
import 'package:tarefas_projetocrescer/providers/graph_provider.dart';
import 'package:tarefas_projetocrescer/providers/project_category_provider.dart';
import 'package:tarefas_projetocrescer/providers/project_provider.dart';
import 'package:tarefas_projetocrescer/providers/recent_task_provider.dart';
import 'package:tarefas_projetocrescer/screens/project_list_screen.dart';
import 'package:tarefas_projetocrescer/screens/widgets/add_new_item_dialog.dart';
import 'package:tarefas_projetocrescer/screens/widgets/project_graph.dart';
import 'package:tarefas_projetocrescer/screens/widgets/recent_task_card.dart';
import 'widgets/home_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final authProvider = context.read<AuthProvider>();

      context.read<RecentTaskProvider>().fetchRecentTasks(authProvider);
      context.read<GraphProvider>().fetchGraphData(authProvider);

      context.read<ProjectCategoryProvider>().fetchCategories(authProvider);
    });
  }

  void _filterProjects(String query) {}

  Future<void> _showEditCategoryDialog(ProjectCategoryModel category) async {
    final String? newCategoryName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AddNewItemDialog(
        title: 'Editar Categoria',
        initialValue: category.name,
      ),
    );

    if (newCategoryName != null &&
        newCategoryName.isNotEmpty &&
        newCategoryName != category.name &&
        mounted) {
      final categoryProvider = context.read<ProjectCategoryProvider>();
      final authProvider = context.read<AuthProvider>();

      final success = await categoryProvider.updateCategory(
        category.id,
        newCategoryName,
        authProvider,
      );

      if (mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              categoryProvider.errorMessage ?? 'Erro ao atualizar categoria.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmAndDeleteCategory(ProjectCategoryModel category) async {
    final warningMessage = category.projects.isEmpty
        ? 'Tem certeza que deseja excluir a categoria "${category.name}"?'
        : 'Esta categoria contém ${category.projects.length} projeto(s).\n\nA exclusão pode falhar se houver projetos associados.\n\nDeseja continuar?';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(warningMessage),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final categoryProvider = context.read<ProjectCategoryProvider>();
      final authProvider = context.read<AuthProvider>();

      final success = await categoryProvider.deleteCategory(
        category.id,
        authProvider,
      );

      if (mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              categoryProvider.errorMessage ?? 'Falha ao excluir categoria.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      } else if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Categoria excluída com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<ProjectCategoryProvider>();
    final recentTaskProvider = context.watch<RecentTaskProvider>();
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: const EdgeInsets.all(24.0),
              child: HomeHeader(onSearchChanged: _filterProjects),
            ),
            Expanded(
              child: categoryProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () async {
                        final authProvider = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );

                        await Future.wait([
                          context
                              .read<ProjectCategoryProvider>()
                              .fetchCategories(authProvider),
                          Provider.of<ProjectProvider>(
                            context,
                            listen: false,
                          ).fetchProjects(authProvider),
                          Provider.of<GraphProvider>(
                            context,
                            listen: false,
                          ).fetchGraphData(authProvider),
                          Provider.of<RecentTaskProvider>(
                            context,
                            listen: false,
                          ).fetchRecentTasks(authProvider),
                        ]);
                      },
                      child: ListView(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        children: [
                          SizedBox(height: 230, child: ProjectValuesPieChart()),
                          const SizedBox(height: 32),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.0),
                            child: Text(
                              'Recentes movimentados',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 120,
                            child: _buildRecentTasksList(recentTaskProvider),
                          ),

                          const SizedBox(height: 16),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.0),
                            child: Text(
                              'Categorias',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildCategoryList(categoryProvider),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTasksList(RecentTaskProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (provider.errorMessage != null) {
      return Center(
        child: Text(
          provider.errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    if (provider.recentTasks.isEmpty) {
      return const Center(child: Text('Nenhuma tarefa recente.'));
    }
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      itemCount: provider.recentTasks.length,
      itemBuilder: (context, index) {
        final task = provider.recentTasks[index];
        return Padding(
          padding: EdgeInsets.only(
            right: index < provider.recentTasks.length - 1 ? 16.0 : 0,
          ),
          child: RecentTaskCard(task: task),
        );
      },
    );
  }

  Widget _buildCategoryList(ProjectCategoryProvider provider) {
    if (provider.isLoading && provider.categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null) {
      return Center(
        child: Text(
          'Erro: ${provider.errorMessage}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    if (provider.categories.isEmpty) {
      return const Center(child: Text('Nenhuma categoria cadastrada.'));
    }

    return ListView.separated(
      itemCount: provider.categories.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final category = provider.categories[index];

        return _buildCategoryCard(category);
      },
    );
  }

  Widget _buildCategoryCard(ProjectCategoryModel category) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectListScreen(category: category),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 8.0,
          top: 12.0,
          bottom: 12.0,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      overflow: TextOverflow.ellipsis,
                      color: Color(0xFF303030),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${category.projects.length} ${category.projects.length == 1 ? 'projeto' : 'projetos'}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),

            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 22,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: () {
                    _showEditCategoryDialog(category);
                  },
                  tooltip: 'Editar nome da categoria',
                  splashRadius: 20,
                  padding: const EdgeInsets.all(10),
                ),

                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 22,
                    color: Colors.red.shade600,
                  ),
                  onPressed: () {
                    _confirmAndDeleteCategory(category);
                  },
                  tooltip: 'Deletar categoria',
                  splashRadius: 20,
                  padding: const EdgeInsets.all(10),
                ),

                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
