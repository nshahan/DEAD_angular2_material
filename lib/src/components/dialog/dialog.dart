library angular2_material.src.components.dialog.dialog;

import "dart:async";
import "dart:html";
import "package:angular2/core.dart"
    show
        bind,
        provide,
        Component,
        ComponentRef,
        Directive,
        DynamicComponentLoader,
        ElementRef,
        Host,
        Injectable,
        ResolvedProvider,
        SkipSelf,
        Injector,
        ViewEncapsulation;
import "package:angular2/src/facade/async.dart"
    show ObservableWrapper, PromiseWrapper;
import "package:angular2/src/facade/lang.dart" show isPresent, Type;
import "package:angular2/src/platform/dom/dom_adapter.dart" show DOM;
import "package:angular2/src/facade/browser.dart"
    show MouseEvent, KeyboardEvent;
import "package:angular2_material/src/core/key_codes.dart" show KeyCodes;
import "package:angular2/src/facade/promise.dart" show PromiseCompleter;
// TODO(jelbourn): Opener of dialog can control where it is rendered.

// TODO(jelbourn): body scrolling is disabled while dialog is open.

// TODO(jelbourn): Don't manually construct and configure a DOM element. See #1402

// TODO(jelbourn): Wrap focus from end of dialog back to the start. Blocked on #1251

// TODO(jelbourn): Focus the dialog element when it is opened.

// TODO(jelbourn): Real dialog styles.

// TODO(jelbourn): Pre-built `alert` and `confirm` dialogs.

// TODO(jelbourn): Animate dialog out of / into opening element.

/**
 * Service for opening modal dialogs.
 */
@Injectable()
class MdDialog {
  DynamicComponentLoader componentLoader;
  MdDialog(DynamicComponentLoader loader) {
    this.componentLoader = loader;
  }
  /**
   * Opens a modal dialog.
   * 
   * 
   * 
   * 
   */
  Future<MdDialogRef> open(Type type, ElementRef elementRef,
      [MdDialogConfig options = null]) {
    var config = isPresent(options) ? options : new MdDialogConfig();
    // Create the dialogRef here so that it can be injected into the content component.
    var dialogRef = new MdDialogRef();
    var bindings =
        Injector.resolve([provide(MdDialogRef, useValue: dialogRef)]);
    var backdropRefPromise = this._openBackdrop(elementRef, bindings);
    // First, load the MdDialogContainer, into which the given component will be loaded.
    return this
        .componentLoader
        .loadNextToLocation(MdDialogContainer, elementRef)
        .then((ComponentRef containerRef) {
      // TODO(tbosch): clean this up when we have custom renderers

      // (https://github.com/angular/angular/issues/1807)

      // TODO(jelbourn): Don't use direct DOM access. Need abstraction to create an element

      // directly on the document body (also needed for web workers stuff).

      // Create a DOM node to serve as a physical host element for the dialog.
      var dialogElement = containerRef.location.nativeElement;
      DOM.appendChild(DOM.query("body"), dialogElement);
      // TODO(jelbourn): Do this with hostProperties (or another rendering abstraction) once

      // ready.
      if (isPresent(config.width)) {
        DOM.setStyle(dialogElement, "width", config.width);
      }
      if (isPresent(config.height)) {
        DOM.setStyle(dialogElement, "height", config.height);
      }
      dialogRef.containerRef = containerRef;
      // Now load the given component into the MdDialogContainer.
      return this
          .componentLoader
          .loadNextToLocation(type, containerRef.instance.contentRef, bindings)
          .then((ComponentRef contentRef) {
        // Wrap both component refs for the container and the content so that we can return

        // the `instance` of the content but the dispose method of the container back to the

        // opener.
        dialogRef.contentRef = contentRef;
        containerRef.instance.dialogRef = dialogRef;
        backdropRefPromise.then((ComponentRef backdropRef) {
          dialogRef.whenClosed.then((_) {
            backdropRef.dispose();
          });
        });
        return dialogRef;
      });
    });
  }

  /** Loads the dialog backdrop (transparent overlay over the rest of the page). */
  Future<ComponentRef> _openBackdrop(
      ElementRef elementRef, List<ResolvedProvider> bindings) {
    return this
        .componentLoader
        .loadNextToLocation(MdBackdrop, elementRef, bindings)
        .then((ComponentRef componentRef) {
      // TODO(tbosch): clean this up when we have custom renderers

      // (https://github.com/angular/angular/issues/1807)
      var backdropElement = componentRef.location.nativeElement;
      DOM.addClass(backdropElement, "md-backdrop");
      DOM.appendChild(DOM.query("body"), backdropElement);
      return componentRef;
    });
  }

  Future<dynamic> alert(String message, String okMessage) {
    throw "Not implemented";
  }

  Future<dynamic> confirm(
      String message, String okMessage, String cancelMessage) {
    throw "Not implemented";
  }
}

/**
 * Reference to an opened dialog.
 */
@Injectable()
class MdDialogRef {
  // Reference to the MdDialogContainer component.
  ComponentRef containerRef;
  // Reference to the Component loaded as the dialog content.
  ComponentRef _contentRef;
  // Whether the dialog is closed.
  bool isClosed;
  // Deferred resolved when the dialog is closed. The promise for this deferred is publicly exposed.
  PromiseCompleter<dynamic> whenClosedDeferred;
  // Deferred resolved when the content ComponentRef is set. Only used internally.
  PromiseCompleter<dynamic> contentRefDeferred;
  MdDialogRef() {
    this._contentRef = null;
    this.containerRef = null;
    this.isClosed = false;
    this.contentRefDeferred = PromiseWrapper.completer();
    this.whenClosedDeferred = PromiseWrapper.completer();
  }
  set contentRef(ComponentRef value) {
    this._contentRef = value;
    this.contentRefDeferred.resolve(value);
  }

  /** Gets the component instance for the content of the dialog. */
  get instance {
    if (isPresent(this._contentRef)) {
      return this._contentRef.instance;
    }
    // The only time one could attempt to access this property before the value is set is if an

    // access occurs during

    // the constructor of the very instance they are trying to get (which is much more easily

    // accessed as `this`).
    throw "Cannot access dialog component instance *from* that component's constructor.";
  }

  /** Gets a promise that is resolved when the dialog is closed. */
  Future<dynamic> get whenClosed {
    return this.whenClosedDeferred.promise;
  }

  /** Closes the dialog. This operation is asynchronous. */
  close([dynamic result = null]) {
    this.contentRefDeferred.promise.then((_) {
      if (!this.isClosed) {
        this.isClosed = true;
        this.containerRef.dispose();
        this.whenClosedDeferred.resolve(result);
      }
    });
  }
}

/** Confiuration for a dialog to be opened. */
class MdDialogConfig {
  String width;
  String height;
  MdDialogConfig() {
    // Default configuration.
    this.width = null;
    this.height = null;
  }
}

/**
 * Container for user-provided dialog content.
 */
@Component(
    selector: "md-dialog-container",
    host: const {
      "class": "md-dialog",
      "tabindex": "0",
      "(body:keydown)": "documentKeypress(\$event)"
    },
    encapsulation: ViewEncapsulation.None,
    templateUrl: "package:angular2_material/src/components/dialog/dialog.html",
    directives: const [MdDialogContent])
class MdDialogContainer {
  // Ref to the dialog content. Used by the DynamicComponentLoader to load the dialog content.
  ElementRef contentRef;
  // Ref to the open dialog. Used to close the dialog based on certain events.
  MdDialogRef dialogRef;
  MdDialogContainer() {
    this.contentRef = null;
    this.dialogRef = null;
  }
  wrapFocus() {}
  documentKeypress(KeyboardEvent event) {
    if (event.keyCode == KeyCodes.ESCAPE) {
      this.dialogRef.close();
    }
  }
}

/**
 * Simple decorator used only to communicate an ElementRef to the parent MdDialogContainer as the
 * location
 * for where the dialog content will be loaded.
 */
@Directive(selector: "md-dialog-content")
class MdDialogContent {
  MdDialogContent(@Host() @SkipSelf() MdDialogContainer dialogContainer,
      ElementRef elementRef) {
    dialogContainer.contentRef = elementRef;
  }
}

/** Component for the dialog "backdrop", a transparent overlay over the rest of the page. */
@Component(
    selector: "md-backdrop",
    host: const {"(click)": "onClick()"},
    template: "",
    encapsulation: ViewEncapsulation.None)
class MdBackdrop {
  MdDialogRef dialogRef;
  MdBackdrop(MdDialogRef dialogRef) {
    this.dialogRef = dialogRef;
  }
  onClick() {
    // TODO(jelbourn): Use MdDialogConfig to capture option for whether dialog should close on

    // clicking outside.
    this.dialogRef.close();
  }
}
