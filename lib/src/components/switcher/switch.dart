library angular2_material.src.components.switcher._switch;

import "package:angular2/core.dart"
    show Component, ViewEncapsulation, Attribute;
import "../checkbox/checkbox.dart" show MdCheckbox;
// TODO(jelbourn): add gesture support

// TODO(jelbourn): clean up CSS.
@Component(
    selector: "md-switch",
    inputs: const ["checked", "disabled"],
    host: const {
      "role": "checkbox",
      "[attr.aria-checked]": "checked",
      "[attr.aria-disabled]": "disabled_",
      "(keydown)": "onKeydown(\$event)"
    },
    templateUrl:
        "package:angular2_material/src/components/switcher/switch.html",
    directives: const [],
    encapsulation: ViewEncapsulation.None)
class MdSwitch extends MdCheckbox {
  MdSwitch(@Attribute("tabindex") String tabindex) : super(tabindex) {
    /* super call moved to initializer */;
  }
}
