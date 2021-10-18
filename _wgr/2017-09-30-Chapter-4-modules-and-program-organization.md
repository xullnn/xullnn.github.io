---
title:  "Rubyist-c4-Modules and program organization"
categories: [Ruby/Rails ℗]
tags: [Ruby & Rails, Notes of Rubyist]
---



*注：这一系列文章是《The Well-Grounded Rubyist》的学习笔记。*



---

**A module encapsulating stacklikeness**

As you may know from previous studies," a stack is a data structure that operates on the last in, first out (LIFO) principle. The classic example is a (physical) stack of plates. The first plate to be used is the last one placed on the stack. Stacks are usually discussed paired with queues, which exhibit first in, first out (FIFO) behavior. Think of a cafeteria: the plates are in a stack; the customers are in a queue.

stack 是一种遵循 last in, first out (后进先出)原则的数据结构。典型的例子是一叠盘子，后放上去的，之后却会最先用到。 stacks 通常与 queues 成对讨论，后者遵循的是 first in first out 原则。可以这么思考： 盘子以 stack 原则使用；顾客以 queue 原则行事。

Numerous items behave in a stacklike, LIFO manner. The last sheet of printer paper you put in the tray is the first one printed on. Double-parked cars have to leave in an order that’s the opposite of the order of their arrival. The quality of being stacklike can manifest itself in a wide variety of collections and aggregations of entities.
很多东西都以stack原则——last in first out——行事。打印机中最后放上去的纸会最先被用到。两辆停在一起的车会是后停的先走，之后先停进去的才能离开。很多不同的集合实体都能表现出 stacklike 特性。

That’s where modules come in. When you’re designing a program and you identify a behavior or set of behaviors that may be exhibited by more than one kind of entity or object, you’ve found a good candidate for a module. Stacklikeness fits the bill: more than one entity, and therefore imaginably more than one class, exhibit stacklike behavior. By creating a module that defines methods that all stacklike objects have in common, you give yourself a way to summon stacklikeness into any and all classes that need it.

这也是 module 发挥作用的地方。当你设计一个程序时，你需要一个或一系列展现出不止一类对象的特点的行为，那你就找到了好的 module 候选。 堆栈性适合这个情况：不止一个实体，甚至不止一个class，都展现出堆栈性。在一个module 中定义好所有具有堆栈性的对象所共有的方法methods，你就在所有需要堆栈性的 classes 中引入了堆栈性。

```ruby
module Stacklike
  def stack
    @stack ||= []
  end

  def add_to_stack(obj)
    stack.push(obj)
  end

  def take_from_stack
    stack.pop
  end
end
```


```ruby
2.5.0 :002 > load './stacklike.rb'
 => true
2.5.0 :003 > s = Stacklike.new
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):3
NoMethodError (undefined method `new' for Stacklike:Module)
2.5.0 :004 > require_relative 'stacklike'
 => true
2.5.0 :005 > class Stack
2.5.0 :006?>   include Stacklike
2.5.0 :007?> end
 => Stack
2.5.0 :008 > s = Stack.new
 => #<Stack:0x00007ff1260a96e0>
2.5.0 :009 > s.add_to_stack("item one")
 => ["item one"]
2.5.0 :010 > s.add_to_stack("item two")
 => ["item one", "item two"]
2.5.0 :011 > s.add_to_stack("item three")
 => ["item one", "item two", "item three"]
2.5.0 :012 > puts s.stack
item one
item two
item three
 => nil
2.5.0 :013 > taken = s.take_from_stack
 => "item three"
2.5.0 :014 > puts taken
item three
 => nil
2.5.0 :015 > puts s.stack
item one
item two
 => nil
```

但在上面例子中，这些方法都可以直接写在 class Stack 而得到相同的结果。那么 module 的用处是什么？

Before you conclude that modules are pointless, remember what the modularization buys you: it lets you apply a general concept like stacklikeness to several cases, not just one.

在你得出module没什么意义的结论之前，记住 module 化的作用：他能提供给你更加一般化(普遍化)的概念比如堆栈性到多个案例中，而不只是一个。

-

That’s because **require and load take strings as their arguments**, whereas **include takes the name of a module in the form of a constant**. More fundamentally, it’s because require and load are locating and loading disk files, whereas include and prepend perform a program-space, in-memory operation that has nothing to do with files. It’s a common sequence to require a feature and then include a module that the feature defines. The two operations thus often go together, but they’re completely different from each other.

require/load 和 include/prepend 的区别在于

前者是针对 文件 的操作。

后者是对 constant 常量的操作,是程序空间，内存中的操作，与文件操作无关。

这两个指令通常同时出现完成 mixing 的操作，首先 require 一个文件（功能），接着 include 这个文件中的 module 来引入其中写的methods。但二者仍然是不同的概念。

-

**Using the module further**

A few examples came up earlier: plates, printer paper, and so forth. Let’s use a new one, borrowed from the world of urban legend.
之前提到的一些例子：盘子，打印机中的纸等，下面我们用一个新的，借用自都市传奇的世界。

Lots of people believe that if you’re the first passenger to check in for a flight, your luggage will be the last off the plane. Real-world experience suggests that it doesn’t work this way. Still, for stack practice, let’s see what a Ruby model of an urban-legendly-correct cargo hold would look like.
许多人认为坐飞机的时候第一个进去的乘客的行李会被放在最下面。实际世界中并不是这样。来看看Ruby如何模拟这个情况。

To model it reasonably closely, we’ll define the following:
为了尽量贴近现实，我们会这样做：
 
1 A barebones Suitcase class: a placeholder (or stub) that lets us create suitcase objects to fling into the cargo hold.
一个基础的 Suitcase 类： 只是为了能够构架出 suitcase 对象让 运输机能拿到它。

2 A CargoHold class with two methods: load_and_report and unload.
一个 CargoHold 类带有两个方法： load_and_report 以及 unload

* load_and_report prints a message reporting that it’s adding a suitcase to the cargo hold, and it gives us the suitcase object’s ID number, which will help us trace what happens to each suitcase.
load_and_report 方法会在拿到一个 suitcase 对象时报告这个对象的 ID 以便我们追踪。

* unload calls take_from_stack. We could call take_from_stack directly, but unload sounds more like a term you might use to describe removing a suitcase from a cargo hold.
unload 方法会呼叫到 take_from_stack 方法。我们直接在unload 方法内部呼叫 take_from_stack ，只不过使用 unload 名称包裹听起来更契合这个例子的语境。

Put the code in the next listing into cargohold.rb, and run it.
```ruby
require_relative 'stacklike'
class Suitcase
end
class CargoHold
  include Stacklike
  def load_and_report(obj)
    print "Loading objet "
    puts obj.object_id
    add_to_stack(obj)
  end

  def unload
    take_from_stack
  end
end

ch = CargoHold.new
sc1 = Suitcase.new
sc2 = Suitcase.new
sc3 = Suitcase.new
ch.load_and_report(sc1)
ch.load_and_report(sc2)
ch.load_and_report(sc3)
first_unloaded = ch.unload
print "The first suitcase off the plane is ..."
puts first_unloaded.object_id
```

The output from the cargo-hold program looks like this (remember that suitcases are referred to by their object ID numbers, which may be different on your system):

```ruby
2.5.0 :002 > load './cargohold.rb'
Loading objet 70102091429060
Loading objet 70102091428980
Loading objet 70102091428940
The first suitcase off the plane is ...70102091428940
 => true
```

The cargo-hold example shows how you can use an existing module for a new class. Sometimes it pays to wrap the methods in new methods with better names for the new domain (like unload instead of take_from_stack), although if you find yourself changing too much, it may be a sign that the module isn’t a good fit.
cargohold 的例子演示了如何在class 中引入一个已经存在的module。有时可能会使用新的方法名称包裹module 中的method。但如果在引入 module 后你需要做大量的修改，那么就说明这个module 可能并不是适合这里。

In the next section, we’ll put together several of the pieces we’ve looked at more or less separately: method calls (message sending), objects and their status as instances of classes, and the mixing of modules into classes. All these concepts come together in the process by which an object, upon being sent a message, looks for and finds (or fails to find) a method to execute whose name matches the message.

下面我们会把之前提到的几个点串起来： 呼叫方法（送出message）， 对象以及他们作为class的实例的状态，以及 module 的混入。 所有这些内容会出现在: 送出 message 给一个 object ，object 去找对应名称的 methods 的进程中。

—

**Modules, classes, and method lookup**

You already know that when an object receives a message, the intended (and usual) result is the execution of a method with the same name as the message in the object’s class or that class’s superclass—and onward, up to the Object or even BasicObject class—or in a module that has been mixed into any of those classes. But how does this come about? And what happens in ambiguous cases—for example, if a class and a mixed-in module both define a method with a given name? Which one does the object choose to execute?
我们已经知道当一个object 接受到一个 message 时， 会去找对应名称的方法——在object自己所在的class 或这个class的superclasses， 沿着这个路径一直往上直到 Object 甚至 BasicObject，或者任何 混入(mix in) 这些classes 的module 中。但这一切是怎么发生的，在可能出现歧义的例子中会怎么样——比如混入两个有同名methods 的module。object会选择哪个执行？

It pays to answer these questions precisely. Imprecise accounts of what happens are easy to come by. Sometimes they’re even adequate: if you say, "This object has a push method," you may succeed in communicating what you’re trying to communicate, even though objects don’t "have" methods but, rather, find them by searching classes and modules.
这个问题值得进行更精确的回答。 不精确的回答也说的过去，甚至有时也够了： 如果你说"这个object有一个叫 `push` 的方法"， 其实就已经达到交流的目的了，即使这object自己的class中并没有写push这个方法，而是从其他module中引入的。

But an imprecise account won’t scale. It won’t help you understand what’s going on in more complex cases, and it won’t support you when you’re designing your own code. Your best course of action is to learn what really happens when you send messages to objects.
但一个不精确的回答不具有拓展性。它不能帮助你理解复杂案例中实际发生了什么，也不能帮助你设计你自己的代码。最好的方法是学习在送message给一个object时，到底发生了什么。

Fortunately, the way it works turns out to be straightforward.

-

**How far does the method search go?**

Ultimately, every object in Ruby is an instance of some class descended from the big class in the sky: BasicObject. However many classes and modules it may cross along the way, the search for a method can always go as far up as BasicObject. But recall that the whole point of BasicObject is that it has few instance methods. Getting to know BasicObject doesn’t tell you much about the bulk of the methods that all Ruby objects share.
不管如何，到最后每一个object都是某个class的实例，而这个class都会是顶层类BasicObject的subclasses之一。这也是方法搜索最终能够到达的地方，但在BasicObject只有极少量的方法存在。


If you want to understand the common behavior and functionality of all Ruby objects, you have to descend from the clouds and look at Object rather than Basic-Object. More precisely, you have to look at Kernel, a module that Object mixes in. It’s in Kernel (as its name suggests) that most of Ruby’s fundamental methods objects are defined. And because Object mixes in Kernel, all instances of Object and all descendants of Object have access to the instance methods in Kernel.
如果想要理解所有ruby对象的共同行为和功能，我们需要让class继承自Object而不是BasicObject。更准确地说，我们要着眼于 Kernel ， 这个被 Object 混入的 module。ruby 对象的绝大多数方法都在这个module中被定义。由于Object混入了 module Kernel ， Object的实例也就能使用所有 Kernel 中定义的方法。

Suppose you’re an object, and you’re trying to find a method to execute based on a message you’ve received. If you’ve looked in Kernel and BasicObject and you haven’t found it, you’re not going to. (It’s possible to mix modules into BasicObject, thus providing all objects with a further potential source of methods. It’s hard to think of a case where you’d do this, though.)
假设你是一个 object， 你正在尝试寻找一个方法。如果你最后在 Kernel 和 BasicObject 中都没有找到，那么你就找不到了。虽然我们也可以在 BasicObject 中混入 module, 这样可以给更多个 objects 提供方法，但几乎找不到必须这么做的案例。（在Object中引入就足够了）

Figure 4.1 illustrates the method search path from our earlier example (the class D object) all the way up the ladder. In the example, the search for the method succeeds at module M; the figure shows how far the object would look if it didn’t find the method there. When the message x is sent to the object, the method search begins, hitting the various classes and mix-ins (modules) as shown by the arrows.


```ruby
module M
  def report
    puts "'report' method in module M"
  end
end

class C
  include M
end

class D < C
end

obj = D.new
obj.report
```

输出

```ruby
2.5.0 :004 > load './lookup_path.rb'
'report' method in module M
 => true
```


![](https://ws4.sinaimg.cn/large/006tNc79ly1fnsswjvl2kj30rk0y0gts.jpg)

The internal definitions of BasicObject, Object, and Kernel are written in the C language. But you can get a reasonable handle on how they interact by looking at a Ruby mockup of their relations:

BasicObject, Object以及Kernel 的内部定义都是用C语言写的，但是下面的代码可以解释他们之间的互动关系。

```ruby
class BasicObject
  # a scant seven method definitions go here
end

module Kernel
  # over 100 method definitions go here!
end

class Object < BasicObject
  # one or two private methods go here,
  # but the main point is to mix in the Kernel module
  include Kernel
end
```

-

BasicObject , Object, Kernel 里面定义的方法都是用 C 语言写的

BasicObject 中只有 7 个 method

Kernel 中则有100个 method

Object 中有少量 private method, 但它存在的主要目的是 include Kernel


—

Ruby 中当我们让一个对象执行一个 method 时，它会首先在自己的 class 和 mixin 的 module 或者 superclass 中找，如果没找到则沿着路径一直往上，直到 BasicObject ，但实际上 BasicObject 没有太多可以给ruby对象用的方法

事实上最常用，最多用到的 methods 在 Kernel 这个 module 中， 它被 Object 这个 class include 到，所以如果要了解更多关于 method 的信息，应该到 kernel 中看看

—

一个 class中 中如果写了两个 同名 的 method 那么后写(新写)的那个会覆盖掉前面的那个

由于 mixing 的存在，导致有可能出现 多个同名 method 的情况，ruby 对此有几个原则。一个总的原则是，使用lookup path中先遇到的第一个

1 include 的 module 中有一个 method 与当前 module 已存在的method 重名。这种情况下，当前 module 中的优先

2 include 了多个 module , 其中不同module 中有同名的method。这种情况代码位置靠下的优先。下面的例子中 N 中的method 会盖掉 M 中的

3 某个 module 被 include 了多次

```ruby
module M
  def report
    puts "'report' method in module M"
  end
end

module N
  def report
    puts "'report' method in module N"
  end
end

class C
  include M
  include N
end
```

上面的例子执行 report 方法结果会是

```ruby
2.5.0 :002 > load './multi_include.rb'
 => true
2.5.0 :003 > C.new.report
'report' method in module N
 => nil
```

如果是

```ruby
class C
  include M
  include N
  include M
end
```
按照2中的逻辑似乎该是 最下方的 M 优先，但实际上第二次 include 同名 module 是无效的，因此结果还是 N

```ruby
2.5.0 :001 > load './multi_include.rb'
 => true
2.5.0 :002 > C.new.report
'report' method in module N
 => nil
```

-

prepend 和 include 功能相同，都是用来引入 module  的

但一个重要不同是

prepend 会 优先于 引入他的 class 这一点与 include 相反，也就是如果一个 class prepend 了一个 module 当调用这个 class 中的 method 时，ruby 会先去到被 prepend 的那个 module 中找，如果找不到再返回 class 内部找，找不到再到被include的module中找


![](https://ws3.sinaimg.cn/large/006tNc79ly1fnstejdiztj30t60ny0yw.jpg)

比如下面的例子

```ruby
module Greet
  def say_hi
    puts "Hi, I am Greet"
  end
end

class Person
  prepend Greet
  def say_hi
    puts "Hi, I am Person"
  end
end

p Person.ancestors
```

输出是

```ruby
2.5.0 :001 > load './prepend.rb'
[Greet, Person, Object, Kernel, BasicObject]
 => true
2.5.0 :002 >
```

然后把prepend 改成 include 看看继承链上顺序的变化

```ruby
2.5.0 :001 > load './prepend.rb'
[Person, Greet, Object, Kernel, BasicObject]
 => true
```

被class prepend的module 会在 lookup path 中出现在 class 之前的位置。

使用 .ancestors 可以查看某个 class对象的祖先血统

```ruby
2.5.0 :002 > class Person; end
 => nil
2.5.0 :003 > Person.ancestors
 => [Person, Object, Kernel, BasicObject]
```

You can use prepend when you want a module’s version of one or more methods to take precedence over the versions defined in a given class. As mentioned earlier, prepend is new in Ruby 2.0. You won’t see it used much, at least not yet. But it’s useful to know it’s there, both so that you can use it if you need it and so that you’ll know what it means if you encounter it in someone else’s code.

`prepend` 是2.0之后才出现的，你不会看到他经常出现，但是知道他的存在是必要的。至少你知道怎么用或者当别人的代码中出现的时候你知道怎么回事。

-

**The rules of method lookup summarized**
方法搜索顺序的原则总结


1.  Modules prepended to its class, in reverse order of prepending 被prepend的module优先于发出prepend动作的class
2.  Its class 当前class
3.  Modules included in its class, in reverse order of inclusion 被当前class include的module
4.  Modules prepended to its superclass 被当前class的superclass prepend的module
5.  Its class’s superclass 当前 class 的superclass
6.  Modules included in its superclass 当前 class 的superclass include的module
7.  Likewise, up to Object (and its mix-in Kernel) and BasicObject 如此直到 BasicObject

但要记住一个class include 了多个module的时候，靠下的（新引入）的优先

-

**super 方法**

super 方法在 method 内部使用。
目的是尝试去找到methods lookup path下一个与该method 同名的 method 并执行一次。这个功能类似 method 内部的 迷你版的 mixin searching

```ruby
module M
  def report
    puts "'report' method in module M"
  end
end

class C
  include M
  def report
    puts "'report' method in class C"
    puts "About to trigger the next higher-up report method ..."
    super
    puts "Back from the 'super' call."
  end
end

c = C.new
c.report
```
输出
```ruby
2.5.0 :001 > load './super.rb'
'report' method in class C
About to trigger the next higher-up report method ...
'report' method in module M
Back from the 'super' call.
 => true
```

Sometimes, particularly when you’re writing a subclass, a method in an existing class does almost but not quite what you want. With super, you can have the best of both worlds by hooking into or wrapping the original method, as the next listing illustrates.

有时，特别是当你在写一个 subclass 时，另一个class中存在的method或许并不是你想要的。使用super你可以远程呼叫到其他 lookup path 中的方法或者使用当前版本的 method 。

```ruby
class Bicycle
  attr_reader :gears, :wheels, :seats
  def initialize(gears = 1)
    @wheels = 2
    @seats = 1
    @gears = gears
  end
end

class Tandem < Bicycle # tandem 双人自行车
  def initialize(gears)
    super
    @seats = 2
  end
end
```

super provides a clean way to make a tandem almost like a bicycle. We change only what needs to be changed (the number of seats ), and super triggers the earlier initialize method , which sets bicycle-like default values for the other properties of the tandem.
`super`提供了一个干净的方法使得 双人自行车 几乎和一个自行车一样。我们只改变需要改变的内容(座位的数量)。

When we call super, we don’t explicitly forward the gears argument that’s passed to initialize. Yet when the original initialize method in Bicycle is called, any arguments provided to the Tandem version are visible. This is a special behavior of super. The way super handles arguments is as follows:

当我们使用super时，我们并没有明确地将 gears 参数 转送 给initialize。当Bicyle中的initialize被呼叫时，所有传给 Tandem 中 initialize 的参数在 Bicycle中的 initialize 都可见。这是 super 特有的行为，super处理参数的方式如下

- Called with no argument list (empty or otherwise), super automatically forwards the arguments that were passed to the method from which it’s called. `super` 后不带任何参数或括号时，super会使用它呼到的那个higher-up方法的默认参数。
- Called with an empty argument list—super()—super sends no arguments to the higher-up method, even if arguments were passed to the current method. `super()` 后带个空的arg list，super不会送任何参数给它呼到的那个方法，即使当前方法持有参数。
- Called with specific arguments—super(a,b,c)—super sends exactly those arguments.
`super(a,b,c)` 有具体参数时，使用super后给出的这些参数。

This unusual treatment of arguments exists because the most common case is the first one, where you want to bump up to the next-higher method with the same arguments as those received by the method from which super is being called. That case is given the simplest syntax—you just type super. (And because super is a keyword rather than a method, it can be engineered to provide this special behavior.)
这样处理参数是因为绝大多数情况会是前面提到的第一种，也就是使用super叫到的方法的默认的参数。

Now that you’ve seen how method lookup works, let’s consider what happens when method lookup fails.

**The method_missing method**

method_missing 是ruby 用来回应未知信息的 instance method
它写在  Kernel 中

当某个 message 送给 object 后，ruby 沿着 预定的 searching path 找遍后都没有找到对应的内容，它就会去执行 Kernel 中的

method_missing(m, *args)

由于 Kernel 的位置相对靠近顶层，也就是在 searching path 中靠后，所以可以在path中靠前的位置 写一个自定义版本的来覆盖，但是 这个 method 的名称要和 Kernel 中的相同

常见的报错是  

```ruby
2.5.0 :001 > class C; end
 => nil
2.5.0 :002 > C.new.unknown
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):2
NoMethodError (undefined method `unknown' for #<C:0x00007fec93060e50>)
2.5.0 :003 >
```

ruby 在报错中提到了错误 method 的名字 所以 method_missing 这个方法 至少需要接受一个 参数 即送给 object 的method的名称

http://ruby-doc.org/core-2.5.0/BasicObject.html#method-i-method_missing

```ruby
2.5.0 :001 > class A
2.5.0 :002?>   def method_missing
2.5.0 :003?>     puts "Miss miss miss"
2.5.0 :004?>     end
2.5.0 :005?>   end
 => :method_missing
2.5.0 :006 > A.new.unknown
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):6
        1: from (irb):2:in `method_missing'
ArgumentError (wrong number of arguments (given 1, expected 0))
2.5.0 :007 >
2.5.0 :008 > class B
2.5.0 :009?>   def method_missing(m)
2.5.0 :010?>     puts "Miss miss miss"
2.5.0 :011?>     end
2.5.0 :012?>   end
 => :method_missing
2.5.0 :013 > B.new.unknown
Miss miss miss
 => nil
```

```ruby
2.5.0 :014 > method(:method_missing).owner
 => BasicObject
```

ruby doc 中也提到可以改写标准的 method_missing 行为来提供更加灵活的错误信息

书中提到的版本添加了一个 `*args` 来吸掉剩余的所有参数

```ruby
def o.method_missing(m, *args)
 # do some
end

o = Object.new
o.unknown
```

`*arg`的存在增加了这个方法的灵活性

m 这个参数实际是以 :symbol 的格式送入

所以如果要在 method_missing 内部对 m 作调整或限定，要先把 m 转为 string

```ruby
class Student
  def method_missing(m, *args)
    if m.to_s.start_with?("grade_for")
      puts "New method name is #{m}"
    else
      super
    end
  end
end
```

```ruby
2.5.0 :001 > load './student.rb'
 => true
2.5.0 :002 > Student.new.grade_for_twelve
New method name is grade_for_twelve
 => nil
2.5.0 :003 > Student.new.standup
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):3
        1: from /Users/caven/Notes & Articles/Note of Rubyist/code examples/student.rb:6:in `method_missing'
NoMethodError (undefined method `standup' for #<Student:0x00007ffe75836fc8>)
```

上面的 method_missing 加入了条件判断

如果传给 Student 的 instance 的method 名称是以 :grade_for_ 开头那么就继续  (注意.to_s)
如果不是

super 会让 ruby 跳过当前 method_missing 去执行 searching path 中下一个 method_missing 也就是标准版的 method_missing method

start_with?()  方法检测字串开头是否与给出参数字串相同

```ruby
class Person
  PEOPLE = []
  attr_reader :name, :friends, :hobbies

  def initialize(name)
    @name = name
    @friends = []
    @hobbies = []
    PEOPLE << self
  end

  def has_friend(friend)
    @friends << friend
  end

  def has_hobby(hobby)
    @hobbies << hobby
  end

  def self.method_missing(m, *args)
    method = m.to_s
    if method.start_with?("all_with_")
      attr = method[9..-1]
      if self.public_method_defined?(attr)
        PEOPLE.find_all do |person|
          person.send(attr).include?(args[0])
        end
      else
        raise ArgumentError, "Cannot find attribute: #{attr}"
      end
    else
      super
    end
  end

end

j = Person.new("John")
p = Person.new("Paul")
g = Person.new("George")
r = Person.new("Ringo")
j.has_friend(p)
j.has_friend(g)
g.has_friend(p)
r.has_hobby("rings")

Person.all_with_friends(p).each do |person|
  puts "#{person.name} is friends with #{p.name}"
end

Person.all_with_hobbies("rings").each do |person|
  puts "#{person.name} is into rings"
end

# 代码报错，暂未查明原因
# John is friends with Paul
# person_my.rb:32:in `method_missing': undefined method ` ' for Person:Class (NoMethodError)
# 	from person_my.rb:49:in `block in <class:Person>'
# 	from person_my.rb:47:in `each'
# 	from person_my.rb:47:in `<class:Person>'
# 	from person_my.rb:1:in `<main>'

```

报错的原因是 ["non-breaking space"](https://en.wikipedia.org/wiki/Non-breaking_space),移除后恢复。

![](https://ws1.sinaimg.cn/large/006tNc79ly1fntqe1hw9vj30n40amdj5.jpg)

上面的例子中既用到了 `method_missing` 也用到了 `super`。

-

**class/module design and naming**

让一个object获得一个方法有很多方式，可以直接写在 class 中也可以引入 module， 该使用哪一种没有标准答案。但有时我们会陷入过度 modulariation 的陷阱，写任何方法的时候都想放在module中，总想着会在其他什么地方用到，这叫 overmodulariztion。 继承也可以达到类似目的，但我们要学会平衡这些工具的使用。

要记住一个 class 只能继承自另一个 superclass ，相当于说一个 class 只有一个 superclass 名额可以给出，所以当之后有更加适合的 superclass 出现时，情况就不那么好了。因此是使用 mix-in 还是 inheritance 要考虑清楚，下面两点是这类问题的考量标准。

- Modules don’t have instances. It follows that entities or things are generally best modeled in classes, and characteristics or properties of entities or things are best encapsulated in modules. Correspondingly, as noted in section 4.1.1, class names tend to be nouns, whereas module names are often adjectives (Stack versus Stacklike).
module 不存在继承动作。通常一类对象关于其实体信息的内容会写在对应的class中，而关于这类实体的特征或描述类的信息适宜放在module中。这也是为什么通常class的名称是名词，而module的名称多是形容词。

- A class can have only one superclass, but it can mix in as many modules as it wants. If you’re using inheritance, give priority to creating a sensible superclass/subclass relationship. Don’t use up a class’s one and only superclass relationship to endow the class with what might turn out to be just one of several sets of characteristics.

一个class只能有一个superclass, 但它可以mix in 很多个module。如果你要使用继承，首先要考虑好一个合理的继承关系。不要让一个只有少量特征的class作为一个class的superclass。

下面这样的事最好别做

```ruby
module Vehicle
...
class SelfPropelling
...
class Truck < SelfPropelling
  include Vehicle
...
```

Rather, you should do this: 你应该这样

```ruby
module SelfPropelling
...
class Vehicle
  include SelfPropelling
...
class Truck < Vehicle
...
```

上面两个例子中，第二个例子从自然语言上理解更为顺畅

虽说第一种组织方式也可以用，但是不符合人类分类习惯的代码会耗费更多的认知资源去矫正这种 不自然感

-

除了这种 独立撰写 class 和 module

然后独立引用的方式

另一种组织方式是 nesting 风格

```ruby
2.5.0 :001 > module Tools
2.5.0 :002?>   class Hammer
2.5.0 :003?>   end
2.5.0 :004?> end
 => nil
2.5.0 :005 > h = Tools::Hammer.new
 => #<Tools::Hammer:0x00007fdd0d928848>
```
这种方式可以构建起 namespace 当有名称相同的 class 时可以使用

比如

Tools::Hammer

Weapon::Hammer

都是 Hammer 但实际是不同的东西

当然也可以使用 ToolsHammer 这种方式实现，但这么做会增加阅读难度，而且当字串很长时这个问题会更加突出，比如

IronWeaponBluntHammer

这种情况下使用

Iron::Weapon::Blunt::Hammer 更容易识别

-

这种使用 两个引号的串接方式 有一个特点

在没有进行特定操作或者看到源码的情况下，有时候不知道某一个片段是代表一个 module 还是 class 抑或是 constant

### Summary
 
- Modules, up close and in detail 近距离观察 modules
- Similarities and differences between modules and classes (both can bundle methods and constants together, but modules can’t be instantiated)
module和class之间的区别，都可以绑入常量和方法，只不过module不能实例化
- Examples of how you might use modules to express the design of a program
如何使用module完善程序设计的例子
- An object’s-eye view of the process of finding and executing a method in response to a message, or handling failure with method_missing in cases where the message doesn’t match a method
以对象的视角回应接受到的message，以及使用 method_missing 处理搜索失败的案例。
- How to nest classes and modules inside each other, with the benefit of keeping namespaces separate and clear
如何组织module和class来保持他们之间的独立性和整洁。
