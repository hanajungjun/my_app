import 'package:flutter/material.dart';
import 'package:my_app/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBootstrap.run();
}
