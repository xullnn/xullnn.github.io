---
title:  "Rubyist-c13-Object individuation"
categories: [Ruby/Rails ℗]
tags: [Ruby & Rails, Notes of Rubyist]
---

*注：这一系列文章是《The Well-Grounded Rubyist》的学习笔记。*



---


## part 3. Ruby dynamics

*Ruby is dynamic, like human nature.*
                                  Matz, at RubyConf 2001



The phrase Ruby dynamics is almost redundant: everything about Ruby is dynamic. Variables don’t care what class of object you bind them to, which means you don’t have to (indeed, you can’t) declare their type in advance. Objects get capabilities from the classes that create them but can also branch away from their classes by having individual methods added to them. Classes and modules can be reopened and modified after their initial definitions. Nothing necessarily stays the same over the life cycle of the running program.

And those examples are just the beginning. In this last part of the book, we’ll look more deeply and widely than we yet have at the ways in which Ruby allows you to alter the execution circumstances of your program in your program.

Ruby dynamics 这个词组几乎是句废话：关于Ruby的一切都是动态灵活的。变数并不在乎绑给自己的是什么对象，你不需要在给变数赋值的时候声明对象的类型（ruby中你也无法这么做）。实例对象从他们的 class链条 中获得各种功能，同时也可以通过单独定义方法来相对独立于他们的class。classes 和 modules 可以被重新打开改写里面的方法。没有什么东西必须在程序运行时保持一直不变。

这些例子都只是开始，在书的最后这部分，我们将会通过介绍 ruby 如何允许我们在程式中修改程式本身所运行的环境来更加深入和广泛的了解ruby。

First, in chapter 13, we’ll look at object individuation, going into the details of how Ruby makes it possible for individual objects to live their own lives and develop their own characteristics and behaviors outside of the class-based characteristics they’re "born" with. We’ll thus circle back to one of the book’s earliest topics: adding methods to individual objects. But here, equipped with the knowledge from the intervening material, we’ll zero in much more closely on the underlying mechanisms of object individuation.

在第13章，我们将着眼于对象的独立性，将会看到 object 如何独立于他们"出生"的class 发展出自己独有的特征和行为。我们将会绕回本书中开头部分的一些话题：给单个object 定义方法。 通过引入的一些材料，我们会深入了解关于 object 的独立性。

Chapter 14 looks at callable objects: objects you can execute. You’ve seen methods already, of course—but you haven’t seen method objects, which we’ll discuss here, as well as anonymous functions in the form of Proc objects. Strings aren’t callable themselves, but you can evaluate a string at runtime as a piece of Ruby code, and chapter 14 will include that (sometimes questionable) technique. The chapter will also introduce you to Ruby threads, which allow you to run segments of code in parallel.

在第14章，我们会了解 可呼叫的对象（callable objects）: 你可以执行的对象。你已经见过 方法 ，但你还没有见过 方法对象。这会涉及到以 Proc objects 形式出现的 匿名函数。 String 本身并不是 callable的， 但你可以在程序运行时把string视作一个代码片段，这也是这一章的内容，我们还会介绍 ruby 线程(threads) ， 它让我们可以并行执行代码片段。

Finally, chapter 15 looks at the facilities Ruby provides for runtime reflection: examining and manipulating the state of your program and your objects while the program is running and the objects exist. Ruby lets you ask your objects for information about themselves, such as what methods they can execute at runtime; and a number of hooks are available, in the form of methods you can write using special reserved names, to intercept runtime events like class inheritance and module inclusion. Here we’re entering the territory of dynamic reflection and decision making that gives Ruby its characteristic and striking quality of flexibility and power.

最后 第15章会着眼于 ruby 提供的运行中的反馈机制：检查和操控程序和对象的状态。 ruby让我们可以查询关于对象本身的信息，比如他们在运行时可以执行的方法；还有许多接口，比如使用一些保留词写的方法，可以用来在运行中截取关于 继承和module包含关系的信息。至此我们进入了ruby动态灵活性的核心区域，这些特质使得ruby成为一种具有强大灵活性和力量的语言。

Chapter 13 also includes information—and advice—about the process of making changes to the Ruby core language in your own programs. In fact, this entire part of the book includes many best-practices pointers (and pointers away from some not-so-best practices). That’s not surprising, given the kind of ground these chapters cover. This is where your programs can distinguish themselves, for better or worse, as to the nature and quality of their use of Ruby’s liberal dynamic-programming toolset. It definitely pays to think through not only the how and why but also the whether of some of these powerful techniques in certain circumstances. Used judiciously and advisedly, Ruby’s dynamic capabilities can take you to new and fascinating heights.

第13章包含关于修改ruby core的信息与建议。实际上，这部分内容包含了许多最佳实践。这些内容，将会把你和普通的开发者区分开来，基于你是如何利用这些ruby工具的。 另外一点绝对值得花注意力的是不仅要思考在什么样的情境下 如何以及为什么要使用这些技术，还要谨慎地思考该不该使用。 Ruby 的动态灵活性将会把你带到另一个高度。

-

Chapter 13. Object individuation

This chapter covers

* Singleton methods and classes  
singleton 方法和 singleton 类

* Class methods
类方法

* The extend method
`extend` 方法

* Overriding Ruby core behavior
重写core中的内容

* The BasicObject class
BasicObject 类

-

Where the singleton methods are: The singleton class
一个object的singleton methods在哪里： 在这个object的singleton class中

ruby中的大多数事件都涉及  class 和 module ，通常我们会在 class 中定义 instance method 然后 实例化之后用到这个 method

```ruby
2.5.0 :001 > class C
2.5.0 :002?>   def talk
2.5.0 :003?>     puts "hi"
2.5.0 :004?>   end
2.5.0 :005?> end
 => :talk
2.5.0 :006 > c = C.new
 => #<C:0x00007fd50403f440>
2.5.0 :007 > c.talk
hi
 => nil
2.5.0 :008 >
```

之前我们也见过给单个对象定义方法的例子

```ruby
2.5.0 :009 > object = Object.new
 => #<Object:0x00007fd504930680>
2.5.0 :010 > def object.talk
2.5.0 :011?>   puts "Hello"
2.5.0 :012?> end
 => :talk
2.5.0 :013 > object.talk
Hello
 => nil
2.5.0 :014 >
```

其实最常见的 singleton method 是用在 class method 类方法 的定义上的

```ruby
2.5.0 :023 > class Car
2.5.0 :024?>   def self.making
2.5.0 :025?>     %w{Honda Ford Toyoto Chevrolet Volvo}
2.5.0 :026?>   end
2.5.0 :027?> end
 => :making
2.5.0 :028 > Car.making
 => ["Honda", "Ford", "Toyoto", "Chevrolet", "Volvo"]
2.5.0 :029 >
```

But any object can have singleton methods added to it. (Almost any object; see sidebar.) The ability to define behavior on a per-object basis is one of the hallmarks of Ruby’s design.

不过几乎所有的对象都可以有自己的 singleton 方法，这是ruby的标志之一

-

Some objects are more individualizable than others

有些对象的独立性比其他更强

-

Almost every object in Ruby can have methods added to it. The exceptions are instances of certain Numeric subclasses, including integer classes and floats, and symbols. If you try this

几乎所有的对象都可以定义新的方法，除了 class Numeric 的 subclasses 的实例对象，包括 Integer 和 Floats, 还有 Symbol

如果你尝试给一个 数字类型class的实例定义 singleton 方法，那么你会得到 syntax error

```ruby
2.5.0 :031 > def 10.some_method; end
Traceback (most recent call last):
        1: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
SyntaxError ((irb):31: syntax error, unexpected tINTEGER
def 10.some_method; end
    ^~
(irb):31: syntax error, unexpected keyword_end, expecting end-of-input
def 10.some_method; end
                    ^~~)
2.5.0 :032 >
```

或者另一种定义 singleton methods 的句法

```ruby
2.5.0 :033 > class << 10; end
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):33
TypeError (can't define singleton)
2.5.0 :034 >
```

一般的 instance methods 都存在于object所属的 class 中， 但是特定实例的 singleton method存在于哪里？

-

**Dual determination through singleton classes**

singleton class赋予的双重身份

-

Ruby, true to character, has a simple answer to this tricky question: an object’s singleton methods live in the object’s singleton class. Every object ultimately has two classes:

The class of which it’s an instance
Its singleton class

这个奇怪的问题是有明确答案的，这些 singleton methods 就存在于该对象的 singleton class 中，对于一个对象来说，他最终会属于两个 classes

- 一个是他被实例化的那个class
- 另一个就是他的 singleton class

You can think of an object’s singleton class as an exclusive stash of methods, tailor-made for that object and not shared with other objects—not even with other instances of the object’s class.

你可以把一个 object 的 singleton class 视作一个高级的藏匿专有 methods 的地方，这些方法都是定制的，甚至无法被同一个父 class 中的其他 instances 使用。

-

Examining and modifying a singleton class directly

-

Singleton classes are anonymous: although they’re class objects (instances of the class Class), they spring up automatically without being given a name. Nonetheless, you can open the class-definition body of a singleton class and add instance methods, class methods, and constants to it, as you would with a regular class.

虽然 singleton class 也是 class 对象（Class 这个 class 的实例），但它是匿名的，它只会在需要时自动冒出来但不会有一个明确的名字。虽然如此，我们还是可以剖开一个 singleton class 然后往里面加 instance methods, class methods 以及 常量，就如我们对待其他 class 那样。

做到上面说的，我们会用到 class 这个关键词

class << object
    # methods here
end

如上所示，我们会用到 上面的语法

The << object notation means the anonymous, singleton class of object. When you’re inside the singleton class–definition body, you can define methods—and these methods will be singleton methods of the object whose singleton class you’re in.

<< object 代表着匿名的，属于 object 的 singleton class
在body之中就可以进行方法的定义了

```ruby
2.5.0 :036 > str = "I am a string."
 => "I am a string."
2.5.0 :037 > class << str
2.5.0 :038?>   def twice
2.5.0 :039?>     self + " " + self
2.5.0 :040?>   end
2.5.0 :041?> end
 => :twice
2.5.0 :042 > puts str.twice
I am a string. I am a string.
 => nil
2.5.0 :043 >
```

这和写 def str.twice 效果是一样的，不过不同的是，我们悄悄打开了 str 的 singleton class 在其内部完成的这个过程。

那么这两种处理方式有什么不同？

-

**The difference between def obj.method and class << obj; def method**

-

The answer is that there’s one difference: constants are resolved differently.

答案是有一个不同：常量的解析不同

If you have a top-level constant N, you can also define an N inside an object’s singleton class:

如果在 top level 中已经定义了一个常量 N , 如果在 singleton class 中定义一个同名的 常量

```ruby
2.5.0 :046 > object = Object.new
 => #<Object:0x00007fd50405cc98>
2.5.0 :047 > class << object
2.5.0 :048?>   N = 2
2.5.0 :049?> end
 => 2
2.5.0 :050 > def object.outside_method
2.5.0 :051?>   puts N
2.5.0 :052?> end
 => :ouside_method
2.5.0 :053 >
2.5.0 :054 > class << object
2.5.0 :055?>   def inside_method
2.5.0 :056?>     puts N
2.5.0 :057?>   end
2.5.0 :058?> end
 => :inside_method

2.5.0 :061 > object.outside_method
1
 => nil
2.5.0 :062 > object.inside_method
2
 => nil
2.5.0 :063 >
```

一个直接在 obj 对象身上定义的 singleton method 拿到的常量会优先是 singleton class外的，而如果是打开 singleton class 后 再在内部定义的 singleton method 就会优先拿到 singleton class 内部的常量。

*我的理解是：（在top-level 中使用 `def obj.method` 时，当下的背景是 top level, 那么拿到的 constant 对应到了这个背景下的常量。

在 一个 object 的 singleton class 内部，当下背景是这个对象的singleton class, 连背景也是专属的，所以对应到的constant就是这个特定scope内的。）*

It’s relatively unusual for this difference in the visibility of constants to affect your code; in most circumstances, you can regard the two notations for singleton-method definition as interchangeable. But it’s worth knowing about the difference, because it may matter in some situations and it may also explain unexpected results.

这种区别在实际中很少遇到，多数情况下都可以忽略，但是知道有区别的存在可能会在某些未预料到的情况下有用。

The class << object notation has a bit of a reputation as cryptic or confusing. It needn’t be either. Think of it this way: it’s the class keyword, and it’s willing to accept either a constant or a << object expression. What’s new here is the concept of the singleton class. When you’re comfortable with the idea that objects have singleton classes, it makes sense for you to be able to open those classes with the class keyword. The << object notation is the way the concept "singleton class of object" is expressed when class requires it.

class << object  看起来有点神秘而令人疑惑。但其实不是，可以这样想： class 这个 keyword , 既可以接受一个 constant （就如普通的class那样），也可以接受 << object 来代表一个 object 的 singleton class. 这里进入视野的新内容只有 singleton class 这个概念。

-

Defining class methods with class <<

使用 class << 语法定义 class methods

-

在下面的例子中，我们用三种不同的方法写同一个 class Ticket 的 同一个 class method

1 这个方法先以常规的方式 class Ticket 进入 Ticket 内部，然后再嵌套了一个 singleton 语法 class << self 打开 Ticket 的 singleton class 内部 ， 最后定义了一个 instance method , 因为这个 instance method 是只属于 Ticket 对象的，所以实际上他也是一个 class method

2 这个方法就是常规的定义 class method 的简单语法 def Ticket.method

3 这里直接使用了 singleton 语法 class << Ticket 进入 Ticket 对象singleton class 内部，然后定义一个 instance method, 实际这里的用法和第一个用法的内部是一样的，只不过第一个方法是嵌套在 class Ticket 内部，所以使用了 self 来代表 Ticket 对象本身，而实际在第一种方法中内部写 class << Ticket 也是可以的

```ruby
class Ticket

  class << self
    def most_expensive(*tickets)
      tickets.max_by(&:price)
    end
  end

end

# ......

def Ticket.most_expensive(*tickets)
  # method body;
end

# ......

class << Ticket

  def most_expensive(*tickets)
    # method body
  end

end
```

The fact that class << self shows up frequently in connection with the creation of class methods sometimes leads to the false impression that the class << object notation can only be used to create class methods, or that the only expression you can legally put on the right is self. In fact, class << self inside a class-definition block is just one particular use case for class << object. The technique is general: it puts you in a definition block for the singleton class of object, whatever object may be.

其实上面演示的定义class method 的方法 事实上仍然在使用  class << object 语法，因为 class 也是对象，object 只是一个代称，只要 object 是一个对象就可以。

只要你清楚 class << 右边的东西是什么，那么就会清楚自己在做什么

```ruby
2.5.0 :064 > class C; end
 => nil
2.5.0 :065 > objcet = C.new
 => #<C:0x00007fd50406d3e0>
2.5.0 :066 > class << object
2.5.0 :067?>   def greet
2.5.0 :068?>     puts "Hi."
2.5.0 :069?>     end
2.5.0 :070?>   end
 => :greet
2.5.0 :071 > object.greet
Hi.
 => nil
2.5.0 :072 > object = C
 => C
2.5.0 :073 > class << object
2.5.0 :074?>   def whoop
2.5.0 :075?>     puts "Oh!"
2.5.0 :076?>     end
2.5.0 :077?>   end
 => :whoop
2.5.0 :078 > C.whoop
Oh!
 => nil
2.5.0 :079 >
```

前面我们了解过关于一个对象的 method 上溯链条，那么现在 singleton class 的存在会对这个上溯过程有什么影响？

-

Singleton classes on the method-lookup path

-

之前我们呈现的 method 上溯搜索示意图中没有包括 singleton class 的部分， 现在让我们将他包含进去

![](https://ws3.sinaimg.cn/large/006tKfTcgy1fodmbsfseuj30c90cpgne.jpg)

The box containing class << object represents the singleton class of object. In its search for the method x, object looks first for any modules prepended to its singleton class; then it looks in the singleton class itself. It then looks in any modules that the singleton class has included. (In the diagram, there’s one: the module N.) Next, the search proceeds up to the object’s original class (class D), and so forth.
Note in particular that it’s possible for a singleton class to prepend or include a module. After all, it’s a class.

class << object 那个方框代表 object 对象的 singleton class. 在他内部，优先搜索 被 prepend 的 X 内部的 方法，然后是自己内部的方法， 最后是被include的 Y 内部的方法。接着他搜索自己出生的 class D 内部的方法，如此继续。

注意 singleton class 仍然可以 prepend 或 include 其他 module , 因为它也是一个 class

顺序原则是： self's prepend -- self's singleton -- self's include -- self's class' prepend -- self's class' singleton -- self's class' include ...

-

**Including a module in a singleton class**

将module 引入singleton class

-

```ruby
2.5.0 :081 > class Person
2.5.0 :082?>   attr_accessor :name
2.5.0 :083?>   end
 => nil
2.5.0 :084 > david = Person.new; david.name = "David"
 => "David"
2.5.0 :085 > matz = Person.new; matz.name = "Matz"
 => "Matz"
2.5.0 :086 > ruby = Person.new; ruby.name = "Ruby"
 => "Ruby"
2.5.0 :087 > def david.name
2.5.0 :088?>   "[not available!]"
2.5.0 :089?>   end
 => :name
2.5.0 :090 > puts ruby.name, matz.name, david.name
Ruby
Matz
[not available!]
 => nil
2.5.0 :091 >
```

上面的例子中， Person 的实例有 name 属性，我们可以通过 instance.name 拿到每个人的名字，但如果有些人不想透露名字，那么我们就可以为它定义一个限制性的 singleton 版本的 :name

但如果现在有很多人，他们当中有一部分人都不想透露名字，那么挨个为这些人写限制性的 singleton 版的 :name 则会变得很麻烦，这时就可以写一个 module 来让需要的人引入到自己的 singleton class 中

```ruby
module Secretive
  def name
    "[not available!]"
  end
end
```

然后让需要匿名的个体的singleton class include 这个 module

```ruby
2.5.0 :093 > module Secretive
2.5.0 :094?>   def name
2.5.0 :095?>     "[not available!]"
2.5.0 :096?>   end
2.5.0 :097?> end
 => :name
2.5.0 :098 > class << ruby
2.5.0 :099?>   include Secretive
2.5.0 :100?> end
 => #<Class:#<Person:0x00007fd504047a28>>
2.5.0 :101 > puts ruby.name, matz.name, david.name
[not available!]
Matz
[not available!]
 => nil
2.5.0 :102 >
```

What happened in Ruby’s case? We sent the message "name" to the object ruby. The object set out to find the method. First it looked in its own singleton class, where it didn’t find a name method. Then it looked in the modules mixed into its singleton class. The singleton class of ruby mixed in the Secretive module, and, sure enough, that module contains an instance method called name. At that point, the method gets executed.

根据之前我们看到的一个 对象 的方法上溯顺序，首先他会查找自己 singleton class 中有没有一个叫 name 的方法，没有找到，然后到 include 的 module 中找到了。

-

**Singleton module inclusion vs. original-class module inclusion**

-

始终要记住的是，ruby是以怎样的原则来搜索方法名称

首先是 singleton class 内部的 prepend

接着是 singleton class 内部

接着是 singleton class 内部的 include

接着是 自己出生的那个 class 如此继续

```ruby
2.5.0 :104 > class C
2.5.0 :105?>   def talk   # talk in ancestral class
2.5.0 :106?>     puts "Hi from original class!"
2.5.0 :107?>   end
2.5.0 :108?> end
 => :talk
2.5.0 :109 > module M
2.5.0 :110?>   def talk
2.5.0 :111?>     puts "Hello from module!"
2.5.0 :112?>   end
2.5.0 :113?> end
 => :talk
2.5.0 :114 >
2.5.0 :115 > c = C.new
 => #<C:0x00007fd5049486b8>
2.5.0 :116 > c.talk
Hi from original class!
 => nil
2.5.0 :117 > class << c
2.5.0 :118?>   include M  # talk in singleton class
2.5.0 :119?> end
 => #<Class:#<C:0x00007fd5049486b8>>
2.5.0 :120 >
2.5.0 :121 > c.talk
Hello from module!
 => nil
2.5.0 :122 >
```

我们可以使用 ancestors 方法来查看 一个object 的方法追溯链

```ruby
2.5.0 :124 > class << c
2.5.0 :125?>   include M
2.5.0 :126?>   p self.ancestors
2.5.0 :127?>   end
[#<Class:#<C:0x00007fd5049486b8>>, M, C, Object, Kernel, BasicObject]
 => [#<Class:#<C:0x00007fd5049486b8>>, M, C, Object, Kernel, BasicObject]
2.5.0 :128 >
```

第一位的是 singleton class 接着是 singleton class 内部引入的 module 最后才是 class C

那么同时在 singleton class 和出生 class 中都引入了同一个 module 的情况会是怎么样

module 会出现在 lookup path 中的哪个位置？

```ruby
2.5.0 :002 > module M
2.5.0 :003?>   def meth_in
2.5.0 :004?>   end
2.5.0 :005?> end
 => :meth_in
2.5.0 :006 > class C;end
 => nil
2.5.0 :007 > c = C.new
 => #<C:0x00007fd6e60cc0c8>
2.5.0 :008 > class << c
2.5.0 :009?>   include M
2.5.0 :010?>   p ancestors
2.5.0 :011?> end
[#<Class:#<C:0x00007fd6e60cc0c8>>, M, C, Object, Kernel, BasicObject]
 => [#<Class:#<C:0x00007fd6e60cc0c8>>, M, C, Object, Kernel, BasicObject]
2.5.0 :012 >
2.5.0 :013 > class C
2.5.0 :014?>   include M
2.5.0 :015?> end
 => C
2.5.0 :016 > c.singleton_class.ancestors
 => [#<Class:#<C:0x00007fd6e60cc0c8>>, M, C, M, Object, Kernel, BasicObject]
2.5.0 :017 >
```


可以看到在上溯链条上， module M 出现了两次，这是ruby按照自己的逻辑处理后的结果。第一次是在 c 对象的singleton class内部由include带来的，第二次则是在 c 对象的 class C 中的 include 带来的。

The module M appears twice! Two different classes—the singleton class of c and the class C—have mixed it in. Each mix-in is a separate transaction. It’s the private business of each class; the classes don’t consult with each other. (You could even mix M into Object, and you’d get it three times in the ancestors list.)

每一次 include 都是一次独立的操作，只与引入它的 class（包括singleton class） 相关。如果你再在 Object 中引入一次，甚至可以看到 M 出现3次

```ruby
2.5.0 :001 > module M; end
 => nil
2.5.0 :002 > class C
2.5.0 :003?>   include M
2.5.0 :004?> end
 => C
2.5.0 :005 > c = C.new
 => #<C:0x00007f88368350e8>
2.5.0 :006 > class << c
2.5.0 :007?>   include M
2.5.0 :008?> end
 => #<Class:#<C:0x00007f88368350e8>>
2.5.0 :009 > class Object
2.5.0 :010?>   include M
2.5.0 :011?> end
 => Object
2.5.0 :012 > c.singleton_class.ancestors
 => [#<Class:#<C:0x00007f88368350e8>>, C, M, Object, M, Kernel, BasicObject]
2.5.0 :013 >
```

The main lesson is that per-object behavior in Ruby is based on the same principles as regular, class-derived object behavior: the definition of instance methods in classes and modules, the mixing in of modules to classes, and the following of a method-lookup path consisting of classes and modules. If you master these concepts and revert to them whenever something seems fuzzy, your understanding will scale upward successfully.

这里主要的点是，Ruby 是有原则的，以class作为源头的行为模式：modules 和 classes 中定义的实例方法，引入 classes 和 modules 中的方法，这些都是方法上溯链条中的组成部分，如果你掌握了这个规则，并且经常回顾，下次遇到问题时会更容易理解。

-

The `singleton_class` method

-

.singleton_class 方法可以直接拿到一个对象的 singleton class 对象， 省去了 class << object 的繁琐

-

-

**Class methods in (even more) depth**

-

通常来说，一个对象的 singleton method 是只能被自己使用的，但是对于 Class 来说有个特例，那就是一个 class 的 singleton method 可以被 继承自他的其他 class 使用

因为一个 class 对象的 singleton class 实际也是一个 class method， 那么就遵循继承规则。

```ruby
2.5.0 :001 > class C; end
 => nil
2.5.0 :002 > def C.a_class_method
2.5.0 :003?>   puts "Singleton method defined on C."
2.5.0 :004?>   end
 => :a_class_method
2.5.0 :005 > C.a_class_method
Singleton method defined on C.
 => nil
2.5.0 :006 > class D < C; end
 => nil
2.5.0 :007 > D.a_class_method
Singleton method defined on C.
 => nil
2.5.0 :008 >
```

这个例子中，C 的singleton class 会被作为 D 的singleton class 的superclass

```ruby
2.5.0 :008 > D.ancestors
 => [D, C, Object, Kernel, BasicObject]
2.5.0 :009 > D.singleton_class.ancestors
 => [#<Class:D>, #<Class:C>, #<Class:Object>, #<Class:BasicObject>, Class, Module, Object, Kernel, BasicObject]
2.5.0 :010 >
```
When you send a message to the class object D, the usual lookup path is followed—except that after D’s singleton class, the superclass of D’s singleton class is searched. That’s the singleton class of D’s superclass. And there’s the method.

![](https://ws1.sinaimg.cn/large/006tKfTcgy1fodoglr5e1j30aw07kaae.jpg)

Singleton classes of class objects are sometimes called meta-classes. You’ll sometimes hear the term meta-class applied to singleton classes in general, although there’s nothing particularly meta about them and singleton class is a more descriptive general term.

class 对象的 singleton class 有时被称作 meta-classes 元类。 有时你会听到人们会这么称呼，但class的对象的singelton class并没有什么 meta 特性，直接使用 singleton class 更容易理解。

You can treat this explanation as a bonus topic. It’s unlikely that an urgent need to understand it will arise often. Still, it’s a great example of how Ruby’s design is based on a relatively small number of rules (such as every object having a singleton class, and the way methods are looked up). Classes are special-cased objects; after all, they’re object factories as well as objects in their own right. But there’s little in Ruby that doesn’t arise naturally from the basic principles of the language’s design—even the special cases.

你可以将这个解释作为额外话题。并不需要急着去理解他，但这是一个很好的例子来说明 Ruby 的设计是基于相对很少的规则（每个对象都有singleton class，method的搜索路径规则）构建起来的。 class 只是特殊一点的对象，他们能批量生产对象。但是ruby中几乎没有会打破基础原则的事——包括哪些所谓的特殊案例。

-

Singleton classes and the singleton pattern
singelton 模式

The word "singleton" has a second, different meaning in Ruby (and elsewhere): it refers to the singleton pattern, which describes a class that only has one instance. The Ruby standard library includes an implementation of the singleton pattern (available via the command require 'singleton'). Keep in mind that singleton classes aren’t directly related to the singleton pattern; the word "singleton" is just a bit overloaded. It’s generally clear from the context which meaning is intended.

singelton(单个对象的) 这个词在Ruby中有另一个含义：singleton 设计模式，用来描述那些只有一个 instance 的类。 ruby std lib 中就能应用这种设计模式（require 'singleton'）。 要记住 singleton class 并不直接和 singelton pattern 联系； `singleton` 这个词承载了太多的含义。 当整个词出现的时候，一定要结合当前语境来判断他的含义。

-

**Modifying Ruby's core classes and modules**

修改ruby的核心 classes 和 modules

-

The openness of Ruby’s classes and modules—the fact that you, the programmer, can get under the hood of the language and change what it does—is one of the most important features of Ruby and also one of the hardest to come to terms with. It’s like being able to eat the dishes along with the food at a restaurant. How do you know where one ends and the other begins? How do you know when to stop? Can you eat the tablecloth too?

Learning how to handle Ruby’s openness is a bit about programming technique and a lot about best practices. It’s not difficult to make modifications to the core language; the hard part is knowing when you should, when you shouldn’t, and how to go about it safely.

In this section, we’ll look at the landscape of core changes: the how, the what, and the why (and the why not). We’ll examine the considerable pitfalls, the possible advantages, and ways to think about objects and their behaviors that allow you to have the best of both worlds: flexibility and safety.

We’ll start with a couple of cautionary tales.

Ruby classes 和 module 的开放性是它最重要的特征之一，也是最难理解的一部分。这就好比我们在一个餐厅里，我们有能力把装食物的盘子一起吃下去，那么我们怎么决定吃到什么程度，什么时候开始吃什么时候停下来，最后可以把餐桌布一起吃了吗？

学习如何处理 ruby 的开发性有一点技术难度，而且会涉及到很多最佳实践。修改ruby core 并不难，最难的是清楚什么时候应该修改，什么时候不应该，还有怎么做才是安全的。

在这节我们将会着眼于修改core的全景：如何改，改什么，为什么要改（以及为什么不改）。 我们将会看到很多陷阱，可能的好处，你对 object 以及他们行为的理解将会让你步入两个美好的世界：灵活 ， 安全。

我们首先会看一些警醒的例子。

-

The risks of changing core functionality

-


一个主要的风险是当你改变core中的某些内容，随之改变的会是程序中所有与之相关的部分。

一个可能会修改的例子是 regular expression

-

Changing Regexp#match ( and why not to )

修改正则表达式中的 match 方法

```ruby
2.5.0 :011 > re = /(xy)(z)/
 => /(xy)(z)/
2.5.0 :012 > re.match("xyz")[1]
 => "xy"
2.5.0 :013 > re.match("abc")[1]
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):13
NoMethodError (undefined method `[]' for nil:NilClass)
2.5.0 :014 >
```

比如上面的例子中，我们想通过索引 [1] 去拿 MatchData 对象中的结果，匹配成功时还好，但是如果匹配不成功返回的会是 nil ， 然后对 nil 使用索引就会引起报错。若我们想将匹配结果作为 if 判断的依据，那么他就不太好用了。

我们需要修改一下 match 的行为

```ruby
2.5.0 :014 > class Regexp
2.5.0 :015?>   alias __old_match__ match
2.5.0 :016?>   def match(string)
2.5.0 :017?>     __old_match__(string) || []
2.5.0 :018?>   end
2.5.0 :019?> end
 => :match
2.5.0 :020 > re.match("abc")[1]
 => nil
2.5.0 :021 >
```

`alias` 和 `alias_method` 都是ruby中用来定义同名方法的方法，但是前者没能在 core 中找到，core 中只有关于 `alias_method` 的介绍。从下面这篇文章可知，二者的主要区别在于 在有继承关系的例子中，alias 方法中对于 self 的解析是绝对的，而 alias_method 则是根据语境在改变的

https://blog.bigbinary.com/2012/01/08/alias-vs-alias-method.html

http://ruby-doc.org/core-2.5.0/Module.html#method-i-alias_method

改变后的 match 返回的要么是 MatchData 对象，要么是一个 空的 array
这样如果没有匹配返回的是 [ ] 而对空 array 使用索引如果没有就返回 nil 而不会报错，之后再用做 if 的判断依据，就不会报错。

An alias is a synonym for a method name. Calling a method by an alias doesn’t involve any change of behavior or any alteration of the method-lookup process. The choice of alias name in the previous example is based on a fairly conventional formula: the addition of the word old plus the leading and trailing underscores. (A case could be made that the formula is too conventional and that you should create names that are less likely to be chosen by other overriders who also know the convention!)


通常使用 __method__ 这种格式书写方法名称是一个惯例，使用这种惯例有助于合作开发者快速理解你的代码。

但如果你的式子后没有索引，那么 if 判断会是永远为 true 要注意

Another common example, and one that’s a little more subtle (both as to what it does and as to why it’s not a good idea), involves the String#gsub! method.

另一个常用例子有点微妙，我们看下怎么做，同时不推荐这么做，关于  String#gsub! 方法

The return value of Strng#gsub! And why it should stay that way

```ruby
2.5.0 :021 > string = "Hello there!"
 => "Hello there!"
2.5.0 :022 > string.gsub!(/e/, "E")
 => "HEllo thErE!"
2.5.0 :023 >
```

gsub! 原来的作用是替换掉对象中的特定内容。

但如果没有对应的匹配内容，gsub! 就不会起作用， 直接 return 一个 nil

```ruby
2.5.0 :024 > string = "Hello there!"
 => "Hello there!"
2.5.0 :025 > string.gsub!(/a/, "A")
 => nil
2.5.0 :026 >
```

返回 nil 那么就说明存在一个潜在的问题：如果把 gsub! 用在 method 链条中时需要注意。

```ruby
2.5.0 :026 > string.gsub!(/e/, "E").reverse!
 => "!ErEht ollEH"
2.5.0 :027 > string.gsub!(/a/, "A").reverse!
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):27
NoMethodError (undefined method `reverse!' for nil:NilClass)
2.5.0 :028 >
```

nil 作为一个特殊的 object 在 methods 链条中容易引起报错。

-

The `tap` method

-

The `tap` method (callable on any object) performs the somewhat odd but potentially useful task of executing a code block, yielding the receiver to the block, and returning the receiver. It’s easier to show this than to describe it:

 `.tap` 会把receiver yield 给block进行里面的操作，不过最后会return receiver(有点像each)

 ```ruby
 2.5.0 :030 > "Hello".tap { |receiver| receiver.upcase }
 => "Hello"
2.5.0 :031 > "Hello".tap { |receiver| puts  receiver.upcase }
HELLO
 => "Hello"
2.5.0 :032 >
 ```

如果加上 tap ， 则无所谓 block 中最后是什么结果，因为最后的返回值始终是 receiver

```ruby
2.5.0 :032 > "Hello".tap { |receiver| puts  receiver.upcase }.reverse
HELLO
 => "olleH"
2.5.0 :033 >
```


Called on the receiver "Hello", the tap method yields that string back to its code block, as confirmed by the printing out of the uppercased version of the string. Then tap returns the entire
string—so the reverse operation is performed on the string. If you call gsub! on a string inside a tap block, it doesn’t matter whether it returns nil, because tap returns the string. Be careful, though. Using tap to circumvent the nil return of gsub! (or of other similarly behaving bang methods) can introduce complexities of its own, especially if you do multiple chaining where some methods perform in-place operations and others return object copies.

我们可以把 gsub! 用在 tap 的 block 中来避免 nil 引起的爆炸，但是又会遇到 if 判断永远为 true 的情况

一个解决办法是使用 chain 的时候考虑到各种可能的情况，把 chain 拆开，分成独立步骤操作

Still, a number of Ruby users have been bitten by the nil return value, either because they expected gsub! to behave like gsub (the non-bang version, which always returns its receiver, whether there’s been a change or not) or because they didn’t anticipate a case where the string wouldn’t change. So gsub! and its nil return value became a popular candidate for change.

很多开发者都被 nil 的特殊性困扰，有时他们希望 gsub! 的行为能够更像 无感叹号版的 gsub, 在不匹配时不返回 nil 返回的是 receiver 本身，也或者他们不预期也不准备处理不匹配的情况。这使得 bang 版本的 gsub! 成为了开发者 override 的备选之一

```ruby
2.5.0 :001 > string = 'Hello'
 => "Hello"
2.5.0 :002 > string.gsub(/x/, "abc")
 => "Hello"
2.5.0 :003 >
```

We start with a hash of state abbreviations and full names . Then comes a string that uses state abbreviations . The goal is to replace the abbreviations with the full names, using a gsub! operation that captures any two consecutive uppercase letters surrounded by word boundaries (\b) and replaces them with the value from the hash corresponding to the two-letter substring . Along the way, we take note of whether any such replacements are made. If any are, gsub! returns the new version of string. If no substitutions are made, gsub! returns nil. The result of the process is printed out at the end .
现在有一个hash中存有州的缩写和全名。接着会拿到一个含有州名称缩写的string。 目标是用全名去替换掉缩写，使用 gsub! 方法操作捕捉两个单词边界内有两个大写字母的内容，接着再用着两个大写字母去对应hash中的对应缩写，拿到全名，替换掉。如果最后替换成功，会return替换后的string，如果没有替换发生，return nil。

下面的例子中我们将 gsub! 改写，让他无论是否匹配，最后返回值都是 receiver， 这样避免了 nil 爆炸问题。

```ruby
2.5.0 :004 > class String
2.5.0 :005?>   alias __old_gsub_bang__ gsub!
2.5.0 :006?>   def gsub!(*args, &block)
2.5.0 :007?>      __old_gsub_bang__(*args, &block)
2.5.0 :008?>     self
2.5.0 :009?>   end
2.5.0 :010?> end
 => :gsub!
2.5.0 : >
```

修改后测试不匹配的情况

```ruby
2.5.0 : > "Hello".gsub!(/xyz/, "abc")
 => "Hello"
2.5.0 : >
```

不过这里 if 判断又陷入了 true 的循环

来看一个，ruby 原版的 gsub! 的运用。

注意

gsub / gusb! 是一个 enumerate 操作 (global substitution)

sub / sub! 则不是

下面例子中的 `string.gsub!(#regexp)` 如果不跟 block 那么会返回一个 enumerator ，如果给了block 则会 一次一个对应到 block 中 ， 如果不使用 书中给出的 { states[$1] } ，使用下面的写法也可以替换掉目标内容

书中例子：

```ruby
2.5.0 : > states = { "NY" => "New York", "NJ" => "New Jersey", "ME" => "Maine" }
 => {"NY"=>"New York", "NJ"=>"New Jersey", "ME"=>"Maine"}
2.5.0 : > string = "Eastern states incldue NY, NJ, and ME."
 => "Eastern states incldue NY, NJ, and ME."
2.5.0 : > if string.gsub!(/\b([A-Z]{2})\b/) { states[$1] }
2.5.0 :?>   puts "Subustitution occuerred."
2.5.0 :?> else
2.5.0 :?>   puts "String unchanged"
2.5.0 :?> end
Subustitution occuerred.
 => nil
2.5.0 : >
```

替换内容：

```ruby
2.5.0 : > string = "Eastern states incldue NY, NJ, and ME."
 => "Eastern states incldue NY, NJ, and ME."
2.5.0 : > states
 => {"NY"=>"New York", "NJ"=>"New Jersey", "ME"=>"Maine"}
2.5.0 : > string.gsub!(/\b([A-Z]{2})\b/) { |match| states[match] }
 => "Eastern states incldue New York, New Jersey, and Maine."
2.5.0 : > string
 => "Eastern states incldue New York, New Jersey, and Maine."
2.5.0 : >
```

The damage here is relatively light, but the lesson is clear: don’t change the documented behavior of core Ruby methods. Here’s another version of the states-hash example, using sub! rather than gsub!. In this version, failure to return nil when the string doesn’t change triggers an infinite loop. Assuming we have the states hash and the original version of string, we can do a one-at-a-time substitution where each substitution is reported:

这里的破坏不大但教训很明显：不要改变ruby doc中core里的方法。 下面是另一个替换states的方法版本。这个版本中使用 sub! 而不是 gsub!

```ruby
2.5.0 :065 > string
 => "Eastern states incldue , New York, New Jersey, and Maine."
2.5.0 :066 > string = "Eastern states incldue NY, NJ, and ME."
 => "Eastern states incldue NY, NJ, and ME."
2.5.0 :067 > states
 => {"NY"=>"New York", "NJ"=>"New Jersey", "ME"=>"Maine"}
2.5.0 :068 > while string.sub!(/\b([A-Z]{2})\b/) { states[$1] }
2.5.0 :069?>   puts "Replacing #{$1} with #{states[$1]}"
2.5.0 :070?> end
Replacing NY with New York
Replacing NJ with New Jersey
Replacing ME with Maine
 => nil
2.5.0 :071 > string
 => "Eastern states incldue New York, New Jersey, and Maine."
2.5.0 :072 >
```

由于 sub! 不是一个迭代方法，他只会每次修改他匹配到的第一个位置，所以这里使用了while loop 来进行操作。每一次都会拿到 string 中的下一个匹配点（因为上一个匹配点被sub!换掉了），直到 string 中再也找不到有像 NY NJ 这类连续的两个大写字母。注意如果string中有些州缩写在states中并没有，也不会终止 loop ，只有当string中找不到连续大写字母的时候才会终止。因为如果 `sub!(/\b([A-Z]{2})\b/)` 侦测到了连续两个大写字母，那么他就锁定了这个位置，而states中没有对应的州名称，所以 `states[$1]` , 那么就会用空值 `nil` 替换掉原来位置的大写字母，然后return替换后的值，整个式子不会导致loop中断。第一步使用 regexp 的匹配才是关键点。

如果人为插入几个不存在的缩写，可以看到实际效果，只会是在那一步的 `$1` 是nil， 虽然如此但不影响boolean判断。

```ruby
2.5.0 :072 > string = "Eastern states incldue OM, NY, NJ, JN, and ME."
 => "Eastern states incldue OM, NY, NJ, JN, and ME."
2.5.0 :073 > while string.sub!(/\b([A-Z]{2})\b/) { states[$1] }
2.5.0 :074?>   puts "Replacing #{$1} with #{states[$1]}"
2.5.0 :075?> end
Replacing OM with
Replacing NY with New York
Replacing NJ with New Jersey
Replacing JN with
Replacing ME with Maine
 => nil
2.5.0 :076 >
```

注意这里拿 matchdata 的两种语法都可以用使用 $n 或者用block parameter 来代表， 但sub!总共只会传1次对象到 block 中

这避免了 nil 报错，也不会出现无限 true 的情况，但如果我们改掉了默认的 sub! 让他每次末尾都返回 receiver 那么就陷入无限循环。

What you should not do, then, is rewrite core methods so that they don’t do what others expect them to do. There’s no exception to this. It’s something you should never do, even though you can.
That leaves us with the question of how to change Ruby core functionality safely. We’ll look at four techniques that you can consider. The first three are additive change, hook or pass-through change, and per-object change. Only one of them is truly safe, although all three are safe enough to use in many circumstances. The fourth technique is refinements, which are module-scoped changes to classes and which can help you pinpoint your core Ruby changes so that they don’t overflow into surrounding code and into Ruby itself.

我们不应该做的，是重写(覆盖原有版本)方法，如果这么做了，其他依赖他的方法很可能被波及。因此不要这么做，即便我们知道怎么做。

留给我们的问题是，如何安全地改变 core中的一些功能。下面会介绍4种技术。
前面三种是 additive change 附加改变， hook or pass-through change 挂靠或穿越改变， per-object change 对单个对象的改变。虽然这前3种在多数情况下都足够安全，但只有一种是绝对安全的。第4种技术是 refinement 改良， 是 module 范围内的改变，这种改变帮助你更精确地定位改变位置，这样可以尽量避免改变冲刷到周围的代码或 ruby 本身。


- additive change
- hook / pass-through change
- per-object change
- module-scoped change

 Along the way, we’ll look at custom-made examples as well as some examples from the Active Support library, which is typically used as part of the Rails web application development framework. Active Support provides good examples of the first two kinds of core change: additive and pass-through. We’ll start with additive.

沿着这条路，我们会用到一些自己写的例子，以及 Active Support 库中的例子，后者是 Rails 的一部分。Active Support 为前两种类型的 core 改变技术提供了很好的例证： additive 和 pass-through

-

**Additive changes**

-

The most common category of changes to built-in Ruby classes is the additive change: adding a method that doesn’t exist. The benefit of additive change is that it doesn’t clobber existing Ruby methods. The danger inherent in it is that if two programmers write added methods with the same name, and both get included into the interpreter during execution of a particular library or program, one of the two will clobber the other. There’s no way to reduce that risk to zero.

最常见的改变 ruby 内建 classes 的类别就是  additive changes : 也就是写一些 core 中没有的方法，好处是不会影响已经存在的 方法，潜在的风险是，如果不同的开发者写了同名的 methods 都引入了同一个 程式，那么其中一个必然会盖掉另一个。

添加methods 通常是因为有很多人都有类似的需求，换句话说他们不是单独为某个程式而专门撰写的。如果一个方法（或者解决某个特定问题的固定思路）已经被讨论了很多年，那么写这样一个方法就是相对安全的。

The Active Support library, and specifically its core extension sublibrary, adds lots of methods to core Ruby classes. The additions to the String class provide some good examples. Active Support comes with a set of "inflections" on String, with methods like pluralize and titleize. Here are some examples (you’ll need to run gem install activesupport to run them, if you don’t have the gem installed already):

Rails 的 active support 库，特别是他的核心拓展库 sublibrary, 添加了很多方法到 ruby core classes 中。比如添加到 String 中的方法就是很好的例子，比如  `pluralize` 和 `titleize` 方法

```ruby
2.5.0 :001 > require 'active_support/core_ext/string/inflections.rb'
 => true
2.5.0 :002 > 'person'.pluralize
 => "people"
2.5.0 :003 > 'man'.pluralize
 => "men"
2.5.0 :004 > 'monkey'.pluralize
 => "monkeys"
2.5.0 :005 >
2.5.0 :006 > 'little dorritt'.titleize
 => "Little Dorritt"
2.5.0 :007 > 'cable bill'.titleize
 => "Cable Bill"
2.5.0 :008 >
```

Any time you add new methods to Ruby core classes, you run the risk that someone else will add a method with the same name that behaves somewhat differently. A library like Active Support depends on the good faith of its users and on its own reputation: if you’re using Active Support, you presumably know that you’re entering into a kind of unwritten contract not to override its methods or load other libraries that do so. In that sense, Active Support is protected by its own reputation and breadth of usage. You can certainly use Active Support if it gives you something you want or need, but don’t take it as a signal that it’s generally okay to add methods to core classes. You need to be quite circumspect about doing so.

额外写 methods 的潜在风险前面已经提到，但如果是引入像 active support 这类广泛接受的库到 core 中则相对安全，由于这类库的维护者相对专业，名声好，使用范围广，那么引入时你基本就默认了不会再去改里面的方法。但这并不是说我们可以随意引入这类库，决定之前仍然要考虑清楚。

-

**Pass-through overrides**

-

A pass-through method change involves overriding an existing method in such a way that the original version of the method ends up getting called along with the new version. The new version
does whatever it needs to do and then passes its arguments along to the original version of the method. It relies on the original method to provide a return value. (As you know from the match and gsub! override examples, calling the original version of a method isn’t enough if you’re going to change the basic interface of the method by changing its return value.)
You can use pass-through overrides for a number of purposes, including logging and debugging:

一个 pass-through 修改是对已经存在的方法的覆盖：新版本的方法实际是续接在原有版本的返回值上，就像我们之前写的新版的 match, gsub! 。它依赖于原来版本的返回值。

```ruby
2.5.0 :002 > class String
2.5.0 :003?>   alias __old_reverse__ reverse
2.5.0 :004?>
2.5.0 :005?>   def reverse
2.5.0 :006?>     $stderr.puts "Reversing a string."
2.5.0 :007?>     __old_reverse__
2.5.0 :008?>     end
2.5.0 :009?>   end
 => :reverse
2.5.0 :010 > puts "David".reverse
Reversing a string.
divaD
 => nil
2.5.0 :011 >
```

The first line is printed to STDERR, and the second line is printed to STDOUT. The example depends on creating an alias for the original reverse and then calling that alias at the end of the new reverse."

"Reversing a string" 这条信息是输出到 STDERR 中的，而 `__old_reverse__`则还是输出到 stdout STDOUT

这个例子中的对 reverse 的覆盖就用到了 reverse 原来的版本，是通过 先建立一个 同名方法的方式实现的。

Aliasing and its aliases

之前提到过 alias 还有另一个功能接近的方法 alias_method

In addition to the alias keyword, Ruby has a method called alias_method, which is a private instance method of Module. The upshot is that you can create an alias for a method either like this

```ruby
# alias version
class String
  alias __old_reverse__ reversr
end

# alias_method version (takes symbol or string object as arg)
# also don't forget the comma `,` between them
class String
  alias_method :__old_reverse__:, :reverse
end
```

Because it’s a method and not a keyword, alias_method needs objects rather than bare method names as its arguments. It can take symbols or strings. Note also that the arguments to alias don’t have a comma between them. Keywords get to do things like that, but methods don’t.

`alias` 是一个keyword, 后面的方面名称可以使用 bare word

`alias_method` 是一个method, 遵循方法的参数句法规则，传入的要是object, 多个参数之间要用逗号分隔。

It’s possible to write methods that combine the additive and pass-through philosophies. Some examples from Active Support demonstrate how to do this.

我们可以将第一种 additive change 和 第二种 pass-through change 结合起来，还是 Active Support 中的例子

-

Additive / pass-through hybrids

-

这种混合的意思是，这个方法的名称仍然是原来的那个名称，只不过添加了一些东西到这个方法的接口上 ( adds something to the method’s interface ) 。也可以说他为原来的方法添加上了一些列具有新功能的子集

比如 Active Support 对 to_s 的修改，对于不同的 对象 to_s 的行为是不同的，比如 `Time#to_s`

```ruby
2.5.0 :015 > Time.now
 => 2018-02-14 10:22:16 +0800
2.5.0 :016 > Time.now.to_s # default version
 => "2018-02-14 10:22:24 +0800"

2.5.0 :017 > require 'active_support/core_ext/time'
 => true
2.5.0 :018 > Time.now.to_s
 => "2018-02-14 10:22:55 +0800"
2.5.0 :019 > Time.now.to_s(:db)
 => "2018-02-14 10:23:03"
2.5.0 :020 > Time.now.to_s(:number)
 => "20180214102306"
2.5.0 :021 > Time.now.to_s(:rfc822)
 => "Wed, 14 Feb 2018 10:23:15 +0800"
2.5.0 :022 >
```

上面的例子中 Active Support 为Time对象 提供了多种to_s 的格式输出，只要在后面传入对应格式的参数

The various formats added to `Time#to_s` work by using strftime, which wraps the system call of the same name and lets you format times in a large number of ways. So there’s nothing in the modified `Time#to_s` that you couldn’t do yourself. The optional argument is added for your convenience (and of course the database-friendly :db format is of interest mainly if you’re using Active Support in conjunction with an object-relational library, such as ActiveRecord). The result is a superset of `Time#to_s`. You can ignore the add-ons, and the method will work like it always did.

这些添加到 `Time#to_s` 的新功能用到了 strftime (这个方法本身就可以进行强大的格式转换输出，所以没有什么关于 `Time#to_s`的改变是你自己不能实现的)。注意 `Time#to_s` 功能原来的功能并没有改变，你如果需要特定格式的输出就传对应参数，如果不传那么和默认版本还是一样的结果。顺带要提的是 :db 是对数据库很友好的格式输出，如果你刚好在使用 ActiveRecord 这类库那么会是很好的选择。

As with pure method addition (such as `String#pluralize`), the kind of superset-driven override of core methods represented by these examples entails some risk: specifically, the risk of collision. Is it likely that you’ll end up loading two libraries that both add an optional :db argument to `Time#to_s`? No, it’s unlikely—but it’s possible. Once again, a library like Active Support is protected by its high profile: if you load it, you’re probably familiar with what it does and will know not to override the overrides. Still, it’s remotely possible that another library you load might clash with Active-Support. As always, it’s difficult or impossible to reduce the risk of collision to zero. You need to protect yourself by familiarizing yourself with what every library does and by testing your code sufficiently.

pluralize 这类方法是直接往 ruby core 里加入不存在的方法， to_s(:db) 使用的是接口拓展的方法。后者存在的潜在风险是： 虽然我们不太可能同时引入两个库，其中都有对 `Time#to_s` 的拓展，但这种情况的发生概率不是零。因此，还是之前提到的，引入这类库之前一定要清楚库里有什么内容，适用范围是什么，还要在引入之后进行充分的测试。

The last major approach to overriding core Ruby behavior we’ll look at—and the safest way to do it—is the addition of functionality on a strictly per-object basis, using `Object#extend`.

最后一种主要的修改 core 的方式，也是最安全的方法：添加只针对单个对象的方法。使用 `Object#extend`

-

**Per-object changes with extend**

-

`Object#extend` is a kind of homecoming in terms of topic flow. We’ve wandered to the outer reaches of modifying core classes—and extend brings us back to the central process at the heart of all such changes: changing the behavior of an individual object. It also brings us back to an earlier topic from this chapter: the mixing of a module into an object’s singleton class. That’s essentially what extend does.

`Object#extend` 算是我们话题的回归。之前都是在说一些相对外部的修改 core classes 的内容， extend 方法实际触及到了这个过程的核心：修改单个 object 的行为。这也扯回到了这章开头介绍的将 module 混入一个 object 的 singleton class 中的内容

Adding to an object’s functionality with extend

之前我们使用

class < object
    Include SomeModule
end

语法打开一个对象的 singleton class ，然后在内部 include module ，以此简化对多个object 的重复操作

```ruby
module Secretive
  def name
    "[not available]"
  end
end

class Person
  attr_accessor :name
end

david = Person.new
david.name = "David"
matz = Person.new
matz.name = "Matz"
ruby = Person.new
ruby.name = "Ruby"
david.extend(Secretive)
ruby.extend(Secretive)
puts "We've got one person named #{matz.name}, " + "one named #{daivid.name}, " + "and one named #{ruby.name}."
```

output:

```ruby
2.5.0 :003 > load './per_object.rb'
We've got one person named Matz, one named [not available], and one named [not available].
```

现在我们不需要打开 object 的 singleton class 而只用 extend 方法也可以做到

如上面所示, 只需要

object.extend(ModuleName)

就可以了

这个语法将 ModuleName 加入了 object 的 lookup path,

同样的 extend 也用于给 class 对象添加 class methods

-

Adding class methods with extend

-

假设我们现在有一个 module Makers

```ruby
module Makers
  def makes
    %w{Honda Ford Toyota Cheverolet Volvo}
  end
end
```

然后我们的 class Car 想要引入这个 module 将里面的 `makes` 方法作为自己的 class method

那么可以有两种方式：

```ruby
class Car
  extend Makders
end
```

或者

```ruby
class Car
  class << self
    def makes
      %w{Honda Ford Toyota Cheverolet Volvo}
    end
  end
end
```

第一种是常规的方法
第二种是采用了 添加 singleton method 的方法

我们甚至可以简化为写

Car.extend(Makers)

```ruby
2.5.0 :001 > class Car; end
 => nil
2.5.0 :002 > module Makers
2.5.0 :003?>   def makes
2.5.0 :004?>     %w{Honda Ford Toyota Cheverolet Volvo}
2.5.0 :005?>   end
2.5.0 :006?> end
 => :makes
2.5.0 :007 > Car.extend(Makers)
 => Car

2.5.0 :009 > Car.makes
 => ["Honda", "Ford", "Toyota", "Cheverolet", "Volvo"]
2.5.0 :010 >
```

As with non-class objects, extending a class object with a module means mixing the module into the class’s singleton class. You can verify this with the ancestors method:

就如我们将module extend 给一个非 class 对象一样， extend module 给一个 class 对象同样是在将module 中的 instance methods 加到了 class 对象的 singleton class 中——也就是 class 本身，module 中的 instance methods 变成了 class 对象的 singleton class 的 instance method

相当于在 class Car 中打开 Car 的 singleton class 然后在里面 include Makers

```ruby
2.5.0 :001 > class Car; end
 => nil
2.5.0 :002 > module Makers
2.5.0 :003?>   def makes
2.5.0 :004?>     %w{Honda Ford Toyota Chevrolet Volvo}
2.5.0 :005?>   end
2.5.0 :006?> end
 => :makes
2.5.0 :007 > class << Car
2.5.0 :008?>   include Makers
2.5.0 :009?>   end
 => #<Class:Car>
2.5.0 :010 > Car.makes
 => ["Honda", "Ford", "Toyota", "Chevrolet", "Volvo"]
2.5.0 :011 >
```

通过 .ancestors 方法查看 lookup path

```ruby
2.5.0 :013 > Car.ancestors
 => [Car, Object, Kernel, BasicObject]
2.5.0 :014 > Car.singleton_class.ancestors
 => [#<Class:Car>, Makers, #<Class:Object>, #<Class:BasicObject>, Class, Module, Object, Kernel, BasicObject]
2.5.0 :015 >
```

The odd-looking entries in the list are singleton classes. The singleton class of Car itself is included; so are the singleton class of Object (which is the superclass of the singleton class of Car) and the singleton class of BasicObject (which is the superclass of the singleton class of Object). The main point for our purpose is that Makers is included in the list.

上面返回的path中的那些 singleton class 看起来比较奇怪。 Car 自己的 singleton class 也被包含在其中，相同的还有 Object 的以及 BasicObject 的，但这里的关键点是 Makers 这个 module 也在其中

但如果不是对 singleton class 使用 .ancestors 那么返回的结果会有所不同

Remember too that subclasses have access to their superclass’s class methods. If you subclass Car and look at the ancestors of the new class’s singleton class, you’ll see Makers in the list.

记住 subclass 也可以获得他们的 superclass 中的方法，那些继承自 Car 的 subclass 也会把 Makers 中的方法包括进去

我们最初的目的是看 extend 如何拓展 ruby core 的功能，现在让我们收回来看。

-

Modifying core behavior with extend

-

前面我们已经看到  module 中可以包含很多能够被复用的 methods , 而 extend 这个来自 Kernel 中的方法可以让各类对象的 singleton class 混入 module 获得不同层级的方法包。
现在将之前提到的各种技巧综合起来，我们就可以相对安全的修改 core.

还是以之前的 `String#gsub!` 方法为例，如果没有匹配它会return nil 如果有 会return 修改后的内容。

```ruby
module GsubBangModifier

  def gsub!(*args, &block)
    super || self
  end

end

str = "Hello there!"
str.extend(GsubBangModifier)
str.gsub!(/xyz/, "abc").reverse!

puts str  # => !ereht olleH
```

上面的方法中 `super` 的作用是到 lookup path 中去找下一个(实际会是往superclass的方向)同名的 `gsub!`，那么就会在 String 中找到 `String#gsub!` 实际也就是 original version 的 `gsub!`， 然后执行这原版方法

而 `super || self`  合起来就是先执行原版gsub! 如果没有匹配会返回 nil 那么会 转到执行 || 右边，也就是返回 receiver ，这也是例子中后面所演示的情况

Thus you can change the behavior of core objects—strings, arrays, hashes, and so forth—without reopening their classes and without introducing changes on a global level. Having calls to extend in your code helps show what’s going on. Changing a method like gsub! inside the String class itself has the disadvantage not only of being global but also of being likely to be stashed away in a library file somewhere, making bugs hard to track down for people who get bitten by the global change.

这样你能够改变一些core中的对象的行为比如 string, array, hash对象，但你并不需要打开他们所在的class引入一些影响全局的改变。如果在 String 内部去修改 `gsub!` 方法会带来一些不利因素，比如影响范围很大，而且可能存在一些潜在的未察觉难以追踪的风险。

There’s one more important piece of the puzzle of how to change core object behaviors: a new feature called refinements.

关于修改core这块拼图还有另外重要的一块 -- refinements 改良

-

**Using refinements to affect core behavior**

-

Refinements were added to Ruby 2.0, but were considered "experimental" until the 2.1 release. The idea of a refinement is to make a temporary, limited-scope change to a class (which can, though needn’t, be a core class).

Refinements 在 2.0 版本的时候加入，直到 2.1 之前都被视作一个实验性的功能，他的目的是 给 class 添加一个临时的，有限范围内的修改，当然不一定是 修改 core

来看之前 String 中用到的 shout 例子

```ruby
module Shout
  refine String do
    def shout
      self.upcase + "!!!"
    end
  end
end

class Person
  attr_accessor :name
  using Shout
  def announce
    puts "Announccing #{name.shout}"
  end
end

david = Person.new
david.name = "David"
david.announce
# => Announcing DAVID!!!
```

Two different methods appear here, and they work hand in hand: refine  and using . The refine method takes a class name and a code block. Inside the code block you define the behaviors you want the class you’re refining to adopt. In our example, we’re refining the String class, adding a shout method that returns an upcased version of the string followed by three exclamation points.

这里用到了 一对 方法： `refine` 和 `using`。

refine 方法接受一个 class 的名称以及一个 block , 上面的例子中 refine 包裹的 block 中我们定义了一个新的 shout (instance)方法。

The using method flips the switch: once you "use" the module in which you’ve defined the refinement you want, the target class adopts the new behaviors. In the example, we use the Shout module inside the Person class. That means that for the duration of that class (from the using statement to the end of the class definition), strings will be "refined" so that they have the shout method.

使用 using 可以引入之前定义好的 refinements ，从你写 using 那个地方开始，一直到引入refinements 的这个 class 的结束，refined methods 都是有效的。或者可以理解为它是基于context的。

The effect of "using" a refinement comes to an end with the end of the class (or module) definition in which you declare that you’re using the refinement. You can actually use using outside of a class or module definition, in which case the effect of the refinement persists to the end of the file in which the call to using occurs.

我们甚至可以在 module 和 class 之外使用 refinements, 有效范围会是 using 的那行一直到 file 文件的末尾。

```ruby
2.5.0 :001 > module Restring
2.5.0 :002?>   refine String do
2.5.0 :003 >     def upcase
2.5.0 :004?>       self.split(//).reverse!
2.5.0 :005?>     end
2.5.0 :006?>   end
2.5.0 :007?> end
 => #<refinement:String@Restring>

2.5.0 :008 > class Person
2.5.0 :009?>   attr_accessor :name
2.5.0 :010?>   using Restring
2.5.0 :011?>   def weird_call
2.5.0 :012?>     self.name.upcase
2.5.0 :013?>     end
2.5.0 :014?>   end
 => :weird_call

2.5.0 :016 > david = Person.new
 => #<Person:0x00007fb5bb8417f0>
2.5.0 :017 > david.name = "David"
 => "David"
2.5.0 :018 > david.weird_call
 => ["d", "i", "v", "a", "D"]
2.5.0 :019 >
2.5.0 :020 > "Arbitrary string.".weird_call # same method on diff obj
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):20
NoMethodError (undefined method `weird_call' for "Arbitrary string.":String)
2.5.0 :021 > "Arbitrary string.".upcase
 => "ARBITRARY STRING."
2.5.0 :022 >
```

上面的例子中可以看到，module Restring 中的 `refine String` block 定义的 upcase 只有在 using 的背景范围内有效，出到 irb 的背景中，string 对象的 `upcase` 任然是原版的。

如果尝试在 irb 中直接使用 using 会报错

```ruby
2.5.0 :022 > using Restring
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):22
        1: from (irb):22:in `using'
RuntimeError (main.using is permitted only at toplevel)
2.5.0 :023 >
```

Refinements can help you make temporary changes to core classes in a relatively safe way. Other program files and libraries your program uses at runtime will not be affected by your refinements.

Refinements 让我们可以临时的，相对安全地给 core 添加一些变化，因为它的范围被限制在 module / class 内部，或者一个 file 的内部，所以其他关联的 库 和 文件不会受到波及。

We’ll end this chapter with a look at a slightly oddball topic: the BasicObject class. BasicObject isn’t exclusively an object-individuation topic (as you know from having read the introductory material about it in chapter 3). But it pertains to the ancestry of all objects—including those whose behavior branches away from their original classes—and can play an important role in the kind of dynamism that Ruby makes possible.

这章的末尾会讨论一个比较奇怪的话题： BaiscObject class
BasicObject 的内含不仅仅只限于 object individuation 话题。他与所有 object 都有关联，包括哪些行为上与他们出生class 偏离很远的对象，BasicObject 为ruby的灵活性提供了相当一部分的基础。

-

**BasicObject as ancestor and class**

-

BasicObject 几乎是所有对象的class的 最高祖先 .ancestors 的最后一个，除非你在 BasicObject 中混入其他 module 延伸 lookup path

在 doc 中也可以看到 BasicObject 在 Parent 那一栏 是空白的，methods 数量也很少

![](https://ws4.sinaimg.cn/large/006tKfTcgy1fog395itn4j30de09zjuo.jpg)

```ruby
2.5.0 :002 > BasicObject.instance_methods
 => [:!, :equal?, :instance_eval, :instance_exec, :==, :!=, :__id__, :__send__]
2.5.0 :003 >
```

-

**Using BasicObject**

-

BasicObject enables you to create objects that do nothing, which means you can teach them to do everything—without worrying about clashing with existing methods. Typically, this entails heavy use of method_missing. By defining method_missing for BasicObject or a class that you write that inherits from it, you can engineer objects whose behavior you’re completely in charge of and that have little or no preconceived sense of how they’re supposed to behave.

BasicObject 让我们可以创造出一些什么都不能做的对象，换句话说，我们可以教给他们任何事。而且不用担心与其他 method 产生冲突。通常这会重度依赖于 method_missing ，通过给 BasicObject 以及那些你自己写的且继承自BasicObject的 class 定义 method_missing , 你可以更好的组织那些必须由你负责的对象，或者那些你不确定会如何回应你的对象。

The best-known example of the use of an object with almost no methods is the Builder library by Jim Weirich. Builder is an XML-writing tool that outputs XML tags corresponding to messages you send to an object that recognizes few messages. The magic happens courtesy of method_missing.

关于那些基本没有方法可用的 objects 的最好的例子是 Jim Weirich 写的 Builder 库。 Builder 是一个 输出 XML 格式的工具，针对那些只能回应很少一部分信息的对象。 主要的功能在于 method_missing

xml is a Builder::XmlMarkup object . The object is programmed to send its output to -STDOUT and to indent by two spaces. The instruct! command  tells the XML builder to start with an XML declaration. All instance methods of Builder::XmlMarkup end with a bang (!). They don’t have non-bang counterparts—which bang methods should have in most cases—but in this case, the bang serves to distinguish these methods from methods with similar names that you may want to use to generate XML tags via method_missing. The assumption is that you may want an XML element

xml 是一个 Builder::XmlMarkup 对象。这类对象是用来输出信息到 STDOUT 然后增加空格缩排的。 `instruct` 方法告诉 XML builder 以一个 XML 声明开头。 所有 Builder::XmlMarkup 里面的方法都是 bang! 版本的。而且他们没有对应的无 `!` 版本。但这里使用的 bang! 版本方法只是为了跟那些你用来生成tag(通过method_missing)的method名称区别开来。

Here’s a simple example of Builder usage (and all Builder usage is simple; that’s the point of the library). This example presupposes that you’ve installed the builder gem.
下面是一个简单的 Builder 的使用案例（所有Builder的用法都简单，这就是他的特点所在）。完成下面的案例你需要安装builder这个gem

```ruby
require 'builder'

xml = Builder::XmlMarkup.new(:target => STDOUT, :indent => 2)
xml.instruct!
xml.friends do
  xml.friend(:source => "college") do
    xml.name("Joe Smith")
    xml.address do
      xml.street("123 Main Street")
      xml.city("Anywhere, USA 00000")
    end
  end
end
```
called instruct, but you won’t need one called instruct!. The bang is thus serving a domain-specific purpose, and it makes sense to depart from the usual Ruby convention for its use."

首先将 xml 赋值为一个 Builder::XmlMarkup 对象，这里接受了一个 hash 的数据，里面包含两个键值对， :target => STDOUT 表示输出到 STDOUT ， :intent => 2 表示缩进两个空格

 Builder::XmlMarkup 对象实际可执行（其他的不带!的是用来生成 xml tag 的）的所有method都是 bang！ 版本的。 instruct! 方法开始一个 xml 文件的声明

"<?xml version="1.0" encoding="UTF-8"?>"

后面对 xml 对象使用的所有不带 ! 的方法用到的 method_missing 机制，将这些 miss 掉的 方法名称都转换为 xml tags ， 比如 xml.name 会生成 <name></name>

Tag 方法连带的 block 内的内容会作为 两个 tags 之间的内容，如果 tag 方法后给出了 string 参数，里面的内容也会作为 标签之间的内容。

The various XML tags take their names from the method calls. Every missing method results in a tag, and code blocks represent XML nesting. If you provide a string argument to a missing method, the string will be used as the text context of the element. Attributes are provided in hash arguments.

通过使用不同的method名称我们可以带出不同的tag名称，因为每一次method_misssing都会导致生成一个新的标签（由于class内部基本没有什么method，所以miss是基本都可以触发的），一个block 代表一个 嵌套 XML 结构（里面包含其他标签）。如果你传入string作为参数，那么string内容将作为开闭标签之间的内容。而关于整个 xml 文件的 attributes 参数是 hash 格式

来看上面例子的输出

```ruby
2.5.0 :001 > load 'builder.rb'
<?xml version="1.0" encoding="UTF-8"?>
<friends>
  <friend source="college">
    <name>Joe Smith</name>
    <address>
      <street>123 Main Street</street>
      <city>Anywhere, USA 00000</city>
    </address>
  </friend>
</friends>
 => true
2.5.0 :002 >
```
这里之所以会直接印出在 irb 中是因为这一行

`xml = Builder::XmlMarkup.new(:target => STDOUT, :indent => 2)`

中的 `:target => STDOUT` 导向了 stdout

同时每一级标签结构是2个空格的缩排 `:indent => 2`

-

Builder uses BasicObject to do its work. Interestingly, Builder existed before BasicObject did. The original versions of Builder used a custom-made class called BlankSlate, which probably served as an inspiration for BasicObject.

Builder 使用 BasicObject 来完成自己的工作，有趣的是， Builder 实际是早于 BasicObject 存在的。最初版本的 Builder 有一个自定义的 class 叫 BlankSlate , 这可能成为了后来 BasicObject 的创造灵感。

那么如果手工打造一个基础版本的 BasicObject class ?


Simple, in the question just asked, means simpler than Builder::XmlMarkup (which makes XML writing simple but is itself fairly complex). Let’s write a small library that operates on a similar principle and outputs an indented list of items. We’ll avoid having to provide closing tags, which makes things a lot easier.

The Lister class, shown in the following listing, will inherit from BasicObject. It will define method_missing in such a way that every missing method is taken as a heading for the list it’s generating. Nested code blocks will govern indentation.”

简单，之前提出的问题意味着我们只需要一个比 Builder::XmlMarkup 简单的版本即可。让我们写一个基于类似原则能够输出具有格式缩排内容的库。 我们不生成 关闭标签，而且使用标签名称加冒号来替代tag，比如`tag:` `friend:`这样的形式， 让事情简单一点。

下面写的这个 Lister class, 将会继承自 BasicObject, 我们将会把每一个 missing 的 method 生成一个 起始tag, 中间接受的 block 中的内容作为 xml 标签后跟的内容（不像Builder能直接传入string作为标签内的内容）。

At the end, method_missing returns an empty string . The goal here is to avoid concatenating @list to itself. If method_missing ended with an expression evaluating to @list (like @list << "\n"), then nested calls to method_missing inside yield instructions would return @list and append it to itself. The empty string breaks the cycle.

Method_missing 末尾 return 了一个空 String。目的是避免 @list 重复叠加自己。

```ruby
class Lister < BasicObject
  attr_reader :list
  def initialize
    @list = ""
    @level = 0
  end

  def indent(string)
    " " * @level + string.to_s
  end

  def method_missing(m, &block)
    @list << indent(m) + ":"
    @list << "\n"
    @level += 2
    @list << indent(yield(self)) if block
    @level -= 2 # if no block given, @level will not change
    @list << "\n"
    return ""
  end
end
```

At the end, method_missing returns an empty string . The goal here is to avoid concatenating @list to itself. If method_missing ended with an expression evaluating to @list (like @list << "\n"), then nested calls to method_missing inside yield instructions would return @list and append it to itself. The empty string breaks the cycle.

用这段代码带来解释
```ruby
lister.groceries do |item|
  item.name {"Apples"}
  item.quantity { 10 }
end
```

`groceries` 是lister遇到的第一个miss, 这时 `indent(m)+":"`生成了第一个标签 和 换行符号

groceries:

groceries后包裹的是一整个 block 所以会进到 `@list << indent(yield(self)) if block`这一行。`yield self` 实际就是将整个lister对象送到了do ... end 里，例子中其实就是 item 所代表的

  在block内部， 如果不再写 item.name 之类而直接给一个字串则不会触发miss，给出的字串就会直接作为 block的return值 append 到lister尾部

  如果写了 item.name 触发了miss， 那么就会把method_miss的流程从头开始走一遍，先生成带冒号的标签，然后如果后面block中仍然有新method名称则再次叠加嵌套结构，如果后面{block}中给的是字串就append字串内容。

  如果block的末尾一行是关于 @list 的操作的，那么整个block回路就会return 当前@list内容，这会导致 内容上的重复，所以最后用 return 空字串来避免这种情况。

yield self 意思就是将当前实例对象object送给block

```ruby
load './lister.rb'

lister = Lister.new

lister.groceries do |item|
  item.name {"Apples"}
  item.quantity { 10 }
  item.name {"Sugar"}
  item.quantity { "1 1b" }
end

lister.freeze do |f|
  f.name { "Ice cream" }
end

lister.inspect do |i|
  i.item { "car" }
end

lister.sleep do |s|
  s.hours {8}
end

lister.print do |document|
  document.book { "Chapter 13" }
  document.letter { "to editor" }
end

lister.no_block

puts lister.list
```

输出

```ruby
ruby test_lister.rb
groceries:
  name:
    Apples
  quantity:
    10
  name:
    Sugar
  quantity:
    1 1b

freeze:
  name:
    Ice cream

inspect:
  item:
    car

sleep:
  hours:
    8

print:
  book:
    Chapter 13
  letter:
    to editor

no_block:

```

Admittedly not as gratifying as Builder—but you can follow the yields and missing method calls and see how you benefit from a BasicObject instance. And if you look at the method names used in the sample code, you’ll see some that are built-in methods of (nonbasic) objects. If you don’t inherit from BasicObject, you’ll get an error when you try to call freeze or inspect. It’s also interesting to note that sleep and print, which are private methods of Kernel and therefore not normally callable with an explicit receiver, trigger method_missing even though strictly speaking they’re private rather than missing.

诚然这个例子没那么美观，但是基本目的达到了。如果我们不继承自 BasicObject , 不在class 内重新定义 method_missing 的行为，那么在使用 .name 和 .freeze 这类方法时就会报错。

还有一点是 sleep 和 print 这两个方法，逻辑上他们不属于 method missing 的管辖范围，但是这里仍然触发了 method_missing 机制，这是因为这两个方法都是前面不能带 object 而应该直接用的。

-

## Summary

In this chapter, you’ve seen

- Singleton classes and how to add methods and constants to them
singleton class 以及如何在其内容增加 method 以及 constant

- Class methods
类方法

- The extend method
extend 方法

- Several approaches to changing Ruby’s core behavior
几种改变ruby core中方法的方式

- BasicObject and how to leverage it
BasicObject 以及如何利用他

We’ve looked at the ways that Ruby objects live up to the philosophy of Ruby, which is that what happens at runtime is all about individual objects and what they can do at any given point. Ruby objects are born into a particular class, but their ability to store individual methods in a dedicated singleton class means that any object can do almost anything.
我们已经看到ruby objects对ruby哲学鲜活的呈现，那就是运行中发生的一切都是关于独立object的，也都是关于他们在当下所能做的。 Ruby 的objects虽然是从一个特定的class中产生出来的，但是每一个object都有自己的singleton class意味着他们单个的个体都几乎能做一切。

You’ve seen how to open singleton class definitions and manipulate the innards of individual objects, including class objects that make heavy use of singleton-method techniques in connection with class methods (which are, essentially, singleton methods on class objects). You’ve also seen some of the power, as well as the risks, of the ability Ruby gives you to pry open not only your own classes but also Ruby’s core classes. This is something you should do sparingly, if at all—and it’s also something you should be aware of other people doing, so that you can evaluate the risks of any third-part code you're using that changes core behaviors.
你已经看到了如何打开一个 singleton class以及如何在内部进行操作，尤其是本身就是class对象的object在定义类方法时对singleton class的紧密联系。你见识了其力量也了解了其中风险。Ruby不仅让你能修改自己的class也让你能对core进行修改，但这一点上你需要谨慎，同时对于引入的第三方的会改变core的库也要谨慎。

We ended with an examination of BasicObject, the ultimate ancestor of all classes and a class you can use in cases where even a vanilla Ruby object isn’t vanilla enough.
最后我们讨论了 BasicObject, 所有class的最终祖先，一个足够简单但又没那么简单的Ruby 对象。
