---
title:  "Rubyist-c15-Callbacks hooks and runtime introspection"
categories: [Ruby/Rails ℗]
tags: [Ruby & Rails, Notes of Rubyist]
---

*注：这一系列文章是《The Well-Grounded Rubyist》的学习笔记。*



---

This chapter covers

- Runtime callbacks: inherited, included, and more 运行中的回呼方法： inherited included …

- The respond_to? and method_missing methods  

- Introspection of object and class method lists 对象的反身检视和 class methods 清单

- Trapping unresolved constant references 固定未解决的常量引用

- Examining in-scope variables and constants  in-scope 变量和 常量

- Parsing caller and stack trace information 解析堆栈轨迹信息


In keeping with its dynamic nature and its encouragement of flexible, supple object and program design, Ruby provides a large number of ways to examine what’s going on while your program is running and to set up event-based callbacks and hooks——essentially, tripwires that are pulled at specified times and for specific reasons——in the form of methods with special, reserved names for which you can, if you wish, provide definitions. Thus you can rig a module so that a particular method gets called every time a class includes that module, or write a callback method for a class that gets called every time the class is inherited, and so on.

为了保持灵活的天性以及对灵活性的鼓励，还有敏捷的对象和程序设计，Ruby 提供了很多在程序运行中检查运行状态的工具，以及基于事件的回呼和挂钩连接——本质上看，就像那些在特定时间点由于特定原因触发的触发线——以特定的关键词方法实现，如果必要你也可以自己写这些方法。 这样你可以操纵一个 module 让特定方法在每次这个 module 被 include 时就触发特定的method，或者给一个class写一个回呼方法让这个 class 被其他 class 继承时就自动触发这个 方法。等等。

In addition to runtime callbacks, Ruby lets you perform more passive but often critical acts of examination: you can ask objects what methods they can execute (in even more ways than you’ve seen already) or what instance variables they have. You can query classes and modules for their constants and their instance methods. You can examine a stack trace to determine what method calls got you to a particular point in your program——and you even get access to the filenames and line numbers of all the method calls along the way.

In short, Ruby invites you to the party: you get to see what’s going on, in considerable detail, via techniques for runtime introspection; and you can order Ruby to push certain buttons in reaction to runtime events. This chapter, the last in the book, will explore a variety of these introspective and callback techniques and will equip you to take ever greater advantage of the facilities offered by this remarkable, and remarkably dynamic, language.

除了运行中的回呼，ruby 让你可以执行一些更加被动但关键的对象行为检查： 你可以询问对象可以执行哪些方法（会有比我们之前看过的更多的方式）或者对象的 instance variable。 你可以查询 class 的常量和他们的 instance method。 你可以检查 堆栈轨迹 来决定在程序中特定的点执行什么方法，你甚至可以查看文件的名称和所有方法的行号。

总的来说，ruby 邀请你参加他的party: 你可以通过运行时的introspection 看到很多细节； 你可以让ruby在程序中的特定事件点触发预定的行为。这是本书的最后一章，将会探索许多回呼和运行时introspection技术，这些由这个强大的，及其灵活的言语带给你的装备，将会促成你极大的进步。

-

Callbacks and hooks

-

The use of callbacks and hooks is a fairly common meta-programming technique. These methods are called when a particular event takes place during the run of a Ruby program. An event is something like

- A nonexistent method being called on an object

- A module being mixed in to a class or another module

- An object being extended with a module

- A class being subclassed (inherited from)

- A reference being made to a nonexistent constant

- An instance method being added to a class

- A singleton method being added to an object

回呼和钩子的使用是很常见的元编程技术。这些方法会在 ruby 程序运行时由特定的事件引发，这些事件比如：

- 对一个对象使用并不存在的方法

- 当一个 module 被 引入其他 module/class 时

- 一个class 去继承另一个 class 时

- 使用一个并不存在的 常量

- 当一个 instance method 被添加到一个 class 中时

- 给特定对象增加 singleton method 时

For every event in that list, you can (if you choose) write a callback method that will be executed when the event happens. These callback methods are per-object or per-class, not global; if you want a method called when the class Ticket gets subclassed, you have to write the appropriate method specifically for class Ticket.

针对上面这些情况的callback 方法他们都是 存在于特定对象中或特定 class 中的，并不是全域的。如果你想写一个当 class Ticket 去继承其他class 时会触发的方法时，你必须针对 Ticket 这个 class 写方法。

下面会按照上面列表中给出的顺序给出每种事件的示例：

-

Intercepting unrecognized message with method_missing

-

第4章中提到了很多关于 method_missing 的内容。总结一下： 当你送一个 message 给一个对象时，对象会执行它在 methods lookup path 中遇到的一个匹配到的方法。如果直到path尽头都没找到，会抛出 NoMethodError，除非你给这个对象提供一个 method_missing 方法引导后续的行为。

当然 method_missing 在这一章也应该提到，因为他可说是 ruby 中最常见的 运行中的 hook 。不再多提第4章中重复的内容，我们来看一些关于 method_missing 的微妙点。 我们会考虑把 method_missing 作为一个代理技术来使用；我们会看看他怎么工作，以及怎么在 class 层级的顶端改写它，这么做会发生什么。

Delegating with method_missing

You can use method_missing to bring about an automatic extension of the way your object behaves. For example, let’s say you’re modeling an object that in some respects is a container but that also has other characteristics——perhaps a cookbook. You want to be able to program your cookbook as a collection of recipes, but it also has certain characteristics (title, author, perhaps a list of people with whom you’ve shared it or who have contributed to it) that need to be stored and handled separately from the recipes. Thus the cookbook is both a collection and the repository of metadata about the collection.

使用 method_missing 你可以让 object 具有一种类似自动拓展的行为方式。比如你正在构想一个对象在某些方面像一个容器，同时还有其他特点——也许还是个食谱。你想让这个食谱中包含一些列的烹饪方法，并且附带其他一些信息，比如菜肴名称，作者，也或者还有清单记录你把这个菜肴分享给了哪些人， 哪些人对菜肴有贡献，这些需要和食谱分开处理。这样的菜谱既是一个集合，也包含了很多元信息。

To do this in a method_missing-based way, you would maintain an array of recipes and then forward any unrecognized messages to that array. A simple implementation might look like this:

如果使用基于 method_missing 的方法实现，你先持有一个 array 的食谱汇总，然后将任何送来的没有出现过的信息 存入这个 array, 简单的实现也许是这样：

```ruby
class Cookbook
  attr_accessor :title, :author

  def initialize
    @recipes = []
  end

  def method_missing(m,*args,&block)
    @recipes.send(m, *args, &block)
  end
end

class Recipe
  # some assuming methods
end
```

上面例子中还增加一个假设的 class Recipe, 假设里面写好了方法，可以生成许多 菜肴 对象。假设我们写好了很多Recipe 的实例对象

假象如下的操作
```ruby
cb = Cookbook.new
cb << recipe_for_cake
cb << recipe_for_chicken

beef_dishes = cb.select { |recipes| recipe.main_ingredient == “beef” }
```

The cookbook instance, cb, doesn’t have methods called << and select, so those messages are passed along to the @recipes array courtesy of method_missing. We can still define any methods we want directly in the Cookbook class—we can even override array methods, if we want a more cookbook-specific behavior for any of those methods—but method_missing saves us from having to define a parallel set of methods for handling pages as an ordered collection.

上的 Cookbook 的实例 cb(注意不是cb.recipes) 并没有 << 和 select 方法（因为它不是array也没有include Enumerable后定义each）, 所以 message 会在 method_missing 的引导下send对象给 @recipes 实例变量(也就是一个array)。 我们仍然可以直接在 Cookbook class 中定义任何方法，规定更加具体的行为，我们甚至可以改写 array 相关的方法。but method_missing saves us from having to define a parallel set of methods for handling pages as an ordered collection.？？？

-

Ruby’s method_delegating techniques

ruby的method代理技术

-

In this method_missing example, we’ve delegated the processing of messages (the unknown ones) to the array @recipes. Ruby has several mechanisms for delegating actions from one object to another. We won’t go into them here, but you may come across both the Delegator class and the SimpleDelegator class in your further encounters with Ruby.

在上面的 method_missing 例子中，我们将信息的处理委派给了 @recipes 这个 array。 Ruby 有很多这样的机制来将一个操作委派给另一个 object 。 我们不会深入这个话题，但会在后面的内容中遇到 Delegator class 和 SimpleDelegator class 这个两个classes.

这种对 method_missing 的利用很直白但也很有效；它可以让我们在 class 中只用很少的努力就得到回报。现在让我们来看看光谱的另一端： method_missing 不用在自定义 class 中而在顶层的 class 中的情况。d

The original : BasicObject#method_missing

method_missing is one of the few methods defined at the very top of the class tree, in the BasicObject class. Thanks to the fact that all classes ultimately derive from Basic-Object, all objects have a method_missing method.

在class tree 顶端的 BasicObject 中存在的方法是很少的，这一点之前提到过，但 method_missing 就是这少数中的其中之一。

The default method_missing is rather intelligent. Look at the difference between the error messages in these two exchanges with irb:

即便默认的 `method_missing` 就是十分智慧的。 观察下面两个不同的错误信息：

```ruby
2.5.0 :001 > a
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):1
NameError (undefined local variable or method `a' for main:Object)
2.5.0 :002 > a?
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):2
NoMethodError (undefined method `a?' for main:Object)
2.5.0 :003 >
```

上面的这个例子中， `a` 既可以是变量也可以是方法，method_missing 接手后也无法分辨，最后的反馈是 undefined variable or method

而对于 `a?` 他只能是一个方法，因为带了一个问号。 因此 method_missing 拿到后缩小了报错信息的范围，抛出的是 undefined method 错误。

我们能够用两种方式来改写 method_missing

第一可以使用 class BasicObject 来打开然后再在里面改写

第二可以直接在 top level 当前语境下是 irb 中直接改写 method_missing ， 这样可以将其作为 Object class 的 private method。这样自己写的 method_missing 就会在 method lookup path 中位于靠前的位置

```ruby
2.5.0 :003 > self
 => main
2.5.0 :004 > self.class
 => Object
 2.5.0 :005 > Object.ancestors
  => [Object, Kernel, BasicObject]
 2.5.0 :006 >
```

If you use this second technique, all objects except actual instances of BasicObject itself will find the new version of method_missing:

如果使用第二种方法，除了 BasicObject 以外的所有 class 都可以找到这个版本的 method_missing

![](https://ws1.sinaimg.cn/large/006tNbRwgy1fop02w6kx8j30de040glu.jpg)

但书中给出的例子无法在本机实现，首先会有很长traceback，接着会直接中断irb会话。

![](https://ws1.sinaimg.cn/large/006tNbRwgy1fop08c0ocuj30de04bjtw.jpg)

(You can put a super call inside your new version, if you want to bounce it up to the version in BasicObject, perhaps after logging the error, instead of raising an exception yourself.)

你可以在新版本中的 method_missing 中放一个 super 方法，让他跳回到 BasicObject 中的 method_missing 版本，或者只是将错误记录进日志中而不是抛出 exception

![](https://ws4.sinaimg.cn/large/006tNbRwgy1fop0auke2mj30de02n3z0.jpg)

书中还提到，如果你自己改写了 method_missing 你就无法识别送来的信息会是 method 还是 variable 。

如果你一定会在新版本中放一个 super 那么这就无所谓，因为最终还是会导到默认版本的 method_missing 哪里。如果不是，那你只有自己检查 m 这个 symbol 是什么。有点绕，但这是观察 class 层级结构和 overriding 语义微妙之处的好机会。

-

method_missing, respond_to?, and respond_to_missing?

-

An oft-cited problem with method_missing is that it doesn’t align with respond_to?. Consider this example. In the Person class, we intercept messages that start with set_, and transform them into setter methods: set_age(n) becomes age=n and so forth. For example:

一个常被提到的问题是 method_missing 和 respond_to? 方法不能对应起来。考虑下面这个例子，在 Person class 中，我们截获以 set_ 开头的 message ，然后将其转换为 setter 方法。

```ruby
2.5.0 :004 > class Person
2.5.0 :005?>   attr_accessor :name, :age
2.5.0 :006?>   def initialize(name, age)
2.5.0 :007?>     @name, @age = name, age
2.5.0 :008?>   end
2.5.0 :009?>
2.5.0 :010?>   def method_missing(m, *args, &block)
2.5.0 :011?>     if /set_(.*)/.match(m)
2.5.0 :012?>       self.send("#{$1}=", *args)
2.5.0 :013?>     else
2.5.0 :014?>       super
2.5.0 :015?>     end
2.5.0 :016?>   end
2.5.0 :017?> end
 => :method_missing
2.5.0 :018 >
2.5.0 :019 > person = Person.new("David", 54)
 => #<Person:0x00007f7eeb87f6b0 @name="David", @age=54>
2.5.0 :020 > person.set_age(55)
 => 55
2.5.0 :021 > person.respond_to?(:set_age?)
 => false
2.5.0 :022 >
```

So does a person object have a set_age method, or not? Well, you can call that method, but the person object claims it doesn’t respond to it:

在 method_missing 中我们截获了 set_开头的message 然后进行了 setting 操作，但实际上 Person 的实例对象本身是并没有 :set_age 这个方法的，因此也对这个message 不会有回应。实际我们是把 :set_age 剖开组合成 `age=` 方法，而这个方法由于 attr_accessor 包括了 :age 所以可以直接使用

如果想让  method_missing 和 respond_to? 能够成对，需要用到 respond_to_missing? 方法。给 Person class 加上这个方法

```ruby
2.5.0 :022 > class Person
2.5.0 :023?>   def respond_to_missing?(m, include_private = false)
2.5.0 :024?>     /set_/.match(m) || super
2.5.0 :025?>   end
2.5.0 :026?> end
 => :respond_to_missing?
2.5.0 :027 > person = Person.new("Caven", 18)
 => #<Person:0x00007f7eed842330 @name="Caven", @age=18>
2.5.0 :028 > person.age
 => 18
2.5.0 :029 > person.respond_to?(:set_age)
 => true
2.5.0 :030 >
```

现在再对 :set_age 或其他随便什么以set_开头的 symbol 使用 respond_to? 就会返回 true

```ruby
2.5.0 :030 > person.respond_to?(:set_any)
 => true
2.5.0 :031 >
```

You can control whether private methods are included by using a second argument to respond_to?. That second argument will be passed along to respond_to_missing?. In the example, it defaults to false.

As a bonus, methods that become visible through respond_to_missing? can also be objectified into method objects using method:

respond_to?()中的第二个参数可以控制检测范围是否包含 private methods ，默认是 false， 这个参数会传到 respond_to_missing? 方法中

作为奖励，只要是能够配 respond_to_missing? 方法承认的 method 都可以被对象化，成为一个 method 对象

```ruby
2.5.0 :032 > p person.method(:set_some)
#<Method: Person#set_some>
 => #<Method: Person#set_some>
2.5.0 :033 >
```

-

Trapping include and prepend operations

-

之前已经看过如果 include 一个 module ，以及 prepend(将 module 加在 一个 module/class 前) 一个 module 。现在来看看以这两个事件点作为触发点的方法 included 和 prepended 。这两个方法后都要跟具体的 module / class ，而且只接受单个参数。

我们先仔细看看 included ， prepended 的行为很类似。你可以用 印出一条信息 的方式来验证这个触发机制。

```ruby
module M
  def self.included(holder)
    puts "I have just been mixed into #{holder}."
  end
end

class C
  include M
end
```

在 class C（或者其他任意class） 中，只要出现 include M 这一行，就会触发 module M 中 self.included 方法中的行为

```ruby
⮀ ruby included.rb
I have just been mixed into C.

```

You see the message "I have just been mixed into C." as a result of the execution of M.included when M gets included by (mixed into) C. (Because you can also mix modules into modules, the example would also work if C were another module.)

这里的触发机制类似 某个 class.self.included do something， 当某个 class 被 mixed in 另一个 class 或 module 的时候，触发什么行为

When would it be useful for a module to intercept its own inclusion like this? One commonly discussed case revolves around the difference between instance and class methods. When you mix a module into a class, you’re ensuring that all the instance methods defined in the module become available to instances of the class. But the class object isn’t affected. The following question often arises: What if you want to add class methods to the class by mixing in the module along with adding the instance methods?

一个module 能够获取自己被其他 module/class 混入的信息有什么用？ 一个常被讨论的案例是围绕 实例方法和类方法之间区别的。 当你混入一个 module 时，你也获得了其中所有的 instance methods。 但是 class 层级的方法并不受影响，这引出了以下问题： 你如何能够将引入的 methods 也加给 class

蒙 included 的帮助，可以实现

```ruby
module M
  def self.included(holder)
    def holder.a_class_method
      puts "Now the class has a new class method."
    end
  end

  def an_inst_method
    puts "This module supplies this instance method."
  end
end   

class C
  include M
end
```

module M 中 在 def self.included 的内部，写 holder.class_method  就可以给引入的 class 定义 class层级的方法。

```ruby
2.5.0 :001 > load './included1.rb'
 => true
2.5.0 :002 > c = C.new
 => #<C:0x00007fdc78035898>
2.5.0 :003 > c.an_inst_method
This module supplies this instance method.
 => nil
2.5.0 :004 > C.a_class_method
Now the class has a new class method.
 => nil
2.5.0 :005 >
```

When class C includes module M, two things happen. First, an instance method called an_inst_method appears in the lookup path of its instances (such as c). Second, thanks to M’s included callback, a class method called a_class_method is defined for the class object C.
`Module#included` is a useful way to hook into the class/module engineering of your program. Meanwhile, let’s look at another callback in the same general area of interest: `Module#extended`.

当 class C 引入了 M 时， 发生了两件事： 1 一个叫 an_inst_method 的方法被加为了 C 的 instance method ； 2 一个叫  a_class_method 的方法被加给了 C 作为 class method。

Included 在你的程序设计中是一个很有用的机制。同时，还有另一个类似的方法 extended

-

**Intercepting extend**

-

As you know from chapter 13, extending individual objects with modules is one of the most powerful techniques available in Ruby for taking advantage of the flexibility of objects and their ability to be customized. It’s also the beneficiary of a runtime hook: using the `Module#extended` method, you can set up a callback that will be triggered whenever an object performs an extend operation that involves the module in question.

在第13章我们看到对一个单独的 object 使用 extend 方法是ruby灵活性的强大武器。
使用 extended 可以设置一个 callback 点， 当有其他 object extend 特定 module/class 时就会触发某些行为。

The next listing shows a modified version of listing 15.1 that illustrates the workings of `Module#extended`.

```ruby
module M
  def self.extended(obj)
    puts "Module #{self} is being used by #{obj}."
  end

  def an_inst_method
    puts "This module supplies this instance method."
  end
end
```

irb

```ruby
2.5.0 :001 > load './extended.rb'
 => true
2.5.0 :002 > my_object = Object.new
 => #<Object:0x00007fdf3a0743a8>
2.5.0 :003 > my_object.extend(M)
Module M is being used by #<Object:0x00007fdf3a0743a8>.
 => #<Object:0x00007fdf3a0743a8>
2.5.0 :004 > my_object.an_inst_method
This module supplies this instance method.
 => nil
2.5.0 :005 >
```

It’s useful to look at how the included and extended callbacks work in conjunction with singleton classes. There’s nothing too surprising here; what you learn is how consistent Ruby’s object and class model is.

把 Included 和 extended 这两个方法和 singleton class 结合起来是一个很有用的方式。虽然在之前见过，但是可以看到 ruby 在 object 和 class 构成一致性。

```ruby
2.5.0 :005 > o = Object.new
 => #<Object:0x00007fdf3a83f538>

2.5.0 :007 > class << o
2.5.0 :008?>   def talk
2.5.0 :009?>     puts "Instance method in singleton class."
2.5.0 :010?>   end
2.5.0 :011?> end
 => :talk
2.5.0 :012 > o.talk
Instance method in singleton class.
 => nil

2.5.0 :014 > class << o
2.5.0 :015?>   def self.talk
2.5.0 :016?>     puts "Class method for singleton class."
2.5.0 :017?>   end
2.5.0 :018?> end
 => :talk

2.5.0 :019 > o.singleton_class.talk
Class method for singleton class.
 => nil
2.5.0 :020 >
```

-

**Singleton-class behavior with extended and included**

-

In effect, extending an object with a module is the same as including that module in the object’s singleton class. Whichever way you describe it, the upshot is that the module is added to the object’s method-lookup path, entering the chain right after the object’s singleton class.

在实际操作中, 一个 object 对象 extend 一个 module 和 这个 object 的 singleton class 去 include 那个 module 效果是一样的。不管是使用哪个方法，最后的结果是 module 会添加到这个对象的 method-lookup path 中， 就放在这个 对象的 singleton class 之后

But the two operations trigger different callbacks: extended and included. The following listing demonstrates the relevant behaviors.

但是两种操作会触发不同的 callbacks ， 下面的例子演示了相关行为

```ruby
module M
  def self.included(c)
    puts "#{self} included by #{c}"
  end

  def self.extended(obj)
    puts "#{self} extended by #{obj}."
  end
end

obj = Object.new
puts "Including M in object's singleton class:"
class << obj
  include M
end

puts
obj = Object.new
puts "Extending object with M:"
obj.extend(M)
```

输出

```ruby
⮀ ruby singleton_mixin.rb
Including M in object's singleton class:
M included by #<Class:#<Object:0x00007fe2870c05a0>>.

Extending object with M:
M extended by #<Object:0x00007fe2870a3e28>.
```

Included 和 extended 都写在了 module M 中，各自都只是在内部印出混入和被混入的对象的信息。

Sure enough, the include triggers the included callback, and the extend triggers extended, even though in this particular scenario the results of the two operations are the same: the object in question has M added to its method lookup path. It’s a nice illustration of some of the subtlety and precision of Ruby’s architecture and a useful reminder that manipulating an object’s singleton class directly isn’t quite identical to doing singleton-level operations directly on the object.

Just as modules can intercept include and extend operations, classes can tell when they’re being subclassed.

虽然两种方法最后导致的结果是一样的，但是过程中还是有所不同， include 由于是在 obj 的 singleton class 内部操作的，所以 included by 后显示的是 一个 singleton class 对象。

而 extend 由于是直接在 obj 上操作，没有使用 class << obj 打开 singleton class 所以显示的直接是 obj 本身。这些细节展示了ruby结构上的精确性，也提醒我们，进入 singleton class 内部进行的操作和对 object 本身的操作并不是完全一样的。

就如module 可以截获他们自身被 mixin 时的信号， class 也可以在自己被作为 subclass 时收到信号。

-

Intercepting inheritance with `Class#inherited`

-

当一个 class被另一个 class 继承时， inherited 方法可以截获这个信号。如果在一个 class 中定义好了 inherited 方法那么后面接受的那个参数就代表了 发出继承动作的这个 subclass。

```ruby
2.5.0 :001 > class C
2.5.0 :002?>   def self.inherited(subclass)
2.5.0 :003?>     puts "#{self} just got a subclass: #{subclass}."
2.5.0 :004?>   end
2.5.0 :005?> end
 => :inherited
2.5.0 :006 >
2.5.0 :007 > class D < C
2.5.0 :008?> end
C just got a subclass: D.
 => nil
2.5.0 :009 > D.ancestors
 => [D, C, Object, Kernel, BasicObject]
2.5.0 :010 >
```

inherited is a class method, so descendants of the class that defines it are also able to call it. The actions you define in inherited cascade: if you inherit from a subclass, that subclass triggers the inherited method, and so on down the chain of inheritance. If you do this

Inherited 是一个 class method 而且由于 C 继承了 D, 那么现在实际在 D 中也定义好了 inhertied，所以只要是往下走的 subclass 链条上的继承动作，都可以触发对应的 class 中的 inherited 。

```ruby
2.5.0 :011 > class E < D
2.5.0 :012?> end
D just got a subclass: E.
 => nil
2.5.0 :013 > class F < E
2.5.0 :014?> end
E just got a subclass: F.
 => nil
2.5.0 :015 >
```

The limits of the inherited callback

`inherited` 回呼的限制

Everything has its limits, including the inherited callback. When D inherits from C, C is D’s superclass; but in addition, C’s singleton class is the superclass of D’s singleton class. That’s how D manages to be able to call C’s class methods. But no callback is triggered. Even if you define inherited in C’s singleton class, it’s never called.

当 D 继承自 C , C就是D的superclass，但是另外， C 的 singleton class 也是 D 的 singleton class 的 superclass。这也是为什么 D 能够使用 C 的class method。 但是如果打开 C 的singleton class 在里面定义一个 inherited 方法，就不会有 callback 被触发，什么也不会发生。

Here’s a testbed. Note how inherited is defined inside the singleton class of C. But even when D inherits from C—and even after the explicit creation of D’s singleton class—the callback isn’t triggered:

下面的例子中我们在 class C 的 singleton class 内部写了 inherited 回呼方法，但是当有其他 class 继承 C 时，并没有触发回呼，也就是说只有以常规方法在 class 内部定义回呼方法才能正确地触发。

```ruby
2.5.0 :016 > class C
2.5.0 :017?>   class << self
2.5.0 :018?>     def self.inherited
2.5.0 :019?>       puts "Singleton class of C just got inherited!"
2.5.0 :020?>       puts "But you'll never see this message."
2.5.0 :021?>     end
2.5.0 :022?>   end
2.5.0 :023?> end
 => :inherited
2.5.0 :024 > class D < C
2.5.0 :025?>   class << self
2.5.0 :026?>     puts "D's singleton class now exists, but no callback!"
2.5.0 :027?>   end
2.5.0 :028?> end
D's singleton class now exists, but no callback!
 => nil
2.5.0 :029 >
```

You’re extremely unlikely ever to come across a situation where this behavior matters, but it gives you a nice X-ray of how Ruby’s class model interoperates with its callback layer.

当然上面提到的情况我们几乎不可能遇到，但这让我们深入了解 ruby 中 class 和 callback 之间是怎样互动的。

-

The `Module#const_missing` method

-

`Module#const_missing` is another commonly used callback. As the name implies, this method is called whenever an unidentifiable constant is referred to inside a given module or class:

这个机制的触发点是当你在一个 试图引用一个不识别的常量时。

```ruby
class C
  def self.const_missing(const)
    puts "#{const} is undefined_setting to 1."
    const_set(const,1)
  end
end
```

const_set 接受两个参数，第一个是常量名称，第二个是你要给这个常量赋予的对象(值)

```ruby
2.5.0 :001 > load './const_missing.rb'
 => true
2.5.0 :002 > puts C::A
A is undefined_setting to 1.
1
 => nil
2.5.0 :003 > puts C::A
1
 => nil
2.5.0 :004 >
```

后面跟的参数代表 你传入的这个不识别的常量。

上面的例子中

第一个 puts C::A 触发了 C 中的 const_missing 方法，印出了一行信息并在第4行设置了常量值为1

第二个 puts C::A 没有触发，因为在上一步中已经设置好了 A ，这次直接印出了 A 的值。

另一个强大的触发点是以 method_added 为代表的触发机制，会在新的 instance_method 建立时触发。

-

The method_added and singleton_method_added methods

-

当你在 一个 module / class 中定义好一个 class 层级的 method_added 时， 任何新的实例方法的新建都会触发他

```ruby
2.5.0 :006 > class C
2.5.0 :007?>   def self.method_added(m)
2.5.0 :008?>     puts "Method #{m} was just defined."
2.5.0 :009?>   end
2.5.0 :010?> end
 => :method_added
2.5.0 :011 >
2.5.0 :012 > class C
2.5.0 :013?>   def one
2.5.0 :014?>   end
2.5.0 :015?> end
Method one was just defined.
 => :one
2.5.0 :016 >
```

The singleton_method_added callback does much the same thing, but for singleton methods. Perhaps surprisingly, it even triggers itself. If you run this snippet

singleton_method_added 行为类似，只不过它针对 singleton_method 的新建。但有趣的是，甚至定义 singleton_method_added 时他自己都会触发自己

```ruby
2.5.0 :016 > class C
2.5.0 :017?>   def self.singleton_method_added(m)
2.5.0 :018?>     puts "Method #{m} was just defined."
2.5.0 :019?>   end
2.5.0 :020?> end
Method singleton_method_added was just defined.
 => :singleton_method_added
2.5.0 :021 >
```

当然 C 的 singleton method 实际就是 C自己的class method ， 所以只要有新定义的 C 的class method 就会触发

```ruby
2.5.0 :021 > def C.a_class_method
2.5.0 :022?> end
Method a_class_method was just defined.
 => :a_class_method
2.5.0 :023 >
```

In most cases, you should use singleton_method_added with objects other than class objects. Here’s how its use might play out with a generic object:

一个 class 的 singleton class 是一个相对特殊的例子。多数情况下 singleton_method_added 还是会使用在普通的 object 身上。

```ruby
2.5.0 :025 > obj = Object.new
 => #<Object:0x00007fe524033778>
2.5.0 :026 > def obj.singleton_method_added(m)
2.5.0 :027?>   puts "Singleton method #{m} was just defined."
2.5.0 :028?> end
Singleton method singleton_method_added was just defined.
 => :singleton_method_added
2.5.0 :029 >
2.5.0 :030 > def obj.new_meth
2.5.0 :031?> end
Singleton method new_meth was just defined.
 => :new_meth
2.5.0 :032 >
```

Again, you get the somewhat surprising effect that defining singleton_method_added triggers the callback’s own execution.

Putting the class-based and object-based approaches together, you can achieve the object-specific effect by defining the relevant methods in the object’s singleton class:

再一次，这里得到了一个意外的结果，给obj 定义 singleton_method_added 时再次触发了这个方法本身。因为 def obj.whatever_method 这样的语法都是在给 obj 增加新的 singleton method

将上面两种情况综合起来，我们可以在 object 的 singleton class 内部进行定义操作。

```ruby
2.5.0 :033 > obj = Object.new
 => #<Object:0x00007fe5258563c8>
2.5.0 :034 > class << obj
2.5.0 :035?>   def singleton_method_added(m)
2.5.0 :036?>     puts "Singleton method #{m} was just defined."
2.5.0 :037?>   end
2.5.0 :038?>
2.5.0 :039?>   def new_meth
2.5.0 :040?>   end
2.5.0 :041?> end
Singleton method singleton_method_added was just defined.
Singleton method new_meth was just defined.
 => :new_meth
2.5.0 :042 >
```

这个例子中其实在 class << obj ;end 内部写 def singleton_method_added 和直接在 top level 中写 obj.singleton_method_added 效果是一样的。

The output for this snippet is exactly the same as for the previous example. Finally, coming full circle, you can define singleton_method_added as a regular instance method of a class, in which case every instance of that class will follow the rule that the callback will be triggered by the creation of a singleton method:

最后，我们可以在一个 class 中将 singleton_method_added 写作一个 instance method ， 那么这个触发就会针对所有这个 class 下的 instance ， 不管哪一个 instance 添加了 新的 singleton method 都会触发这个行为。

```ruby
2.5.0 :001 > class C
2.5.0 :002?>   def singleton_method_added(m)
2.5.0 :003?>     puts "Singleton method #{m} was just defined to #{self}."
2.5.0 :004?>   end
2.5.0 :005?> end
 => :singleton_method_added
2.5.0 :006 >
2.5.0 :007 > c = C.new
 => #<C:0x00007fdeb90f9278>
2.5.0 :008 > def c.new_meth
2.5.0 :009?> end
Singleton method new_meth was just defined to #<C:0x00007fdeb90f9278>.
 => :new_meth
2.5.0 :010 >
```

It’s possible that you won’t use either method_added or singleton_method_added often in your Ruby applications. But experimenting with them is a great way to get a deeper feel for how the various parts of the class, instance, and singleton-class pictures fit together.

我们几乎很少可能用到上面提到的 method_added 和 singleton_method_added 方法，但是对他们进行一些试验可以让我们加深对 class ， instance , 自己 singleton class 之间关系的理解。

We’ll turn now to the subject of examining object capabilities ("abc".methods and friends). The basics of this topic were included in the “Built-in Essentials” survey in chapter 7, and as promised in that chapter, we’ll go into them more deeply here.

下一个主题我们将转向检视 对象的能力（比如包含哪些methods）。这部分的基础部分在 第七章已经提到过，现在我们兑现承诺深入了解这一部分。

-

Interpreting object capability queries

窥探 对象 的功能
-

At this point in your work with Ruby, you can set your sights on doing more with lists of objects’ methods than examining and discarding them. In this section we’ll look at a few examples (and there’ll be plenty of room left for you to create more, as your needs and interests demand) of ways in which you might use and interpret the information in method lists. The Ruby you’ve learned since we last addressed this topic directly will stand you in good stead. You’ll also learn a few fine points of the method-querying methods themselves.

Let’s start at the most familiar point of departure: listing non-private methods with the methods method.

在这一阶段对 ruby 的探索中，我们除了检视和丢弃 object 的方法，还会看一些其他例子。之前我们提到过的这部分相关内容会是你理解后面部分的坚实基础。我们还会学习一些 关于 method querying 方法本身的细微的点。

首先还是看下最基础的 methods 方法

-

**Listing an  object’s non-private methods**

列出一个对象的非private方法

-

Non -private 指的是 public 和 protected 方法。我们使用 methods 可以拿到一个 array 的方法，但在这个基础上可以作更多的过滤。

比如下面的例子，我们可以从一个 string 的 方法集合中过滤出包含 “case” 的方法。

```ruby
2.5.0 :011 > string = "Test string"
 => "Test string"
2.5.0 :012 > string.methods.grep(/case/).sort
 => [:casecmp, :casecmp?, :downcase, :downcase!, :swapcase, :swapcase!, :upcase, :upcase!]
2.5.0 :013 >
```

grep  过滤器滤掉了所有不包含 case 的方法（记住虽然methods都是以 symbol 形式出现，但是它和string之间有很多共同的特性）。

下面的例子找出 所有 bang! 版本的方法

```ruby
2.5.0 :014 > string.methods.grep(/.!/).sort
 => [:capitalize!, :chomp!, :chop!, :delete!, :delete_prefix!, :delete_suffix!, :downcase!, :encode!, :gsub!, :lstrip!, :next!, :reverse!, :rstrip!, :scrub!, :slice!, :squeeze!, :strip!, :sub!, :succ!, :swapcase!, :tr!, :tr_s!, :unicode_normalize!, :upcase!]
2.5.0 :015 >
```

Why the dot before the ! in the regular expression? Its purpose is to ensure that there’s at least one character before the ! in the method name, and thus to exclude the !, !=, and !~ methods, which contain ! but aren’t bang methods in the usual sense. We want methods that end with a bang, but not those that begin with one.

感叹号之前的 . 点号的作用是保证 感叹号! 之前至少有一个字符，这样可以滤掉 ! , != , !~ 这类方法。我们只想要以 ! 结束的方法。

Let’s use methods a little further. Here’s a question we can answer by interpreting method query results: do strings have any bang methods that don’t have corresponding non-bang methods?

再进一步，我们想看看string的方法集合中有哪些 bang! 版本的方法是没有对应的 无! 版本的。
也就是找到那些独立存在的 bang! 版本的方法。

下面是代码示例

```ruby
string = "Test string"
methods = string.methods
bangs = methods.grep(/.!/)
unmatched = bangs.reject do |b|
  methods.include?(b[0..-2].to_sym) # bangs 中每个method从倒数第二到第一个字符，也就是刨去了`!`
end

if unmatched.empty?
  puts "All bang methods are matched by non-bang methods."
else
  puts "Some bang methods have non-bang partner: "
  puts unmatched
end
```

输出

```ruby
 All bang methods are matched by non-bang methods.
```

也就是string对象的 所有bang! 方法都是成对出现的，不存在独立存在的 bang method

The code works by collecting all of a string’s public methods and, separately, all of its bang methods . Then, a reject operation filters out all bang method names for which a corresponding non-bang name can be found in the larger method-name list . The [0..-2] index grabs everything but the last character of the symbol—the method name minus the !, in other words—and the call to to_sym converts the resulting string back to a symbol so that the include? test can look for it in the array of methods. If the filtered list is empty, that means that no unmatched bang method names were found. If it isn’t empty, then at least one such name was found and can be printed out.

首先分别收集到 string 的所有 methods 以及所有 bang 版本方法 bangs。

4-6行是关键

基础是从 bangs 中排除匹配到的项

这是一个遍历操作，b[0..-2] 每次拿到 bangs 中的一个方法的 第1到倒数第二个字符，也就是排除掉了最后一个!

然后用这个 砍掉了! 的方法去匹配（注意这里用的是include？ 不是match ） methods 中的所有方法。include 是精确匹配

从 bangs 排除到匹配到的结果，剩下的就是那些独立存在的 bang! 版本的方法

```ruby
2.5.0 :019 > a = [:one!, :two, :two!, :twoo]
 => [:one!, :two, :two!, :twoo]
2.5.0 :020 > a.include?(:one)
 => false
2.5.0 :021 >
```

在上面的例子中 所有的 bang！ 版本方法都有对应的 非 bang 版本。给 string 加上一个 人为的bang!方法可以得到不同结果。

```ruby
def string.surprise!;end
...
```

输出结果是

```ruby
Some bang methods have no non-bang partner:
surprise!
```


As you’ve already seen, writing bang methods without non-bang partners is usually bad practice—but it’s a good way to see the methods method at work.

依照默认情况下的结果，写独立存在的 bang! 版本方法不是好的实践。

You can, of course, ask class and module objects what their methods are. After all, they’re just objects. But remember that the methods method always lists the non-private methods of the object itself. In the case of classes and modules, that means you’re not getting a list of the methods that instances of the class—or instances of classes that mix in the module—can call. You’re getting the methods that the class or module itself knows about. Here’s a (partial) result from calling methods on a newly created class object:

当然我们也可以对 module / class 使用 methods 因为从本质上说他们也是 object 。只不过要记住，默认情况返回的是 non-private (public & protected)方法。
这意味着我们拿不到这个 class 下的instance methods 或者，mixin in 的其他 module 中的instance方法。

Class and module objects share some methods with their own instances, because they’re all objects and objects in general share certain methods. But the methods you see are those that the class or module itself can call. You can also ask classes and modules about the instance methods they define. We’ll return to that technique shortly. First, let’s look briefly at the process of listing an object’s private and protected methods.

Class / module 会和他们自己的 instance 共享一些方法，因为本质上他们都是 objects ， 他们直接就会共享特定的一些方法。但是 之前使用 methods 看到的都只是 class/ module 他们自己才能呼叫到的方法集合。 我们也有方法拿到 class/ module 中定义的 instance methods。之后我们会提到这一点，不过先简单看下如何列出一个 object 的private 和 protected 方法.

-

Listing private and protected methods

-

Every object (except instances of BasicObject) has a private_methods method and a protected_methods method. They work as you’d expect; they provide arrays of symbols, but containing private and protected method names, respectively.
Freshly minted Ruby objects have a lot of private methods and no protected methods:

除了 BasicObject 的实例以外， 所有的 object 都有 private_methods 和 protected_methods 这两个方法。

新铸造出的 ruby 对象 有很多 private methods 但是没有 protected methods

```ruby
2.5.0 :025 > o = Object.new
 => #<Object:0x00007fdeb90fa588>
2.5.0 :026 > p o.private_methods.size
74
 => 74
2.5.0 :027 > p o.protected_methods.size
0
 => 0
2.5.0 :028 >
```

What are those private methods? They’re private instance methods defined mostly in the Kernel module and secondarily in the BasicObject class. Here’s how you can track this down:

这些 private methods 都是什么？ 他们中绝大多数都是来自 Kernel 这个module 中定义的 private instance methods ，还有一部分来自 BasicObject 中。

![](https://ws4.sinaimg.cn/large/006tNbRwgy1fop0auke2mj30de02n3z0.jpg)

```ruby
⮀ ruby -e 'o = Object.new; p o.private_methods - BasicObject.private_instance_methods(false) - Kernel.private_instance_methods(false)'
[:DelegateClass]
```

要注意这里 ruby 2.5.0 版本返回的结果和书中给出的不同。

Note that after you subtract the private methods defined in Kernel and BasicObject, the original object has no private methods to list. The private methods defined in Kernel are the methods we think of as “top-level,” like puts, binding, and raise. Play around a little with the method-listing techniques you’re learning here and you’ll see some familiar methods listed.
Naturally, if you define a private method yourself, it will also appear in the list of private methods. Here’s an example: a simple Person class in which assigning a name to the person via the name= method triggers a name-normalization method that removes everything other than letters and selected punctuation characters from the name. The normalize_name method is private:

书中原文解释: 注意在减去 Kernel 和 BasicObject 中的 private instance methods 之后，原来的那个 object 就没有其他 private methods 剩在列表中了。在 Kernel 中定义的这个 private methods 我们能想到的是 top-level 中的 puts , binding, raise 这些方法。

当然如果你自己定义了新的 private method ，新方法会出现在列表中。 这里有一个例子: 在 Person 这个 class 中，name=这个 setter 方法的使用，会触发一个 normalize_name （private）方法 去掉与名字不相关的字符和标点。

![](https://ws4.sinaimg.cn/large/006tNbRwgy1fop0auke2mj30de02n3z0.jpg)

![](https://ws3.sinaimg.cn/large/006tNbRwgy1fopb6jo236j30de032mxd.jpg)

在 normalize_name 方法中，通过 gsub! 方法和 正则表达式的配合，滤掉非法字符

```ruby
class Person
  attr_reader :name
  def name=(name)
    @name = name
    normalize_name # normalizes name when assign
  end

  private
  def normalize_name
    name.gsub!(/[^-a-z'.\s]/i, "") # remove undesirable characters from name
  end
end
```

测试

```ruby
2.5.0 :001 > load './private_methods.rb'
 => true
2.5.0 :002 > david = Person.new
 => #<Person:0x00007fefd403f8d8>
2.5.0 :003 > david.name = "123Da%vi(d! Bla&^ck"
 => "David Black"
2.5.0 :004 > p david.private_methods.sort.grep(/normal/)
[:normalize_name]
 => [:normalize_name]
2.5.0 :005 >
```

使用 protected_methods 类似地。我们除了会查询 object 拥有的各类方法，也经常需要查看 module/ class 所拥有的各类方法。

-

**Getting class and module instance methods**

-

class/ module 相关的 method querying 方法更加强大。以 String 为例演示

  ```ruby
  2.5.0 :006 > String.methods.grep(/methods/).sort
   => [:instance_methods, :methods, :private_instance_methods, :private_methods, :protected_instance_methods, :protected_methods, :public_instance_methods, :public_methods, :singleton_methods]
  2.5.0 :007 >
  ```

instance_methods 返回 public 和 protected methods

public_instance_methods 返回所有的 public 实例方法

protected_instance_methods 和 private_instance_methods 分别返回所有 protected 和 private 实例方法

使用这些方法的时候，你可以选择性的传入一个参数。 如果传入 false 那么结果中只会包含在当前 class/ module 中定义的方法。如果传入除了 false 和 nil 以外的任何参数（都会视为true）则会将 整个继承链上游的 module/ class 中的方法都包含进去。

```ruby
2.5.0 :009 > Range.instance_methods(false).sort
 => [:==, :===, :begin, :bsearch, :cover?, :each, :end, :eql?, :exclude_end?, :first, :hash, :include?, :inspect, :last, :max, :member?, :min, :size, :step, :to_s]
2.5.0 :010 >
```

更进一步地，如果你想知道哪些在 Enumerable 中定义的方法 在 Range 中被 override 了？ 可以使用 & 操作符来找出两个 lists 的交集

```ruby
2.5.0 :010 > Range.instance_methods(false) & Enumerable.instance_methods(false)
 => [:max, :min, :member?, :include?, :first]
2.5.0 :011 >
```

As you can see, Range redefines five methods that Enumerable already defines.

如上所示，Range 中重新定义了 5 个继承自 Enumerable 中的方法。

接下来简短地看下 最后一个 methods 相关的方法， singleton_methods

不过首先我们先拿到 所有class 中 override 了 Enumerable 中的所有的方法。

Getting all the Enumerable overrides

The strategy here will be to find out which classes mix in Enumerable and then perform on each such class an and (&) operation like the one in the last example, storing the results and, finally, printing them out. The following listing shows the code.


这里的策略是 先找到哪些 class 混入了 Enumerable ，然后还是用 & 操作符来完成筛选。

http://ruby-doc.org/core-2.5.0/ObjectSpace.html#method-c-each_object

书中给出的例子在 9 行出进行的排序操作引起了报错

![](https://ws3.sinaimg.cn/large/006tNc79gy1foq559hx4pj30de03vmyl.jpg)

查了下可能是 2.5 版本中，有些 enum_classes 的 module / class 并没有 name 方法，导致 nil 的出现， 而 sort 操作是基于比较的， nil 值无法进行比较，引起报错。

![](https://ws3.sinaimg.cn/large/006tNc79gy1foq55zp7dkj30de06wmzm.jpg)

将sort 操作去除后恢复

```ruby
overrides = {}

enum_classes = ObjectSpace.each_object(Class).select do |c|
  c.ancestors.include?(Enumerable)
end

puts enum_classes

enum_classes.each do |c|
  overrides[c] = c.instance_methods(false) & Enumerable.instance_methods(false)
end

overrides.delete_if { |c, methods| methods.empty? }

puts "-" * 50

overrides.each do |c, methods|
  puts "Class #{c} overrides: #{methods.join(", ")}"
end
```

```ruby
2.5.0 :013 > load './Enumerable_overrides.rb'
StringIO
Gem::List
#<Class:Gem::Specification>
Process::Tms
Enumerator::Generator
Enumerator::Lazy
Enumerator
ObjectSpace::WeakMap
Dir
File
ARGF.class
IO
Range
Struct
#<Class:#<Object:0x00007fefd28ad030>>
Hash
Array
DidYouMean::DeprecatedIgnoredCallers
#<Class:0x00007fefd2945420>
IRB::DefaultEncodings
#<Class:0x00007fefd29822d0>
#<Class:#<Object:0x00007fefd3040bd0>>
#<Class:#<Hash:0x00007fefd405ca00>>
--------------------------------------------------
Class Gem::List overrides: to_a
Class Enumerator::Lazy overrides: grep, grep_v, find_all, select, reject, collect, map, flat_map, collect_concat, lazy, zip, take, take_while, drop, drop_while, chunk, slice_before, slice_after, slice_when, chunk_while, uniq
Class Enumerator overrides: each_with_index, each_with_object
Class ObjectSpace::WeakMap overrides: member?, include?
Class ARGF.class overrides: to_a
Class Range overrides: max, min, member?, include?, first
Class Struct overrides: to_a, to_h, select
Class #<Class:#<Object:0x00007fefd28ad030>> overrides: to_a, select, reject, include?, to_h, member?
Class Hash overrides: to_h, include?, to_a, select, reject, any?, member?
Class Array overrides: to_h, include?, sort, count, find_index, select, reject, collect, map, first, any?, reverse_each, zip, take, take_while, drop, drop_while, cycle, sum, uniq, max, min, to_a
 => true
```


First, we create an empty hash in the variable overrides . We then get a list of all classes that mix in Enumerable. The technique for getting this list involves the ObjectSpace module and its each_object method . This method takes a single argument representing the class of the objects you want it to find. In this case, we’re interested in objects of class Class, and we’re only interested in those that have Enumerable among their ancestors. The each_object method returns an enumerator, and the call to select on that enumerator has the desired effect of filtering the list of all classes down to a list of only those that have mixed in Enumerable.

Now it’s time to populate the overrides hash. For each class in enum_classes (nicely sorted by class name), we put an entry in overrides. The key is the class, and the value is an array of method names—the names of the Enumerable methods that this class overrides . After removing any entries representing classes that haven’t overridden any Enumerable methods , we proceed to print the results, using sort and join operations to make the output look consistent and clear , as shown here:

首先建了一个空 hash 来存 class名称 以及对应的 overrided 方法

先要拿到所有 混入了 Enumerable 的class，这里使用到了 ObjectSpace + each_object 技术，传入 Class 作为参数。这个方法接受一个参数，会拿到这个参数（Class）相关的所有对象，要记住主要的class 的 class 都是 Class 这个class

所以这里可以近似认为，我们拿到了所有的 class 然后从中筛选出包含 Enumerable 的class

接下来需要将信息植入 overrides 这个 hash

key将会是 class 名称， value 则是这个class 中 override 了的方法

方法是遍历 enum_classes 中搜集的所有混入了Enumerable 的class， 分别找到每一个 class 中 instance methods 与 Enumerable 中方法的交集，每个 class 存成一个键值对。

接着从 overrides 中删除那些没有交集的 键值对，也就是 value 是空 array 的

The first line pertains to the somewhat anomalous object designated as ARGF.class, which is a unique, specially engineered object involved in the processing of program input. The other lines pertain to several familiar classes that mix in Enumerable. In each case, you see which Enumerable methods the class in question has overridden.
Let’s look next at how to query an object with regard to its singleton methods.

class中关系到一个比较特殊的ARGF.class 这个对象，这是一个与 程序输入 有关的独特对象。

关于 ObjectSpace

```ruby
2.5.0 :016 > ObjectSpace.class
 => Module
2.5.0 :017 > ObjectSpace.methods(false)
 => [:each_object, :define_finalizer, :undefine_finalizer, :_id2ref, :garbage_collect, :count_objects]
2.5.0 :018 >
```

下面看如何查询一个 object 的 singleton methods

Listing objects’ singleton methods

A singleton method, as you know, is a method defined for the sole use of a particular object (or, if the object is a class, for the use of the object and its subclasses) and stored in that object’s singleton class. You can use the singleton_methods method to list all such methods. Note that singleton_methods lists public and protected singleton methods but not private ones. Here’s an example:

我们已经知道一个 singleton method 是一个 object 所特有的（如果这个object 是一个class, 也可以被他的subclasses 使用）并且存在这个object 的 singleton class 中。 使用 singleton_methods 来查询这类方法，注意这个方法印出了 public 和 protected 的 singleton methods 但是不包含 private 的方法


```ruby
class C
end

c = C.new
class << c
  def x; end
  def y; end
  def z; end
  protected :y
  private :z
end

p c.singleton_methods
```

结果是

```ruby
[:x, :y]
```

Singleton methods are also considered just methods. The methods :x and :y will show up if you call c.methods, too. You can use the class-based method-query methods on the singleton class. Add this code to the end of the last example:

Singleton methods 也是 methods 。 所以 :x 和 :y 也可以用 c.methods 找到。 我们还可以使用 基于class的method查询方法 用在对象的 singleton class 内部。

```ruby
class C
end

c = C.new
class << c
  def x; end
  def y; end
  def z; end
  protected :y
  private :z
end

p c.singleton_methods

class << c
  p private_instance_methods(false)
end
```

结果会是

```ruby
[:x, :y]
[:z]
```

The method :z is a singleton method of c, which means it’s an instance method (a private instance method, as it happens) of c’s singleton class.
You can ask a class for its singleton methods, and you’ll get the singleton methods defined for that class and for all of its ancestors. Here’s an irb-based illustration:

:z 方法是 c 对象的singelton 方法，那么也就是说 :z 是 c对象的singleton class 中的 实例方法。

我们可以查询一个 class 的 singleton methods ， 结果会拿到 所有为这个 class 定义的 singleton 方法 以及它的所有 ancestor 的 singleton methods

```ruby
2.5.0 :006 > class C; end
 => nil
2.5.0 :007 > class D < C; end
 => nil
2.5.0 :008 > def C.meth1; end
 => :meth1
2.5.0 :009 > def C.meth2; end
 => :meth2
2.5.0 :010 > def C.meth3; end
 => :meth3
2.5.0 :011 > def D.func1; end
 => :func1
2.5.0 :012 > def D.func2; end
 => :func2
2.5.0 :013 > D.singleton_methods
 => [:func1, :func2, :meth2, :meth3, :meth1]
2.5.0 :014 >
```


上面的例子中 D 继承自 C， 当对 D 使用 singleton methods 的时候，也同时拿到了他的 ancestor C 中的 singleton methods

Once you get some practice using the various methods methods, you’ll find them useful for studying and exploring how and where methods are defined. For example, you can use method queries to examine how the class methods of File are composed. To start with, find out which class methods File inherits from its ancestors, as opposed to those it defines itself:

一旦你熟悉了 methods 相关的查询方法，你将会发现对于 查找一个 method 是在哪里被定义的 变得容易。 比如说你可以 File 这个class 中定义了哪些 class methods 。 或者找到 有哪些方法是 它因继承而得来的。

```ruby
2.5.0 :014 > File.singleton_methods - File.singleton_methods(false)
 => [:read, :sysopen, :for_fd, :popen, :foreach, :binread, :binwrite, :pipe, :copy_stream, :new, :write, :select, :open, :readlines, :try_convert]
2.5.0 :015 >
```

The call to singleton_methods(false) provides only the singleton methods defined on File. The call without the false argument provides all the singleton methods defined on File and its ancestors. The difference is the ones defined by the ancestors.

The superclass of File is IO. Interestingly, although not surprisingly, all 12 of the ancestral singleton methods available to File are defined in IO. You can confirm this with another query:

带了 false 参数的 singleton_methods（false） 返回的是只在 File 内部定义的方法，不带参数的则包含了继承链上游中的 方法。

File 的 superclass 是 IO 。有趣的是，所有12个 File 上游的 singleton methods(class methods) 都是在 IO 中定义的， 也就是从这里继承过去的

```ruby
2.5.0 :017 > File.singleton_methods - File.singleton_methods(false) == IO.singleton_methods
 => true
2.5.0 :018 >
```

The relationship among classes—in this case, the fact that File is a subclass of IO and therefore shares its singleton methods (its class methods)—is directly visible in the method-name arrays. The various methods methods allow for almost unlimited inspection and exploration of this kind.

As you can see, the method-querying facilities in Ruby can tell you quite a lot about the objects, class, and modules that you’re handling. You just need to connect the dots by applying collection-querying and text-processing techniques to the lists they provide. Interpreting method queries is a nice example of the kind of learning feedback loop that Ruby provides: the more you learn about the language, the more you can learn.

We’ll turn next to the matter of runtime reflection on variables and constants.

在这个例子中，class 之间的关系，实际上 File 是 IO 的一个subclass ， 但他们共享了一些 singleton methods(也是他们的class methods)。灵活地使用 methods 方法我们可以进行很多这样的探索。

如你所见，methods 查询相关方法可以让我们了解很多关于 对象 class module 的信息。对 methods 查询的探索是一个很好的正向反馈的学习过程，你学得越多，你越能学到更多。

下面将会进入 runtime reflection 和 constant 的话题。

-

**Introspection of variables and constants**

-

Ruby can tell you several things about which variables and constants you have access to at a given point in runtime. You can get a listing of local or global variables, an object’s instance variables, the class variables of a class or module, and the constants of a class or module.

Ruby 可以在运行中告诉你很多关于变量和常量的信息。你可以拿到所有本地变量和全域变量的清单，可以拿到一个 object 的实例变量，一个 class 的 类变量，以及 class / module 中的常量。

-

Listing local and global variables

-

The local and global variable inspections are straightforward: you use the top-level methods local_variables and global_variables. In each case, you get back an array of symbols corresponding to the local or global variables currently defined:

这类查询很直白，直接使用 local_variables 和 global_variables 在 top level。

```ruby
2.5.0 :018 > local_variables
 => [:_]
2.5.0 :019 > x = 1; y = 2; z = 3
 => 3
2.5.0 :020 > local_variables
 => [:x, :y, :z, :_]
2.5.0 :021 > global_variables.sort
 => [:$!, :$", :$$, :$&, :$', :$*, :$+, :$,, :$-0, :$-F, :$-I, :$-K, :$-W, :$-a, :$-d, :$-i, :$-l, :$-p, :$-v, :$-w, :$., :$/, :$0, :$:, :$;, :$<, :$=, :$>, :$?, :$@, :$DEBUG, :$FILENAME, :$KCODE, :$LOADED_FEATURES, :$LOAD_PATH, :$PROGRAM_NAME, :$SAFE, :$VERBOSE, :$\, :$_, :$`, :$binding, :$stderr, :$stdin, :$stdout, :$~]
2.5.0 :022 >
```

The global variable list includes globals like $: (the library load path, also available as $LOAD_PATH), $~ (the global MatchData object based on the most recent pattern-matching operation), $0 (the name of the file in which execution of the current program was initiated), $FILENAME (the name of the file currently being executed), and others. The local variable list includes all currently defined local variables.

$ 代表library load path， 库的加载路径，也可以使用 $LOAD_PATH

$~ 代表 global MatchData 对象，对应最近一次模式匹配操作的结果

$0 代表当前程序初始化所使用的文件名称

$FILENAME 代表正在执行的文件的名称

```RUBY
2.5.0 :024 > $LOAD_PATH
 => ["/Users/caven/.rvm/gems/ruby-2.5.0@global/gems/did_you_mean-1.2.0/lib", "/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/site_ruby/2.5.0", "/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/site_ruby/2.5.0/x86_64-darwin17", "/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/site_ruby", "/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/vendor_ruby/2.5.0", "/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/vendor_ruby/2.5.0/x86_64-darwin17", "/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/vendor_ruby", "/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/2.5.0", "/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/2.5.0/x86_64-darwin17"]
2.5.0 :025 >
2.5.0 :026 > $~
 => nil
2.5.0 :027 > $0
 => "irb"
2.5.0 :028 > $FILENAME
 => "-"
2.5.0 :029 >
```

要注意 local_variable global_variable 以及 instance_variable 这类方法返回的只是 变量的 名称，而不是他们的 value

-

Listing instance variables

-

```ruby
2.5.0 :031 > class Person
2.5.0 :032?>   attr_accessor :name, :age
2.5.0 :033?> end
 => nil
2.5.0 :034 > p = Person.new
 => #<Person:0x00007f87b08df038>
2.5.0 :035 > p.instance_variables
 => []
2.5.0 :036 > p.name, p.age = "David", 55
 => ["David", 55]
2.5.0 :037 > p.instance_variables
 => [:@name, :@age]
2.5.0 :038 >
```

The irb underscore variable

如果你在一个新开启的 irb 中执行 local_variables 你会看到这样一个变量

```ruby
2.5.0 :018 > local_variables
 => [:_]
```

The underscore is a special irb variable: it represents the value of the last expression evaluated by irb. You can use it to grab values that otherwise will have disappeared:

这个变量存储的是你在 irb 中执行的  上一行命令的最终返回值

```ruby
⮀ irb
2.5.0 :001 > _
 => nil
2.5.0 :002 > x = 100
 => 100
2.5.0 :003 > _
 => 100
2.5.0 :004 > rand 1000
 => 124
2.5.0 :005 > _
 => 124
2.5.0 :006 > "some string"
 => "some string"
2.5.0 :007 > _
 => "some string"
2.5.0 :008 >
```

Next, we’ll look at execution-tracing techniques that help you determine the method-calling history at a given point in runtime.

接下来我们将看下 执行轨迹追踪技术，这将会帮助你决定特定时间点上的程序执行顺序

-

Tracing execution

-

No matter where you are in the execution of your program, you got there somehow. Either you’re at the top level or you’re one or more method calls deep. Ruby provides information about how you got where you are. The chief tool for examining the method-calling history is the top-level method caller.

不管你处于程序执行中的哪个位置，你总是沿着某个路径来到这里的。 不管你是在 top level 中还是在 method 的更深处。 Ruby 都可以提供你是如何到达这里的信息。 这类检查来访路径历史的主要方法是 caller 方法。

-

Examining the stack trace with caller

-

The caller method provides an array of strings. Each string represents one step in the stack trace: a description of a single method call along the way to where you are now. The strings contain information about the file or program where the method call was made, the line on which the method call occurred, and the method from which the current method was called, if any.
Here’s an example. Put these lines in a file called tracedemo.rb:

Caller 方法最后返回一个 array 的 string 信息。 每一个 string 元素代表一步： 对你到达目前所在位置经过的每一个步骤的独立描述。string 中的信息包括该步骤使用的 method 处于文件或程序中的位置，具体执行的代码在哪一行，以及当前执行的是哪一个method(如果有的话)。

下面是一个例子

caller.rb
```ruby
def x
  y
end

def y
  z
end

def z
  puts "Stacktrace: "
  p caller
end

x
```

输出是

```ruby
Stacktrace:
["caller.rb:6:in `y'", "caller.rb:2:in `x'", "caller.rb:15:in `<main>'"]
```

Each string in the stack trace array contains one link in the chain of method calls that got us to the point where caller was called. The first string represents the most recent call in the history: we were at line 6 of tracedemo.rb, inside the method y. The second string shows that we got to y via x. The third, final string tells us that we were in <main>, which means the call to x was made from the top level rather than from inside a method.

每一个字串element代表我们到达 `caller` 方法之前历经的事件点。最靠前的是最近一次的触发点，而最后的 main 那里也就是我们呼叫 `x` 方法的地方告诉我们使用 `x` 方法的地方是在 top level 而不是在某个 method 内部。


Ruby stack traces are useful, but they’re also looked askance at because they consist solely of strings. If you want to do anything with the information a stack trace provides, you have to scan or parse the string and extract the useful information. Another approach is to write a Ruby tool for parsing stack traces and turning them into objects.

Ruby 的 stacktrace 是有用的，但是它看起来有点令人疑惑，因为全部都是 string 构成的信息。如果想对 stacktrace 提供的信息做点什么，我们需要浏览并解析这些信息。 另一个方法是写一个 工具来解析 stacktrace 信息，并把他们转换为 objects.

-

Writing a tool for parsing stack traces

-

Given a stack trace—an array of strings—we want to generate an array of objects, each of which has knowledge of a program or filename, a line number, and a method name (or <main>). We’ll write a Call class, which will represent one stack trace step per object, and a Stack class that will represent an entire stack trace, consisting of one or more Call objects. To minimize the risk of name clashes, let’s put both of these classes inside a module, CallerTools. Let’s start by describing in more detail what each of the two classes will do.

给定一个 stacktrace——一个 array 的 string 信息——我们想要将其变成一个 array 的 objects。 每个 objects 中包含程序或文件的名称，行号，以及方法名称。
我们会写一个 Call class ，这个类下的每一个 object 将会代表 stacktrace 中的一步
还有一个 Stack class ， 这个类将代表一个完整的 stacktrace——由一个或多个 Call 对象构成。

为了减少名称的冲突，我们把这两个类放在一个 module 中叫 CallerTools。

CallerTools::Call will have three reader attributes: program, line, and meth. (It’s better to use meth than method as the name of the third attribute because classes already have a method called method and we don’t want to override it.) Upon initialization, an object of this class will parse a stack trace string and save the relevant substrings to the appropriate instance variables for later retrieval via the attribute-reader methods.

CallerTools::Call 将会有三个 reader attributes 分别是 :program, :line, :meth
每当一个 Call 对象被实例化时，都将解析 stacktrace 中的一个步骤，将 string 中各种信息对应地存入3个attributes 中，方便后面使用 reader 读取。

CallerTools::Stack will store one or more Call objects in an array, which in turn will be stored in the instance variable @backtrace. We’ll also write a report method, which will produce a (reasonably) pretty printable representation of all the information in this particular stack of calls.

Stack 类将会以 array 形式存储 Call 对象，对应的 attribute 是@backtrace。
还会写一个 report 方法，以易读地方式输出 stacktrace 信息。

stacktrace.rb

```ruby
module CallerTools
  class Call
    CALL_RE = /(.*):(\d+):in`(.*)'/
    attr_reader :program, :line, :meth

    def initialize(event)
      @program, @line, @meth = CALL_RE.match(event).captures
    end

    def to_s
      "%30s%5s%15s" % [program, line, meth]
    end

  end
end
```


主要思路是用 带有3个捕获器的 正则表达式 抓取 stacktrace 中的对应信息，然后赋值给对应的 实例变量

正则表达式有固定的表述套路， 冒号是一个明显的信息分隔标志

下面演示了 CALL_RE 是怎么抓取一个典型的 stacktrace 中的信息的

![](https://ws4.sinaimg.cn/large/006tNc79gy1foqb4945d5j30de08uabz.jpg)

注意，上面的截图中第3行有错误， 正则表达式的 in 的后面有一个空格

![](https://ws2.sinaimg.cn/large/006tNc79gy1foqb4wrmh5j30a900uq2v.jpg)


We also define a to_s method for Call objects . This method comes into play in situations where it’s useful to print out a report of a particular backtrace element. It involves Ruby’s handy % technique. On the left of the % is a sprintf-style formatting string, and on the right is an array of replacement values. You might want to tinker with the lengths of the fields in the replacement string—or, for that matter, write your own to_s method, if you prefer a different style of output.


我们重写了 to_s 方法作为输出用。这个方法在报告 stacktrace 信息时会很有用。他包含了 ruby 中很顺手的  % 技术，百分号% 左边是一个 sprintf 格式风格的字串（用来规定输出格式），百分号%右边是一个 array 的值（会应用%左边给出的格式规定）。你或许想对输出格式作一些修改，或者写你自己的 to_s 方法，这都可以。

http://ruby-doc.org/core-2.5.0/String.html#method-i-25


下面是 CallerTools::Stack class

```ruby
class Stack
  def initialize # Stack.new is involved in stacktrace too
    stack = caller
    stack.shift
    @backtrace = stack.map do |call|
      # this step will created (caller.size-1) Call instances
      # then push them into a stack object's @backtrace
      Call.new(call)
    end
  end

  def report
    @backtrace.map do |call|
      call.to_s
    end
  end

  def find(&block)
    @backtrace.find(&block)
  end
end
```

Upon initialization, a new Stack object calls caller and saves the resulting array . It then shifts that array, removing the first string; that string reports on the call to Stack.new itself and is therefore just noise.

The stored @backtrace should consist of one Call object for each string in the my_caller array. That’s a job for map . Note that there’s no backtrace reader attribute. In this case, all we need is the instance variable for internal use by the object.

Next comes the report method, which uses map on the @backtrace array to generate an array of strings for all the Call objects in the stack . This report array is suitable for printing or, if need be, for searching and filtering.

http://ruby-doc.org/core-2.5.0/Array.html#method-i-map

Stack 实例化时，shift 会去除 caller 呼出的 stacktrace 中的第一个 string——反映的是最后一步，也就是 Stack.new 这一步，这不属于我们需要的信息。接着使用 map 枚举将 stacktrace 中的每一个 字串分别送给 Call.new(string)，最后存在 stack 对象的 @backtrace 实例变量中。

注意这里没有 @backtrace attribute reader ，因为这个例子中我们并不会使用到 .backtrace 方法来印出一串信息，@backtrace 只是在内部使用，印出的动作由其他methods 完成，只不过这些方法内部用到了 @backtrace 中存储的信息。

report 方法中，因为 Call.new(string) 每一次生成的是一个 call 对象，所以 map 中使用的 to_s 实际是 Call 中我们重写的 to_s.

The Stack class includes one final method: find . It works by forwarding its code block to the find method of the @backtrace array. It works a lot like some of the deck-of-cards methods you’ve seen, which forward a method to an array containing the cards that make up the deck. Techniques like this allow you to fine-tune the interface of your objects, using underlying objects to provide them with exactly the functionality they need. (You’ll see the specific usefulness of find shortly.)

最后一个 find 方法。他会将 @backtrace 中的每一个对象 送到 block 中。这里很像是之前我们使用过的 一副扑克牌 的例子，将一个 method 转送给包含一副牌的 array 。这类技术允许你对 object 的接口进行微调，使用更底层的 objects 来为他们自己提供他们需要的功能（后面我们会看到具体的应用）

下面来试试我们写的这个 module

首先再看一遍完整的代码

```ruby
# external wrapping
module CallerTools
  # class Call's every instance represents and formats one step of a stacktrace
  class Call
    CALL_RE = /(.*):(\d+):in `(.*)'/
    attr_reader :program, :line, :meth

    def initialize(event)
      @program, @line, @meth = CALL_RE.match(event).captures
    end

    def to_s
      "%30s%5s%15s" % [program, line, meth]
    end
  end

  # class Stack being to hold Call's instance and report formatted info based on Call's work
  class Stack
    def initialize
      stack = caller
      stack.shift
      @backtrace = stack.map do |call|
        Call.new(call)
      end
    end

    def report
      @backtrace.map do |call|
        call.to_s
      end
    end

    def find(&block)
      @backtrace.find(&block)
    end
  end
end
```

You can use a modified version of the “x, y, z” demo from section 15.4.1 to try out CallerTools. Put this code in a file called callertest.rb:

可以利用之前写的 x y z 那个文件，将它改名为 callertest.rb

然后执行这个文件

callertest.rb

```ruby
require './stacktrace.rb'

def x
  y
end

def y
  z
end

def z
  stack = CallerTools::Stack.new
  puts stack.report
end

x
```

这是最后拿到的结果

```ruby
⮀ ruby callertest.rb
                 callertest.rb   12              z
                 callertest.rb    8              y
                 callertest.rb    4              x
                 callertest.rb   16         <main>
```

Nothing too fancy, but it’s a nice programmatic way to address a stack trace rather than having to munge the strings directly every time. (There’s a lot of blank space at the beginnings of the lines, but there would be less if the file paths were longer—and of course you can adjust the formatting to taste.)

Next on the agenda, and the last stop for this chapter, is a project that ties together a number of the techniques we’ve been looking at: stack tracing, method querying, and callbacks, as well as some techniques you know from elsewhere in the book. We’ll write a test framework.

没有太华丽的效果，但这是一个很好的程式化地输出 back trace 信息的方法，这避免了每次都要直接去看一大堆 string 信息。

议程中的下一项，也是这一章的最后一站，会是一个将我们之前提到的很多技术串起来的项目：  stack tracing , method querying , callbacks 以及书中提到的其他一些技术。我们会写一个测试框架。

-

**Callbacks and method inspection in practice**

-

In this section, we’ll implement MicroTest, a tiny test framework. It doesn’t have many features, but the ones it has will demonstrate some of the power and expressiveness of the callbacks and inspection techniques you’ve just learned.
First, a bit of backstory.

这一章我们将写一个小小的测试框架——MicroTest。它不会有太多功能，但可以用来演示我们之前学过的 callbacks 和 inspection 技术是多么的强大和富有表现力。

首先要补充一点背景知识

-

MicroTest background: MiniTest

-

Ruby ships with a testing framework called MiniTest. You use MiniTest by writing a class that inherits from the class MiniTest::Unit::TestCase and that contains methods whose names begin with the string test. You can then either specify which test methods you want executed, or arrange (as we will below) for every test-named method to be executed automatically when you run the file. Inside those methods, you write assertions. The truth or falsehood of your assertions determines whether your tests pass.

The exercise we’ll do here is to write a simple testing utility based on some of the same principles as MiniTest. To help you get your bearings, we’ll look first at a full example of MiniTest in action and then do the implementation exercise.

We’ll test dealing cards. The following listing shows a version of a class for a deck of cards. The deck consists of an array of 52 strings held in the @cards instance variable. Dealing one or more cards means popping that many cards off the top of the deck.”

Ruby 带有一个测试框架叫 MiniTest。我们通过将自己写的 class 继承自 MiniTest::Unit::TestCase 来使用其中以 test 开头的methods。我们可以具体指定要执行哪一个测试方法，或者给每一个 test 开头的方法排好序在你的文件中执行。在这些方法中，你会写 assertions。 Assertion 的真或假决定了你的测试是否通过。

我要写的框架将基于MiniTest 的某些原则。为了让你找到自己的位置，我们先实际试一下真实的 MiniTest 案例，之后再写自己的版本。

我们用之前扑克牌代码。

```ruby
module PlayingCards
  RANKS = %w{ 2 3 4 5 6 7 8 9 10 J Q K A }
  SUITS = %w{ clubs diamonds hearts spades }

  class Deck
    def initialize
      @cards = []
      RANKS.each do |r|
        SUITS.each do |s|
          @cards << "#{r} of #{s}"
        end
      end
      @cards.shuffle!
    end

    def deal(n=1)
      @cards.pop(n)
    end

    def size
      @cards.size
    end
  end

end
```

Creating a new deck  involves initializing @cards, inserting 52 strings into it, and shuffling the array. Each string takes the form “rank of suit,” where rank is one of the ranks in the constant array RANKS and suit is one of SUITS. In dealing from the deck , we return an array of n cards, where n is the number of cards being dealt and defaults to 1.
So far, so good. Now, let’s test it. Enter MiniTest. The next listing shows the test code for the cards class. The test code assumes that you’ve saved the cards code to a separate file called cards.rb in the same directory as the test code file (which you can call cardtest.rb).

接下来我们用 MiniTest 进行测试，测试文件和 PlayingCards 文件放在同一目录下。

microtest_cardstest.rb

```ruby
require 'minitest/unit'
require 'minitest/autorun'
require_relative 'microtest_cards'

class CardTest < MiniTest::Unit::TestCase
  def setup
    @deck = PlayingCards::Deck.new
  end

  def test_deal_one
    @deck.deal
    assert_equal(51, @deck.size)
  end

  def test_deal_many
    @deck.deal(5)
    assert_equal(47, @deck.size)
  end
end
```

The first order of business is to require both the minitest/unit library and the cards.rb file . We also require minitest/autorun; this feature causes MiniTest to run the test methods it encounters without our having to make explicit method calls. Next, we create a CardTest class that inherits from MiniTest::Unit::TestCase . In this class, we define three methods. The first is setup . The method name setup is magic to MiniTest; if defined, it’s executed before every test method in the test class. Running the setup method before each test method contributes to keeping the test methods independent of each other, and that independence is an important part of the architecture of test suites.


第一件事是 require 到 minitest/unit 库以及 扑克牌代码文件，另外还 require 了 minitest/autorun ；这个功能使得 MiniTest 能够让我们在不执行具体 methods 的情况下执行测试。

接下来我们建立了一个 CardTest 类，让他继承自 MiniTest::Unit::TestCase。在这个 class 中我们定义了三个方法
1 `setup`， 这个方法会在执行任何一个 test method 之前自动执行一次，这样可以使每次测试都独立于其他测试，相当于一次重置。独立性对于测试来说是很重要的前提。


Now come the two test methods, test_deal_one  and test_deal_many . These methods define the actual tests. In each case, we’re dealing from the deck and then making an assertion about the size of the deck subsequent to the dealing. Remember that setup is executed before each test method, which means @deck contains a full 52-card deck for each method.

The assertions are performed using the assert_equal method . This method takes two arguments. If the two are equal (using == to do the comparison behind the scenes), the assertion succeeds. If not, it fails.
Execute cardtest.rb from the command line. Here’s what you’ll see (probably with a different seed and different time measurements):

接下来是 test_deal_one 和 test_deal_many 两个方法。
这两个方法都是实际进行测试的方法。在每一个方法中，我们明确给出的发牌的数量以及发牌后 @cards 的size。记住 setup 会在每一个测试方法前执行一次，所以每次测试对是在对一副新的完整的扑克牌进行测试。

assert_equal 是我们用来执行断言的方法，这个方法接受两个参数，如果给出的两个参数的测试结果是相等，那么断言通过，否则失败。

书中给出的引入 MiniTest 库的代码有所改变

![](https://ws4.sinaimg.cn/large/006tNc79gy1foqcey5dwbj30de03st9t.jpg)

前面require的文件应该改为

```ruby
require 'minitest/autorun'
require 'microtest_cards'
```
https://stackoverflow.com/questions/28597971/ruby-unittest-error-you-should-require-minitest-autorun-instead

修改好 require 的文件之后，运行 microtest_cardstest.rb

```ruby
⮀ ruby microtest_cardstest.rb
Run options: --seed 33974

# Running:

..

Finished in 0.001026s, 1949.3179 runs/s, 1949.3179 assertions/s.
2 runs, 2 assertions, 0 failures, 0 errors, 0 skips
```


The last line tells you that there were two methods whose names began with test (2 tests) and a total of two assertions (the two calls to assert_equal). It tells you further that both assertions passed (no failures) and that nothing went drastically wrong (no errors; an error is something unrecoverable like a reference to an unknown variable, whereas a failure is an incorrect assertion). It also reports that no tests were skipped (skipping a test is something you can do explicitly with a call to the skip method).

最后一行告诉我们 测试文件中有两个 以 test_开头的方法(`2 runs`)，也就对应了两个测试。其中包含两个断言(`2 assertions`)，而且都通过了(`0 failures`)，没有出现失败的情况。同时报告了没有测试被跳过(`0 skips`)（我们可以手动设置跳过某些步骤）。

The most striking thing about running this test file is that at no point do you have to instantiate the CardTest class or explicitly call the test methods or the setup method. Thanks to the loading of the autorun feature, MiniTest figures out that it’s supposed to run all the methods whose names begin with test, running the setup method before each of them. This automatic execution—or at least a subset of it—is what we’ll implement in our exercise.

最惊奇的事是我们不需要 实例化 CardTest 类或者明确使用 测试方法 或者 每次都写setup 来执行它。多亏了 autorun 功能， MiniTest 了解他应该自动运行所有以 test_开头的测试方法，在每一个测试执行前运行 setup。这种自动执行功能，或者至少一部分这样的功能将会是我们后面要实际完成的。

-

Specifying and implementing MicroTest

-

在我们自己版本的 MicroTest 中我们打算实现的功能有

Automatic execution of the setup method and test methods, based on class inheritance

A simple assertion method that either succeeds or fails

The first specification will entail most of the work.

以 class 继承的方式实现 setup 在每个测试方法执行前的自动运行

一个简单的判断真假的断言机制

多数的工作会用在第一个标准上。

We need a class that, upon being inherited, observes the new subclass and executes the methods in that subclass as they’re defined. For the sake of (relative!) simplicity, we’ll execute them in definition order, which means setup should be defined first.

我们需要一个 class ，当他被另一个 subclass 继承时，能够自动执行 subclass 中定义的方法。为了简单起见，我们将会以定义顺序来执行他们，也就是说 setup 方法应该被第一个定义。

下面是更具体的描述

1.Define the class MicroTest.   定义 MicroTest 类
2.Define MicroTest.inherited.   在 MicroTest 里写 inherited (hook)方法
3.Inside inherited, the inheriting class should… 在 inherited 方法内写入具体代码
4.Define its own method_added callback, which should… 写 method_added 方法
5.Instantiate the class and execute the new method if it starts with test, but first… 实例化class 的同时执行新写好的以test 开头的方法。
6.Execute the setup method, if there is one.  如果 定义了setup 方法，首先在每一个方法前执行它。

我们先在文件中用注释搭建好整体框架

microtest.rb

```ruby
class MicroTest
  def self.inherited(c)
    c.class_eval do
      def self.method_added(m)
      # If m starts with 'test'
      #    Create an instance of c
      #    If there's a setup method
      #       execute setup
      #    Execute method m
      end
    end
  end
end
```

There’s a kind of logic cascade here. Inside MicroTest, we define self.inherited, which receives the inheriting class (the new subclass) as its argument. We then enter into that class’s definition scope using class_eval. Inside that scope, we implement method_added, which will be called every time a new method is defined in the class.

Writing the full code follows directly from the comments inside the code mockup. The following listing shows the full version of micro_test.rb. Put it in the same directory as callertools.rb.

这是大概的逻辑构成。在 MicroTest 内部，我们定义了 self.inherited 方法（接受发出继承动作的 class 作为参数）。接着使用c.class_eval  进入子类的类方法定义域，在里面定义了 self.method_added ，这个方法会在 每当有新实例方法(instance methods)在这个 class 内部进行定义时执行。

![](https://ws2.sinaimg.cn/large/006tNc79gy1foqdg0zg70j30de04c74w.jpg)

我们会沿着注释展开代码编写。

microtest.rb

```ruby
require_relative 'stacktrace'

class MicroTest
  def self.inherited(c)         # Once a class inherit from MicroTest, this method will be triggered
    c.class_eval do
      def self.method_added(m)  # whatever instance method was building in testing class, this method will be triggered
        puts "method_added got triggered..."
        if m =~ /^test/         # If m starts with 'test'
          obj = self.new        #   create an instance of c
          if self.instance_methods.include?(:setup) # if there's a setup method
            obj.setup                               # execute it
          end
          obj.send(m)                               # Execute m
        end
      end
    end
  end

  def assert(assertion) # to be used in assert_equal method
    if assertion
      puts "Assertion passed."
      true
    else
      puts "Assertion failed: "
      stack = CallerTools::Stack.new
      failure = stack.find { |call| call.meth !~ /assert/ }
      puts failure
      false
    end
  end

  def assert_equal(expected, actual)
    result = assert(expected == actual)
    puts "#{actual} is not #{expected}" unless result
    result
  end

end
```

Inside the class definition (class_eval) scope of the new subclass, we define method_added, and that’s where most of the action is. If the method being defined starts with test , we create a new instance of the class . If a setup method is defined , we call it on that instance. Then (whether or not there was a setup method; that’s optional), we call the newly added method using send because we don’t know the method’s name.

在(你将要测试的)class 内部定义好 self.method_added(method_name) 方法，这是最重要的步骤之一。当在 (你将要测试的) class 内部，如果新定义了方法，就会触发 method_added(m)， m 代表的就是你新定义的方法的完整名称。

如果新定义的方法名称以test 开头(^ 代表 the start of a line)，实例化一个测试class 对象存入 obj 。

       如果测试class 的实例对象中有一个 setup 方法，执行它

对 obj 执行 m 方法。

要记住以上步骤被包裹在 self.inherited 内部，所以当 测试 class 继承自 MicroTest 时会自动触发以上步骤。

Note

As odd as it may seem (in light of the traditional notion of pattern matching, which involves strings), the m in the pattern-matching operation m =~ /^test/ is a symbol, not a string. The ability of symbol objects to match themselves against regular expressions is part of the general move we’ve already noted toward making symbols more easily interchangeable with strings. Keep in mind, though, the important differences between the two, as explained in chapter 8.

第5行的 m 应该是个 symbol ，以往我们看到的都是 string 和 regular expression 匹配。但这种用法也可以，他体现出 string 和 symbol 之间某些方面的可互换性。但也要记住二者之间重要的区别。

The assert method tests the truth of its single argument . If the argument is true (in the Boolean sense; it doesn’t have to be the actual object true), a message is printed out, indicating success. If the assertion fails, the message printing gets a little more intricate. We create a CallerTools::Stack object and pinpoint the first Call object in that stack whose method name doesn’t contain the string assert . The purpose is to make sure we don’t report the failure as having occurred in the assert method nor in the assert_equal method (described shortly).

It’s not robust; you might have a method with assert in it that you did want an error reported from. But it illustrates the kind of manipulation that the find method of CallerTools::Stack allows.
The second assertion method, assert_equal, tests for equality between its two arguments . It does this by calling assert on a comparison. If the result isn’t true, an error message showing the two compared objects is displayed . Either way—success or failure—the result of the assert call is returned from assert_equal.

Assert 方面接受一个参数，如果 给出的参数的 boolean 值是 true 那么印出断言通过，return true
如果 assertion 的 boolean 判断为 false， 那么印出断言 失败。接着实例化一个 Stack 对象，将当前的 stack trace 信息存入这个对象。接着使用find 找出 stack trace 信息中 第一个(find只)不包含  assert 的方法。这么做是为了确保我们不会在报错时 针对了 assert 和 assert_equal 方法本身。这么做并不完美，或许你要测试的class 中就存在一个需要测试的方法带有 ‘assert’ 。 但这演示了 find 能够起到的作用。
24行印出 了错误信息， 25行 return false

assert_equal 方法 , 利用到 assert 方法对传入的两个参数进行 == 比较，(expected == actual) 返回的是 boolean 值。如果返回的是 false 那么印出错误提示。
不管 expected 和 actual 的 == 比较返回的是什么，最后一步都会返回 assert(expected == actual) 作为最终返回值，也就是进入到 assert 方法流程。

To try out MicroTest, put the following code in a file called microcardtest.rb, and run it from the command line:

现在来试一试 class MicroTest ，将下面的代码放入一个叫 mirocardtest.rb 的文件，然后再 cml 中执行

```ruby
require_relative 'microtest'
require_relative 'microtest_cards'

class CardTest < MicroTest
  def setup
    @deck = PlayingCards::Deck.new
  end

  def test_deal_one
    @deck.deal
    assert_equal(51, @deck.size)
  end

  def test_deal_many
    @deck.deal(5)
    assert_equal(47, @deck.size)
  end
end
```

结果是

```ruby
Assertion passed.
Assertion passed.
```

As you can see, this code is almost identical to the MiniTest test file we wrote before. The only differences are the names of the test library and parent test class. And when you run the code, you get these somewhat obscure but encouraging results:

如上，运行返回结果和 MiniTest 很像，只不过我们测试功能所在库的名称不同。执行返回的结果虽然很笼统但是却鼓舞人心。

如果想看下错误结果，可以将 test_deal_one 中的 51 改成 50

```ruby
Assertion failed:
              microcardtest.rb   11  test_deal_one
51 is not 50
Assertion passed.
```

MicroTest won’t supplant MiniTest any time soon, but it does do a couple of the most magical things that MiniTest does. It’s all made possible by Ruby’s introspection and callback facilities, techniques that put extraordinary power and flexibility in your hands.

我们自己写的 MicroTest 不可能完全替代 MiniTest 。但是它做到了最具魔力的那部分。这要归功于 ruby 的 inspection 和 callback 技术带来的强大力量和灵活性。

代码中使用到了 `c.class_eval do` 来打开目标class body进行内部操作，这里不能使用 `class c` 来替换，因为 `c` 在这个语境下是一个 object 而不是 `class C` 这样的形式，所以语法上错误：

```ruby
⮀ ruby microcardtest.rb
Traceback (most recent call last):
	1: from microcardtest.rb:1:in `<main>'
microcardtest.rb:1:in `require_relative': /Users/caven/Notes & Articles/Note of Rubyist/code examples/microtest.rb:6: class/module name must be CONSTANT (SyntaxError)
     class c
            ^
/Users/caven/Notes & Articles/Note of Rubyist/code examples/microtest.rb:6: class definition in method body
     class c
            ^
```

但如果换成 singleton class 的写法 `class << c` 在句法上是正确的

但前面提过在 singleton class 中写的 callback 并不会被继承的subclasses 触发。

所以还是要用回 `c.class_eval do`

我们可以给 microtest.rb 中的特定点加上一些识别信息来看某些方法是否触发

使用 class_eval 的版本

```ruby
def self.inherited(c)        
  puts "-----------Now #{c} inherits from #{self}------------\n\n"
  c.class_eval do
    def self.method_added(m)  
      puts "------------method_added got triggered by #{m}"
      if m =~ /^test/         
        obj = self.new       
        if self.instance_methods.include?(:setup)
          obj.setup                               
        end
        obj.send(m)                               
      end
    end
  end
end
```

输出

```ruby
-----------Now CardTest inherits from MicroTest------------

------------method_added got triggered by setup
------------method_added got triggered by test_deal_one
Assertion failed:
              microcardtest.rb   11  test_deal_one
51 is not 50
------------method_added got triggered by test_deal_many
Assertion passed.
```

使用 singlton class 语法的版本

```ruby
def self.inherited(c)        
  puts "-----------Now #{c} inherits from #{self}------------\n\n"
  c.class_eval do
    def self.method_added(m)  
      puts "------------method_added got triggered by #{m}"
      if m =~ /^test/         
        obj = self.new       
        if self.instance_methods.include?(:setup)
          obj.setup                               
        end
        obj.send(m)                               
      end
    end
  end
end
```

输出

```ruby
⮀ ruby microcardtest.rb
-----------Now CardTest inherits from MicroTest------------

```

后一个例子中，可以看到 `method_added` 并没有被触发

将第一个例子视觉化

![](https://ws3.sinaimg.cn/large/006tNc79gy1foqf7hwj7lj312o0b8tdl.jpg)















---

## Summary

In this chapter, you’ve seen

- Intercepting methods with method_missing  使用 method_missing 截获不存在的方法

- Runtime hooks and callbacks for objects, classes, and modules 对象以及类/module 层级的 hooks 和 callbacks

- Querying objects about their methods, on various criteria  以不同的标准查询对象的 methods

- Trapping references to unknown constants 把 const_missing 作为 hook 触发点

- Stack traces  堆栈追踪信息

- Writing the MicroTest framework 写 MicroTest 测试框架

We’ve covered a lot of ground in this chapter, and practicing the techniques covered here will contribute greatly to your grounding as a Rubyist. We looked at intercepting unknown messages with method_missing, along with other runtime hooks and callbacks like Module.included, Module.extended, and Class.inherited. The chapter also took us into method querying in its various nuances: public, protected, private; class, instance, singleton. You’ve seen some examples of how this kind of querying can help you derive information about how Ruby does its own class, module, and method organization.

这一站我们涵盖了很多内容，这一章实践的技术将会对你成为一个有坚实基础的Rubyist 有巨大的助益。 我们学习了使用 method_missing 来窃取未知信息，还有其他一些 hooks 和 callbacks 比如 Module.included, Module.extended 以及 Class.inherited。 我们同样了解了查询不同权限层级的方法： public, private , protected ; 以及 class , instance , singleton 。 你已经看到了一些能够帮助你了解ruby自身 class , module 构成的方法。

The last overall topic was the handling of stack traces, which we put to use in the CallerTools module. The chapter ended with the extended exercise consisting of implementing the MicroTest class, which pulled together a number of topics and threads from this chapter and elsewhere.

接下来是关于 stack trace 的，我们将代码写在 module CallerTools 中。最后我们将之前学到的很多个话题串到一起，用来写我们自己的 测试框架。

We’ve been going through the material methodically and deliberately, as befits a grounding or preparation. But if you look at the results, particularly MicroTest, you can see how much power Ruby gives you in exchange for relatively little effort. That’s why it pays to know about even what may seem to be the magic or “meta” parts of Ruby. They really aren’t—it’s all Ruby, and once you internalize the principles of class and object structure and relationships, everything else follows.

And that’s that! Enjoy your groundedness as a Rubyist and the many structures you’ll build on top of the foundation you’ve acquired through this book.

我们已经悉心学习了这些材料，这会作为我们的基础。但是观察一下最后的结果，尤其是 MicroTest ，会发现 ruby 是如何以少量的代码实现强大的功能的。这也是为什么值得花精力去了解ruby中那些最神奇的部分。 这就是 ruby ， 如果你讲 class 和 object 构成的原则内化于心，一且都会水到渠成。

就到这里了，享受作为一个有良好基础的Rubyist 的感觉，你将会在本书知识的基础上搭建出更加丰富的结构。
