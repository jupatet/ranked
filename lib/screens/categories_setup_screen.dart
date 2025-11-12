import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import '../models/category.dart';
import '../models/question.dart';

class CategoriesSetupScreen extends StatefulWidget {
  final List<Category> categories;
  final Function(List<Category>) onCategoriesChanged;

  const CategoriesSetupScreen({
    super.key,
    required this.categories,
    required this.onCategoriesChanged,
  });

  @override
  State<CategoriesSetupScreen> createState() => _CategoriesSetupScreenState();
}

class _CategoriesSetupScreenState extends State<CategoriesSetupScreen> {
  final _categoryController = TextEditingController();
  final _questionController = TextEditingController();
  List<Category> _categories = [];
  Category? _selectedCategory;
  Category? _editingCategory;
  Question? _editingQuestion;

  @override
  void initState() {
    super.initState();
    _categories = List.from(widget.categories);
    if (_categories.isNotEmpty) {
      _selectedCategory = _categories.first;
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  void _addCategory() {
    if (_categoryController.text.trim().isEmpty) {
      _showError('Please enter a category name');
      return;
    }

    setState(() {
      if (_editingCategory != null) {
        // Update existing category
        final index = _categories.indexWhere((c) => c.id == _editingCategory!.id);
        if (index != -1) {
          _categories[index] = _editingCategory!.copyWith(
            name: _categoryController.text.trim(),
          );
          _selectedCategory = _categories[index];
        }
        _editingCategory = null;
      } else {
        // Add new category
        final newCategory = Category(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _categoryController.text.trim(),
          weight: 1.0,
          questions: [],
        );
        _categories.add(newCategory);
        _selectedCategory = newCategory;
      }
      _categoryController.clear();
    });

    widget.onCategoriesChanged(_categories);
  }

  void _editCategory(Category category) {
    setState(() {
      _editingCategory = category;
      _categoryController.text = category.name;
    });
  }

  void _cancelCategoryEdit() {
    setState(() {
      _editingCategory = null;
      _categoryController.clear();
    });
  }

  void _removeCategory(int index) {
    setState(() {
      if (_categories[index] == _selectedCategory) {
        _selectedCategory = null;
      }
      _categories.removeAt(index);
      if (_categories.isNotEmpty && _selectedCategory == null) {
        _selectedCategory = _categories.first;
      }
    });
    widget.onCategoriesChanged(_categories);
  }

  void _addQuestion() {
    if (_selectedCategory == null) {
      _showError('Please select or create a category first');
      return;
    }

    if (_questionController.text.trim().isEmpty) {
      _showError('Please enter a question');
      return;
    }

    setState(() {
      final index = _categories.indexOf(_selectedCategory!);
      
      if (_editingQuestion != null) {
        // Update existing question
        final questions = List<Question>.from(_selectedCategory!.questions);
        final questionIndex = questions.indexWhere((q) => q.id == _editingQuestion!.id);
        if (questionIndex != -1) {
          questions[questionIndex] = _editingQuestion!.copyWith(
            text: _questionController.text.trim(),
          );
          _categories[index] = _selectedCategory!.copyWith(questions: questions);
        }
        _editingQuestion = null;
      } else {
        // Add new question
        final newQuestion = Question(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: _questionController.text.trim(),
          categoryId: _selectedCategory!.id,
        );
        _categories[index] = _selectedCategory!.copyWith(
          questions: [..._selectedCategory!.questions, newQuestion],
        );
      }
      
      _selectedCategory = _categories[index];
      _questionController.clear();
    });

    widget.onCategoriesChanged(_categories);
  }

  void _editQuestion(Question question) {
    setState(() {
      _editingQuestion = question;
      _questionController.text = question.text;
    });
  }

  void _cancelQuestionEdit() {
    setState(() {
      _editingQuestion = null;
      _questionController.clear();
    });
  }

  void _removeQuestion(int questionIndex) {
    if (_selectedCategory == null) return;

    setState(() {
      final index = _categories.indexOf(_selectedCategory!);
      final updatedQuestions = List<Question>.from(
        _selectedCategory!.questions,
      );
      updatedQuestions.removeAt(questionIndex);
      _categories[index] = _selectedCategory!.copyWith(
        questions: updatedQuestions,
      );
      _selectedCategory = _categories[index];
    });

    widget.onCategoriesChanged(_categories);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  int _getTotalQuestions() {
    return _categories.fold(0, (sum, cat) => sum + cat.questions.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const Text(
                    'CATEGORIES & QUESTIONS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 4,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
            // Add Category Section
            FCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _editingCategory != null ? 'Edit Category' : 'Add Category',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_editingCategory != null) ...[
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _cancelCategoryEdit,
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text('Cancel'),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _categoryController,
                            decoration: const InputDecoration(
                              labelText: 'Category Name',
                              hintText: 'e.g., Skills, Personality',
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _addCategory(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FButton(
                          onPress: _addCategory,
                          child: Text(_editingCategory != null ? 'Update' : 'Add'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Categories List
            if (_categories.isNotEmpty) ...[
              const Text(
                'Select Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onLongPress: () => _editCategory(category),
                        child: FilterChip(
                          label: Text(
                            '${category.name} (${category.questions.length})',
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: Colors.white,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          checkmarkColor: Colors.black,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          deleteIcon: Icon(
                            Icons.close, 
                            size: 18,
                            color: isSelected ? Colors.black : Colors.white70,
                          ),
                          onDeleted: () => _removeCategory(index),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Add Question Section
            if (_selectedCategory != null)
              FCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _editingQuestion != null 
                                ? 'Edit Question'
                                : 'Add Question to ${_selectedCategory!.name}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_editingQuestion != null) ...[
                            const Spacer(),
                            TextButton.icon(
                              onPressed: _cancelQuestionEdit,
                              icon: const Icon(Icons.close, size: 16),
                              label: const Text('Cancel'),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _questionController,
                              decoration: const InputDecoration(
                                labelText: 'Question',
                                hintText: 'Who is more...?',
                                border: OutlineInputBorder(),
                              ),
                              onSubmitted: (_) => _addQuestion(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FButton(
                            onPress: _addQuestion,
                            child: Text(_editingQuestion != null ? 'Update' : 'Add'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Questions List
            Text(
              'Questions (${_getTotalQuestions()} total)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child:
                  _selectedCategory == null ||
                      _selectedCategory!.questions.isEmpty
                  ? Center(
                      child: FCard(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.quiz_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _selectedCategory == null
                                    ? 'No category selected'
                                    : 'No questions yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add questions to compare items',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _selectedCategory!.questions.length,
                      itemBuilder: (context, index) {
                        final question = _selectedCategory!.questions[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: FCard(
                            child: ListTile(
                              onTap: () => _editQuestion(question),
                              leading: const Icon(Icons.quiz),
                              title: Text(question.text),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed: () => _editQuestion(question),
                                    tooltip: 'Edit',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => _removeQuestion(index),
                                    tooltip: 'Delete',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
              ),
            ),
            
            // Bottom Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FButton(
                onPress: _getTotalQuestions() >= 1
                    ? () => Navigator.pop(context)
                    : null,
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
