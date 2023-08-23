import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list/categories.dart';
import 'package:shopping_list/widgets/new_item.dart';
import '../models/groceryItems_model.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
        'grocerylist-bcd58-default-rtdb.firebaseio.com', 'shopping-list.json');

    try{
      final response = await http.get(url);

      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to get data, please try again later';
        });
      }

      if(response.body == 'null'){
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> loadedItems = [];
      var category;
      listData.forEach((key, value) {
        String catStr = value['category'] ?? "";
        categories.forEach((key, value) {
          if (value.title == catStr) {
            category = value;
          }
        });
        loadedItems.add(GroceryItem(
            name: value['name'],
            category: category,
            quantity: value['quantity'],
            id: key));
      });
      // for (final item in listData.entries) {
      //   final category = categories.entries
      //       .firstWhere(
      //           (catItem) => catItem.value.title == item.value['category'])
      //       .value;
      //   loadedItems.add(GroceryItem(
      //       name: item.value['name'],
      //       category: category ,
      //       quantity: item.value['quantity'],
      //       id: item.key));
      // }
      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
      });
    } catch(e){
      setState(() {
        _error = 'Something went wrong!, please try again later';
      });
    }

  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (ctx) => const NewItem()));

    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem groceryItem) async {
    final index = _groceryItems.indexOf(groceryItem);

    setState(() {
      _groceryItems.remove(groceryItem);
    });

    final url = Uri.https('grocerylist-bcd58-default-rtdb.firebaseio.com',
        'shopping-list/${groceryItem.id}.json');
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, groceryItem);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('NO items were added'),
    );
    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (context, index) => Dismissible(
          key: ValueKey(_groceryItems[index].id),
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]);
          },
          child: ListTile(
            title: Text(
              _groceryItems[index].name,
              style: const TextStyle(fontSize: 20),
            ),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(
              _groceryItems[index].quantity.toString(),
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      content = Center(child: Text(_error!));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
              onPressed: () {
                _addItem();
              },
              icon: const Icon(Icons.add)),
        ],
      ),
      body: content,
    );
  }
}
