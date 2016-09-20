# AngularJS Directive 隔离 Scope 数据交互

####什么是隔离 Scope
>AngularJS 的 `directive` 默认能共享父 `scope` 中定义的属性，例如在模版中直接使用父 scope 中的对象和属性。通常使用这种直接共享的方式可以实现一些简单的 directive 功能。当你需要创建一个**可重复使用的 `directive`**，只是偶尔需要访问或者修改父 scope 的数据，就需要使用**隔离 `scope`**。当使用隔离 scope 的时候，directive 会创建一个**没有依赖父 `scope`** 的 scope，并提供一些访问父 scope 的方式。  

