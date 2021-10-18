---
title:  "Rubyist-c5-The default object scope and visibility"
categories: [Ruby/Rails ℗]
tags: [Ruby & Rails, Notes of Rubyist]
---


*注：这一系列文章是《The Well-Grounded Rubyist》的学习笔记。*



---

This chapter covers

	•	The role of the current or default object, self `self` 作为当前默认对象的角色
	•	Scoping rules for local, global, and class variables 各类变量的作用域
	•	Constant lookup and visibility 常量的查询以及可见性
	•	Method-access rules 方法的可见层级

-

In describing and discussing computer programs, we often use spatial and, sometimes, human metaphors. We talk about being “in” a class definition or returning “from” a method call. We address objects in the second person, as in obj.respond_to?("x") (that is, “Hey obj, do you respond to 'x'?”). As a program runs, the question of which objects are being addressed, and where in the imaginary space of the program they stand, constantly shifts.

在对程序的描述与讨论中，我们通常使用空间性的，有时甚至是拟人化的表述方式。比如"在一个class的定义空间内" 或 "从"一个method返回。我们用第二人称指代对象，比如 `obj.respond_to?("x")` （好像在说 'hey, obj, 你能回应 x 这个信息吗？'）。程序在运行时，诸如"哪些对象正在被处理"，以及"他们在假象空间中的哪个位置"这类问题的答案，是随时变化的。

And the shifts aren’t just metaphorical. The meanings of identifiers shift too. A few elements mean the same thing everywhere. Integers, for example, mean what they mean wherever you see them. The same is true for keywords: you can’t use keywords like def and class as variable names, so when you see them, you can easily glean what they’re doing. But most elements depend on context for their meaning. Most words and tokens—most identifiers—can mean different things at different places and times.

这些'变换'并不只是比喻性的。这些识别符的实际意义的确是在变化的。有些元素在各处都代表相同的东西。比如 Integers 在哪里都说的是同一个东西。有些keywords也是如此比如 def 以及 变数的名称，因此当你见到他们时就能轻松地指定他们在做什么。但是大多数元素的含义都要基于当前语境来解读。大多数词汇可以在不同背景不同时间点代表不同含义。

This chapter is about orienting yourself in Ruby code: knowing how the identifiers you’re using are going to resolve, following the shifts in context, and making sense of the use and reuse of identifiers and terms. If you understand what can change from one context to another, and also what triggers a change in context (for example, entering a method-definition block), you can always get your bearings in a Ruby program. And it’s not just a matter of passive Ruby literacy: you also need to know about contexts and how they affect the meaning of what you’re doing when you’re writing Ruby.
这一章内容关于你在Ruby代码中的自我定位：弄清你正在使用的识别符将会怎样解析，基于背景的切换，以及弄清识别符以及术语的使用与复用。如果你知道了如何从一个背景切换到另一个背景，以及是什么触发了背景的切换（比如键入一个方法定义block），你就总能在ruby程序中清楚自己的位置。但这并不只是一个被动的ruby读写能力： 你同样要清楚背景是如何影响你所写的代码的含义。

This chapter focuses initially on two topics: self and scope. Self is the “current” or “default” object, a role typically assigned to many objects in sequence (though only one at a time) as a program runs. The self object in Ruby is like the first person or I of the program. As in a book with multiple first-person narrators, the I role can get passed around. There’s always one self, but what object it is will vary. The rules of scope govern the visibility of variables (and other elements, but largely variables). It’s important to know what scope you’re in, so that you can tell what the variables refer to and not confuse them with variables from different scopes that have the same name, nor with similarly named methods.
这章开头关注两个话题：self 和 scope 。 Self 是当前的，默认的对象，随着程序的运行，这个对象会被分配到不同的角色。 self 对象在ruby中就像 第一人称，或者程序中的'我'. 就如一本书中有很多个第一人称描述，'我' 这个角色也会不断切换。通常一个时间点下只会有一个 self， 但它指代什么却是不同的。 scope 的规则约束着 变数的能见度范围。清楚当前scope边界是很重要的，这样你才能说清楚变数指代的是什么，才不会在有同名变数（类似名称）出现时弄混他们。

Between them, self and scope are the master keys to orienting yourself in a Ruby program. If you know what scope you’re in and know what object is self, you’ll be able to tell what’s going on, and you’ll be able to analyze errors quickly.
self和scope是ruby程序中最重要的用于定位你自己的概念。 如果你知道当前所在的 scope 以及 self 指代的对象，你就清楚发生了什么，而且你会迅速的分析现的错误。

The third main topic of this chapter is method access. Ruby provides mechanisms for making distinctions among access levels of methods. Basically, this means rules limiting the calling of methods depending on what self is. Method access is therefore a meta-topic, grounded in the study of self and scope.
第三个话题是 方法的权限（可达性）。 Ruby为方法设置了不同的可达层级。基本上，这种限制的实现是基于当前背景下self的含义。 Method access 话题是一个 '元' 话题，需要在对self和scope的学习之上。

Finally, we’ll also discuss a topic that pulls together several of these threads: top-level methods, which are written outside of any class or module definition.
最后个话题会将这些话题串起来： top-level 方法， 那些不在任何 class或module 中定义的方法。

-


| Context       | Example        | Which object is self?  |
| ------------- |:-------------:| :-----:|
| top level of program     | any code outside of other blocks | main(built in top-level default object) |
| class definition    | class C self    |   the class object C |
|  module definition | module M self     |   the module object M |
| method definitions | 1. top level(outside any definition block): def method_name self  |  whatever object is self when the method is called; top-level methods are available as private method to all objects |
|                 | 2. instance-method definition in a class: class C def method_name self     |    an instance of C, responding to method_name |
|                 | 3. instance-method definition in a module: module M def method_name self     | individual object extended by M; instance of class that mixes in M |
|                 | 4. singleton method on a specific object: def obj.method_name      |   obj |

-

要识别当前 self 具体指代的是什么，要从 context 中分析

```ruby
2.5.0 :002 > puts "In top level context self is #{self}"
In top level context self is main
 => nil
```

在 top level 语境下，也就是没有预先定义任何 class 或者 module 时
self 指的是 main

而在其他情况下 self 的指代是容易推测出的

![](https://ws3.sinaimg.cn/large/006tNc79ly1fnu1x2zjhoj30uy0lwth5.jpg)

```ruby
2.5.0 :002 > class C
2.5.0 :003?>   puts "Class definition block: self is #{self}."
2.5.0 :004?>   def self.x
2.5.0 :005?>     puts "Class method C.x: self is #{self}"
2.5.0 :006?>   end
2.5.0 :007?>   def m
2.5.0 :008?>     puts "Instance method C#m: self is #{self}"
2.5.0 :009?>   end
2.5.0 :010?> end
Class definition block: self is C.
 => :m
2.5.0 :011 > C.x
Class method C.x: self is C
 => nil
2.5.0 :012 > C.new.m
Instance method C#m: self is #<C:0x00007fa94891a5c0>
 => nil
```

-

main is a special term that the default self object uses to refer to itself. You can’t refer to it as main; Ruby will interpret your use of main as a regular variable or method name. If you want to grab main for any reason, you need to assign it to a variable at the top level:

main 是一个特殊的术语，默认 self 对象用来指代自己。你不能使用 'main' 叫到他。 Ruby 会认为 'main' 是一个常规的变量或方法名称。如果你想拿到main，你可以在top level 中将它赋值给一个变数。

```ruby
2.5.0 :001 > x = self
 => main
2.5.0 :002 > x
 => main
```

```ruby
2.5.0 :001 > class C
2.5.0 :002?>   puts "In class C level, self is #{self}"
2.5.0 :003?>   module D
2.5.0 :004?>     puts "In C::D level, self is #{self}"
2.5.0 :005?>   end
2.5.0 :006?> end
In class C level, self is C
In C::D level, self is C::D
 => nil
```

在一个 class 内部的 instance method 内部写的 self 指代一个 由该 class 衍生出的 实例
#<C:0x00000101b381a0> 类似这种方式  

C 就是母体 class 名称

The weird-looking item in the output (#<C:0x00000101b381a0>) is Ruby’s way of saying “an instance of C.” (The hexadecimal number after the colon is a memory-location reference. When you run the code on your system, you’ll probably get a different number.)

-

如果是在一个 singleton method 内部，那么 self 指的就是该 对象自己

比如

```ruby
class Home
  def Home.some_method
      self  # 这里的 self 就是 Home 这个 class
  end

  def move
      self # 在没有执行 move 前， self 泛指执行 move 这个method 的 Home 的一个 instance
  end
end
```


self 是默认的 message receiver 所以在某些没有歧义的情况下，ruby 允许省去

但如果 有同名的 variable 就需要在 method() 后加上 () 告诉ruby 这是个 method 不是 variable

-

当 进行 赋值 操作 等号左边的 self 不能省去

self.friend = “caven”
friend = “caven”

如果没有 self. 那么 ruby 就不会知道 friend 指的是一个 local variable 还是 某个 instance 的 一个 attribute

实际上 local variable 在此语境下优先

-

**Resolving instance variables through self**

```ruby
class C
  def show_var
    @v = "I am @v inside show_var"
    puts @v
  end

  @v = "I am @v outside show_var but inside class C"

  p @v # class level

  C.new.show_var # instance level
end
```

输出

```ruby
2.5.0 :002 > load './self.rb'
"I am @v outside show_var but inside class C"
I am @v inside show_var
 => true
```
在上面的例子中 class 背景下的 @v 是属于 class C 的instance variable

一个 class 的 instance variable 能够存在是因为 任何class 都是 Class 的一个实例 (C = Class.new) 它同样是一个 object

任何 object 都可以拥有自己的 实例变量

-

Global scope is scope that covers the **entire program.**

ruby中有很多内建的 global variable

The Ruby interpreter starts up with a fairly large number of global variables already initialized. These variables store information that’s of potential use anywhere and everywhere in your program. For example, the global variable $0 contains the name of the startup file for the currently running program. The global $: (dollar sign followed by a colon) contains the directories that make up the path Ruby searches when you load an external file. $$ contains the process ID of the Ruby process. And there are more.

ruby解释器在初始状态下就存有很多global variables。这些全域变量可能在任何地方用到。比如 $0 包含当前运行的程序的启动文件。 $: 包含当你加载一个外部文件时ruby的搜索路径。 $$ 包含ruby进程ID。

```ruby
2.5.0 :002 > require 'pp'
 => true
2.5.0 :003 > pp $0
"irb"
 => "irb"
2.5.0 :004 > pp $$
38678
 => 38678
2.5.0 :005 > pp $:
["/Users/caven/.rvm/gems/ruby-2.5.0@global/gems/did_you_mean-1.2.0/lib",
 "/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/site_ruby/2.5.0",
 "/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/site_ruby/2.5.0/x86_64-darwin17",
 "/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/site_ruby",
 "/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/vendor_ruby/2.5.0",
 "/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/vendor_ruby/2.5.0/x86_64-darwin17",
 "/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/vendor_ruby",
 "/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/2.5.0",
 "/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/2.5.0/x86_64-darwin17"]
 => ["/Users/caven/.rvm/gems/ruby-2.5.0@global/gems/did_you_mean-1.2.0/lib", "/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/site_ruby/2.5.0", "/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/site_ruby/2.5.0/x86_64-darwin17", "/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/site_ruby", "/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/vendor_ruby/2.5.0", "/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/vendor_ruby/2.5.0/x86_64-darwin17", "/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/vendor_ruby", "/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/2.5.0", "/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/2.5.0/x86_64-darwin17"]
2.5.0 :006 >
```

—

在程式中大量使用 global variable 与 object-oriented philosophy 违背

因为大量与程式的交流都是以对象为核心的，我们送出 message 给对象，对象反馈给我们信息

并不是说使用 global variable 无法完成程序的最终目的，只是以这种方式构建程式就不是 面向对象的 思考和组织路径了，也许会以另一种完全不同的代码结构来完成相同的任务，对于初学者来说，大概率上说不是一个好选择

—

local variable 则在不同的语境下保持 该背景框架内的 local

在 某个 method 内是一个框架

在 top level 中是一个框架

在 class 或 module 下的 top level 中是一个

在 nested class 和 module 结构中 单独的 class 或 module 中也是单独的框架

不喜欢越界是 local variable 的特点

—


Every time you cross into a class-, module-, or method-definition block—every time you step over a class, module, or def keyword—you start a new local scope.

![](https://ws3.sinaimg.cn/large/006tNc79ly1fnu3tbixs3j30v80xqdoa.jpg)

-


—

constant 不算 global 因为拿到一个 constant 需要明确写清楚路径比如

A::B::C::PEOPLE

中间不能省掉任何一个结构，当然也无法穿透

—

即使是同名 constant 只要是镶嵌在不同的结构位置，那么他们就相互独立，不是同一个东西

到达特定 constant 的句法规定也不会让我们弄混他们

```ruby
module M
  class C
    X = 2
    class D
      module N
        X = 1
      end
    end
  end
end

puts M::C::D::N::X
puts M::C::X
```

输出

```ruby
2.5.0 :001 > load './constant.rb'
1
2
 => true
```

-

```ruby
module M
  class C
    class D
      module N
        X = 1
      end
    end
    puts D::N::X # => 1
  end
end
```
Here the identifier D::N::X is interpreted relative to where it occurs: inside the definition block of the class M::C. From M::C’s perspective, D is just one level away. There’s no need to do M::C::D::N::X, when just D::N::X points the way down the path to the right constant. Sure enough, we get what we want: a printout of the number 1.

如果呼叫 常量 的地方在结构内部，那么使用相对路径也可以。这一点很像对文件路径的处理，绝对路径总能找到，但当我们已经处在文件路径中的某个点时，相对路径更简洁也能达到同样的目的。


**Forcing an absolute constant path**

Sometimes you don’t want a relative path. Sometimes you really want to start the constant-lookup process at the top level—just as you sometimes need to use an absolute path for a file.

This may happen if you create a class or module with a name that’s similar to the name of a Ruby built-in class or module. For example, Ruby comes with a String class. But if you create a Violin class, you may also have Strings:

有时你不想使用相对路径，你需要从 top level 开始常量的查询。这种情况发生在当你的class/module名称和ruby内建的class/module很类似时。比如说你有一个 Violin(小提琴) 类，你可能就还有 String（琴弦）

```ruby
class Violin
  class String
    attr_accessor :pitch
    def initialize(pitch)
      @pitch = pitch
    end
  end

  def initialize
    @e = String.new("E")
    @a = String.new("A")
    .
    .
    .
end
```

The constant String in this context  resolves to Violin::String, as defined. Now let’s say that elsewhere in the overall Violin class definition, you need to refer to Ruby’s built-in String class. If you have a plain reference to String, it resolves to Violin::String. To make sure you’re referring to the built-in, original String class, you need to put the constant path separator :: (double colon) at the beginning of the class name:
这个例子中的 String 指的是 Violin::String 。现在假设在 Violin 中其他地方我们要用到ruby内建的String类应该怎么办？ 如果直接使用 String 那么由于之前已经override了它， 单写 String 会指代 Violin::String。想拿到内建的String 要在常量名称前加上连个 冒号 `::String`

```ruby
def history
  ::String.new(maker + ", " + date)
end
```

This way, you get a Ruby String object instead of a Violin::String object. Like the slash at the beginning of a pathname, the :: in front of a constant means “start the search for this at the top level.” (Yes, you could just piece the string together inside double quotes, using interpolation, and bypass String.new. But then we wouldn’t have such a vivid name-clash example!)

这样就拿到了ruby内建的String而不是你自己写的。就像 `/` 放在路径之前代表根目录一样， `::`放在常量前就代表从top level 中找。当然你可以在双引号中使用 解析器 解析内容，这里只是为了举例。

**Class variable syntax, and visibility**

之前一直用到 `@instance_variable` ，但有些情况下我们需要获得关于某个 class 下所有对象集合的信息，instance variable就不够用了，我们需要涵盖范围更广的变量。

Here’s an example: a little tracker for cars. Let’s start with a trial run and the output; then, we’ll look at how the program works. Let’s say we want to register the makes (manufacturer names) of cars, which we’ll do using the class method Car.add_make(make). Once a make has been registered, we can create cars of that make, using Car.new(make). We’ll register Honda and Ford, and create two Hondas and one Ford:

假设有一个关于汽车的类， 主要功能有 可以注册汽车的品牌`make` 使用 Car.add_make(make)。另外可以造出特定品牌的汽车实例 `Car.new(make)`


```ruby
Car.add_make("Honda")
Car.add_make("Ford")
h = Car.new("Honda")
f = Car.new("Ford")
h2 = Car.new("Honda")
```

The program tells us which cars are being created:

```ruby
Creating a new Honda!
Creating a new Ford!
Creating a new Honda!
```

接着我们想知道有多少辆车子与h2是一个品牌("Honda")的，我们使用 instance 方法 `make_mates`来实现。

```ruby
puts "Counting cars of same make as h2..."
puts "There are #{h2.make_mates}.
```

如上代码，会有两辆车是 'Honda'的。

接下来要问，总共有多少辆车。这类信息不会存储在单个独立object中，所以我们会送message 给Car 类 `Car.total_count`

puts "Counting total cars..."
puts "There are #{Car.total_count}."

The output is

```ruby
Counting total cars...
There are 3.
```

Finally, we try to create a car of a nonexistent make:
最后我们要阻止用户建立一个不存在的汽车品牌

```ruby
x = Car.new("Brand X")
```

The program doesn’t like it, and we get a fatal error:
这样会引起报错

```ruby
car.rb:21:in `initialize': No such make: Brand X. (RuntimeError)
```

下面是具体实现的代码：

```ruby
class Car
  @@makes = []
  @cars = {}
  @total_count = 0
  attr_reader :make
  def self.total_count
    @total_count
  end

  def self.add_make(make)
    unless @@makes.include?(make)
      @@makes << make
      @@cars[make] = 0
    end
  end

  def initialize(make)
    if @@makes.include?(make)
      puts "Creating a new #{make}!"
      @make = make
      @@cars[make] += 1
      @@total_count += 1
    else
      raise "No such make: #{make}."
    end
  end

  def make_mates
    @@cars[self.make]
  end
end
```

As noted earlier, class variables aren’t class-scoped variables. They’re class-hierarchy-scoped variables.
Here’s an example. What would you expect the following code to print?

如之前提到的 class variable 并不是 class域的变量，而是 class层级域中的变量

```ruby
class Parent
  @@value = 100
end

class Child < Parent
  @@value = 200
end

class Parent
  puts @@value
end
```

这个例子中 @@value 的输出是什么？

``ruby
=> 200
```

What gets printed is 200. The Child class is a subclass of Parent, and that means Parent and Child share the same class variables—not different class variables with the same names, but the same actual variables. When you assign to @@value in Child, you’re setting the one and only @@value variable that’s shared throughout the hierarchy—that is, by Parent and Child and any other descendant classes of either of them. The term class variable becomes a bit difficult to reconcile with the fact that two (and potentially a lot more) classes share exactly the same ones.

As promised, we’ll end this section with a consideration of the pros and cons of using class variables as a way to maintain state in a class.

我们拿到了200，一个继承链中的 class variable 是共享的。并不只是共享同名的变量，而是事实上的同一个变量。 上面的例子中我们先在 class Parent 中给@@value 赋值， 接着在 class Child 中 `@@value`实际指代的还是 Parent 中的变量。



**Evaluating the pros and cons of class variables**

class variable 的优缺点

在一个对象内部维持状态的最稳妥的方式是使用 instance variable。Class variable 虽然打破了 class 和 他的实例之间的隔离, 但类变量存在于继承系统中的特性也让他具有了准全域的特性： 一个class variable 并不是全域的，但可以确定的是他可以被许多objects可见，一旦他所在的class有了很多个subclasses 那么这个 class variable 将会对所有子类可见。

之前的例子中我们使用 class variable 来持有 Car 总体相关的信息。class variable 很流行因为在这种情况下这是最简单的处理数据的方式。

但这是有漏洞的。太多的对象能持有这个信息，假设我们有一个 Car 的 subclass 叫做 Hybrid, 这个类中也想有个 @@total_count 来存储这类车的总数
```ruby
class Hybrid < Car ; end

hy = Hybrid.new("Honda")
puts "There are #{Hybrid.total_count} hybrids in existence!"
```

由于 Hybrid 和 Car 在一个继承链中，那么在任何一个class中使用 @@total_count 都会影响继承链上的其他class。

为了区别，我们可能这样做：
```ruby
class Hybrid < Car
  @@total_hybrid_count = 0
  ...
end
```
这种使用区别变量名称的方式虽然可以达到目的，但这不是最简单的方式。

What’s the alternative?
有什么替代方案？

Maintaining per-class state with instance variables of class objects

The alternative is to go back to basics. We need a slot where we can put a value (the total count), and it should be a different slot for every class. In other words, we need to maintain state on a per-class basis; and because classes are objects, that means on a per-object basis (for a certain group of objects, namely, class objects). And per-object state, whether the object in question is a class or something else, suggests instance variables.

The following listing shows a rewrite of the Car class in listing 5.6. Two of the class variables are still there, but @@total_count has been transformed into an instance variable.

答案是使用 class 自己的 instance variable 来存储自己(class)的信息。

这个替代方案回到更基础的层面。当我们需要class的卡槽来放置一个值的时候，我们希望这个卡槽是区别于其他卡槽的。换言之，我们要基于单个class来存储信息；由于class也是object，那么class这个对象也可以有自己的instance variable 而这个 实例变量正是属于这个class独有的。下面的代码做出了相应的改变：

```ruby
class Car
  @@makes = []
  @@cars = {}
  attr_reader :make

  def self.total_count           
    @total_count ||= 0                         # key!!!
  end

  def self.total_count=(n)                     # key!!!
    @total_count = n     
  end

  def self.add_make(make)
    unless @@makes.include?(make)
      @@makes << make
      @@cars[make] = 0
    end
  end

  def initialize(make)
    if @@makes.include?(make)
      puts "Creating a new #{make}!"
      @make = make
      @@cars[make] += 1
      self.class.total_count += 1                # key!!!
    else
      raise "No such make: #{make}."
    end
  end   

  def make_mates
    @@cars[self.make]
  end
end
```

改良后，不再直接使用 @@total_count

但也不直接给 @total_count 赋值

而是使用 def self.total_count 让继承关系中的不同 subclass 都能根据自己self的 class 名称拿到各自的 @total_count。 同时也指明了 self.total_count 指的是 @total_count 而不是 @@total_count

写 self.total_count=(n)的原因是：
在 class Car 背景下, 这里的 @total_count 实现的机制相当于 Car 所属 实例的 attribute 的实现机制，而不是以单纯 variable 的身份出现， 所以不能直接赋值，要手工写好 赋值操作的 method

class Car 相当于 Class 的实例， 而 Class 并没有提供对应的 attr_* 机制，所以 以 attribute 身份出现的 @total_count 要单独写好  读 (def self.total_count)和 写(def self.total_count=(n))两个 methods

而之前的 @@class_variable 提供的是一种 共享的存储机制，他是以变量身份出现，所以可以直接进行赋值

那么如果再使用 Hybrid 作为subclass

```ruby
class Hybrid < Car; end
h3 = Hybrid.new("Honda")
f2 = Hybrid.new("Ford")
puts Hybrid.total_count
```

这里的 Hybrid.total_count就不会影响到 Car 中的，因为它是专属于 Hybrid 这个对象的 instance_variable


the biggest obstacle to understanding these examples is understanding the fact that classes are objects—and that every object, whether it’s a car, a person, or a class, gets to have its own stash of instance variables. Car and Hybrid can keep track of manufacturing numbers separately, thanks to the way instance variables are quarantined per object.

理解这些例子的最大障碍是，要理解 class 本身也是对象。每一个对象，不管是一个车，一个人，或者一个class都有自己的instance variable。而如果这个对象的class中没有 attr_ 这类快捷设置 实例变量读写的方法，那就要自己动手写。

-

**Private , Protected , Public **


比如我让某个 烘焙师 烤一个蛋糕

烘焙师接到指令后会做很多事，比如 倒出面粉flour, 加入鸡蛋，搅拌，制成了烤蛋糕的面糊，最后进行烘烤

但是 我们通常不会 发出一个指令 让烘焙师去打一个鸡蛋，这种行为感觉怪异

```ruby
# batter: 面糊（用面粉、鸡蛋、牛奶或水调制而成，作薄饼或裹在即将油炸的食品外）
# flour: 面粉； 撒上、裹上面粉

class Cake
  def initialize(batter)
    @batter = batter
    @baked = true
  end
end

class Egg
end

class Flour
end

class Baker
  def bake_cake
    @batter = []
    pour_flour
    add_egg
    stir_batter
    return Cake.new(@batter)
  end

  def pour_flour
    @batter.push(Flour.new)
  end

  def add_egg
    @batter.push(Egg.new)
  end

  def stir_batter
  end

  private :pour_flour, :add_egg, :stir_batter
end
```

```ruby
2.5.0 :001 > load './baker.rb'
 => true
2.5.0 :002 > baker = Baker.new
 => #<Baker:0x00007f83088d2f88>
2.5.0 :003 > baker.bake_cake
 => #<Cake:0x00007f83088caf68 @batter=[#<Flour:0x00007f83088cb008>, #<Egg:0x00007f83088cafe0>], @baked=true>
2.5.0 :004 > baker.pour_flour
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):4
NoMethodError (private method `pour_flour' called for #<Baker:0x00007f83088d2f88>)
2.5.0 :005 > baker.add_egg
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):5
NoMethodError (private method `add_egg' called for #<Baker:0x00007f83088d2f88>)
2.5.0 :006 >
```

Private means that the method can’t be called with an explicit receiver. You can’t say

baker.add_egg

Private 的意思是不能明确指明 receiver 的 method

那么这些 private methods 就不能直接使用在 instance 上，也不能在 instance method 内部使用 self 作为 receiver 。

如果把 Baker 中的 `bake_cake` 改成

```ruby
def bake_cake
  @batter = []
  self.pour_flour
  self.add_egg
  self.stir_batter
  return Cake.new(@batter)
end
```

结果是

```ruby
2.5.0 :001 > load './baker.rb'
 => true
2.5.0 :002 > baker = Baker.new
 => #<Baker:0x00007fd80402b550>
2.5.0 :003 > baker.bake_cake
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):3
        1: from /Users/caven/Notes & Articles/Note of Rubyist/code examples/baker.rb:20:in `bake_cake'
NoMethodError (private method `pour_flour' called for #<Baker:0x00007fd80402b550 @batter=[]>)
2.5.0 :004 >
```

那么这些 private methods 就不能直接使用在 instance 对象上，也不能在 instance method 内部使用 self 作为 receiver 。

一个 method 不能有明确的 receiver 那么在程序中他就不太可能被单独使用，所以 private method 通常只在 其他 method 内部出现，且前面没有 receiver


Okay; let’s go along with the rules. We won’t specify a receiver. We’ll just say
前面不能带 receiver 那么我们可不可以直接就使用 private 方法？像这样

```ruby
add_egg
```

But wait. Can we call add_egg in isolation? Where will the message go? How can a method be called if there’s no object handling the message?
等一下，我们能这样单独使用吗？ 这个message会送到哪里？ 一个方法怎么能没有一个对象来接手信息？

A little detective work will answer this question.

If you don’t use an explicit receiver for a method call, Ruby assumes that you want to send the message to the current object, self. Thinking logically, you can conclude that the message add_egg has an object to go to only if self is an object that responds to add_egg. In other words, you can only call the add_egg instance method of Baker when self is an instance of Baker.
如果你在呼叫一个方法时不写明receiver，那么ruby默认你会送给当前语境下的`self`。从逻辑上看，我们可以得出单独写的 add_egg 只在当前 self 是一个能够回应`add_egg`信息的情况下有效。换句话说，你只能在当当前背景的self指代的是一个Baker的instance时使用add_egg

And when is self an instance of Baker?

When any instance method of Baker is being executed. Inside the definition of bake_cake, for example, you can call add_egg, and Ruby will know what to do. Whenever Ruby hits that call to add_egg inside that method definition, it sends the message add_egg to self, and self is a Baker object.

那什么时候 self 指代的是 Baker 的一个实例。那就是当任何一个Baker的 instance method 的执行过程中。比如说 `bake_cake` 这个方法的定义block内部，在这里呼叫add_egg， ruby 知道怎么做。不管什么时候在这个定义方法的内部见到 add_egg(或其他Baker中的private method)，他都会把这个信息送给 self， 也就是一个 Baker 的实例。不过虽然背后的事实如此，但我们却不能明确地在代码上写 self.add_egg

**Private and singleton are different**

It’s important to note the difference between a private method and a singleton method. A singleton method is “private” in the loose, informal sense that it belongs to only one object, but it isn’t private in the technical sense. (You can make a singleton method private, but by default it isn’t.) A private, non-singleton instance method, on the other hand, may be shared by any number of objects but can only be called under the right circumstances. What determines whether you can call a private method isn’t the object you’re sending the message to, but which object is self at the time you send the message.

private 方法和 singleton 方法是不同的。一个 singleton 方法具有不严格的 private 特性，他只属于特定的 object，但从技术上并不 private。（你可以将一个 singleton method 设为 private method，但是默认情况下不是）一个 private 的非singleton实例方法，只要在正确的环境下可以说能被任何object使用。决定你是否能用一个private的因素不是你正在送出信息的那个objec，而是当前背景下的 self 指的是哪个对象。

It comes down to this: by tagging add_egg as private, you’re saying the Baker object gets to send this message to itself (the baker can tell himself or herself to add an egg to the batter), but no one else can send the message to the baker (you, as an outsider, can’t tell the baker to add an egg to the batter). Ruby enforces this privacy through the mechanism of forbidding an explicit receiver. And the only circumstances under which you can omit the receiver are precisely the circumstances in which it’s okay to call a private method.

It’s all elegantly engineered. There’s one small fly in the ointment, though.

更基础的说，将 `add_egg` 设为 private, 意味着 Bakder 下的实例必须将这个方法(message)送给自己（也就是只能在定义块内部self代表的含义），其他任何人不能送add_egg这个message给baker实例(也就是之前提到的外面的人不能告诉一个烘焙师，让他去加鸡蛋)。 Ruby 通过设置不能有明确receiver的方式来实现这个机制。而唯一一个没有receiver而实际message有实际送给对象自己的环境正好精确匹配了 private 能够使用的范围。

一切都被优雅地安排。但这里仍然有一个小问题。

Private setter (=) methods

The implementation of private access through the “no explicit receiver” rule runs into a hitch when it comes to methods that end with equal signs. As you’ll recall, when you call a setter method, you have to specify the receiver. You can’t do this

```ruby
dog_years = age * 7
```
because Ruby will think that dog_years is a local variable. You have to do this:

private 方法不能有明确 receiver 的规则会在写 setter 方法(以`=`结束的名称)的时候出现麻烦。当你使用 setter 方法的时候，你必须指明receiver 如果你直接写

```ruby
dog_years = age * 7
```
那么ruby会直接以为你在给本地变量赋值。你必须写:

```ruby
self.dog_years = age * 7
```

But the need for an explicit receiver makes it hard to declare the method dog_years= private, at least by the logic of the “no explicit receiver” requirement for calling private methods.

The way out of this conundrum is that Ruby doesn’t apply the rule to setter methods. If you declare dog_years= private, you can call it with a receiver—as long as the receiver is self. It can’t be another reference to self; it has to be the keyword self.

但这么做又打破了 private 方法的原则，至少是'不能有明确receiver'这一条规则。ruby 解决这个问题的方法是对 带等号的setter方法设置一个例外，你可以对self使用private的setter方法，但是前面必须是用 self 而不能是同义的其他识别符

比如先把 self 赋给一个变数，然后让变数来作为receiver就会引起报错

```ruby
def age=(years)
	@age = years
	dog = self
	dog.dog_years = years * 7
end
```
这么做会引起

```ruby
NoMethodError: private method 'dog_years=' called for
#<Dog:0x00000101b0d1a8 @age=10>
```
Ruby’s policy is that it’s okay to use an explicit receiver for private setter methods, but you have to thread the needle by making sure the receiver is exactly self.
The third method-access level, along with public and private, is protected.

ruby 允许 private setter 方法前加上 receiver ，但是也限制了前面的 receiver 只能用 self

**Protected methods**

A protected method is like a slightly kinder, gentler private method. The rule for protected methods is as follows: you can call a protected method on an object x, as long as the default object (self) is an instance of the same class as x or of an ancestor or descendant class of x’s class.

This rule sounds convoluted. But it’s generally used for a particular reason: you want one instance of a certain class to do something with another instance of its class. The following listing shows such a case.

protected method 类似柔和版的 private 方法。 他的规则如下： 你可以在对象x的身上使用protected 方法，只要对象x 是其所在class的实例或者是整个继承链上的其他classes（包括superclass和subclass）的实例。

这条规则提起来比较复杂，但他的存在有一个特殊的理由：你想要class中的一个实例和另一个实例之前发生互动。

```ruby
class C
  def initialize(n)
    @n = n
  end

  def n
    @n
  end

  def compare(c)
    if c.n > n
      puts "The other object's n is bigger."
    else
      puts "The other object's n is the same or smaller."
    end
  end

  protected :n
end

c1 = C.new(100)
c2 = C.new(200)
c1.compare(c2)
```
输出

```ruby
2.5.0 :001 > load './protected.rb'
The other object's n is bigger.
 => true
```

The goal in this listing is to compare one C instance with another C instance. The comparison depends on the result of a call to the method n. The object doing the comparing (c1, in the example) has to ask the other object (c2) to execute its n method. Therefore, n can’t be private.

整个代码是为了将 C 下的两个 instance 作比较。在做对比的method中，我们会对另一个object使用到`n`，那么n就不能是private的（private不能指明receiver也就没法表达要对另一个object使用n的意愿）。

That’s where the protected level comes in. With n protected rather than private, c1 can ask c2 to execute n, because c1 and c2 are both instances of the same class. But if you try to call the n method of a C object when self is anything other than an instance of C (or of one of C’s ancestors or descendants), the method fails.

A protected method is thus like a private method, but with an exemption for cases where the class of self (c1) and the class of the object having the method called on it (c2) are the same or related by inheritance.

这也正是protected方法发挥作用的时候。把n设成protected而不是private, c1对象就能让c2去执行`n`方法。但如果c1让另一个不是所在继承链上对象执行`n`就会失败。protected方法就是这样工作的，他让一个继承链上的对象可以与其他对象进行互动。

Inheritance and method access

Subclasses inherit the method-access rules of their superclasses. Given a class C with a set of access rules, and a class D that’s a subclass of C, instances of D exhibit the same access behavior as instances of C. But you can set up new rules inside the class definition of D, in which case the new rules take precedence for instances of D over the rules inherited from C.

现在有一个class C， 我们在C中设置了很多方法的 access 层级（比如protected和private各有几个）。现在另一个Class D 继承自C， 那么D获取了C中的方法后，这些方法的access level 是什么情况？
结果是D会遵循C中设置的各种access 规则权限。

-

**Writing and using top-level methods**

The most natural thing to do with Ruby is to design classes and modules and instantiate your classes. But sometimes you just want to write a quick script—a few commands stuffed in a file and executed. It’s sometimes more convenient to write method definitions at the top level of your script and then call them on top-level objects than to wrap everything in class definitions. When you do this, you’re coding in the context of the top-level default object, main, which is an instance of Object brought into being automatically for the sole reason that something has to be self, even at the top level.

But you’re not inside a class or module definition, so what exactly happens when you define a method?

在ruby中，设计 class 和 module 是最自然不过的事了。 但是有时候你想写一些快速脚本—— 执行少量写在文件中的指令。 这种情况直接在top-level 中写代码并在 top-level 中执行他们会比把所有东西都放入 class 或 module 中更加方便。 当你这么做时，你就在 top-level 默认对象(`main`)的背景下书写代码，他是 Object 的一个实例，在top-level中也是存在self对应的实体的。

```ruby
def talk
	puts "Hello"
end
```

如上我们就定义了一个 top-level 方法。

这个方法不在任何一个class或module中，那么他是什么？你在 top-level 中定义的方法 将会被视作 class Object 的 private instance method， 相当于你在这么做：

```ruby
class Object
	private
	def talk
		puts "Hello"
	end
end
```

Defining private instance methods of Object has some interesting implications.

First, these methods not only can but must be called in bareword style. Why? Because they’re private. You can only call them on self, and only without an explicit receiver (with the usual exemption of private setter methods, which must be called with self as the receiver).

Second, private instance methods of Object can be called from anywhere in your code, because Object lies in the method lookup path of every class (except Basic-Object, but that’s too special a case to worry about). So a top-level method is always available. No matter what self is, it will be able to recognize the message you send it if that message resolves to a private instance method of Object.
To illustrate, let’s extend the talk example. Here it is again, with some code that exercises it:

给Object 定义 private instance 方法会有一些有趣的引申。

首先，这些方法必须是不带前缀的 bareword，因为他们是 private 方法。 我们只能在背景为self的前提下使用它但又不能写明receiver（setter方法除外）。

第二，Object的private instance 方法能在你代码中的任何地方使用，因为Object几乎就在所有class的顶层了（刨去BasicObject这个特例）。其他class的继承链向上追溯都可以到到Object这里，所以Object中的private方法也就成了其他所有class的private方法，因此在哪里都能用。即使是在其他class的class层级，因为class本身也是Class的object，也属于在某个实例的内部。

```ruby
2.5.0 :002 > def talk
2.5.0 :003?>   puts "Hello"
2.5.0 :004?>   end
 => :talk
2.5.0 :005 > talk
Hello
 => nil
2.5.0 :006 > Object.new.talk
Hello
 => nil
```

The first call to talk succeeds ; the second fails with a fatal error , because it tries to call a private method with an explicit receiver.

这里书中给出的描述与实际代码测试不符，实际情况中，有receiver的情况也可以使用 talk方法

What’s nice about the way top-level methods work is that they provide a useful functionality (simple, script-friendly, procedural-style bareword commands), but they do so in complete conformity with the rules of Ruby: private methods have to default to self as the receiver, and methods defined in Object are visible to all objects. No extra language-level constructs are involved, just an elegant and powerful combination of the ones that already exist.

The rules concerning definition and use of top-level methods bring us all the way back to some of the bareword methods we’ve been using since as early as chapter 1. You’re now in a position to understand how those methods work.

top-level 优雅的地方在于他提供了一种简便的代码书写渠道，但这一切都还建立在完全遵守ruby的规则之上： private方法必须把self作为默认receiver， Object中定义的方法所有object都能用到。没有增加多余的语言结构方面的东西，只是优雅地将已经存在的东西结合起来。

内建的 top-level 方法

put , print 都是 predefined (built-in) top level methods
但他们不是写在 Object 中的 而是 Kernel 中， 而 Object 又混入了 Kernel

puts and print are built-in private instance methods of Kernel—not, like the ones you write, of Object, but of Kernel. The upshot is similar, though (because Object mixes in Kernel): you can call such methods at any time, and you must call them without a receiver. The Kernel module thus provides a substantial toolkit of imperative methods, like puts and print, that increases the power of Ruby as a scripting language.

`ruby -e 'p Kernel.private_instance_methods.sort` 或在 irb 中使用 Kernel.private_instance_methods 可以用来查看 所有的 top level private  instance methods

```ruby
2.5.0 :009 > Kernel.private_instance_methods
 => [:sprintf, :format, :Integer, :Float, :String, :Array, :Hash, :warn, :local_variables, :autoload, :raise, :fail, :global_variables, :__method__, :__callee__, :__dir__, :require, :require_relative, :autoload?, :eval, :iterator?, :block_given?, :catch, :throw, :loop, :binding, :trace_var, :untrace_var, :at_exit, :Rational, :Complex, :select, :`, :gem, :set_trace_func, :caller, :caller_locations, :test, :fork, :exit, :respond_to_missing?, :sleep, :gets, :proc, :lambda, :initialize_copy, :initialize_clone, :initialize_dup, :load, :syscall, :open, :printf, :print, :putc, :puts, :readline, :readlines, :p, :system, :spawn, :exec, :exit!, :abort, :gem_original_require, :rand, :srand, :trap]
```

require ,raise, require_relative, p, load, loop , sleep 这些methods 都经常用到

### Summary
This chapter covered

The rotating role of self (the current or default object)
具有自指性质的 `self`

Self as the receiver for method calls with no explicit receiver
sefl作为不能指明receiver的方法的接受者

Self as the owner of instance variables
self作为实例变量的拥有者

Implications of the “classes are objects too” rule
class也是对象的具体含义

Variable scope and visibility for local, global, and class variables
三类变量的可见层级

The rules for looking up and referencing constants
查询常量的规则方法

Ruby’s method-access levels (public, private, protected)
ruby的方法可达性层级

Writing and working with top-level method definitions
top-level中的方法
