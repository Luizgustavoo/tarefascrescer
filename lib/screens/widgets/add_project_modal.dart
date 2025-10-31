import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tarefas_projetocrescer/models/project_category_model.dart';
import 'package:tarefas_projetocrescer/models/status.dart';
import 'package:tarefas_projetocrescer/providers/project_category_provider.dart';
import 'package:tarefas_projetocrescer/providers/project_status_provider.dart';
import 'package:tarefas_projetocrescer/screens/widgets/add_new_item_dialog.dart';
import 'package:tarefas_projetocrescer/screens/widgets/color_selector.dart';
import 'package:tarefas_projetocrescer/utils/formatters.dart';
import '../../models/project.dart';
import '../../providers/auth_provider.dart';

class AddProjectModal extends StatefulWidget {
  final Project? projectToEdit;

  const AddProjectModal({super.key, this.projectToEdit});

  @override
  State<AddProjectModal> createState() => _AddProjectModalState();
}

class _AddProjectModalState extends State<AddProjectModal> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _responsavelFiscalController = TextEditingController();
  final _observacoesController = TextEditingController();
  final _dataApresentacaoController = TextEditingController();
  final _dataAprovacaoController = TextEditingController();
  final _dataPrestacaoContasController = TextEditingController();
  final _inicioCaptacaoController = TextEditingController();
  final _finalCaptacaoController = TextEditingController();
  final _inicioExecucaoController = TextEditingController();
  final _fimExecucaoController = TextEditingController();

  final _valorApresentadoController = MoneyMaskedTextController(
    decimalSeparator: ',',
    thousandSeparator: '.',
  );
  final _valorAprovadoController = MoneyMaskedTextController(
    decimalSeparator: ',',
    thousandSeparator: '.',
  );
  final _totalColetadoController = MoneyMaskedTextController(
    decimalSeparator: ',',
    thousandSeparator: '.',
  );

  int? selectedSituacaoId;
  int? selectedCategoryId;
  String _selectedColor = '#F8BBD0';
  static const String _addNewSituacaoKey = 'ADD_NEW_SITUACAO';
  static const String _addNewCategoryKey = 'ADD_NEW_CATEGORIA';
  bool isInitialLoad = true;
  bool get _isEditing => widget.projectToEdit != null;
  final AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    _selectedColor = (_isEditing ? widget.projectToEdit!.color : '#F8BBD0');
    if (_isEditing) {
      final project = widget.projectToEdit!;
      _nomeController.text = project.name;
      _responsavelFiscalController.text = project.fiscalResponsible;
      _observacoesController.text = project.observations;

      _dataApresentacaoController.text = Formatters.formatApiDate(
        project.presentationDate,
      );
      _dataAprovacaoController.text = Formatters.formatApiDate(
        project.approvalDate,
      );
      _dataPrestacaoContasController.text = Formatters.formatApiDate(
        project.accountabilityDate,
      );
      _inicioCaptacaoController.text = Formatters.formatApiDate(
        project.collectionStartDate,
      );
      _finalCaptacaoController.text = Formatters.formatApiDate(
        project.collectionEndDate,
      );
      _inicioExecucaoController.text = Formatters.formatApiDate(
        project.executionStartDate,
      );
      _fimExecucaoController.text = Formatters.formatApiDate(
        project.executionEndDate,
      );

      _valorApresentadoController.updateValue(project.presentedValue);
      _valorAprovadoController.updateValue(project.approvedValue ?? 0.0);
      _totalColetadoController.updateValue(project.totalCollected ?? 0.0);

      selectedSituacaoId = project.statusId;
      selectedCategoryId = project.categoryId;
    }
    Future.microtask(() {
      Provider.of<ProjectStatusProvider>(
        context,
        listen: false,
      ).fetchStatuses(Provider.of<AuthProvider>(context, listen: false));

      Provider.of<ProjectCategoryProvider>(
        context,
        listen: false,
      ).fetchCategories(Provider.of<AuthProvider>(context, listen: false));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isInitialLoad) {
      final statusProvider = Provider.of<ProjectStatusProvider>(context);
      final categoryProvider = Provider.of<ProjectCategoryProvider>(context);

      if (statusProvider.statuses.isNotEmpty ||
          categoryProvider.categories.isNotEmpty) {
        setState(() {
          if (statusProvider.statuses.isNotEmpty) {
            if (_isEditing && selectedSituacaoId != null) {
              bool idExists = statusProvider.statuses.any(
                (s) => s.id == selectedSituacaoId,
              );
              if (!idExists)
                selectedSituacaoId = statusProvider.statuses.first.id;
            } else if (!_isEditing && selectedSituacaoId == null) {
              selectedSituacaoId = statusProvider.statuses.first.id;
            }
          }

          if (categoryProvider.categories.isNotEmpty) {
            if (_isEditing && selectedCategoryId != null) {
              bool idExists = categoryProvider.categories.any(
                (c) => c.id == selectedCategoryId,
              );
              if (!idExists)
                selectedCategoryId = categoryProvider.categories.first.id;
            } else if (!_isEditing && selectedCategoryId == null) {
              selectedCategoryId = categoryProvider.categories.first.id;
            }
          }
          isInitialLoad = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _responsavelFiscalController.dispose();
    _observacoesController.dispose();
    _dataApresentacaoController.dispose();
    _dataAprovacaoController.dispose();
    _dataPrestacaoContasController.dispose();
    _inicioCaptacaoController.dispose();
    _finalCaptacaoController.dispose();
    _inicioExecucaoController.dispose();
    _fimExecucaoController.dispose();
    _valorApresentadoController.dispose();
    _valorAprovadoController.dispose();
    _totalColetadoController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime initial = DateTime.now();
    try {
      if (controller.text.isNotEmpty)
        initial = DateFormat('dd/MM/yyyy').parseStrict(controller.text);
    } catch (e) {}

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(20101),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<String?> _showAddNewItemDialog({required String title}) async {
    return await showDialog<String>(
      context: context,
      builder: (dialogContext) => AddNewItemDialog(title: title),
    );
  }

  Future<void> _showAddSituacaoDialog() async {
    final String? newSituacaoName = await _showAddNewItemDialog(
      title: 'Nova Situação',
    );

    if (newSituacaoName != null && newSituacaoName.isNotEmpty && mounted) {
      final statusProvider = context.read<ProjectStatusProvider>();
      final authProvider = context.read<AuthProvider>();

      final Status? newStatus = await statusProvider.registerStatus(
        newSituacaoName,
        authProvider,
      );

      if (newStatus != null && mounted) {
        setState(() => selectedSituacaoId = newStatus.id);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              statusProvider.errorMessage ?? 'Erro ao cadastrar status.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showAddCategoryDialog() async {
    final String? newCategoryName = await _showAddNewItemDialog(
      title: 'Nova Categoria',
    );

    if (newCategoryName != null && newCategoryName.isNotEmpty && mounted) {
      final categoryProvider = context.read<ProjectCategoryProvider>();
      final authProvider = context.read<AuthProvider>();

      final ProjectCategoryModel? newCategory = await categoryProvider
          .registerCategory(newCategoryName, authProvider);

      if (newCategory != null && mounted) {
        setState(() => selectedCategoryId = newCategory.id);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              categoryProvider.errorMessage ?? 'Erro ao cadastrar categoria.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveOrUpdateProject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final statusProvider = context.read<ProjectStatusProvider>();
    final categoryProvider = context.read<ProjectCategoryProvider>();

    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: Usuário não autenticado.')),
      );
      return;
    }

    Status? selectedStatusObject;
    ProjectCategoryModel? selectedCategoryObject;

    try {
      selectedStatusObject = statusProvider.statuses.firstWhere(
        (s) => s.id == selectedSituacaoId,
      );
      selectedCategoryObject = categoryProvider.categories.firstWhere(
        (c) => c.id == selectedCategoryId,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: Status ou Categoria inválida.')),
      );
      return;
    }

    final projectData = Project(
      id: _isEditing ? widget.projectToEdit!.id : null,
      name: _nomeController.text,
      fiscalResponsible: _responsavelFiscalController.text,
      statusId: selectedSituacaoId!,
      categoryId: selectedCategoryId!,
      status: selectedStatusObject,
      category: selectedCategoryObject,
      presentationDate: Formatters.formatDateForApiFromString(
        _dataApresentacaoController.text,
      ),
      presentedValue: _valorApresentadoController.numberValue,
      approvalDate: Formatters.formatDateForApiFromString(
        _dataAprovacaoController.text,
      ),
      approvedValue: _valorAprovadoController.numberValue,
      accountabilityDate: Formatters.formatDateForApiFromString(
        _dataPrestacaoContasController.text,
      ),
      collectionStartDate: Formatters.formatDateForApiFromString(
        _inicioCaptacaoController.text,
      ),
      collectionEndDate: Formatters.formatDateForApiFromString(
        _finalCaptacaoController.text,
      ),
      totalCollected: _totalColetadoController.numberValue,
      executionStartDate: Formatters.formatDateForApiFromString(
        _inicioExecucaoController.text,
      ),
      executionEndDate: Formatters.formatDateForApiFromString(
        _fimExecucaoController.text,
      ),
      observations: _observacoesController.text,
      createdBy: _isEditing
          ? widget.projectToEdit!.createdBy
          : authProvider.user!.id,
      color: _selectedColor,
    );

    bool success;
    if (_isEditing) {
      success = await categoryProvider.updateProject(projectData, authProvider);
    } else {
      success = await categoryProvider.registerProject(
        projectData,
        authProvider,
      );
    }
    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Projeto cadastrado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              categoryProvider.errorMessage ?? 'Falha ao cadastrar projeto.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusProvider = context.watch<ProjectStatusProvider>();
    final categoryProvider = context.watch<ProjectCategoryProvider>();

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidateMode, // Usa a variável de estado
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'Editar Projeto' : 'Novo Projeto',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // NOVO: Texto de ajuda
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
                  child: Text(
                    'Preencha as informações abaixo. Campos com * são obrigatórios.',
                    style: TextStyle(fontSize: 14, color: Colors.red.shade600),
                  ),
                ),

                // --- Dropdown de Categoria ---
                if (categoryProvider.isLoading &&
                    categoryProvider.categories.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: DropdownButtonFormField<dynamic>(
                      value: selectedCategoryId,
                      hint: const Text('Selecione uma categoria'),
                      isExpanded: true,
                      items: [
                        ...categoryProvider.categories.map((
                          ProjectCategoryModel c,
                        ) {
                          return DropdownMenuItem<dynamic>(
                            value: c.id,
                            child: Text(c.name),
                          );
                        }),
                        const DropdownMenuItem<dynamic>(
                          enabled: false,
                          child: Divider(),
                        ),
                        DropdownMenuItem<dynamic>(
                          value: _addNewCategoryKey,
                          child: Row(
                            children: [
                              Icon(
                                Icons.add,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 8),
                              const Text('Cadastrar nova...'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (newValue) {
                        if (newValue == _addNewCategoryKey) {
                          _showAddCategoryDialog();
                        } else if (newValue is int) {
                          setState(() => selectedCategoryId = newValue);
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Categoria *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      validator: (value) =>
                          value == null || value == _addNewCategoryKey
                          ? 'Selecione uma categoria'
                          : null,
                    ),
                  ),

                // --- Campos de Texto ---
                // Adiciona 'isOptional: false' (ou omite) para campos obrigatórios
                _buildTextField(
                  label: 'Nome Projeto/Emenda *',
                  controller: _nomeController,
                ),
                _buildTextField(
                  label: 'Responsável Fiscal *',
                  controller: _responsavelFiscalController,
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ColorSelector(
                    initialColor: _selectedColor,
                    onColorSelected: (newColor) =>
                        setState(() => _selectedColor = newColor),
                  ),
                ),

                // --- Dropdown de Situação ---
                if (statusProvider.isLoading && statusProvider.statuses.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: DropdownButtonFormField<dynamic>(
                      hint: const Text('Selecione uma situação'),
                      isExpanded: true,
                      items: [
                        ...statusProvider.statuses.map((Status status) {
                          return DropdownMenuItem<dynamic>(
                            value: status.id,
                            child: Text(status.name),
                          );
                        }),
                        const DropdownMenuItem<dynamic>(
                          enabled: false,
                          child: Divider(),
                        ),
                        DropdownMenuItem<dynamic>(
                          value: _addNewSituacaoKey,
                          child: Row(
                            children: [
                              Icon(
                                Icons.add,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 8),
                              const Text('Cadastrar nova...'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (newValue) {
                        if (newValue == _addNewSituacaoKey) {
                          _showAddSituacaoDialog();
                        } else if (newValue is int) {
                          setState(() => selectedSituacaoId = newValue);
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Situação *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      validator: (value) =>
                          value == null || value == _addNewSituacaoKey
                          ? 'Selecione uma situação'
                          : null,
                    ),
                  ),

                // --- Campos de Data ---
                _buildDatePickerField(
                  label: 'Data Apresentação *',
                  controller: _dataApresentacaoController,
                ),
                _buildCurrencyField(
                  label: 'Valor Apresentado',
                  controller: _valorApresentadoController,
                  isOptional: true,
                ),
                _buildDatePickerField(
                  label: 'Data Aprovação',
                  controller: _dataAprovacaoController,
                  isOptional: true,
                ),
                _buildCurrencyField(
                  label: 'Valor Aprovado',
                  controller: _valorAprovadoController,
                  isOptional: true,
                ),
                _buildDatePickerField(
                  label: 'Data Prestação de contas',
                  controller: _dataPrestacaoContasController,
                  isOptional: true,
                ),
                _buildDatePickerField(
                  label: 'Início Captação',
                  controller: _inicioCaptacaoController,
                  isOptional: true,
                ),
                _buildDatePickerField(
                  label: 'Final Captação',
                  controller: _finalCaptacaoController,
                  isOptional: true,
                ),
                _buildCurrencyField(
                  label: 'Total Coletado',
                  controller: _totalColetadoController,
                  isOptional: true,
                ),

                const Text(
                  "Período de Execução *",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildDatePickerField(
                        label: 'Início',
                        controller: _inicioExecucaoController,
                        isDense: true,
                        isOptional: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDatePickerField(
                        label: 'Fim',
                        controller: _fimExecucaoController,
                        isDense: true,
                        isOptional: true,
                      ),
                    ),
                  ],
                ),

                _buildTextField(
                  label: 'Objetivo do projeto *',
                  maxLines: 3,
                  controller: _observacoesController,
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0XFFD932CE),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _saveOrUpdateProject,
                    child: Text(
                      _isEditing ? 'Salvar Alterações' : 'Salvar Projeto',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    IconData? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      alignLabelWithHint: true, // Melhora alinhamento
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      // Borda padrão
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
      ),
      // Borda quando focado
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 2.0,
        ),
      ),
      // Borda de ERRO
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.red, width: 1.5),
      ),
      // Borda de erro quando focado
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.red, width: 2.0),
      ),
      suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
    );
  }

  Widget _buildTextField({
    required String label,
    int maxLines = 1,
    TextEditingController? controller,
    bool isOptional = false, // NOVO
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: _buildInputDecoration(label: label), // Usa o helper
        validator: (value) {
          // Só valida se NÃO for opcional
          if (!isOptional && (value == null || value.isEmpty)) {
            return 'Este campo é obrigatório';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required TextEditingController controller,
    bool isDense = false,
    bool isOptional = false, // NOVO
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: _buildInputDecoration(
          label: label,
          suffixIcon: Icons.calendar_today,
        ).copyWith(isDense: isDense),
        onTap: () => _selectDate(context, controller),
        validator: (v) {
          if (!isOptional && (v == null || v.isEmpty))
            return 'Selecione uma data';
          if (v != null && v.isNotEmpty) {
            try {
              DateFormat('dd/MM/yyyy').parseStrict(v);
            } catch (e) {
              return 'Formato inválido (dd/MM/yyyy)';
            }
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCurrencyField({
    required String label,
    required TextEditingController controller,
    bool isOptional = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        // Adiciona um formatador simples para números
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
        ],
        decoration: InputDecoration(
          labelText: label,
          prefixText: 'R\$ ',
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        // Opcional: Formatar ao perder o foco
        onEditingComplete: () {
          final value = Formatters.parseCurrency(controller.text);
          if (value != null) {
            controller.text = Formatters.formatCurrency(value);
          }
        },
      ),
    );
  }
}
