library angular2_material.src.components.progress_linear.progress_linear;

import "package:angular2/core.dart"
    show Component, ViewEncapsulation, Attribute, OnChanges;
import "package:angular2/src/facade/lang.dart" show isPresent, isBlank;
import "package:angular2/src/facade/math.dart" show Math;

/** Different display / behavior modes for progress-linear. */
class ProgressMode {
  static const DETERMINATE = "determinate";
  static const INDETERMINATE = "indeterminate";
  static const BUFFER = "buffer";
  static const QUERY = "query";
  const ProgressMode();
}

@Component(
    selector: "md-progress-linear",
    inputs: const ["value", "bufferValue"],
    host: const {
      "role": "progressbar",
      "aria-valuemin": "0",
      "aria-valuemax": "100",
      "[attr.aria-valuenow]": "value"
    },
    templateUrl:
        "package:angular2_material/src/components/progress-linear/progress_linear.html",
    directives: const [],
    encapsulation: ViewEncapsulation.None)
class MdProgressLinear implements OnChanges {
  /** Value for the primary bar. */
  num value_;
  /** Value for the secondary bar. */
  num bufferValue;
  /** The render mode for the progress bar. */
  String mode;
  /** CSS `transform` property applied to the primary bar. */
  String primaryBarTransform;
  /** CSS `transform` property applied to the secondary bar. */
  String secondaryBarTransform;
  MdProgressLinear(@Attribute("mode") String mode) {
    this.primaryBarTransform = "";
    this.secondaryBarTransform = "";
    this.mode = isPresent(mode) ? mode : ProgressMode.DETERMINATE;
  }
  get value {
    return this.value_;
  }

  set value(v) {
    if (isPresent(v)) {
      this.value_ = MdProgressLinear.clamp(v);
    }
  }

  ngOnChanges(_) {
    // If the mode does not use a value, or if there is no value, do nothing.
    if (this.mode == ProgressMode.QUERY ||
        this.mode == ProgressMode.INDETERMINATE ||
        isBlank(this.value)) {
      return;
    }
    this.primaryBarTransform = this.transformForValue(this.value);
    // The bufferValue is only used in buffer mode.
    if (this.mode == ProgressMode.BUFFER) {
      this.secondaryBarTransform = this.transformForValue(this.bufferValue);
    }
  }

  /** Gets the CSS `transform` property for a progress bar based on the given value (0 - 100). */
  transformForValue(value) {
    // TODO(jelbourn): test perf gain of caching these, since there are only 101 values.
    var scale = value / 100;
    var translateX = (value - 100) / 2;
    return '''translateX(${ translateX}%) scale(${ scale}, 1)''';
  }

  /** Clamps a value to be between 0 and 100. */
  static clamp(v) {
    return Math.max(0, Math.min(100, v));
  }
}
