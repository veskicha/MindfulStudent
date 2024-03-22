import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void showToast(BuildContext context, String title,
    {ToastificationType type = ToastificationType.info}) {
  toastification.show(
    context: context,
    type: type,
    style: ToastificationStyle.flatColored,
    title: Text(title),
    autoCloseDuration: const Duration(seconds: 5),
  );
}
