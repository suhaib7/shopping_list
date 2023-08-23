import 'package:shopping_list/models/categories_model.dart';

class GroceryItem {
  String id, name;
  int quantity;
  Category category;

  GroceryItem(
      {required this.name,
      required this.category,
      required this.quantity,
      required this.id});
}
