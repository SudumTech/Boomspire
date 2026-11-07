import 'strike_target.dart';

/// Where the AI army strikes this round: the main force's target, plus an
/// optional weakly-guarded target for a fast raiding squad.
class StrikePlan {
  final StrikeTarget main;
  final StrikeTarget? raid;

  const StrikePlan({required this.main, this.raid});
}
