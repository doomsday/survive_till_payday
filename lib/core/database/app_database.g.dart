// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('BANK'),
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('KZT'),
  );
  static const VerificationMeta _isNoWithdrawalMeta = const VerificationMeta(
    'isNoWithdrawal',
  );
  @override
  late final GeneratedColumn<bool> isNoWithdrawal = GeneratedColumn<bool>(
    'is_no_withdrawal',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_no_withdrawal" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDepositMeta = const VerificationMeta(
    'isDeposit',
  );
  @override
  late final GeneratedColumn<bool> isDeposit = GeneratedColumn<bool>(
    'is_deposit',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deposit" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _initialBalanceMeta = const VerificationMeta(
    'initialBalance',
  );
  @override
  late final GeneratedColumn<int> initialBalance = GeneratedColumn<int>(
    'initial_balance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _currentBalanceMeta = const VerificationMeta(
    'currentBalance',
  );
  @override
  late final GeneratedColumn<int> currentBalance = GeneratedColumn<int>(
    'current_balance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    currency,
    isNoWithdrawal,
    isDeposit,
    initialBalance,
    currentBalance,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Account> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('is_no_withdrawal')) {
      context.handle(
        _isNoWithdrawalMeta,
        isNoWithdrawal.isAcceptableOrUnknown(
          data['is_no_withdrawal']!,
          _isNoWithdrawalMeta,
        ),
      );
    }
    if (data.containsKey('is_deposit')) {
      context.handle(
        _isDepositMeta,
        isDeposit.isAcceptableOrUnknown(data['is_deposit']!, _isDepositMeta),
      );
    }
    if (data.containsKey('initial_balance')) {
      context.handle(
        _initialBalanceMeta,
        initialBalance.isAcceptableOrUnknown(
          data['initial_balance']!,
          _initialBalanceMeta,
        ),
      );
    }
    if (data.containsKey('current_balance')) {
      context.handle(
        _currentBalanceMeta,
        currentBalance.isAcceptableOrUnknown(
          data['current_balance']!,
          _currentBalanceMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      isNoWithdrawal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_no_withdrawal'],
      )!,
      isDeposit: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deposit'],
      )!,
      initialBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}initial_balance'],
      )!,
      currentBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_balance'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final int id;
  final String name;
  final String type;
  final String currency;
  final bool isNoWithdrawal;
  final bool isDeposit;
  final int initialBalance;
  final int currentBalance;
  final bool isActive;
  final DateTime createdAt;
  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.currency,
    required this.isNoWithdrawal,
    required this.isDeposit,
    required this.initialBalance,
    required this.currentBalance,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['currency'] = Variable<String>(currency);
    map['is_no_withdrawal'] = Variable<bool>(isNoWithdrawal);
    map['is_deposit'] = Variable<bool>(isDeposit);
    map['initial_balance'] = Variable<int>(initialBalance);
    map['current_balance'] = Variable<int>(currentBalance);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      currency: Value(currency),
      isNoWithdrawal: Value(isNoWithdrawal),
      isDeposit: Value(isDeposit),
      initialBalance: Value(initialBalance),
      currentBalance: Value(currentBalance),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory Account.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      currency: serializer.fromJson<String>(json['currency']),
      isNoWithdrawal: serializer.fromJson<bool>(json['isNoWithdrawal']),
      isDeposit: serializer.fromJson<bool>(json['isDeposit']),
      initialBalance: serializer.fromJson<int>(json['initialBalance']),
      currentBalance: serializer.fromJson<int>(json['currentBalance']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'currency': serializer.toJson<String>(currency),
      'isNoWithdrawal': serializer.toJson<bool>(isNoWithdrawal),
      'isDeposit': serializer.toJson<bool>(isDeposit),
      'initialBalance': serializer.toJson<int>(initialBalance),
      'currentBalance': serializer.toJson<int>(currentBalance),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Account copyWith({
    int? id,
    String? name,
    String? type,
    String? currency,
    bool? isNoWithdrawal,
    bool? isDeposit,
    int? initialBalance,
    int? currentBalance,
    bool? isActive,
    DateTime? createdAt,
  }) => Account(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    currency: currency ?? this.currency,
    isNoWithdrawal: isNoWithdrawal ?? this.isNoWithdrawal,
    isDeposit: isDeposit ?? this.isDeposit,
    initialBalance: initialBalance ?? this.initialBalance,
    currentBalance: currentBalance ?? this.currentBalance,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      currency: data.currency.present ? data.currency.value : this.currency,
      isNoWithdrawal: data.isNoWithdrawal.present
          ? data.isNoWithdrawal.value
          : this.isNoWithdrawal,
      isDeposit: data.isDeposit.present ? data.isDeposit.value : this.isDeposit,
      initialBalance: data.initialBalance.present
          ? data.initialBalance.value
          : this.initialBalance,
      currentBalance: data.currentBalance.present
          ? data.currentBalance.value
          : this.currentBalance,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('currency: $currency, ')
          ..write('isNoWithdrawal: $isNoWithdrawal, ')
          ..write('isDeposit: $isDeposit, ')
          ..write('initialBalance: $initialBalance, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    currency,
    isNoWithdrawal,
    isDeposit,
    initialBalance,
    currentBalance,
    isActive,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.currency == this.currency &&
          other.isNoWithdrawal == this.isNoWithdrawal &&
          other.isDeposit == this.isDeposit &&
          other.initialBalance == this.initialBalance &&
          other.currentBalance == this.currentBalance &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String> currency;
  final Value<bool> isNoWithdrawal;
  final Value<bool> isDeposit;
  final Value<int> initialBalance;
  final Value<int> currentBalance;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.currency = const Value.absent(),
    this.isNoWithdrawal = const Value.absent(),
    this.isDeposit = const Value.absent(),
    this.initialBalance = const Value.absent(),
    this.currentBalance = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AccountsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.type = const Value.absent(),
    this.currency = const Value.absent(),
    this.isNoWithdrawal = const Value.absent(),
    this.isDeposit = const Value.absent(),
    this.initialBalance = const Value.absent(),
    this.currentBalance = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Account> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? currency,
    Expression<bool>? isNoWithdrawal,
    Expression<bool>? isDeposit,
    Expression<int>? initialBalance,
    Expression<int>? currentBalance,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (currency != null) 'currency': currency,
      if (isNoWithdrawal != null) 'is_no_withdrawal': isNoWithdrawal,
      if (isDeposit != null) 'is_deposit': isDeposit,
      if (initialBalance != null) 'initial_balance': initialBalance,
      if (currentBalance != null) 'current_balance': currentBalance,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AccountsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? type,
    Value<String>? currency,
    Value<bool>? isNoWithdrawal,
    Value<bool>? isDeposit,
    Value<int>? initialBalance,
    Value<int>? currentBalance,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      isNoWithdrawal: isNoWithdrawal ?? this.isNoWithdrawal,
      isDeposit: isDeposit ?? this.isDeposit,
      initialBalance: initialBalance ?? this.initialBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (isNoWithdrawal.present) {
      map['is_no_withdrawal'] = Variable<bool>(isNoWithdrawal.value);
    }
    if (isDeposit.present) {
      map['is_deposit'] = Variable<bool>(isDeposit.value);
    }
    if (initialBalance.present) {
      map['initial_balance'] = Variable<int>(initialBalance.value);
    }
    if (currentBalance.present) {
      map['current_balance'] = Variable<int>(currentBalance.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('currency: $currency, ')
          ..write('isNoWithdrawal: $isNoWithdrawal, ')
          ..write('isDeposit: $isDeposit, ')
          ..write('initialBalance: $initialBalance, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('category'),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0xFF607D8B),
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isHiddenMeta = const VerificationMeta(
    'isHidden',
  );
  @override
  late final GeneratedColumn<bool> isHidden = GeneratedColumn<bool>(
    'is_hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_hidden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    icon,
    color,
    isSystem,
    isArchived,
    isHidden,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('is_hidden')) {
      context.handle(
        _isHiddenMeta,
        isHidden.isAcceptableOrUnknown(data['is_hidden']!, _isHiddenMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      isHidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_hidden'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String name;
  final String type;
  final String icon;
  final int color;
  final bool isSystem;
  final bool isArchived;
  final bool isHidden;
  const Category({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    required this.isSystem,
    required this.isArchived,
    required this.isHidden,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['icon'] = Variable<String>(icon);
    map['color'] = Variable<int>(color);
    map['is_system'] = Variable<bool>(isSystem);
    map['is_archived'] = Variable<bool>(isArchived);
    map['is_hidden'] = Variable<bool>(isHidden);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      icon: Value(icon),
      color: Value(color),
      isSystem: Value(isSystem),
      isArchived: Value(isArchived),
      isHidden: Value(isHidden),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<int>(json['color']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      isHidden: serializer.fromJson<bool>(json['isHidden']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<int>(color),
      'isSystem': serializer.toJson<bool>(isSystem),
      'isArchived': serializer.toJson<bool>(isArchived),
      'isHidden': serializer.toJson<bool>(isHidden),
    };
  }

  Category copyWith({
    int? id,
    String? name,
    String? type,
    String? icon,
    int? color,
    bool? isSystem,
    bool? isArchived,
    bool? isHidden,
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    isSystem: isSystem ?? this.isSystem,
    isArchived: isArchived ?? this.isArchived,
    isHidden: isHidden ?? this.isHidden,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      isHidden: data.isHidden.present ? data.isHidden.value : this.isHidden,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('isSystem: $isSystem, ')
          ..write('isArchived: $isArchived, ')
          ..write('isHidden: $isHidden')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, type, icon, color, isSystem, isArchived, isHidden);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.isSystem == this.isSystem &&
          other.isArchived == this.isArchived &&
          other.isHidden == this.isHidden);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String> icon;
  final Value<int> color;
  final Value<bool> isSystem;
  final Value<bool> isArchived;
  final Value<bool> isHidden;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.isHidden = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String type,
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.isHidden = const Value.absent(),
  }) : name = Value(name),
       type = Value(type);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? icon,
    Expression<int>? color,
    Expression<bool>? isSystem,
    Expression<bool>? isArchived,
    Expression<bool>? isHidden,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (isSystem != null) 'is_system': isSystem,
      if (isArchived != null) 'is_archived': isArchived,
      if (isHidden != null) 'is_hidden': isHidden,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? type,
    Value<String>? icon,
    Value<int>? color,
    Value<bool>? isSystem,
    Value<bool>? isArchived,
    Value<bool>? isHidden,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isSystem: isSystem ?? this.isSystem,
      isArchived: isArchived ?? this.isArchived,
      isHidden: isHidden ?? this.isHidden,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (isHidden.present) {
      map['is_hidden'] = Variable<bool>(isHidden.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('isSystem: $isSystem, ')
          ..write('isArchived: $isArchived, ')
          ..write('isHidden: $isHidden')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('KZT'),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _transactionDateMeta = const VerificationMeta(
    'transactionDate',
  );
  @override
  late final GeneratedColumn<DateTime> transactionDate =
      GeneratedColumn<DateTime>(
        'transaction_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isExcludedFromStatisticsMeta =
      const VerificationMeta('isExcludedFromStatistics');
  @override
  late final GeneratedColumn<bool> isExcludedFromStatistics =
      GeneratedColumn<bool>(
        'is_excluded_from_statistics',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_excluded_from_statistics" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _isUnavoidableMeta = const VerificationMeta(
    'isUnavoidable',
  );
  @override
  late final GeneratedColumn<bool> isUnavoidable = GeneratedColumn<bool>(
    'is_unavoidable',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_unavoidable" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _linkedPaymentOccurrenceIdMeta =
      const VerificationMeta('linkedPaymentOccurrenceId');
  @override
  late final GeneratedColumn<int> linkedPaymentOccurrenceId =
      GeneratedColumn<int>(
        'linked_payment_occurrence_id',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _transferGroupIdMeta = const VerificationMeta(
    'transferGroupId',
  );
  @override
  late final GeneratedColumn<int> transferGroupId = GeneratedColumn<int>(
    'transfer_group_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountId,
    categoryId,
    type,
    amount,
    currency,
    description,
    transactionDate,
    createdAt,
    updatedAt,
    isExcludedFromStatistics,
    isUnavoidable,
    linkedPaymentOccurrenceId,
    transferGroupId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('transaction_date')) {
      context.handle(
        _transactionDateMeta,
        transactionDate.isAcceptableOrUnknown(
          data['transaction_date']!,
          _transactionDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_excluded_from_statistics')) {
      context.handle(
        _isExcludedFromStatisticsMeta,
        isExcludedFromStatistics.isAcceptableOrUnknown(
          data['is_excluded_from_statistics']!,
          _isExcludedFromStatisticsMeta,
        ),
      );
    }
    if (data.containsKey('is_unavoidable')) {
      context.handle(
        _isUnavoidableMeta,
        isUnavoidable.isAcceptableOrUnknown(
          data['is_unavoidable']!,
          _isUnavoidableMeta,
        ),
      );
    }
    if (data.containsKey('linked_payment_occurrence_id')) {
      context.handle(
        _linkedPaymentOccurrenceIdMeta,
        linkedPaymentOccurrenceId.isAcceptableOrUnknown(
          data['linked_payment_occurrence_id']!,
          _linkedPaymentOccurrenceIdMeta,
        ),
      );
    }
    if (data.containsKey('transfer_group_id')) {
      context.handle(
        _transferGroupIdMeta,
        transferGroupId.isAcceptableOrUnknown(
          data['transfer_group_id']!,
          _transferGroupIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      transactionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}transaction_date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isExcludedFromStatistics: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_excluded_from_statistics'],
      )!,
      isUnavoidable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_unavoidable'],
      )!,
      linkedPaymentOccurrenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}linked_payment_occurrence_id'],
      ),
      transferGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transfer_group_id'],
      ),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int id;
  final int accountId;
  final int? categoryId;
  final String type;
  final int amount;
  final String currency;
  final String description;
  final DateTime transactionDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isExcludedFromStatistics;
  final bool isUnavoidable;
  final int? linkedPaymentOccurrenceId;
  final int? transferGroupId;
  const Transaction({
    required this.id,
    required this.accountId,
    this.categoryId,
    required this.type,
    required this.amount,
    required this.currency,
    required this.description,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
    required this.isExcludedFromStatistics,
    required this.isUnavoidable,
    this.linkedPaymentOccurrenceId,
    this.transferGroupId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['account_id'] = Variable<int>(accountId);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    map['type'] = Variable<String>(type);
    map['amount'] = Variable<int>(amount);
    map['currency'] = Variable<String>(currency);
    map['description'] = Variable<String>(description);
    map['transaction_date'] = Variable<DateTime>(transactionDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_excluded_from_statistics'] = Variable<bool>(
      isExcludedFromStatistics,
    );
    map['is_unavoidable'] = Variable<bool>(isUnavoidable);
    if (!nullToAbsent || linkedPaymentOccurrenceId != null) {
      map['linked_payment_occurrence_id'] = Variable<int>(
        linkedPaymentOccurrenceId,
      );
    }
    if (!nullToAbsent || transferGroupId != null) {
      map['transfer_group_id'] = Variable<int>(transferGroupId);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      accountId: Value(accountId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      type: Value(type),
      amount: Value(amount),
      currency: Value(currency),
      description: Value(description),
      transactionDate: Value(transactionDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isExcludedFromStatistics: Value(isExcludedFromStatistics),
      isUnavoidable: Value(isUnavoidable),
      linkedPaymentOccurrenceId:
          linkedPaymentOccurrenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedPaymentOccurrenceId),
      transferGroupId: transferGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(transferGroupId),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      accountId: serializer.fromJson<int>(json['accountId']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      type: serializer.fromJson<String>(json['type']),
      amount: serializer.fromJson<int>(json['amount']),
      currency: serializer.fromJson<String>(json['currency']),
      description: serializer.fromJson<String>(json['description']),
      transactionDate: serializer.fromJson<DateTime>(json['transactionDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isExcludedFromStatistics: serializer.fromJson<bool>(
        json['isExcludedFromStatistics'],
      ),
      isUnavoidable: serializer.fromJson<bool>(json['isUnavoidable']),
      linkedPaymentOccurrenceId: serializer.fromJson<int?>(
        json['linkedPaymentOccurrenceId'],
      ),
      transferGroupId: serializer.fromJson<int?>(json['transferGroupId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'accountId': serializer.toJson<int>(accountId),
      'categoryId': serializer.toJson<int?>(categoryId),
      'type': serializer.toJson<String>(type),
      'amount': serializer.toJson<int>(amount),
      'currency': serializer.toJson<String>(currency),
      'description': serializer.toJson<String>(description),
      'transactionDate': serializer.toJson<DateTime>(transactionDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isExcludedFromStatistics': serializer.toJson<bool>(
        isExcludedFromStatistics,
      ),
      'isUnavoidable': serializer.toJson<bool>(isUnavoidable),
      'linkedPaymentOccurrenceId': serializer.toJson<int?>(
        linkedPaymentOccurrenceId,
      ),
      'transferGroupId': serializer.toJson<int?>(transferGroupId),
    };
  }

  Transaction copyWith({
    int? id,
    int? accountId,
    Value<int?> categoryId = const Value.absent(),
    String? type,
    int? amount,
    String? currency,
    String? description,
    DateTime? transactionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isExcludedFromStatistics,
    bool? isUnavoidable,
    Value<int?> linkedPaymentOccurrenceId = const Value.absent(),
    Value<int?> transferGroupId = const Value.absent(),
  }) => Transaction(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    currency: currency ?? this.currency,
    description: description ?? this.description,
    transactionDate: transactionDate ?? this.transactionDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isExcludedFromStatistics:
        isExcludedFromStatistics ?? this.isExcludedFromStatistics,
    isUnavoidable: isUnavoidable ?? this.isUnavoidable,
    linkedPaymentOccurrenceId: linkedPaymentOccurrenceId.present
        ? linkedPaymentOccurrenceId.value
        : this.linkedPaymentOccurrenceId,
    transferGroupId: transferGroupId.present
        ? transferGroupId.value
        : this.transferGroupId,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      currency: data.currency.present ? data.currency.value : this.currency,
      description: data.description.present
          ? data.description.value
          : this.description,
      transactionDate: data.transactionDate.present
          ? data.transactionDate.value
          : this.transactionDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isExcludedFromStatistics: data.isExcludedFromStatistics.present
          ? data.isExcludedFromStatistics.value
          : this.isExcludedFromStatistics,
      isUnavoidable: data.isUnavoidable.present
          ? data.isUnavoidable.value
          : this.isUnavoidable,
      linkedPaymentOccurrenceId: data.linkedPaymentOccurrenceId.present
          ? data.linkedPaymentOccurrenceId.value
          : this.linkedPaymentOccurrenceId,
      transferGroupId: data.transferGroupId.present
          ? data.transferGroupId.value
          : this.transferGroupId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('description: $description, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isExcludedFromStatistics: $isExcludedFromStatistics, ')
          ..write('isUnavoidable: $isUnavoidable, ')
          ..write('linkedPaymentOccurrenceId: $linkedPaymentOccurrenceId, ')
          ..write('transferGroupId: $transferGroupId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    categoryId,
    type,
    amount,
    currency,
    description,
    transactionDate,
    createdAt,
    updatedAt,
    isExcludedFromStatistics,
    isUnavoidable,
    linkedPaymentOccurrenceId,
    transferGroupId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.categoryId == this.categoryId &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.currency == this.currency &&
          other.description == this.description &&
          other.transactionDate == this.transactionDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isExcludedFromStatistics == this.isExcludedFromStatistics &&
          other.isUnavoidable == this.isUnavoidable &&
          other.linkedPaymentOccurrenceId == this.linkedPaymentOccurrenceId &&
          other.transferGroupId == this.transferGroupId);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<int> accountId;
  final Value<int?> categoryId;
  final Value<String> type;
  final Value<int> amount;
  final Value<String> currency;
  final Value<String> description;
  final Value<DateTime> transactionDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isExcludedFromStatistics;
  final Value<bool> isUnavoidable;
  final Value<int?> linkedPaymentOccurrenceId;
  final Value<int?> transferGroupId;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.currency = const Value.absent(),
    this.description = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isExcludedFromStatistics = const Value.absent(),
    this.isUnavoidable = const Value.absent(),
    this.linkedPaymentOccurrenceId = const Value.absent(),
    this.transferGroupId = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required int accountId,
    this.categoryId = const Value.absent(),
    required String type,
    required int amount,
    this.currency = const Value.absent(),
    this.description = const Value.absent(),
    required DateTime transactionDate,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isExcludedFromStatistics = const Value.absent(),
    this.isUnavoidable = const Value.absent(),
    this.linkedPaymentOccurrenceId = const Value.absent(),
    this.transferGroupId = const Value.absent(),
  }) : accountId = Value(accountId),
       type = Value(type),
       amount = Value(amount),
       transactionDate = Value(transactionDate);
  static Insertable<Transaction> custom({
    Expression<int>? id,
    Expression<int>? accountId,
    Expression<int>? categoryId,
    Expression<String>? type,
    Expression<int>? amount,
    Expression<String>? currency,
    Expression<String>? description,
    Expression<DateTime>? transactionDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isExcludedFromStatistics,
    Expression<bool>? isUnavoidable,
    Expression<int>? linkedPaymentOccurrenceId,
    Expression<int>? transferGroupId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (categoryId != null) 'category_id': categoryId,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (currency != null) 'currency': currency,
      if (description != null) 'description': description,
      if (transactionDate != null) 'transaction_date': transactionDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isExcludedFromStatistics != null)
        'is_excluded_from_statistics': isExcludedFromStatistics,
      if (isUnavoidable != null) 'is_unavoidable': isUnavoidable,
      if (linkedPaymentOccurrenceId != null)
        'linked_payment_occurrence_id': linkedPaymentOccurrenceId,
      if (transferGroupId != null) 'transfer_group_id': transferGroupId,
    });
  }

  TransactionsCompanion copyWith({
    Value<int>? id,
    Value<int>? accountId,
    Value<int?>? categoryId,
    Value<String>? type,
    Value<int>? amount,
    Value<String>? currency,
    Value<String>? description,
    Value<DateTime>? transactionDate,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isExcludedFromStatistics,
    Value<bool>? isUnavoidable,
    Value<int?>? linkedPaymentOccurrenceId,
    Value<int?>? transferGroupId,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isExcludedFromStatistics:
          isExcludedFromStatistics ?? this.isExcludedFromStatistics,
      isUnavoidable: isUnavoidable ?? this.isUnavoidable,
      linkedPaymentOccurrenceId:
          linkedPaymentOccurrenceId ?? this.linkedPaymentOccurrenceId,
      transferGroupId: transferGroupId ?? this.transferGroupId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (transactionDate.present) {
      map['transaction_date'] = Variable<DateTime>(transactionDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isExcludedFromStatistics.present) {
      map['is_excluded_from_statistics'] = Variable<bool>(
        isExcludedFromStatistics.value,
      );
    }
    if (isUnavoidable.present) {
      map['is_unavoidable'] = Variable<bool>(isUnavoidable.value);
    }
    if (linkedPaymentOccurrenceId.present) {
      map['linked_payment_occurrence_id'] = Variable<int>(
        linkedPaymentOccurrenceId.value,
      );
    }
    if (transferGroupId.present) {
      map['transfer_group_id'] = Variable<int>(transferGroupId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('description: $description, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isExcludedFromStatistics: $isExcludedFromStatistics, ')
          ..write('isUnavoidable: $isUnavoidable, ')
          ..write('linkedPaymentOccurrenceId: $linkedPaymentOccurrenceId, ')
          ..write('transferGroupId: $transferGroupId')
          ..write(')'))
        .toString();
  }
}

class $RecurringPaymentsTable extends RecurringPayments
    with TableInfo<$RecurringPaymentsTable, RecurringPayment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringPaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentDayMeta = const VerificationMeta(
    'paymentDay',
  );
  @override
  late final GeneratedColumn<int> paymentDay = GeneratedColumn<int>(
    'payment_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isAutoPayMeta = const VerificationMeta(
    'isAutoPay',
  );
  @override
  late final GeneratedColumn<bool> isAutoPay = GeneratedColumn<bool>(
    'is_auto_pay',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_auto_pay" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    amount,
    categoryId,
    accountId,
    frequency,
    paymentDay,
    startDate,
    endDate,
    isActive,
    isAutoPay,
    description,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringPayment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('payment_day')) {
      context.handle(
        _paymentDayMeta,
        paymentDay.isAcceptableOrUnknown(data['payment_day']!, _paymentDayMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('is_auto_pay')) {
      context.handle(
        _isAutoPayMeta,
        isAutoPay.isAcceptableOrUnknown(data['is_auto_pay']!, _isAutoPayMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringPayment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringPayment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      ),
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      )!,
      paymentDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payment_day'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      isAutoPay: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_auto_pay'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
    );
  }

  @override
  $RecurringPaymentsTable createAlias(String alias) {
    return $RecurringPaymentsTable(attachedDatabase, alias);
  }
}

class RecurringPayment extends DataClass
    implements Insertable<RecurringPayment> {
  final int id;
  final String name;
  final int amount;
  final int? categoryId;
  final int? accountId;
  final String frequency;
  final int? paymentDay;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final bool isAutoPay;
  final String description;
  const RecurringPayment({
    required this.id,
    required this.name,
    required this.amount,
    this.categoryId,
    this.accountId,
    required this.frequency,
    this.paymentDay,
    required this.startDate,
    this.endDate,
    required this.isActive,
    required this.isAutoPay,
    required this.description,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['amount'] = Variable<int>(amount);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<int>(accountId);
    }
    map['frequency'] = Variable<String>(frequency);
    if (!nullToAbsent || paymentDay != null) {
      map['payment_day'] = Variable<int>(paymentDay);
    }
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['is_auto_pay'] = Variable<bool>(isAutoPay);
    map['description'] = Variable<String>(description);
    return map;
  }

  RecurringPaymentsCompanion toCompanion(bool nullToAbsent) {
    return RecurringPaymentsCompanion(
      id: Value(id),
      name: Value(name),
      amount: Value(amount),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      frequency: Value(frequency),
      paymentDay: paymentDay == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentDay),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      isActive: Value(isActive),
      isAutoPay: Value(isAutoPay),
      description: Value(description),
    );
  }

  factory RecurringPayment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringPayment(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      amount: serializer.fromJson<int>(json['amount']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      accountId: serializer.fromJson<int?>(json['accountId']),
      frequency: serializer.fromJson<String>(json['frequency']),
      paymentDay: serializer.fromJson<int?>(json['paymentDay']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      isAutoPay: serializer.fromJson<bool>(json['isAutoPay']),
      description: serializer.fromJson<String>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'amount': serializer.toJson<int>(amount),
      'categoryId': serializer.toJson<int?>(categoryId),
      'accountId': serializer.toJson<int?>(accountId),
      'frequency': serializer.toJson<String>(frequency),
      'paymentDay': serializer.toJson<int?>(paymentDay),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'isActive': serializer.toJson<bool>(isActive),
      'isAutoPay': serializer.toJson<bool>(isAutoPay),
      'description': serializer.toJson<String>(description),
    };
  }

  RecurringPayment copyWith({
    int? id,
    String? name,
    int? amount,
    Value<int?> categoryId = const Value.absent(),
    Value<int?> accountId = const Value.absent(),
    String? frequency,
    Value<int?> paymentDay = const Value.absent(),
    DateTime? startDate,
    Value<DateTime?> endDate = const Value.absent(),
    bool? isActive,
    bool? isAutoPay,
    String? description,
  }) => RecurringPayment(
    id: id ?? this.id,
    name: name ?? this.name,
    amount: amount ?? this.amount,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    accountId: accountId.present ? accountId.value : this.accountId,
    frequency: frequency ?? this.frequency,
    paymentDay: paymentDay.present ? paymentDay.value : this.paymentDay,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    isActive: isActive ?? this.isActive,
    isAutoPay: isAutoPay ?? this.isAutoPay,
    description: description ?? this.description,
  );
  RecurringPayment copyWithCompanion(RecurringPaymentsCompanion data) {
    return RecurringPayment(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      amount: data.amount.present ? data.amount.value : this.amount,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      paymentDay: data.paymentDay.present
          ? data.paymentDay.value
          : this.paymentDay,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      isAutoPay: data.isAutoPay.present ? data.isAutoPay.value : this.isAutoPay,
      description: data.description.present
          ? data.description.value
          : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringPayment(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('accountId: $accountId, ')
          ..write('frequency: $frequency, ')
          ..write('paymentDay: $paymentDay, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('isActive: $isActive, ')
          ..write('isAutoPay: $isAutoPay, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    amount,
    categoryId,
    accountId,
    frequency,
    paymentDay,
    startDate,
    endDate,
    isActive,
    isAutoPay,
    description,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringPayment &&
          other.id == this.id &&
          other.name == this.name &&
          other.amount == this.amount &&
          other.categoryId == this.categoryId &&
          other.accountId == this.accountId &&
          other.frequency == this.frequency &&
          other.paymentDay == this.paymentDay &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.isActive == this.isActive &&
          other.isAutoPay == this.isAutoPay &&
          other.description == this.description);
}

class RecurringPaymentsCompanion extends UpdateCompanion<RecurringPayment> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> amount;
  final Value<int?> categoryId;
  final Value<int?> accountId;
  final Value<String> frequency;
  final Value<int?> paymentDay;
  final Value<DateTime> startDate;
  final Value<DateTime?> endDate;
  final Value<bool> isActive;
  final Value<bool> isAutoPay;
  final Value<String> description;
  const RecurringPaymentsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.amount = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.frequency = const Value.absent(),
    this.paymentDay = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isAutoPay = const Value.absent(),
    this.description = const Value.absent(),
  });
  RecurringPaymentsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int amount,
    this.categoryId = const Value.absent(),
    this.accountId = const Value.absent(),
    required String frequency,
    this.paymentDay = const Value.absent(),
    required DateTime startDate,
    this.endDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isAutoPay = const Value.absent(),
    this.description = const Value.absent(),
  }) : name = Value(name),
       amount = Value(amount),
       frequency = Value(frequency),
       startDate = Value(startDate);
  static Insertable<RecurringPayment> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? amount,
    Expression<int>? categoryId,
    Expression<int>? accountId,
    Expression<String>? frequency,
    Expression<int>? paymentDay,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<bool>? isActive,
    Expression<bool>? isAutoPay,
    Expression<String>? description,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (amount != null) 'amount': amount,
      if (categoryId != null) 'category_id': categoryId,
      if (accountId != null) 'account_id': accountId,
      if (frequency != null) 'frequency': frequency,
      if (paymentDay != null) 'payment_day': paymentDay,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (isActive != null) 'is_active': isActive,
      if (isAutoPay != null) 'is_auto_pay': isAutoPay,
      if (description != null) 'description': description,
    });
  }

  RecurringPaymentsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? amount,
    Value<int?>? categoryId,
    Value<int?>? accountId,
    Value<String>? frequency,
    Value<int?>? paymentDay,
    Value<DateTime>? startDate,
    Value<DateTime?>? endDate,
    Value<bool>? isActive,
    Value<bool>? isAutoPay,
    Value<String>? description,
  }) {
    return RecurringPaymentsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      frequency: frequency ?? this.frequency,
      paymentDay: paymentDay ?? this.paymentDay,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      isAutoPay: isAutoPay ?? this.isAutoPay,
      description: description ?? this.description,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (paymentDay.present) {
      map['payment_day'] = Variable<int>(paymentDay.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (isAutoPay.present) {
      map['is_auto_pay'] = Variable<bool>(isAutoPay.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringPaymentsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('accountId: $accountId, ')
          ..write('frequency: $frequency, ')
          ..write('paymentDay: $paymentDay, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('isActive: $isActive, ')
          ..write('isAutoPay: $isAutoPay, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }
}

class $PaymentOccurrencesTable extends PaymentOccurrences
    with TableInfo<$PaymentOccurrencesTable, PaymentOccurrence> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentOccurrencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _recurringPaymentIdMeta =
      const VerificationMeta('recurringPaymentId');
  @override
  late final GeneratedColumn<int> recurringPaymentId = GeneratedColumn<int>(
    'recurring_payment_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recurring_payments (id)',
    ),
  );
  static const VerificationMeta _expectedAmountMeta = const VerificationMeta(
    'expectedAmount',
  );
  @override
  late final GeneratedColumn<int> expectedAmount = GeneratedColumn<int>(
    'expected_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('UPCOMING'),
  );
  static const VerificationMeta _paidAmountMeta = const VerificationMeta(
    'paidAmount',
  );
  @override
  late final GeneratedColumn<int> paidAmount = GeneratedColumn<int>(
    'paid_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _linkedTransactionIdMeta =
      const VerificationMeta('linkedTransactionId');
  @override
  late final GeneratedColumn<int> linkedTransactionId = GeneratedColumn<int>(
    'linked_transaction_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recurringPaymentId,
    expectedAmount,
    dueDate,
    status,
    paidAmount,
    linkedTransactionId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payment_occurrences';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentOccurrence> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('recurring_payment_id')) {
      context.handle(
        _recurringPaymentIdMeta,
        recurringPaymentId.isAcceptableOrUnknown(
          data['recurring_payment_id']!,
          _recurringPaymentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recurringPaymentIdMeta);
    }
    if (data.containsKey('expected_amount')) {
      context.handle(
        _expectedAmountMeta,
        expectedAmount.isAcceptableOrUnknown(
          data['expected_amount']!,
          _expectedAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expectedAmountMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('paid_amount')) {
      context.handle(
        _paidAmountMeta,
        paidAmount.isAcceptableOrUnknown(data['paid_amount']!, _paidAmountMeta),
      );
    }
    if (data.containsKey('linked_transaction_id')) {
      context.handle(
        _linkedTransactionIdMeta,
        linkedTransactionId.isAcceptableOrUnknown(
          data['linked_transaction_id']!,
          _linkedTransactionIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PaymentOccurrence map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentOccurrence(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      recurringPaymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recurring_payment_id'],
      )!,
      expectedAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_amount'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      paidAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paid_amount'],
      )!,
      linkedTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}linked_transaction_id'],
      ),
    );
  }

  @override
  $PaymentOccurrencesTable createAlias(String alias) {
    return $PaymentOccurrencesTable(attachedDatabase, alias);
  }
}

class PaymentOccurrence extends DataClass
    implements Insertable<PaymentOccurrence> {
  final int id;
  final int recurringPaymentId;
  final int expectedAmount;
  final DateTime dueDate;
  final String status;
  final int paidAmount;
  final int? linkedTransactionId;
  const PaymentOccurrence({
    required this.id,
    required this.recurringPaymentId,
    required this.expectedAmount,
    required this.dueDate,
    required this.status,
    required this.paidAmount,
    this.linkedTransactionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['recurring_payment_id'] = Variable<int>(recurringPaymentId);
    map['expected_amount'] = Variable<int>(expectedAmount);
    map['due_date'] = Variable<DateTime>(dueDate);
    map['status'] = Variable<String>(status);
    map['paid_amount'] = Variable<int>(paidAmount);
    if (!nullToAbsent || linkedTransactionId != null) {
      map['linked_transaction_id'] = Variable<int>(linkedTransactionId);
    }
    return map;
  }

  PaymentOccurrencesCompanion toCompanion(bool nullToAbsent) {
    return PaymentOccurrencesCompanion(
      id: Value(id),
      recurringPaymentId: Value(recurringPaymentId),
      expectedAmount: Value(expectedAmount),
      dueDate: Value(dueDate),
      status: Value(status),
      paidAmount: Value(paidAmount),
      linkedTransactionId: linkedTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedTransactionId),
    );
  }

  factory PaymentOccurrence.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentOccurrence(
      id: serializer.fromJson<int>(json['id']),
      recurringPaymentId: serializer.fromJson<int>(json['recurringPaymentId']),
      expectedAmount: serializer.fromJson<int>(json['expectedAmount']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      status: serializer.fromJson<String>(json['status']),
      paidAmount: serializer.fromJson<int>(json['paidAmount']),
      linkedTransactionId: serializer.fromJson<int?>(
        json['linkedTransactionId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recurringPaymentId': serializer.toJson<int>(recurringPaymentId),
      'expectedAmount': serializer.toJson<int>(expectedAmount),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'status': serializer.toJson<String>(status),
      'paidAmount': serializer.toJson<int>(paidAmount),
      'linkedTransactionId': serializer.toJson<int?>(linkedTransactionId),
    };
  }

  PaymentOccurrence copyWith({
    int? id,
    int? recurringPaymentId,
    int? expectedAmount,
    DateTime? dueDate,
    String? status,
    int? paidAmount,
    Value<int?> linkedTransactionId = const Value.absent(),
  }) => PaymentOccurrence(
    id: id ?? this.id,
    recurringPaymentId: recurringPaymentId ?? this.recurringPaymentId,
    expectedAmount: expectedAmount ?? this.expectedAmount,
    dueDate: dueDate ?? this.dueDate,
    status: status ?? this.status,
    paidAmount: paidAmount ?? this.paidAmount,
    linkedTransactionId: linkedTransactionId.present
        ? linkedTransactionId.value
        : this.linkedTransactionId,
  );
  PaymentOccurrence copyWithCompanion(PaymentOccurrencesCompanion data) {
    return PaymentOccurrence(
      id: data.id.present ? data.id.value : this.id,
      recurringPaymentId: data.recurringPaymentId.present
          ? data.recurringPaymentId.value
          : this.recurringPaymentId,
      expectedAmount: data.expectedAmount.present
          ? data.expectedAmount.value
          : this.expectedAmount,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      status: data.status.present ? data.status.value : this.status,
      paidAmount: data.paidAmount.present
          ? data.paidAmount.value
          : this.paidAmount,
      linkedTransactionId: data.linkedTransactionId.present
          ? data.linkedTransactionId.value
          : this.linkedTransactionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentOccurrence(')
          ..write('id: $id, ')
          ..write('recurringPaymentId: $recurringPaymentId, ')
          ..write('expectedAmount: $expectedAmount, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('linkedTransactionId: $linkedTransactionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    recurringPaymentId,
    expectedAmount,
    dueDate,
    status,
    paidAmount,
    linkedTransactionId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentOccurrence &&
          other.id == this.id &&
          other.recurringPaymentId == this.recurringPaymentId &&
          other.expectedAmount == this.expectedAmount &&
          other.dueDate == this.dueDate &&
          other.status == this.status &&
          other.paidAmount == this.paidAmount &&
          other.linkedTransactionId == this.linkedTransactionId);
}

class PaymentOccurrencesCompanion extends UpdateCompanion<PaymentOccurrence> {
  final Value<int> id;
  final Value<int> recurringPaymentId;
  final Value<int> expectedAmount;
  final Value<DateTime> dueDate;
  final Value<String> status;
  final Value<int> paidAmount;
  final Value<int?> linkedTransactionId;
  const PaymentOccurrencesCompanion({
    this.id = const Value.absent(),
    this.recurringPaymentId = const Value.absent(),
    this.expectedAmount = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.status = const Value.absent(),
    this.paidAmount = const Value.absent(),
    this.linkedTransactionId = const Value.absent(),
  });
  PaymentOccurrencesCompanion.insert({
    this.id = const Value.absent(),
    required int recurringPaymentId,
    required int expectedAmount,
    required DateTime dueDate,
    this.status = const Value.absent(),
    this.paidAmount = const Value.absent(),
    this.linkedTransactionId = const Value.absent(),
  }) : recurringPaymentId = Value(recurringPaymentId),
       expectedAmount = Value(expectedAmount),
       dueDate = Value(dueDate);
  static Insertable<PaymentOccurrence> custom({
    Expression<int>? id,
    Expression<int>? recurringPaymentId,
    Expression<int>? expectedAmount,
    Expression<DateTime>? dueDate,
    Expression<String>? status,
    Expression<int>? paidAmount,
    Expression<int>? linkedTransactionId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recurringPaymentId != null)
        'recurring_payment_id': recurringPaymentId,
      if (expectedAmount != null) 'expected_amount': expectedAmount,
      if (dueDate != null) 'due_date': dueDate,
      if (status != null) 'status': status,
      if (paidAmount != null) 'paid_amount': paidAmount,
      if (linkedTransactionId != null)
        'linked_transaction_id': linkedTransactionId,
    });
  }

  PaymentOccurrencesCompanion copyWith({
    Value<int>? id,
    Value<int>? recurringPaymentId,
    Value<int>? expectedAmount,
    Value<DateTime>? dueDate,
    Value<String>? status,
    Value<int>? paidAmount,
    Value<int?>? linkedTransactionId,
  }) {
    return PaymentOccurrencesCompanion(
      id: id ?? this.id,
      recurringPaymentId: recurringPaymentId ?? this.recurringPaymentId,
      expectedAmount: expectedAmount ?? this.expectedAmount,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      paidAmount: paidAmount ?? this.paidAmount,
      linkedTransactionId: linkedTransactionId ?? this.linkedTransactionId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recurringPaymentId.present) {
      map['recurring_payment_id'] = Variable<int>(recurringPaymentId.value);
    }
    if (expectedAmount.present) {
      map['expected_amount'] = Variable<int>(expectedAmount.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (paidAmount.present) {
      map['paid_amount'] = Variable<int>(paidAmount.value);
    }
    if (linkedTransactionId.present) {
      map['linked_transaction_id'] = Variable<int>(linkedTransactionId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentOccurrencesCompanion(')
          ..write('id: $id, ')
          ..write('recurringPaymentId: $recurringPaymentId, ')
          ..write('expectedAmount: $expectedAmount, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('linkedTransactionId: $linkedTransactionId')
          ..write(')'))
        .toString();
  }
}

class $IncomeSchedulesTable extends IncomeSchedules
    with TableInfo<$IncomeSchedulesTable, IncomeSchedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IncomeSchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expectedAmountMeta = const VerificationMeta(
    'expectedAmount',
  );
  @override
  late final GeneratedColumn<int> expectedAmount = GeneratedColumn<int>(
    'expected_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expectedDateMeta = const VerificationMeta(
    'expectedDate',
  );
  @override
  late final GeneratedColumn<DateTime> expectedDate = GeneratedColumn<DateTime>(
    'expected_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _linkedTransactionIdMeta =
      const VerificationMeta('linkedTransactionId');
  @override
  late final GeneratedColumn<int> linkedTransactionId = GeneratedColumn<int>(
    'linked_transaction_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    expectedAmount,
    frequency,
    expectedDate,
    isActive,
    linkedTransactionId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'income_schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<IncomeSchedule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('expected_amount')) {
      context.handle(
        _expectedAmountMeta,
        expectedAmount.isAcceptableOrUnknown(
          data['expected_amount']!,
          _expectedAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expectedAmountMeta);
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('expected_date')) {
      context.handle(
        _expectedDateMeta,
        expectedDate.isAcceptableOrUnknown(
          data['expected_date']!,
          _expectedDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expectedDateMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('linked_transaction_id')) {
      context.handle(
        _linkedTransactionIdMeta,
        linkedTransactionId.isAcceptableOrUnknown(
          data['linked_transaction_id']!,
          _linkedTransactionIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IncomeSchedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IncomeSchedule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      expectedAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_amount'],
      )!,
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      )!,
      expectedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expected_date'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      linkedTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}linked_transaction_id'],
      ),
    );
  }

  @override
  $IncomeSchedulesTable createAlias(String alias) {
    return $IncomeSchedulesTable(attachedDatabase, alias);
  }
}

class IncomeSchedule extends DataClass implements Insertable<IncomeSchedule> {
  final int id;
  final String name;
  final int expectedAmount;
  final String frequency;
  final DateTime expectedDate;
  final bool isActive;
  final int? linkedTransactionId;
  const IncomeSchedule({
    required this.id,
    required this.name,
    required this.expectedAmount,
    required this.frequency,
    required this.expectedDate,
    required this.isActive,
    this.linkedTransactionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['expected_amount'] = Variable<int>(expectedAmount);
    map['frequency'] = Variable<String>(frequency);
    map['expected_date'] = Variable<DateTime>(expectedDate);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || linkedTransactionId != null) {
      map['linked_transaction_id'] = Variable<int>(linkedTransactionId);
    }
    return map;
  }

  IncomeSchedulesCompanion toCompanion(bool nullToAbsent) {
    return IncomeSchedulesCompanion(
      id: Value(id),
      name: Value(name),
      expectedAmount: Value(expectedAmount),
      frequency: Value(frequency),
      expectedDate: Value(expectedDate),
      isActive: Value(isActive),
      linkedTransactionId: linkedTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedTransactionId),
    );
  }

  factory IncomeSchedule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IncomeSchedule(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      expectedAmount: serializer.fromJson<int>(json['expectedAmount']),
      frequency: serializer.fromJson<String>(json['frequency']),
      expectedDate: serializer.fromJson<DateTime>(json['expectedDate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      linkedTransactionId: serializer.fromJson<int?>(
        json['linkedTransactionId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'expectedAmount': serializer.toJson<int>(expectedAmount),
      'frequency': serializer.toJson<String>(frequency),
      'expectedDate': serializer.toJson<DateTime>(expectedDate),
      'isActive': serializer.toJson<bool>(isActive),
      'linkedTransactionId': serializer.toJson<int?>(linkedTransactionId),
    };
  }

  IncomeSchedule copyWith({
    int? id,
    String? name,
    int? expectedAmount,
    String? frequency,
    DateTime? expectedDate,
    bool? isActive,
    Value<int?> linkedTransactionId = const Value.absent(),
  }) => IncomeSchedule(
    id: id ?? this.id,
    name: name ?? this.name,
    expectedAmount: expectedAmount ?? this.expectedAmount,
    frequency: frequency ?? this.frequency,
    expectedDate: expectedDate ?? this.expectedDate,
    isActive: isActive ?? this.isActive,
    linkedTransactionId: linkedTransactionId.present
        ? linkedTransactionId.value
        : this.linkedTransactionId,
  );
  IncomeSchedule copyWithCompanion(IncomeSchedulesCompanion data) {
    return IncomeSchedule(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      expectedAmount: data.expectedAmount.present
          ? data.expectedAmount.value
          : this.expectedAmount,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      expectedDate: data.expectedDate.present
          ? data.expectedDate.value
          : this.expectedDate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      linkedTransactionId: data.linkedTransactionId.present
          ? data.linkedTransactionId.value
          : this.linkedTransactionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IncomeSchedule(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('expectedAmount: $expectedAmount, ')
          ..write('frequency: $frequency, ')
          ..write('expectedDate: $expectedDate, ')
          ..write('isActive: $isActive, ')
          ..write('linkedTransactionId: $linkedTransactionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    expectedAmount,
    frequency,
    expectedDate,
    isActive,
    linkedTransactionId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IncomeSchedule &&
          other.id == this.id &&
          other.name == this.name &&
          other.expectedAmount == this.expectedAmount &&
          other.frequency == this.frequency &&
          other.expectedDate == this.expectedDate &&
          other.isActive == this.isActive &&
          other.linkedTransactionId == this.linkedTransactionId);
}

class IncomeSchedulesCompanion extends UpdateCompanion<IncomeSchedule> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> expectedAmount;
  final Value<String> frequency;
  final Value<DateTime> expectedDate;
  final Value<bool> isActive;
  final Value<int?> linkedTransactionId;
  const IncomeSchedulesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.expectedAmount = const Value.absent(),
    this.frequency = const Value.absent(),
    this.expectedDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.linkedTransactionId = const Value.absent(),
  });
  IncomeSchedulesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int expectedAmount,
    required String frequency,
    required DateTime expectedDate,
    this.isActive = const Value.absent(),
    this.linkedTransactionId = const Value.absent(),
  }) : name = Value(name),
       expectedAmount = Value(expectedAmount),
       frequency = Value(frequency),
       expectedDate = Value(expectedDate);
  static Insertable<IncomeSchedule> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? expectedAmount,
    Expression<String>? frequency,
    Expression<DateTime>? expectedDate,
    Expression<bool>? isActive,
    Expression<int>? linkedTransactionId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (expectedAmount != null) 'expected_amount': expectedAmount,
      if (frequency != null) 'frequency': frequency,
      if (expectedDate != null) 'expected_date': expectedDate,
      if (isActive != null) 'is_active': isActive,
      if (linkedTransactionId != null)
        'linked_transaction_id': linkedTransactionId,
    });
  }

  IncomeSchedulesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? expectedAmount,
    Value<String>? frequency,
    Value<DateTime>? expectedDate,
    Value<bool>? isActive,
    Value<int?>? linkedTransactionId,
  }) {
    return IncomeSchedulesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      expectedAmount: expectedAmount ?? this.expectedAmount,
      frequency: frequency ?? this.frequency,
      expectedDate: expectedDate ?? this.expectedDate,
      isActive: isActive ?? this.isActive,
      linkedTransactionId: linkedTransactionId ?? this.linkedTransactionId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (expectedAmount.present) {
      map['expected_amount'] = Variable<int>(expectedAmount.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (expectedDate.present) {
      map['expected_date'] = Variable<DateTime>(expectedDate.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (linkedTransactionId.present) {
      map['linked_transaction_id'] = Variable<int>(linkedTransactionId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IncomeSchedulesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('expectedAmount: $expectedAmount, ')
          ..write('frequency: $frequency, ')
          ..write('expectedDate: $expectedDate, ')
          ..write('isActive: $isActive, ')
          ..write('linkedTransactionId: $linkedTransactionId')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BackupImportIdentitiesTable extends BackupImportIdentities
    with TableInfo<$BackupImportIdentitiesTable, BackupImportIdentity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BackupImportIdentitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceDatabaseIdMeta = const VerificationMeta(
    'sourceDatabaseId',
  );
  @override
  late final GeneratedColumn<String> sourceDatabaseId = GeneratedColumn<String>(
    'source_database_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceTableMeta = const VerificationMeta(
    'sourceTable',
  );
  @override
  late final GeneratedColumn<String> sourceTable = GeneratedColumn<String>(
    'source_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<int> sourceId = GeneratedColumn<int>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetIdMeta = const VerificationMeta(
    'targetId',
  );
  @override
  late final GeneratedColumn<int> targetId = GeneratedColumn<int>(
    'target_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sourceDatabaseId,
    sourceTable,
    sourceId,
    targetId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'backup_import_identities';
  @override
  VerificationContext validateIntegrity(
    Insertable<BackupImportIdentity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_database_id')) {
      context.handle(
        _sourceDatabaseIdMeta,
        sourceDatabaseId.isAcceptableOrUnknown(
          data['source_database_id']!,
          _sourceDatabaseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceDatabaseIdMeta);
    }
    if (data.containsKey('source_table')) {
      context.handle(
        _sourceTableMeta,
        sourceTable.isAcceptableOrUnknown(
          data['source_table']!,
          _sourceTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceTableMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(
        _targetIdMeta,
        targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    sourceDatabaseId,
    sourceTable,
    sourceId,
  };
  @override
  BackupImportIdentity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BackupImportIdentity(
      sourceDatabaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_database_id'],
      )!,
      sourceTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_table'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_id'],
      )!,
      targetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_id'],
      )!,
    );
  }

  @override
  $BackupImportIdentitiesTable createAlias(String alias) {
    return $BackupImportIdentitiesTable(attachedDatabase, alias);
  }
}

class BackupImportIdentity extends DataClass
    implements Insertable<BackupImportIdentity> {
  final String sourceDatabaseId;
  final String sourceTable;
  final int sourceId;
  final int targetId;
  const BackupImportIdentity({
    required this.sourceDatabaseId,
    required this.sourceTable,
    required this.sourceId,
    required this.targetId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_database_id'] = Variable<String>(sourceDatabaseId);
    map['source_table'] = Variable<String>(sourceTable);
    map['source_id'] = Variable<int>(sourceId);
    map['target_id'] = Variable<int>(targetId);
    return map;
  }

  BackupImportIdentitiesCompanion toCompanion(bool nullToAbsent) {
    return BackupImportIdentitiesCompanion(
      sourceDatabaseId: Value(sourceDatabaseId),
      sourceTable: Value(sourceTable),
      sourceId: Value(sourceId),
      targetId: Value(targetId),
    );
  }

  factory BackupImportIdentity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BackupImportIdentity(
      sourceDatabaseId: serializer.fromJson<String>(json['sourceDatabaseId']),
      sourceTable: serializer.fromJson<String>(json['sourceTable']),
      sourceId: serializer.fromJson<int>(json['sourceId']),
      targetId: serializer.fromJson<int>(json['targetId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceDatabaseId': serializer.toJson<String>(sourceDatabaseId),
      'sourceTable': serializer.toJson<String>(sourceTable),
      'sourceId': serializer.toJson<int>(sourceId),
      'targetId': serializer.toJson<int>(targetId),
    };
  }

  BackupImportIdentity copyWith({
    String? sourceDatabaseId,
    String? sourceTable,
    int? sourceId,
    int? targetId,
  }) => BackupImportIdentity(
    sourceDatabaseId: sourceDatabaseId ?? this.sourceDatabaseId,
    sourceTable: sourceTable ?? this.sourceTable,
    sourceId: sourceId ?? this.sourceId,
    targetId: targetId ?? this.targetId,
  );
  BackupImportIdentity copyWithCompanion(BackupImportIdentitiesCompanion data) {
    return BackupImportIdentity(
      sourceDatabaseId: data.sourceDatabaseId.present
          ? data.sourceDatabaseId.value
          : this.sourceDatabaseId,
      sourceTable: data.sourceTable.present
          ? data.sourceTable.value
          : this.sourceTable,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BackupImportIdentity(')
          ..write('sourceDatabaseId: $sourceDatabaseId, ')
          ..write('sourceTable: $sourceTable, ')
          ..write('sourceId: $sourceId, ')
          ..write('targetId: $targetId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(sourceDatabaseId, sourceTable, sourceId, targetId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BackupImportIdentity &&
          other.sourceDatabaseId == this.sourceDatabaseId &&
          other.sourceTable == this.sourceTable &&
          other.sourceId == this.sourceId &&
          other.targetId == this.targetId);
}

class BackupImportIdentitiesCompanion
    extends UpdateCompanion<BackupImportIdentity> {
  final Value<String> sourceDatabaseId;
  final Value<String> sourceTable;
  final Value<int> sourceId;
  final Value<int> targetId;
  final Value<int> rowid;
  const BackupImportIdentitiesCompanion({
    this.sourceDatabaseId = const Value.absent(),
    this.sourceTable = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.targetId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BackupImportIdentitiesCompanion.insert({
    required String sourceDatabaseId,
    required String sourceTable,
    required int sourceId,
    required int targetId,
    this.rowid = const Value.absent(),
  }) : sourceDatabaseId = Value(sourceDatabaseId),
       sourceTable = Value(sourceTable),
       sourceId = Value(sourceId),
       targetId = Value(targetId);
  static Insertable<BackupImportIdentity> custom({
    Expression<String>? sourceDatabaseId,
    Expression<String>? sourceTable,
    Expression<int>? sourceId,
    Expression<int>? targetId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceDatabaseId != null) 'source_database_id': sourceDatabaseId,
      if (sourceTable != null) 'source_table': sourceTable,
      if (sourceId != null) 'source_id': sourceId,
      if (targetId != null) 'target_id': targetId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BackupImportIdentitiesCompanion copyWith({
    Value<String>? sourceDatabaseId,
    Value<String>? sourceTable,
    Value<int>? sourceId,
    Value<int>? targetId,
    Value<int>? rowid,
  }) {
    return BackupImportIdentitiesCompanion(
      sourceDatabaseId: sourceDatabaseId ?? this.sourceDatabaseId,
      sourceTable: sourceTable ?? this.sourceTable,
      sourceId: sourceId ?? this.sourceId,
      targetId: targetId ?? this.targetId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceDatabaseId.present) {
      map['source_database_id'] = Variable<String>(sourceDatabaseId.value);
    }
    if (sourceTable.present) {
      map['source_table'] = Variable<String>(sourceTable.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<int>(sourceId.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<int>(targetId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BackupImportIdentitiesCompanion(')
          ..write('sourceDatabaseId: $sourceDatabaseId, ')
          ..write('sourceTable: $sourceTable, ')
          ..write('sourceId: $sourceId, ')
          ..write('targetId: $targetId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DatabaseMetadataTable extends DatabaseMetadata
    with TableInfo<$DatabaseMetadataTable, DatabaseMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DatabaseMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _databaseIdMeta = const VerificationMeta(
    'databaseId',
  );
  @override
  late final GeneratedColumn<String> databaseId = GeneratedColumn<String>(
    'database_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastChangedAtMeta = const VerificationMeta(
    'lastChangedAt',
  );
  @override
  late final GeneratedColumn<int> lastChangedAt = GeneratedColumn<int>(
    'last_changed_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    databaseId,
    revision,
    lastChangedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'database_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<DatabaseMetadataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('database_id')) {
      context.handle(
        _databaseIdMeta,
        databaseId.isAcceptableOrUnknown(data['database_id']!, _databaseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_databaseIdMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    if (data.containsKey('last_changed_at')) {
      context.handle(
        _lastChangedAtMeta,
        lastChangedAt.isAcceptableOrUnknown(
          data['last_changed_at']!,
          _lastChangedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastChangedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DatabaseMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DatabaseMetadataData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      databaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}database_id'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      lastChangedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_changed_at'],
      )!,
    );
  }

  @override
  $DatabaseMetadataTable createAlias(String alias) {
    return $DatabaseMetadataTable(attachedDatabase, alias);
  }
}

class DatabaseMetadataData extends DataClass
    implements Insertable<DatabaseMetadataData> {
  final int id;
  final String databaseId;
  final int revision;
  final int lastChangedAt;
  const DatabaseMetadataData({
    required this.id,
    required this.databaseId,
    required this.revision,
    required this.lastChangedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['database_id'] = Variable<String>(databaseId);
    map['revision'] = Variable<int>(revision);
    map['last_changed_at'] = Variable<int>(lastChangedAt);
    return map;
  }

  DatabaseMetadataCompanion toCompanion(bool nullToAbsent) {
    return DatabaseMetadataCompanion(
      id: Value(id),
      databaseId: Value(databaseId),
      revision: Value(revision),
      lastChangedAt: Value(lastChangedAt),
    );
  }

  factory DatabaseMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DatabaseMetadataData(
      id: serializer.fromJson<int>(json['id']),
      databaseId: serializer.fromJson<String>(json['databaseId']),
      revision: serializer.fromJson<int>(json['revision']),
      lastChangedAt: serializer.fromJson<int>(json['lastChangedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'databaseId': serializer.toJson<String>(databaseId),
      'revision': serializer.toJson<int>(revision),
      'lastChangedAt': serializer.toJson<int>(lastChangedAt),
    };
  }

  DatabaseMetadataData copyWith({
    int? id,
    String? databaseId,
    int? revision,
    int? lastChangedAt,
  }) => DatabaseMetadataData(
    id: id ?? this.id,
    databaseId: databaseId ?? this.databaseId,
    revision: revision ?? this.revision,
    lastChangedAt: lastChangedAt ?? this.lastChangedAt,
  );
  DatabaseMetadataData copyWithCompanion(DatabaseMetadataCompanion data) {
    return DatabaseMetadataData(
      id: data.id.present ? data.id.value : this.id,
      databaseId: data.databaseId.present
          ? data.databaseId.value
          : this.databaseId,
      revision: data.revision.present ? data.revision.value : this.revision,
      lastChangedAt: data.lastChangedAt.present
          ? data.lastChangedAt.value
          : this.lastChangedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DatabaseMetadataData(')
          ..write('id: $id, ')
          ..write('databaseId: $databaseId, ')
          ..write('revision: $revision, ')
          ..write('lastChangedAt: $lastChangedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, databaseId, revision, lastChangedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DatabaseMetadataData &&
          other.id == this.id &&
          other.databaseId == this.databaseId &&
          other.revision == this.revision &&
          other.lastChangedAt == this.lastChangedAt);
}

class DatabaseMetadataCompanion extends UpdateCompanion<DatabaseMetadataData> {
  final Value<int> id;
  final Value<String> databaseId;
  final Value<int> revision;
  final Value<int> lastChangedAt;
  const DatabaseMetadataCompanion({
    this.id = const Value.absent(),
    this.databaseId = const Value.absent(),
    this.revision = const Value.absent(),
    this.lastChangedAt = const Value.absent(),
  });
  DatabaseMetadataCompanion.insert({
    this.id = const Value.absent(),
    required String databaseId,
    required int revision,
    required int lastChangedAt,
  }) : databaseId = Value(databaseId),
       revision = Value(revision),
       lastChangedAt = Value(lastChangedAt);
  static Insertable<DatabaseMetadataData> custom({
    Expression<int>? id,
    Expression<String>? databaseId,
    Expression<int>? revision,
    Expression<int>? lastChangedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (databaseId != null) 'database_id': databaseId,
      if (revision != null) 'revision': revision,
      if (lastChangedAt != null) 'last_changed_at': lastChangedAt,
    });
  }

  DatabaseMetadataCompanion copyWith({
    Value<int>? id,
    Value<String>? databaseId,
    Value<int>? revision,
    Value<int>? lastChangedAt,
  }) {
    return DatabaseMetadataCompanion(
      id: id ?? this.id,
      databaseId: databaseId ?? this.databaseId,
      revision: revision ?? this.revision,
      lastChangedAt: lastChangedAt ?? this.lastChangedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (databaseId.present) {
      map['database_id'] = Variable<String>(databaseId.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (lastChangedAt.present) {
      map['last_changed_at'] = Variable<int>(lastChangedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DatabaseMetadataCompanion(')
          ..write('id: $id, ')
          ..write('databaseId: $databaseId, ')
          ..write('revision: $revision, ')
          ..write('lastChangedAt: $lastChangedAt')
          ..write(')'))
        .toString();
  }
}

class $DatabaseHistoryChangesTable extends DatabaseHistoryChanges
    with TableInfo<$DatabaseHistoryChangesTable, DatabaseHistoryChange> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DatabaseHistoryChangesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entityTableMeta = const VerificationMeta(
    'entityTable',
  );
  @override
  late final GeneratedColumn<String> entityTable = GeneratedColumn<String>(
    'entity_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<String> rowId = GeneratedColumn<String>(
    'row_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<int> recordedAt = GeneratedColumn<int>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _beforeJsonMeta = const VerificationMeta(
    'beforeJson',
  );
  @override
  late final GeneratedColumn<String> beforeJson = GeneratedColumn<String>(
    'before_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _afterJsonMeta = const VerificationMeta(
    'afterJson',
  );
  @override
  late final GeneratedColumn<String> afterJson = GeneratedColumn<String>(
    'after_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityTable,
    rowId,
    recordedAt,
    operation,
    beforeJson,
    afterJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'database_history_changes';
  @override
  VerificationContext validateIntegrity(
    Insertable<DatabaseHistoryChange> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_table')) {
      context.handle(
        _entityTableMeta,
        entityTable.isAcceptableOrUnknown(
          data['entity_table']!,
          _entityTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entityTableMeta);
    }
    if (data.containsKey('row_id')) {
      context.handle(
        _rowIdMeta,
        rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rowIdMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('before_json')) {
      context.handle(
        _beforeJsonMeta,
        beforeJson.isAcceptableOrUnknown(data['before_json']!, _beforeJsonMeta),
      );
    }
    if (data.containsKey('after_json')) {
      context.handle(
        _afterJsonMeta,
        afterJson.isAcceptableOrUnknown(data['after_json']!, _afterJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DatabaseHistoryChange map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DatabaseHistoryChange(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entityTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_table'],
      )!,
      rowId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}row_id'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recorded_at'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      beforeJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}before_json'],
      ),
      afterJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}after_json'],
      ),
    );
  }

  @override
  $DatabaseHistoryChangesTable createAlias(String alias) {
    return $DatabaseHistoryChangesTable(attachedDatabase, alias);
  }
}

class DatabaseHistoryChange extends DataClass
    implements Insertable<DatabaseHistoryChange> {
  final int id;
  final String entityTable;
  final String rowId;
  final int recordedAt;
  final String operation;
  final String? beforeJson;
  final String? afterJson;
  const DatabaseHistoryChange({
    required this.id,
    required this.entityTable,
    required this.rowId,
    required this.recordedAt,
    required this.operation,
    this.beforeJson,
    this.afterJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_table'] = Variable<String>(entityTable);
    map['row_id'] = Variable<String>(rowId);
    map['recorded_at'] = Variable<int>(recordedAt);
    map['operation'] = Variable<String>(operation);
    if (!nullToAbsent || beforeJson != null) {
      map['before_json'] = Variable<String>(beforeJson);
    }
    if (!nullToAbsent || afterJson != null) {
      map['after_json'] = Variable<String>(afterJson);
    }
    return map;
  }

  DatabaseHistoryChangesCompanion toCompanion(bool nullToAbsent) {
    return DatabaseHistoryChangesCompanion(
      id: Value(id),
      entityTable: Value(entityTable),
      rowId: Value(rowId),
      recordedAt: Value(recordedAt),
      operation: Value(operation),
      beforeJson: beforeJson == null && nullToAbsent
          ? const Value.absent()
          : Value(beforeJson),
      afterJson: afterJson == null && nullToAbsent
          ? const Value.absent()
          : Value(afterJson),
    );
  }

  factory DatabaseHistoryChange.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DatabaseHistoryChange(
      id: serializer.fromJson<int>(json['id']),
      entityTable: serializer.fromJson<String>(json['entityTable']),
      rowId: serializer.fromJson<String>(json['rowId']),
      recordedAt: serializer.fromJson<int>(json['recordedAt']),
      operation: serializer.fromJson<String>(json['operation']),
      beforeJson: serializer.fromJson<String?>(json['beforeJson']),
      afterJson: serializer.fromJson<String?>(json['afterJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityTable': serializer.toJson<String>(entityTable),
      'rowId': serializer.toJson<String>(rowId),
      'recordedAt': serializer.toJson<int>(recordedAt),
      'operation': serializer.toJson<String>(operation),
      'beforeJson': serializer.toJson<String?>(beforeJson),
      'afterJson': serializer.toJson<String?>(afterJson),
    };
  }

  DatabaseHistoryChange copyWith({
    int? id,
    String? entityTable,
    String? rowId,
    int? recordedAt,
    String? operation,
    Value<String?> beforeJson = const Value.absent(),
    Value<String?> afterJson = const Value.absent(),
  }) => DatabaseHistoryChange(
    id: id ?? this.id,
    entityTable: entityTable ?? this.entityTable,
    rowId: rowId ?? this.rowId,
    recordedAt: recordedAt ?? this.recordedAt,
    operation: operation ?? this.operation,
    beforeJson: beforeJson.present ? beforeJson.value : this.beforeJson,
    afterJson: afterJson.present ? afterJson.value : this.afterJson,
  );
  DatabaseHistoryChange copyWithCompanion(
    DatabaseHistoryChangesCompanion data,
  ) {
    return DatabaseHistoryChange(
      id: data.id.present ? data.id.value : this.id,
      entityTable: data.entityTable.present
          ? data.entityTable.value
          : this.entityTable,
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      operation: data.operation.present ? data.operation.value : this.operation,
      beforeJson: data.beforeJson.present
          ? data.beforeJson.value
          : this.beforeJson,
      afterJson: data.afterJson.present ? data.afterJson.value : this.afterJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DatabaseHistoryChange(')
          ..write('id: $id, ')
          ..write('entityTable: $entityTable, ')
          ..write('rowId: $rowId, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('operation: $operation, ')
          ..write('beforeJson: $beforeJson, ')
          ..write('afterJson: $afterJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityTable,
    rowId,
    recordedAt,
    operation,
    beforeJson,
    afterJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DatabaseHistoryChange &&
          other.id == this.id &&
          other.entityTable == this.entityTable &&
          other.rowId == this.rowId &&
          other.recordedAt == this.recordedAt &&
          other.operation == this.operation &&
          other.beforeJson == this.beforeJson &&
          other.afterJson == this.afterJson);
}

class DatabaseHistoryChangesCompanion
    extends UpdateCompanion<DatabaseHistoryChange> {
  final Value<int> id;
  final Value<String> entityTable;
  final Value<String> rowId;
  final Value<int> recordedAt;
  final Value<String> operation;
  final Value<String?> beforeJson;
  final Value<String?> afterJson;
  const DatabaseHistoryChangesCompanion({
    this.id = const Value.absent(),
    this.entityTable = const Value.absent(),
    this.rowId = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.operation = const Value.absent(),
    this.beforeJson = const Value.absent(),
    this.afterJson = const Value.absent(),
  });
  DatabaseHistoryChangesCompanion.insert({
    this.id = const Value.absent(),
    required String entityTable,
    required String rowId,
    required int recordedAt,
    required String operation,
    this.beforeJson = const Value.absent(),
    this.afterJson = const Value.absent(),
  }) : entityTable = Value(entityTable),
       rowId = Value(rowId),
       recordedAt = Value(recordedAt),
       operation = Value(operation);
  static Insertable<DatabaseHistoryChange> custom({
    Expression<int>? id,
    Expression<String>? entityTable,
    Expression<String>? rowId,
    Expression<int>? recordedAt,
    Expression<String>? operation,
    Expression<String>? beforeJson,
    Expression<String>? afterJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityTable != null) 'entity_table': entityTable,
      if (rowId != null) 'row_id': rowId,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (operation != null) 'operation': operation,
      if (beforeJson != null) 'before_json': beforeJson,
      if (afterJson != null) 'after_json': afterJson,
    });
  }

  DatabaseHistoryChangesCompanion copyWith({
    Value<int>? id,
    Value<String>? entityTable,
    Value<String>? rowId,
    Value<int>? recordedAt,
    Value<String>? operation,
    Value<String?>? beforeJson,
    Value<String?>? afterJson,
  }) {
    return DatabaseHistoryChangesCompanion(
      id: id ?? this.id,
      entityTable: entityTable ?? this.entityTable,
      rowId: rowId ?? this.rowId,
      recordedAt: recordedAt ?? this.recordedAt,
      operation: operation ?? this.operation,
      beforeJson: beforeJson ?? this.beforeJson,
      afterJson: afterJson ?? this.afterJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityTable.present) {
      map['entity_table'] = Variable<String>(entityTable.value);
    }
    if (rowId.present) {
      map['row_id'] = Variable<String>(rowId.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<int>(recordedAt.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (beforeJson.present) {
      map['before_json'] = Variable<String>(beforeJson.value);
    }
    if (afterJson.present) {
      map['after_json'] = Variable<String>(afterJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DatabaseHistoryChangesCompanion(')
          ..write('id: $id, ')
          ..write('entityTable: $entityTable, ')
          ..write('rowId: $rowId, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('operation: $operation, ')
          ..write('beforeJson: $beforeJson, ')
          ..write('afterJson: $afterJson')
          ..write(')'))
        .toString();
  }
}

class $DatabaseHistoryMetadataTable extends DatabaseHistoryMetadata
    with TableInfo<$DatabaseHistoryMetadataTable, DatabaseHistoryMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DatabaseHistoryMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firstAvailableDateMeta =
      const VerificationMeta('firstAvailableDate');
  @override
  late final GeneratedColumn<int> firstAvailableDate = GeneratedColumn<int>(
    'first_available_date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, firstAvailableDate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'database_history_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<DatabaseHistoryMetadataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('first_available_date')) {
      context.handle(
        _firstAvailableDateMeta,
        firstAvailableDate.isAcceptableOrUnknown(
          data['first_available_date']!,
          _firstAvailableDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstAvailableDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DatabaseHistoryMetadataData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DatabaseHistoryMetadataData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      firstAvailableDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_available_date'],
      )!,
    );
  }

  @override
  $DatabaseHistoryMetadataTable createAlias(String alias) {
    return $DatabaseHistoryMetadataTable(attachedDatabase, alias);
  }
}

class DatabaseHistoryMetadataData extends DataClass
    implements Insertable<DatabaseHistoryMetadataData> {
  final int id;
  final int firstAvailableDate;
  const DatabaseHistoryMetadataData({
    required this.id,
    required this.firstAvailableDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['first_available_date'] = Variable<int>(firstAvailableDate);
    return map;
  }

  DatabaseHistoryMetadataCompanion toCompanion(bool nullToAbsent) {
    return DatabaseHistoryMetadataCompanion(
      id: Value(id),
      firstAvailableDate: Value(firstAvailableDate),
    );
  }

  factory DatabaseHistoryMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DatabaseHistoryMetadataData(
      id: serializer.fromJson<int>(json['id']),
      firstAvailableDate: serializer.fromJson<int>(json['firstAvailableDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'firstAvailableDate': serializer.toJson<int>(firstAvailableDate),
    };
  }

  DatabaseHistoryMetadataData copyWith({int? id, int? firstAvailableDate}) =>
      DatabaseHistoryMetadataData(
        id: id ?? this.id,
        firstAvailableDate: firstAvailableDate ?? this.firstAvailableDate,
      );
  DatabaseHistoryMetadataData copyWithCompanion(
    DatabaseHistoryMetadataCompanion data,
  ) {
    return DatabaseHistoryMetadataData(
      id: data.id.present ? data.id.value : this.id,
      firstAvailableDate: data.firstAvailableDate.present
          ? data.firstAvailableDate.value
          : this.firstAvailableDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DatabaseHistoryMetadataData(')
          ..write('id: $id, ')
          ..write('firstAvailableDate: $firstAvailableDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, firstAvailableDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DatabaseHistoryMetadataData &&
          other.id == this.id &&
          other.firstAvailableDate == this.firstAvailableDate);
}

class DatabaseHistoryMetadataCompanion
    extends UpdateCompanion<DatabaseHistoryMetadataData> {
  final Value<int> id;
  final Value<int> firstAvailableDate;
  const DatabaseHistoryMetadataCompanion({
    this.id = const Value.absent(),
    this.firstAvailableDate = const Value.absent(),
  });
  DatabaseHistoryMetadataCompanion.insert({
    this.id = const Value.absent(),
    required int firstAvailableDate,
  }) : firstAvailableDate = Value(firstAvailableDate);
  static Insertable<DatabaseHistoryMetadataData> custom({
    Expression<int>? id,
    Expression<int>? firstAvailableDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (firstAvailableDate != null)
        'first_available_date': firstAvailableDate,
    });
  }

  DatabaseHistoryMetadataCompanion copyWith({
    Value<int>? id,
    Value<int>? firstAvailableDate,
  }) {
    return DatabaseHistoryMetadataCompanion(
      id: id ?? this.id,
      firstAvailableDate: firstAvailableDate ?? this.firstAvailableDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (firstAvailableDate.present) {
      map['first_available_date'] = Variable<int>(firstAvailableDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DatabaseHistoryMetadataCompanion(')
          ..write('id: $id, ')
          ..write('firstAvailableDate: $firstAvailableDate')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $RecurringPaymentsTable recurringPayments =
      $RecurringPaymentsTable(this);
  late final $PaymentOccurrencesTable paymentOccurrences =
      $PaymentOccurrencesTable(this);
  late final $IncomeSchedulesTable incomeSchedules = $IncomeSchedulesTable(
    this,
  );
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $BackupImportIdentitiesTable backupImportIdentities =
      $BackupImportIdentitiesTable(this);
  late final $DatabaseMetadataTable databaseMetadata = $DatabaseMetadataTable(
    this,
  );
  late final $DatabaseHistoryChangesTable databaseHistoryChanges =
      $DatabaseHistoryChangesTable(this);
  late final $DatabaseHistoryMetadataTable databaseHistoryMetadata =
      $DatabaseHistoryMetadataTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    accounts,
    categories,
    transactions,
    recurringPayments,
    paymentOccurrences,
    incomeSchedules,
    appSettings,
    backupImportIdentities,
    databaseMetadata,
    databaseHistoryChanges,
    databaseHistoryMetadata,
  ];
}

typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  Value<int> id,
  required String name,
  Value<String> type,
  Value<String> currency,
  Value<bool> isNoWithdrawal,
  Value<bool> isDeposit,
  Value<int> initialBalance,
  Value<int> currentBalance,
  Value<bool> isActive,
  Value<DateTime> createdAt,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> type,
  Value<String> currency,
  Value<bool> isNoWithdrawal,
  Value<bool> isDeposit,
  Value<int> initialBalance,
  Value<int> currentBalance,
  Value<bool> isActive,
  Value<DateTime> createdAt,
});

final class $$AccountsTableReferences
    extends BaseReferences<_$AppDatabase, $AccountsTable, Account> {
  $$AccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: 'accounts__id__transactions__account_id',
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RecurringPaymentsTable, List<RecurringPayment>>
  _recurringPaymentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recurringPayments,
        aliasName: 'accounts__id__recurring_payments__account_id',
      );

  $$RecurringPaymentsTableProcessedTableManager get recurringPaymentsRefs {
    final manager = $$RecurringPaymentsTableTableManager(
      $_db,
      $_db.recurringPayments,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recurringPaymentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isNoWithdrawal => $composableBuilder(
    column: $table.isNoWithdrawal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeposit => $composableBuilder(
    column: $table.isDeposit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get initialBalance => $composableBuilder(
    column: $table.initialBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentBalance => $composableBuilder(
    column: $table.currentBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recurringPaymentsRefs(
    Expression<bool> Function($$RecurringPaymentsTableFilterComposer f) f,
  ) {
    final $$RecurringPaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recurringPayments,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringPaymentsTableFilterComposer(
            $db: $db,
            $table: $db.recurringPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isNoWithdrawal => $composableBuilder(
    column: $table.isNoWithdrawal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeposit => $composableBuilder(
    column: $table.isDeposit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get initialBalance => $composableBuilder(
    column: $table.initialBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentBalance => $composableBuilder(
    column: $table.currentBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<bool> get isNoWithdrawal => $composableBuilder(
    column: $table.isNoWithdrawal,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeposit =>
      $composableBuilder(column: $table.isDeposit, builder: (column) => column);

  GeneratedColumn<int> get initialBalance => $composableBuilder(
    column: $table.initialBalance,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentBalance => $composableBuilder(
    column: $table.currentBalance,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> recurringPaymentsRefs<T extends Object>(
    Expression<T> Function($$RecurringPaymentsTableAnnotationComposer a) f,
  ) {
    final $$RecurringPaymentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recurringPayments,
          getReferencedColumn: (t) => t.accountId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringPaymentsTableAnnotationComposer(
                $db: $db,
                $table: $db.recurringPayments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountsTable,
          Account,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (Account, $$AccountsTableReferences),
          Account,
          PrefetchHooks Function({
            bool transactionsRefs,
            bool recurringPaymentsRefs,
          })
        > {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<bool> isNoWithdrawal = const Value.absent(),
                Value<bool> isDeposit = const Value.absent(),
                Value<int> initialBalance = const Value.absent(),
                Value<int> currentBalance = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                name: name,
                type: type,
                currency: currency,
                isNoWithdrawal: isNoWithdrawal,
                isDeposit: isDeposit,
                initialBalance: initialBalance,
                currentBalance: currentBalance,
                isActive: isActive,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> type = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<bool> isNoWithdrawal = const Value.absent(),
                Value<bool> isDeposit = const Value.absent(),
                Value<int> initialBalance = const Value.absent(),
                Value<int> currentBalance = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AccountsCompanion.insert(
                id: id,
                name: name,
                type: type,
                currency: currency,
                isNoWithdrawal: isNoWithdrawal,
                isDeposit: isDeposit,
                initialBalance: initialBalance,
                currentBalance: currentBalance,
                isActive: isActive,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AccountsTable, Account>(table),
                  $$AccountsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({transactionsRefs = false, recurringPaymentsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionsRefs) db.transactions,
                    if (recurringPaymentsRefs) db.recurringPayments,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionsRefs)
                        await $_getPrefetchedDataByColumns<
                          Account,
                          $AccountsTable,
                          Transaction,
                          $TransactionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'account_id',
                          typedResults: items,
                        ),
                      if (recurringPaymentsRefs)
                        await $_getPrefetchedDataByColumns<
                          Account,
                          $AccountsTable,
                          RecurringPayment,
                          $RecurringPaymentsTable
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._recurringPaymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).recurringPaymentsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'account_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountsTable,
      Account,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (Account, $$AccountsTableReferences),
      Account,
      PrefetchHooks Function({
        bool transactionsRefs,
        bool recurringPaymentsRefs,
      })
    >;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  required String name,
  required String type,
  Value<String> icon,
  Value<int> color,
  Value<bool> isSystem,
  Value<bool> isArchived,
  Value<bool> isHidden,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> type,
  Value<String> icon,
  Value<int> color,
  Value<bool> isSystem,
  Value<bool> isArchived,
  Value<bool> isHidden,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: 'categories__id__transactions__category_id',
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RecurringPaymentsTable, List<RecurringPayment>>
  _recurringPaymentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recurringPayments,
        aliasName: 'categories__id__recurring_payments__category_id',
      );

  $$RecurringPaymentsTableProcessedTableManager get recurringPaymentsRefs {
    final manager = $$RecurringPaymentsTableTableManager(
      $_db,
      $_db.recurringPayments,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recurringPaymentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recurringPaymentsRefs(
    Expression<bool> Function($$RecurringPaymentsTableFilterComposer f) f,
  ) {
    final $$RecurringPaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recurringPayments,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringPaymentsTableFilterComposer(
            $db: $db,
            $table: $db.recurringPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isHidden =>
      $composableBuilder(column: $table.isHidden, builder: (column) => column);

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> recurringPaymentsRefs<T extends Object>(
    Expression<T> Function($$RecurringPaymentsTableAnnotationComposer a) f,
  ) {
    final $$RecurringPaymentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recurringPayments,
          getReferencedColumn: (t) => t.categoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringPaymentsTableAnnotationComposer(
                $db: $db,
                $table: $db.recurringPayments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({
            bool transactionsRefs,
            bool recurringPaymentsRefs,
          })
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                type: type,
                icon: icon,
                color: color,
                isSystem: isSystem,
                isArchived: isArchived,
                isHidden: isHidden,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String type,
                Value<String> icon = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                type: type,
                icon: icon,
                color: color,
                isSystem: isSystem,
                isArchived: isArchived,
                isHidden: isHidden,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTable, Category>(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({transactionsRefs = false, recurringPaymentsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionsRefs) db.transactions,
                    if (recurringPaymentsRefs) db.recurringPayments,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionsRefs)
                        await $_getPrefetchedDataByColumns<
                          Category,
                          $CategoriesTable,
                          Transaction,
                          $TransactionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'category_id',
                          typedResults: items,
                        ),
                      if (recurringPaymentsRefs)
                        await $_getPrefetchedDataByColumns<
                          Category,
                          $CategoriesTable,
                          RecurringPayment,
                          $RecurringPaymentsTable
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._recurringPaymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).recurringPaymentsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'category_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({
        bool transactionsRefs,
        bool recurringPaymentsRefs,
      })
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      required int accountId,
      Value<int?> categoryId,
      required String type,
      required int amount,
      Value<String> currency,
      Value<String> description,
      required DateTime transactionDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isExcludedFromStatistics,
      Value<bool> isUnavoidable,
      Value<int?> linkedPaymentOccurrenceId,
      Value<int?> transferGroupId,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      Value<int> accountId,
      Value<int?> categoryId,
      Value<String> type,
      Value<int> amount,
      Value<String> currency,
      Value<String> description,
      Value<DateTime> transactionDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isExcludedFromStatistics,
      Value<bool> isUnavoidable,
      Value<int?> linkedPaymentOccurrenceId,
      Value<int?> transferGroupId,
    });

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, Transaction> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias('transactions__account_id__accounts__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<int>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('transactions__category_id__categories__id');

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<int>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isExcludedFromStatistics => $composableBuilder(
    column: $table.isExcludedFromStatistics,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isUnavoidable => $composableBuilder(
    column: $table.isUnavoidable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get linkedPaymentOccurrenceId => $composableBuilder(
    column: $table.linkedPaymentOccurrenceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get transferGroupId => $composableBuilder(
    column: $table.transferGroupId,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isExcludedFromStatistics => $composableBuilder(
    column: $table.isExcludedFromStatistics,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isUnavoidable => $composableBuilder(
    column: $table.isUnavoidable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get linkedPaymentOccurrenceId => $composableBuilder(
    column: $table.linkedPaymentOccurrenceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get transferGroupId => $composableBuilder(
    column: $table.transferGroupId,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isExcludedFromStatistics => $composableBuilder(
    column: $table.isExcludedFromStatistics,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isUnavoidable => $composableBuilder(
    column: $table.isUnavoidable,
    builder: (column) => column,
  );

  GeneratedColumn<int> get linkedPaymentOccurrenceId => $composableBuilder(
    column: $table.linkedPaymentOccurrenceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get transferGroupId => $composableBuilder(
    column: $table.transferGroupId,
    builder: (column) => column,
  );

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          Transaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (Transaction, $$TransactionsTableReferences),
          Transaction,
          PrefetchHooks Function({bool accountId, bool categoryId})
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> accountId = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DateTime> transactionDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isExcludedFromStatistics = const Value.absent(),
                Value<bool> isUnavoidable = const Value.absent(),
                Value<int?> linkedPaymentOccurrenceId = const Value.absent(),
                Value<int?> transferGroupId = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                accountId: accountId,
                categoryId: categoryId,
                type: type,
                amount: amount,
                currency: currency,
                description: description,
                transactionDate: transactionDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isExcludedFromStatistics: isExcludedFromStatistics,
                isUnavoidable: isUnavoidable,
                linkedPaymentOccurrenceId: linkedPaymentOccurrenceId,
                transferGroupId: transferGroupId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int accountId,
                Value<int?> categoryId = const Value.absent(),
                required String type,
                required int amount,
                Value<String> currency = const Value.absent(),
                Value<String> description = const Value.absent(),
                required DateTime transactionDate,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isExcludedFromStatistics = const Value.absent(),
                Value<bool> isUnavoidable = const Value.absent(),
                Value<int?> linkedPaymentOccurrenceId = const Value.absent(),
                Value<int?> transferGroupId = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                accountId: accountId,
                categoryId: categoryId,
                type: type,
                amount: amount,
                currency: currency,
                description: description,
                transactionDate: transactionDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isExcludedFromStatistics: isExcludedFromStatistics,
                isUnavoidable: isUnavoidable,
                linkedPaymentOccurrenceId: linkedPaymentOccurrenceId,
                transferGroupId: transferGroupId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TransactionsTable, Transaction>(table),
                  $$TransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false, categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (accountId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.accountId,
                        referencedTable: $$TransactionsTableReferences
                            ._accountIdTable(db),
                        referencedColumn: $$TransactionsTableReferences
                            ._accountIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (categoryId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.categoryId,
                        referencedTable: $$TransactionsTableReferences
                            ._categoryIdTable(db),
                        referencedColumn: $$TransactionsTableReferences
                            ._categoryIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      Transaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (Transaction, $$TransactionsTableReferences),
      Transaction,
      PrefetchHooks Function({bool accountId, bool categoryId})
    >;
typedef $$RecurringPaymentsTableCreateCompanionBuilder =
    RecurringPaymentsCompanion Function({
      Value<int> id,
      required String name,
      required int amount,
      Value<int?> categoryId,
      Value<int?> accountId,
      required String frequency,
      Value<int?> paymentDay,
      required DateTime startDate,
      Value<DateTime?> endDate,
      Value<bool> isActive,
      Value<bool> isAutoPay,
      Value<String> description,
    });
typedef $$RecurringPaymentsTableUpdateCompanionBuilder =
    RecurringPaymentsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> amount,
      Value<int?> categoryId,
      Value<int?> accountId,
      Value<String> frequency,
      Value<int?> paymentDay,
      Value<DateTime> startDate,
      Value<DateTime?> endDate,
      Value<bool> isActive,
      Value<bool> isAutoPay,
      Value<String> description,
    });

final class $$RecurringPaymentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RecurringPaymentsTable,
          RecurringPayment
        > {
  $$RecurringPaymentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) => db.categories
      .createAlias('recurring_payments__category_id__categories__id');

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<int>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias('recurring_payments__account_id__accounts__id');

  $$AccountsTableProcessedTableManager? get accountId {
    final $_column = $_itemColumn<int>('account_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PaymentOccurrencesTable, List<PaymentOccurrence>>
  _paymentOccurrencesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.paymentOccurrences,
        aliasName:
            'recurring_payments__id__payment_occurrences__recurring_payment_id',
      );

  $$PaymentOccurrencesTableProcessedTableManager get paymentOccurrencesRefs {
    final manager =
        $$PaymentOccurrencesTableTableManager(
          $_db,
          $_db.paymentOccurrences,
        ).filter(
          (f) => f.recurringPaymentId.id.sqlEquals($_itemColumn<int>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _paymentOccurrencesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RecurringPaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringPaymentsTable> {
  $$RecurringPaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paymentDay => $composableBuilder(
    column: $table.paymentDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAutoPay => $composableBuilder(
    column: $table.isAutoPay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> paymentOccurrencesRefs(
    Expression<bool> Function($$PaymentOccurrencesTableFilterComposer f) f,
  ) {
    final $$PaymentOccurrencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentOccurrences,
      getReferencedColumn: (t) => t.recurringPaymentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentOccurrencesTableFilterComposer(
            $db: $db,
            $table: $db.paymentOccurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecurringPaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringPaymentsTable> {
  $$RecurringPaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paymentDay => $composableBuilder(
    column: $table.paymentDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAutoPay => $composableBuilder(
    column: $table.isAutoPay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecurringPaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringPaymentsTable> {
  $$RecurringPaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<int> get paymentDay => $composableBuilder(
    column: $table.paymentDay,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get isAutoPay =>
      $composableBuilder(column: $table.isAutoPay, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> paymentOccurrencesRefs<T extends Object>(
    Expression<T> Function($$PaymentOccurrencesTableAnnotationComposer a) f,
  ) {
    final $$PaymentOccurrencesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.paymentOccurrences,
          getReferencedColumn: (t) => t.recurringPaymentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PaymentOccurrencesTableAnnotationComposer(
                $db: $db,
                $table: $db.paymentOccurrences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$RecurringPaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringPaymentsTable,
          RecurringPayment,
          $$RecurringPaymentsTableFilterComposer,
          $$RecurringPaymentsTableOrderingComposer,
          $$RecurringPaymentsTableAnnotationComposer,
          $$RecurringPaymentsTableCreateCompanionBuilder,
          $$RecurringPaymentsTableUpdateCompanionBuilder,
          (RecurringPayment, $$RecurringPaymentsTableReferences),
          RecurringPayment,
          PrefetchHooks Function({
            bool categoryId,
            bool accountId,
            bool paymentOccurrencesRefs,
          })
        > {
  $$RecurringPaymentsTableTableManager(
    _$AppDatabase db,
    $RecurringPaymentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringPaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringPaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringPaymentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<int?> accountId = const Value.absent(),
                Value<String> frequency = const Value.absent(),
                Value<int?> paymentDay = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isAutoPay = const Value.absent(),
                Value<String> description = const Value.absent(),
              }) => RecurringPaymentsCompanion(
                id: id,
                name: name,
                amount: amount,
                categoryId: categoryId,
                accountId: accountId,
                frequency: frequency,
                paymentDay: paymentDay,
                startDate: startDate,
                endDate: endDate,
                isActive: isActive,
                isAutoPay: isAutoPay,
                description: description,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int amount,
                Value<int?> categoryId = const Value.absent(),
                Value<int?> accountId = const Value.absent(),
                required String frequency,
                Value<int?> paymentDay = const Value.absent(),
                required DateTime startDate,
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isAutoPay = const Value.absent(),
                Value<String> description = const Value.absent(),
              }) => RecurringPaymentsCompanion.insert(
                id: id,
                name: name,
                amount: amount,
                categoryId: categoryId,
                accountId: accountId,
                frequency: frequency,
                paymentDay: paymentDay,
                startDate: startDate,
                endDate: endDate,
                isActive: isActive,
                isAutoPay: isAutoPay,
                description: description,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecurringPaymentsTable, RecurringPayment>(table),
                  $$RecurringPaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categoryId = false,
                accountId = false,
                paymentOccurrencesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (paymentOccurrencesRefs) db.paymentOccurrences,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoryId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.categoryId,
                            referencedTable: $$RecurringPaymentsTableReferences
                                ._categoryIdTable(db),
                            referencedColumn: $$RecurringPaymentsTableReferences
                                ._categoryIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (accountId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.accountId,
                            referencedTable: $$RecurringPaymentsTableReferences
                                ._accountIdTable(db),
                            referencedColumn: $$RecurringPaymentsTableReferences
                                ._accountIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (paymentOccurrencesRefs)
                        await $_getPrefetchedDataByColumns<
                          RecurringPayment,
                          $RecurringPaymentsTable,
                          PaymentOccurrence,
                          $PaymentOccurrencesTable
                        >(
                          currentTable: table,
                          referencedTable: $$RecurringPaymentsTableReferences
                              ._paymentOccurrencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RecurringPaymentsTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentOccurrencesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'recurring_payment_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RecurringPaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringPaymentsTable,
      RecurringPayment,
      $$RecurringPaymentsTableFilterComposer,
      $$RecurringPaymentsTableOrderingComposer,
      $$RecurringPaymentsTableAnnotationComposer,
      $$RecurringPaymentsTableCreateCompanionBuilder,
      $$RecurringPaymentsTableUpdateCompanionBuilder,
      (RecurringPayment, $$RecurringPaymentsTableReferences),
      RecurringPayment,
      PrefetchHooks Function({
        bool categoryId,
        bool accountId,
        bool paymentOccurrencesRefs,
      })
    >;
typedef $$PaymentOccurrencesTableCreateCompanionBuilder =
    PaymentOccurrencesCompanion Function({
      Value<int> id,
      required int recurringPaymentId,
      required int expectedAmount,
      required DateTime dueDate,
      Value<String> status,
      Value<int> paidAmount,
      Value<int?> linkedTransactionId,
    });
typedef $$PaymentOccurrencesTableUpdateCompanionBuilder =
    PaymentOccurrencesCompanion Function({
      Value<int> id,
      Value<int> recurringPaymentId,
      Value<int> expectedAmount,
      Value<DateTime> dueDate,
      Value<String> status,
      Value<int> paidAmount,
      Value<int?> linkedTransactionId,
    });

final class $$PaymentOccurrencesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PaymentOccurrencesTable,
          PaymentOccurrence
        > {
  $$PaymentOccurrencesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RecurringPaymentsTable _recurringPaymentIdTable(_$AppDatabase db) =>
      db.recurringPayments.createAlias(
        'payment_occurrences__recurring_payment_id__recurring_payments__id',
      );

  $$RecurringPaymentsTableProcessedTableManager get recurringPaymentId {
    final $_column = $_itemColumn<int>('recurring_payment_id')!;

    final manager = $$RecurringPaymentsTableTableManager(
      $_db,
      $_db.recurringPayments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recurringPaymentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PaymentOccurrencesTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentOccurrencesTable> {
  $$PaymentOccurrencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedAmount => $composableBuilder(
    column: $table.expectedAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get linkedTransactionId => $composableBuilder(
    column: $table.linkedTransactionId,
    builder: (column) => ColumnFilters(column),
  );

  $$RecurringPaymentsTableFilterComposer get recurringPaymentId {
    final $$RecurringPaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recurringPaymentId,
      referencedTable: $db.recurringPayments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringPaymentsTableFilterComposer(
            $db: $db,
            $table: $db.recurringPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentOccurrencesTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentOccurrencesTable> {
  $$PaymentOccurrencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedAmount => $composableBuilder(
    column: $table.expectedAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get linkedTransactionId => $composableBuilder(
    column: $table.linkedTransactionId,
    builder: (column) => ColumnOrderings(column),
  );

  $$RecurringPaymentsTableOrderingComposer get recurringPaymentId {
    final $$RecurringPaymentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recurringPaymentId,
      referencedTable: $db.recurringPayments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringPaymentsTableOrderingComposer(
            $db: $db,
            $table: $db.recurringPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentOccurrencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentOccurrencesTable> {
  $$PaymentOccurrencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get expectedAmount => $composableBuilder(
    column: $table.expectedAmount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get linkedTransactionId => $composableBuilder(
    column: $table.linkedTransactionId,
    builder: (column) => column,
  );

  $$RecurringPaymentsTableAnnotationComposer get recurringPaymentId {
    final $$RecurringPaymentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.recurringPaymentId,
          referencedTable: $db.recurringPayments,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringPaymentsTableAnnotationComposer(
                $db: $db,
                $table: $db.recurringPayments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$PaymentOccurrencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentOccurrencesTable,
          PaymentOccurrence,
          $$PaymentOccurrencesTableFilterComposer,
          $$PaymentOccurrencesTableOrderingComposer,
          $$PaymentOccurrencesTableAnnotationComposer,
          $$PaymentOccurrencesTableCreateCompanionBuilder,
          $$PaymentOccurrencesTableUpdateCompanionBuilder,
          (PaymentOccurrence, $$PaymentOccurrencesTableReferences),
          PaymentOccurrence,
          PrefetchHooks Function({bool recurringPaymentId})
        > {
  $$PaymentOccurrencesTableTableManager(
    _$AppDatabase db,
    $PaymentOccurrencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentOccurrencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentOccurrencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentOccurrencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> recurringPaymentId = const Value.absent(),
                Value<int> expectedAmount = const Value.absent(),
                Value<DateTime> dueDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> paidAmount = const Value.absent(),
                Value<int?> linkedTransactionId = const Value.absent(),
              }) => PaymentOccurrencesCompanion(
                id: id,
                recurringPaymentId: recurringPaymentId,
                expectedAmount: expectedAmount,
                dueDate: dueDate,
                status: status,
                paidAmount: paidAmount,
                linkedTransactionId: linkedTransactionId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int recurringPaymentId,
                required int expectedAmount,
                required DateTime dueDate,
                Value<String> status = const Value.absent(),
                Value<int> paidAmount = const Value.absent(),
                Value<int?> linkedTransactionId = const Value.absent(),
              }) => PaymentOccurrencesCompanion.insert(
                id: id,
                recurringPaymentId: recurringPaymentId,
                expectedAmount: expectedAmount,
                dueDate: dueDate,
                status: status,
                paidAmount: paidAmount,
                linkedTransactionId: linkedTransactionId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PaymentOccurrencesTable, PaymentOccurrence>(
                    table,
                  ),
                  $$PaymentOccurrencesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({recurringPaymentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (recurringPaymentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.recurringPaymentId,
                        referencedTable: $$PaymentOccurrencesTableReferences
                            ._recurringPaymentIdTable(db),
                        referencedColumn: $$PaymentOccurrencesTableReferences
                            ._recurringPaymentIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PaymentOccurrencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentOccurrencesTable,
      PaymentOccurrence,
      $$PaymentOccurrencesTableFilterComposer,
      $$PaymentOccurrencesTableOrderingComposer,
      $$PaymentOccurrencesTableAnnotationComposer,
      $$PaymentOccurrencesTableCreateCompanionBuilder,
      $$PaymentOccurrencesTableUpdateCompanionBuilder,
      (PaymentOccurrence, $$PaymentOccurrencesTableReferences),
      PaymentOccurrence,
      PrefetchHooks Function({bool recurringPaymentId})
    >;
typedef $$IncomeSchedulesTableCreateCompanionBuilder =
    IncomeSchedulesCompanion Function({
      Value<int> id,
      required String name,
      required int expectedAmount,
      required String frequency,
      required DateTime expectedDate,
      Value<bool> isActive,
      Value<int?> linkedTransactionId,
    });
typedef $$IncomeSchedulesTableUpdateCompanionBuilder =
    IncomeSchedulesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> expectedAmount,
      Value<String> frequency,
      Value<DateTime> expectedDate,
      Value<bool> isActive,
      Value<int?> linkedTransactionId,
    });

class $$IncomeSchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $IncomeSchedulesTable> {
  $$IncomeSchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedAmount => $composableBuilder(
    column: $table.expectedAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expectedDate => $composableBuilder(
    column: $table.expectedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get linkedTransactionId => $composableBuilder(
    column: $table.linkedTransactionId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IncomeSchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $IncomeSchedulesTable> {
  $$IncomeSchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedAmount => $composableBuilder(
    column: $table.expectedAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expectedDate => $composableBuilder(
    column: $table.expectedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get linkedTransactionId => $composableBuilder(
    column: $table.linkedTransactionId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IncomeSchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $IncomeSchedulesTable> {
  $$IncomeSchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get expectedAmount => $composableBuilder(
    column: $table.expectedAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<DateTime> get expectedDate => $composableBuilder(
    column: $table.expectedDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get linkedTransactionId => $composableBuilder(
    column: $table.linkedTransactionId,
    builder: (column) => column,
  );
}

class $$IncomeSchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IncomeSchedulesTable,
          IncomeSchedule,
          $$IncomeSchedulesTableFilterComposer,
          $$IncomeSchedulesTableOrderingComposer,
          $$IncomeSchedulesTableAnnotationComposer,
          $$IncomeSchedulesTableCreateCompanionBuilder,
          $$IncomeSchedulesTableUpdateCompanionBuilder,
          (
            IncomeSchedule,
            BaseReferences<
              _$AppDatabase,
              $IncomeSchedulesTable,
              IncomeSchedule
            >,
          ),
          IncomeSchedule,
          PrefetchHooks Function()
        > {
  $$IncomeSchedulesTableTableManager(
    _$AppDatabase db,
    $IncomeSchedulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IncomeSchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IncomeSchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IncomeSchedulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> expectedAmount = const Value.absent(),
                Value<String> frequency = const Value.absent(),
                Value<DateTime> expectedDate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int?> linkedTransactionId = const Value.absent(),
              }) => IncomeSchedulesCompanion(
                id: id,
                name: name,
                expectedAmount: expectedAmount,
                frequency: frequency,
                expectedDate: expectedDate,
                isActive: isActive,
                linkedTransactionId: linkedTransactionId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int expectedAmount,
                required String frequency,
                required DateTime expectedDate,
                Value<bool> isActive = const Value.absent(),
                Value<int?> linkedTransactionId = const Value.absent(),
              }) => IncomeSchedulesCompanion.insert(
                id: id,
                name: name,
                expectedAmount: expectedAmount,
                frequency: frequency,
                expectedDate: expectedDate,
                isActive: isActive,
                linkedTransactionId: linkedTransactionId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$IncomeSchedulesTable, IncomeSchedule>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $IncomeSchedulesTable,
                    IncomeSchedule
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IncomeSchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IncomeSchedulesTable,
      IncomeSchedule,
      $$IncomeSchedulesTableFilterComposer,
      $$IncomeSchedulesTableOrderingComposer,
      $$IncomeSchedulesTableAnnotationComposer,
      $$IncomeSchedulesTableCreateCompanionBuilder,
      $$IncomeSchedulesTableUpdateCompanionBuilder,
      (
        IncomeSchedule,
        BaseReferences<_$AppDatabase, $IncomeSchedulesTable, IncomeSchedule>,
      ),
      IncomeSchedule,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$BackupImportIdentitiesTableCreateCompanionBuilder =
    BackupImportIdentitiesCompanion Function({
      required String sourceDatabaseId,
      required String sourceTable,
      required int sourceId,
      required int targetId,
      Value<int> rowid,
    });
typedef $$BackupImportIdentitiesTableUpdateCompanionBuilder =
    BackupImportIdentitiesCompanion Function({
      Value<String> sourceDatabaseId,
      Value<String> sourceTable,
      Value<int> sourceId,
      Value<int> targetId,
      Value<int> rowid,
    });

class $$BackupImportIdentitiesTableFilterComposer
    extends Composer<_$AppDatabase, $BackupImportIdentitiesTable> {
  $$BackupImportIdentitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sourceDatabaseId => $composableBuilder(
    column: $table.sourceDatabaseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceTable => $composableBuilder(
    column: $table.sourceTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BackupImportIdentitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $BackupImportIdentitiesTable> {
  $$BackupImportIdentitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sourceDatabaseId => $composableBuilder(
    column: $table.sourceDatabaseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceTable => $composableBuilder(
    column: $table.sourceTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BackupImportIdentitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BackupImportIdentitiesTable> {
  $$BackupImportIdentitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sourceDatabaseId => $composableBuilder(
    column: $table.sourceDatabaseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceTable => $composableBuilder(
    column: $table.sourceTable,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<int> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);
}

class $$BackupImportIdentitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BackupImportIdentitiesTable,
          BackupImportIdentity,
          $$BackupImportIdentitiesTableFilterComposer,
          $$BackupImportIdentitiesTableOrderingComposer,
          $$BackupImportIdentitiesTableAnnotationComposer,
          $$BackupImportIdentitiesTableCreateCompanionBuilder,
          $$BackupImportIdentitiesTableUpdateCompanionBuilder,
          (
            BackupImportIdentity,
            BaseReferences<
              _$AppDatabase,
              $BackupImportIdentitiesTable,
              BackupImportIdentity
            >,
          ),
          BackupImportIdentity,
          PrefetchHooks Function()
        > {
  $$BackupImportIdentitiesTableTableManager(
    _$AppDatabase db,
    $BackupImportIdentitiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BackupImportIdentitiesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$BackupImportIdentitiesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$BackupImportIdentitiesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> sourceDatabaseId = const Value.absent(),
                Value<String> sourceTable = const Value.absent(),
                Value<int> sourceId = const Value.absent(),
                Value<int> targetId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BackupImportIdentitiesCompanion(
                sourceDatabaseId: sourceDatabaseId,
                sourceTable: sourceTable,
                sourceId: sourceId,
                targetId: targetId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sourceDatabaseId,
                required String sourceTable,
                required int sourceId,
                required int targetId,
                Value<int> rowid = const Value.absent(),
              }) => BackupImportIdentitiesCompanion.insert(
                sourceDatabaseId: sourceDatabaseId,
                sourceTable: sourceTable,
                sourceId: sourceId,
                targetId: targetId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $BackupImportIdentitiesTable,
                    BackupImportIdentity
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $BackupImportIdentitiesTable,
                    BackupImportIdentity
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BackupImportIdentitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BackupImportIdentitiesTable,
      BackupImportIdentity,
      $$BackupImportIdentitiesTableFilterComposer,
      $$BackupImportIdentitiesTableOrderingComposer,
      $$BackupImportIdentitiesTableAnnotationComposer,
      $$BackupImportIdentitiesTableCreateCompanionBuilder,
      $$BackupImportIdentitiesTableUpdateCompanionBuilder,
      (
        BackupImportIdentity,
        BaseReferences<
          _$AppDatabase,
          $BackupImportIdentitiesTable,
          BackupImportIdentity
        >,
      ),
      BackupImportIdentity,
      PrefetchHooks Function()
    >;
typedef $$DatabaseMetadataTableCreateCompanionBuilder =
    DatabaseMetadataCompanion Function({
      Value<int> id,
      required String databaseId,
      required int revision,
      required int lastChangedAt,
    });
typedef $$DatabaseMetadataTableUpdateCompanionBuilder =
    DatabaseMetadataCompanion Function({
      Value<int> id,
      Value<String> databaseId,
      Value<int> revision,
      Value<int> lastChangedAt,
    });

class $$DatabaseMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $DatabaseMetadataTable> {
  $$DatabaseMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get databaseId => $composableBuilder(
    column: $table.databaseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastChangedAt => $composableBuilder(
    column: $table.lastChangedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DatabaseMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $DatabaseMetadataTable> {
  $$DatabaseMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get databaseId => $composableBuilder(
    column: $table.databaseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastChangedAt => $composableBuilder(
    column: $table.lastChangedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DatabaseMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $DatabaseMetadataTable> {
  $$DatabaseMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get databaseId => $composableBuilder(
    column: $table.databaseId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<int> get lastChangedAt => $composableBuilder(
    column: $table.lastChangedAt,
    builder: (column) => column,
  );
}

class $$DatabaseMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DatabaseMetadataTable,
          DatabaseMetadataData,
          $$DatabaseMetadataTableFilterComposer,
          $$DatabaseMetadataTableOrderingComposer,
          $$DatabaseMetadataTableAnnotationComposer,
          $$DatabaseMetadataTableCreateCompanionBuilder,
          $$DatabaseMetadataTableUpdateCompanionBuilder,
          (
            DatabaseMetadataData,
            BaseReferences<
              _$AppDatabase,
              $DatabaseMetadataTable,
              DatabaseMetadataData
            >,
          ),
          DatabaseMetadataData,
          PrefetchHooks Function()
        > {
  $$DatabaseMetadataTableTableManager(
    _$AppDatabase db,
    $DatabaseMetadataTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DatabaseMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DatabaseMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DatabaseMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> databaseId = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> lastChangedAt = const Value.absent(),
              }) => DatabaseMetadataCompanion(
                id: id,
                databaseId: databaseId,
                revision: revision,
                lastChangedAt: lastChangedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String databaseId,
                required int revision,
                required int lastChangedAt,
              }) => DatabaseMetadataCompanion.insert(
                id: id,
                databaseId: databaseId,
                revision: revision,
                lastChangedAt: lastChangedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DatabaseMetadataTable, DatabaseMetadataData>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $DatabaseMetadataTable,
                    DatabaseMetadataData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DatabaseMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DatabaseMetadataTable,
      DatabaseMetadataData,
      $$DatabaseMetadataTableFilterComposer,
      $$DatabaseMetadataTableOrderingComposer,
      $$DatabaseMetadataTableAnnotationComposer,
      $$DatabaseMetadataTableCreateCompanionBuilder,
      $$DatabaseMetadataTableUpdateCompanionBuilder,
      (
        DatabaseMetadataData,
        BaseReferences<
          _$AppDatabase,
          $DatabaseMetadataTable,
          DatabaseMetadataData
        >,
      ),
      DatabaseMetadataData,
      PrefetchHooks Function()
    >;
typedef $$DatabaseHistoryChangesTableCreateCompanionBuilder =
    DatabaseHistoryChangesCompanion Function({
      Value<int> id,
      required String entityTable,
      required String rowId,
      required int recordedAt,
      required String operation,
      Value<String?> beforeJson,
      Value<String?> afterJson,
    });
typedef $$DatabaseHistoryChangesTableUpdateCompanionBuilder =
    DatabaseHistoryChangesCompanion Function({
      Value<int> id,
      Value<String> entityTable,
      Value<String> rowId,
      Value<int> recordedAt,
      Value<String> operation,
      Value<String?> beforeJson,
      Value<String?> afterJson,
    });

class $$DatabaseHistoryChangesTableFilterComposer
    extends Composer<_$AppDatabase, $DatabaseHistoryChangesTable> {
  $$DatabaseHistoryChangesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get beforeJson => $composableBuilder(
    column: $table.beforeJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get afterJson => $composableBuilder(
    column: $table.afterJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DatabaseHistoryChangesTableOrderingComposer
    extends Composer<_$AppDatabase, $DatabaseHistoryChangesTable> {
  $$DatabaseHistoryChangesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get beforeJson => $composableBuilder(
    column: $table.beforeJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get afterJson => $composableBuilder(
    column: $table.afterJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DatabaseHistoryChangesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DatabaseHistoryChangesTable> {
  $$DatabaseHistoryChangesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => column);

  GeneratedColumn<int> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get beforeJson => $composableBuilder(
    column: $table.beforeJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get afterJson =>
      $composableBuilder(column: $table.afterJson, builder: (column) => column);
}

class $$DatabaseHistoryChangesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DatabaseHistoryChangesTable,
          DatabaseHistoryChange,
          $$DatabaseHistoryChangesTableFilterComposer,
          $$DatabaseHistoryChangesTableOrderingComposer,
          $$DatabaseHistoryChangesTableAnnotationComposer,
          $$DatabaseHistoryChangesTableCreateCompanionBuilder,
          $$DatabaseHistoryChangesTableUpdateCompanionBuilder,
          (
            DatabaseHistoryChange,
            BaseReferences<
              _$AppDatabase,
              $DatabaseHistoryChangesTable,
              DatabaseHistoryChange
            >,
          ),
          DatabaseHistoryChange,
          PrefetchHooks Function()
        > {
  $$DatabaseHistoryChangesTableTableManager(
    _$AppDatabase db,
    $DatabaseHistoryChangesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DatabaseHistoryChangesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$DatabaseHistoryChangesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DatabaseHistoryChangesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entityTable = const Value.absent(),
                Value<String> rowId = const Value.absent(),
                Value<int> recordedAt = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String?> beforeJson = const Value.absent(),
                Value<String?> afterJson = const Value.absent(),
              }) => DatabaseHistoryChangesCompanion(
                id: id,
                entityTable: entityTable,
                rowId: rowId,
                recordedAt: recordedAt,
                operation: operation,
                beforeJson: beforeJson,
                afterJson: afterJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entityTable,
                required String rowId,
                required int recordedAt,
                required String operation,
                Value<String?> beforeJson = const Value.absent(),
                Value<String?> afterJson = const Value.absent(),
              }) => DatabaseHistoryChangesCompanion.insert(
                id: id,
                entityTable: entityTable,
                rowId: rowId,
                recordedAt: recordedAt,
                operation: operation,
                beforeJson: beforeJson,
                afterJson: afterJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $DatabaseHistoryChangesTable,
                    DatabaseHistoryChange
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DatabaseHistoryChangesTable,
                    DatabaseHistoryChange
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DatabaseHistoryChangesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DatabaseHistoryChangesTable,
      DatabaseHistoryChange,
      $$DatabaseHistoryChangesTableFilterComposer,
      $$DatabaseHistoryChangesTableOrderingComposer,
      $$DatabaseHistoryChangesTableAnnotationComposer,
      $$DatabaseHistoryChangesTableCreateCompanionBuilder,
      $$DatabaseHistoryChangesTableUpdateCompanionBuilder,
      (
        DatabaseHistoryChange,
        BaseReferences<
          _$AppDatabase,
          $DatabaseHistoryChangesTable,
          DatabaseHistoryChange
        >,
      ),
      DatabaseHistoryChange,
      PrefetchHooks Function()
    >;
typedef $$DatabaseHistoryMetadataTableCreateCompanionBuilder =
    DatabaseHistoryMetadataCompanion Function({
      Value<int> id,
      required int firstAvailableDate,
    });
typedef $$DatabaseHistoryMetadataTableUpdateCompanionBuilder =
    DatabaseHistoryMetadataCompanion Function({
      Value<int> id,
      Value<int> firstAvailableDate,
    });

class $$DatabaseHistoryMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $DatabaseHistoryMetadataTable> {
  $$DatabaseHistoryMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstAvailableDate => $composableBuilder(
    column: $table.firstAvailableDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DatabaseHistoryMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $DatabaseHistoryMetadataTable> {
  $$DatabaseHistoryMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstAvailableDate => $composableBuilder(
    column: $table.firstAvailableDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DatabaseHistoryMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $DatabaseHistoryMetadataTable> {
  $$DatabaseHistoryMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get firstAvailableDate => $composableBuilder(
    column: $table.firstAvailableDate,
    builder: (column) => column,
  );
}

class $$DatabaseHistoryMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DatabaseHistoryMetadataTable,
          DatabaseHistoryMetadataData,
          $$DatabaseHistoryMetadataTableFilterComposer,
          $$DatabaseHistoryMetadataTableOrderingComposer,
          $$DatabaseHistoryMetadataTableAnnotationComposer,
          $$DatabaseHistoryMetadataTableCreateCompanionBuilder,
          $$DatabaseHistoryMetadataTableUpdateCompanionBuilder,
          (
            DatabaseHistoryMetadataData,
            BaseReferences<
              _$AppDatabase,
              $DatabaseHistoryMetadataTable,
              DatabaseHistoryMetadataData
            >,
          ),
          DatabaseHistoryMetadataData,
          PrefetchHooks Function()
        > {
  $$DatabaseHistoryMetadataTableTableManager(
    _$AppDatabase db,
    $DatabaseHistoryMetadataTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DatabaseHistoryMetadataTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$DatabaseHistoryMetadataTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DatabaseHistoryMetadataTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> firstAvailableDate = const Value.absent(),
              }) => DatabaseHistoryMetadataCompanion(
                id: id,
                firstAvailableDate: firstAvailableDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int firstAvailableDate,
              }) => DatabaseHistoryMetadataCompanion.insert(
                id: id,
                firstAvailableDate: firstAvailableDate,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $DatabaseHistoryMetadataTable,
                    DatabaseHistoryMetadataData
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DatabaseHistoryMetadataTable,
                    DatabaseHistoryMetadataData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DatabaseHistoryMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DatabaseHistoryMetadataTable,
      DatabaseHistoryMetadataData,
      $$DatabaseHistoryMetadataTableFilterComposer,
      $$DatabaseHistoryMetadataTableOrderingComposer,
      $$DatabaseHistoryMetadataTableAnnotationComposer,
      $$DatabaseHistoryMetadataTableCreateCompanionBuilder,
      $$DatabaseHistoryMetadataTableUpdateCompanionBuilder,
      (
        DatabaseHistoryMetadataData,
        BaseReferences<
          _$AppDatabase,
          $DatabaseHistoryMetadataTable,
          DatabaseHistoryMetadataData
        >,
      ),
      DatabaseHistoryMetadataData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$RecurringPaymentsTableTableManager get recurringPayments =>
      $$RecurringPaymentsTableTableManager(_db, _db.recurringPayments);
  $$PaymentOccurrencesTableTableManager get paymentOccurrences =>
      $$PaymentOccurrencesTableTableManager(_db, _db.paymentOccurrences);
  $$IncomeSchedulesTableTableManager get incomeSchedules =>
      $$IncomeSchedulesTableTableManager(_db, _db.incomeSchedules);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$BackupImportIdentitiesTableTableManager get backupImportIdentities =>
      $$BackupImportIdentitiesTableTableManager(
        _db,
        _db.backupImportIdentities,
      );
  $$DatabaseMetadataTableTableManager get databaseMetadata =>
      $$DatabaseMetadataTableTableManager(_db, _db.databaseMetadata);
  $$DatabaseHistoryChangesTableTableManager get databaseHistoryChanges =>
      $$DatabaseHistoryChangesTableTableManager(
        _db,
        _db.databaseHistoryChanges,
      );
  $$DatabaseHistoryMetadataTableTableManager get databaseHistoryMetadata =>
      $$DatabaseHistoryMetadataTableTableManager(
        _db,
        _db.databaseHistoryMetadata,
      );
}
