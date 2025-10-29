import 'package:flutter/material.dart';

class AddNewItemDialog extends StatefulWidget {
  final String title;
  final String hintText;
  final String? initialValue;

  const AddNewItemDialog({
    super.key,
    required this.title,
    this.hintText = 'Nome',
    this.initialValue,
  });

  @override
  State<AddNewItemDialog> createState() => _AddNewItemDialogState();
}

class _AddNewItemDialogState extends State<AddNewItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _textController;
  @override
  void initState() {
    super.initState();

    _textController = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_textController.text.toUpperCase());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _textController,
          decoration: InputDecoration(hintText: widget.hintText),
          autofocus: true,
          validator: (value) =>
              value == null || value.isEmpty ? 'Campo obrigatório' : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Salvar')),
      ],
    );
  }
}
