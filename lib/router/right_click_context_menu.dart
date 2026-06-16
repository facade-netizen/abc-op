import 'dart:async';
import 'package:web/web.dart' as html;
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../reusable/colors.dart';

/// A reusable right-click context menu for link-like UI elements.
class RightClickContextMenu {
  static OverlayEntry? _overlayEntry;
  static StreamSubscription<html.MouseEvent>? _contextMenuSubscription;
  static VoidCallback? _onOverlayRemoved;
  static bool isShowing = false;

  static Future<void> show(
    BuildContext context,
    Offset position,
    String linkUrl, {
    VoidCallback? onOverlayRemoved,
  }) async {
    _removeOverlay();
    _onOverlayRemoved = onOverlayRemoved;
    isShowing = true;

    html.document.body?.onContextMenu.listen((event) {
      event.preventDefault();
    });

    final overlay = Overlay.of(context);
    final completer = Completer<void>();

    _overlayEntry = OverlayEntry(
      builder: (BuildContext overlayContext) {
        final screenSize = MediaQuery.of(overlayContext).size;
        final double horizontalMargin = 8.0;
        final double verticalMargin = 8.0;
        const double menuWidth = 260.0;
        const double menuHeight = 240.0;
        final double maxMenuWidth = math.min(menuWidth, screenSize.width - horizontalMargin * 2);

        final double rightSideLeft = position.dx + horizontalMargin;
        final double leftSideLeft = position.dx - maxMenuWidth - horizontalMargin;
        double leftPosition = rightSideLeft;
        if (rightSideLeft + maxMenuWidth > screenSize.width) {
          leftPosition = math.max(horizontalMargin, leftSideLeft);
        }

        double topPosition = position.dy + verticalMargin;
        if (topPosition + menuHeight > screenSize.height - verticalMargin) {
          topPosition = position.dy - menuHeight - verticalMargin;
        }
        topPosition = math.max(verticalMargin, topPosition);

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _removeOverlay();
                  if (!completer.isCompleted) completer.complete();
                },
              ),
            ),
            Positioned(
              left: leftPosition,
              top: topPosition,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: maxMenuWidth,
                    maxHeight: screenSize.height - verticalMargin * 2,
                  ),
                  child: Container(
                    width: maxMenuWidth,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFDDDDDD), width: 1),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildMenuItem(
                            context,
                            'Open link in new tab',
                            Icons.open_in_new,
                            _ContextMenuAction.openNewTab,
                            linkUrl,
                            completer,
                          ),
                          _buildMenuItem(
                            context,
                            'Open link in new window',
                            Icons.open_in_new_outlined,
                            _ContextMenuAction.openNewWindow,
                            linkUrl,
                            completer,
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            context,
                            'Save link as...',
                            Icons.save_alt_outlined,
                            _ContextMenuAction.saveAs,
                            linkUrl,
                            completer,
                          ),
                          _buildMenuItem(
                            context,
                            'Copy link address',
                            Icons.link,
                            _ContextMenuAction.copyLink,
                            linkUrl,
                            completer,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
    return completer.future;
  }

  static void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _contextMenuSubscription?.cancel();
    _contextMenuSubscription = null;
    isShowing = false;
    final callback = _onOverlayRemoved;
    _onOverlayRemoved = null;
    if (callback != null) {
      callback();
    }
  }

  static Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    _ContextMenuAction action,
    String url,
    Completer<void> completer,
  ) {
    return InkWell(
      onTap: () async {
        _removeOverlay();
        try {
          await _handleSelection(action, url);
        } finally {
          if (!completer.isCompleted) {
            completer.complete();
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(0),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: const Color(0xFFB0B0B0),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: black,
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[300],
    );
  }

  static Future<void> _handleSelection(
    _ContextMenuAction action,
    String url,
  ) async {
    switch (action) {
      case _ContextMenuAction.openNewTab:
        html.window.open(url, '_blank');
        break;

      case _ContextMenuAction.openNewWindow:
        html.window.open(
          url,
          '_blank',
          'width=1200,height=800,resizable=yes,scrollbars=yes,status=yes,menubar=no,toolbar=no,location=yes',
        );
        break;

      case _ContextMenuAction.saveAs:
        await _saveLinkAs(url);
        break;

      case _ContextMenuAction.copyLink:
        await _copyLink(url);
        break;
    }
  }

  static Future<void> _saveLinkAs(String url) async {
    final anchor = html.HTMLAnchorElement()
      ..href = url
      ..download = _getFileNameFromUrl(url)
      ..style.display = 'none';

    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
  }

  static String _getFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        final fileName = pathSegments.last;
        if (fileName.contains('.') && !fileName.endsWith('/')) {
          return fileName;
        }
      }
      final host = uri.host.replaceAll('.', '_');
      return 'download_$host';
    } catch (e) {
      return 'download';
    }
  }

  static Future<void> _copyLink(String url) async {
    try {
      final clipboard = html.window.navigator.clipboard;
      clipboard.writeText(url);
      return;
    } catch (e) {
      final textArea = html.HTMLTextAreaElement()
        ..value = url
        ..style.position = 'fixed'
        ..style.top = '0'
        ..style.left = '0'
        ..style.opacity = '0'
        ..style.pointerEvents = 'none';

      html.document.body?.append(textArea);
      textArea.select();

      try {
        html.document.execCommand('copy');
      } catch (e) {
        textArea.style.opacity = '1';
        textArea.style.pointerEvents = 'auto';
        textArea.style.zIndex = '999999';
        textArea.style.position = 'fixed';
        textArea.style.top = '50%';
        textArea.style.left = '50%';
        textArea.style.transform = 'translate(-50%, -50%)';
        textArea.style.padding = '10px';
        textArea.style.width = '400px';
        textArea.select();
      }

      textArea.remove();
    }
  }
}

enum _ContextMenuAction { openNewTab, openNewWindow, saveAs, copyLink }
