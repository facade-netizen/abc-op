import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/fetchBlocs/fetch_cg_balance_history_bloc.dart';
import '../../../model/casino_balance_log_model.dart';
import '../../../reusable/button.dart';
import '../../../reusable/calender.dart';
import '../../../reusable/colors.dart';
import '../../../reusable/formatters.dart';
import '../../../reusable/loader.dart';
import '../../../reusable/custom_table.dart';
import '../../../reusable/sized_box_hw.dart';
import '../../../reusable/snack_bar.dart';
import 'balance_log_screen.dart';

class CasinoBalanceLogScreen extends StatefulWidget {
  const CasinoBalanceLogScreen({super.key});

  @override
  State<CasinoBalanceLogScreen> createState() => _CasinoBalanceLogScreenState();
}

class _CasinoBalanceLogScreenState extends State<CasinoBalanceLogScreen> {
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();

  int currentPage = 1;
  int totalPages = 1;
  bool isLoading = false;
  final Map<int, List<CasinoBalanceLogModel>> _pageCache = <int, List<CasinoBalanceLogModel>>{};

  void fetchCasinoBalanceHistory({int page = 1}) {
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
    final Map<String, dynamic> casinoMap = {"userName": userIdController.text, "from": from, "to": to, "page": page, "limit": 25};
    context.read<FetchCGBalanceHistoryBloc>().add(FetchCGBalanceHistory(body: casinoMap));
  }

  void fetchPage(int page) {
    final int safePage = page < 1 ? 1 : page;
    if (totalPages != 0 && safePage > totalPages) return;
    if (_pageCache.containsKey(safePage)) {
      setState(() => currentPage = safePage);
      return;
    }
    fetchCasinoBalanceHistory(page: safePage);
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
                      fetchCasinoBalanceHistory(page: 1);
                    },
                  ),
                ],
              ),
              hb10,
            ],
          ),
        ),

        hb10,
        BlocConsumer<FetchCGBalanceHistoryBloc, FetchCGBalanceHistoryState>(
          listener: (context, state) {
            if (state is FetchCGBalanceHistorySuccess) {
              setState(() {
                totalPages = state.cgBalanceHistory.totalPages < 1 ? 1 : state.cgBalanceHistory.totalPages;
                currentPage = state.cgBalanceHistory.page < 1 ? 1 : state.cgBalanceHistory.page;
                _pageCache[state.cgBalanceHistory.page] = state.cgBalanceHistory.data;
                isLoading = false;
              });
            }

            if (state is FetchCGBalanceHistoryFailure) {
              setState(() {
                isLoading = false;
              });
            }
          },
          builder: (context, state) {
            if (state is FetchCGBalanceHistoryProgress || isLoading) {
              return const LoaderContainerWithMessage(message: "Loading...");
            }

            final List<CasinoBalanceLogModel> logs = _pageCache[currentPage] ?? [];

            return CustomPaginatedTable<CasinoBalanceLogModel>(
              topPadding: 10,
              columns: casinoBalanceLogColumns,
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
