import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/services/app_lifecycle_service.dart';
import 'core/services/time_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await TimeInitializer.instance.initialize();

  AppLifecycleService.instance.initialize();

  runApp(const LifeSaarthiApp());
}
