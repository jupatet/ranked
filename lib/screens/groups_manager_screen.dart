import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/item_group.dart';

class GroupsManagerScreen extends StatefulWidget {
  final List<ItemGroup> groups;
  final Function(List<ItemGroup>) onGroupsChanged;

  const GroupsManagerScreen({
    super.key,
    required this.groups,
    required this.onGroupsChanged,
  });

  @override
  State<GroupsManagerScreen> createState() => _GroupsManagerScreenState();
}

class _GroupsManagerScreenState extends State<GroupsManagerScreen> {
  final _nameController = TextEditingController();
  List<ItemGroup> _groups = [];
  Color _selectedColor = Colors.blue;
  GroupIcon _selectedIcon = GroupIcon.folder;
  ItemGroup? _editingGroup;

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.amber,
    Colors.indigo,
    Colors.cyan,
  ];

  final List<GroupIcon> _availableIcons = GroupIcon.values;

  @override
  void initState() {
    super.initState();
    _groups = List.from(widget.groups);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addGroup() {
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter a group name');
      return;
    }

    setState(() {
      if (_editingGroup != null) {
        // Update existing group
        final index = _groups.indexWhere((g) => g.id == _editingGroup!.id);
        if (index != -1) {
          _groups[index] = ItemGroup(
            id: _editingGroup!.id,
            name: _nameController.text.trim(),
            color: _selectedColor,
            groupIcon: _selectedIcon,
          );
        }
        _editingGroup = null;
      } else {
        // Add new group
        final newGroup = ItemGroup(
          id: const Uuid().v4(),
          name: _nameController.text.trim(),
          color: _selectedColor,
          groupIcon: _selectedIcon,
        );
        _groups.add(newGroup);
      }
      
      _nameController.clear();
      _selectedColor = Colors.blue;
      _selectedIcon = GroupIcon.folder;
    });

    widget.onGroupsChanged(_groups);
  }

  void _editGroup(ItemGroup group) {
    setState(() {
      _editingGroup = group;
      _nameController.text = group.name;
      _selectedColor = group.color;
      _selectedIcon = group.groupIcon;
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingGroup = null;
      _nameController.clear();
      _selectedColor = Colors.blue;
      _selectedIcon = GroupIcon.folder;
    });
  }

  void _removeGroup(int index) {
    setState(() {
      _groups.removeAt(index);
    });
    widget.onGroupsChanged(_groups);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
                    'MANAGE GROUPS',
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

            // Add Group Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _editingGroup != null ? 'Edit Group' : 'New Group',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        if (_editingGroup != null) ...[
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _cancelEdit,
                            icon: const Icon(Icons.close, size: 16, color: Colors.white70),
                            label: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Group name',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _addGroup(),
                    ),
                    const SizedBox(height: 16),
                    
                    // Color Picker
                    Text(
                      'Color',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableColors.map((color) {
                        final isSelected = _selectedColor == color;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: Colors.white, width: 3)
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    
                    // Icon Picker
                    Text(
                      'Icon',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableIcons.map((groupIcon) {
                        final isSelected = _selectedIcon == groupIcon;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIcon = groupIcon;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: Icon(groupIcon.iconData, color: Colors.white, size: 20),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    
                    // Add Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addGroup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _editingGroup != null ? 'UPDATE GROUP' : 'ADD GROUP',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Groups List
            Expanded(
              child: _groups.isEmpty
                  ? Center(
                      child: Text(
                        'No groups yet',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _groups.length,
                      itemBuilder: (context, index) {
                        final group = _groups[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () => _editGroup(group),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: group.color,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      group.icon,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      group.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit_outlined,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                    onPressed: () => _editGroup(group),
                                    tooltip: 'Edit',
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                    onPressed: () => _removeGroup(index),
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
    );
  }
}
