library angular2_material.src.components.input.input;

import "package:angular2/core.dart"
    show Directive, Attribute, Host, SkipSelf, AfterContentChecked;
import "package:angular2/src/facade/async.dart"
    show ObservableWrapper, EventEmitter;
// TODO(jelbourn): validation (will depend on Forms API).

// TODO(jelbourn): textarea resizing

// TODO(jelbourn): max-length counter

// TODO(jelbourn): placeholder property
@Directive(selector: "md-input-container", host: const {
  "[class.md-input-has-value]": "inputHasValue",
  "[class.md-input-focused]": "inputHasFocus"
})
class MdInputContainer implements AfterContentChecked {
  // The MdInput or MdTextarea inside of this container.
  MdInput _input;
  // Whether the input inside of this container has a non-empty value.
  bool inputHasValue;
  // Whether the input inside of this container has focus.
  bool inputHasFocus;
  MdInputContainer(@Attribute("id") String id) {
    this._input = null;
    this.inputHasValue = false;
    this.inputHasFocus = false;
  }
  ngAfterContentChecked() {
    // Enforce that this directive actually contains a text input.
    if (this._input == null) {
      throw "No <input> or <textarea> found inside of <md-input-container>";
    }
  }

  /** Registers the child MdInput or MdTextarea. */
  registerInput(input) {
    if (this._input != null) {
      throw "Only one text input is allowed per <md-input-container>.";
    }
    this._input = input;
    this.inputHasValue = input.value != "";
    // Listen to input changes and focus events so that we can apply the appropriate CSS

    // classes based on the input state.
    ObservableWrapper.subscribe(input.mdChange, (value) {
      this.inputHasValue = value != "";
    });
    ObservableWrapper.subscribe/*< bool >*/(
        input.mdFocusChange, (hasFocus) => this.inputHasFocus = hasFocus);
  }
}

@Directive(selector: "md-input-container input", outputs: const [
  "mdChange",
  "mdFocusChange"
], host: const {
  "class": "md-input",
  "(input)": "updateValue(\$event)",
  "(focus)": "setHasFocus(true)",
  "(blur)": "setHasFocus(false)"
})
class MdInput {
  String value;
  // Events emitted by this directive. We use these special 'md-' events to communicate

  // to the parent MdInputContainer.
  EventEmitter<dynamic> mdChange;
  EventEmitter<dynamic> mdFocusChange;
  MdInput(
      @Attribute("value") String value,
      @SkipSelf() @Host() MdInputContainer container,
      @Attribute("id") String id) {
    this.value = value == null ? "" : value;
    this.mdChange = new EventEmitter();
    this.mdFocusChange = new EventEmitter();
    container.registerInput(this);
  }
  updateValue(event) {
    this.value = event.target.value;
    ObservableWrapper.callEmit(this.mdChange, this.value);
  }

  setHasFocus(bool hasFocus) {
    ObservableWrapper.callEmit(this.mdFocusChange, hasFocus);
  }
}
