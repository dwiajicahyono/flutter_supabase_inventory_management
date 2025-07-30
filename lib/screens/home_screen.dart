import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/inventory_controller.dart';
import '../models/product.dart';
import 'add_product_screen.dart';
import 'add_category_screen.dart';

class HomeScreen extends StatelessWidget {
  final InventoryController controller = Get.put(InventoryController());

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.category),
            onPressed: () => Get.to(() => AddCategoryScreen()),
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => controller.loadData(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: controller.updateSearchQuery,
            ),
          ),

          // Statistics Cards - Horizontal Scroll
          SizedBox(
            height: 120, // Fixed height untuk horizontal scroll
            child: Obx(
              () => ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildStatCard(
                    'Products',
                    controller.totalProducts.toString(),
                    Icons.inventory,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    'Categories',
                    controller.totalCategories.toString(),
                    Icons.category,
                    Colors.green,
                  ),
                  _buildStatCard(
                    'Total Quantity',
                    _formatNumber(controller.totalQuantity),
                    Icons.numbers,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    'Total Value',
                    _formatCurrency(controller.totalValue),
                    Icons.attach_money,
                    Colors.purple,
                  ),
                  _buildStatCard(
                    'Low Stock',
                    controller.lowStockProducts.length.toString(),
                    Icons.warning,
                    Colors.red,
                  ),
                  _buildStatCard(
                    'Normal Stock',
                    (controller.totalProducts -
                            controller.lowStockProducts.length)
                        .toString(),
                    Icons.check_circle,
                    Colors.green[600]!,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Products List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              final filteredProducts = controller.filteredProducts;

              if (filteredProducts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        controller.searchQuery.value.isEmpty
                            ? 'No products found'
                            : 'No products match your search',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 16),
                      if (controller.searchQuery.value.isEmpty)
                        ElevatedButton(
                          onPressed: () => Get.to(() => AddProductScreen()),
                          child: Text('Add First Product'),
                        ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: filteredProducts.length,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        product.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.description != null &&
                              product.description!.isNotEmpty)
                            Text(
                              product.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.category,
                                size: 14,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 4),
                              Text(
                                controller.getCategoryName(product.categoryId),
                              ),
                              SizedBox(width: 16),
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 4),
                              Text(product.location ?? 'No location'),
                            ],
                          ),
                          SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: product.stockStatusColor.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Qty: ${product.quantity}',
                                  style: TextStyle(
                                    color: product.stockStatusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              if (product.price != null)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _formatCurrency(product.price!),
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              if (product.stockStatus != 'Normal')
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: product.stockStatusColor.withValues(
                                      alpha: 0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    product.stockStatus,
                                    style: TextStyle(
                                      color: product.stockStatusColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (product.sku != null &&
                              product.sku!.isNotEmpty) ...[
                            SizedBox(height: 4),
                            Text(
                              'SKU: ${product.sku}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder:
                            (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 18),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            Get.to(() => AddProductScreen(product: product));
                          } else if (value == 'delete') {
                            _showDeleteConfirmation(context, product);
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => AddProductScreen()),
        tooltip: 'Add Product',
        child: Icon(Icons.add),
      ),
    );
  }

  // Updated _buildStatCard untuk horizontal layout
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 130, // Fixed width untuk horizontal scroll
      margin: EdgeInsets.only(right: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '\$${amount.toStringAsFixed(0)}';
    }
  }

  void _showDeleteConfirmation(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Product'),
            content: Text(
              'Are you sure you want to delete "${product.name}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  controller.deleteProduct(product.id!);
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('Delete'),
              ),
            ],
          ),
    );
  }
}
