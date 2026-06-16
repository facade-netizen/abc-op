import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/fetchBlocs/fetch_betlist_live_bloc.dart';
import '../../../model/bet_list_model.dart';
import '../../../reusable/colors.dart';
import '../../../reusable/custom_table.dart';
import '../../../reusable/highlighted_text_widget.dart';
import '../../../reusable/sized_box_hw.dart';
import 'bet_list_live_filter.dart';

class TableSection extends StatelessWidget {
  final FilterState filters;
  final bool isSportsBook;
  const TableSection({super.key, required this.filters, required this.isSportsBook});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<FetchBetListLiveBloc, FetchBetListLiveState>(
          buildWhen: (previous, current) {
            if (previous is FetchBetListLiveSuccess && current is FetchBetListLiveSuccess) {
              return previous.betsList != current.betsList || previous.isLoading != current.isLoading || previous.isLoadingMore != current.isLoadingMore;
            }
            return true;
          },
          builder: (context, state) {
            final bool showSportsbookColumns = isSportsBook && state is FetchBetListLiveSuccess;

            if (filters.betStatus == 'Unmatched') {
              return Column(
                children: [
                  hb15,
                  BetListTable(bets: [], filters: filters, isSportsBook: showSportsbookColumns),
                ],
              );
            }

            return switch (state) {
              FetchBetListLiveSuccess() => BetListTable(bets: state.betsList, filters: filters, isSportsBook: showSportsbookColumns),
              _ => const SizedBox.shrink(),
            };
          },
        ),
      ],
    );
  }
}

class BetListTable extends StatelessWidget {
  final List<BetData> bets;
  final FilterState filters;
  final bool isSportsBook;
  const BetListTable({super.key, required this.bets, required this.filters, required this.isSportsBook});

  @override
  Widget build(BuildContext context) {
    if (filters.betStatus == 'Matched') {
      return Column(
        children: [BetSection(title: "Matched", data: bets, isSportsBook: isSportsBook)],
      );
    }

    if (filters.betStatus == 'Unmatched') {
      return Column(
        children: [BetSection(title: "Unmatched", data: [], isSportsBook: isSportsBook)],
      );
    }

    return Column(
      children: [
        hb15,
        BetSection(title: "Unmatched", data: [], isSportsBook: isSportsBook),
        BetSection(title: "Matched", data: bets, isSportsBook: isSportsBook),
      ],
    );
  }
}

class BetSection extends StatelessWidget {
  final String title;
  final List<BetData> data;
  final bool isSportsBook;
  final List<TableColumn<BetData>>? columns;
  const BetSection({super.key, required this.title, required this.data, this.columns, this.isSportsBook = false});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Column(
        children: [
          BllTableHeader(title: title),
          Container(height: 50, alignment: Alignment.centerLeft, color: white, child: HighlightText('You have no bets in this time period.')),
        ],
      );
    }
    return CustomTable<BetData>(
      data: data,
      columns: columns ?? betListLiveColumns(isSportsBook),
      child: BllTableHeader(title: title),
    );
  }
}

class BllTableHeader extends StatelessWidget {
  final Color? color;
  final String title;

  const BllTableHeader({super.key, this.color, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: double.infinity,
      decoration: BoxDecoration(
        color: color ?? tileOrFontColor,
        border: Border(bottom: BorderSide(color: black)),
      ),
      child: Row(
        children: [
          wb12,
          HighlightText(
            title,
            style: TextStyle(color: color != null ? black : white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
