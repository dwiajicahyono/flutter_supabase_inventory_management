import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/inventory_controller.dart';
import '../models/product.dart';
import '../models/category.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product; // null untuk add, berisi data untuk edit

  const AddProductScreen({Key? key, this.product}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final InventoryController controller = Get.find<InventoryController>();
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _skuController = TextEditingController();
  final _locationController = TextEditingController();
  final _supplierController = TextEditingController();
  final _minStockController = TextEditingController();
  final _maxStockController = TextEditingController();

  Category? selectedCategory;
  bool isLoading = false;
  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _populateFields();
    }
  }

  void _populateFields() {
    final product = widget.product!;
    _nameController.text = product.name;
    _descriptionController.text = product.description ?? '';
    _quantityController.text = product.quantity.toString();
    _priceController.text = product.price?.toString() ?? '';
    _skuController.text = product.sku ?? '';
    _locationController.text = product.location ?? '';
    _supplierController.text = product.supplier ?? '';
    _minStockController.text = product.minStock?.toString() ?? '';
    _maxStockController.text = product.maxStock?.toString() ?? '';

    // Set selected category
    if (product.categoryId != null) {
      selectedCategory = controller.categories.firstWhereOrNull(
        (cat) => cat.id == product.categoryId,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _skuController.dispose();
    _locationController.dispose();
    _supplierController.dispose();
    _minStockController.dispose();
    _maxStockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add Product'),
        actions: [
          if (isEditing)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _showDeleteConfirmation,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Product Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Product name is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),

              // Category Dropdown
              Obx(
                () => DropdownButtonFormField<Category>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items:
                      controller.categories.map((category) {
                        return DropdownMenuItem<Category>(
                          value: category,
                          child: Text(category.name),
                        );
                      }).toList(),
                  onChanged: (Category? value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                ),
              ),
              SizedBox(height: 16),

              // Quantity and Price Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Quantity *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Quantity is required';
                        }
                        if (int.tryParse(value) == null ||
                            int.parse(value) < 0) {
                          return 'Enter valid quantity';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (double.tryParse(value) == null ||
                              double.parse(value) < 0) {
                            return 'Enter valid price';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // SKU
              TextFormField(
                controller: _skuController,
                decoration: InputDecoration(
                  labelText: 'SKU (Stock Keeping Unit)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.qr_code),
                ),
              ),
              SizedBox(height: 16),

              // Min Stock and Max Stock Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minStockController,
                      decoration: InputDecoration(
                        labelText: 'Min Stock',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.trending_down),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (int.tryParse(value) == null ||
                              int.parse(value) < 0) {
                            return 'Enter valid number';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _maxStockController,
                      decoration: InputDecoration(
                        labelText: 'Max Stock',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.trending_up),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (int.tryParse(value) == null ||
                              int.parse(value) < 0) {
                            return 'Enter valid number';
                          }
                          // Validate max > min
                          final minStock = int.tryParse(
                            _minStockController.text,
                          );
                          final maxStock = int.parse(value);
                          if (minStock != null && maxStock <= minStock) {
                            return 'Max must be > Min';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Location and Supplier Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _supplierController,
                      decoration: InputDecoration(
                        labelText: 'Supplier',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: isLoading ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                          isEditing ? 'Update Product' : 'Add Product',
                          style: TextStyle(fontSize: 16),
                        ),
              ),
              SizedBox(height: 16),

              // Cancel Button
              OutlinedButton(
                onPressed: isLoading ? null : () => Get.back(),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Cancel', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final product = Product(
        id: isEditing ? widget.product!.id : null,
        name: _nameController.text.trim(),
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        categoryId: selectedCategory?.id,
        quantity: int.parse(_quantityController.text),
        price:
            _priceController.text.trim().isEmpty
                ? null
                : double.parse(_priceController.text),
        sku:
            _skuController.text.trim().isEmpty
                ? null
                : _skuController.text.trim(),
        location:
            _locationController.text.trim().isEmpty
                ? null
                : _locationController.text.trim(),
        supplier:
            _supplierController.text.trim().isEmpty
                ? null
                : _supplierController.text.trim(),
        minStock:
            _minStockController.text.trim().isEmpty
                ? null
                : int.parse(_minStockController.text),
        maxStock:
            _maxStockController.text.trim().isEmpty
                ? null
                : int.parse(_maxStockController.text),
      );

      if (isEditing) {
        await controller.updateProduct(widget.product!.id!, product);
      } else {
        await controller.addProduct(product);
      }

      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save product: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Product'),
            content: Text(
              'Are you sure you want to delete "${widget.product!.name}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await controller.deleteProduct(widget.product!.id!);
                  Get.back();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('Delete'),
              ),
            ],
          ),
    );
  }
}
