library angular2_material.src.components.button.button;

import "package:angular2/core.dart"
    show Component, ViewEncapsulation, OnChanges;
import "package:angular2/src/facade/async.dart" show TimerWrapper;
import "package:angular2/src/facade/lang.dart" show isPresent;
// TODO(jelbourn): Ink ripples.

// TODO(jelbourn): Make the `isMouseDown` stuff done with one global listener.
@Component(
    selector: "[mdButton]:not(a), [mdFab]:not(a), [mdRaisedButton]:not(a)",
    host: const {
      "(mousedown)": "onMousedown()",
      "(focus)": "onFocus()",
      "(blur)": "onBlur()",
      "[class.md-button-focus]": "isKeyboardFocused"
    },
    templateUrl: "package:angular2_material/src/components/button/button.html",
    styleUrls: const [
      "package:angular2_material/src/components/button/button.css"
    ],
    encapsulation: ViewEncapsulation.None)
class MdButton {
  /** Whether a mousedown has occurred on this element in the last 100ms. */
  bool isMouseDown = false;
  /** Whether the button has focus from the keyboard (not the mouse). Used for class binding. */
  bool isKeyboardFocused = false;
  onMousedown() {
    // We only *show* the focus style when focus has come to the button via the keyboard.

    // The Material Design spec is silent on this topic, and without doing this, the

    // button continues to look :active after clicking.

    // @see http://marcysutton.com/button-focus-hell/
    this.isMouseDown = true;
    TimerWrapper.setTimeout(() {
      this.isMouseDown = false;
    }, 100);
  }

  onFocus() {
    this.isKeyboardFocused = !this.isMouseDown;
  }

  onBlur() {
    this.isKeyboardFocused = false;
  }
}

@Component(
    selector: "a[mdButton], a[mdRaisedButton], a[mdFab]",
    inputs: const ["disabled"],
    host: const {
      "(click)": "onClick(\$event)",
      "(mousedown)": "onMousedown()",
      "(focus)": "onFocus()",
      "(blur)": "onBlur()",
      "[tabIndex]": "tabIndex",
      "[class.md-button-focus]": "isKeyboardFocused",
      "[attr.aria-disabled]": "isAriaDisabled"
    },
    templateUrl: "package:angular2_material/src/components/button/button.html",
    encapsulation: ViewEncapsulation.None)
class MdAnchor extends MdButton implements OnChanges {
  num tabIndex;
  bool disabled_;
  bool get disabled {
    return this.disabled_;
  }

  set disabled(value) {
    // The presence of *any* disabled value makes the component disabled, *except* for false.
    this.disabled_ = isPresent(value) && !identical(this.disabled, false);
  }

  onClick(event) {
    // A disabled anchor shouldn't navigate anywhere.
    if (this.disabled) {
      event.preventDefault();
    }
  }

  /** Invoked when a change is detected. */
  ngOnChanges(_) {
    // A disabled anchor should not be in the tab flow.
    this.tabIndex = this.disabled ? -1 : 0;
  }

  /** Gets the aria-disabled value for the component, which must be a string for Dart. */
  String get isAriaDisabled {
    return this.disabled ? "true" : "false";
  }
}
