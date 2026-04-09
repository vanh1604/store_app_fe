/// Test toàn bộ flow: Upload product áo với size + màu, thêm vào giỏ, đặt hàng.
///
/// Chạy: flutter test test/product_variant_flow_test.dart
library;

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanh_store_app/features/products/models/product_variant.dart';
import 'package:vanh_store_app/features/products/models/product.dart';
import 'package:vanh_store_app/features/cart/models/cart.dart';
import 'package:vanh_store_app/features/orders/models/order.dart';

// ---------------------------------------------------------------------------
// Dữ liệu mẫu — áo thun "Basic Tee" với 6 variants (3 size × 2 màu)
// ---------------------------------------------------------------------------
Map<String, dynamic> _buildMockProductJson() {
  return {
    '_id': 'prod_001',
    'name': 'Áo Thun Basic Tee',
    'description': 'Áo thun cotton 100%, form unisex.',
    'price': 150000.0,
    'quantity': 0, // tổng sẽ tính từ variants
    'category': 'Clothing',
    'subCategory': 'T-Shirts',
    'images': ['https://example.com/img1.jpg'],
    'vendorId': 'vendor_001',
    'fullName': 'Fashion Store',
    'averageRating': 4.5,
    'totalRatings': 12,
    'variants': [
      {'_id': 'v1', 'size': 'S', 'color': 'Trắng', 'price': 150000.0, 'quantity': 20},
      {'_id': 'v2', 'size': 'S', 'color': 'Đen',   'price': 150000.0, 'quantity': 15},
      {'_id': 'v3', 'size': 'M', 'color': 'Trắng', 'price': 150000.0, 'quantity': 30},
      {'_id': 'v4', 'size': 'M', 'color': 'Đen',   'price': 155000.0, 'quantity': 25},
      {'_id': 'v5', 'size': 'L', 'color': 'Trắng', 'price': 160000.0, 'quantity': 10},
      {'_id': 'v6', 'size': 'L', 'color': 'Đen',   'price': 160000.0, 'quantity': 0}, // hết hàng
    ],
  };
}

// ---------------------------------------------------------------------------
// Helper tạo Cart item từ Product + Variant (giả lập hành động user)
// ---------------------------------------------------------------------------
Map<String, Cart> _addToCart(
  Map<String, Cart> cart,
  Product product,
  ProductVariant variant,
  int qty,
) {
  final cartKey = '${product.id}_${variant.id}';
  if (cart.containsKey(cartKey)) {
    final existing = cart[cartKey]!;
    return {
      ...cart,
      cartKey: Cart(
        productName: existing.productName,
        quantity: existing.quantity + qty,
        price: existing.price,
        image: existing.image,
        category: existing.category,
        vendorId: existing.vendorId,
        productId: existing.productId,
        productDescription: existing.productDescription,
        productQuantity: existing.productQuantity,
        fullName: existing.fullName,
        selectedSize: existing.selectedSize,
        variantId: existing.variantId,
      ),
    };
  }
  return {
    ...cart,
    cartKey: Cart(
      productName: product.name,
      quantity: qty,
      price: variant.price,
      image: product.images,
      category: product.category,
      vendorId: product.vendorId,
      productId: product.id,
      productDescription: product.description,
      productQuantity: variant.quantity,
      fullName: product.fullName,
      selectedSize: variant.label,
      variantId: variant.id,
    ),
  };
}

void main() {
  // =========================================================================
  // NHÓM 1: Model ProductVariant
  // =========================================================================
  group('ProductVariant model', () {
    test('fromMap() parse đúng size + color + price + quantity', () {
      final map = {
        '_id': 'v3',
        'size': 'M',
        'color': 'Trắng',
        'price': 150000.0,
        'quantity': 30,
      };
      final variant = ProductVariant.fromMap(map);

      expect(variant.id, 'v3');
      expect(variant.size, 'M');
      expect(variant.color, 'Trắng');
      expect(variant.price, 150000.0);
      expect(variant.quantity, 30);
    });

    test('label = "M / Trắng" khi có màu', () {
      final v = ProductVariant(id: 'v3', size: 'M', color: 'Trắng', price: 150000, quantity: 30);
      expect(v.label, 'M / Trắng');
    });

    test('label = "S" khi không có màu', () {
      final v = ProductVariant(id: 'v1', size: 'S', price: 150000, quantity: 20);
      expect(v.label, 'S');
    });

    test('toMap() không include _id khi id rỗng (khi vendor tạo mới)', () {
      final v = ProductVariant(id: '', size: 'XL', color: 'Đỏ', price: 170000, quantity: 5);
      final map = v.toMap();
      expect(map.containsKey('_id'), isFalse);
      expect(map['size'], 'XL');
      expect(map['color'], 'Đỏ');
    });

    test('toMap() không include color khi color null', () {
      final v = ProductVariant(id: 'v1', size: 'S', price: 150000, quantity: 20);
      final map = v.toMap();
      expect(map.containsKey('color'), isFalse);
    });

    test('fromMap() → toMap() → fromMap() roundtrip giữ nguyên data', () {
      final original = {
        '_id': 'v4',
        'size': 'M',
        'color': 'Đen',
        'price': 155000.0,
        'quantity': 25,
      };
      final v = ProductVariant.fromMap(original);
      final restored = ProductVariant.fromMap(v.toMap());

      expect(restored.id, v.id);
      expect(restored.size, v.size);
      expect(restored.color, v.color);
      expect(restored.price, v.price);
      expect(restored.quantity, v.quantity);
    });
  });

  // =========================================================================
  // NHÓM 2: Model Product với variants
  // =========================================================================
  group('Product model với variants', () {
    late Product product;

    setUp(() {
      product = Product.fromMap(_buildMockProductJson());
    });

    test('parse được 6 variants từ API response', () {
      expect(product.variants.length, 6);
    });

    test('hasVariants = true khi có variants', () {
      expect(product.hasVariants, isTrue);
    });

    test('hasVariants = false khi variants rỗng', () {
      final p = Product.fromMap({
        ..._buildMockProductJson(),
        'variants': [],
      });
      expect(p.hasVariants, isFalse);
    });

    test('parse đúng variant đầu tiên: S / Trắng, giá 150000', () {
      final v = product.variants[0];
      expect(v.id, 'v1');
      expect(v.size, 'S');
      expect(v.color, 'Trắng');
      expect(v.price, 150000.0);
      expect(v.quantity, 20);
    });

    test('variant M/Đen có giá cao hơn (155000)', () {
      final v = product.variants.firstWhere((v) => v.id == 'v4');
      expect(v.price, 155000.0);
      expect(v.label, 'M / Đen');
    });

    test('variant L/Đen hết hàng (quantity = 0)', () {
      final v = product.variants.firstWhere((v) => v.id == 'v6');
      expect(v.quantity, 0);
    });

    test('toMap() bao gồm variants array', () {
      final map = product.toMap();
      expect(map['variants'], isA<List>());
      expect((map['variants'] as List).length, 6);
    });

    test('toJson() → fromMap() roundtrip giữ đủ 6 variants', () {
      final json = jsonDecode(product.toJson());
      // fromMap dùng '_id', nhưng toMap dùng 'id' cho product root
      // variants vẫn dùng '_id'
      final variantsJson = json['variants'] as List;
      final restoredVariants = variantsJson.map((v) => ProductVariant.fromMap(v)).toList();
      expect(restoredVariants.length, 6);
      expect(restoredVariants[2].label, 'M / Trắng');
    });
  });

  // =========================================================================
  // NHÓM 3: Cart — key logic và thêm vào giỏ
  // =========================================================================
  group('Cart — variant key và thêm vào giỏ', () {
    late Product product;
    late ProductVariant variantMTrang; // v3
    late ProductVariant variantMDen;   // v4

    setUp(() {
      product = Product.fromMap(_buildMockProductJson());
      variantMTrang = product.variants.firstWhere((v) => v.id == 'v3');
      variantMDen   = product.variants.firstWhere((v) => v.id == 'v4');
    });

    test('cart key = productId_variantId', () {
      final key = '${product.id}_${variantMTrang.id}';
      expect(key, 'prod_001_v3');
    });

    test('thêm M/Trắng vào giỏ → cart có 1 item', () {
      var cart = <String, Cart>{};
      cart = _addToCart(cart, product, variantMTrang, 1);

      expect(cart.length, 1);
      expect(cart.containsKey('prod_001_v3'), isTrue);
      expect(cart['prod_001_v3']!.selectedSize, 'M / Trắng');
      expect(cart['prod_001_v3']!.variantId, 'v3');
      expect(cart['prod_001_v3']!.price, 150000.0);
    });

    test('thêm M/Đen vào giỏ (cùng sản phẩm, khác màu) → cart có 2 item riêng biệt', () {
      var cart = <String, Cart>{};
      cart = _addToCart(cart, product, variantMTrang, 1);
      cart = _addToCart(cart, product, variantMDen,   1);

      expect(cart.length, 2);
      expect(cart.containsKey('prod_001_v3'), isTrue);
      expect(cart.containsKey('prod_001_v4'), isTrue);

      // Giá khác nhau
      expect(cart['prod_001_v3']!.price, 150000.0);
      expect(cart['prod_001_v4']!.price, 155000.0);
    });

    test('thêm M/Trắng 2 lần → quantity tăng lên 2 (không tạo item mới)', () {
      var cart = <String, Cart>{};
      cart = _addToCart(cart, product, variantMTrang, 1);
      cart = _addToCart(cart, product, variantMTrang, 1);

      expect(cart.length, 1);
      expect(cart['prod_001_v3']!.quantity, 2);
    });

    test('Cart.toMap() lưu đủ selectedSize và variantId', () {
      var cart = <String, Cart>{};
      cart = _addToCart(cart, product, variantMTrang, 1);
      final map = cart['prod_001_v3']!.toMap();

      expect(map['selectedSize'], 'M / Trắng');
      expect(map['variantId'], 'v3');
      expect(map['price'], 150000.0);
    });

    test('Cart.fromMap() restore đúng selectedSize và variantId', () {
      var cart = <String, Cart>{};
      cart = _addToCart(cart, product, variantMTrang, 2);
      final original = cart['prod_001_v3']!;

      final restored = Cart.fromMap(original.toMap());
      expect(restored.selectedSize, 'M / Trắng');
      expect(restored.variantId, 'v3');
      expect(restored.quantity, 2);
      expect(restored.price, 150000.0);
    });

    test('Cart serialization JSON (SharedPreferences) giữ đủ data', () {
      var cart = <String, Cart>{};
      cart = _addToCart(cart, product, variantMTrang, 1);
      cart = _addToCart(cart, product, variantMDen,   2);

      // Serialize (giống _savedCartItems())
      final cartJson = jsonEncode(cart.map((k, v) => MapEntry(k, v.toMap())));

      // Deserialize (giống _loadCartItems())
      final decoded = jsonDecode(cartJson) as Map<String, dynamic>;
      final restored = decoded.map((k, v) => MapEntry(k, Cart.fromMap(v as Map<String, dynamic>)));

      expect(restored.length, 2);
      expect(restored['prod_001_v3']!.selectedSize, 'M / Trắng');
      expect(restored['prod_001_v4']!.selectedSize, 'M / Đen');
      expect(restored['prod_001_v4']!.quantity, 2);
    });
  });

  // =========================================================================
  // NHÓM 4: Order model với selectedSize + variantId
  // =========================================================================
  group('Order model với selectedSize và variantId', () {
    Map<String, dynamic> _buildOrderMap({String? selectedSize, String? variantId}) {
      return {
        '_id': 'order_001',
        'fullName': 'Nguyen Van A',
        'email': 'a@example.com',
        'state': 'TP.HCM',
        'city': 'Quận 1',
        'locality': '123 Lê Lợi',
        'productName': 'Áo Thun Basic Tee',
        'quantity': 2,
        'productPrice': 150000.0,
        'category': 'Clothing',
        'image': 'https://example.com/img1.jpg',
        'buyerId': 'buyer_001',
        'vendorId': 'vendor_001',
        'processing': true,
        'delivered': false,
        'orderedAt': '2026-03-24T10:00:00.000Z',
        if (selectedSize != null) 'selectedSize': selectedSize,
        if (variantId != null) 'variantId': variantId,
      };
    }

    test('Order.fromMap() parse được selectedSize và variantId', () {
      final order = Order.fromMap(_buildOrderMap(
        selectedSize: 'M / Trắng',
        variantId: 'v3',
      ));

      expect(order.selectedSize, 'M / Trắng');
      expect(order.variantId, 'v3');
    });

    test('Order.fromMap() selectedSize = null khi không có field', () {
      final order = Order.fromMap(_buildOrderMap());
      expect(order.selectedSize, isNull);
      expect(order.variantId, isNull);
    });

    test('Order.toMap() include selectedSize và variantId khi có giá trị', () {
      final order = Order.fromMap(_buildOrderMap(
        selectedSize: 'M / Trắng',
        variantId: 'v3',
      ));
      final map = order.toMap();

      expect(map['selectedSize'], 'M / Trắng');
      expect(map['variantId'], 'v3');
    });

    test('Order.toMap() KHÔNG include selectedSize khi null (sản phẩm không có size)', () {
      final order = Order.fromMap(_buildOrderMap());
      final map = order.toMap();

      expect(map.containsKey('selectedSize'), isFalse);
      expect(map.containsKey('variantId'), isFalse);
    });

    test('Order roundtrip qua API map giữ nguyên selectedSize', () {
      // Simulate: nhận từ API (có _id) → fromMap → kiểm tra fields
      final apiMap = _buildOrderMap(selectedSize: 'L / Đen', variantId: 'v6');
      final order = Order.fromMap(apiMap);

      expect(order.selectedSize, 'L / Đen');
      expect(order.variantId, 'v6');
      expect(order.productPrice, 150000.0);

      // Kiểm tra toMap() output (dùng để gửi lên backend POST body)
      final body = order.toMap();
      expect(body['selectedSize'], 'L / Đen');
      expect(body['variantId'], 'v6');
      expect(body['productPrice'], 150000.0);
    });
  });

  // =========================================================================
  // NHÓM 5: End-to-end flow — Vendor upload → User mua → Order
  // =========================================================================
  group('End-to-end flow: áo thun với size + màu', () {
    test('FLOW HOÀN CHỈNH: vendor tạo product → user chọn variant → add cart → checkout → order', () {
      // --- BƯỚC 1: Vendor upload sản phẩm (simulate API response) ---
      final product = Product.fromMap(_buildMockProductJson());

      expect(product.name, 'Áo Thun Basic Tee');
      expect(product.hasVariants, isTrue);
      expect(product.variants.length, 6);

      // --- BƯỚC 2: User xem ProductDetailScreen, chọn M/Trắng ---
      final selectedVariant = product.variants.firstWhere((v) => v.id == 'v3');
      expect(selectedVariant.label, 'M / Trắng');
      expect(selectedVariant.quantity, greaterThan(0)); // còn hàng

      // Kiểm tra variant hết hàng (L/Đen) bị disabled
      final outOfStock = product.variants.firstWhere((v) => v.id == 'v6');
      expect(outOfStock.quantity, 0);

      // --- BƯỚC 3: User thêm 2 cái M/Trắng và 1 cái M/Đen vào giỏ ---
      var cart = <String, Cart>{};
      final variantMDen = product.variants.firstWhere((v) => v.id == 'v4');

      cart = _addToCart(cart, product, selectedVariant, 1);
      cart = _addToCart(cart, product, selectedVariant, 1); // lần 2 → qty = 2
      cart = _addToCart(cart, product, variantMDen, 1);

      // Giỏ có 2 dòng riêng biệt
      expect(cart.length, 2);
      expect(cart['prod_001_v3']!.quantity, 2);
      expect(cart['prod_001_v4']!.quantity, 1);

      // --- BƯỚC 4: Tính tổng tiền ---
      double total = 0;
      cart.forEach((_, item) => total += item.price * item.quantity);
      // 2 × 150000 + 1 × 155000 = 455000
      expect(total, 455000.0);

      // --- BƯỚC 5: Checkout → tạo Order cho từng cart item ---
      final orders = cart.entries.map((entry) {
        final item = entry.value;
        return Order(
          id: '',
          fullName: 'Nguyen Van A',
          email: 'a@example.com',
          state: 'TP.HCM',
          city: 'Quận 1',
          locality: '123 Lê Lợi',
          productName: item.productName,
          quantity: item.quantity,
          productPrice: item.price,
          category: item.category,
          image: item.image[0],
          buyerId: 'buyer_001',
          vendorId: item.vendorId,
          processing: true,
          delivered: false,
          selectedSize: item.selectedSize,
          variantId: item.variantId,
        );
      }).toList();

      expect(orders.length, 2);

      // Order 1: M/Trắng × 2
      final orderMTrang = orders.firstWhere((o) => o.variantId == 'v3');
      expect(orderMTrang.selectedSize, 'M / Trắng');
      expect(orderMTrang.quantity, 2);
      expect(orderMTrang.productPrice, 150000.0);

      // Order 2: M/Đen × 1
      final orderMDen = orders.firstWhere((o) => o.variantId == 'v4');
      expect(orderMDen.selectedSize, 'M / Đen');
      expect(orderMDen.quantity, 1);
      expect(orderMDen.productPrice, 155000.0);

      // --- BƯỚC 6: Kiểm tra toMap() để gửi lên backend ---
      final bodyMTrang = orderMTrang.toMap();
      expect(bodyMTrang['selectedSize'], 'M / Trắng');
      expect(bodyMTrang['variantId'], 'v3');
      expect(bodyMTrang['quantity'], 2);

      // --- BƯỚC 7: Sản phẩm điện thoại (không có size) → KHÔNG có selectedSize ---
      final phoneProduct = Product.fromMap({
        ..._buildMockProductJson(),
        '_id': 'prod_phone',
        'name': 'iPhone 16',
        'variants': [],
        'price': 25000000.0,
        'quantity': 50,
      });
      expect(phoneProduct.hasVariants, isFalse);

      // Cart item cho điện thoại: key = productId (không có variantId)
      final phoneCartKey = phoneProduct.id; // 'prod_phone'
      final phoneCart = {
        phoneCartKey: Cart(
          productName: phoneProduct.name,
          quantity: 1,
          price: phoneProduct.price,
          image: phoneProduct.images,
          category: phoneProduct.category,
          vendorId: phoneProduct.vendorId,
          productId: phoneProduct.id,
          productDescription: phoneProduct.description,
          productQuantity: phoneProduct.quantity,
          fullName: phoneProduct.fullName,
          selectedSize: null,  // không có size
          variantId: null,
        ),
      };

      final phoneOrder = Order(
        id: '',
        fullName: 'Nguyen Van A',
        email: 'a@example.com',
        state: 'TP.HCM',
        city: 'Quận 1',
        locality: '123 Lê Lợi',
        productName: phoneCart[phoneCartKey]!.productName,
        quantity: 1,
        productPrice: phoneProduct.price,
        category: phoneProduct.category,
        image: phoneProduct.images[0],
        buyerId: 'buyer_001',
        vendorId: phoneProduct.vendorId,
        processing: true,
        delivered: false,
        selectedSize: null,
        variantId: null,
      );

      // toMap() của sản phẩm không có size không chứa selectedSize
      expect(phoneOrder.toMap().containsKey('selectedSize'), isFalse);
    });

    test('Validation: không cho add to cart nếu product hasVariants nhưng chưa chọn variant', () {
      final product = Product.fromMap(_buildMockProductJson());
      String? selectedVariantId; // user chưa chọn

      // Logic giống trong _buildBottomBar
      bool wouldBlock = product.hasVariants && selectedVariantId == null;
      expect(wouldBlock, isTrue, reason: 'Phải chặn nếu chưa chọn size');
    });

    test('Validation: cho phép add to cart nếu product không có variants', () {
      final product = Product.fromMap({..._buildMockProductJson(), 'variants': []});
      String? selectedVariantId; // không cần chọn

      bool wouldBlock = product.hasVariants && selectedVariantId == null;
      expect(wouldBlock, isFalse, reason: 'Không chặn với sản phẩm không có size');
    });
  });
}
