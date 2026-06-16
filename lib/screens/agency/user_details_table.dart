import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/fetchBlocs/fetch_lt_report_bloc.dart';
import '../../reusable/snack_bar.dart';
import '../../bloc/authBlocs/update_user_access_bloc.dart';
import '../../model/agency_model.dart';
import '../../reusable/colors.dart';
import '../../reusable/formatters.dart';
import '../../reusable/highlighted_text_widget.dart';
import 'show_user_commission.dart';
import 'view_user_balance_dialog.dart';

class UserDataTableScreen extends StatefulWidget {
  const UserDataTableScreen({super.key, required this.agency});

  final List<AgencyModel> agency;

  @override
  State<UserDataTableScreen> createState() => _UserDataTableScreenState();
}

class _UserDataTableScreenState extends State<UserDataTableScreen> {
  String? selectedUserId;
  Set<String> selectedSystemLockedUserIds = {};
  Set<String> selectedSystemSuspendedUserIds = {};
  Set<String> selectedPassLockedUserIds = {};
  bool isSystemLockedSelectAllChecked = false;
  bool isSystemSuspendedSelectAllChecked = false;
  bool isPassLockedSelectAllChecked = false;

  AgencyModel? get selectedUser {
    if (selectedUserId == null) return null;
    try {
      return widget.agency.firstWhere((user) => user.id == selectedUserId);
    } catch (_) {
      return null;
    }
  }

  List<AgencyModel> _targetUsers(Set<String> selectedIds) {
    return widget.agency.where((user) => selectedIds.contains(user.id)).toList();
  }

  void _toggleSelectAll(Set<String> selectedIds, bool checked) {
    selectedIds.clear();
    if (checked) {
      selectedIds.addAll(widget.agency.map((user) => user.id));
    }
  }

  void _dispatchStatusUpdate({required List<AgencyModel> users, bool? suspend, bool? systemLock, bool? disablePassLock}) {
    final map = users.map((user) {
      return {"clientId": user.id, "systemLock": systemLock ?? user.systemLocked, "suspend": suspend ?? user.systemSuspended, "disablePassLock": disablePassLock ?? false};
    }).toList();
    context.read<UpdateUserAccessBloc>().add(UpdateUserAccess(map: map));
  }

  @override
  void initState() {
    super.initState();
    if (widget.agency.isNotEmpty) {
      selectedUserId = widget.agency.first.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<FetchLtReportBloc>().add(FetchLtReport(userName: widget.agency.first.userName, createdTime: widget.agency.first.createdTime));
      });
    }
  }

  @override
  void didUpdateWidget(covariant UserDataTableScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.agency.isNotEmpty) {
      final bool selectedUserStillExists = selectedUserId != null && widget.agency.any((user) => user.id == selectedUserId);
      if (!selectedUserStillExists) {
        selectedUserId = widget.agency.first.id;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          context.read<FetchLtReportBloc>().add(FetchLtReport(userName: widget.agency.first.userName, createdTime: widget.agency.first.createdTime));
        });
      }
    } else {
      selectedUserId = null;
    }

    selectedSystemLockedUserIds.retainWhere((id) => widget.agency.any((user) => user.id == id));
    selectedSystemSuspendedUserIds.retainWhere((id) => widget.agency.any((user) => user.id == id));
    selectedPassLockedUserIds.retainWhere((id) => widget.agency.any((user) => user.id == id));

    if (widget.agency.isEmpty) {
      isSystemLockedSelectAllChecked = false;
      isSystemSuspendedSelectAllChecked = false;
      isPassLockedSelectAllChecked = false;
    }
  }

  void _selectUser(AgencyModel user) {
    setState(() {
      selectedUserId = user.id;
    });
    context.read<FetchLtReportBloc>().add(FetchLtReport(userName: user.userName, createdTime: user.createdTime));
  }

  @override
  Widget build(BuildContext context) {
    List<UserTableColumn> columns = [
      /// WEBSITE
      UserTableColumn(
        flex: 1.5,
        title: 'Web Site',
        cellBuilder: (user, index) {
          return UserDetailsCell(
            flex: 1.5,
            child: Row(
              children: [
                if (user.isPlayer)
                  SizedBox(
                    width: 30,
                    child: Radio<String>(
                      value: user.id,
                      groupValue: selectedUserId,
                      toggleable: true,
                      onChanged: (_) => _selectUser(user),
                      splashRadius: 0,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  )
                else
                  const SizedBox(width: 30),
                Flexible(
                  child: HighlightText(
                    user.wlName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: black, fontWeight: FontWeight.normal),
                  ),
                ),
              ],
            ),
          );
        },
      ),

      /// USER ID
      UserTableColumn(
        flex: 1,
        title: 'User Id',
        cellBuilder: (user, index) {
          return UserDetailsCell(title: user.userName, flex: 1);
        },
      ),

      /// USER LEVEL
      UserTableColumn(
        flex: 0.7,
        title: 'User Level',
        cellBuilder: (user, index) {
          return UserDetailsCell(title: user.role, flex: 0.7);
        },
      ),

      /// UPLINE
      UserTableColumn(
        title: 'Upline',
        flex: 2.5,
        cellBuilder: (user, index) {
          return UserDetailsCell(title: user.upLine, flex: 2.5);
        },
      ),

      /// CURRENCY
      UserTableColumn(
        flex: 0.8,
        title: 'Currency',
        cellBuilder: (user, index) {
          return UserDetailsCell(title: user.currency, flex: 0.8);
        },
      ),

      /// SYSTEM LOCKED
      UserTableColumn(
        title: 'System Locked',
        headerChild: Column(
          children: [
            /// select all users for action
            Checkbox(
              value: isSystemLockedSelectAllChecked,
              onChanged: (v) {
                setState(() {
                  isSystemLockedSelectAllChecked = v ?? false;
                  _toggleSelectAll(selectedSystemLockedUserIds, isSystemLockedSelectAllChecked);
                });
              },
            ),

            /// ACTIVE BUTTON
            CustomTCTAButton(
              title: 'Active',
              action: () {
                final targets = _targetUsers(selectedSystemLockedUserIds);
                final updatableUsers = targets.where((user) => user.systemLocked).toList();
                if (updatableUsers.isEmpty) {
                  showSnackBar(context, 'No data be updated.', error: true);
                  return;
                }
                _dispatchStatusUpdate(users: updatableUsers, systemLock: false);
                setState(() {
                  for (final user in updatableUsers) {
                    user.systemLocked = false;
                  }
                });
              },
            ),

            /// LOCK BUTTON
            CustomTCTAButton(
              title: 'Lock',
              action: () {
                final targets = _targetUsers(selectedSystemLockedUserIds);
                final updatableUsers = targets.where((user) => !user.systemLocked).toList();
                if (updatableUsers.isEmpty) {
                  showSnackBar(context, 'No data be updated.', error: true);
                  return;
                }
                _dispatchStatusUpdate(users: updatableUsers, systemLock: true);
                setState(() {
                  for (final user in updatableUsers) {
                    user.systemLocked = true;
                  }
                });
              },
            ),
          ],
        ),
        cellBuilder: (user, index) {
          return CheckboxWithValue(
            title: user.systemLocked ? 'SystemLocked' : 'Active',
            value: selectedSystemLockedUserIds.contains(user.id),
            onChanged: (value) {
              setState(() {
                isSystemLockedSelectAllChecked = false;
                if (value ?? false) {
                  selectedSystemLockedUserIds.add(user.id);
                } else {
                  selectedSystemLockedUserIds.remove(user.id);
                }
              });
            },
          );
        },
      ),

      /// UPDATOR
      UserTableColumn(
        title: 'Updator',
        cellBuilder: (user, index) {
          return UserDetailsCell(title: user.sysLockedUpdator);
        },
      ),

      /// SYSTEM SUSPENDED
      UserTableColumn(
        title: 'System Suspended',
        headerChild: Column(
          children: [
            /// select all users for action
            Checkbox(
              value: isSystemSuspendedSelectAllChecked,
              onChanged: (v) {
                setState(() {
                  isSystemSuspendedSelectAllChecked = v ?? false;
                  _toggleSelectAll(selectedSystemSuspendedUserIds, isSystemSuspendedSelectAllChecked);
                });
              },
            ),

            /// ACTIVE BUTTON
            CustomTCTAButton(
              title: 'Active',
              action: () {
                final targets = _targetUsers(selectedSystemSuspendedUserIds);
                final updatableUsers = targets.where((user) => user.systemSuspended).toList();
                if (updatableUsers.isEmpty) {
                  showSnackBar(context, 'No data be updated.', error: true);
                  return;
                }
                _dispatchStatusUpdate(users: updatableUsers, suspend: false);
                setState(() {
                  for (final user in updatableUsers) {
                    user.systemSuspended = false;
                  }
                });
              },
            ),

            /// SUSPENDED BUTTON
            CustomTCTAButton(
              title: 'Suspended',
              action: () {
                final targets = _targetUsers(selectedSystemSuspendedUserIds);
                final updatableUsers = targets.where((user) => !user.systemSuspended).toList();
                if (updatableUsers.isEmpty) {
                  showSnackBar(context, 'No data be updated.', error: true);
                  return;
                }
                _dispatchStatusUpdate(users: updatableUsers, suspend: true);
                setState(() {
                  for (final user in updatableUsers) {
                    user.systemSuspended = true;
                  }
                });
              },
            ),
          ],
        ),
        cellBuilder: (user, index) {
          return CheckboxWithValue(
            title: user.systemSuspended ? 'Suspended' : 'Active',
            value: selectedSystemSuspendedUserIds.contains(user.id),
            onChanged: (value) {
              setState(() {
                isSystemSuspendedSelectAllChecked = false;
                if (value ?? false) {
                  selectedSystemSuspendedUserIds.add(user.id);
                } else {
                  selectedSystemSuspendedUserIds.remove(user.id);
                }
              });
            },
          );
        },
      ),

      /// UPDATOR
      UserTableColumn(
        title: 'Updator',
        cellBuilder: (user, index) {
          return UserDetailsCell(title: user.sysSuspendedUpdator);
        },
      ),

      /// PASS LOCK
      UserTableColumn(
        title: 'Pass Lock',
        headerChild: Column(
          children: [
            /// select all users for action
            Checkbox(
              value: isPassLockedSelectAllChecked,
              onChanged: (v) {
                setState(() {
                  isPassLockedSelectAllChecked = v ?? false;
                  _toggleSelectAll(selectedPassLockedUserIds, isPassLockedSelectAllChecked);
                });
              },
            ),

            /// ACTIVE BUTTON
            CustomTCTAButton(
              title: 'Active',
              action: () {
                final targets = _targetUsers(selectedPassLockedUserIds);
                final unlockUsers = targets.where((user) => user.passLocked).toList();

                if (unlockUsers.isEmpty) {
                  showSnackBar(context, 'No data be updated.', error: true);
                  return;
                }

                if (unlockUsers.isNotEmpty) {
                  _dispatchStatusUpdate(users: unlockUsers, disablePassLock: true);
                }

                setState(() {
                  for (final user in unlockUsers) {
                    user.passLocked = false;
                  }
                });
              },
            ),
          ],
        ),
        cellBuilder: (user, index) {
          return CheckboxWithValue(
            title: user.passLocked ? 'PasswordLocked' : 'Active',
            value: selectedPassLockedUserIds.contains(user.id),
            onChanged: (value) {
              setState(() {
                isPassLockedSelectAllChecked = false;
                if (value ?? false) {
                  selectedPassLockedUserIds.add(user.id);
                } else {
                  selectedPassLockedUserIds.remove(user.id);
                }
              });
            },
          );
        },
      ),

      /// STATUS
      UserTableColumn(
        title: 'Status',
        cellBuilder: (user, index) {
          return UserDetailsCell(title: user.userStatus);
        },
      ),

      /// PROFILE
      UserTableColumn(
        title: 'Profile',
        flex: 0.6,
        cellBuilder: (user, index) {
          return UserDetailsCell(
            flex: 0.6,
            child: ViewCTAButton(
              onPressed: () {
                showUserCommissionHtml(context, user);
              },
            ),
          );
        },
      ),

      /// CREDIT
      UserTableColumn(
        flex: 1,
        title: 'Credit Allocated',
        cellBuilder: (user, index) {
          return UserDetailsCell(title: formattedAmounts(user.creditRef), color: user.creditRef >= 0 ? black : red, flex: 1);
        },
      ),

      /// NET BALANCE
      UserTableColumn(
        title: 'Net Balance',
        cellBuilder: (user, index) {
          return UserDetailsCell(title: formattedAmounts(user.netPoint), color: user.netPoint >= 0 ? black : red);
        },
      ),

      /// TODAY PNL
      UserTableColumn(
        title: 'Today P/L',
        cellBuilder: (user, index) {
          return UserDetailsCell(title: formattedAmounts(user.todayPnl), color: user.todayPnl >= 0 ? black : red);
        },
      ),

      /// PNL
      UserTableColumn(
        title: 'PNL',
        cellBuilder: (user, index) {
          return UserDetailsCell(title: formattedAmounts(user.pnl), color: user.pnl >= 0 ? black : red);
        },
      ),

      /// AGENT BALANCE
      UserTableColumn(
        title: 'Agent Balance',
        cellBuilder: (user, index) {
          return UserDetailsCell(title: user.agentBalance == 0.0 ? '-' : formattedAmounts(user.agentBalance), color: user.agentBalance >= 0 ? black : red);
        },
      ),

      /// AVAILABLE BALANCE
      UserTableColumn(
        title: 'Available Balance',
        cellBuilder: (user, index) {
          return UserDetailsCell(title: formattedAmounts(user.balancePoint), color: user.balancePoint >= 0 ? black : red);
        },
      ),

      /// VIEW BALANCE
      UserTableColumn(
        title: '',
        flex: 0.6,
        cellBuilder: (user, index) {
          return user.isPlayer ? UserDetailsCell(flex: 0.6, child: ViewCTAButton(onPressed: () => viewUserBalance(context, user))) : UserDetailsCell(title: '', flex: 0.6);
        },
      ),

      /// EXPOSURE
      UserTableColumn(
        title: 'Exposure',
        cellBuilder: (user, index) {
          return UserDetailsCell(title: formattedAmounts(user.exposure), color: user.exposure >= 0 ? black : red);
        },
      ),

      /// CREATED DATE
      UserTableColumn(
        title: 'Created Date',
        cellBuilder: (user, index) {
          return UserDetailsCell(title: formattedDate(user.createdTime));
        },
      ),
    ];

    return BlocListener<UpdateUserAccessBloc, UpdateUserAccessState>(
      listener: (context, uas) {
        if (uas is UpdateUserAccessSuccess) {
          selectedSystemLockedUserIds = {};
          selectedSystemSuspendedUserIds = {};
          selectedPassLockedUserIds = {};
          isSystemLockedSelectAllChecked = false;
          isSystemSuspendedSelectAllChecked = false;
          isPassLockedSelectAllChecked = false;
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TABLE HEADER
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFE4E4E4),
              border: Border(
                bottom: BorderSide(color: borderColor),
                top: BorderSide(color: borderColor),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            child: Row(
              children: columns.map((column) {
                return UserDetailsCell(title: column.title, isHeader: true, flex: column.flex, child: column.headerChild);
              }).toList(),
            ),
          ),

          /// TABLE DATA
          Column(
            children: List.generate(widget.agency.length, (index) {
              final user = widget.agency[index];
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                  child: Row(
                    children: columns.map((column) {
                      return column.cellBuilder(user, index);
                    }).toList(),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
