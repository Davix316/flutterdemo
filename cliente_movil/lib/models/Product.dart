class ProductView {
  final int id;
  final String name;
  final String dimensions;
  final String texture;
  // ignore: non_constant_identifier_names
  final String consumption_time;
  // ignore: non_constant_identifier_names
  final String img_url;
  final String description;
  // ignore: non_constant_identifier_names
  final int package_amount;
  final Category category;

  ProductView(
      this.id,
      this.name,
      this.dimensions,
      this.texture,
      this.consumption_time,
      this.img_url,
      this.description,
      this.package_amount,
      this.category);
}

class Category {
  final int id;
  final String name;

  Category(this.id, this.name);
}
