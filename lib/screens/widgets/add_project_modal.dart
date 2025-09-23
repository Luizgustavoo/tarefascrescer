import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AddProjectModal extends StatefulWidget {
  const AddProjectModal({super.key});

  @override
  State<AddProjectModal> createState() => _AddProjectModalState();
}

class _AddProjectModalState extends State<AddProjectModal> {
  final TextEditingController _dataApresentacaoController =
      TextEditingController();
  final TextEditingController _dataAprovacaoController =
      TextEditingController();
  final TextEditingController _dataPrestacaoContasController =
      TextEditingController();
  final TextEditingController _inicioCaptacaoController =
      TextEditingController();
  final TextEditingController _finalCaptacaoController =
      TextEditingController();
  final TextEditingController _inicioExecucaoController =
      TextEditingController();
  final TextEditingController _fimExecucaoController = TextEditingController();

  final List<String> _situacoes = ['EM ANDAMENTO', 'PAUSADO', 'FINALIZADO'];
  String? _selectedSituacao;

  @override
  void initState() {
    super.initState();
    _selectedSituacao = _situacoes.first;
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Novo Projeto',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 24),

            _buildTextField(label: 'Nome Projeto/Emenda'),

            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: DropdownButtonFormField<String>(
                value: _selectedSituacao,
                items: _situacoes.map((String situacao) {
                  return DropdownMenuItem<String>(
                    value: situacao,
                    child: Text(situacao),
                  );
                }).toList(),
                onChanged: (newValue) =>
                    setState(() => _selectedSituacao = newValue),
                decoration: const InputDecoration(
                  labelText: 'Situação',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
            ),

            _buildDatePickerField(
              label: 'Data Apresentação',
              controller: _dataApresentacaoController,
            ),
            _buildCurrencyField(label: 'Valor apresentado'),
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
            _buildCurrencyField(label: 'Total captado'),

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

            _buildTextField(label: 'Contempla', maxLines: 3),
            _buildTextField(label: 'Contatos', maxLines: 3),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A3DE8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Salvar Projeto'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: maxLines > 1,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
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
      ),
    );
  }

  Widget _buildCurrencyField({required String label}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\,?\d{0,2}')),
        ],
        decoration: InputDecoration(
          labelText: label,
          prefixText: 'R\$ ',
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
    );
  }
}
