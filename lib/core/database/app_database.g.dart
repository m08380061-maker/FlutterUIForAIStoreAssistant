// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProductsTable extends Products with TableInfo<$ProductsTable, Product> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _purchasePriceMeta =
      const VerificationMeta('purchasePrice');
  @override
  late final GeneratedColumn<double> purchasePrice = GeneratedColumn<double>(
      'purchase_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _sellingPriceMeta =
      const VerificationMeta('sellingPrice');
  @override
  late final GeneratedColumn<double> sellingPrice = GeneratedColumn<double>(
      'selling_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _barcodeMeta =
      const VerificationMeta('barcode');
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
      'barcode', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _branchIdMeta =
      const VerificationMeta('branchId');
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
      'branch_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        category,
        purchasePrice,
        sellingPrice,
        quantity,
        barcode,
        imageUrl,
        description,
        createdAt,
        updatedAt,
        isActive,
        branchId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(Insertable<Product> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('purchase_price')) {
      context.handle(
          _purchasePriceMeta,
          purchasePrice.isAcceptableOrUnknown(
              data['purchase_price']!, _purchasePriceMeta));
    } else if (isInserting) {
      context.missing(_purchasePriceMeta);
    }
    if (data.containsKey('selling_price')) {
      context.handle(
          _sellingPriceMeta,
          sellingPrice.isAcceptableOrUnknown(
              data['selling_price']!, _sellingPriceMeta));
    } else if (isInserting) {
      context.missing(_sellingPriceMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('barcode')) {
      context.handle(_barcodeMeta,
          barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta));
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('branch_id')) {
      context.handle(_branchIdMeta,
          branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Product map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Product(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      purchasePrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}purchase_price'])!,
      sellingPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}selling_price'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      barcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barcode']),
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      branchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}branch_id']),
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class Product extends DataClass implements Insertable<Product> {
  final String id;
  final String name;
  final String category;
  final double purchasePrice;
  final double sellingPrice;
  final int quantity;
  final String? barcode;
  final String? imageUrl;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String? branchId;
  const Product(
      {required this.id,
      required this.name,
      required this.category,
      required this.purchasePrice,
      required this.sellingPrice,
      required this.quantity,
      this.barcode,
      this.imageUrl,
      this.description,
      required this.createdAt,
      required this.updatedAt,
      required this.isActive,
      this.branchId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['purchase_price'] = Variable<double>(purchasePrice);
    map['selling_price'] = Variable<double>(sellingPrice);
    map['quantity'] = Variable<int>(quantity);
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || branchId != null) {
      map['branch_id'] = Variable<String>(branchId);
    }
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      purchasePrice: Value(purchasePrice),
      sellingPrice: Value(sellingPrice),
      quantity: Value(quantity),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isActive: Value(isActive),
      branchId: branchId == null && nullToAbsent
          ? const Value.absent()
          : Value(branchId),
    );
  }

  factory Product.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Product(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      purchasePrice: serializer.fromJson<double>(json['purchasePrice']),
      sellingPrice: serializer.fromJson<double>(json['sellingPrice']),
      quantity: serializer.fromJson<int>(json['quantity']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      branchId: serializer.fromJson<String?>(json['branchId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'purchasePrice': serializer.toJson<double>(purchasePrice),
      'sellingPrice': serializer.toJson<double>(sellingPrice),
      'quantity': serializer.toJson<int>(quantity),
      'barcode': serializer.toJson<String?>(barcode),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isActive': serializer.toJson<bool>(isActive),
      'branchId': serializer.toJson<String?>(branchId),
    };
  }

  Product copyWith(
          {String? id,
          String? name,
          String? category,
          double? purchasePrice,
          double? sellingPrice,
          int? quantity,
          Value<String?> barcode = const Value.absent(),
          Value<String?> imageUrl = const Value.absent(),
          Value<String?> description = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isActive,
          Value<String?> branchId = const Value.absent()}) =>
      Product(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        purchasePrice: purchasePrice ?? this.purchasePrice,
        sellingPrice: sellingPrice ?? this.sellingPrice,
        quantity: quantity ?? this.quantity,
        barcode: barcode.present ? barcode.value : this.barcode,
        imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
        description: description.present ? description.value : this.description,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isActive: isActive ?? this.isActive,
        branchId: branchId.present ? branchId.value : this.branchId,
      );
  Product copyWithCompanion(ProductsCompanion data) {
    return Product(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      purchasePrice: data.purchasePrice.present
          ? data.purchasePrice.value
          : this.purchasePrice,
      sellingPrice: data.sellingPrice.present
          ? data.sellingPrice.value
          : this.sellingPrice,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      description:
          data.description.present ? data.description.value : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Product(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('sellingPrice: $sellingPrice, ')
          ..write('quantity: $quantity, ')
          ..write('barcode: $barcode, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isActive: $isActive, ')
          ..write('branchId: $branchId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      category,
      purchasePrice,
      sellingPrice,
      quantity,
      barcode,
      imageUrl,
      description,
      createdAt,
      updatedAt,
      isActive,
      branchId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Product &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.purchasePrice == this.purchasePrice &&
          other.sellingPrice == this.sellingPrice &&
          other.quantity == this.quantity &&
          other.barcode == this.barcode &&
          other.imageUrl == this.imageUrl &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isActive == this.isActive &&
          other.branchId == this.branchId);
}

class ProductsCompanion extends UpdateCompanion<Product> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> category;
  final Value<double> purchasePrice;
  final Value<double> sellingPrice;
  final Value<int> quantity;
  final Value<String?> barcode;
  final Value<String?> imageUrl;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isActive;
  final Value<String?> branchId;
  final Value<int> rowid;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.sellingPrice = const Value.absent(),
    this.quantity = const Value.absent(),
    this.barcode = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.branchId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String id,
    required String name,
    required String category,
    required double purchasePrice,
    required double sellingPrice,
    required int quantity,
    this.barcode = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.description = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isActive = const Value.absent(),
    this.branchId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        category = Value(category),
        purchasePrice = Value(purchasePrice),
        sellingPrice = Value(sellingPrice),
        quantity = Value(quantity),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Product> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<double>? purchasePrice,
    Expression<double>? sellingPrice,
    Expression<int>? quantity,
    Expression<String>? barcode,
    Expression<String>? imageUrl,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isActive,
    Expression<String>? branchId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (sellingPrice != null) 'selling_price': sellingPrice,
      if (quantity != null) 'quantity': quantity,
      if (barcode != null) 'barcode': barcode,
      if (imageUrl != null) 'image_url': imageUrl,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isActive != null) 'is_active': isActive,
      if (branchId != null) 'branch_id': branchId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? category,
      Value<double>? purchasePrice,
      Value<double>? sellingPrice,
      Value<int>? quantity,
      Value<String?>? barcode,
      Value<String?>? imageUrl,
      Value<String?>? description,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isActive,
      Value<String?>? branchId,
      Value<int>? rowid}) {
    return ProductsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      quantity: quantity ?? this.quantity,
      barcode: barcode ?? this.barcode,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      branchId: branchId ?? this.branchId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (purchasePrice.present) {
      map['purchase_price'] = Variable<double>(purchasePrice.value);
    }
    if (sellingPrice.present) {
      map['selling_price'] = Variable<double>(sellingPrice.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('sellingPrice: $sellingPrice, ')
          ..write('quantity: $quantity, ')
          ..write('barcode: $barcode, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isActive: $isActive, ')
          ..write('branchId: $branchId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SalesTable extends Sales with TableInfo<$SalesTable, Sale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subtotalMeta =
      const VerificationMeta('subtotal');
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
      'subtotal', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _discountMeta =
      const VerificationMeta('discount');
  @override
  late final GeneratedColumn<double> discount = GeneratedColumn<double>(
      'discount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
      'total', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _customerIdMeta =
      const VerificationMeta('customerId');
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
      'customer_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _customerNameMeta =
      const VerificationMeta('customerName');
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
      'customer_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _workerIdMeta =
      const VerificationMeta('workerId');
  @override
  late final GeneratedColumn<String> workerId = GeneratedColumn<String>(
      'worker_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _branchIdMeta =
      const VerificationMeta('branchId');
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
      'branch_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _paymentMethodMeta =
      const VerificationMeta('paymentMethod');
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
      'payment_method', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('cash'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        subtotal,
        discount,
        total,
        customerId,
        customerName,
        workerId,
        branchId,
        createdAt,
        paymentMethod
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales';
  @override
  VerificationContext validateIntegrity(Insertable<Sale> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('subtotal')) {
      context.handle(_subtotalMeta,
          subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta));
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    if (data.containsKey('discount')) {
      context.handle(_discountMeta,
          discount.isAcceptableOrUnknown(data['discount']!, _discountMeta));
    }
    if (data.containsKey('total')) {
      context.handle(
          _totalMeta, total.isAcceptableOrUnknown(data['total']!, _totalMeta));
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
          _customerIdMeta,
          customerId.isAcceptableOrUnknown(
              data['customer_id']!, _customerIdMeta));
    }
    if (data.containsKey('customer_name')) {
      context.handle(
          _customerNameMeta,
          customerName.isAcceptableOrUnknown(
              data['customer_name']!, _customerNameMeta));
    }
    if (data.containsKey('worker_id')) {
      context.handle(_workerIdMeta,
          workerId.isAcceptableOrUnknown(data['worker_id']!, _workerIdMeta));
    } else if (isInserting) {
      context.missing(_workerIdMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(_branchIdMeta,
          branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('payment_method')) {
      context.handle(
          _paymentMethodMeta,
          paymentMethod.isAcceptableOrUnknown(
              data['payment_method']!, _paymentMethodMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Sale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sale(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      subtotal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}subtotal'])!,
      discount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}discount'])!,
      total: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total'])!,
      customerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_id']),
      customerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_name']),
      workerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}worker_id'])!,
      branchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}branch_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      paymentMethod: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_method'])!,
    );
  }

  @override
  $SalesTable createAlias(String alias) {
    return $SalesTable(attachedDatabase, alias);
  }
}

class Sale extends DataClass implements Insertable<Sale> {
  final String id;
  final double subtotal;
  final double discount;
  final double total;
  final String? customerId;
  final String? customerName;
  final String workerId;
  final String? branchId;
  final DateTime createdAt;
  final String paymentMethod;
  const Sale(
      {required this.id,
      required this.subtotal,
      required this.discount,
      required this.total,
      this.customerId,
      this.customerName,
      required this.workerId,
      this.branchId,
      required this.createdAt,
      required this.paymentMethod});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['subtotal'] = Variable<double>(subtotal);
    map['discount'] = Variable<double>(discount);
    map['total'] = Variable<double>(total);
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    if (!nullToAbsent || customerName != null) {
      map['customer_name'] = Variable<String>(customerName);
    }
    map['worker_id'] = Variable<String>(workerId);
    if (!nullToAbsent || branchId != null) {
      map['branch_id'] = Variable<String>(branchId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['payment_method'] = Variable<String>(paymentMethod);
    return map;
  }

  SalesCompanion toCompanion(bool nullToAbsent) {
    return SalesCompanion(
      id: Value(id),
      subtotal: Value(subtotal),
      discount: Value(discount),
      total: Value(total),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      customerName: customerName == null && nullToAbsent
          ? const Value.absent()
          : Value(customerName),
      workerId: Value(workerId),
      branchId: branchId == null && nullToAbsent
          ? const Value.absent()
          : Value(branchId),
      createdAt: Value(createdAt),
      paymentMethod: Value(paymentMethod),
    );
  }

  factory Sale.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sale(
      id: serializer.fromJson<String>(json['id']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      discount: serializer.fromJson<double>(json['discount']),
      total: serializer.fromJson<double>(json['total']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      customerName: serializer.fromJson<String?>(json['customerName']),
      workerId: serializer.fromJson<String>(json['workerId']),
      branchId: serializer.fromJson<String?>(json['branchId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'subtotal': serializer.toJson<double>(subtotal),
      'discount': serializer.toJson<double>(discount),
      'total': serializer.toJson<double>(total),
      'customerId': serializer.toJson<String?>(customerId),
      'customerName': serializer.toJson<String?>(customerName),
      'workerId': serializer.toJson<String>(workerId),
      'branchId': serializer.toJson<String?>(branchId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
    };
  }

  Sale copyWith(
          {String? id,
          double? subtotal,
          double? discount,
          double? total,
          Value<String?> customerId = const Value.absent(),
          Value<String?> customerName = const Value.absent(),
          String? workerId,
          Value<String?> branchId = const Value.absent(),
          DateTime? createdAt,
          String? paymentMethod}) =>
      Sale(
        id: id ?? this.id,
        subtotal: subtotal ?? this.subtotal,
        discount: discount ?? this.discount,
        total: total ?? this.total,
        customerId: customerId.present ? customerId.value : this.customerId,
        customerName:
            customerName.present ? customerName.value : this.customerName,
        workerId: workerId ?? this.workerId,
        branchId: branchId.present ? branchId.value : this.branchId,
        createdAt: createdAt ?? this.createdAt,
        paymentMethod: paymentMethod ?? this.paymentMethod,
      );
  Sale copyWithCompanion(SalesCompanion data) {
    return Sale(
      id: data.id.present ? data.id.value : this.id,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      discount: data.discount.present ? data.discount.value : this.discount,
      total: data.total.present ? data.total.value : this.total,
      customerId:
          data.customerId.present ? data.customerId.value : this.customerId,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      workerId: data.workerId.present ? data.workerId.value : this.workerId,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sale(')
          ..write('id: $id, ')
          ..write('subtotal: $subtotal, ')
          ..write('discount: $discount, ')
          ..write('total: $total, ')
          ..write('customerId: $customerId, ')
          ..write('customerName: $customerName, ')
          ..write('workerId: $workerId, ')
          ..write('branchId: $branchId, ')
          ..write('createdAt: $createdAt, ')
          ..write('paymentMethod: $paymentMethod')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, subtotal, discount, total, customerId,
      customerName, workerId, branchId, createdAt, paymentMethod);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sale &&
          other.id == this.id &&
          other.subtotal == this.subtotal &&
          other.discount == this.discount &&
          other.total == this.total &&
          other.customerId == this.customerId &&
          other.customerName == this.customerName &&
          other.workerId == this.workerId &&
          other.branchId == this.branchId &&
          other.createdAt == this.createdAt &&
          other.paymentMethod == this.paymentMethod);
}

class SalesCompanion extends UpdateCompanion<Sale> {
  final Value<String> id;
  final Value<double> subtotal;
  final Value<double> discount;
  final Value<double> total;
  final Value<String?> customerId;
  final Value<String?> customerName;
  final Value<String> workerId;
  final Value<String?> branchId;
  final Value<DateTime> createdAt;
  final Value<String> paymentMethod;
  final Value<int> rowid;
  const SalesCompanion({
    this.id = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.discount = const Value.absent(),
    this.total = const Value.absent(),
    this.customerId = const Value.absent(),
    this.customerName = const Value.absent(),
    this.workerId = const Value.absent(),
    this.branchId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SalesCompanion.insert({
    required String id,
    required double subtotal,
    this.discount = const Value.absent(),
    required double total,
    this.customerId = const Value.absent(),
    this.customerName = const Value.absent(),
    required String workerId,
    this.branchId = const Value.absent(),
    required DateTime createdAt,
    this.paymentMethod = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        subtotal = Value(subtotal),
        total = Value(total),
        workerId = Value(workerId),
        createdAt = Value(createdAt);
  static Insertable<Sale> custom({
    Expression<String>? id,
    Expression<double>? subtotal,
    Expression<double>? discount,
    Expression<double>? total,
    Expression<String>? customerId,
    Expression<String>? customerName,
    Expression<String>? workerId,
    Expression<String>? branchId,
    Expression<DateTime>? createdAt,
    Expression<String>? paymentMethod,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subtotal != null) 'subtotal': subtotal,
      if (discount != null) 'discount': discount,
      if (total != null) 'total': total,
      if (customerId != null) 'customer_id': customerId,
      if (customerName != null) 'customer_name': customerName,
      if (workerId != null) 'worker_id': workerId,
      if (branchId != null) 'branch_id': branchId,
      if (createdAt != null) 'created_at': createdAt,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SalesCompanion copyWith(
      {Value<String>? id,
      Value<double>? subtotal,
      Value<double>? discount,
      Value<double>? total,
      Value<String?>? customerId,
      Value<String?>? customerName,
      Value<String>? workerId,
      Value<String?>? branchId,
      Value<DateTime>? createdAt,
      Value<String>? paymentMethod,
      Value<int>? rowid}) {
    return SalesCompanion(
      id: id ?? this.id,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      workerId: workerId ?? this.workerId,
      branchId: branchId ?? this.branchId,
      createdAt: createdAt ?? this.createdAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (discount.present) {
      map['discount'] = Variable<double>(discount.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (workerId.present) {
      map['worker_id'] = Variable<String>(workerId.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesCompanion(')
          ..write('id: $id, ')
          ..write('subtotal: $subtotal, ')
          ..write('discount: $discount, ')
          ..write('total: $total, ')
          ..write('customerId: $customerId, ')
          ..write('customerName: $customerName, ')
          ..write('workerId: $workerId, ')
          ..write('branchId: $branchId, ')
          ..write('createdAt: $createdAt, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SaleItemsTable extends SaleItems
    with TableInfo<$SaleItemsTable, SaleItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaleItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
      'sale_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productNameMeta =
      const VerificationMeta('productName');
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
      'product_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _unitPriceMeta =
      const VerificationMeta('unitPrice');
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
      'unit_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _totalPriceMeta =
      const VerificationMeta('totalPrice');
  @override
  late final GeneratedColumn<double> totalPrice = GeneratedColumn<double>(
      'total_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, saleId, productId, productName, quantity, unitPrice, totalPrice];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sale_items';
  @override
  VerificationContext validateIntegrity(Insertable<SaleItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sale_id')) {
      context.handle(_saleIdMeta,
          saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta));
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
          _productNameMeta,
          productName.isAcceptableOrUnknown(
              data['product_name']!, _productNameMeta));
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_price')) {
      context.handle(_unitPriceMeta,
          unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta));
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('total_price')) {
      context.handle(
          _totalPriceMeta,
          totalPrice.isAcceptableOrUnknown(
              data['total_price']!, _totalPriceMeta));
    } else if (isInserting) {
      context.missing(_totalPriceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  SaleItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      saleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sale_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      productName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_name'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      unitPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_price'])!,
      totalPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_price'])!,
    );
  }

  @override
  $SaleItemsTable createAlias(String alias) {
    return $SaleItemsTable(attachedDatabase, alias);
  }
}

class SaleItem extends DataClass implements Insertable<SaleItem> {
  final String id;
  final String saleId;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  const SaleItem(
      {required this.id,
      required this.saleId,
      required this.productId,
      required this.productName,
      required this.quantity,
      required this.unitPrice,
      required this.totalPrice});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sale_id'] = Variable<String>(saleId);
    map['product_id'] = Variable<String>(productId);
    map['product_name'] = Variable<String>(productName);
    map['quantity'] = Variable<int>(quantity);
    map['unit_price'] = Variable<double>(unitPrice);
    map['total_price'] = Variable<double>(totalPrice);
    return map;
  }

  SaleItemsCompanion toCompanion(bool nullToAbsent) {
    return SaleItemsCompanion(
      id: Value(id),
      saleId: Value(saleId),
      productId: Value(productId),
      productName: Value(productName),
      quantity: Value(quantity),
      unitPrice: Value(unitPrice),
      totalPrice: Value(totalPrice),
    );
  }

  factory SaleItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleItem(
      id: serializer.fromJson<String>(json['id']),
      saleId: serializer.fromJson<String>(json['saleId']),
      productId: serializer.fromJson<String>(json['productId']),
      productName: serializer.fromJson<String>(json['productName']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      totalPrice: serializer.fromJson<double>(json['totalPrice']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'saleId': serializer.toJson<String>(saleId),
      'productId': serializer.toJson<String>(productId),
      'productName': serializer.toJson<String>(productName),
      'quantity': serializer.toJson<int>(quantity),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'totalPrice': serializer.toJson<double>(totalPrice),
    };
  }

  SaleItem copyWith(
          {String? id,
          String? saleId,
          String? productId,
          String? productName,
          int? quantity,
          double? unitPrice,
          double? totalPrice}) =>
      SaleItem(
        id: id ?? this.id,
        saleId: saleId ?? this.saleId,
        productId: productId ?? this.productId,
        productName: productName ?? this.productName,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice ?? this.unitPrice,
        totalPrice: totalPrice ?? this.totalPrice,
      );
  SaleItem copyWithCompanion(SaleItemsCompanion data) {
    return SaleItem(
      id: data.id.present ? data.id.value : this.id,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      productId: data.productId.present ? data.productId.value : this.productId,
      productName:
          data.productName.present ? data.productName.value : this.productName,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      totalPrice:
          data.totalPrice.present ? data.totalPrice.value : this.totalPrice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleItem(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('totalPrice: $totalPrice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, saleId, productId, productName, quantity, unitPrice, totalPrice);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleItem &&
          other.id == this.id &&
          other.saleId == this.saleId &&
          other.productId == this.productId &&
          other.productName == this.productName &&
          other.quantity == this.quantity &&
          other.unitPrice == this.unitPrice &&
          other.totalPrice == this.totalPrice);
}

class SaleItemsCompanion extends UpdateCompanion<SaleItem> {
  final Value<String> id;
  final Value<String> saleId;
  final Value<String> productId;
  final Value<String> productName;
  final Value<int> quantity;
  final Value<double> unitPrice;
  final Value<double> totalPrice;
  final Value<int> rowid;
  const SaleItemsCompanion({
    this.id = const Value.absent(),
    this.saleId = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.totalPrice = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SaleItemsCompanion.insert({
    required String id,
    required String saleId,
    required String productId,
    required String productName,
    required int quantity,
    required double unitPrice,
    required double totalPrice,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        saleId = Value(saleId),
        productId = Value(productId),
        productName = Value(productName),
        quantity = Value(quantity),
        unitPrice = Value(unitPrice),
        totalPrice = Value(totalPrice);
  static Insertable<SaleItem> custom({
    Expression<String>? id,
    Expression<String>? saleId,
    Expression<String>? productId,
    Expression<String>? productName,
    Expression<int>? quantity,
    Expression<double>? unitPrice,
    Expression<double>? totalPrice,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saleId != null) 'sale_id': saleId,
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (totalPrice != null) 'total_price': totalPrice,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SaleItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? saleId,
      Value<String>? productId,
      Value<String>? productName,
      Value<int>? quantity,
      Value<double>? unitPrice,
      Value<double>? totalPrice,
      Value<int>? rowid}) {
    return SaleItemsCompanion(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (totalPrice.present) {
      map['total_price'] = Variable<double>(totalPrice.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleItemsCompanion(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('totalPrice: $totalPrice, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DebtsTable extends Debts with TableInfo<$DebtsTable, Debt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DebtsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _customerIdMeta =
      const VerificationMeta('customerId');
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
      'customer_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _customerNameMeta =
      const VerificationMeta('customerName');
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
      'customer_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _customerPhoneMeta =
      const VerificationMeta('customerPhone');
  @override
  late final GeneratedColumn<String> customerPhone = GeneratedColumn<String>(
      'customer_phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _originalAmountMeta =
      const VerificationMeta('originalAmount');
  @override
  late final GeneratedColumn<double> originalAmount = GeneratedColumn<double>(
      'original_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _paidAmountMeta =
      const VerificationMeta('paidAmount');
  @override
  late final GeneratedColumn<double> paidAmount = GeneratedColumn<double>(
      'paid_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _branchIdMeta =
      const VerificationMeta('branchId');
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
      'branch_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        customerId,
        customerName,
        customerPhone,
        originalAmount,
        paidAmount,
        createdAt,
        dueDate,
        note,
        branchId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'debts';
  @override
  VerificationContext validateIntegrity(Insertable<Debt> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
          _customerIdMeta,
          customerId.isAcceptableOrUnknown(
              data['customer_id']!, _customerIdMeta));
    }
    if (data.containsKey('customer_name')) {
      context.handle(
          _customerNameMeta,
          customerName.isAcceptableOrUnknown(
              data['customer_name']!, _customerNameMeta));
    } else if (isInserting) {
      context.missing(_customerNameMeta);
    }
    if (data.containsKey('customer_phone')) {
      context.handle(
          _customerPhoneMeta,
          customerPhone.isAcceptableOrUnknown(
              data['customer_phone']!, _customerPhoneMeta));
    }
    if (data.containsKey('original_amount')) {
      context.handle(
          _originalAmountMeta,
          originalAmount.isAcceptableOrUnknown(
              data['original_amount']!, _originalAmountMeta));
    } else if (isInserting) {
      context.missing(_originalAmountMeta);
    }
    if (data.containsKey('paid_amount')) {
      context.handle(
          _paidAmountMeta,
          paidAmount.isAcceptableOrUnknown(
              data['paid_amount']!, _paidAmountMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('branch_id')) {
      context.handle(_branchIdMeta,
          branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Debt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Debt(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      customerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_id']),
      customerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_name'])!,
      customerPhone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_phone']),
      originalAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}original_amount'])!,
      paidAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}paid_amount'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      branchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}branch_id']),
    );
  }

  @override
  $DebtsTable createAlias(String alias) {
    return $DebtsTable(attachedDatabase, alias);
  }
}

class Debt extends DataClass implements Insertable<Debt> {
  final String id;
  final String? customerId;
  final String customerName;
  final String? customerPhone;
  final double originalAmount;
  final double paidAmount;
  final DateTime createdAt;
  final DateTime? dueDate;
  final String? note;
  final String? branchId;
  const Debt(
      {required this.id,
      this.customerId,
      required this.customerName,
      this.customerPhone,
      required this.originalAmount,
      required this.paidAmount,
      required this.createdAt,
      this.dueDate,
      this.note,
      this.branchId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    map['customer_name'] = Variable<String>(customerName);
    if (!nullToAbsent || customerPhone != null) {
      map['customer_phone'] = Variable<String>(customerPhone);
    }
    map['original_amount'] = Variable<double>(originalAmount);
    map['paid_amount'] = Variable<double>(paidAmount);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || branchId != null) {
      map['branch_id'] = Variable<String>(branchId);
    }
    return map;
  }

  DebtsCompanion toCompanion(bool nullToAbsent) {
    return DebtsCompanion(
      id: Value(id),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      customerName: Value(customerName),
      customerPhone: customerPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(customerPhone),
      originalAmount: Value(originalAmount),
      paidAmount: Value(paidAmount),
      createdAt: Value(createdAt),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      branchId: branchId == null && nullToAbsent
          ? const Value.absent()
          : Value(branchId),
    );
  }

  factory Debt.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Debt(
      id: serializer.fromJson<String>(json['id']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      customerName: serializer.fromJson<String>(json['customerName']),
      customerPhone: serializer.fromJson<String?>(json['customerPhone']),
      originalAmount: serializer.fromJson<double>(json['originalAmount']),
      paidAmount: serializer.fromJson<double>(json['paidAmount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      note: serializer.fromJson<String?>(json['note']),
      branchId: serializer.fromJson<String?>(json['branchId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'customerId': serializer.toJson<String?>(customerId),
      'customerName': serializer.toJson<String>(customerName),
      'customerPhone': serializer.toJson<String?>(customerPhone),
      'originalAmount': serializer.toJson<double>(originalAmount),
      'paidAmount': serializer.toJson<double>(paidAmount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'note': serializer.toJson<String?>(note),
      'branchId': serializer.toJson<String?>(branchId),
    };
  }

  Debt copyWith(
          {String? id,
          Value<String?> customerId = const Value.absent(),
          String? customerName,
          Value<String?> customerPhone = const Value.absent(),
          double? originalAmount,
          double? paidAmount,
          DateTime? createdAt,
          Value<DateTime?> dueDate = const Value.absent(),
          Value<String?> note = const Value.absent(),
          Value<String?> branchId = const Value.absent()}) =>
      Debt(
        id: id ?? this.id,
        customerId: customerId.present ? customerId.value : this.customerId,
        customerName: customerName ?? this.customerName,
        customerPhone:
            customerPhone.present ? customerPhone.value : this.customerPhone,
        originalAmount: originalAmount ?? this.originalAmount,
        paidAmount: paidAmount ?? this.paidAmount,
        createdAt: createdAt ?? this.createdAt,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        note: note.present ? note.value : this.note,
        branchId: branchId.present ? branchId.value : this.branchId,
      );
  Debt copyWithCompanion(DebtsCompanion data) {
    return Debt(
      id: data.id.present ? data.id.value : this.id,
      customerId:
          data.customerId.present ? data.customerId.value : this.customerId,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      customerPhone: data.customerPhone.present
          ? data.customerPhone.value
          : this.customerPhone,
      originalAmount: data.originalAmount.present
          ? data.originalAmount.value
          : this.originalAmount,
      paidAmount:
          data.paidAmount.present ? data.paidAmount.value : this.paidAmount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      note: data.note.present ? data.note.value : this.note,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Debt(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('customerName: $customerName, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('originalAmount: $originalAmount, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('createdAt: $createdAt, ')
          ..write('dueDate: $dueDate, ')
          ..write('note: $note, ')
          ..write('branchId: $branchId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, customerId, customerName, customerPhone,
      originalAmount, paidAmount, createdAt, dueDate, note, branchId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Debt &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.customerName == this.customerName &&
          other.customerPhone == this.customerPhone &&
          other.originalAmount == this.originalAmount &&
          other.paidAmount == this.paidAmount &&
          other.createdAt == this.createdAt &&
          other.dueDate == this.dueDate &&
          other.note == this.note &&
          other.branchId == this.branchId);
}

class DebtsCompanion extends UpdateCompanion<Debt> {
  final Value<String> id;
  final Value<String?> customerId;
  final Value<String> customerName;
  final Value<String?> customerPhone;
  final Value<double> originalAmount;
  final Value<double> paidAmount;
  final Value<DateTime> createdAt;
  final Value<DateTime?> dueDate;
  final Value<String?> note;
  final Value<String?> branchId;
  final Value<int> rowid;
  const DebtsCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.customerName = const Value.absent(),
    this.customerPhone = const Value.absent(),
    this.originalAmount = const Value.absent(),
    this.paidAmount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.note = const Value.absent(),
    this.branchId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DebtsCompanion.insert({
    required String id,
    this.customerId = const Value.absent(),
    required String customerName,
    this.customerPhone = const Value.absent(),
    required double originalAmount,
    this.paidAmount = const Value.absent(),
    required DateTime createdAt,
    this.dueDate = const Value.absent(),
    this.note = const Value.absent(),
    this.branchId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        customerName = Value(customerName),
        originalAmount = Value(originalAmount),
        createdAt = Value(createdAt);
  static Insertable<Debt> custom({
    Expression<String>? id,
    Expression<String>? customerId,
    Expression<String>? customerName,
    Expression<String>? customerPhone,
    Expression<double>? originalAmount,
    Expression<double>? paidAmount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? dueDate,
    Expression<String>? note,
    Expression<String>? branchId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (customerName != null) 'customer_name': customerName,
      if (customerPhone != null) 'customer_phone': customerPhone,
      if (originalAmount != null) 'original_amount': originalAmount,
      if (paidAmount != null) 'paid_amount': paidAmount,
      if (createdAt != null) 'created_at': createdAt,
      if (dueDate != null) 'due_date': dueDate,
      if (note != null) 'note': note,
      if (branchId != null) 'branch_id': branchId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DebtsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? customerId,
      Value<String>? customerName,
      Value<String?>? customerPhone,
      Value<double>? originalAmount,
      Value<double>? paidAmount,
      Value<DateTime>? createdAt,
      Value<DateTime?>? dueDate,
      Value<String?>? note,
      Value<String?>? branchId,
      Value<int>? rowid}) {
    return DebtsCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      originalAmount: originalAmount ?? this.originalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      note: note ?? this.note,
      branchId: branchId ?? this.branchId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (customerPhone.present) {
      map['customer_phone'] = Variable<String>(customerPhone.value);
    }
    if (originalAmount.present) {
      map['original_amount'] = Variable<double>(originalAmount.value);
    }
    if (paidAmount.present) {
      map['paid_amount'] = Variable<double>(paidAmount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DebtsCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('customerName: $customerName, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('originalAmount: $originalAmount, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('createdAt: $createdAt, ')
          ..write('dueDate: $dueDate, ')
          ..write('note: $note, ')
          ..write('branchId: $branchId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BranchesTable extends Branches with TableInfo<$BranchesTable, Branche> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BranchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _dailySalesMeta =
      const VerificationMeta('dailySales');
  @override
  late final GeneratedColumn<double> dailySales = GeneratedColumn<double>(
      'daily_sales', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _workerCountMeta =
      const VerificationMeta('workerCount');
  @override
  late final GeneratedColumn<int> workerCount = GeneratedColumn<int>(
      'worker_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, address, isActive, dailySales, workerCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'branches';
  @override
  VerificationContext validateIntegrity(Insertable<Branche> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('daily_sales')) {
      context.handle(
          _dailySalesMeta,
          dailySales.isAcceptableOrUnknown(
              data['daily_sales']!, _dailySalesMeta));
    }
    if (data.containsKey('worker_count')) {
      context.handle(
          _workerCountMeta,
          workerCount.isAcceptableOrUnknown(
              data['worker_count']!, _workerCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Branche map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Branche(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      dailySales: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}daily_sales'])!,
      workerCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}worker_count'])!,
    );
  }

  @override
  $BranchesTable createAlias(String alias) {
    return $BranchesTable(attachedDatabase, alias);
  }
}

class Branche extends DataClass implements Insertable<Branche> {
  final String id;
  final String name;
  final String? address;
  final bool isActive;
  final double dailySales;
  final int workerCount;
  const Branche(
      {required this.id,
      required this.name,
      this.address,
      required this.isActive,
      required this.dailySales,
      required this.workerCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['daily_sales'] = Variable<double>(dailySales);
    map['worker_count'] = Variable<int>(workerCount);
    return map;
  }

  BranchesCompanion toCompanion(bool nullToAbsent) {
    return BranchesCompanion(
      id: Value(id),
      name: Value(name),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      isActive: Value(isActive),
      dailySales: Value(dailySales),
      workerCount: Value(workerCount),
    );
  }

  factory Branche.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Branche(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      address: serializer.fromJson<String?>(json['address']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      dailySales: serializer.fromJson<double>(json['dailySales']),
      workerCount: serializer.fromJson<int>(json['workerCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'address': serializer.toJson<String?>(address),
      'isActive': serializer.toJson<bool>(isActive),
      'dailySales': serializer.toJson<double>(dailySales),
      'workerCount': serializer.toJson<int>(workerCount),
    };
  }

  Branche copyWith(
          {String? id,
          String? name,
          Value<String?> address = const Value.absent(),
          bool? isActive,
          double? dailySales,
          int? workerCount}) =>
      Branche(
        id: id ?? this.id,
        name: name ?? this.name,
        address: address.present ? address.value : this.address,
        isActive: isActive ?? this.isActive,
        dailySales: dailySales ?? this.dailySales,
        workerCount: workerCount ?? this.workerCount,
      );
  Branche copyWithCompanion(BranchesCompanion data) {
    return Branche(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      address: data.address.present ? data.address.value : this.address,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      dailySales:
          data.dailySales.present ? data.dailySales.value : this.dailySales,
      workerCount:
          data.workerCount.present ? data.workerCount.value : this.workerCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Branche(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('isActive: $isActive, ')
          ..write('dailySales: $dailySales, ')
          ..write('workerCount: $workerCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, address, isActive, dailySales, workerCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Branche &&
          other.id == this.id &&
          other.name == this.name &&
          other.address == this.address &&
          other.isActive == this.isActive &&
          other.dailySales == this.dailySales &&
          other.workerCount == this.workerCount);
}

class BranchesCompanion extends UpdateCompanion<Branche> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> address;
  final Value<bool> isActive;
  final Value<double> dailySales;
  final Value<int> workerCount;
  final Value<int> rowid;
  const BranchesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.address = const Value.absent(),
    this.isActive = const Value.absent(),
    this.dailySales = const Value.absent(),
    this.workerCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BranchesCompanion.insert({
    required String id,
    required String name,
    this.address = const Value.absent(),
    this.isActive = const Value.absent(),
    this.dailySales = const Value.absent(),
    this.workerCount = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<Branche> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? address,
    Expression<bool>? isActive,
    Expression<double>? dailySales,
    Expression<int>? workerCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (isActive != null) 'is_active': isActive,
      if (dailySales != null) 'daily_sales': dailySales,
      if (workerCount != null) 'worker_count': workerCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BranchesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? address,
      Value<bool>? isActive,
      Value<double>? dailySales,
      Value<int>? workerCount,
      Value<int>? rowid}) {
    return BranchesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      dailySales: dailySales ?? this.dailySales,
      workerCount: workerCount ?? this.workerCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (dailySales.present) {
      map['daily_sales'] = Variable<double>(dailySales.value);
    }
    if (workerCount.present) {
      map['worker_count'] = Variable<int>(workerCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BranchesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('isActive: $isActive, ')
          ..write('dailySales: $dailySales, ')
          ..write('workerCount: $workerCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, Customer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fullNameMeta =
      const VerificationMeta('fullName');
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
      'full_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns =>
      [id, fullName, email, phone, address, note, createdAt, isActive];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(Insertable<Customer> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(_fullNameMeta,
          fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta));
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Customer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Customer(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      fullName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}full_name'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class Customer extends DataClass implements Insertable<Customer> {
  final String id;
  final String fullName;
  final String? email;
  final String? phone;
  final String? address;
  final String? note;
  final DateTime createdAt;
  final bool isActive;
  const Customer(
      {required this.id,
      required this.fullName,
      this.email,
      this.phone,
      this.address,
      this.note,
      required this.createdAt,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['full_name'] = Variable<String>(fullName);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      fullName: Value(fullName),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      isActive: Value(isActive),
    );
  }

  factory Customer.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Customer(
      id: serializer.fromJson<String>(json['id']),
      fullName: serializer.fromJson<String>(json['fullName']),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
      address: serializer.fromJson<String?>(json['address']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fullName': serializer.toJson<String>(fullName),
      'email': serializer.toJson<String?>(email),
      'phone': serializer.toJson<String?>(phone),
      'address': serializer.toJson<String?>(address),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  Customer copyWith(
          {String? id,
          String? fullName,
          Value<String?> email = const Value.absent(),
          Value<String?> phone = const Value.absent(),
          Value<String?> address = const Value.absent(),
          Value<String?> note = const Value.absent(),
          DateTime? createdAt,
          bool? isActive}) =>
      Customer(
        id: id ?? this.id,
        fullName: fullName ?? this.fullName,
        email: email.present ? email.value : this.email,
        phone: phone.present ? phone.value : this.phone,
        address: address.present ? address.value : this.address,
        note: note.present ? note.value : this.note,
        createdAt: createdAt ?? this.createdAt,
        isActive: isActive ?? this.isActive,
      );
  Customer copyWithCompanion(CustomersCompanion data) {
    return Customer(
      id: data.id.present ? data.id.value : this.id,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      address: data.address.present ? data.address.value : this.address,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Customer(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, fullName, email, phone, address, note, createdAt, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Customer &&
          other.id == this.id &&
          other.fullName == this.fullName &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.address == this.address &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.isActive == this.isActive);
}

class CustomersCompanion extends UpdateCompanion<Customer> {
  final Value<String> id;
  final Value<String> fullName;
  final Value<String?> email;
  final Value<String?> phone;
  final Value<String?> address;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<bool> isActive;
  final Value<int> rowid;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.fullName = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomersCompanion.insert({
    required String id,
    required String fullName,
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        fullName = Value(fullName),
        createdAt = Value(createdAt);
  static Insertable<Customer> custom({
    Expression<String>? id,
    Expression<String>? fullName,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? address,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fullName != null) 'full_name': fullName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomersCompanion copyWith(
      {Value<String>? id,
      Value<String>? fullName,
      Value<String?>? email,
      Value<String?>? phone,
      Value<String?>? address,
      Value<String?>? note,
      Value<DateTime>? createdAt,
      Value<bool>? isActive,
      Value<int>? rowid}) {
    return CustomersCompanion(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PromotionsTable extends Promotions
    with TableInfo<$PromotionsTable, Promotion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PromotionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _discountMeta =
      const VerificationMeta('discount');
  @override
  late final GeneratedColumn<String> discount = GeneratedColumn<String>(
      'discount', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _expiresAtMeta =
      const VerificationMeta('expiresAt');
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
      'expires_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, discount, isActive, expiresAt, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'promotions';
  @override
  VerificationContext validateIntegrity(Insertable<Promotion> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('discount')) {
      context.handle(_discountMeta,
          discount.isAcceptableOrUnknown(data['discount']!, _discountMeta));
    } else if (isInserting) {
      context.missing(_discountMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('expires_at')) {
      context.handle(_expiresAtMeta,
          expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta));
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Promotion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Promotion(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      discount: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}discount'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      expiresAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expires_at'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PromotionsTable createAlias(String alias) {
    return $PromotionsTable(attachedDatabase, alias);
  }
}

class Promotion extends DataClass implements Insertable<Promotion> {
  final String id;
  final String title;
  final String discount;
  final bool isActive;
  final DateTime expiresAt;
  final DateTime createdAt;
  const Promotion(
      {required this.id,
      required this.title,
      required this.discount,
      required this.isActive,
      required this.expiresAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['discount'] = Variable<String>(discount);
    map['is_active'] = Variable<bool>(isActive);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PromotionsCompanion toCompanion(bool nullToAbsent) {
    return PromotionsCompanion(
      id: Value(id),
      title: Value(title),
      discount: Value(discount),
      isActive: Value(isActive),
      expiresAt: Value(expiresAt),
      createdAt: Value(createdAt),
    );
  }

  factory Promotion.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Promotion(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      discount: serializer.fromJson<String>(json['discount']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'discount': serializer.toJson<String>(discount),
      'isActive': serializer.toJson<bool>(isActive),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Promotion copyWith(
          {String? id,
          String? title,
          String? discount,
          bool? isActive,
          DateTime? expiresAt,
          DateTime? createdAt}) =>
      Promotion(
        id: id ?? this.id,
        title: title ?? this.title,
        discount: discount ?? this.discount,
        isActive: isActive ?? this.isActive,
        expiresAt: expiresAt ?? this.expiresAt,
        createdAt: createdAt ?? this.createdAt,
      );
  Promotion copyWithCompanion(PromotionsCompanion data) {
    return Promotion(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      discount: data.discount.present ? data.discount.value : this.discount,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Promotion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('discount: $discount, ')
          ..write('isActive: $isActive, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, discount, isActive, expiresAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Promotion &&
          other.id == this.id &&
          other.title == this.title &&
          other.discount == this.discount &&
          other.isActive == this.isActive &&
          other.expiresAt == this.expiresAt &&
          other.createdAt == this.createdAt);
}

class PromotionsCompanion extends UpdateCompanion<Promotion> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> discount;
  final Value<bool> isActive;
  final Value<DateTime> expiresAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PromotionsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.discount = const Value.absent(),
    this.isActive = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PromotionsCompanion.insert({
    required String id,
    required String title,
    required String discount,
    this.isActive = const Value.absent(),
    required DateTime expiresAt,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        discount = Value(discount),
        expiresAt = Value(expiresAt),
        createdAt = Value(createdAt);
  static Insertable<Promotion> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? discount,
    Expression<bool>? isActive,
    Expression<DateTime>? expiresAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (discount != null) 'discount': discount,
      if (isActive != null) 'is_active': isActive,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PromotionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? discount,
      Value<bool>? isActive,
      Value<DateTime>? expiresAt,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return PromotionsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      discount: discount ?? this.discount,
      isActive: isActive ?? this.isActive,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (discount.present) {
      map['discount'] = Variable<String>(discount.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PromotionsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('discount: $discount, ')
          ..write('isActive: $isActive, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $SalesTable sales = $SalesTable(this);
  late final $SaleItemsTable saleItems = $SaleItemsTable(this);
  late final $DebtsTable debts = $DebtsTable(this);
  late final $BranchesTable branches = $BranchesTable(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $PromotionsTable promotions = $PromotionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [products, sales, saleItems, debts, branches, customers, promotions];
}

typedef $$ProductsTableCreateCompanionBuilder = ProductsCompanion Function({
  required String id,
  required String name,
  required String category,
  required double purchasePrice,
  required double sellingPrice,
  required int quantity,
  Value<String?> barcode,
  Value<String?> imageUrl,
  Value<String?> description,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> isActive,
  Value<String?> branchId,
  Value<int> rowid,
});
typedef $$ProductsTableUpdateCompanionBuilder = ProductsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> category,
  Value<double> purchasePrice,
  Value<double> sellingPrice,
  Value<int> quantity,
  Value<String?> barcode,
  Value<String?> imageUrl,
  Value<String?> description,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isActive,
  Value<String?> branchId,
  Value<int> rowid,
});

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get purchasePrice => $composableBuilder(
      column: $table.purchasePrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get sellingPrice => $composableBuilder(
      column: $table.sellingPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get branchId => $composableBuilder(
      column: $table.branchId, builder: (column) => ColumnFilters(column));
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get purchasePrice => $composableBuilder(
      column: $table.purchasePrice,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get sellingPrice => $composableBuilder(
      column: $table.sellingPrice,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get branchId => $composableBuilder(
      column: $table.branchId, builder: (column) => ColumnOrderings(column));
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get purchasePrice => $composableBuilder(
      column: $table.purchasePrice, builder: (column) => column);

  GeneratedColumn<double> get sellingPrice => $composableBuilder(
      column: $table.sellingPrice, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);
}

class $$ProductsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProductsTable,
    Product,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (Product, BaseReferences<_$AppDatabase, $ProductsTable, Product>),
    Product,
    PrefetchHooks Function()> {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<double> purchasePrice = const Value.absent(),
            Value<double> sellingPrice = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<String?> barcode = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String?> branchId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductsCompanion(
            id: id,
            name: name,
            category: category,
            purchasePrice: purchasePrice,
            sellingPrice: sellingPrice,
            quantity: quantity,
            barcode: barcode,
            imageUrl: imageUrl,
            description: description,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isActive: isActive,
            branchId: branchId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String category,
            required double purchasePrice,
            required double sellingPrice,
            required int quantity,
            Value<String?> barcode = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<String?> description = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> isActive = const Value.absent(),
            Value<String?> branchId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductsCompanion.insert(
            id: id,
            name: name,
            category: category,
            purchasePrice: purchasePrice,
            sellingPrice: sellingPrice,
            quantity: quantity,
            barcode: barcode,
            imageUrl: imageUrl,
            description: description,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isActive: isActive,
            branchId: branchId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProductsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProductsTable,
    Product,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (Product, BaseReferences<_$AppDatabase, $ProductsTable, Product>),
    Product,
    PrefetchHooks Function()>;
typedef $$SalesTableCreateCompanionBuilder = SalesCompanion Function({
  required String id,
  required double subtotal,
  Value<double> discount,
  required double total,
  Value<String?> customerId,
  Value<String?> customerName,
  required String workerId,
  Value<String?> branchId,
  required DateTime createdAt,
  Value<String> paymentMethod,
  Value<int> rowid,
});
typedef $$SalesTableUpdateCompanionBuilder = SalesCompanion Function({
  Value<String> id,
  Value<double> subtotal,
  Value<double> discount,
  Value<double> total,
  Value<String?> customerId,
  Value<String?> customerName,
  Value<String> workerId,
  Value<String?> branchId,
  Value<DateTime> createdAt,
  Value<String> paymentMethod,
  Value<int> rowid,
});

class $$SalesTableFilterComposer extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get discount => $composableBuilder(
      column: $table.discount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get workerId => $composableBuilder(
      column: $table.workerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get branchId => $composableBuilder(
      column: $table.branchId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => ColumnFilters(column));
}

class $$SalesTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get discount => $composableBuilder(
      column: $table.discount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerName => $composableBuilder(
      column: $table.customerName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get workerId => $composableBuilder(
      column: $table.workerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get branchId => $composableBuilder(
      column: $table.branchId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod,
      builder: (column) => ColumnOrderings(column));
}

class $$SalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<double> get discount =>
      $composableBuilder(column: $table.discount, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => column);

  GeneratedColumn<String> get workerId =>
      $composableBuilder(column: $table.workerId, builder: (column) => column);

  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => column);
}

class $$SalesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SalesTable,
    Sale,
    $$SalesTableFilterComposer,
    $$SalesTableOrderingComposer,
    $$SalesTableAnnotationComposer,
    $$SalesTableCreateCompanionBuilder,
    $$SalesTableUpdateCompanionBuilder,
    (Sale, BaseReferences<_$AppDatabase, $SalesTable, Sale>),
    Sale,
    PrefetchHooks Function()> {
  $$SalesTableTableManager(_$AppDatabase db, $SalesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<double> subtotal = const Value.absent(),
            Value<double> discount = const Value.absent(),
            Value<double> total = const Value.absent(),
            Value<String?> customerId = const Value.absent(),
            Value<String?> customerName = const Value.absent(),
            Value<String> workerId = const Value.absent(),
            Value<String?> branchId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> paymentMethod = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SalesCompanion(
            id: id,
            subtotal: subtotal,
            discount: discount,
            total: total,
            customerId: customerId,
            customerName: customerName,
            workerId: workerId,
            branchId: branchId,
            createdAt: createdAt,
            paymentMethod: paymentMethod,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required double subtotal,
            Value<double> discount = const Value.absent(),
            required double total,
            Value<String?> customerId = const Value.absent(),
            Value<String?> customerName = const Value.absent(),
            required String workerId,
            Value<String?> branchId = const Value.absent(),
            required DateTime createdAt,
            Value<String> paymentMethod = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SalesCompanion.insert(
            id: id,
            subtotal: subtotal,
            discount: discount,
            total: total,
            customerId: customerId,
            customerName: customerName,
            workerId: workerId,
            branchId: branchId,
            createdAt: createdAt,
            paymentMethod: paymentMethod,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SalesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SalesTable,
    Sale,
    $$SalesTableFilterComposer,
    $$SalesTableOrderingComposer,
    $$SalesTableAnnotationComposer,
    $$SalesTableCreateCompanionBuilder,
    $$SalesTableUpdateCompanionBuilder,
    (Sale, BaseReferences<_$AppDatabase, $SalesTable, Sale>),
    Sale,
    PrefetchHooks Function()>;
typedef $$SaleItemsTableCreateCompanionBuilder = SaleItemsCompanion Function({
  required String id,
  required String saleId,
  required String productId,
  required String productName,
  required int quantity,
  required double unitPrice,
  required double totalPrice,
  Value<int> rowid,
});
typedef $$SaleItemsTableUpdateCompanionBuilder = SaleItemsCompanion Function({
  Value<String> id,
  Value<String> saleId,
  Value<String> productId,
  Value<String> productName,
  Value<int> quantity,
  Value<double> unitPrice,
  Value<double> totalPrice,
  Value<int> rowid,
});

class $$SaleItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SaleItemsTable> {
  $$SaleItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get saleId => $composableBuilder(
      column: $table.saleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalPrice => $composableBuilder(
      column: $table.totalPrice, builder: (column) => ColumnFilters(column));
}

class $$SaleItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SaleItemsTable> {
  $$SaleItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get saleId => $composableBuilder(
      column: $table.saleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalPrice => $composableBuilder(
      column: $table.totalPrice, builder: (column) => ColumnOrderings(column));
}

class $$SaleItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaleItemsTable> {
  $$SaleItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get saleId =>
      $composableBuilder(column: $table.saleId, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<double> get totalPrice => $composableBuilder(
      column: $table.totalPrice, builder: (column) => column);
}

class $$SaleItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SaleItemsTable,
    SaleItem,
    $$SaleItemsTableFilterComposer,
    $$SaleItemsTableOrderingComposer,
    $$SaleItemsTableAnnotationComposer,
    $$SaleItemsTableCreateCompanionBuilder,
    $$SaleItemsTableUpdateCompanionBuilder,
    (SaleItem, BaseReferences<_$AppDatabase, $SaleItemsTable, SaleItem>),
    SaleItem,
    PrefetchHooks Function()> {
  $$SaleItemsTableTableManager(_$AppDatabase db, $SaleItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaleItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaleItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaleItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> saleId = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<String> productName = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<double> unitPrice = const Value.absent(),
            Value<double> totalPrice = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SaleItemsCompanion(
            id: id,
            saleId: saleId,
            productId: productId,
            productName: productName,
            quantity: quantity,
            unitPrice: unitPrice,
            totalPrice: totalPrice,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String saleId,
            required String productId,
            required String productName,
            required int quantity,
            required double unitPrice,
            required double totalPrice,
            Value<int> rowid = const Value.absent(),
          }) =>
              SaleItemsCompanion.insert(
            id: id,
            saleId: saleId,
            productId: productId,
            productName: productName,
            quantity: quantity,
            unitPrice: unitPrice,
            totalPrice: totalPrice,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SaleItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SaleItemsTable,
    SaleItem,
    $$SaleItemsTableFilterComposer,
    $$SaleItemsTableOrderingComposer,
    $$SaleItemsTableAnnotationComposer,
    $$SaleItemsTableCreateCompanionBuilder,
    $$SaleItemsTableUpdateCompanionBuilder,
    (SaleItem, BaseReferences<_$AppDatabase, $SaleItemsTable, SaleItem>),
    SaleItem,
    PrefetchHooks Function()>;
typedef $$DebtsTableCreateCompanionBuilder = DebtsCompanion Function({
  required String id,
  Value<String?> customerId,
  required String customerName,
  Value<String?> customerPhone,
  required double originalAmount,
  Value<double> paidAmount,
  required DateTime createdAt,
  Value<DateTime?> dueDate,
  Value<String?> note,
  Value<String?> branchId,
  Value<int> rowid,
});
typedef $$DebtsTableUpdateCompanionBuilder = DebtsCompanion Function({
  Value<String> id,
  Value<String?> customerId,
  Value<String> customerName,
  Value<String?> customerPhone,
  Value<double> originalAmount,
  Value<double> paidAmount,
  Value<DateTime> createdAt,
  Value<DateTime?> dueDate,
  Value<String?> note,
  Value<String?> branchId,
  Value<int> rowid,
});

class $$DebtsTableFilterComposer extends Composer<_$AppDatabase, $DebtsTable> {
  $$DebtsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerPhone => $composableBuilder(
      column: $table.customerPhone, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get originalAmount => $composableBuilder(
      column: $table.originalAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get branchId => $composableBuilder(
      column: $table.branchId, builder: (column) => ColumnFilters(column));
}

class $$DebtsTableOrderingComposer
    extends Composer<_$AppDatabase, $DebtsTable> {
  $$DebtsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerName => $composableBuilder(
      column: $table.customerName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerPhone => $composableBuilder(
      column: $table.customerPhone,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get originalAmount => $composableBuilder(
      column: $table.originalAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get branchId => $composableBuilder(
      column: $table.branchId, builder: (column) => ColumnOrderings(column));
}

class $$DebtsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DebtsTable> {
  $$DebtsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => column);

  GeneratedColumn<String> get customerPhone => $composableBuilder(
      column: $table.customerPhone, builder: (column) => column);

  GeneratedColumn<double> get originalAmount => $composableBuilder(
      column: $table.originalAmount, builder: (column) => column);

  GeneratedColumn<double> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);
}

class $$DebtsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DebtsTable,
    Debt,
    $$DebtsTableFilterComposer,
    $$DebtsTableOrderingComposer,
    $$DebtsTableAnnotationComposer,
    $$DebtsTableCreateCompanionBuilder,
    $$DebtsTableUpdateCompanionBuilder,
    (Debt, BaseReferences<_$AppDatabase, $DebtsTable, Debt>),
    Debt,
    PrefetchHooks Function()> {
  $$DebtsTableTableManager(_$AppDatabase db, $DebtsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DebtsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DebtsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DebtsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> customerId = const Value.absent(),
            Value<String> customerName = const Value.absent(),
            Value<String?> customerPhone = const Value.absent(),
            Value<double> originalAmount = const Value.absent(),
            Value<double> paidAmount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<String?> branchId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DebtsCompanion(
            id: id,
            customerId: customerId,
            customerName: customerName,
            customerPhone: customerPhone,
            originalAmount: originalAmount,
            paidAmount: paidAmount,
            createdAt: createdAt,
            dueDate: dueDate,
            note: note,
            branchId: branchId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> customerId = const Value.absent(),
            required String customerName,
            Value<String?> customerPhone = const Value.absent(),
            required double originalAmount,
            Value<double> paidAmount = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> dueDate = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<String?> branchId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DebtsCompanion.insert(
            id: id,
            customerId: customerId,
            customerName: customerName,
            customerPhone: customerPhone,
            originalAmount: originalAmount,
            paidAmount: paidAmount,
            createdAt: createdAt,
            dueDate: dueDate,
            note: note,
            branchId: branchId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DebtsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DebtsTable,
    Debt,
    $$DebtsTableFilterComposer,
    $$DebtsTableOrderingComposer,
    $$DebtsTableAnnotationComposer,
    $$DebtsTableCreateCompanionBuilder,
    $$DebtsTableUpdateCompanionBuilder,
    (Debt, BaseReferences<_$AppDatabase, $DebtsTable, Debt>),
    Debt,
    PrefetchHooks Function()>;
typedef $$BranchesTableCreateCompanionBuilder = BranchesCompanion Function({
  required String id,
  required String name,
  Value<String?> address,
  Value<bool> isActive,
  Value<double> dailySales,
  Value<int> workerCount,
  Value<int> rowid,
});
typedef $$BranchesTableUpdateCompanionBuilder = BranchesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> address,
  Value<bool> isActive,
  Value<double> dailySales,
  Value<int> workerCount,
  Value<int> rowid,
});

class $$BranchesTableFilterComposer
    extends Composer<_$AppDatabase, $BranchesTable> {
  $$BranchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get dailySales => $composableBuilder(
      column: $table.dailySales, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get workerCount => $composableBuilder(
      column: $table.workerCount, builder: (column) => ColumnFilters(column));
}

class $$BranchesTableOrderingComposer
    extends Composer<_$AppDatabase, $BranchesTable> {
  $$BranchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get dailySales => $composableBuilder(
      column: $table.dailySales, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get workerCount => $composableBuilder(
      column: $table.workerCount, builder: (column) => ColumnOrderings(column));
}

class $$BranchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BranchesTable> {
  $$BranchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<double> get dailySales => $composableBuilder(
      column: $table.dailySales, builder: (column) => column);

  GeneratedColumn<int> get workerCount => $composableBuilder(
      column: $table.workerCount, builder: (column) => column);
}

class $$BranchesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BranchesTable,
    Branche,
    $$BranchesTableFilterComposer,
    $$BranchesTableOrderingComposer,
    $$BranchesTableAnnotationComposer,
    $$BranchesTableCreateCompanionBuilder,
    $$BranchesTableUpdateCompanionBuilder,
    (Branche, BaseReferences<_$AppDatabase, $BranchesTable, Branche>),
    Branche,
    PrefetchHooks Function()> {
  $$BranchesTableTableManager(_$AppDatabase db, $BranchesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BranchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BranchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BranchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<double> dailySales = const Value.absent(),
            Value<int> workerCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BranchesCompanion(
            id: id,
            name: name,
            address: address,
            isActive: isActive,
            dailySales: dailySales,
            workerCount: workerCount,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> address = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<double> dailySales = const Value.absent(),
            Value<int> workerCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BranchesCompanion.insert(
            id: id,
            name: name,
            address: address,
            isActive: isActive,
            dailySales: dailySales,
            workerCount: workerCount,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BranchesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BranchesTable,
    Branche,
    $$BranchesTableFilterComposer,
    $$BranchesTableOrderingComposer,
    $$BranchesTableAnnotationComposer,
    $$BranchesTableCreateCompanionBuilder,
    $$BranchesTableUpdateCompanionBuilder,
    (Branche, BaseReferences<_$AppDatabase, $BranchesTable, Branche>),
    Branche,
    PrefetchHooks Function()>;
typedef $$CustomersTableCreateCompanionBuilder = CustomersCompanion Function({
  required String id,
  required String fullName,
  Value<String?> email,
  Value<String?> phone,
  Value<String?> address,
  Value<String?> note,
  required DateTime createdAt,
  Value<bool> isActive,
  Value<int> rowid,
});
typedef $$CustomersTableUpdateCompanionBuilder = CustomersCompanion Function({
  Value<String> id,
  Value<String> fullName,
  Value<String?> email,
  Value<String?> phone,
  Value<String?> address,
  Value<String?> note,
  Value<DateTime> createdAt,
  Value<bool> isActive,
  Value<int> rowid,
});

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$CustomersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CustomersTable,
    Customer,
    $$CustomersTableFilterComposer,
    $$CustomersTableOrderingComposer,
    $$CustomersTableAnnotationComposer,
    $$CustomersTableCreateCompanionBuilder,
    $$CustomersTableUpdateCompanionBuilder,
    (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
    Customer,
    PrefetchHooks Function()> {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> fullName = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomersCompanion(
            id: id,
            fullName: fullName,
            email: email,
            phone: phone,
            address: address,
            note: note,
            createdAt: createdAt,
            isActive: isActive,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String fullName,
            Value<String?> email = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<String?> note = const Value.absent(),
            required DateTime createdAt,
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomersCompanion.insert(
            id: id,
            fullName: fullName,
            email: email,
            phone: phone,
            address: address,
            note: note,
            createdAt: createdAt,
            isActive: isActive,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CustomersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CustomersTable,
    Customer,
    $$CustomersTableFilterComposer,
    $$CustomersTableOrderingComposer,
    $$CustomersTableAnnotationComposer,
    $$CustomersTableCreateCompanionBuilder,
    $$CustomersTableUpdateCompanionBuilder,
    (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
    Customer,
    PrefetchHooks Function()>;
typedef $$PromotionsTableCreateCompanionBuilder = PromotionsCompanion Function({
  required String id,
  required String title,
  required String discount,
  Value<bool> isActive,
  required DateTime expiresAt,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$PromotionsTableUpdateCompanionBuilder = PromotionsCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> discount,
  Value<bool> isActive,
  Value<DateTime> expiresAt,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$PromotionsTableFilterComposer
    extends Composer<_$AppDatabase, $PromotionsTable> {
  $$PromotionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get discount => $composableBuilder(
      column: $table.discount, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$PromotionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PromotionsTable> {
  $$PromotionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get discount => $composableBuilder(
      column: $table.discount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PromotionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PromotionsTable> {
  $$PromotionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get discount =>
      $composableBuilder(column: $table.discount, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PromotionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PromotionsTable,
    Promotion,
    $$PromotionsTableFilterComposer,
    $$PromotionsTableOrderingComposer,
    $$PromotionsTableAnnotationComposer,
    $$PromotionsTableCreateCompanionBuilder,
    $$PromotionsTableUpdateCompanionBuilder,
    (Promotion, BaseReferences<_$AppDatabase, $PromotionsTable, Promotion>),
    Promotion,
    PrefetchHooks Function()> {
  $$PromotionsTableTableManager(_$AppDatabase db, $PromotionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PromotionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PromotionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PromotionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> discount = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> expiresAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PromotionsCompanion(
            id: id,
            title: title,
            discount: discount,
            isActive: isActive,
            expiresAt: expiresAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String discount,
            Value<bool> isActive = const Value.absent(),
            required DateTime expiresAt,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              PromotionsCompanion.insert(
            id: id,
            title: title,
            discount: discount,
            isActive: isActive,
            expiresAt: expiresAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PromotionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PromotionsTable,
    Promotion,
    $$PromotionsTableFilterComposer,
    $$PromotionsTableOrderingComposer,
    $$PromotionsTableAnnotationComposer,
    $$PromotionsTableCreateCompanionBuilder,
    $$PromotionsTableUpdateCompanionBuilder,
    (Promotion, BaseReferences<_$AppDatabase, $PromotionsTable, Promotion>),
    Promotion,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$SalesTableTableManager get sales =>
      $$SalesTableTableManager(_db, _db.sales);
  $$SaleItemsTableTableManager get saleItems =>
      $$SaleItemsTableTableManager(_db, _db.saleItems);
  $$DebtsTableTableManager get debts =>
      $$DebtsTableTableManager(_db, _db.debts);
  $$BranchesTableTableManager get branches =>
      $$BranchesTableTableManager(_db, _db.branches);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$PromotionsTableTableManager get promotions =>
      $$PromotionsTableTableManager(_db, _db.promotions);
}
