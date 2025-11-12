import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import '../models/rankable_item.dart';
import '../models/item_group.dart';

class ItemsSetupScreen extends StatefulWidget {
  final List<RankableItem> items;
  final List<ItemGroup> groups;
  final Function(List<RankableItem>) onItemsChanged;

  const ItemsSetupScreen({
    super.key,
    required this.items,
    required this.groups,
    required this.onItemsChanged,
  });

  @override
  State<ItemsSetupScreen> createState() => _ItemsSetupScreenState();
}

class _ItemsSetupScreenState extends State<ItemsSetupScreen> {
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();
  List<RankableItem> _items = [];
  String? _selectedGroupId;
  RankableItem? _editingItem;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<RankableItem> get _filteredItems {
    if (_searchQuery.isEmpty) {
      return _items;
    }
    return _items.where((item) {
      final nameMatch = item.name.toLowerCase().contains(_searchQuery);
      final groupMatch = item.groupId != null
          ? widget.groups.any((g) => 
              g.id == item.groupId && 
              g.name.toLowerCase().contains(_searchQuery))
          : false;
      return nameMatch || groupMatch;
    }).toList();
  }

  void _addItem() {
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter a name');
      return;
    }

    setState(() {
      if (_editingItem != null) {
        // Update existing item
        final index = _items.indexWhere((item) => item.id == _editingItem!.id);
        if (index != -1) {
          _items[index] = _editingItem!.copyWith(
            name: _nameController.text.trim(),
            groupId: _selectedGroupId,
          );
        }
        _editingItem = null;
      } else {
        // Add new item
        final newItem = RankableItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text.trim(),
          groupId: _selectedGroupId,
        );
        _items.add(newItem);
      }
      
      _nameController.clear();
      _selectedGroupId = null;
    });

    widget.onItemsChanged(_items);
  }

  void _editItem(RankableItem item) {
    setState(() {
      _editingItem = item;
      _nameController.text = item.name;
      _selectedGroupId = item.groupId;
    });
    
    // Scroll to top to show the form
    // Note: In a real implementation, you might want to use a ScrollController
  }

  void _cancelEdit() {
    setState(() {
      _editingItem = null;
      _nameController.clear();
      _selectedGroupId = null;
    });
  }

  void _removeItem(RankableItem item) {
    setState(() {
      _items.removeWhere((i) => i.id == item.id);
    });
    widget.onItemsChanged(_items);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
                    'ADD ITEMS TO RANK',
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
            FCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _editingItem != null ? 'Edit Item' : 'Add New Item',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_editingItem != null) ...[
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _cancelEdit,
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text('Cancel'),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Item Name',
                        hintText: 'Enter person or object name',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _addItem(),
                    ),
                    if (widget.groups.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String?>(
                        value: _selectedGroupId,
                        decoration: const InputDecoration(
                          labelText: 'Group (Optional)',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('No Group'),
                          ),
                          ...widget.groups.map((group) => DropdownMenuItem<String?>(
                            value: group.id,
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: group.color,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    group.icon,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(group.name),
                              ],
                            ),
                          )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGroupId = value;
                          });
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: Container()),
                        FButton(
                          onPress: _addItem,
                          child: Text(_editingItem != null ? 'Update' : 'Add'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Items (${_filteredItems.length}${_searchQuery.isNotEmpty ? ' of ${_items.length}' : ''})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Search field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search items',
                hintText: 'Search by name or group',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_filteredItems.isEmpty)
              Center(
                child: FCard(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _searchQuery.isNotEmpty 
                              ? Icons.search_off 
                              : Icons.inbox_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty 
                              ? 'No items found' 
                              : 'No items yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty 
                              ? 'Try a different search term' 
                              : 'Add at least 2 items to start ranking',
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
            else
              ..._filteredItems.map((item) {
                final group = item.groupId != null
                    ? widget.groups.firstWhere(
                        (g) => g.id == item.groupId,
                        orElse: () => ItemGroup(
                          id: '',
                          name: '',
                          color: Colors.grey,
                        ),
                      )
                    : null;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: FCard(
                    child: ListTile(
                      onTap: () => _editItem(item),
                      leading: group != null
                          ? Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: group.color,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                group.icon,
                                color: Colors.white,
                                size: 20,
                              ),
                            )
                          : CircleAvatar(
                              child: Text(
                                item.name[0].toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                      title: Text(item.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Rating: ${item.rating.toStringAsFixed(0)}'),
                          if (group != null && group.name.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                'Group: ${group.name}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: group.color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _editItem(item),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _removeItem(item),
                            tooltip: 'Delete',
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            
            const SizedBox(height: 80), // Space for bottom button
          ],
        ),
              ),
            ),
            
            // Bottom Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FButton(
                onPress: _items.length >= 2 ? () => Navigator.pop(context) : null,
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
