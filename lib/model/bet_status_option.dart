class BetStatusOption {
  final String label;
  final bool? isDone;
  final String? status;

  const BetStatusOption({required this.label, this.isDone, this.status});
}

List<BetStatusOption> bookMakerStatuses = [
  BetStatusOption(label: 'Active', isDone: false, status: 'new'),
  BetStatusOption(label: 'Voided', isDone: true, status: 'void'),
  BetStatusOption(label: 'Settled', isDone: true, status: 'filled'),
];

List<BetStatusOption> exchangeStatuses = [
  BetStatusOption(label: 'Unmatched'),
  BetStatusOption(label: 'Matched', isDone: false, status: 'new'),
  BetStatusOption(label: 'Cancelled'),
  BetStatusOption(label: 'Settled', isDone: true, status: 'filled'),
  BetStatusOption(label: 'Voided', isDone: true, status: 'void'),
];

List<BetStatusOption> betListDetailsStatuses = [
  BetStatusOption(label: 'Unmatched'),
  BetStatusOption(label: 'Matched', isDone: false, status: 'new'),
];