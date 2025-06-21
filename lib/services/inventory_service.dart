import '../config/supabase_config.dart';
import '../models/product.dart';
import '../models/category.dart';

class InventoryService {
  // CRUD untuk Products
  Future<List<Product>> getProducts() async {
    try {
      final response = await supabase
          .from('products')
          .select()
          .order('created_at', ascending: false);

      return (response as List).map((item) => Product.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  Future<Product> createProduct(Product product) async {
    try {
      final response =
          await supabase
              .from('products')
              .insert(product.toJson())
              .select()
              .single();

      return Product.fromJson(response);
    } catch (e) {
      if (e.toString().contains('duplicate key')) {
        throw Exception('SKU already exists');
      }
      throw Exception('Failed to create product: $e');
    }
  }

  Future<Product> updateProduct(int id, Product product) async {
    try {
      final response =
          await supabase
              .from('products')
              .update({
                ...product.toJson(),
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', id)
              .select()
              .single();

      return Product.fromJson(response);
    } catch (e) {
      if (e.toString().contains('duplicate key')) {
        throw Exception('SKU already exists');
      }
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await supabase.from('products').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // CRUD untuk Categories
  Future<List<Category>> getCategories() async {
    try {
      final response = await supabase.from('categories').select().order('name');

      return (response as List).map((item) => Category.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  Future<Category> createCategory(Category category) async {
    try {
      final response =
          await supabase
              .from('categories')
              .insert(category.toJson())
              .select()
              .single();

      return Category.fromJson(response);
    } catch (e) {
      if (e.toString().contains('duplicate key')) {
        throw Exception('Category name already exists');
      }
      throw Exception('Failed to create category: $e');
    }
  }

  Future<Category> updateCategory(int id, Category category) async {
    try {
      final response =
          await supabase
              .from('categories')
              .update({
                ...category.toJson(),
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', id)
              .select()
              .single();

      return Category.fromJson(response);
    } catch (e) {
      if (e.toString().contains('duplicate key')) {
        throw Exception('Category name already exists');
      }
      throw Exception('Failed to update category: $e');
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      // Check if category is used by any products
      final products = await supabase
          .from('products')
          .select('id')
          .eq('category_id', id)
          .limit(1);

      if (products.isNotEmpty) {
        throw Exception('Cannot delete category that has products');
      }

      await supabase.from('categories').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  // Search products
  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await supabase
          .from('products')
          .select()
          .or(
            'name.ilike.%$query%,sku.ilike.%$query%,description.ilike.%$query%',
          )
          .order('created_at', ascending: false);

      return (response as List).map((item) => Product.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  // Get products by category
  Future<List<Product>> getProductsByCategory(int categoryId) async {
    try {
      final response = await supabase
          .from('products')
          .select()
          .eq('category_id', categoryId)
          .order('name');

      return (response as List).map((item) => Product.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to fetch products by category: $e');
    }
  }

  // Get low stock products
  Future<List<Product>> getLowStockProducts() async {
    try {
      final response = await supabase
          .from('products')
          .select()
          .filter('quantity', 'lte', 'min_stock')
          .order('quantity');

      return (response as List).map((item) => Product.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to fetch low stock products: $e');
    }
  }

  // Update product quantity (for stock management)
  Future<void> updateProductQuantity(int id, int newQuantity) async {
    try {
      await supabase
          .from('products')
          .update({
            'quantity': newQuantity,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to update product quantity: $e');
    }
  }

  // Bulk operations
  Future<void> bulkUpdateQuantities(Map<int, int> updates) async {
    try {
      for (final entry in updates.entries) {
        await updateProductQuantity(entry.key, entry.value);
      }
    } catch (e) {
      throw Exception('Failed to bulk update quantities: $e');
    }
  }
}
