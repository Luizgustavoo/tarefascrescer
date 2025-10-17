import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tarefas_projetocrescer/models/status.dart';
import 'package:tarefas_projetocrescer/providers/project_provider.dart';
import 'package:tarefas_projetocrescer/providers/project_status_provider.dart';
import 'package:tarefas_projetocrescer/screens/widgets/color_selector.dart';
import '../../models/project.dart';
import '../../providers/auth_provider.dart';

class AddProjectModal extends StatefulWidget {
  const AddProjectModal({super.key});

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
  final _valorApresentadoController = TextEditingController();
  final _valorAprovadoController = TextEditingController();
  final _totalColetadoController = TextEditingController();

  DateTime? _presentationDateTime,
      _approvalDateTime,
      _accountabilityDateTime,
      _collectionStartDateTime,
      _collectionEndDateTime,
      _executionStartDateTime,
      _executionEndDateTime;

  String _selectedColor = '#F8BBD0';

  Status? _selectedSituacao;
  static const String _addNewSituacaoKey = 'ADD_NEW_SITUACAO';
  bool isInitialLoad = true;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<ProjectStatusProvider>(
        context,
        listen: false,
      ).fetchStatuses(Provider.of<AuthProvider>(context, listen: false));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (isInitialLoad) {
      final statusProvider = Provider.of<ProjectStatusProvider>(context);
      if (statusProvider.statuses.isNotEmpty) {
        setState(() {
          _selectedSituacao ??= statusProvider.statuses.first;
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
    void Function(DateTime) onDateSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      onDateSelected(picked);

      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _showAddSituacaoDialog() async {
    final newSituacaoController = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();

    final String? newSituacaoName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nova Situação'),
        content: Form(
          key: dialogFormKey,
          child: TextFormField(
            controller: newSituacaoController,
            decoration: const InputDecoration(hintText: 'Nome da situação'),
            autofocus: true,
            validator: (value) =>
                value == null || value.isEmpty ? 'Campo obrigatório' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (dialogFormKey.currentState!.validate()) {
                Navigator.of(
                  dialogContext,
                ).pop(newSituacaoController.text.toUpperCase());
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (newSituacaoName != null && newSituacaoName.isNotEmpty && mounted) {
      final statusProvider = Provider.of<ProjectStatusProvider>(
        context,
        listen: false,
      );
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final Status? newStatus = await statusProvider.registerStatus(
        newSituacaoName,
        authProvider,
      );

      if (newStatus != null && mounted) {
        setState(() {
          _selectedSituacao = newStatus;
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cadastrar status.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final projectProvider = context.read<ProjectProvider>();

    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: Usuário não autenticado.')),
      );
      return;
    }

    String formatDateForApi(DateTime? dt) {
      if (dt == null) return '';
      return DateFormat('yyyy-MM-dd').format(dt);
    }

    final newProject = Project(
      name: _nomeController.text,
      fiscalResponsible: _responsavelFiscalController.text,
      statusId: _selectedSituacao!.id,
      status: _selectedSituacao,
      presentationDate: formatDateForApi(_presentationDateTime),
      presentedValue: double.tryParse(_valorApresentadoController.text) ?? 0.0,
      approvalDate: formatDateForApi(_approvalDateTime),
      approvedValue: double.tryParse(_valorAprovadoController.text),
      accountabilityDate: formatDateForApi(_accountabilityDateTime),
      collectionStartDate: formatDateForApi(_collectionStartDateTime),
      collectionEndDate: formatDateForApi(_collectionEndDateTime),
      totalCollected: double.tryParse(_totalColetadoController.text),
      executionStartDate: formatDateForApi(_executionStartDateTime),
      executionEndDate: formatDateForApi(_executionEndDateTime),
      observations: _observacoesController.text,
      createdBy: authProvider.user!.id,
      color: _selectedColor,
    );

    final success = await projectProvider.registerProject(
      newProject,
      authProvider,
    );

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
              projectProvider.errorMessage ?? 'Falha ao cadastrar projeto.',
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Novo Projeto',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                _buildTextField(
                  label: 'Nome Projeto/Emenda',
                  controller: _nomeController,
                ),
                _buildTextField(
                  label: 'Responsável Fiscal',
                  controller: _responsavelFiscalController,
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ColorSelector(
                    initialColor: _selectedColor,
                    onColorSelected: (newColor) {
                      setState(() {
                        _selectedColor = newColor;
                      });
                    },
                  ),
                ),

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
                      value: _selectedSituacao,
                      isExpanded: true,
                      hint: const Text('Carregando...'),
                      items: [
                        ...statusProvider.statuses.map((Status status) {
                          return DropdownMenuItem<dynamic>(
                            value: status,
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
                        } else if (newValue is Status) {
                          setState(() => _selectedSituacao = newValue);
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Situação',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      validator: (value) =>
                          value == null ? 'Selecione uma situação' : null,
                    ),
                  ),

                _buildDatePickerField(
                  label: 'Data Apresentação',
                  controller: _dataApresentacaoController,
                  onDateSelected: (date) => _presentationDateTime = date,
                ),
                _buildDatePickerField(
                  label: 'Data Aprovação',
                  controller: _dataAprovacaoController,
                  onDateSelected: (date) => _approvalDateTime = date,
                ),
                _buildDatePickerField(
                  label: 'Data Prestação de contas',
                  controller: _dataPrestacaoContasController,
                  onDateSelected: (date) => _accountabilityDateTime = date,
                ),
                _buildDatePickerField(
                  label: 'Início Captação',
                  controller: _inicioCaptacaoController,
                  onDateSelected: (date) => _collectionStartDateTime = date,
                ),
                _buildDatePickerField(
                  label: 'Final Captação',
                  controller: _finalCaptacaoController,
                  onDateSelected: (date) => _collectionEndDateTime = date,
                ),

                const Text(
                  "Período de Execução",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildDatePickerField(
                        label: 'Início',
                        controller: _inicioExecucaoController,
                        isDense: true,
                        onDateSelected: (date) =>
                            _executionStartDateTime = date,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDatePickerField(
                        label: 'Fim',
                        controller: _fimExecucaoController,
                        isDense: true,
                        onDateSelected: (date) => _executionEndDateTime = date,
                      ),
                    ),
                  ],
                ),

                _buildTextField(
                  label: 'Observações',
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
                    onPressed: _saveProject,
                    child: const Text('Salvar Projeto'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    int maxLines = 1,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: maxLines > 1,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Este campo é obrigatório' : null,
      ),
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required TextEditingController controller,
    required void Function(DateTime) onDateSelected,
    bool isDense = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          suffixIcon: const Icon(Icons.calendar_today),
          isDense: isDense,
        ),
        onTap: () => _selectDate(context, controller, onDateSelected),
        validator: (value) =>
            value == null || value.isEmpty ? 'Selecione uma data' : null,
      ),
    );
  }
}
