import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/fetchBlocs/fetch_sports_book_bloc.dart';
import '../../../model/sports_book_model.dart';
import '../../../reusable/button.dart';
import '../../../reusable/calender.dart';
import '../../../reusable/colors.dart';
import '../../../reusable/formatters.dart';
import '../../../reusable/loader.dart';
import '../../../reusable/custom_table.dart';
import '../../../reusable/sized_box_hw.dart';
import '../../../reusable/snack_bar.dart';
import 'balance_log_screen.dart';

class SbBalanceLogScreen extends StatefulWidget {
  const SbBalanceLogScreen({super.key});

  @override
  State<SbBalanceLogScreen> createState() => _SbBalanceLogScreenState();
}

class _SbBalanceLogScreenState extends State<SbBalanceLogScreen> {
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();

  int currentPage = 1;
  int totalPages = 1;
  bool isLoading = false;
  final Map<int, List<SportsBookModel>> _pageCache = <int, List<SportsBookModel>>{};

  void fetchSbBalanceHistory({int page = 1}) {
    if (userIdController.text.isEmpty) {
      showSnackBar(context, "userId is blank.", error: true);
      return;
    }

    setState(() {
      currentPage = page;
      isLoading = true;
      if (page == 1) {
        _pageCache.clear();
      }
    });
    validateAndSwapDates(fromDateController, toDateController);
    final from = fromToDateTimeString(fromDateController.text, startOfDay: true);
    final to = fromToDateTimeString(toDateController.text, startOfDay: false);
    final Map<String, dynamic> body = {"userName": userIdController.text, 'status': "filled", "from": from, "to": to, "page": page, "limit": 10};
    context.read<FetchSportsBookBloc>().add(FetchSportsBook(body: body));
  }

  void fetchPage(int page) {
    final int safePage = page < 1 ? 1 : page;
    if (totalPages != 0 && safePage > totalPages) return;
    if (_pageCache.containsKey(safePage)) {
      setState(() => currentPage = safePage);
      return;
    }
    fetchSbBalanceHistory(page: safePage);
  }

  @override
  void dispose() {
    userIdController.dispose();
    fromDateController.dispose();
    toDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// FILTER SECTION
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: accountStatementHeaderBg,
            border: Border(bottom: BorderSide(color: borderColor)),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              hb10,

              /// FILTERS
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  /// USER ID
                  RowTFF(title: '*userId:', controller: userIdController, hintText: "enter userId..."),

                  /// DATE FILTER
                  PeriodFilterCard(fromDateController: fromDateController, toDateController: toDateController),

                  /// SUBMIT
                  CustomECTAButton(
                    title: 'Submit',
                    action: () {
                      currentPage = 1; // Reset to first page on new search
                      fetchSbBalanceHistory(page: 1);
                    },
                  ),
                ],
              ),
              hb10,
            ],
          ),
        ),

        hb10,
        BlocConsumer<FetchSportsBookBloc, FetchSportsBookState>(
          listener: (context, state) {
            if (state is FetchSportsBookSuccess) {
              setState(() {
                totalPages = state.sportsBookResponse.totalPages < 1 ? 1 : state.sportsBookResponse.totalPages;
                currentPage = state.sportsBookResponse.page < 1 ? 1 : state.sportsBookResponse.page;
                _pageCache[state.sportsBookResponse.page] = state.sportsBookResponse.data;
                isLoading = false;
              });
            }

            if (state is FetchSportsBookFailure) {
              setState(() {
                isLoading = false;
              });
            }
          },
          builder: (context, state) {
            if (state is FetchSportsBookProgress || isLoading) {
              return const LoaderContainerWithMessage(message: "Loading...");
            }

            final List<SportsBookModel> logs = _pageCache[currentPage] ?? [];

            return CustomPaginatedTable<SportsBookModel>(
              topPadding: 10,
              columns: sbBalanceLogColumns,
              data: logs,
              currentPage: currentPage,
              totalPages: totalPages,
              onPageTap: fetchPage,
              onPrevious: () {
                if (currentPage <= 1) return;
                fetchPage(currentPage - 1);
              },
              onNext: () {
                if (currentPage >= totalPages) return;
                fetchPage(currentPage + 1);
              },
            );
          },
        ),
      ],
    );
  }
}
