import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/repositories/uniselection_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = UniSelectionRepository();
  runApp(UniSelectionApp(repository: repository));
}
