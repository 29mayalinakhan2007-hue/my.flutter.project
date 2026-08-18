import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flashcard.dart';
import '../providers/flashcard_provider.dart';
import '../theme/app_colors.dart';

class AddEditCardScreen extends StatefulWidget {
  final Flashcard? card;

  const AddEditCardScreen({super.key, this.card});

  @override
  State<AddEditCardScreen> createState() => _AddEditCardScreenState();
}

class _AddEditCardScreenState extends State<AddEditCardScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _question;
  late String _answer;
  late String _category;

  @override
  void initState() {
    super.initState();
    _question = widget.card?.question ?? '';
    _answer = widget.card?.answer ?? '';
    _category = widget.card?.category ?? 'Computer Science';
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final provider = Provider.of<FlashcardProvider>(context, listen: false);

      if (widget.card == null) {
        provider.addCard(Flashcard(
          question: _question,
          answer: _answer,
          category: _category,
        ));
      } else {
        provider.updateCard(widget.card!.copyWith(
          question: _question,
          answer: _answer,
          category: _category,
        ));
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.card == null ? 'Create Flashcard' : 'Edit Flashcard')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _question,
                decoration: const InputDecoration(labelText: 'Question'),
                validator: (val) => val!.isEmpty ? 'Enter a question' : null,
                onSaved: (val) => _question = val!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _answer,
                decoration: const InputDecoration(labelText: 'Answer'),
                validator: (val) => val!.isEmpty ? 'Enter an answer' : null,
                onSaved: (val) => _answer = val!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                items: ['Computer Science', 'Mathematics', 'Science', 'English']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => _category = val!),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _save,
                child: const Text('Save Flashcard', style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }
}