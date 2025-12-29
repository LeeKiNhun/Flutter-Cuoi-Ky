import 'package:flutter/cupertino.dart';
import '../models/category_entity.dart';

const expense = 0;
const income = 1;

/// Default categories for MoneyTrack (used for seed & reset)
final List<CategoryEntity> defaultCategories = [
  // ===== Expense =====
  CategoryEntity(
    id: 'exp_food',
    type: expense,
    name: 'Food',
    iconCode: CupertinoIcons.cart.codePoint,
    colorValue: 0xFFFF6B6B,
  ),
  CategoryEntity(
    id: 'exp_transport',
    type: expense,
    name: 'Transport',
    iconCode: CupertinoIcons.car.codePoint,
    colorValue: 0xFF4D96FF,
  ),
  CategoryEntity(
    id: 'exp_bills',
    type: expense,
    name: 'Bills',
    iconCode: CupertinoIcons.doc_text.codePoint,
    colorValue: 0xFFFFC75F,
  ),
  CategoryEntity(
    id: 'exp_entertainment',
    type: expense,
    name: 'Entertainment',
    iconCode: CupertinoIcons.film.codePoint,
    colorValue: 0xFF845EC2,
  ),
  CategoryEntity(
    id: 'exp_shopping',
    type: expense,
    name: 'Shopping',
    iconCode: CupertinoIcons.bag.codePoint,
    colorValue: 0xFF00C9A7,
  ),

  // ===== Income =====
  CategoryEntity(
    id: 'inc_salary',
    type: income,
    name: 'Salary',
    iconCode: CupertinoIcons.money_dollar_circle.codePoint,
    colorValue: 0xFF2ECC71,
  ),
  CategoryEntity(
    id: 'inc_business',
    type: income,
    name: 'Business',
    iconCode: CupertinoIcons.briefcase.codePoint,
    colorValue: 0xFF1ABC9C,
  ),
  CategoryEntity(
    id: 'inc_gift',
    type: income,
    name: 'Gift',
    iconCode: CupertinoIcons.gift.codePoint,
    colorValue: 0xFFFF9671,
  ),
];
