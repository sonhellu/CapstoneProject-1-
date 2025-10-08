import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hi_cam_app/app/app.dart';

void main(){
  runApp(const ProviderScope(child: App()));
}