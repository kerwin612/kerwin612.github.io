# Angular2 - how to call component function from outside the app

[Angular2 - how to call component function from outside the app](https://stackoverflow.com/questions/35296704/angular2-how-to-call-component-function-from-outside-the-app)

```typescript
function callbackfunction(){   
   // window['angularComponentRef'] might not yet be set here though
   window['angularComponent'].zone.run(() => {
     runThisFunctionFromOutside(); 
   });
 }

constructor(private _ngZone: NgZone){
  window['angularComponentRef'] = {component: this, zone: _ngZone};
}

ngOnDestroy() {
  window.angularComponent = null;
}
```

use:

```typescript
window['angularComponentRef'].zone.run(() => {window['angularComponentRef'].component.callFromOutside('1');})
```

OR

```typescript
window.angularComponentRef.zone.run(() => {window.angularComponentRef.componentFn('2');})
```

