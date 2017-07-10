library angular2_material.src.components.checkbox.checkbox;

import "dart:html";
import "package:angular2/core.dart"
    show Component, Attribute, ViewEncapsulation;
import "package:angular2/src/facade/lang.dart" show isPresent;
import "package:angular2_material/src/core/key_codes.dart" show KeyCodes;
import "package:angular2/src/facade/browser.dart" show KeyboardEvent;
import "package:angular2/src/facade/lang.dart" show NumberWrapper;

@Component(
    selector: "md-checkbox",
    inputs: const ["checked", "disabled"],
    host: const {
      "role": "checkbox",
      "[attr.aria-checked]": "checked",
      "[attr.aria-disabled]": "disabled",
      "[tabindex]": "tabindex",
      "(keydown)": "onKeydown(\$event)"
    },
    templateUrl:
        "package:angular2_material/src/components/checkbox/checkbox.html",
    directives: const [],
    encapsulation: ViewEncapsulation.None)
class MdCheckbox {
  /** Whether this checkbox is checked. */
  bool checked;
  /** Whether this checkbox is disabled. */
  bool disabled_;
  /** Setter for tabindex */
  num tabindex;
  MdCheckbox(@Attribute("tabindex") String tabindex) {
    this.checked = false;
    this.tabindex =
        isPresent(tabindex) ? NumberWrapper.parseInt(tabindex, 10) : 0;
    this.disabled_ = false;
  }
  get disabled {
    return this.disabled_;
  }

  set disabled(value) {
    this.disabled_ = isPresent(value) && !identical(value, false);
  }

  onKeydown(KeyboardEvent event) {
    if (event.keyCode == KeyCodes.SPACE) {
      event.preventDefault();
      this.toggle(event);
    }
  }

  toggle(event) {
    if (this.disabled) {
      event.stopPropagation();
      return;
    }
    this.checked = !this.checked;
  }
}
