import 'dart:ui';

enum Categories{
  vegetables,
  fruit,
  meat,
  dairy,
  carbs,
  sweets,
  spices,
  convenience,
  hygiene,
  other
}

class Category{
  String title;
  Color color;

  Category(this.title,this.color);
}