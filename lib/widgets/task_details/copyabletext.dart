import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class CopyableText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const CopyableText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        _copyToClipboard(context);
      },
      onTap: () {
        // Optionnel: montrer un tooltip pour indiquer que c'est copiable
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Press and hold to copy'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200] ?? Colors.grey),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                text,
                style: style ?? const TextStyle(fontSize: 16),
                textAlign: textAlign,
                maxLines: maxLines,
                overflow: overflow,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.content_copy,
              size: 18,
              color: Colors.grey[500],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Description copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }
}