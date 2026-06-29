import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/modules/catalogue/service/catalogue_service.dart';
import 'package:modfirstpos/modules/home/controller/home_controller.dart';
import 'package:modfirstpos/modules/home/model/product_item.dart';

class CatalogueController extends GetxController {
  final CatalogueService _service;

  CatalogueController({CatalogueService? service})
    : _service = service ?? CatalogueService();

  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxList<ProductItem> allProducts = <ProductItem>[].obs;
  HomeController get _home => Get.find<HomeController>();

  @override
  void onInit() {
    super.onInit();
    _loadStaticData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void _loadStaticData() {
    allProducts.addAll([
      ProductItem(
        id: 'p1',
        name: 'Coca Cola 500ml',
        skuCode: 'SKU-1001',
        oldSkuCode: 'OLD-221',
        imageUrl: null,
        productPrice: 120,
      ),
      ProductItem(
        id: 'p2',
        name: 'Lays Classic Chips 50g',
        skuCode: 'SKU-1002',
        oldSkuCode: 'OLD-222',
        imageUrl: null,
        productPrice: 80,
      ),
      ProductItem(
        id: 'p3',
        name: 'Nestle Pure Life Water 1.5L',
        skuCode: 'SKU-1003',
        oldSkuCode: 'OLD-223',
        imageUrl: null,
        productPrice: 100,
      ),
      ProductItem(
        id: 'p4',
        name: 'Tapal Danedar Tea 190g',
        skuCode: 'SKU-1004',
        oldSkuCode: 'OLD-224',
        imageUrl: null,
        productPrice: 250,
      ),
      ProductItem(
        id: 'p5',
        name: 'Knorr Chicken Noodles',
        skuCode: 'SKU-1005',
        oldSkuCode: 'OLD-225',
        imageUrl: null,
        productPrice: 60,
      ),
      ProductItem(
        id: 'p6',
        name: 'Dawn Flour 5kg',
        skuCode: 'SKU-1006',
        oldSkuCode: 'OLD-226',
        imageUrl: null,
        productPrice: 900,
      ),
      ProductItem(
        id: 'p7',
        name: 'Olper\'s Milk 1L',
        skuCode: 'SKU-1007',
        oldSkuCode: 'OLD-227',
        imageUrl: null,
        productPrice: 230,
      ),
      ProductItem(
        id: 'p8',
        name: 'Sooper Biscuits',
        skuCode: 'SKU-1008',
        oldSkuCode: 'OLD-228',
        imageUrl: null,
        productPrice: 50,
      ),
      ProductItem(
        id: 'p9',
        name: 'Shezan Apple Juice 1L',
        skuCode: 'SKU-1009',
        oldSkuCode: 'OLD-229',
        imageUrl: null,
        productPrice: 180,
      ),
      ProductItem(
        id: 'p10',
        name: 'Colgate Toothpaste 100g',
        skuCode: 'SKU-1010',
        oldSkuCode: 'OLD-230',
        imageUrl: null,
        productPrice: 220,
      ),
    ]);
  }

  List<ProductItem> get filteredProducts {
    final query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) return allProducts;
    return allProducts
        .where((p) => p.name.toLowerCase().contains(query))
        .toList();
  }

  void onSearch(String val) => searchQuery.value = val;

  void onProductTap(ProductItem product) {
    _home.addPinnedProduct(product);
  }

  void addToCart(ProductItem product) {
    _home.addToCartFromItem(product);
  }
}