library angular2_material.src.components.radio.radio_button;

import "dart:html";
import "package:angular2/core.dart"
    show
        Component,
        ViewEncapsulation,
        Host,
        SkipSelf,
        Attribute,
        Optional,
        OnChanges,
        OnInit;
import "package:angular2/src/facade/lang.dart"
    show isPresent, StringWrapper, NumberWrapper;
import "package:angular2/src/facade/async.dart"
    show ObservableWrapper, EventEmitter;
import "package:angular2/src/facade/browser.dart" show Event, KeyboardEvent;
import "package:angular2_material/src/components/radio/radio_dispatcher.dart"
    show MdRadioDispatcher;
import "package:angular2_material/src/core/key_codes.dart" show KeyCodes;
// TODO(jelbourn): Behaviors to test

// Disabled radio don't select

// Disabled radios don't propagate click event

// Radios are disabled by parent group

// Radios set default tab index iff not in parent group

// Radios are unique-select

// Radio updates parent group's value

// Change to parent group's value updates the selected child radio

// Radio name is pulled on parent group

// Radio group changes on arrow keys

// Radio group skips disabled radios on arrow keys
num _uniqueIdCounter = 0;

@Component(
    selector: "md-radio-group",
    outputs: const ["change"],
    inputs: const ["disabled", "value"],
    host: const {
      "role": "radiogroup", "[attr.aria-disabled]": "disabled",
      "[attr.aria-activedescendant]": "activedescendant",
      // TODO(jelbourn): Remove ^ when event retargeting is fixed.
      "(keydown)": "onKeydown(\$event)", "[tabindex]": "tabindex"
    },
    templateUrl:
        "package:angular2_material/src/components/radio/radio_group.html",
    encapsulation: ViewEncapsulation.None)
class MdRadioGroup implements OnChanges {
  /** The selected value for the radio group. The value comes from the options. */
  dynamic value;
  /** The HTML name attribute applied to radio buttons in this group. */
  String name_;
  /** Dispatcher for coordinating radio unique-selection by name. */
  MdRadioDispatcher radioDispatcher;
  /** Array of child radio buttons. */
  List<MdRadioButton> radios_;
  dynamic activedescendant;
  bool disabled_;
  /** The ID of the selected radio button. */
  String selectedRadioId;
  EventEmitter<dynamic> change;
  num tabindex;
  MdRadioGroup(
      @Attribute("tabindex") String tabindex,
      @Attribute("disabled") String disabled,
      MdRadioDispatcher radioDispatcher) {
    this.name_ = '''md-radio-group-${ _uniqueIdCounter ++}''';
    this.radios_ = [];
    this.change = new EventEmitter();
    this.radioDispatcher = radioDispatcher;
    this.selectedRadioId = "";
    this.disabled_ = false;
    // The simple presence of the `disabled` attribute dictates disabled state.
    this.disabled = isPresent(disabled);
    // If the user has not set a tabindex, default to zero (in the normal document flow).
    this.tabindex =
        isPresent(tabindex) ? NumberWrapper.parseInt(tabindex, 10) : 0;
  }
  /** Gets the name of this group, as to be applied in the HTML 'name' attribute. */
  String getName() {
    return this.name_;
  }

  get disabled {
    return this.disabled_;
  }

  set disabled(value) {
    this.disabled_ = isPresent(value) && !identical(value, false);
  }

  /** Change handler invoked when bindings are resolved or when bindings have changed. */
  ngOnChanges(_) {
    // If the component has a disabled attribute with no value, it will set disabled = ''.
    this.disabled =
        isPresent(this.disabled) && !identical(this.disabled, false);
    // If the value of this radio-group has been set or changed, we have to look through the

    // child radio buttons and select the one that has a corresponding value (if any).
    if (isPresent(this.value) && this.value != "") {
      this.radioDispatcher.notify(this.name_);
      this.radios_.forEach((radio) {
        if (radio.value == this.value) {
          radio.checked = true;
          this.selectedRadioId = radio.id;
          this.activedescendant = radio.id;
        }
      });
    }
  }

  /** Update the value of this radio group from a child md-radio being selected. */
  updateValue(dynamic value, String id) {
    this.value = value;
    this.selectedRadioId = id;
    this.activedescendant = id;
    ObservableWrapper.callEmit(this.change, null);
  }

  /** Registers a child radio button with this group. */
  register(MdRadioButton radio) {
    this.radios_.add(radio);
  }

  /** Handles up and down arrow key presses to change the selected child radio. */
  onKeydown(KeyboardEvent event) {
    if (this.disabled) {
      return;
    }
    switch (event.keyCode) {
      case KeyCodes.UP:
        this.stepSelectedRadio(-1);
        event.preventDefault();
        break;
      case KeyCodes.DOWN:
        this.stepSelectedRadio(1);
        event.preventDefault();
        break;
    }
  }

  // TODO(jelbourn): Replace this with a findIndex method in the collections facade.
  num getSelectedRadioIndex() {
    for (var i = 0; i < this.radios_.length; i++) {
      if (this.radios_[i].id == this.selectedRadioId) {
        return i;
      }
    }
    return -1;
  }

  /** Steps the selected radio based on the given step value (usually either +1 or -1). */
  stepSelectedRadio(step) {
    var index = this.getSelectedRadioIndex() + step;
    if (index < 0 || index >= this.radios_.length) {
      return;
    }
    var radio = this.radios_[index];
    // If the next radio is line is disabled, skip it (maintaining direction).
    if (radio.disabled) {
      this.stepSelectedRadio(step + (step < 0 ? -1 : 1));
      return;
    }
    this.radioDispatcher.notify(this.name_);
    radio.checked = true;
    ObservableWrapper.callEmit(this.change, null);
    this.value = radio.value;
    this.selectedRadioId = radio.id;
    this.activedescendant = radio.id;
  }
}

@Component(
    selector: "md-radio-button",
    inputs: const ["id", "name", "value", "checked", "disabled"],
    host: const {
      "role": "radio",
      "[id]": "id",
      "[tabindex]": "tabindex",
      "[attr.aria-checked]": "checked",
      "[attr.aria-disabled]": "disabled",
      "(keydown)": "onKeydown(\$event)"
    },
    templateUrl:
        "package:angular2_material/src/components/radio/radio_button.html",
    directives: const [],
    encapsulation: ViewEncapsulation.None)
class MdRadioButton implements OnInit {
  /** Whether this radio is checked. */
  bool checked;
  /** Whether the radio is disabled. */
  bool disabled_;
  /** The unique ID for the radio button. */
  String id;
  /** Analog to HTML 'name' attribute used to group radios for unique selection. */
  String name;
  /** Value assigned to this radio. Used to assign the value to the parent MdRadioGroup. */
  dynamic value;
  /** The parent radio group. May or may not be present. */
  MdRadioGroup radioGroup;
  /** Dispatcher for coordinating radio unique-selection by name. */
  MdRadioDispatcher radioDispatcher;
  num tabindex;
  MdRadioButton(
      @Optional() @SkipSelf() @Host() MdRadioGroup radioGroup,
      @Attribute("id") String id,
      @Attribute("tabindex") String tabindex,
      MdRadioDispatcher radioDispatcher) {
    // Assertions. Ideally these should be stripped out by the compiler.

    // TODO(jelbourn): Assert that there's no name binding AND a parent radio group.
    this.radioGroup = radioGroup;
    this.radioDispatcher = radioDispatcher;
    this.value = null;
    this.checked = false;
    this.id = isPresent(id) ? id : '''md-radio-${ _uniqueIdCounter ++}''';
    // Whenever a radio button with the same name is checked, uncheck this radio button.
    radioDispatcher.listen((name) {
      if (name == this.name) {
        this.checked = false;
      }
    });
    // When this radio-button is inside of a radio-group, the group determines the name.
    if (isPresent(radioGroup)) {
      this.name = radioGroup.getName();
      this.radioGroup.register(this);
    }
    // If the user has not set a tabindex, default to zero (in the normal document flow).
    if (!isPresent(radioGroup)) {
      this.tabindex =
          isPresent(tabindex) ? NumberWrapper.parseInt(tabindex, 10) : 0;
    } else {
      this.tabindex = -1;
    }
  }
  /** Change handler invoked when bindings are resolved or when bindings have changed. */
  ngOnInit() {
    if (isPresent(this.radioGroup)) {
      this.name = this.radioGroup.getName();
    }
  }

  /** Whether this radio button is disabled, taking the parent group into account. */
  bool isDisabled() {
    // Here, this.disabled may be true/false as the result of a binding, may be the empty string

    // if the user just adds a `disabled` attribute with no value, or may be absent completely.

    // TODO(jelbourn): If someone sets `disabled="disabled"`, will this work in dart?
    return this.disabled ||
        (isPresent(this.disabled) && StringWrapper.equals(this.disabled, "")) ||
        (isPresent(this.radioGroup) && this.radioGroup.disabled);
  }

  dynamic get disabled {
    return this.disabled_;
  }

  set disabled(dynamic value) {
    this.disabled_ = isPresent(value) && !identical(value, false);
  }

  /** Select this radio button. */
  select(Event event) {
    if (this.isDisabled()) {
      event.stopPropagation();
      return;
    }
    // Notifiy all radio buttons with the same name to un-check.
    this.radioDispatcher.notify(this.name);
    this.checked = true;
    if (isPresent(this.radioGroup)) {
      this.radioGroup.updateValue(this.value, this.id);
    }
  }

  /** Handles pressing the space key to select this focused radio button. */
  onKeydown(KeyboardEvent event) {
    if (event.keyCode == KeyCodes.SPACE) {
      event.preventDefault();
      this.select(event);
    }
  }
}
