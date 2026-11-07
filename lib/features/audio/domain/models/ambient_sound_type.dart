/// One layer of the environmental soundscape. Every type is driven by the
/// live environment (weather, terrain in view, combat) through
/// `AmbientSoundEngine` - never played as a fixed loop.
enum AmbientSoundType {
  /// Wind - soft breeze to harsh gale depending on strength.
  wind,

  /// Rain.
  rain,

  /// Falling snow and snow-storm wind.
  snow,

  /// Blowing dust/sand.
  dust,

  /// Birdsong - sporadic calls rather than a bed.
  birds,

  /// Wind rustling through trees/leaves.
  leaves,

  /// A river or lake close by.
  water,

  /// Sea waves.
  sea,

  /// Molten lava.
  lava,
}
