# angular 代码日记

**只能输入整数**

```javascript
<input input-number />

main.directive('inputNumber', [function () {
    // 仅能输入数字
    function isNumber(keyCode) {
        // 数字
        if (keyCode >= 48 &amp;&amp; keyCode <= 57 ) return true;
        // 小数字键盘
        if (keyCode >= 96 &amp;&amp; keyCode <= 105) return true;
        // Backspace键
        if (keyCode == 8) return true;
        return false;
    }
    return {
        restrict: 'A',
        require: 'ngModel',
        link: function (scope, element, attrs, ctrl) {
            element.bind('keydown', function (event) {
                if (!isNumber(event.keyCode || event.which) || event.altKey || event.ctrlKey || event.metaKey || event.shiftKey) {
                    event.preventDefault();
                }
            });
            ctrl.$validators.inputNumber = function (modelValue) {
                return !modelValue || /^\d+$/.test(modelValue);
            };
        }
    }
}]);
```

**不容许以下特殊字符“\#”、“&”、“&lt;”、“&gt;”、“?”、“/”、“\”、“\|”、“+”、“;”、“%”、“@”**

```javascript
main.directive('inputOthersId', [function () {
    //其他标识符自动作为PDRI后段码,不容许以下特殊字符
    //“#”、“&amp;”、“&lt;”、“&gt;”、“?”、“/”、“\”、“|”、“+”、“;”、“%”、“@”
    function isLegitimate(value) {
        if (!value)    return true;
        return /^[^#&amp;&lt;&gt;\?/\\|\+;%@\u4e00-\u9fa5]+$/.test(value);
    }
    function isRequisite(event, keyCode) {
        if ((event.shiftKey &amp;&amp; (
                keyCode == 50  || //@
                keyCode == 51  || //#
                keyCode == 53  || //%
                keyCode == 55  || //&amp;
                keyCode == 187 || //+
                keyCode == 188 || //&lt;
                keyCode == 190 || //&gt;
                keyCode == 191 || //?
                keyCode == 220    //|
                )) || 
            keyCode == 186 || //;
            keyCode == 191 || ///
            keyCode == 220    //\
        ) {
            return false;
        }
        return true;
    }
    return {
        restrict: 'A',
        require: 'ngModel',
        link: function (scope, element, attrs, ctrl) {
            element.bind('keydown', function (event) {
                if (!isRequisite(event, event.keyCode || event.which)) {
                    event.preventDefault();
                }
            });
            ctrl.$validators.inputOthersId = function (modelValue) {
                return !modelValue || isLegitimate(modelValue);
            };
        }
    }
}]);
```

**两个输入框的值合计长度为8**

```javascript
<input name="e1" total8-to="e2" />
<input name="e2" total8-to="e1" />

main.directive('total8To', ['$timeout', function ($timeout) {
    var commitAnotherValue = function (anotherModel) {
        var temp = anotherModel.$validators.total8To;
        anotherModel.$validators.total8To = function () {
            return true;
        };
        anotherModel.$validate();
        anotherModel.$validators.total8To = temp;
    }
    return {
        require: "ngModel",
        scope: {},
        link: function (scope, element, attributes, ngModel) {
            scope.another = (element &amp;&amp; element[0] &amp;&amp; element[0].form &amp;&amp; attributes &amp;&amp; attributes.total8To &amp;&amp; angular.element(element[0].form[attributes.total8To])) || null;
            ngModel.$validators.total8To = function (modelValue) {
                var anotherModel,anotherModelValue;
                if (!(anotherModel = scope.another &amp;&amp; scope.another.controller('ngModel'))) return true;
//                console.log('validator:'+ngModel.$name+',anotherModelValue:'+anotherModel.$name);
                var anotherModelValue = (anotherModel &amp;&amp; anotherModel.$viewValue) || null;
                if (anotherModelValue === null || anotherModelValue.trim() === ''
                    || modelValue === undefined || modelValue === null || modelValue === '')    return true;
                $timeout(function(){
                    commitAnotherValue(anotherModel); 
                    console.log(ngModel.$name+':'+ngModel.$modelValue+','+anotherModel.$name+':'+anotherModel.$modelValue);
                });
                return (modelValue + '' + anotherModelValue).length == 8;
            };
        }
    };
}]
);
```

**清除元素验证错误**

```javascript
$rootScope.clearElementError = function (element) {
    if (!element || !element.$name) {
        return;
    }
    if (element.$error) {
        var errors = element.$error;
        for (var error in errors) {
            element.$setValidity(error, true);
        }
    }
};
```

**清除元素值（调用清除错误）**

```javascript
$rootScope.clearElement = function (element) {
    if (!element || !element.$name) {
        return;
    }
    $rootScope.clearElementError(element);
    element.$setViewValue(undefined);
    element.$commitViewValue();
    element.$setPristine();
    element.$render();
};
```

**清除表单值**

```javascript
$rootScope.clearForm = function (form) {
    if (!form)    return true;
    for (var attr in form) {
        var element = form[attr];
        if (!element || !element.$name) {
            continue;
        }
        $rootScope.clearElement(element);
    }
    form.$setPristine();
};
```

**同步验证表单（包含唯一性验证）**

```javascript
如果表单里面有某个元素有唯一性等需要请求后端的验证，需要在directive里设置uniqueValidate函数
例如：
<input email-unique-validator />
main.directive('emailUniqueValidator', ['returnCodeService', function (returnCodeService) {
    //验证登录用户：使用的电子邮件格式、工号格式
    var WorkerEmailExistUrl = rootPath + '/pdri/prms/openapisys/v101/account/emailExist/:email';
    var WorkerEmailExistUrlM = rootPath + '/pdri/prms/openapisys/v101/account/emailExist/:workerId/:email';
    return {
        restrict: 'A',
        require: 'ngModel',
        link: function (scope, element, attrs, ctrl) {
            ctrl.uniqueValidate = function(success, faild) {
                var workerId = (element &amp;&amp; element[0]) ? element[0].getAttribute('email-unique-validator') : null;
                scope.uniqueValidate(ctrl, workerId ? WorkerEmailExistUrlM : WorkerEmailExistUrl, {email: ctrl.$viewValue, workerId: workerId}, null, success, faild);
            };
            element.bind('blur', function (event) {
                var form = null;
                var value = element.val();
                value = value ? value.trim() : value;
                //输入值需要符合，电子邮件和电话号码格式/^[1-9]{1}[0-9]*/   ^(?:13\d|15[89])-?\d{8}$
                if (((form = angular.element(event.currentTarget.form).controller('form')) &amp;&amp; form.validating === true)
                        || !(value &amp;&amp; scope.regular.EMAIL.test(value))) {
                    return;
                }
                ctrl.uniqueValidate(null);
            })
        }
    }
}
]);

调用：
$scope.validatForm($scope.modifyUserInfoForm, function () {
    dosometh...
}, function () {
    dosometh...
});


// 封装get请求
var getHttpResolver = function (url, params, $resource, $q) {
    var http = $resource(url, {}, {
        get: {
            method: 'GET',
            transformRequest: function (data) {
                return angular.toJson(data);
            },
            transformResponse: function (data) {
                return angular.fromJson(data);
            },
            headers: {
                'Cache-Control': 'no-cache',
                'Pragma': 'no-cache'
            }
        }
    });
    var methodName = function (params) {
        var deferredObj = $q.defer();
        http.get(params, function (data) {
            deferredObj.resolve(data);
        }, function (err) {
            deferredObj.reject(err);
        });
        return deferredObj.promise;
    };
    return methodName(params);
};

$rootScope.uniqueValidate = function (ngModel, url, params, custom, success, faild) {
    getHttpResolver(url, params, $resource, $q).then(
        function (data) {
            returnCodeService.processCode(data.errorCode, function () {
                if ((angular.isFunction(custom) &amp;&amp; !custom(data)) || data.data) {
                    ngModel.$setValidity('unique', false);
                    if (angular.isFunction(faild)) faild();
                } else {
                    ngModel.$setValidity('unique', true);
                    ngModel.$setValidity('errorCodeException', true);
                    ngModel.$setValidity('connectionException', true);
                    if (angular.isFunction(success)) {
                        success();
                    }
                }
            }, function () {
                ngModel.$setValidity('errorCodeException', false);
                //并绑定一次性事件，元素值改变时去掉“需要字符”的错误
                angular.element(document.getElementsByName(ngModel.$name)[0]).one('change', function (event) {
                    angular.element(event.currentTarget).controller('ngModel').$setValidity('errorCodeException', true);
                })
                if (angular.isFunction(faild)) faild();
            });
        },
        function (error) {
            ngModel.$setValidity('connectionException', false);
            //并绑定一次性事件，元素值改变时去掉“需要字符”的错误
            angular.element(document.getElementsByName(ngModel.$name)[0]).one('change', function (event) {
                angular.element(event.currentTarget).controller('ngModel').$setValidity('connectionException', true);
            })
            if (angular.isFunction(faild)) faild();
        }
    );
}
$rootScope.validatForm = function (form, success, faild) {
    if (!form || !form.$name || form.validating)    return true;
    console.log('validatForm:' + form.$name);
    form.$commitViewValue();
    form.validating = true;
    var elements = [];
    //为了保证元素顺序和html里面顺序一致，先得到原生的form对象，然后循环生成angular对象
    var fs = document.getElementsByName(form.$name)[0];
    for (var i = 0, j = fs.length; i < j; i++) {
        var obj = angular.element(fs[i]).controller('ngModel');
        if (!obj || !obj.$name) {
            continue;
        }
        elements.push(obj);
    }
    $rootScope.validatElement(elements, function () {
        if (angular.isFunction(success)) {
            success();
        }
        form.validating = false;
    }, function () {
        if (angular.isFunction(faild)) {
            faild();
        }
        form.validating = false;
    });
};
$rootScope.validatElement = function (elements, success, faild) {
    var element = elements ? elements[0] : null;
    if (element &amp;&amp; element.$name) {
        $rootScope.clearElementError(element);
        element.$validate();
        var isValid = false;
        if (element &amp;&amp; element.$invalid) {    //验证不通过
        } else if (!element.$invalid &amp;&amp; (element.$modelValue === undefined || element.$modelValue === null || element.$modelValue === '')) {    //验证通过，且值为空
            //需求：元素本身不用添加required验证，等到提交的时候再去判断
            //获取该元素的元素dom对象
            var dom = document.getElementsByName(element.$name)[0];
            //判断是否允许为空
            var allowEmpty = dom.getAttribute('allow-empty');
            if (allowEmpty !== 'true') {
                //如果不允许为空，则设置“需要字符”的错误
                element.$setValidity('required', false);
                //并绑定一次性事件，元素值改变时去掉“需要字符”的错误
                angular.element(dom).one('change', function (event) {
                    angular.element(event.currentTarget).controller('ngModel').$setValidity('required', true);
                })
            } else {
                isValid = true;
            }
        } else {
            isValid = true;
        }
        elements.splice(0, 1);
        if (isValid) {
            if (angular.isFunction(element.uniqueValidate)) {
                element.uniqueValidate(function () {
                    $rootScope.validatElement(elements, success, faild);
                }, function () {
                    for (var i = 0, j = elements.length; i < j; i++) {
                        $rootScope.clearElementError(elements[i]);
                    }
                    faild();
                    document.getElementsByName(element.$name)[0].focus();
                });
            } else {
                $rootScope.validatElement(elements, success, faild);
            }
        } else {
            if (angular.isFunction(faild)) {
                faild();
            }
            for (var i = 0, j = elements.length; i < j; i++) {
                $rootScope.clearElementError(elements[i]);
            }
            element.$setDirty();
            document.getElementsByName(element.$name)[0].focus();
            console.log('validatElement:' + "[" + element.$name + ":" + angular.toJson(element.$error) + "]");
            return false;
        }
    } else {
        if (angular.isFunction(success)) {
            success();
        }
        return true;
    }
}
```

**IE9不支持placeholer的解决方案**

```javascript
/**
 * Placeholder for non-HTML5 browsers ... specifically IE8 and IE9, but also
 * works with Firefox 3 and possibly others.
 *
 * Always toggles on/off the placeholder class (default is "placeholder").
 * Shims in the visual effects for older IE.
 *
 * Quick Usage:
 *
 *     &lt;input ng-model="xyz" placeholder="Enter Value" /&gt;
 *
 *     &lt;textarea ng-model="xyz" placeholder="Enter Value"
 *         placeholder-class="placeholder"&gt;&lt;/textarea&gt;
 *
 * Styling:
 *
 * Browsers still use specific placeholder selectors.  IE8 and 9 can now style
 * the text with a `placeholder` class.
 *
 *     .placeholder { color: red; }
 *
 * @link https://github.com/tests-always-included/angular-placeholder
 * @license MIT
 */


/*global angular*/
(function (undef) {
    "use strict";

    var propName, needsShimByNodeName;

    propName = 'placeholder';
    needsShimByNodeName = {};

    angular.module("taiPlaceholder", []).directive("placeholder", [
        "$document",
        "$timeout",
        function ($document, $timeout) {

            if ('placeholder' in document.createElement('input'))     return {};

            // Determine if we need to perform the visual shimming
            angular.forEach([ 'INPUT', 'TEXTAREA' ], function (val) {
                needsShimByNodeName[val] = $document[0].createElement(val)[propName] === undef;
            });

            /**
             * Determine if a given type (string) is a password field
             *
             * @param {string} type
             * @return {boolean}
             */
            function isPasswordType(type) {
                return type &amp;&amp; type.toLowerCase() === "password";
            }

            return {
                require: "^ngModel",
                restrict: "A",
                link: function ($scope, $element, $attributes, $controller) {
                    /*jslint unparam:true*/
                    var className, needsShim, text;

                    text = $attributes[propName]; if (!text)    return;
                    className = $attributes[propName + "Class"] || propName;
                    needsShim = needsShimByNodeName[$element[0].nodeName];

                    var isPwd = isPasswordType($element.prop("type"));

                    // On blur, check the value.  If nothing is entered then
                    // add the placeholder class and text.
                    $element.bind("blur", function () {
                        var currentValue;

                        currentValue = $element.val();

                        if (!currentValue) {
                            if (isPwd) $element.attr('type', 'text');
                            $element.addClass(className);

                            if (needsShim) {
                                /* Add a delay so the value isn't assigned to
                                 * scope.  Issue #9
                                 */
                                $timeout(function () {
                                    $element.val(text);
                                }, 1);
                            }
                        }
                    });

                    // When focused, check if the field has the placeholder
                    // class.  If so, wipe the field out.
                    $element.bind("focus", function () {
                        if (needsShim &amp;&amp; $element.hasClass(className)) {
                            $element.val("");
                        }

                        $element.removeClass(className);
                        if (isPwd) $element.attr('type', 'password');
                    });

                    if (needsShim) {
                        // This determines if we show placeholder text or not
                        // when there was a change detected on scope.
                        $controller.$formatters.unshift(function (val) {

                            // When there is a value, this is not a placeholder.
                            if (val) {
                                $element.removeClass(className);

                                return val;
                            }

                            if (isPwd) $element.attr('type', 'text');
                            $element.addClass(className);
                            $timeout(function () {
                                $element.val(text);
                            }, 1);
                            return null;
                        });
                    }
                }
            };
        }
    ]);
}());
```

**ngDialog封装的公共弹窗（模板需要自己替换）**

```javascript
/**
 * <br>《确认》弹窗
 * <br>ngDialog     angular的ngDialog对象
 * <br>title        窗口的标题
 * <br>enterTitle    确认按钮的名称
 * <br>cancelTitle    取消按钮的名称
 * <br>enterFun        确认按钮的事件
 * <br>cancelFun    取消按钮的事件
 * <br>ConfirmDialog(ngDialog, title, enterFun);
 * <br>ConfirmDialog(ngDialog, title, enterFun, cancelFun);
 * <br>ConfirmDialog(ngDialog, title, enterTitle, cancelTitle, enterFun);
 * <br>ConfirmDialog(ngDialog, title, enterTitle, cancelTitle, enterFun, cancelFun);
 */
function ConfirmDialog() {
    var ngDialog, title, enterTitle, cancelTitle, enterFun, cancelFun;
    var len = arguments.length; 
    if (len < 3) {
        return null;
    }
    ngDialog = arguments[0];
    title = arguments[1];
    if (len == 3) {
        enterFun = arguments[2];
    } else if (len == 4) {
        enterFun = arguments[2];
        cancelFun = arguments[3];
    } else if (len == 5) {
        enterTitle = arguments[2];
        cancelTitle = arguments[3];
        enterFun = arguments[4];
    } else {
        enterTitle = arguments[2];
        cancelTitle = arguments[3];
        enterFun = arguments[4];
        cancelFun = arguments[5];
    }
    var dialog = ngDialog.open({
        template:  '<div class="popup pop_warning">' +
                        '<div class=" popup_static">' + 
                            '<div class="pop_cont "><p><span>'+title+'</span></p></div>' + 
                            '<div class="pop_foot">' + 
                                '<button type="submit" class="btn_pop btn_primary_pop" onclick="popClick(\'y\')">' +
                                    (enterTitle ? enterTitle : '{{\'btnOk\'|translate}}') +
                                '</button>' + 
                                '<button type="button" class="btn_pop btn_default_pop " onclick="popClick(\'n\')">' +
                                    (cancelTitle ? cancelTitle : '{{\'btnCancel\'|translate}}') +
                                '</button>' + 
                            '</div>' + 
                        '</div>' + 
                    '</div>',
        plain: true,
        showClose:false,
        controller: [function () {
            var isEnter, isCancel;
            popClick = function (val) {
                var isClose;
                if ("y" === val &amp;&amp; enterFun) {
                    if (isEnter)     return;
                    isEnter = true;
                    isClose = enterFun(dialog);
                } else {
                    if (isCancel)     return;
                    isCancel = true;
                }
                if (isClose !== false) {
                    dialog.close();
                }
            }
        }],
        preCloseCallback: function () {
            if (cancelFun) {
                cancelFun(dialog);
            }
        }
    })
    return dialog;
}
```

**取值的封装避免空指针**

```javascript
/**
 * <br>获取对象属性值
 * <br>obj     对象
 * <br>key    属性名
 * <br>def    默认值
 * <br>fun    处理函数(属性值为函数的参数)
 * <br>hasValue(obj, key);
 * <br>hasValue(obj, key, def);
 * <br>hasValue(obj, key, fun);
 * <br>hasValue(obj, key, def, fun);
 */
function hasValue() {
    var len = arguments.length;
    if (len < 2) return false;
    var obj, key, def, fun;
    obj = arguments[0] || {};
    key = arguments[1] || '';
    def = (len >= 3 &amp;&amp; !angular.isFunction(arguments[2]) ? arguments[2] : null);
    fun = (len == 3 &amp;&amp; angular.isFunction(arguments[2]) ? arguments[2] : (len == 4 ? arguments[3] : null));
    var value = ((key &amp;&amp; angular.isObject(obj) &amp;&amp; obj.hasOwnProperty(key) &amp;&amp; obj[key]) || null) || def;
    return fun ? fun(value) : value;
}
```

