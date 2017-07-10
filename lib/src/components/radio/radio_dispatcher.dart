library angular2_material.src.components.radio.radio_dispatcher;

import "package:angular2/core.dart" show Injectable;

/**
 * Class for radio buttons to coordinate unique selection based on name.
 * Indended to be consumed as an Angular service.
 */
@Injectable()
class MdRadioDispatcher {
  // TODO(jelbourn): Change this to TypeScript syntax when supported.
  List<Function> listeners_;
  MdRadioDispatcher() {
    this.listeners_ = [];
  }
  /** Notify other radio buttons that selection for the given name has been set. */
  notify(String name) {
    this.listeners_.forEach((listener) => listener(name));
  }

  /** Listen for future changes to radio button selection. */
  listen(listener) {
    this.listeners_.add(listener);
  }
}
