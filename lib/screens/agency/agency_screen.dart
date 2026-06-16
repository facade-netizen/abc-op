import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/fetchBlocs/fetch_lt_report_bloc.dart';
import '../../reusable/snack_bar.dart';
import '../../bloc/authBlocs/update_user_access_bloc.dart';
import '../../bloc/fetchBlocs/fetch_agency_bloc.dart';
import '../../model/agency_model.dart';
import '../../reusable/button.dart';
import '../../reusable/colors.dart';
import '../../reusable/highlighted_text_widget.dart';
import '../../reusable/loader.dart';
import '../../reusable/sized_box_hw.dart';
import '../../reusable/style.dart';
import '../reportsView/profitAndLoss/profit_and_loss_widgets.dart';
import '../riskView/riskManagement/riskManagementWidgets/risk_management_custom_widget.dart';
import '../riskView/riskMonitoring/row_dropdown.dart';
import 'sports_wise_table.dart';
import 'user_details_table.dart';

class AgencyScreen extends StatefulWidget {
  const AgencyScreen({super.key});

  @override
  State<AgencyScreen> createState() => _AgencyScreenState();
}

class _AgencyScreenState extends State<AgencyScreen> {
  final TextEditingController userIdController = TextEditingController();

  /// USER LEVEL
  final Map<String, String> userLevelMap = {"All": "", "Senior Super": "supersuperAdmin", "Super": "superAdmin", "Master Agent": "master", "Player": "client"};

  /// USER FILTER STATUS
  final List<String> userFilterType = ["UserId", "LastName"];

  String selectedUserLevel = "All";
  String selectedUserFilter = "UserId";

  // Helper getters
  String get _searchHint => "Enter ${selectedUserFilter.toLowerCase()}...";
  String get _searchValue => userIdController.text.trim();
  bool get _isSearchValid => _searchValue.isNotEmpty;

  Map<String, dynamic> get _searchBody => {"role": userLevelMap[selectedUserLevel], "userName": _searchValue.isEmpty ? null : _searchValue};

  void _performSearch() {
    if (_isSearchValid) {
      context.read<FetchAgencyBloc>().add(FetchAgency(body: _searchBody));
    } else {
      showSnackBar(context, '$selectedUserFilter is blank.', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    return BlocConsumer<UpdateUserAccessBloc, UpdateUserAccessState>(
      listener: (context, uas) {
        if (uas is UpdateUserAccessSuccess && _isSearchValid) {
          context.read<FetchAgencyBloc>().add(FetchAgency(body: _searchBody));
        }
      },
      builder: (context, uas) {
        return BlocBuilder<FetchLtReportBloc, FetchLtReportState>(
          builder: (context, lts) {
            return BlocBuilder<FetchAgencyBloc, FetchAgencyState>(
              builder: (context, fas) {
                List<AgencyModel> agency = [];
                if (fas is FetchAgencySuccess) {
                  agency = fas.agency;
                }
                return Stack(
                  children: [
                    SizedBox(
                      width: size.width,
                      height: size.height,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const RiskHeader(type: 1, title: "Agency"),

                              /// FILTER SECTION
                              Container(
                                decoration: BoxDecoration(
                                  color: accountStatementHeaderBg,
                                  border: const Border(bottom: BorderSide(color: borderColor)),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// USER LEVEL
                                    RowDropdown<String>(
                                      title: 'User Level',
                                      value: selectedUserLevel,
                                      items: userLevelMap.keys.toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() => selectedUserLevel = value);
                                        }
                                      },
                                    ),
                                    hb15,

                                    Wrap(
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: [
                                        /// USER STATUS
                                        RowDropdown<String>(
                                          value: selectedUserFilter,
                                          items: userFilterType,
                                          onChanged: (value) {
                                            if (value != null) {
                                              setState(() => selectedUserFilter = value);
                                            }
                                          },
                                        ),

                                        /// USER ID
                                        SizedBox(
                                          width: 500,
                                          child: TextFormField(
                                            controller: userIdController,
                                            onFieldSubmitted: (_) => _performSearch(),
                                            textAlignVertical: TextAlignVertical.center,
                                            decoration: tfInputDecoration.copyWith(hintText: _searchHint, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12)),
                                          ),
                                        ),
                                        CustomECTAButton(title: 'Search', action: _performSearch),

                                        HighlightText('Last Search Date : ${DateTime.now()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    hb10,
                                    const Heading(
                                      '1. "UserId" or "LastName" is a required search criteria. Please make sure to fill in one before proceeding with the search.',
                                      isBold: false,
                                    ),
                                    const Heading(
                                      '2. Please enter "UserId" or "LastName" separated by commas. You can search for a maximum of 100 "UserId" or "LastName" at once.',
                                      isBold: false,
                                    ),
                                    hb10,
                                  ],
                                ),
                              ),
                              hb10,

                              /// BLOC TABLE DATA
                              UserDataTableScreen(agency: agency, key: ValueKey(agency.length)),
                              hb10,
                              if (agency.isNotEmpty) ...[const SportsWiseTable(), hb10],
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (uas is UpdateUserAccessProgress || lts is FetchLtReportProgress || fas is FetchAgencyProgress)
                      Positioned.fill(
                        child: Center(child: LoaderContainerWithMessage(message: "Loading...")),
                      ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
