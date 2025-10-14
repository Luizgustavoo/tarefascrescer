// FILE: lib/screens/widgets/add_project_modal.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tarefas_projetocrescer/models/status.dart';
import 'package:tarefas_projetocrescer/providers/status_provider.dart';
import '../../models/project.dart';
import '../../providers/auth_provider.dart';

class AddProjectModal extends StatefulWidget {
  final Function(Project) onProjectSaved;
  const AddProjectModal({super.key, required this.onProjectSaved});

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

  Status? _selectedSituacao;
  static const String _addNewSituacaoKey = 'ADD_NEW_SITUACAO';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<ProjectStatusProvider>(
        context,
        listen: false,
      ).fetchStatuses(authProvider);
    });
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
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
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

      // Chama o provider para registrar. Ele retorna o novo objeto ProjectStatus.
      final Status? newStatus = await statusProvider.registerStatus(
        newSituacaoName,
        authProvider,
      );

      // Se o cadastro funcionou, usa o objeto retornado para atualizar o estado local.
      if (newStatus != null && mounted) {
        setState(() {
          _selectedSituacao = newStatus;
        });
      } else if (mounted) {
        // Mostra um erro se o cadastro falhar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cadastrar status.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _saveProject() {
    if (_formKey.currentState!.validate()) {
      // Cria o objeto Project com os dados dos controllers
      final newProject = Project(
        name: _nomeController.text,
        status:
            _selectedSituacao?.name ??
            'Não definido', // Pega o nome do objeto selecionado
        responsavelFiscal: _responsavelFiscalController.text,
        dataApresentacao: _dataApresentacaoController.text,
        dataAprovacao: _dataAprovacaoController.text,
        dataPrestacaoContas: _dataPrestacaoContasController.text,
        finalCaptacao: _finalCaptacaoController.text,
        totalCaptado: 0.0, // Adicione o controller de valor se necessário
        inicioExecucao: _inicioExecucaoController.text,
        fimExecucao: _fimExecucaoController.text,
        contempla: '', // Adicione o controller de contempla se necessário
        observacoes: _observacoesController.text,
      );

      widget.onProjectSaved(newProject);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuta o provider para obter a lista de status e o estado de carregamento
    final statusProvider = context.watch<ProjectStatusProvider>();

    // Lógica para definir o valor inicial do dropdown após o carregamento
    if (_selectedSituacao == null && statusProvider.statuses.isNotEmpty) {
      _selectedSituacao = statusProvider.statuses.first;
    }

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
                      // ALTERADO: Lógica de seleção mais segura
                      // Ele verifica se o item selecionado AINDA existe na lista. Se não, fica nulo.
                      value:
                          (_selectedSituacao != null &&
                              statusProvider.statuses.contains(
                                _selectedSituacao,
                              ))
                          ? _selectedSituacao
                          : null,
                      hint: const Text(
                        'Selecione uma situação',
                      ), // Mostra um texto quando nada está selecionado
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
                ),
                _buildDatePickerField(
                  label: 'Data Aprovação',
                  controller: _dataAprovacaoController,
                ),
                _buildDatePickerField(
                  label: 'Data Prestação de contas',
                  controller: _dataPrestacaoContasController,
                ),
                _buildDatePickerField(
                  label: 'Início Captação',
                  controller: _inicioCaptacaoController,
                ),
                _buildDatePickerField(
                  label: 'Final Captação',
                  controller: _finalCaptacaoController,
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
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDatePickerField(
                        label: 'Fim',
                        controller: _fimExecucaoController,
                        isDense: true,
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

  // Seus widgets helpers (com validator adicionado)
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
        onTap: () => _selectDate(context, controller),
        validator: (value) =>
            value == null || value.isEmpty ? 'Selecione uma data' : null,
      ),
    );
  }
}
