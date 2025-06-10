/// gesture displacement (logical pixels) needed to trigger a pitch change
/// tweak via UI or const value for now
const double kSlideSensitivity = 5.0;      // ≈ 30 px ≃ 0.5 cm
/// How much easier it is to trigger a semitone change when also sliding vertically.
/// A value of 0.7 means it only requires 70% of the horizontal distance.
const double kDiagonalSensitivityFactor = 0.5;

const Duration kPressDelay = Duration(milliseconds: 120);
const double slideThreshold = kSlideSensitivity * 20;
