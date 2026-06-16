import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:universal_html/html.dart' as html;

import '../../bloc/authBlocs/user_logout_bloc.dart';
import '../../bloc/fetchBlocs/fetch_current_user_info_bloc.dart';
import '../../constants/app_constant.dart';
import '../../localDb/token/login_token_model.dart';
import '../../model/user_details_model.dart';
import '../bloc/fetchBlocs/fetch_all_wl_bloc.dart';
import '../bloc/fetchBlocs/fetch_balance_summary_log_bloc.dart';
import '../bloc/fetchBlocs/fetch_betlist_live_bloc.dart';
import '../bloc/fetchBlocs/fetch_lt_report_bloc.dart';
import '../bloc/fetchBlocs/fetch_open_bm_bloc.dart';
import '../bloc/fetchBlocs/fetch_open_fancy_bloc.dart';
import '../bloc/fetchBlocs/fetch_open_odds_bloc.dart';
import '../bloc/fetchBlocs/fetch_open_premium_sport_bloc.dart';
import '../bloc/fetchBlocs/fetch_order_event_bloc.dart';
import '../bloc/fetchBlocs/fetch_player_bet_history_bloc.dart';
import '../bloc/fetchBlocs/fetch_risk_monitoring_bloc.dart';
import '../bloc/fetchBlocs/fetch_sb_betlist_bloc.dart';
import '../bloc/fetchBlocs/fetch_top_exposure_player_bloc.dart';
import '../reusable/colors.dart';
import '../reusable/highlighted_text_widget.dart';
import '../reusable/search_controller.dart';
import '../router/right_click_context_menu.dart';

import '../bloc/fetchBlocs/fetch_agency_bloc.dart';
import '../bloc/fetchBlocs/fetch_betlist_bloc.dart';
import '../bloc/fetchBlocs/fetch_player_profit_and_loss_bloc.dart';
import '../bloc/fetchBlocs/fetch_settle_history_bloc.dart';
import '../bloc/fetchBlocs/fetch_user_activity_logs_bloc.dart';
import '../bloc/fetchBlocs/fetch_user_logs_bloc.dart';

import '../router/route_paths.dart';
import 'show_all_error_msg_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.child = const SizedBox(), this.currentLocation = RoutePaths.manage, this.savedUserData});

  final Widget child;
  final String currentLocation;
  final SaveLoginTokenModel? savedUserData;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Track which menu is currently hovered
  String hoverMenu = "";

  // Track hover states for overlay management
  bool _isHoveringNavTrigger = false;
  bool _isHoveringOverlay = false;

  // Key for forcing widget rebuild when needed
  int reloadKey = 0;

  // Overlay entry reference
  OverlayEntry? _activeOverlay;

  // Tracks the position of the latest right-click for context menu placement
  Offset? _latestSecondaryTapPosition;

  /// Removes the active overlay and resets hover states
  void _removeOverlay() {
    _activeOverlay?.remove();
    _activeOverlay = null;
    _isHoveringNavTrigger = false;
    _isHoveringOverlay = false;
    if (mounted) {
      setState(() => hoverMenu = "");
    }
  }

  String _buildAbsoluteUrl(String path) {
    final baseUrl = html.window.location.origin;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final useHash = html.window.location.hash.isNotEmpty || html.window.location.href.contains('#');
    return useHash ? '$baseUrl/#$cleanPath' : '$baseUrl$cleanPath';
  }

  /// Schedules overlay closure with a small delay to handle mouse transitions
  void _scheduleOverlayClose() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      if (RightClickContextMenu.isShowing) return;
      if (!_isHoveringNavTrigger && !_isHoveringOverlay) {
        _removeOverlay();
      }
    });
  }

  // Get current page label from location
  String get currentPageLabel => RoutePaths.pageLabelForLocation(widget.currentLocation);

  // Hide dashboard shell header/navbar for user report full-screen view
  bool get _hideShellHeaderNavbar =>
      widget.currentLocation == RoutePaths.manageUserReport ||
      widget.currentLocation == RoutePaths.manageEventBookView ||
      widget.currentLocation == RoutePaths.manageRunnerWiseReport ||
      widget.currentLocation == RoutePaths.manageSportWiseReport ||
      widget.currentLocation == RoutePaths.manageSportBookReport ||
      widget.currentLocation == RoutePaths.manageSportBookRunnerWiseReport;

  // Navigation groups for the navbar
  final List<NavGroup> _navGroups = [
    NavGroup("Risk", ["Risk Management", "Risk Monitoring"]),
    NavGroup("Report", [
      "Market Profit/Loss",
      "Profit/Loss",
      "Betting History",
      "BetList",
      "BetListLive",
      "BetListDetail",
      "Market Settle Status Live",
      "Market Settle Status Log",
    ]),
    NavGroup("Admin", ['Agency']),
    NavGroup("Log", ["Agency History", "OP Action Log", "User Activity Log", "Balance Log"]),
    NavGroup("API Wallet", ['Action Log']),
    NavGroup('Personal', ["Change Password"]),
  ];
  bool showSearchBar = false;
  final TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  late html.EventListener _keyListener;

  @override
  void initState() {
    context.read<FetchAllWlBloc>().add(FetchAllWl());
    Get.put(GlobalSearchController());
    _keyListener = (event) {
      if (event is html.KeyboardEvent) {
        final isCtrlF = (event.ctrlKey || event.metaKey) && event.key?.toLowerCase() == 'f';

        if (isCtrlF) {
          event.preventDefault();
          if (!mounted) return;
          setState(() {
            if (showSearchBar) {
              Get.find<GlobalSearchController>().clear();
            }
            showSearchBar = !showSearchBar;
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            searchFocusNode.requestFocus();
          });
        }

        if (event.key == 'Escape' && showSearchBar) {
          setState(() {
            showSearchBar = false;
            searchController.clear();
          });
          Get.find<GlobalSearchController>().clear();
        }
      }
    };

    html.window.addEventListener('keydown', _keyListener);

    context.read<FetchCurrentUserDetailsBloc>().add(FetchCurrentUserDetails());
    super.initState();
  }

  @override
  void dispose() {
    html.window.removeEventListener('keydown', _keyListener);
    searchFocusNode.dispose();
    searchController.dispose();
    _activeOverlay?.remove();
    super.dispose();
  }

  /// Fetches data based on the selected page
  void _fetchForPage(String page) {
    switch (page) {
      case 'Risk Management':
        context.read<FetchOpenBMBloc>().add(FetchOpenBMInt());
        context.read<FetchOpenFancyBloc>().add(FetchOpenFancyInt());
        context.read<FetchOpenOddsBloc>().add(FetchOpenOddsInt());
        context.read<FetchTopExposurePlayerBloc>().add(FetchTopExposurePlayerInt());
        context.read<FetchOpenPremiumSportBloc>().add(FetchOpenPremiumSportInt());
        break;
      case 'Risk Monitoring':
        context.read<FetchRiskMonitoringBloc>().add(FetchRiskMonitoringInt());
        context.read<FetchOrderEventsBloc>().add(FetchOrderEventsInt());
        break;
      case 'BetList':
      case 'BetListDetail':
        context.read<FetchBetListBloc>().add(FetchBetListInt());
        context.read<FetchSbBetListBloc>().add(FetchSbBetListInt());
        context.read<FetchOrderEventsBloc>().add(FetchOrderEventsInt());
        break;
      case 'BetListLive':
        context.read<FetchSbBetListBloc>().add(FetchSbBetListInt());
        context.read<FetchBetListLiveBloc>().add(ResetBetListLive());
        context.read<FetchOrderEventsBloc>().add(FetchOrderEventsInt());
        break;
      case 'Betting History':
        context.read<FetchPlayerBetHistoryBloc>().add(FetchPlayerBetInt());
        break;
      case 'Profit/Loss':
        context.read<FetchPlayerProfitAndLossBloc>().add(FetchPlayerProfitAndLossInt());
        break;
      case 'Market Settle Status Live':
      case 'Market Settle Status Log':
        context.read<FetchSettleHistoryBloc>().add(FetchSettleHistoryInt());
        break;
      case 'User Activity Log':
        context.read<FetchUserActivityLogsBloc>().add(FetchUserActivityLogsInt());
        break;
      case 'Balance Log':
        context.read<FetchBalanceSummaryLogBloc>().add(FetchBalanceSummaryLogInt());
        break;
      case 'Agency':
        context.read<FetchLtReportBloc>().add(FetchLtReportInt());
        context.read<FetchAgencyBloc>().add(FetchAgencyInt());
        break;
      case 'Agency History':
      case 'OP Action Log':
        context.read<FetchUserLogsBloc>().add(FetchUserLogsInt());
        break;
      default:
        break;
    }
  }

  /// Handles page navigation when a menu item is clicked
  void handlePageChange(String page) {
    // Close overlay immediately
    _removeOverlay();

    // Force reload if same page is clicked
    if (currentPageLabel == page) {
      reloadKey++;
    }

    final path = RoutePaths.getRouteForPageName(page);
    context.go(path);
    _fetchForPage(page);
  }

  @override
  Widget build(BuildContext context) {
    final searchCtrl = Get.find<GlobalSearchController>();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ShowAllErrorMsgScreen(
          child: SelectionArea(
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_hideShellHeaderNavbar) _buildHeader(),
                    if (!_hideShellHeaderNavbar) _buildNavbar(),
                    Expanded(
                      child: KeyedSubtree(key: ValueKey("$currentPageLabel-$reloadKey"), child: widget.child),
                    ),
                  ],
                ),
                if (showSearchBar)
                  Positioned(
                    top: 10,
                    right: 30,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 320,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: searchController,
                                focusNode: searchFocusNode,
                                style: const TextStyle(color: black),
                                decoration: const InputDecoration(
                                  hintText: 'Find...',
                                  hintStyle: TextStyle(color: black),
                                  border: InputBorder.none,
                                ),
                                onChanged: searchCtrl.updateQuery,
                                onSubmitted: (_) {
                                  searchCtrl.nextMatch();
                                  searchFocusNode.requestFocus();
                                },
                              ),
                            ),
                            Obx(() {
                              final total = searchCtrl.matchCount.value;
                              final current = searchCtrl.currentIndex.value;

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: HighlightText(total == 0 ? '0/0' : '${current + 1}/$total', style: const TextStyle(fontSize: 12, color: black)),
                              );
                            }),
                            Obx(() {
                              final hasMatches = searchCtrl.matchCount.value > 0;
                              return IconButton(icon: const Icon(Icons.keyboard_arrow_up), onPressed: hasMatches ? searchCtrl.previousMatch : null);
                            }),
                            Obx(() {
                              final hasMatches = searchCtrl.matchCount.value > 0;
                              return IconButton(icon: const Icon(Icons.keyboard_arrow_down), onPressed: hasMatches ? searchCtrl.nextMatch : null);
                            }),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  showSearchBar = false;
                                  searchController.clear();
                                });
                                searchCtrl.clear();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the header section with app title and user info
  Widget _buildHeader() {
    return SizedBox(
      height: 75,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () => html.window.location.reload(),
                  child: HighlightText(AppConstants.appTitle, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                ),
                const VerticalDivider(),
                BlocBuilder<FetchCurrentUserDetailsBloc, FetchCurrentUserDetailsState>(
                  builder: (context, state) {
                    UserDetails? userDetails;
                    if (state is FetchCurrentUserDetailsSuccess) {
                      userDetails = state.userDetails;
                    }
                    return Row(
                      children: [
                        const HighlightText("User", style: TextStyle(color: black)),
                        const SizedBox(width: 10),
                        HighlightText(userDetails?.userName ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    );
                  },
                ),
              ],
            ),
            HighlightText("${AppConstants.appVersion} (${AppConstants.build})", style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  /// Builds the main navigation bar
  Widget _buildNavbar() {
    return Container(
      height: 30,
      color: const Color(0xFF2D2D2D),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: Row(children: _navGroups.map((g) => _buildDropdownNavItem(g)).toList())),
          _buildRightNavbar(),
        ],
      ),
    );
  }

  /// Builds an individual dropdown navigation item with overlay support
  Widget _buildDropdownNavItem(NavGroup group) {
    bool isHovered = hoverMenu == group.title;
    bool isSelected = currentPageLabel == group.title || group.items.contains(currentPageLabel);

    return Builder(
      builder: (context) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onExit: (_) {
            setState(() => _isHoveringNavTrigger = false);
            _scheduleOverlayClose();
          },
          onEnter: (_) {
            // Remove any existing overlay first
            _removeOverlay();
            if (!mounted) return;

            setState(() {
              _isHoveringNavTrigger = true;
              hoverMenu = group.title;
            });

            // Get position for overlay placement
            final renderObject = context.findRenderObject();
            if (renderObject is! RenderBox) return;
            final box = renderObject;
            final size = box.size;
            final offset = box.localToGlobal(Offset.zero);

            _activeOverlay = OverlayEntry(
              builder: (_) {
                return Positioned(
                  left: offset.dx,
                  top: offset.dy + size.height,
                  child: MouseRegion(
                    onEnter: (_) {
                      setState(() {
                        _isHoveringOverlay = true;
                        hoverMenu = group.title;
                      });
                    },
                    onExit: (_) {
                      setState(() => _isHoveringOverlay = false);
                      _scheduleOverlayClose();
                    },
                    child: Material(
                      color: const Color(0xFF2D2D2D),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: size.width),
                        child: IntrinsicWidth(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: group.items.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              final bool isLastItem = index == group.items.length - 1;
                              final path = RoutePaths.getRouteForPageName(item);

                              return _buildDropdownMenuItem(item: item, path: path, isLastItem: isLastItem);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );

            Overlay.of(context).insert(_activeOverlay!);
          },
          child: Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? white.withOpacity(0.2)
                  : isHovered
                  ? white.withOpacity(0.1)
                  : transparent,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                HighlightText(
                  group.title,
                  style: const TextStyle(color: white, fontWeight: FontWeight.w500, fontSize: 13),
                ),
                const SizedBox(width: 2),
                Icon(Icons.arrow_drop_down, size: 18, color: white),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds an individual dropdown menu item with proper URL handling
  Widget _buildDropdownMenuItem({required String item, required String path, required bool isLastItem}) {
    return Builder(
      builder: (itemContext) {
        return InkWell(
          onSecondaryTapDown: (details) {
            _latestSecondaryTapPosition = details.globalPosition;
          },
          onSecondaryTap: () {
            if (_latestSecondaryTapPosition == null) return;
            RightClickContextMenu.show(context, _latestSecondaryTapPosition!, _buildAbsoluteUrl(path), onOverlayRemoved: _removeOverlay);
          },
          child: InkWell(
            onTap: () {
              // Close overlay immediately on click
              _fetchForPage(item);
              _removeOverlay();
              context.go(path);
            },
            child: Container(
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border(bottom: isLastItem ? BorderSide.none : const BorderSide(color: Color(0xFF444444), width: 1)),
              ),
              child: Row(
                children: [
                  HighlightText(
                    item,
                    style: const TextStyle(color: white, fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the right side of navbar with timezone and logout
  Widget _buildRightNavbar() {
    return Row(
      children: [
        const HighlightText("Time Zone : ", style: TextStyle(color: grey)),
        const HighlightText(
          "GMT+5:30",
          style: TextStyle(color: white, fontWeight: FontWeight.bold),
        ),
        VerticalDivider(color: grey),
        InkWell(
          onTap: () {
            _removeOverlay();
            context.read<UserLogoutBloc>().add(UserLogoutListener(context: context));
          },
          child: const Row(
            children: [
              HighlightText(
                "Logout",
                style: TextStyle(color: white, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 5),
              Icon(Icons.logout, size: 16, color: white),
            ],
          ),
        ),
      ],
    );
  }
}

/// Model class for navigation groups
class NavGroup {
  final String title;
  final List<String> items;
  NavGroup(this.title, [this.items = const []]);
}
