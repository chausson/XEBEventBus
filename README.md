# XEBEventBus
EventBus Object-C Version(EventBus 的Object-C语言版本)

#Install
```
  pod install
```

# How to Use

## 实现接收事件
EventBus采用订阅者的策略,接收Event事件的类需要注册成为订阅者对象并且遵守XEBSubscriber

``` obj-c
  @interface CHMessageEventCenter ()<XEBSubscriber>

  @end
  @implementation CHMessageEventCenter{
     + (instancetype)init{
        self = [super init];
         if (self){
              [[XEBEventBus defaultEventBus] registerSubscriber:self];
         }
         return self;
    }
  }

```

## 实现以下两个方法来订阅
*handleableEventClasses方法需要返回在当前订阅者中需要接收Event的类型
*当接收到event事件后会执行onEvent方法

``` obj-c
  - (void)onEvent: (id )event{
      // execute code 
  }
  + (NSArray<Class>*)handleableEventClasses {
    return @[[CHEvent class]];
  }
```

## 实现发送事件
CHEvent是一个自定义的Event对象，发送给订阅了该类型的对象，evnet中可以代入一些上下文内容
``` obj-c
  - (void)postEvent{
       CHEvent *event = [CHEvent new];

       [[XEBEventBus defaultEventBus] postEvent:event];
  }

```
