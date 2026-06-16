import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'search_controller.dart';

class HighlightText extends StatefulWidget {
  final String text;
  final InlineSpan? textSpan;
  final TextStyle? style;
  final TextOverflow? overflow;
  final int? maxLines;
  final TextAlign? textAlign;
  final bool? softWrap;
  final TextDirection? textDirection;

  const HighlightText(
    this.text, {
    super.key,
    this.textSpan,
    this.style,
    this.overflow,
    this.maxLines,
    this.textAlign,
    this.softWrap,
    this.textDirection,
  });

  const HighlightText.rich(
    this.text, {
    super.key,
    this.textSpan,
    this.style,
    this.overflow,
    this.maxLines,
    this.textAlign,
    this.softWrap,
    this.textDirection,
  });

  @override
  State<HighlightText> createState() => _HighlightTextState();
}

class _HighlightTextState extends State<HighlightText> {
  final GlobalKey _key = GlobalKey();

  int? _matchIndex;
  String? _lastQuery;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GlobalSearchController>();

    return Obx(() {
      final query = controller.query.value.toLowerCase();
      final currentIndex = controller.currentIndex.value;

      if (_lastQuery != query) {
        _matchIndex = null;
        _lastQuery = query;
      }

      final fullText = widget.textSpan != null ? _extractText(widget.textSpan!) : widget.text;

      final hasMatch = query.isNotEmpty && fullText.toLowerCase().contains(query);

      if (hasMatch && _matchIndex == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _matchIndex = controller.registerMatch(_key);
          }
        });
      }

      if (!hasMatch) {
        _matchIndex = null;
      }

      final isActive = _matchIndex != null && _matchIndex == currentIndex;

      ///SIMPLE TEXT
      if (widget.textSpan == null) {
        if (!hasMatch) {
          return Text(
            widget.text,
            key: _key,
            style: widget.style,
            overflow: widget.overflow,
            maxLines: widget.maxLines,
            textAlign: widget.textAlign,
            softWrap: widget.softWrap,
            textDirection: widget.textDirection,
          );
        }

        return Text.rich(
          TextSpan(
            children: _highlightText(widget.text, query, isActive),
            style: widget.style,
          ),
          key: _key,
          overflow: widget.overflow,
          maxLines: widget.maxLines,
          textAlign: widget.textAlign ?? TextAlign.start,
          textDirection: widget.textDirection,
        );
      }

      ///RICH TEXT (FIXED)
      if (!hasMatch) {
        return Text.rich(
          widget.textSpan!,
          key: _key,
          overflow: widget.overflow,
          maxLines: widget.maxLines,
          textAlign: widget.textAlign ?? TextAlign.start,
          textDirection: widget.textDirection,
        );
      }

      return Text.rich(
        _highlightSpan(widget.textSpan!, query, isActive),
        key: _key,
        overflow: widget.overflow,
        maxLines: widget.maxLines,
        textAlign: widget.textAlign ?? TextAlign.start,
        textDirection: widget.textDirection,
      );
    });
  }

  /// Extract full text from TextSpan (for searching)
  String _extractText(InlineSpan span) {
    if (span is TextSpan) {
      String text = span.text ?? '';
      if (span.children != null) {
        for (var child in span.children!) {
          text += _extractText(child);
        }
      }
      return text;
    }
    return '';
  }

  /// Highlight normal string
  List<TextSpan> _highlightText(String text, String query, bool isActive) {
    final lowerText = text.toLowerCase();
    final spans = <TextSpan>[];

    int start = 0;

    while (true) {
      final index = lowerText.indexOf(query, start);

      if (index < 0) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }

      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: TextStyle(
            backgroundColor: isActive ? Colors.blue : Colors.yellow,
            color: isActive ? Colors.white : Colors.black,
          ),
        ),
      );

      start = index + query.length;
    }

    return spans;
  }

  /// Recursive highlight for TextSpan (MAIN FIX)
  InlineSpan _highlightSpan(InlineSpan span, String query, bool isActive) {
    if (span is TextSpan) {
      final text = span.text ?? '';

      /// If this span has children → process recursively
      if (span.children != null && span.children!.isNotEmpty) {
        return TextSpan(
          style: span.style,
          children: span.children!.map((child) => _highlightSpan(child, query, isActive)).toList(),
        );
      }

      /// If this span has text → highlight it
      if (text.isNotEmpty) {
        return TextSpan(
          style: span.style,
          children: _highlightText(text, query, isActive),
        );
      }

      return span;
    }

    /// Keep WidgetSpan (icons etc.)
    return span;
  }
}
