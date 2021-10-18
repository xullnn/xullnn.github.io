---
title:  "Rubyist-c3-Organizing objects with classes"
categories: [Ruby/Rails ℗]
tags: [Ruby & Rails, Notes of Rubyist]
---


*注：这一系列文章是《The Well-Grounded Rubyist》的学习笔记。*



---

Talking about classes doesn’t mean you’re not talking about objects; that’s why this chapter has the title it has, rather than, say, “Ruby classes.” Much of what we’ll look at here pertains to objects and methods—but that’s because classes are, at heart, a way to organize objects and methods. We’ll look at the kinds of things you can and will do inside classes, as well as what classes themselves are.

ruby 中谈论class 并不代表你没有在谈论 object 实际上 class 本身也是 object ，另一方面 class 也是我们组织对象以及methods 的一种方式，这也表明这并不是唯一方式。

—

Constants can change—they’re not as constant as their name implies. But if you assign a new value to a constant, Ruby prints a warning. The best practice is to avoid assigning new values to constants that you’ve already assigned a value to.”

常量并不如它字面上的名字所暗含的那样不可改变，当人为尝试去改变一个常量的值时，ruby会抛出警告，但最好不要这么做

```ruby
2.5.0 :001 > ONE = [1, 2, 3]
 => [1, 2, 3]
2.5.0 :002 > ONE[2] = "8"
 => "8"
2.5.0 :003 > ONE
 => [1, 2, "8"]
2.5.0 :004 > ONE = [7, 8, 9]
(irb):4: warning: already initialized constant ONE
(irb):1: warning: previous definition of ONE was here
 => [7, 8, 9]
2.5.0 :005 > ONE
 => [7, 8, 9]
```

除了在 class 里面直接用 def sample 来定义通用的 instance method

也可以单独为某一个特定的 object 定义专用 method

```ruby
class Ticket
  def event
    # do some
  end

  ticket_1 = Ticket.new

  def ticket_1.price
    # do some
  end
end
```

上面的 ticket_1.price 称为 singleton method

Methods that you define for one particular object—as in def ticket.price — are called singleton methods.

-

当第一次写出 class Sample;  end 时我们建立了一个新的 class

当我们再次，甚至多次 写 class Sample 并在里面写入新的 method 时不会将原来的所有内容覆盖，而是附加上去

```ruby
2.5.0 :001 > class X
2.5.0 :002?>   def one
2.5.0 :003?>     puts "one"
2.5.0 :004?>   end
2.5.0 :005?> end
 => :one
2.5.0 :006 > X.new.one
one
 => nil
2.5.0 :007 > class X
2.5.0 :008?>   def two
2.5.0 :009?>     puts "two"
2.5.0 :010?>   end
2.5.0 :011?> end
 => :two
2.5.0 :012 > X.new.two
two
 => nil
2.5.0 :013 > X.new.one
one
 => nil
```

这种拆分 class 的写法不容易阅读

但是在某些场景下会用到

比如会把同一个 class 的 不同 method 写在不同的 文件file 中

运行程序时 require 不同数量的 file 就能得到特定组合的 methods

类似 rails 中 partial 的用法

-

ruby 本身也用到了这种 重新打开 class 的方法

require 库的方法就是一个例子

```ruby
2.5.0 :002 > t = Time.now
 => 2018-01-24 14:18:56 +0800
2.5.0 :003 > t.xmlschema
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):3
NoMethodError (undefined method `xmlschema' for 2018-01-24 14:18:56 +0800:Time)
2.5.0 :004 > require 'time'
 => true
2.5.0 :005 > t.xmlschema
 => "2018-01-24T14:18:56+08:00"
```

上面的例子中，Time的实例在没有 require ’time’ 之前是没有 .xmlschema 这个方法的。只不过这里 time 库更可能是 module 不是 class

-

class 中的 initialize method会在每次 new 一个 class 的时候被执行

```ruby
2.5.0 :001 > class X
2.5.0 :002?>   def initialize
2.5.0 :003?>     puts "When you are creating an instance ..."
2.5.0 :004?>   end
2.5.0 :005?> end
 => :initialize
2.5.0 :006 > X.new
When you are creating an instance ...
 => #<X:0x00007fec89031e70>
2.5.0 :007 >
```

这个行为类似 rails 中的 before_action call back 方法

-

关于 sprintf % 的用法

f float
d decimal
s string
…

http://ruby-doc.org/core-2.4.2/Kernel.html#method-i-sprintf

```ruby
2.5.0 :001 > "%.2f" % 23.456
 => "23.46"
2.5.0 :002 > "%.2d" % 23.456
 => "23"
2.5.0 :003 > "%.2s" % 23.456
 => "23"
```
—

—

def price=(number)
  @price = number
end

Programmers use the term syntactic sugar to refer to special rules **that let you write your code in a way that doesn’t correspond to the normal rules but that’s easier to remember how to do and looks better.**

这种命名 method 的手法叫做 syntactic sugar

虽然定义方法时  price=(price) 的等号两边没有空格，但是 ruby 会自动将这一类定义扩展到有空格的情况

所以用 instance.price = 199.0  的时候同样有效

—

class 中类似

def price
  @price
end

其实对应到 attr_reader :price

def price=(price)
  @price=price
end

其实对应到 attr_writer :price

如果都有就是 attr_accessor :price

attr_accessor is the equivalent of attr_reader plus attr_writer.
—-


attr_accessor 实际是 class method

前面省掉了 self.

—

还有一种不常见的 attr 方法

attr :price, true  与  attr_accessor :price 等价

attr :price 与 attr_reader :price 等价

但这个方法相对少见

——

class 中类似

def price
  @price
end

其实对应到 attr_reader :price

def price=(price)
  @price=price
end

其实对应到 attr_writer :price

如果都有就是 attr_accessor :price

attr_accessor is the equivalent of attr_reader plus attr_writer.
—-


attr_accessor 实际是 class method

前面省掉了 self.

—

还有一种不常见的 attr 方法

attr :price, true  与  attr_accessor :price 等价

attr :price 与 attr_reader :price 等价

但这个方法相对少见

—

class 中类似

def price
  @price
end

其实对应到 attr_reader :price

def price=(price)
  @price=price
end

其实对应到 attr_writer :price

如果都有就是 attr_accessor :price

attr_accessor is the equivalent of attr_reader plus attr_writer.
—-


attr_accessor 实际是 class method

前面省掉了 self.

—

还有一种不常见的 attr 方法

attr :price, true  与  attr_accessor :price 等价

attr :price 与 attr_reader :price 等价

但这个方法相对少见

—

class 中类似

def price
  @price
end

其实对应到 attr_reader :price

def price=(price)
  @price=price
end

其实对应到 attr_writer :price

如果都有就是 attr_accessor :price

attr_accessor is the equivalent of attr_reader plus attr_writer.
—-


attr_accessor 实际是 class method

前面省掉了 self.

—

还有一种不常见的 attr 方法

attr :price, true  与  attr_accessor :price 等价

attr :price 与 attr_reader :price 等价

但这个方法相对少见

—

class 中类似

```ruby
def price
  @price
end
```
其实对应到 attr_reader :price
```ruby
def price=(price)
  @price=price
end
```
其实对应到 attr_writer :price

如果都有就是 attr_accessor :price

attr_accessor is the equivalent of attr_reader **plus** attr_writer.


—-


attr_accessor 实际是 class method

前面省掉了 `self`.

—

还有一种不常见的 attr 方法

attr :price, true  与  attr_accessor :price 等价

attr :price 与 attr_reader :price 等价

但这个方法相对少见

-
class 的演化进程

![](https://ws2.sinaimg.cn/large/006tNc79gy1fnromllcbbj31kw0eudjo.jpg)

注意在所有上面的 class 中 initialize 方法都不是必须的，他类似一个 call back 在不指定默认值时 如果 new 一个新A 时反而会报错

更稳妥的方法是写 def initialize(event=nil, price=nil) 这样就不会强制要求新建实例的时候要求传参数

这是 `def initialize(event,price)`版本
```ruby
2.5.0 :001 > load './class_v3.rb'
 => true
2.5.0 :002 > a = A.new
Traceback (most recent call last):
        4: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        3: from (irb):2
        2: from (irb):2:in `new'
        1: from /Users/caven/Notes & Articles/Note of Rubyist/code examples/class_v3.rb:3:in `initialize'
ArgumentError (wrong number of arguments (given 0, expected 2))
```

这是 `def initialize(event=nil, price=nil)` 版本
```ruby
2.5.0 :002 > load './class_v3.rb'
 => true
2.5.0 :003 > a = A.new
 => #<A:0x00007fe6d401a0f0 @event=nil, @price=nil>
```
如果不写 initialize 只写  attr_accessor

那么在新建 instance 的时候就不能同时传参数

需要另起一行写 instance.price = ### 来赋值

综合来看，在 initialize 中使用 nil 作为默认值的方法是比较好的

所以，合理的版本应该是v5

```ruby
class A
  attr_accessor :event
  attr_reader :price

  def initialize(event=nil,price=nil)
    @event = event
    @price = price
  end
end
```

但这里 :price 是只读，:price 没有writer方法来赋值，但是 initialize 中却写了它

因为实际上 initialize 有更高的权限

```ruby
2.5.0 :001 > load './class_v5.rb'
 => true
2.5.0 :002 > t = A.new("Tennis", 1800)
 => #<A:0x00007fa17b8224f8 @event="Tennis", @price=1800>
2.5.0 :003 > t.price
 => 1800
2.5.0 :004 > t.price = 2000  # price= 这个方法是没有被定义的
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):4
NoMethodError (undefined method `price=' for #<A:0x00007fa17b8224f8 @event="Tennis", @price=1800>
Did you mean?  price)
```

**inheritance 与 module**

```ruby
2.5.0 :001 > class Publication
2.5.0 :002?>   attr_accessor :publisher
2.5.0 :003?> end
 => nil
2.5.0 :004 > class Magzine < Publication
2.5.0 :005?>   attr_accessor :editor
2.5.0 :006?> end
 => nil
2.5.0 :007 > mg = Magzine.new
 => #<Magzine:0x00007fae9d848520>
2.5.0 :008 > mg.publisher = "US"
 => "US"
2.5.0 :009 > mg.editor = "Caven"
 => "Caven"
2.5.0 :010 > mg
 => #<Magzine:0x00007fae9d848520 @publisher="US", @editor="Caven">
```

—

ruby 中不允许一个 class 同时继承自多个 class

这个限制称为  single inheritance

如果需要以组块形式引入更多功能 可以选择 module

module 和 class 很类似，只不过它不能 Module.new 来实例化一个对象

—

ruby 中几乎所有 class 都继承自 class Object

从逻辑上看，只要是在  class Object 中定义的 method 在他所有的 subclass 中都可以用

—

The idea behind BasicObject is to offer a kind of blank-slate object—an object with almost no methods. (Indeed, the precedent for BasicObject was a library by Jim Weirich called BlankSlate.) BasicObjects have so few methods that you’ll run into trouble if you create a BasicObject instance in irb:

BasicObject 背后的思想是提供一个类似白板的对象——一个几乎没有 methods 的对象。（确切的说，BasicObject 前身是 Jim Weirich 写的一个叫 BlankSlate的库）。BasicObject 中能用的方法是如此之少你甚至例化一个 BasicObject 对象时都会遇到麻烦。

```ruby
2.5.0 :002 > BasicObject.new
(Object doesn't support #inspect)
 =>
2.5.0 :003 > BasicObject.new.methods.count
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):3
NoMethodError (undefined method `methods' for #<BasicObject:0x00007feffd839b50>)
2.5.0 :004 > BasicObject.methods.count
 => 111
```

BasicObject 类似一个垫底的白板，可以理解为 photoshop 中最底下的那个图层

里面没有太多东西 甚至没有 .inspect 这个 method

class 们也是一种对象，所以也可以如实例对象一般接受 message 或说作为 receivers

—

Classes are special objects: they’re the only kind of object that has the power to spawn new objects (instances). Nonetheless, they’re objects. When you create a class, like Ticket, you can send messages to it, add methods to it, pass it around to other objects as a method argument, and generally do anything to it you would to another object.
Like other objects, classes can be created—indeed, in more than one way.

class 是一类特殊的 object

它是唯一可以产生 instance 的对象

-

除了常见的 以 class Name; end 形式来建立新 class 的方法外

还可以直接使用 Class.new 来新建，甚至可以把他赋值给一个变数，这种情况下 这个 class 是没有名字的

上面的方法套上 block 可以定义 匿名 class 中的 methods

```ruby
2.5.0 :001 > anonymous_class = Class.new do
2.5.0 :002 >   def say_hello
2.5.0 :003?>     puts "Hello World."
2.5.0 :004?>   end
2.5.0 :005?> end
 => #<Class:0x00007f8d0c020530>
2.5.0 :006 > anonymous_class.new.say_hello
Hello World.
 => nil
```

当然也可以使用 `Ticket = Class.new` 来建立 一个叫 Ticket 的 class

-

class methods 其实就是  class 层级的 singleton method

singleton-method style. A singleton method defined on a class object is commonly referred to as a class method of the class on which it’s defined.

-

Class 这个 class 既有 class method 层级的 :new （可以用来新建其他 class）

同时他又有 instance method 层级的 :new 让他生出的实例 class 用

比如

Ticket = Class.new # class 层级

t = Ticket.new # instance 层级

但是会发现其实第二个 new 对于 Class 来说是 instance method 但对于 Ticket 来说又是 class method

```ruby
2.5.0 :001 > Class.respond_to?(:new)
 => true
2.5.0 :002 > Class.new.respond_to?(:new)
 => true
```

—

三个基本原则

Classes are objects.

Instances of classes are objects, too.

A class object (like Ticket) has its own methods, its own state, and its own identity. It doesn’t share these things with instances of itself. Sending a message to Ticket isn’t the same thing as sending a message to fg or cc or any other instance of Ticket.

	•	Classes 也是对象
	•	Classes 的实例也是对象
	•	class method 和 instance method 是不同层面的东西
—

class method 和 instance method 也有不同的表示方法

Ticket.method 指 class method
Ticket#method 指 instance method （比如 rails routes.rb 中的 controller 列）
Ticket::method 指 class method

—

### Constant

-

class 的构成三要素：

	•	class methods
	•	instance methods
	•	constant

  ruby 中有一些内建的 constant

  Ruby’s predefined constants

  如 Math::PI

  ```ruby
  2.5.0 :001 > RUBY_VERSION
   => "2.5.0"
  2.5.0 :002 > Math::PI
   => 3.141592653589793
  2.5.0 :003 > RUBY_RELEASE_DATE
   => "2017-12-25"
  2.5.0 :004 > RUBY_COPYRIGHT
   => "ruby - Copyright (C) 1993-2017 Yukihiro Matsumoto"
  ```

constant 并不是不可改变，但是要注意 重新赋值（即使是相同内容）会引起警告

但如果只是改变其中的内容 则不会

这个案例和前面提到的  object 在内存中的 编号 机制契合

```ruby
2.5.0 :001 > CON = [1, 2, 3]
 => [1, 2, 3]
2.5.0 :002 > CON = [1, 2, 3]
(irb):2: warning: already initialized constant CON
(irb):1: warning: previous definition of CON was here
 => [1, 2, 3]
2.5.0 :003 > ANO = [1, 2, 3]
 => [1, 2, 3]
2.5.0 :004 > ANO.object_id
 => 70343050490720
2.5.0 :005 > ANO.push 4
 => [1, 2, 3, 4]
2.5.0 :006 > ANO.object_id
 => 70343050490720
2.5.0 :007 > ANO[1] = "hello"
 => "hello"
2.5.0 :008 > ANO.object_id
 => 70343050490720
2.5.0 :009 > ANO
 => [1, "hello", 3, 4]
```
The difference between reassigning a constant name and modifying the object referenced by the constant is important, and it provides a useful lesson in two kinds of change in Ruby: changing the mapping of identifiers to objects (assignment) and changing the state or contents of an object.

重新给一个 constant 赋值和改变 constant 中的对象是不同的，这一点很重要。这印出ruby中两种不同类型的改变：改变object的位置编码，修改object的状态或其中的内容。

```ruby
2.5.0 :002 > CON = [1, 2, 3]
 => [1, 2, 3]
2.5.0 :003 > CON.object_id
 => 70097729335000
2.5.0 :004 > CON.replace 123
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):4
        1: from (irb):4:in `replace'
TypeError (no implicit conversion of Integer into Array)
2.5.0 :005 > CON.replace [7, 8, 9]
 => [7, 8, 9]
2.5.0 :006 > CON
 => [7, 8, 9]
2.5.0 :007 > CON.object_id
 => 70097729335000
```
上面例子中 CON 中的内容被改变，但它仍然是那个对象。

-

使用 is a 来描述 ruby 中 instance 和 class 的关系十分贴切

an ezine is a Magazine

a magazine is a Publication

ruby 中甚至有一个 is_a? 方法来判断一个 object 是不是 另一个 object 的子嗣

```ruby
2.5.0 :001 > class Publication; end
 => nil
2.5.0 :002 > class Magazine < Publication
2.5.0 :003?> end
 => nil
2.5.0 :004 > class Ezine < Magazine
2.5.0 :005?> end
 => nil
2.5.0 :006 > ebook = Ezine.new
 => #<Ezine:0x00007f83640bd080>
2.5.0 :007 > ebook.is_a?(Ezine)
 => true
2.5.0 :008 > ebook.is_a?(Magazine)
 => true
2.5.0 :009 > ebook.is_a?(Publication)
 => true
2.5.0 :010 > newspaper = Publication.new
 => #<Publication:0x00007f8364817da8>
2.5.0 :011 > newspaper.is_a?(Publication)
 => true
2.5.0 :012 > newspaper.is_a?(Magazine)
 => false
2.5.0 :013 > Ezine.is_a?(Publication)
 => false
```

注意最后一段， is_a? 不是用来判断 class 之间的继承关系

-

一个 object 可以使用它所属的 class 中定义的 各种 methods 但是它的能力并不知限于此

它还可以有自己单独的 singleton method

```ruby
2.5.0 :014 > def ebook.wings
2.5.0 :015?>   puts "Look! I can fly ..."
2.5.0 :016?> end
 => :wings
2.5.0 :017 > ebook.wings
Look! I can fly ...
 => nil
2.5.0 :018 > Ezine.new.wings
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):18
NoMethodError (undefined method `wings' for #<Ezine:0x00007f836481ba20>)
```

wings 这个 method 属于 ebook 这个 实例， 但却不属于同 class 下的其他实例或 class 本身

不过上面这种给单个 instance 定义方法的行为很少见，如果你一定要这么做，那么背后要有真正支持你这么做的 原因和理由
常见的 singleton-style method 常用于定义 class methods

### Summary
In this chapter, you’ve learned the basics of Ruby classes:
 
How writing a class and then creating instances of that class allow you to share behaviors among numerous objects.
如何写一个 class 以及如何实例化对象，以及这些对象之间如何共享多个方法

How to use setter and getter methods, either written out or automatically created with the attr_* family of methods, to create object attributes, which store an object’s state in instance variables.
如何使用 setter 和 getter 方法，以及 attr_* 系列方法，如何给class 中的对象设置 attributes， 如何在 instance 的 instance variable 中存储实例的状态

As objects, classes can have methods added to them on a per-object basis—such methods being commonly known as class methods, and providing general utility functionality connected with the class.
作为对象，class 也可以针对他们自身添加方法，也就是 class method

Ruby constants are a special kind of identifier usually residing inside class (or module) definitions.
Ruby 中的常量是一类特殊的通常出现在 class / module 中的对象

Inheritance is a class-to-class relationship between a superclass and one or more subclasses, and all Ruby objects have a common ancestry in the Object and BasicObject classes.
继承时一个 class 层级的，一个 superclass 对 多个 subclasses 的关系， 所有 ruby 中的对象都有两个共同的祖先—— Object 和 BasicObject

The superclass/subclass structure can lend itself to modeling entities in a strictly hierarchical, taxonomical way, but the dynamic qualities of Ruby objects (including class objects!) can offer less strictly determined ways of thinking about objects and how their behaviors might unfold over the course of their lives.
superclass/subclass 的构架可以以严格的层级化，类别化的方式构建出实体，但是ruby对象（包括class）灵活的特性提供了不那么严格地方式来思考对象以及他们生命进程中的各种可能的行为。
