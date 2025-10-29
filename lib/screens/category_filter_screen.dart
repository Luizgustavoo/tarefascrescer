// FILE: lib/screens/category_filter_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tarefas_projetocrescer/models/project.dart';
import 'package:tarefas_projetocrescer/models/project_category_model.dart';
import 'package:tarefas_projetocrescer/providers/auth_provider.dart';
import 'package:tarefas_projetocrescer/providers/project_category_provider.dart';
import 'package:tarefas_projetocrescer/screens/widgets/project_card.dart';

class CategoryFilterScreen extends StatefulWidget {
  const CategoryFilterScreen({super.key});

  @override
  State<CategoryFilterScreen> createState() => _CategoryFilterScreenState();
}

class _CategoryFilterScreenState extends State<CategoryFilterScreen> {
  // Armazena a categoria selecionada localmente
  ProjectCategoryModel? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Busca as categorias ao iniciar a tela
    Future.microtask(() {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<ProjectCategoryProvider>(
        context,
        listen: false,
      ).fetchCategories(authProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<ProjectCategoryProvider>();

    // Lista de projetos a ser exibida, baseada na categoria selecionada
    final List<Project> projectsToShow = _selectedCategory?.projects ?? [];

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Projetos por Categoria'),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
        ),
        body: Column(
          children: [
            // --- Dropdown de Seleção de Categoria ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child:
                  categoryProvider.isLoading &&
                      categoryProvider.categories.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : DropdownButtonFormField<ProjectCategoryModel>(
                      value: _selectedCategory,
                      hint: const Text(
                        'Selecione uma categoria para filtrar...',
                      ),
                      isExpanded: true,
                      items: categoryProvider.categories.map((
                        ProjectCategoryModel category,
                      ) {
                        return DropdownMenuItem<ProjectCategoryModel>(
                          value: category,
                          child: Text(
                            category.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (newCategory) {
                        setState(() {
                          _selectedCategory = newCategory;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Categoria',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                    ),
            ),

            // --- Lista de Projetos Filtrados ---
            Expanded(
              child: _selectedCategory == null
                  ? const Center(child: Text('Selecione uma categoria acima.'))
                  : projectsToShow.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum projeto encontrado para esta categoria.',
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: projectsToShow.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final project = projectsToShow[index];
                        final cardColor = index.isEven
                            ? Colors.white
                            : const Color(0xFFFFF1F3);
                        return ProjectCard(
                          project: project,
                          backgroundColor: cardColor,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
