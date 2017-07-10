library angular2_material.test.button_spec;

import "package:angular2/testing_internal.dart"
    show
        AsyncTestCompleter,
        TestComponentBuilder,
        beforeEach,
        beforeEachProviders,
        ddescribe,
        describe,
        el,
        expect,
        iit,
        inject,
        it,
        xit;
import "package:angular2/core.dart"
    show Component, ViewMetadata, bind, provide, DebugElement;
import "package:angular2/compiler.dart" show UrlResolver;
import "package:angular2_material/src/components/button/button.dart"
    show MdButton, MdAnchor;
import "test_url_resolver.dart" show TestUrlResolver;

main() {
  describe("MdButton", () {
    TestComponentBuilder builder;
    beforeEachProviders(() => [
          // Need a custom URL resolver for ng-material template files in order for them to work

          // with both JS and Dart output.
          provide(UrlResolver, useValue: new TestUrlResolver())
        ]);
    beforeEach(inject([TestComponentBuilder], (tcb) {
      builder = tcb;
    }));
    describe("button[mdButton]", () {
      it(
          "should handle a click on the button",
          inject([AsyncTestCompleter], (async) {
            builder.createAsync(TestApp).then((fixture) {
              var testComponent = fixture.debugElement.componentInstance;
              var buttonDebugElement =
                  getChildDebugElement(fixture.debugElement, "button");
              buttonDebugElement.nativeElement.click();
              expect(testComponent.clickCount).toBe(1);
              async.done();
            });
          }),
          10000);
      it(
          "should disable the button",
          inject([AsyncTestCompleter], (async) {
            builder.createAsync(TestApp).then((fixture) {
              var testAppComponent = fixture.debugElement.componentInstance;
              var buttonDebugElement =
                  getChildDebugElement(fixture.debugElement, "button");
              var buttonElement = buttonDebugElement.nativeElement;
              // The button should initially be enabled.
              expect(buttonElement.disabled).toBe(false);
              // After the disabled binding has been changed.
              testAppComponent.isDisabled = true;
              fixture.detectChanges();
              // The button should should now be disabled.
              expect(buttonElement.disabled).toBe(true);
              // Clicking the button should not invoke the handler.
              buttonElement.click();
              expect(testAppComponent.clickCount).toBe(0);
              async.done();
            });
          }),
          10000);
    });
    describe("a[mdButton]", () {
      const anchorTemplate =
          '''<a mdButton href="http://google.com" [disabled]="isDisabled">Go</a>''';
      beforeEach(() {
        builder = builder.overrideView(TestApp,
            new ViewMetadata(template: anchorTemplate, directives: [MdAnchor]));
      });
      it(
          "should remove disabled anchors from tab order",
          inject([AsyncTestCompleter], (async) {
            builder.createAsync(TestApp).then((fixture) {
              var testAppComponent = fixture.debugElement.componentInstance;
              var anchorDebugElement =
                  getChildDebugElement(fixture.debugElement, "a");
              var anchorElement = anchorDebugElement.nativeElement;
              // The anchor should initially be in the tab order.
              expect(anchorElement.tabIndex).toBe(0);
              // After the disabled binding has been changed.
              testAppComponent.isDisabled = true;
              fixture.detectChanges();
              // The anchor should now be out of the tab order.
              expect(anchorElement.tabIndex).toBe(-1);
              async.done();
            });
            it(
                "should preventDefault for disabled anchor clicks",
                inject([AsyncTestCompleter], (async) {
                  // No clear way to test this; see https://github.com/angular/angular/issues/3782
                  async.done();
                }));
          }),
          10000);
    });
  });
}

/** Gets a child DebugElement by tag name. */
DebugElement getChildDebugElement(DebugElement parent, String tagName) {
  var el = parent
      .query((debugEl) => debugEl.nativeNode.tagName.toLowerCase() == tagName);
  return (el as DebugElement);
}

/** Test component that contains an MdButton. */
@Component(
    selector: "test-app",
    directives: const [MdButton],
    template:
        '''<button mdButton type="button" (click)="increment()" [disabled]="isDisabled">Go</button>''')
class TestApp {
  num clickCount = 0;
  bool isDisabled = false;
  increment() {
    this.clickCount++;
  }
}
