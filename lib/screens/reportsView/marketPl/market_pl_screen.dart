import 'package:web/web.dart' as html;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/fetchBlocs/fetch_market_pl_bloc.dart';
import '../../../model/market_pl_model.dart';
import '../../../reusable/button.dart';
import '../../../reusable/calender.dart';
import '../../../reusable/colors.dart';
import '../../../reusable/formatters.dart';
import '../../../reusable/highlighted_text_widget.dart';
import '../../../reusable/loader.dart';
import '../../../reusable/sized_box_hw.dart';
import '../../../reusable/snack_bar.dart';
import '../../logView/agencyLogHistory/balance_log_screen.dart';
import '../../riskView/riskManagement/riskManagementWidgets/risk_management_custom_widget.dart';
import '../../../router/route_paths.dart';

class MarketPlScreen extends StatefulWidget {
  const MarketPlScreen({super.key});

  @override
  State<MarketPlScreen> createState() => _MarketPlScreenState();
}

class _MarketPlScreenState extends State<MarketPlScreen> {
  TextEditingController userIdController = TextEditingController();
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();

  final GlobalKey<_MarketPlTableState> marketPlTableKey = GlobalKey<_MarketPlTableState>();

  @override
  void initState() {
    context.read<FetchMarketPlBloc>().add(FetchMarketPlInt());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return SizedBox(
      width: size.width,
      height: size.height,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RiskHeader(type: 1, title: "Market Profit/Loss"),
              hb10,
              RowTFF(controller: userIdController, hintText: "Enter userId..."),
              hb10,
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: accountStatementHeaderBg,
                  border: Border(bottom: BorderSide(color: borderColor)),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PeriodFilterCard(fromDateController: fromDateController, toDateController: toDateController),
                    hb20,
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        CustomOCTAButton(
                          title: 'Just For Today',
                          action: () {
                            final now = DateTime.now();
                            final dateText = now.toIso8601String().split('T').first;
                            fromDateController.text = dateText;
                            toDateController.text = dateText;
                            final from = fromToDateTimeString(now.toIso8601String(), startOfDay: true);
                            final to = fromToDateTimeString(now.toIso8601String(), startOfDay: false);
                            context.read<FetchMarketPlBloc>().add(FetchMarketPl(fromDate: from, toDate: to, userName: userIdController.text.trim()));
                          },
                        ),
                        CustomOCTAButton(
                          title: 'From Yesterday',
                          action: () {
                            final now = DateTime.now();
                            final yesterday = now.subtract(const Duration(days: 1));
                            final fromText = yesterday.toIso8601String().split('T').first;
                            final toText = now.toIso8601String().split('T').first;
                            fromDateController.text = fromText;
                            toDateController.text = toText;
                            final from = fromToDateTimeString(yesterday.toIso8601String(), startOfDay: true);
                            final to = fromToDateTimeString(now.toIso8601String(), startOfDay: false);
                            context.read<FetchMarketPlBloc>().add(FetchMarketPl(fromDate: from, toDate: to, userName: userIdController.text.trim()));
                          },
                        ),
                        CustomECTAButton(
                          title: 'Get History',
                          action: () {
                            validateAndSwapDates(fromDateController, toDateController);
                            final fromDate = fromToDateTimeString(fromDateController.text, startOfDay: true);
                            final toDate = fromToDateTimeString(toDateController.text, startOfDay: false);
                            context.read<FetchMarketPlBloc>().add(FetchMarketPl(fromDate: fromDate, toDate: toDate, userName: userIdController.text.trim()));
                          },
                        ),
                      ],
                    ),
                    hb20,
                  ],
                ),
              ),

              /// table
              BlocBuilder<FetchMarketPlBloc, FetchMarketPlState>(
                builder: (context, mps) {
                  List<MarketPlData> marketPl = [];
                  String? searchedUser;
                  if (mps is FetchMarketPlSuccess) {
                    marketPl = mps.marketPl;
                    searchedUser = mps.searchedUser;
                  }
                  return mps is FetchMarketPlProgress
                      ? const LoaderContainerWithMessage(message: "Loading...")
                      : marketPl.isEmpty
                      ? const SizedBox.shrink()
                      : MarketPlTable(
                          key: marketPlTableKey,
                          marketPlData: marketPl,
                          searchedUser: searchedUser,
                          onUserSelected: (username) {
                            final baseUrl = html.window.location.origin;
                            final url = '$baseUrl${RoutePaths.manageProfitLoss}?userName=${eqc(username)}';
                            html.window.open(url, '_blank');
                          },
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MarketPlTable extends StatefulWidget {
  final List<MarketPlData> marketPlData;
  final String? searchedUser;
  final void Function(String username)? onUserSelected;

  const MarketPlTable({super.key, this.onUserSelected, required this.marketPlData, this.searchedUser});

  @override
  State<MarketPlTable> createState() => _MarketPlTableState();
}

class _MarketPlTableState extends State<MarketPlTable> {
  // Flex values for different column types
  Map<String, int> columnFlex = {'UserName': 3, 'Site': 3, 'Stake': 2, 'All Stake': 2, 'Win': 3, 'Loss': 2, 'Win/Loss': 2, 'Comm': 1, 'Total P/L': 2};

  // Role to columns mapping
  final Map<String, Map<String, String>> roleToColumns = {
    'INR': {'username': 'UserName', 'site': 'Site', 'stake': 'Stake', 'allStake': 'All Stake', 'win': 'Win', 'loss': 'Loss'},
    'P': {'winLoss': 'Win/Loss', 'commission': 'Comm', 'totalPnl': 'Total P/L'},
    'MA': {'maWinLoss': 'Win/Loss', 'maComm': 'Comm'},
    'SUP': {'supWinLoss': 'Win/Loss', 'supComm': 'Comm'},
    'SS': {'ssWinLoss': 'Win/Loss', 'ssComm': 'Comm'},
    'WL': {'wlWinLoss': 'Win/Loss', 'wlComm': 'Comm'},
  };

  final Map<String, Color> roleColors = {
    'INR': Colors.white,
    'P': const Color(0xfffec556),
    'MA': const Color(0xff1589de),
    'SUP': const Color(0xff8ec03d),
    'SS': const Color(0xff7cb8e7),
    'WL': const Color(0xffc9a227),
  };

  // State variables
  late List<String> hierarchyHeaders;
  late Set<String> expandedSportRows;
  late List<MarketPlData> currentRows;
  late List<MarketPlData> hierarchyPath;
  late Set<String> hiddenRoles;

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  void _initializeState() {
    hierarchyHeaders = ['INR'];
    expandedSportRows = {};
    hierarchyPath = [];
    hiddenRoles = {};
    currentRows = widget.marketPlData;

    _collectRoles(widget.marketPlData);
    hierarchyHeaders = ['INR', ...hierarchyHeaders.sublist(1).reversed];
    // Automatically expand to searchedUser
    if (widget.searchedUser != null && widget.searchedUser!.isNotEmpty) {
      final path = _findUserPath(widget.searchedUser!, widget.marketPlData);
      if (path != null) {
        hierarchyPath = path.sublist(0, path.length - 1);
        currentRows = [path.last];
        hiddenRoles.clear();
        for (var row in hierarchyPath) {
          hiddenRoles.add(row.userRole);
        }
        if (path.last.sportWise.isNotEmpty) {
          expandedSportRows.add(path.last.username);
        }
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showSnackBar(context, 'User "${widget.searchedUser}" not found!', error: true);
        });
      }
    }
  }

  @override
  void didUpdateWidget(MarketPlTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.marketPlData != widget.marketPlData) {
      _initializeState();
    }
  }

  // Public method to restore state
  void restoreState(List<String> savedExpandedRows, List<MarketPlData> savedPath, Set<String> savedHidden) {
    setState(() {
      expandedSportRows = Set.from(savedExpandedRows);
      hierarchyPath = List.from(savedPath);
      hiddenRoles = Set.from(savedHidden);

      if (hierarchyPath.isNotEmpty) {
        currentRows = hierarchyPath.last.childs;
      } else {
        currentRows = widget.marketPlData;
      }
    });
  }

  // Helper methods
  void _collectRoles(List<MarketPlData> data) {
    for (var item in data) {
      if (!hierarchyHeaders.contains(item.userRole)) {
        hierarchyHeaders.add(item.userRole);
      }
      if (item.childs.isNotEmpty) {
        _collectRoles(item.childs);
      }
    }
  }

  List<MarketPlData>? _findUserPath(String username, List<MarketPlData> data) {
    for (var item in data) {
      if (item.username == username) return [item];
      if (item.childs.isNotEmpty) {
        final childPath = _findUserPath(username, item.childs);
        if (childPath != null) return [item, ...childPath];
      }
    }
    return null;
  }

  // Get flex value for a column
  int _getColumnFlex(String displayName) {
    return columnFlex[displayName] ?? 2;
  }

  String getRole(String roleCode) {
    switch (roleCode.toUpperCase()) {
      case 'INR':
        return 'INR';
      case 'P':
        return 'Player';
      case 'MA':
        return 'Master Agent';
      case 'SUP':
        return 'Super';
      case 'SS':
        return 'Senior Super';
      case 'WL':
        return 'White Label';
      default:
        return 'Unknown Role';
    }
  }

  Color resolveColor(dynamic value) {
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.startsWith('(') && trimmed.endsWith(')')) {
        return Colors.red;
      }
      final numeric = double.tryParse(trimmed.replaceAll(',', ''));
      if (numeric != null) {
        return numeric < 0 ? Colors.red : Colors.black;
      }
    } else if (value is num) {
      return value < 0 ? Colors.red : Colors.black;
    }
    return Colors.black;
  }

  void _drillDown(MarketPlData row) {
    if (row.childs.isEmpty) {
      showSnackBar(context, "This is a User. No further hierarchy.");
      return;
    }
    setState(() {
      hierarchyPath.add(row);
      currentRows = row.childs;
      hiddenRoles.add(row.userRole);
    });
  }

  void _onChipTap(int index) {
    setState(() {
      if (index == 0) {
        hierarchyPath.clear();
        currentRows = widget.marketPlData;
        hiddenRoles.clear();
      } else {
        hierarchyPath = hierarchyPath.sublist(0, index);
        currentRows = hierarchyPath.last.childs;
        hiddenRoles.clear();
        for (var row in hierarchyPath) {
          hiddenRoles.add(row.userRole);
        }
      }
    });
  }

  void _toggleSportExpand(String username) {
    setState(() {
      expandedSportRows.contains(username) ? expandedSportRows.remove(username) : expandedSportRows.add(username);
    });
  }

  // Value getters
  String _getValueByFieldKey(MarketPlData row, String fieldKey) {
    switch (fieldKey) {
      case 'username':
        return row.username;
      case 'site':
        return row.site;
      case 'stake':
      case 'allStake':
        return formattedAmounts(row.stake);
      case 'win':
        return formattedAmounts(row.win);
      case 'loss':
        return formattedAmounts(row.loss);
      case 'winLoss':
        return formattedAmounts(row.winLoss);
      case 'commission':
        return formattedAmounts(row.commission);
      case 'totalPnl':
        return formattedAmounts(row.totalPnl);
      case 'maWinLoss':
        return formattedAmounts(row.maAgent.winLoss);
      case 'maComm':
        return formattedAmounts(row.maAgent.comm);
      case 'supWinLoss':
        return formattedAmounts(row.supAgent.winLoss);
      case 'supComm':
        return formattedAmounts(row.supAgent.comm);
      case 'ssWinLoss':
        return formattedAmounts(row.ssAgent.winLoss);
      case 'ssComm':
        return formattedAmounts(row.ssAgent.comm);
      case 'wlWinLoss':
        return formattedAmounts(row.wlAgent.winLoss);
      case 'wlComm':
        return formattedAmounts(row.wlAgent.comm);
      default:
        return '0';
    }
  }

  String _getSportValueByFieldKey(SportWiseModel sport, String fieldKey) {
    switch (fieldKey) {
      case 'username':
        return sport.sportName;
      case 'site':
        return sport.site;
      case 'stake':
      case 'allStake':
        return formattedAmounts(sport.stake);
      case 'win':
        return formattedAmounts(sport.win);
      case 'loss':
        return formattedAmounts(sport.loss);
      case 'winLoss':
        return formattedAmounts(sport.winLoss);
      case 'commission':
        return formattedAmounts(sport.commission);
      case 'totalPnl':
        return formattedAmounts(sport.totalPnl);
      case 'maWinLoss':
        return formattedAmounts(sport.maAgent.winLoss);
      case 'maComm':
        return formattedAmounts(sport.maAgent.comm);
      case 'supWinLoss':
        return formattedAmounts(sport.supAgent.winLoss);
      case 'supComm':
        return formattedAmounts(sport.supAgent.comm);
      case 'ssWinLoss':
        return formattedAmounts(sport.ssAgent.winLoss);
      case 'ssComm':
        return formattedAmounts(sport.ssAgent.comm);
      case 'wlWinLoss':
        return formattedAmounts(sport.wlAgent.winLoss);
      case 'wlComm':
        return formattedAmounts(sport.wlAgent.comm);
      default:
        return '0';
    }
  }

  // Generate flat headers based on visible roles
  List<Map<String, String>> _getVisibleHeaders() {
    final List<Map<String, String>> headers = [];
    for (var role in hierarchyHeaders) {
      if (!hiddenRoles.contains(role) && roleToColumns.containsKey(role)) {
        roleToColumns[role]!.forEach((fieldKey, displayName) {
          headers.add({'fieldKey': fieldKey, 'displayName': displayName, 'role': role});
        });
      }
    }
    return headers;
  }

  @override
  Widget build(BuildContext context) {
    final visibleHeaders = _getVisibleHeaders();

    if (currentRows.isEmpty || visibleHeaders.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MarketPlBreadcrumb(hierarchyPath: hierarchyPath, onChipTap: _onChipTap),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarketPlTableHeader(hierarchyHeaders: hierarchyHeaders, hiddenRoles: hiddenRoles, roleToColumns: roleToColumns, getColumnFlex: _getColumnFlex, getRole: getRole),
            MarketPlColumnHeader(visibleHeaders: visibleHeaders, getColumnFlex: _getColumnFlex),
            MarketPlTableBody(
              data: currentRows,
              headers: visibleHeaders,
              expandedSportRows: expandedSportRows,
              roleColors: roleColors,
              getColumnFlex: _getColumnFlex,
              getValueByFieldKey: _getValueByFieldKey,
              getSportValueByFieldKey: _getSportValueByFieldKey,
              resolveColor: resolveColor,
              onNameTap: _onRowNameTap,
              onToggleSportExpand: _toggleSportExpand,
              sumField: (fieldKey) => _sumField(currentRows, fieldKey),
            ),
          ],
        ),
      ],
    );
  }

  void _onRowNameTap(MarketPlData row) {
    if (row.userRole == 'P') {
      if (widget.onUserSelected != null) {
        widget.onUserSelected!(row.username);
      }
    } else {
      _drillDown(row);
    }
  }

  double _sumField(List<MarketPlData> data, String fieldKey) {
    double total = 0;
    for (var row in data) {
      switch (fieldKey) {
        case 'stake':
          total += row.stake;
          break;
        case 'allStake':
          total += row.stake;
          break;
        case 'win':
          total += row.win;
          break;
        case 'loss':
          total += row.loss;
          break;
        case 'winLoss':
          total += row.winLoss;
          break;
        case 'commission':
          total += row.commission;
          break;
        case 'totalPnl':
          total += row.totalPnl;
          break;
        case 'maWinLoss':
          total += row.maAgent.winLoss;
          break;
        case 'maComm':
          total += row.maAgent.comm;
          break;
        case 'supWinLoss':
          total += row.supAgent.winLoss;
          break;
        case 'supComm':
          total += row.supAgent.comm;
          break;
        case 'ssWinLoss':
          total += row.ssAgent.winLoss;
          break;
        case 'ssComm':
          total += row.ssAgent.comm;
          break;
        case 'wlWinLoss':
          total += row.wlAgent.winLoss;
          break;
        case 'wlComm':
          total += row.wlAgent.comm;
          break;
        default:
          break;
      }
    }
    return total;
  }
}

class MarketPlBreadcrumb extends StatelessWidget {
  final List<MarketPlData> hierarchyPath;
  final void Function(int) onChipTap;

  const MarketPlBreadcrumb({super.key, required this.hierarchyPath, required this.onChipTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Wrap(
        spacing: 4,
        children: [
          ActionChip(
            label: const RoleBreadcrumb(role: 'COM', name: 'ONE'),
            onPressed: () => onChipTap(0),
          ),
          ...List.generate(hierarchyPath.length, (index) {
            final row = hierarchyPath[index];
            return ActionChip(
              label: RoleBreadcrumb(role: row.userRole, name: row.username),
              onPressed: () => onChipTap(index + 1),
            );
          }),
        ],
      ),
    );
  }
}

class MarketPlTableHeader extends StatelessWidget {
  final List<String> hierarchyHeaders;
  final Set<String> hiddenRoles;
  final Map<String, Map<String, String>> roleToColumns;
  final int Function(String) getColumnFlex;
  final String Function(String) getRole;

  const MarketPlTableHeader({
    super.key,
    required this.hierarchyHeaders,
    required this.hiddenRoles,
    required this.roleToColumns,
    required this.getColumnFlex,
    required this.getRole,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: const BoxDecoration(
        color: Color(0xFFE4E4E4),
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: hierarchyHeaders.where((role) => !hiddenRoles.contains(role)).map((role) {
          var totalFlex = 0;
          if (roleToColumns.containsKey(role)) {
            for (var column in roleToColumns[role]!.values) {
              totalFlex += getColumnFlex(column);
            }
          }
          return Expanded(
            flex: totalFlex,
            child: Container(
              height: 32,
              alignment: Alignment.center,
              child: HighlightText(
                getRole(role),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: headerTextColor),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class MarketPlColumnHeader extends StatelessWidget {
  final List<Map<String, String>> visibleHeaders;
  final int Function(String) getColumnFlex;

  const MarketPlColumnHeader({super.key, required this.visibleHeaders, required this.getColumnFlex});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: const BoxDecoration(
        color: Color(0xFFE4E4E4),
        border: Border(
          bottom: BorderSide(color: borderColor),
          top: BorderSide(color: borderColor),
        ),
      ),
      child: Row(
        children: visibleHeaders.map((header) {
          return Expanded(
            flex: getColumnFlex(header['displayName']!),
            child: Container(
              height: 32,
              alignment: Alignment.center,
              child: HighlightText(
                header['displayName']!,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, height: 1.25, color: headerTextColor),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class MarketPlTableBody extends StatelessWidget {
  final List<MarketPlData> data;
  final List<Map<String, String>> headers;
  final Set<String> expandedSportRows;
  final Map<String, Color> roleColors;
  final int Function(String) getColumnFlex;
  final String Function(MarketPlData, String) getValueByFieldKey;
  final String Function(SportWiseModel, String) getSportValueByFieldKey;
  final Color Function(dynamic) resolveColor;
  final void Function(MarketPlData) onNameTap;
  final void Function(String) onToggleSportExpand;
  final double Function(String) sumField;

  const MarketPlTableBody({
    super.key,
    required this.data,
    required this.headers,
    required this.expandedSportRows,
    required this.roleColors,
    required this.getColumnFlex,
    required this.getValueByFieldKey,
    required this.getSportValueByFieldKey,
    required this.resolveColor,
    required this.onNameTap,
    required this.onToggleSportExpand,
    required this.sumField,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...data.map((row) {
          return MarketPlDataRow(
            row: row,
            headers: headers,
            expandedSportRows: expandedSportRows,
            roleColors: roleColors,
            getColumnFlex: getColumnFlex,
            getValueByFieldKey: getValueByFieldKey,
            getSportValueByFieldKey: getSportValueByFieldKey,
            resolveColor: resolveColor,
            onNameTap: onNameTap,
            onToggleSportExpand: onToggleSportExpand,
          );
        }),
        MarketPlFooterRow(headers: headers, sumField: sumField, getColumnFlex: getColumnFlex, resolveColor: resolveColor),
      ],
    );
  }
}

class MarketPlDataRow extends StatelessWidget {
  final MarketPlData row;
  final List<Map<String, String>> headers;
  final Set<String> expandedSportRows;
  final Map<String, Color> roleColors;
  final int Function(String) getColumnFlex;
  final String Function(MarketPlData, String) getValueByFieldKey;
  final String Function(SportWiseModel, String) getSportValueByFieldKey;
  final Color Function(dynamic) resolveColor;
  final void Function(MarketPlData) onNameTap;
  final void Function(String) onToggleSportExpand;

  const MarketPlDataRow({
    super.key,
    required this.row,
    required this.headers,
    required this.expandedSportRows,
    required this.roleColors,
    required this.getColumnFlex,
    required this.getValueByFieldKey,
    required this.getSportValueByFieldKey,
    required this.resolveColor,
    required this.onNameTap,
    required this.onToggleSportExpand,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 32,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: headers.map((header) {
              final fieldKey = header['fieldKey']!;
              final displayName = header['displayName']!;
              final role = header['role']!;
              final value = getValueByFieldKey(row, fieldKey);
              final isUserName = displayName == 'UserName';

              return Expanded(
                flex: getColumnFlex(displayName),
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  alignment: isUserName ? Alignment.centerLeft : Alignment.center,
                  color: roleColors[role],
                  child: isUserName
                      ? Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => onNameTap(row),
                                child: HighlightText(
                                  value,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    height: 1.25,
                                    decoration: TextDecoration.underline,
                                    decorationColor: blue,
                                    color: blue,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            if (row.sportWise.isNotEmpty)
                              InkWell(
                                onTap: () => onToggleSportExpand(row.username),
                                child: Icon(expandedSportRows.contains(row.username) ? Icons.indeterminate_check_box_outlined : Icons.add_box_outlined, size: 16),
                              ),
                          ],
                        )
                      : HighlightText(
                          value,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12, height: 1.25, color: resolveColor(value)),
                        ),
                ),
              );
            }).toList(),
          ),
        ),
        if (expandedSportRows.contains(row.username))
          Column(
            children: row.sportWise.map((sport) {
              return MarketPlSportRow(sport: sport, headers: headers, getColumnFlex: getColumnFlex, getSportValueByFieldKey: getSportValueByFieldKey, resolveColor: resolveColor);
            }).toList(),
          ),
      ],
    );
  }
}

class MarketPlSportRow extends StatelessWidget {
  final SportWiseModel sport;
  final List<Map<String, String>> headers;
  final int Function(String) getColumnFlex;
  final String Function(SportWiseModel, String) getSportValueByFieldKey;
  final Color Function(dynamic) resolveColor;

  const MarketPlSportRow({super.key, required this.sport, required this.headers, required this.getColumnFlex, required this.getSportValueByFieldKey, required this.resolveColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xffe1f9c3),
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: headers.map((header) {
          final value = getSportValueByFieldKey(sport, header['fieldKey']!);
          return Expanded(
            flex: getColumnFlex(header['displayName']!),
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.center,
              child: HighlightText(
                value,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12, height: 1.25, color: resolveColor(value)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class MarketPlFooterRow extends StatelessWidget {
  final List<Map<String, String>> headers;
  final double Function(String) sumField;
  final int Function(String) getColumnFlex;
  final Color Function(dynamic) resolveColor;

  const MarketPlFooterRow({super.key, required this.headers, required this.sumField, required this.getColumnFlex, required this.resolveColor});

  @override
  Widget build(BuildContext context) {
    final totals = <String, double>{};
    for (var header in headers) {
      totals[header['fieldKey']!] = sumField(header['fieldKey']!);
    }

    return Container(
      height: 32,
      decoration: const BoxDecoration(
        color: Color(0xFFFFF4B0),
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: headers.map((header) {
          final fieldKey = header['fieldKey']!;
          final displayName = header['displayName']!;
          final isSite = displayName == 'Site';
          final value = displayName == 'UserName'
              ? ''
              : isSite
              ? 'Grand Total'
              : formattedAmounts(totals[fieldKey] ?? 0);

          return Expanded(
            flex: getColumnFlex(displayName),
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.center,
              child: HighlightText(
                value,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12, height: 1.25, color: resolveColor(value)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class RoleBreadcrumb extends StatelessWidget {
  const RoleBreadcrumb({super.key, required this.role, required this.name});
  final String role, name;
  @override
  Widget build(BuildContext context) {
    Color getRoleBreadcrumbColor(String role) {
      switch (role.toUpperCase()) {
        case 'SS':
          return Colors.purple;
        case 'SUP':
          return Colors.blue;
        case 'MA':
          return Colors.green;
        case 'COM':
          return Colors.orange;
        case 'WL':
          return Color(0xffc9a227);
        default:
          return Colors.grey;
      }
    }

    Color color = getRoleBreadcrumbColor(role);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color),
          ),
          child: HighlightText(
            role.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
          ),
        ),
        const SizedBox(width: 6),
        HighlightText(
          name,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: Colors.black87),
        ),
      ],
    );
  }
}
