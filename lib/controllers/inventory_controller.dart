import 'package:get/get.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../services/inventory_service.dart';

class InventoryController extends GetxController {
  final InventoryService _service = InventoryService();

  var products = <Product>[].obs;
  var categories = <Category>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  // Filtered products based on search
  List<Product> get filteredProducts {
    if (searchQuery.value.isEmpty) {
      return products;
    }
    return products.where((product) {
      return product.name.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          ) ||
          (product.sku?.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ) ??
              false);
    }).toList();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      await Future.wait([loadProducts(), loadCategories()]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadProducts() async {
    try {
      products.value = await _service.getProducts();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load products: $e');
    }
  }

  Future<void> loadCategories() async {
    try {
      categories.value = await _service.getCategories();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load categories: $e');
    }
  }

  // Product operations
  Future<void> addProduct(Product product) async {
    try {
      await _service.createProduct(product);
      await loadProducts();
      Get.snackbar('Success', 'Product added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add product: $e');
    }
  }

  Future<void> updateProduct(int id, Product product) async {
    try {
      await _service.updateProduct(id, product);
      await loadProducts();
      Get.snackbar('Success', 'Product updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await _service.deleteProduct(id);
      await loadProducts();
      Get.snackbar('Success', 'Product deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete product: $e');
    }
  }

  // Category operations
  Future<void> addCategory(Category category) async {
    try {
      await _service.createCategory(category);
      await loadCategories();
      Get.snackbar('Success', 'Category added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add category: $e');
    }
  }

  // Search functionality
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Get category name by id
  String getCategoryName(int? categoryId) {
    if (categoryId == null) return 'No Category';
    final category = categories.firstWhereOrNull((cat) => cat.id == categoryId);
    return category?.name ?? 'Unknown Category';
  }

  // Get products by category
  List<Product> getProductsByCategory(int categoryId) {
    return products
        .where((product) => product.categoryId == categoryId)
        .toList();
  }

  // Get low stock products
  List<Product> get lowStockProducts {
    return products.where((product) {
      return product.minStock != null && product.quantity <= product.minStock!;
    }).toList();
  }

  // Get overstock products
  List<Product> get overstockProducts {
    return products.where((product) {
      return product.maxStock != null && product.quantity >= product.maxStock!;
    }).toList();
  }

  // Statistics
  int get totalProducts => products.length;
  int get totalCategories => categories.length;
  int get totalQuantity =>
      products.fold(0, (sum, product) => sum + product.quantity);
  double get totalValue => products.fold(
    0.0,
    (sum, product) => sum + (product.quantity * (product.price ?? 0.0)),
  );
}
