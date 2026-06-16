import 'package:flutter/material.dart';
import '../../../reusable/colors.dart';
import 'highlighted_text_widget.dart';

/// GENERIC HYBRID TABLE
class CustomTable<T> extends StatelessWidget {
  final List<T> data;
  final List<TableColumn<T>> columns;
  final Widget? child;
  final double? tableTopPadding;
  final double? rowVerticalPadding;
  const CustomTable({
    super.key,
    this.child,
    required this.data,
    required this.columns,
    this.tableTopPadding,
    this.rowVerticalPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 30, top: tableTopPadding ?? 30),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            if (child != null) SizedBox(child: child),

            /// HEADER
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFE4E4E4),
                border: Border(
                  top: BorderSide(color: borderColor),
                  bottom: BorderSide(color: borderColor),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: rowVerticalPadding ?? 4),
                child: Row(
                  children: columns.map((col) {
                    return _buildColumnWrapper(
                      col: col,
                      child: HighlightText(
                        col.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          height: 1.25,
                          color: headerTextColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            /// BODY
            ListView.builder(
              itemCount: data.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: true,
              addSemanticIndexes: false,
              itemBuilder: (context, index) {
                final row = data[index];
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: rowVerticalPadding ?? 4),
                  decoration: BoxDecoration(
                    color: white,
                    border: Border(
                      bottom: BorderSide(
                        color: index == data.length - 1 ? borderColor : Colors.grey.shade200,
                      ),
                    ),
                  ),
                  child: Row(
                    children: columns.map((col) {
                      final text = col.value?.call(row) ?? '';
                      final color = col.color != null ? col.color!(row) : Colors.black;

                      if (col.customCell != null) {
                        return _buildColumnWrapper(
                          col: col,
                          child: col.customCell!(row),
                        );
                      }

                      return _buildColumnWrapper(
                        col: col,
                        child: HighlightText(
                          text,
                          textDirection: col.alignRight ? TextDirection.rtl : TextDirection.ltr,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.25,
                            fontWeight: FontWeight.w300,
                            color: color,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// CELL WRAPPER
  Widget _buildColumnWrapper({
    required TableColumn<T> col,
    required Widget child,
  }) {
    /// FIXED WIDTH
    if (col.width != null) {
      return SizedBox(
        width: col.width,
        child: _alignCell(col, child),
      );
    }

    /// FLEXIBLE WIDTH
    return Flexible(
      flex: (col.flex * 100).toInt(),
      child: _alignCell(col, child),
    );
  }

  /// ALIGNMENT + PADDING
  Widget _alignCell(TableColumn<T> col, Widget child) {
    return Container(
      alignment: col.alignCenter
          ? Alignment.center
          : col.alignRight
              ? Alignment.centerRight
              : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: child,
    );
  }
}

/// COLUMN MODEL
class TableColumn<T> {
  final String label;
  final double? width;
  final double flex;

  final bool alignRight;
  final bool alignCenter;
  final FontWeight fontWeight;

  final Color Function(T row)? color;
  final String Function(T row)? value;
  final Widget Function(T row)? customCell;

  const TableColumn({
    required this.label,
    this.width,
    this.flex = 1,
    this.value,
    this.customCell,
    this.alignCenter = false,
    this.alignRight = false,
    this.color,
    this.fontWeight = FontWeight.normal,
  });
}

/// Generic column wrapper usable by both table variants
Widget _tableColumnWrapper<T>({
  required TableColumn<T> col,
  required Widget child,
}) {
  if (col.width != null) {
    return SizedBox(width: col.width, child: _tableAlignCell(col, child));
  }

  return Flexible(flex: (col.flex * 100).toInt(), child: _tableAlignCell(col, child));
}

Widget _tableAlignCell<T>(TableColumn<T> col, Widget child) {
  return Container(
    alignment: col.alignCenter
        ? Alignment.center
        : col.alignRight
            ? Alignment.centerRight
            : Alignment.centerLeft,
    padding: const EdgeInsets.symmetric(horizontal: 2),
    child: child,
  );
}

class CustomPaginatedTable<T> extends StatelessWidget {
  const CustomPaginatedTable({
    super.key,
    required this.columns,
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.onPageTap,
    required this.onPrevious,
    required this.onNext,
    this.rowKey,
    this.expandedRowIds,
    this.expandedRowBuilder,
    this.emptyMessage,
    this.topPadding = 30,
  });

  final List<TableColumn<T>> columns;
  final List<T> data;
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageTap;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final Object? Function(T row)? rowKey;
  final Set<Object?>? expandedRowIds;
  final Widget Function(T row)? expandedRowBuilder;
  final String? emptyMessage;
  final double topPadding;
  @override
  Widget build(BuildContext context) {
    final int safeTotalPages = totalPages < 1 ? 1 : totalPages;
    final int safeCurrentPage = currentPage.clamp(1, safeTotalPages).toInt();

    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: headerRowColor,
              border: const Border(
                top: BorderSide(color: borderColor),
                bottom: BorderSide(color: borderColor),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: columns.map((col) {
                  return _tableColumnWrapper(
                    col: col,
                    child: HighlightText(
                      col.label,
                      textDirection: col.alignRight ? TextDirection.ltr : TextDirection.ltr,
                      textAlign: col.alignRight ? TextAlign.right : TextAlign.left,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        height: 1.25,
                        color: headerTextColor,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          ScrollbarTheme(
            data: ScrollbarThemeData(
              thumbColor: MaterialStateProperty.all(grey),
              trackColor: MaterialStateProperty.all(Colors.grey.shade100),
              thumbVisibility: MaterialStateProperty.all(true),
              trackVisibility: MaterialStateProperty.all(true),
              thickness: MaterialStateProperty.all(10),
              radius: const Radius.circular(10),
              minThumbLength: 50,
              crossAxisMargin: 2,
              mainAxisMargin: 2,
              interactive: true,
            ),
            child: data.isEmpty && (emptyMessage != null)
                ? Container(
                    height: 30,
                    color: white,
                    width: double.infinity,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: HighlightText(
                            emptyMessage ?? 'No Data',
                            style: const TextStyle(fontSize: 14, color: black, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: data.length,
                    shrinkWrap: true,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: true,
                    addSemanticIndexes: false,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final row = data[index];
                      final rowKeyValue = rowKey?.call(row);
                      final bool isExpanded = rowKeyValue != null && expandedRowIds != null && expandedRowBuilder != null && expandedRowIds!.contains(rowKeyValue);

                      final rowWidget = Container(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        decoration: BoxDecoration(
                          color: white,
                          border: Border(
                            bottom: BorderSide(
                              color: index == data.length - 1 && !isExpanded ? borderColor : Colors.grey.shade200,
                            ),
                          ),
                        ),
                        child: Row(
                          children: columns.map((col) {
                            final text = col.value?.call(row) ?? '';
                            final color = col.color != null ? col.color!(row) : Colors.black;

                            final Widget cellChild = col.customCell != null
                                ? col.customCell!(row)
                                : HighlightText(
                                    text,
                                    softWrap: true,
                                    //textDirection: col.alignRight ? TextDirection.rtl : TextDirection.ltr,
                                    textAlign: col.alignRight ? TextAlign.right : TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 12,
                                      height: 1.25,
                                      fontWeight: FontWeight.w300,
                                      color: color,
                                    ),
                                  );

                            return _tableColumnWrapper(col: col, child: cellChild);
                          }).toList(),
                        ),
                      );

                      if (!isExpanded) {
                        return rowWidget;
                      }

                      return Column(
                        children: [
                          rowWidget,
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: white,
                            ),
                            child: expandedRowBuilder!(row),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          if (data.isNotEmpty) ...[
            SizedBox(height: 10),
            _TablePaginationBar(
              currentPage: safeCurrentPage,
              totalPages: safeTotalPages,
              onPageTap: onPageTap,
              onPrevious: onPrevious,
              onNext: onNext,
            ),
            SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _TablePaginationBar extends StatefulWidget {
  const _TablePaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.onPageTap,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageTap;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  State<_TablePaginationBar> createState() => _TablePaginationBarState();
}

class _TablePaginationBarState extends State<_TablePaginationBar> {
  final TextEditingController _pageController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Widget> _buildPageButtons() {
    final List<Widget> buttons = [];

    void addPageButton(int page) {
      buttons.add(
        _TablePageIndexButton(
          label: '$page',
          isActive: page == widget.currentPage,
          onTap: () => widget.onPageTap(page),
        ),
      );
      buttons.add(const SizedBox(width: 4));
    }

    if (widget.totalPages <= 11) {
      for (int page = 1; page <= widget.totalPages; page++) {
        addPageButton(page);
      }
      return buttons;
    }

    // show condensed range with ellipsis for large page counts
    addPageButton(1);
    final int start = (widget.currentPage - 1).clamp(2, widget.totalPages - 9);
    final int end = (start + 8).clamp(2, widget.totalPages - 1);
    if (start > 2) buttons.add(_TablePageIndexButton(label: '...', isActive: false, onTap: () {}));
    buttons.add(const SizedBox(width: 4));

    for (int page = start; page <= end; page++) {
      addPageButton(page);
    }
    if (end < widget.totalPages - 1) buttons.add(_TablePageIndexButton(label: '...', isActive: false, onTap: () {}));
    buttons.add(const SizedBox(width: 4));

    addPageButton(widget.totalPages);
    return buttons;
  }

  void _onGo() {
    final text = _pageController.text.trim();
    if (text.isEmpty) return;
    final parsed = int.tryParse(text);
    if (parsed == null) return;
    final page = parsed.clamp(1, widget.totalPages);
    widget.onPageTap(page);
    _pageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final bool canGoPrevious = widget.currentPage > 1;
    final bool canGoNext = widget.currentPage < widget.totalPages;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TablePageButton(title: 'Prev', enabled: canGoPrevious, action: widget.onPrevious),
        const SizedBox(width: 6),
        ..._buildPageButtons(),
        const SizedBox(width: 6),
        TablePageButton(title: 'Next', enabled: canGoNext, action: widget.onNext),
        if (canGoNext) ...[
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            height: 25,
            child: TextField(
              controller: _pageController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onSubmitted: (_) => _onGo(),
            ),
          ),
          const SizedBox(width: 8),
          TablePageButton(title: 'GO', enabled: true, action: _onGo),
        ],
      ],
    );
  }
}

class _TablePageIndexButton extends StatelessWidget {
  const _TablePageIndexButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 25,
      child: OutlinedButton(
        onPressed: isActive ? null : onTap,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            isActive ? primary : Colors.grey.shade200,
          ),
          foregroundColor: MaterialStateProperty.all(blue),
          side: MaterialStateProperty.resolveWith<BorderSide>((states) {
            return BorderSide(color: grey, width: 0.5);
          }),
          overlayColor: MaterialStateProperty.all(blue.withOpacity(0.1)),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          minimumSize: MaterialStateProperty.all(const Size(35, 25)),
          padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 10)),
        ),
        child: HighlightText(
          label,
          style: TextStyle(
            fontSize: 12,
            height: 1.25,
            fontWeight: FontWeight.w500,
            color: isActive ? white : black,
          ),
        ),
      ),
    );
  }
}

class TablePageButton extends StatelessWidget {
  const TablePageButton({
    super.key,
    required this.title,
    required this.enabled,
    this.action,
  });
  final String title;
  final bool enabled;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 25,
      child: OutlinedButton(
        onPressed: enabled ? action : null,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            enabled ? Colors.grey.shade100 : Colors.grey.shade200,
          ),
          foregroundColor: MaterialStateProperty.all(blue),
          side: MaterialStateProperty.resolveWith<BorderSide>((states) {
            return BorderSide(color: grey, width: 0.5);
          }),
          overlayColor: MaterialStateProperty.all(blue.withOpacity(0.1)),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 6)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            HighlightText(
              title,
              style: TextStyle(
                fontSize: 12,
                height: 1.25,
                fontWeight: FontWeight.w500,
                color: enabled ? Colors.grey.shade700 : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
