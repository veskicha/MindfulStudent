import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void showToast(BuildContext context, String title,
    {String description = '',
    ToastificationType type = ToastificationType.info}) {
  toastification.show(
    context: context,
    type: type,
    style: ToastificationStyle.flatColored,
    title: Text(title),
    description: Text(description),
    autoCloseDuration: const Duration(seconds: 5),
  );
}

void showInfo(BuildContext context, String title, {String description = ''}) {
  return showToast(context, title,
      description: description, type: ToastificationType.info);
}

void showError(BuildContext context, String title, {String description = ''}) {
  return showToast(context, title,
      description: description, type: ToastificationType.error);
}

void showSuccess(BuildContext context, String title,
    {String description = ''}) {
  return showToast(context, title,
      description: description, type: ToastificationType.success);
}
