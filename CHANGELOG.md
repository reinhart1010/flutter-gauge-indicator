## 0.2.1

- Updated readme.
- Updated analysis options.
  
## 0.2.0

- Allow `RadialGauge` to pass the child as a label.
  - Added `child` parameter to the `RadialGauge` widget.
  - Removed `style` and `labelProvider` arguments.
  - Migrated `GaugeLabelProvider` class.
  - Added `child` and `builder` parameters to the `AnimatedRadialGauge` widget.
  - Introduced `RadialGaugeLabel` widget.
- The `AnimatedRadialGauge` value is now constrained by the `min` and `max` parameters.
- Added `GaugeLabelProvider.map` constructor.
- Added `AnimatedLinearGauge` and `LinearGauge`.
  - Updated `readme` with new features.
  - Added `LinearGauge` example page.
- Removed obsolete dependencies.
- Redone structure of example project.
- Added 80 char limit to code.

## 0.1.0

- Migrated to the render box.
- Added `flutter_lints` package for the analysis.
- Removed gauge custom painter.
- Renamed `Gauge` into `AnimatedRadialGauge`.
  - `AnimatedRadialGauge` is simplicity animated widget.
  - Added `initialValue` which describes the value from which the gauge indicator will be initially animated to the current `value`.
- Added `RadialGauge` widget, that supports drawing gauge indicator without the animations.

## 0.0.1

- Initial release.
