import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/web.dart' as html;

import '../../../../bloc/fetchBlocs/fetch_bm_book_bloc.dart';
import '../../../../model/bm_book_model.dart';
import '../../../../reusable/colors.dart';
import '../../../../reusable/loader.dart';
import '../../../../router/route_paths.dart';
import 'event_pl_tile.dart';

class EventBookView extends StatefulWidget {
  const EventBookView({super.key, required this.eventName, required this.eventType, required this.marketId, required this.userName});
  final String eventName;
  final String eventType;
  final String marketId;
  final String userName;
  @override
  State<EventBookView> createState() => _EventBookViewState();
}

class _EventBookViewState extends State<EventBookView> {
  @override
  void initState() {
    context.read<FetchBMBookBloc>().add(FetchBMBook(marketId: widget.marketId, userName: widget.userName));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF3F3F3),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: 1200,
          height: 650,
          decoration: BoxDecoration(
            color: white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Column(
            children: [
              // Header Bar
              BookHeaderBar(eventName: widget.eventName, eventType: widget.eventType),

              // Table Layout
              Expanded(
                child: BlocBuilder<FetchBMBookBloc, FetchBMBookState>(
                  builder: (context, fbs) {
                    if (fbs is FetchBMBookProgress) {
                      return const LoaderContainerWithMessage();
                    }

                    List<BMBookData> book = [];
                    if (fbs is FetchBMBookSuccess) {
                      book = fbs.bmBook;
                    }

                    return BookTableLayout(
                      book: book,
                      onRowTap: (e) {
                        final hasMa = e.upLines.any((u) => u.title.trim().toUpperCase() == 'MA');
                        final baseUrl = html.window.location.origin;
                        if (hasMa) {
                          final storageKey = 'user-report-upline-${e.name}';
                          final uplineJson = jsonEncode(e.upLines.map((u) => {'name': u.name, 'title': u.title}).toList());
                          html.window.localStorage[storageKey] = uplineJson;
                          final url = '$baseUrl${RoutePaths.manageUserReport}?userName=${eqc(e.name)}';
                          html.window.open(url, '_blank', 'width=1200,height=850,resizable=yes,scrollbars=yes,menubar=no,toolbar=no,location=no,status=no');
                          return;
                        }
                        final url =
                            '$baseUrl${RoutePaths.manageEventBookView}?eventName=${eqc(widget.eventName)}&eventType=${eqc(widget.eventType)}&marketId=${eqc(widget.marketId)}&userName=${eqc(e.name)}';
                        html.window.open(url, '_blank', 'width=1200,height=650,resizable=yes,scrollbars=yes,menubar=no,toolbar=no,location=no,status=no');
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
