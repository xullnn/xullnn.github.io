---
title:  "Rubyist-c7-Built in essentials"
categories: [Ruby/Rails ℗]
tags: [Ruby & Rails, Notes of Rubyist]
---

*注：这一系列文章是《The Well-Grounded Rubyist》的学习笔记。*



---

## Part 2. Built-in classes and modules

In part 2, we come to the heart of the Ruby language: built-in classes and modules.
这部分将进入 Ruby 的核心内容： 内建的 classes 和 modules

A great deal of what you’ll do as a Rubyist will involve Ruby’s built-ins. You’ve already seen examples involving many of them: strings, arrays, files, and so forth. Ruby provides you with a rich toolset of out-of-the-box built-in data types that you can use and on which you can build.
之前做的很多例子都涉及到了ruby的内建class和module。比如 strings, arrays, files。 ruby 提供了丰富的内建 数据 类型供你使用。

That’s the thing: when you design your own classes and modules, you’ll often find that what you need is something similar to an existing Ruby class. If you’re writing a DeckOfCards class, for example, one of your first thoughts will probably be that a deck of cards is a lot like an array. Then you’d want to think about whether your cards class should be a subclass of Array—or perhaps each deck object could store an array in an instance variable and put the cards there—and so forth. The point is that Ruby’s built-in classes provide you with starting points for your own class and object designs as well as with a set of classes extremely useful in their own right.
当你写自己的class或module时，你会发现你需要的和ruby中已经存在的某些class很类似。比如你写了一个 DeckOfCards 类，首先想到的是一副牌很像一个array。那么你会想到把 DeckOfCards 作为Array的subclass，或者每个 deck 对象将一副牌以array形式存在instance variable中，等等。 关键点是，ruby 内建的class为你自己的class提供了起始的原料，丰富的，有用的原料。

We’ll start part 2 with a look at built-in essentials (chapter 7). The purpose of this chapter is to provide you with an array (so to speak!) of techniques and tools that you’ll find useful across the board in the chapters that follow. To study strings, arrays, and hashes, for example, it’s useful to know how Ruby handles the concepts of true and false—concepts that aren’t pegged to any single built-in class but that you need to understand generally.

我们会学习 string, array, 和 hash ，会了解ruby如何处理 真与假 的概念-那些不与任何内建class挂钩但你必须理解的概念。

Following the essentials, we’ll turn to specific classes, but grouped into higher-level categories: scalar objects first (chapter 8) and then collections (chapter 9). Scalars are atomic objects, like strings, numbers, and symbols. Each scalar object represents one value; scalars don’t contain other objects. (Strings contain characters, of course; but there’s no separate character class in Ruby, so strings are still scalar.) Collection objects contain other objects; the major collection classes in Ruby are arrays and hashes. The collection survey will also include ranges, which are hybrid objects that can (but don’t always) serve to represent collections of objects. Finally, we’ll look at sets, which are implemented in the standard library (rather than the Ruby core) but which merit an exception to the general rule that our focus is on the core itself.

接着我们会转向具体的classes， 但将这些类以更高的抽象层级合并讨论： 首先是纯量 scalar 对象，接着是 集合对象 collection。 纯量是最基础的对象，比如strings, numbers, 以及 symbols。 每一个纯量对象代表一个值； 纯量对象不包含其他对象（虽然string中包含字符但ruby中没有单独的 Character 类）。collection 对象包含其他对象，ruby中collection主要是 array和hash。 对collection的了解还会包含 ranges， 这是一类综合性的对象， 可以用来代表一个集合的对象。最后将会了解 sets， 他放在 standard library 中，不过值得破例了解一下。

Equal in importance to the specific collection classes are the facilities that all collections in Ruby share: facilities embodied in the Enumerable module. Enumerable endows collection objects with the knowledge of how to traverse and transform themselves in a great number of ways. Chapter 10 will be devoted to the Enumerable module and its ramifications for Ruby programming power.
跟具体collection classes同样重要的是ruby中所有collection共享的功能：放在 Enumerable module 中的功能。 module Enumerable 赋予了 collection 对象大量的如何走访他们自己的方法。 第10章会专门讲 Enumerable module 和它强大的功能。

Part 2 continues in chapter 11 with a look at regular expressions—a string-related topic that, nonetheless, deserves some space of its own—and concludes in chapter 12 with an exploration of file and I/O operations: reading from and writing to files and I/O streams, and related subtopics like error handling and file-status queries. Not surprisingly, Ruby treats all of these things, including regular expressions and I/O streams, as objects.
第11章会讲 regular expressions-一个与string相关的话题，值得专门花篇幅介绍。最后12章会学习文件相关的 I / O 操作：从文件中读写，以及 I / O 流，还有相关子话题比如 错误处理以及文件状态查询。不出意外的，ruby会把所有这些东西包括 regular expressions  和 I / O 流，视作对象 objects。

## chapter 7 Built-in essentials

It’s more than that, though: it’s also a kind of next-generation Ruby literacy guide, a deeper and wider version of chapter 1. Like chapter 1, this chapter has two goals: making it possible to take a certain amount of material for granted in later chapters, where it will arise in various places to varying degrees; and presenting you with information about Ruby that’s important and usable in its own right. Throughout this chapter, you’ll explore the richness that lies in every Ruby object, as well as some of the syntactic and semantic subsystems that make the language so interesting and versatile.

这章不仅要介绍主要的内建classes，也会像是新版的ruby入门指导，是第一章的拓展和延伸。 就如第一章，这章有两个目的： 尽量拿出一定量的材料让你熟悉后面的章节，包含不同范围和深度的材料； 呈现ruby中最重要最有用的信息。 通过这一章将了解到每一个ruby对象背后的丰富性，以及某些语法和语义上的子系统，which 让ruby变得如此有趣以及功能丰富。


- Literal constructors —Ways to create certain objects with syntax, rather than with a call to new
字母构建器 - 使用句法新建object而不使用 new method 的方法

- Syntactic sugar —Things Ruby lets you do to make your code look nicer
语法糖果 - ruby 提供的代码美化

- “Dangerous” and/or destructive methods —Methods that alter their receivers permanently, and other “danger” considerations
危险以及具有破坏性的方法 - 永久改变 receivers 的方法，以及其他关于危险的考虑。

- The to_* family of conversion methods —Methods that produce a conversion from an object to an object of a different class, and the syntactic features that hook into those methods
`to_*` 系列转换方法 - 让一个对象从一个class变为另一个class对象的方法，以及这些方法中夹带的语法功能

- Boolean states and objects, and nil —A close look at true and false and related concepts in Ruby
boolean状态和对象，以及nil - 对 true / false 以及相关概念的深入了解。

- Object-comparison techniques —Ruby-wide techniques, both default and customizable, for object-to-object comparison
object 对比技术 - 整个ruby范围内会用到的技术，既是默认的也可以自定义。

- Runtime inspection of objects’ capabilities —An important set of techniques for runtime reflection on the capabilities of an object
运行时对对象功能的检视 - 一系列重要的 对 object 功能的运行当中的反馈技术。

**Ruby's literal constructors**


ruby’s literal constructors

对于很多 内建的 classes 可以使用 .new 方法来新建一个对象

但是少数几个 class 则不行，比如 Integer

新建对象除了使用 new 之外还可以使用一些简洁的方式，这种用很直观的方式构建 object 的方法叫做

literal constructors

|Class |Literal constructor| Example(s)|
|:-|:-|:-|
|String	|Quotation marks|	"new string" 'new string'|
|Symbol	|Leading colon	|:symbol :"symbol with spaces"|
|Array	|Square brackets	|[1,2,3,4,5]|
|Hash	|Curly braces	|{"New York" => "NY", "Oregon" => "OR"}|
|Range	|Two or three dots	|0..9 or 0...10|
|Regexp	|Forward slashes	|/([a-z]+)/|
|Proc (lambda)|	Dash, arrow, parentheses, braces	|->(x,y) { x * y }|

-

虽然 [] 可以用来直接新建 array

{ } 可以用来直接新建 hash

但是 []也可以不代表array 而作为 array的索引取得

{ #block } 也可以用来包裹 block

不过这种分歧只存在于少数的应用场景中

-

ruby 中许多顺手的method 实际上是美化过后的版本

比如 + 操作

还有  === method

原本是 object.===(other_ob)

但可以简化为 object === other_ob

```ruby
2.5.0 :001 > 1 + 2
 => 3
2.5.0 :002 > 1.+(2)
 => 3
2.5.0 :003 >
```

Ruby doesn’t know that + means addition. Nothing (other than good judgment) stops you from writing completely nonaddition-like + methods:
要清楚ruby并不知道`+`的意思是'加', 只是依照人的使用习惯把 `+` 方法定义成我们想要的行为。你可以自己改写 `+` 方法

```ruby
2.5.0 :003 > obj = Object.new
 => #<Object:0x00007fead491e6c0>
2.5.0 :004 > def obj.+(other)
2.5.0 :005?>   "Trying to add something to me, en?"
2.5.0 :006?> end
 => :+
2.5.0 :007 > puts obj + 100
Trying to add something to me, eh?
```

`+=` ,  `*=`  这些方法都是 ruby 构建出的 sugar-calling notation

或叫  operator-style sugar

```ruby
class Account
  attr_accessor :balance

  def initialize(amount=0)
    self.balance = amount
  end

  def +(x)
    self.balance += x
  end

  def -(x)
    self.balance -= x
  end

  def to_s
    balance.to_s
  end

  acc = Account.new(20)
  acc -= 5
  puts acc
end
```

`ruby sugar.rb`输出

```ruby
15
```

上面的例子中 + 和 - 实际都是针对 数字类型 的操作，但在这里可以直接用一个
Account 的实例去执行 - 和 + 操作，直接返回 其中一个 attribute 的值(`self.balance`)

ruby 对 操作符 风格的常用方法都进行了简化以更加契合人类的理解偏好

![](https://ws4.sinaimg.cn/large/006tNc79ly1fo0prh3toxj30gf0fjjuw.jpg)

-

**Customizing unary operators**

The unary operators + and - occur most frequently as signs for numbers, as in -1. But they can be defined; you can specify the behavior of the expressions +obj and -obj for your own objects and classes. You do so by defining the methods +@ and -@.

Let’s say that you want + and - to mean uppercase and lowercase for a stringlike object. Here’s how you define the appropriate unary operator behavior, using a Banner class as an example:

一元操作符大多与数字操作相关。但他们是可以被定义的的； 你可以给你自己的class定义 +obj 和 -obj 的行为，通过定义 `+@` 和 `-@` 这两个方法。

假设你想把 + 和 - 的行为改为大写和小写字串。 看下面的例子

```ruby
class Banner
  def initialize(text)
    @text = text
  end

  def to_s
    @text
  end

  def +@
    @text.upcase
  end

  def -@
    @text.downcase
  end
end

banner = Banner.new("Eat at David's!")
puts banner
puts +banner
puts -banner
```

输出

```ruby
Eat at David's!
EAT AT DAVID'S!
eat at david's!
```

You can also define the ! (logical not) operator, by defining the ! method. In fact, defining the ! method gives you both the unary ! and the keyword not. Let’s add a definition to Banner:
也可以重新定义叹号 `!` ，重新定义 `!` 不仅会改变一元操作符 `!` 的含义，也同时改变了 `not` 的行为。

```ruby
def !
  @text.reverse
end
```

然后执行

```ruby
puts !banner
puts (not banner)
```

```ruby
!s'divaD ta taE
!s'divaD ta taE
```

As it so often does, Ruby gives you an object-oriented, method-based way to customize what you might at first think are hardwired syntactic features—even unary operators like !.

如ruby经常做的，他给出 面向对象的，基于method的方式来自定义一些第一眼看起来是 硬性语法要求的功能-甚至如 `!` 这样的一元操作符。

-

感叹号 通常作为一种标记 告知这个方法会改变 reciever 自身

it usually means this method, unlike its nonbang equivalent, permanently modifies its receiver.

—

ruby 中

不带 叹号 ! 的方法返回的是 原object 经过处理后的一个新的副本 object

而带 叹号 ! 的方法则是在对 object 本身进行改变

下面的例子中不带 ！的 str.upcase 返回的 oject 的 id 与原来的物件是不同的

```ruby
2.5.0 :001 > str = 'hello'
 => "hello"
2.5.0 :002 > str.object_id
 => 70337950032840
2.5.0 :003 > str.upcase.object_id
 => 70337949939580
2.5.0 :004 > str.upcase!.object_id
 => 70337950032840
2.5.0 :005 >
```
返回新副本的 method 对比于改变 receiver 的method 前者更耗内存

改变 receiver 的 method 在使用时要考虑此处的改变会不会影响到其他地方(比如拿到这个receiver对象reference的变数)

—

带有 exclamation ！并不等同于这个 method 是破坏性的，它只是一种提醒，一个惯例，告诉你这个method 可能导致意外的结果。

同样反过来看 并不是不带 exclamation 的method 都不具有破坏性或者潜在危险，这些不带!而又具有破坏性的 method 不一定有对应的!版本。

好的实践是，不要随意给 method 后加 exclamation

—

```ruby
2.5.0 :008 > str = "A piece of string."
 => "A piece of string."
2.5.0 :009 > str.clear
 => ""
2.5.0 :010 > str
 => ""
```

上面的 clear 可以清空一个 string object 但它后面并没有 ! exclamation

Don’t use ! except in m/m! method pairs

The ! notation for a method name should only be used when there’s a method of the same name without the !, when the relation between those two methods is that they both do substantially the same thing, and when the bang version also has side effects, a different return value, or some other behavior that diverges from its nonbang counterpart.
除非你写的方法是成对的，否则不要使用`!`在方法名称后面。

Don’t name a method save! just because it writes to a file. Call that method save, and then, if you have another method that writes to a file but (say) doesn’t back up the original file (assuming that save does so), go ahead and call that one save!.
不要因为一个方法会写内容到文件中而将方法命名为 `save!`。 如果你在写入一个文件而没有将其备份，那么可以使用 `save!`

Don’t equate ! notation with destructive behavior, or vice versa

Danger in the bang sense usually means object-changing or “destructive” behavior. It’s therefore not uncommon to hear people assert that the ! means destructive. From there, it’s not much of a leap to start wondering why some destructive methods’ names don’t end with !.
不要将 `!` 符号等同于危险，或者反过来

危险只是相对的，有些带有不可逆操作的方法不带`!`

—

**Built-in and custom `to_*` (conversion) methods**

—

Every Ruby object—except instances of BasicObject—responds to to_s, and thus has a way of displaying itself as a string.


除了 BasicObject 之外的所有 class 的 instance 都可以使用 to_s

to returning a string containing a codelike representation of an object

```ruby
>> ["one", "two", "three", 4, 5, 6].to_s
=> "[\"one\", \"two\", \"three\", 4, 5, 6]"
```

反斜线溢出符号表示，string中仍然包含双引号

(where the backslash-escaped quotation marks mean there’s a literal quotation mark inside the string) to returning an informative, if cryptic, descriptive string about an object:
将一个 obj 以string方式描述

```ruby
2.5.0 :002 > Object.new.to_s
 => "#<Object:0x00007fdde512bf18>"
2.5.0 :003 >
```

-

The salient point about to_s is that it’s used by certain methods and in certain syntactic contexts to provide a canonical string representation of an object. The puts method, for example, calls to_s on its arguments. If you write your own to_s for a class or override it on an object, your to_s will surface when you give your object to puts. You can see this clearly, if a bit nonsensically, using a generic object:

`to_s` 的显著特征是他用于在特定背景下提供对一个object对象的string格式的呈现。 puts 方法就会在其 arguments 上使用 `to_s`

```ruby
2.5.0 :005 > obj = Object.new
 => #<Object:0x00007fdde513c340>
2.5.0 :006 > puts obj
#<Object:0x00007fdde513c340>
 => nil
2.5.0 :007 > def obj.to_s
2.5.0 :008?>   "I am an object!"
2.5.0 :009?>   end
 => :to_s
2.5.0 :010 > puts obj
I am an object!
 => nil
2.5.0 :011 >
```

The object’s default string representation is the usual class and memory-location screen dump . When you call puts on the object, that’s what you see . But if you define a custom to_s method on the object , subsequent calls to puts reflect the new definition . (Note that the method definition itself evaluates to a symbol, :to_s, representing the name of the method .)”

通常一个object对象的string呈现是 他的class加上他的内存地址，也就是你对object使用puts 所见的。 但是如果你重新定义 to_s ，结果就变了。

You also get the output of to_s when you use an object in string interpolation:

使用 string解析器的时候也会用到 to_s

```ruby
2.5.0 :011 > "My object says: #{obj}"
 => "My object says: I am an object!"
2.5.0 :012 >
```

Don’t forget, too, that you can call to_s explicitly. You don’t have to wait for Ruby to go looking for it. But a large percentage of calls to to_s are automatic, behind-the-scenes calls on behalf of puts or the interpolation mechanism.
不要忘记，虽然你可以明确的使用 to_s ， 但ruby中很多方法都实际用到了to_s，比如 puts 方法和 解析器。

Note

When it comes to generating string representations of their instances, arrays do things a little differently from the norm. If you call puts on an array, you get a cyclical representation based on calling to_s on each of the elements in the array and outputting one per line. That’s a special behavior; it doesn’t correspond to what you get when you call to_s on an array—namely, a string representation of the array in square brackets.
array在产生string格式输出时会有所不同。 对一个array使用to_s会单独把每一个元素拿出来，一个一行地印出。

**Born to be overridden: inspect**

Every Ruby object—once again, with the exception of instances of BasicObject—has an inspect method. By default—unless a given class overrides inspect—the inspect string is a mini-screen-dump of the object’s memory location:

同样的，除了 BasicObject 之外的所有 class 都有 inspect 这个实例方法。默认情况下-除非你重写了他-inspect方法是将对象的内存地址印出。

```ruby
2.5.0 :002 > obj = Object.new
 => #<Object:0x00007f9d650546f0>
2.5.0 :003 > obj.to_s
 => "#<Object:0x00007f9d650546f0>"
2.5.0 :004 > obj.inspect
 => "#<Object:0x00007f9d650546f0>"
2.5.0 :005 >
```

Actually, irb uses inspect on every value it prints out, so you can see the inspect strings of various objects without even explicitly calling inspect:

实际上，irb对每一个印出的值都使用了 inspect， 所以你可以在不呼叫 inspect 的情况下看到不同对象的 inspect string。

If you want a useful inspect string for your classes, you need to define inspect explicitly:

如果你需要定制自己class的inspect string输出，你可以自己定义

```ruby
2.5.0 :007 > class Person
2.5.0 :008?>   def initialize(name)
2.5.0 :009?>     @name = name
2.5.0 :010?>     end
2.5.0 :011?>
2.5.0 :012?>   def inspect
2.5.0 :013?>     @name
2.5.0 :014?>     end
2.5.0 :015?>   end
 => :inspect
2.5.0 :016 >
2.5.0 :017 > david = Person.new("David")
 => David
2.5.0 :018 > puts david.inspect
David
 => nil
2.5.0 :019 > puts david
#<Person:0x00007f9d65022fd8>
 => nil
2.5.0 :020 >
```

(Note that overriding to_s and overriding inspect are two different things. Prior to Ruby 2, inspect piggybacked on to_s, so you could override both by overriding one. That’s no longer the case.)
注意改写 to_s 和改写 inspect 是不一样的两件事。 ruby 2之前， 二者是绑在一起，但现在不是了。

Another, less frequently used, method generates and displays a string representation of an object: display.
另一个不常用的输出string格式的obj的方法是： `display`

You won’t see display much. It occurs only once, at last count, in all the Ruby program files in the entire standard library. (inspect occurs 160 times.) It’s a specialized output method.

`display` takes an argument: a writable output stream, in the form of a Ruby I/O object. By default, it uses STDOUT, the standard output stream:

你很少会见到 `display`，在整个ruby的standard library中，只出现过一次。而 inspect 出现了至少160次。

`display` 接受一个参数： 一个可写的输出流，以 Ruby I/O 对象的形式。默认情况下，他使用 STDOUT ， 标准输出流：

```ruby
2.5.0 :020 > "Hello".display
Hello => nil
2.5.0 :021 >
```

Note that display, unlike puts but like print, doesn’t automatically insert a newline character. That’s why => nil is run together on one line with the output.

You can redirect the output of display by providing, for example, an open file handle as an argument:

`display`更像是 `print` 而不像 puts ， 不会自动插入一个换行符号。这也是为什么上面例子中的结果 => nil 没有单独一行。

你可以通过提供一个打开的文件作为参数来重新定向 `display` 的输出

```ruby
2.5.0 :022 > fh = File.open("./display.out", "w")
 => #<File:./display.out>
2.5.0 :023 > "Hello".display(fh)
 => nil
2.5.0 :024 > fh.close
 => nil
2.5.0 :025 > puts(File.read("./display.out"))
Hello
 => nil
2.5.0 :026 >
```

The string "Hello" is “displayed” directly to the file , as we confirm by reading the contents of the file in and printing them out .

-

**Array conversion with to_a and the * operator**

之前在关于 method 的 parameter 中用到过 星号 * 用来吸收富余的 arguments

对于 array 来说， 星号有类似降维的功用

在一个 array 中，里面的所有 elements 相当于是一个 list, 而 array 两边的 []  只是提供界定范围的作用，星号就有脱去 界定， 留下 裸体list 的效果

```ruby
2.5.0 :001 > array = [1, 2, 3, "one", "two"]
 => [1, 2, 3, "one", "two"]
2.5.0 :002 > array_1 = [array]
 => [[1, 2, 3, "one", "two"]]
2.5.0 :003 > array_2 = [*array]
 => [1, 2, 3, "one", "two"]
```

上面的例子中 原本是 双层 array 的情况在加上 *星号之后 脱掉了一层包裹

这种 裸list 只能在特定 context 下才能存在

在 irb 中不能直接写

```ruby
>> "one", "two"
```

这样会报错

但在某些运行中的情况，list 可以存在，比如在 method() 括号中的参数

```ruby
2.5.0 :006 > def show(one, two)
2.5.0 :007?>   puts one
2.5.0 :008?>   puts two
2.5.0 :009?> end
 => :show
2.5.0 :010 > show "Hello", "World"
Hello
World
 => nil
2.5.0 :011 > "Hello", "World"
Traceback (most recent call last):
        1: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
SyntaxError ((irb):11: syntax error, unexpected ',', expecting end-of-input
"Hello", "World"
       ^)
2.5.0 :012 >
```

上面例子中把 `"Hello", "World"` 这个bare list作为 show 方法的参数传入，程序正常运转，但如果 单独使用就会出错，因为bare list只能在特定背景下才能存在。

下面是一个使用星号的例子

```ruby
2.5.0 :015 > def full_name(first_name, last_name)
2.5.0 :016?>   first_name + " " + last_name
2.5.0 :017?> end
 => :full_name
2.5.0 :018 >
2.5.0 :019 > names = ["David", "Black"]
 => ["David", "Black"]
2.5.0 :020 > puts full_name(*names)
David Black
 => nil
2.5.0 :021 >
```

If you don’t use the unarraying star, you’ll send just one argument—an array—to the method, and the method won’t be happy.

```ruby
2.5.0 :021 > puts full_name(names)
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):21
        1: from (irb):15:in `full_name'
ArgumentError (wrong number of arguments (given 1, expected 2))
2.5.0 :022 >
```

to_i 只会拿 string 最前面的 连续的 整数

如果
整数不在字串开头
或者没有数字
返回 0

```ruby
2.5.0 :002 > "1234a56b789".to_i
 => 1234
2.5.0 :003 > "hello".to_i
 => 0
2.5.0 :004 > "hello123world".to_i
 => 0
2.5.0 :005 >
```

-

to_f 的规则和 to_i 一致

```ruby
2.5.0 :005 > "3.14abc0.618".to_f
 => 3.14
2.5.0 :006 > "abc3.14".to_f
 => 0.0
2.5.0 :007 >
```

负值也一样

```ruby
2.5.0 :008 > "-123abc".to_i
 => -123
2.5.0 :009 > "-123abc".to_f
 => -123.0
2.5.0 :010 >
```

另一种更严格的 转换 method 是 `Integer()` 和 `Float()`

严格之处在于，如果给出的对象里面不是纯数字类型，就会抛出 exception

```ruby
2.5.0 :012 > Float("123abc")
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):12
        1: from (irb):12:in `Float'
ArgumentError (invalid value for Float(): "123abc")
2.5.0 :013 > Integer("123abc")
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):13
        1: from (irb):13:in `Integer'
ArgumentError (invalid value for Integer(): "123abc")
2.5.0 :014 > Integer("123")
 => 123
2.5.0 :015 > Float("123")
 => 123.0
2.5.0 :016 >
```

**Conversion vs. typecasting**

When you call methods like to_s, to_i, and to_f, the result is a new object (or the receiver, if you’re converting it to its own class). It’s not quite the same as typecasting in C and other languages. You’re not using the object as a string or an integer; you’re asking the object to provide a second object that corresponds to its idea of itself (so to speak) in one of those forms.
当使用 `to_s`, `to_i`, `to_f` 这类方法的时候，返回的是一个新的object(除非是to自己所在class)。ruby中的这类转换和 C 语言等的 typecasting 类型浇铸不同。不是在将object变为一个 string或integer；你在让 object 提供一个指定格式的，关于他自身的形式呈现。

```ruby
2.5.0 :018 > str = "string"
 => "string"
2.5.0 :019 > str.object_id
 => 70225471129980
2.5.0 :020 > str.to_s.object_id
 => 70225471129980
2.5.0 :021 >
2.5.0 :022 > num = 123
 => 123
2.5.0 :023 > num.object_id
 => 247
2.5.0 :024 > num.to_s.object_id
 => 70225475726500
2.5.0 :025 >
```

The distinction between conversion and typecasting touches on some important aspects of the heart of Ruby. In a sense, all objects are typecasting themselves constantly. Every time you call a method on an object, you’re asking the object to behave as a particular type. Correspondingly, an object’s “type” is really the aggregate of everything it can do at a particular time.
conversion和typecasting的区别触及到了ruby中最核心的内容。那就是所有的objects都在不断浇铸自己的角色。每一次你对一个object使用一个method,当你都在命令这个object按照特定的类型行动。 相应地，一个object的'type' 是在特定时间点他能做的所有事情的集合。

**Role-playing to_* methods**

It’s somewhat against the grain in Ruby programming to worry much about what class an object belongs to. All that matters is what the object can do—what methods it can execute.
在ruby程式中太关心一个object的class归属是没有必要的。重点应该是object能做什么以及它能执行什么方法。

But in a few cases involving the core classes, strict attention is paid to the class of objects. Don’t think of this as a blueprint for “the Ruby way” of thinking about objects. It’s more like an expediency that bootstraps you into the world of the core objects in such a way that once you get going, you can devote less thought to your objects’ class memberships.
但在少量与core classes相关的案例中，是值得花精力去了解对象的class的。不要认为这是关于objects的ruby式的思考蓝图，他更像是一个权宜的带你进入ruby core的方法，一旦你这么做了，你可以花更少的精力在object的类之间的关系上。

String role-playing with to_str

If you want to print an object, you can define a to_s method for it or use whatever to_s behavior it’s been endowed with by its class. But what if you need an object to be a string?
如果你想改变 to_s 的行为或者背后用到了 to_s 的方法，你可以改写他，但如果你想要一个object '变成一个string'应该怎么做？

The answer is that you define a to_str method for the object. An object’s to_str representation enters the picture when you call a core method that requires that its argument be a string.
方法是你可以为这个object定义一个 `to_str`方法。

The classic example is string addition. Ruby lets you add two strings together, producing a third string:

经典的案例是 string 的相加

```ruby
2.5.0 :002 > "hello" + " world"
 => "hello world"
2.5.0 :003 > "hello" + 100
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):3
        1: from (irb):3:in `+'
TypeError (no implicit conversion of Integer into String)
```

This is where to_str comes in. If an object responds to to_str, its to_str representation will be used when the object is used as the argument to String#+.
如果一个object能够回应 to_str， 那么一个string对象在作为 String#+ 的参数时，就会用到 to_str

Here’s an example involving a simple Person class. The to_str method is a wrapper around the name method:

```ruby
2.5.0 :004 > class Person
2.5.0 :005?>   attr_accessor :name
2.5.0 :006?>   def to_str
2.5.0 :007?>     name
2.5.0 :008?>   end
2.5.0 :009?> end
 => :to_str

# If you create a Person object and add it to a string, to_str kicks in with the name string:

2.5.0 :010 > david = Person.new
 => #<Person:0x00007fa2de09bec8>
2.5.0 :011 > david.name = "David"
 => "David"
2.5.0 :012 > puts "David is named " + david + "."
David is named David.
 => nil
2.5.0 :013 >
```

`+` 后面作为参数的 object 就会用到 to_str 方法

The to_str conversion is also used on arguments to the << (append to string) method. And arrays, like strings, have a role-playing conversion method.”

同样用来增加字符内容的 `<<` 的方法也用到 to_str

```ruby
2.5.0 :013 > david
 => #<Person:0x00007fa2de09bec8 @name="David">
2.5.0 :014 > "david object after << is: " << david
 => "david object after << is: David"
2.5.0 :015 >
```

Array role-playing with to_ary

Objects can masquerade as arrays if they have a to_ary method. If such a method is present, it’s called on the object in cases where an array, and only an array, will do—for example, in an array-concatenation operation.

Here’s another Person implementation, where the array role is played by an array containing three person attributes:

object能够伪装成array如果他有 to_ary 方法。他只会在进行 array 的 concatenate 操作时会用到

![](https://ws2.sinaimg.cn/large/006tNc79ly1fo0zx3e88cj30gt09u0tj.jpg)

```ruby
2.5.0 :001 > class Person
2.5.0 :002?>   attr_accessor :name, :age, :email
2.5.0 :003?>   def to_ary
2.5.0 :004?>     [name, age, email]
2.5.0 :005?>     end
2.5.0 :006?>   end
 => :to_ary
2.5.0 :007 > david = Person.new
 => #<Person:0x00007fe20f00b650>
2.5.0 :008 > david.name = "David"
 => "David"
2.5.0 :009 > david.email = "david@wherever"
 => "david@wherever"
2.5.0 :010 > array = []
 => []
2.5.0 :011 > array.concat(david)
 => ["David", nil, "david@wherever"]
2.5.0 :012 > p array
["David", nil, "david@wherever"]
 => ["David", nil, "david@wherever"]
2.5.0 :013 >
```

**Boolean states, Boolean objects, and nil**

if 空method 返回 true

if 空 class 返回 false

甚至内部 return false 的空 method 都是 true

if 实际的判断依据是 它后面跟的 Expression 的返回值

```ruby
2.5.0 :015 > class MyClass; end
 => nil
2.5.0 :016 > class YourClass; 1; end
 => 1
2.5.0 :017 > def meth1; return false; end
 => :meth1
2.5.0 :018 > def meth2; end
 => :meth2
2.5.0 :019 > puts "string"
string
 => nil
2.5.0 :020 >
```

定义一个 method 最后返回的是一个 :symbol 所以不会是 false

-

true 和 false 语义上是一种状态表述，但在 ruby 中他们仍然是 object

```ruby
2.5.0 :001 > true.class
 => TrueClass
2.5.0 :002 > false.class
 => FalseClass
2.5.0 :003 > TrueClass.ancestors
 => [TrueClass, Object, Kernel, BasicObject]
2.5.0 :004 > FalseClass.ancestors
 => [FalseClass, Object, Kernel, BasicObject]
2.5.0 :005 >
```

作为  object 那么 逻辑上他们就可以被

赋值给变量或者作为参数使用

赋值：

```ruby
2.5.0 :005 > a = true
 => true
2.5.0 :006 > a = 1 unless a
 => nil
2.5.0 :007 > a
 => true
2.5.0 :008 > b = a
 => true
2.5.0 :009 > b
 => true
2.5.0 :010 > a.object_id
 => 20
2.5.0 :011 > b.object_id
 => 20
2.5.0 :012 >
```

作为参数使用

```ruby
2.5.0 :012 > String.instance_methods.size
 => 183
2.5.0 :013 > String.instance_methods(false).size
 => 128
2.5.0 :014 >
```

Module/Class.instance_methods()

默认参数是 include_super = true

意为包含此 module或class 继承或include 自其他 module/class 的 methods

如果给出 false

则只包含自身定义的 methods

http://ruby-doc.org/core-2.5.0/Module.html#method-i-instance_methods

![](https://ws1.sinaimg.cn/large/006tNc79ly1fo10f2u56lj30gg0f70wc.jpg)

**True/false: States vs. values**

As you now know, every Ruby expression is true or false in a Boolean sense (as indicated by the if test), and there are also objects called true and false. This double usage of the true/false terminology is sometimes a source of confusion: when you say that something is true, it’s not always clear whether you mean it has a Boolean truth value or that it’s the object true.
Remember that every expression has a Boolean value—including the expression true and the expression false. It may seem awkward to have to say, “The object true is true.” But that extra step makes it possible for the model to work consistently.

除了 false 和 nil 或者 返回值是 false 和 nil 的 expression 其他情况都是 true

**The special object nil**

The special object nil is, indeed, an object (it’s the only instance of a class called NilClass). But in practice, it’s also a kind of nonobject. The Boolean value of nil is false, but that’s just the start of its nonobjectness.
nil是一个特殊的对象，它是 NilClass 的唯一实例。但实际应用中，他又更像'无对象'。 nil 的 boolean 值是 false ，但这只是他的无对象性的开始。

nil denotes an absence of anything. You can see this graphically when you inquire into the value of, for example, an instance variable you haven’t initialized:
nil 代表着缺少了什么东西。 你可以通过印出一个没出现过的 instance variable 的值来直观感受：

```ruby
2.5.0 :016 > @x
 => nil
2.5.0 :017 > puts @x

 => nil
2.5.0 :018 >
```

This command prints nil. (If you try this with a local variable, you’ll get an error; local variables aren’t automatically initialized to anything, not even nil.) nil is also the default value for nonexistent elements of container and collection objects. For example, if you create an array with three elements, and then you try to access the tenth element (at index 9, because array indexing starts at 0), you’ll find that it’s nil:
印出 `nil` 的结果是一个空行。 nil 是那些未初始化的 container 和 collection 类的对象中的不存在的元素的默认值。

```ruby
2.5.0 :021 > [1,2,3][9]
 => nil
2.5.0 :022 >
```

nil is sometimes a difficult object to understand. It’s all about absence and nonexistence; but nil does exist, and it responds to method calls like other objects:

nil 有时是一个难以理解的对象，他的所有只关于不存在以及缺少；但nil对象又是实际存在的，他也可以当做 receiver

```ruby
2.5.0 :029 > nil.class
 => NilClass
2.5.0 :030 > nil.to_s
 => ""
2.5.0 :031 > nil.to_i
 => 0
2.5.0 :032 > nil.object_id
 => 8
2.5.0 :033 >
```

It’s not accurate to say that nil is empty, because doing so would imply that it has characteristics and dimension, like a number or a collection, which it isn’t supposed to. Trying to grasp nil can take you into some thorny philosophical territory. You can think of nil as an object that exists and that comes equipped with a survival kit of methods but that serves the purpose of representing absence and a state of being undetermined.

说nil是空的并不准确，因为这么说好像在暗示 nil 有特征和维度，就像一个数字或collection那样，但它不是。 尝试理解 nil 的内含会把你带入某些艰深的哲学话题。 nil只是代表缺席以及未定状态。

**Comparing two objects**

Ruby objects are created with the capacity to compare themselves to other objects for equality and/or order, using any of several methods. Tests for equality are the most common comparison tests, and we’ll start with them. We’ll then look at a built-in Ruby module called Comparable, which gives you a quick way to impart knowledge of comparison operations to your classes and objects, and that is used for that purpose by a number of built-in Ruby classes.

Ruby 对象生来就有把自己与其他对象就进行 等同 对比的功能，对应的有几个methods。 等同对比是最常见比较测试，先看这个，接着会了解ruby内建的 module Comparable , 引入这个module 可以让你的class获得对实例之间进行比较的功能， 这也是很多内建 classes 使用这个module的原因。


`==`, `.eql?`,  `.equal?`

都是用来比较 object 的

但是他们之间有一定区别

![](https://ws3.sinaimg.cn/large/006tNc79ly1fo11zgw3hoj30gc0gqq8o.jpg)


在 object 层级谈这个 3 个 methods

他们都用来对比两个 object 是否是相同的 object (注意不是他们的content)

```ruby
2.5.0 :001 > one = Object.new
 => #<Object:0x00007fdfcb019d40>
2.5.0 :002 > two = one.dup
 => #<Object:0x00007fdfcb032778>
2.5.0 :003 > one == two
 => false
2.5.0 :004 > one.eql?(two)
 => false
2.5.0 :005 > one.equal?(two)
 => false
2.5.0 :006 >
```

如果两个 object 的 object_id 不同，他们他们就是不同的 object

三个 方法 都返回 false

但在 object 的 subclasses 中， == 和 eql?() 被 overridden 用来比较其他内容，比如 string 的内容， hash 中两个 key 对应的值等

其中有个例外是对于 numerical class

1 == 1.0 是 true

1.eql?(1.0) 是 false

但是

对于 `equal?()` 来说，从 Object 这一级开始，他的含义是不变了，就是判断两个 object 是否是同一个东西，即使是在 Object 的 subclasses 中


—

All Ruby numerical classes include Comparable and have a definition for <=>. The same is true of the String class; you can compare strings using the full assortment of Comparable method/operators. Comparable is a handy tool, giving you a lot of functionality in return for, essentially, one method definition.

ruby 中所有 数字类型的 class 都 include 了 Comparable 这个 module，而且定义了 `<=>` 方法。包括 String 也这么做了，你可以使用 Comparable 中的各种工具来比较string对象。 Comparable 是一个顺手的工具，你只需要顶一个method就可以得到许多可用的功能。

http://ruby-doc.org/core-2.5.0/Comparable.html

 Comparable uses`<=>`to implement the conventional comparison operators (<, <=, ==, >=, and >) and the method between?.
Comparable 中使用 `<=>` 来实现传统的 大于 小于 等于 大于等于 小于等于 这些比较方法

如果需要让自己自定义的 class 中的 object 可以使用 Comparable 中的比较 methods

先要 `include Comparable`

然后 定义好 `<=>`

第二步可以一次设置好多个 methods  (<, <=, ==, >=, and >)

这步的作用是要告诉 ruby 当你在比较这个 class 中的 instances 时， 你比较的具体内容是什么？一个 instance 可以有多个 attributes 也就有多个 可以比较的方面

```ruby
2.5.0 :006 > class MyClass; end
 => nil
2.5.0 :007 > one = MyClass.new
 => #<MyClass:0x00007fdfcc85fdc8>
2.5.0 :008 > two = MyClass.new
 => #<MyClass:0x00007fdfcc828260>
2.5.0 :009 > one == two
 => false
2.5.0 :010 > one > two
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):10
NoMethodError (undefined method `>' for #<MyClass:0x00007fdfcc85fdc8>)
2.5.0 :011 >
```

当你的 class 中没有 include Comparable 时
使用 == 实际是在 Object 层级比较两个 objects 是否是同一个object

但使用 < 时则会出现 undefined method 报错

如果仅仅 `include Comparable` 但是没有定义 `<=>`

则会报错  ArgumentError

```ruby
2.5.0 :013 > class MyClass
2.5.0 :014?>   include Comparable
2.5.0 :015?> end
 => MyClass
2.5.0 :016 > one = MyClass.new
 => #<MyClass:0x00007fdfcb05a8e0>
2.5.0 :017 > two = MyClass.new
 => #<MyClass:0x00007fdfcb040378>
2.5.0 :018 > one.eql? two
 => false
2.5.0 :019 > one > two
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):19
        1: from (irb):19:in `>'
ArgumentError (comparison of MyClass with MyClass failed)
2.5.0 :020 >
```

The comparison method <=> (usually called the spaceship operator or spaceship method) is the heart of the matter. Inside this method, you define what you mean by less than, equal to, and greater than. Once you’ve done that, Ruby has all it needs to provide the corresponding comparison methods.
`<=>` 方法是达成这件事的核心。 在这个方法内部，你要表面什么是大于，什么是等于，什么是小于，比较的两方具体是什么东西。 一旦你完成这件事，ruby 就会提供一整套的比较方法。

For example, let’s say you’re taking bids on a job and using a Ruby script to help you keep track of what bids have come in. You decide it would be handy to be able to compare any two Bid objects, based on an estimate attribute, using simple comparison operators like > and <. Greater than means asking for more money, and less than means asking for less money.
比如说你在对一项工作招标，使用ruby脚本来帮助你最终新到的投标。 你有一个 Bid 类，然后基于实例的 estimate 属性对两个 bid 对象进行对比。大于说明投标价更高。小于则反之。

```ruby
class Bid
  include Comparable
  attr_accessor :estimate
  def <=>(other)
    if self.estimate < other.estimate
      -1
    elsif self.estimate > other.estimate
      1
    else
      0
    end
  end
end
```

The spaceship method  consists of a cascading if/elsif/else statement. Depending on which branch is executed, the method returns a negative number (by convention, –1), a positive number (by convention, 1), or 0. Those three return values are predefined, prearranged signals to Ruby. Your <=> method must return one of those three values every time it’s called—and they always mean less than, equal to, and greater than, respectively.
`<=>` 方法由一整套的 if/elsif/else 分支构成。三个分支分别会返回 -1, 0, 1。这三个值是被预先定义好含义的，对应三种比较情况。

You can shorten this method. Bid estimates are either floating-point numbers or integers (the latter, if you don’t bother with the cents parts of the figure or if you store the amounts as cents rather than dollars). Numbers already know how to compare themselves to each other, including integers to floats. Bid’s <=> method can therefore piggyback on the existing <=> methods of the Integer and Float classes, like this:
你可以简化这个方法，estimate 属性可能是整数或者浮点数。那么数字类型的值是已经知道怎么进行比较的了，所以数字类型的比较只需要：

```ruby
def <=>(other)
  self.estimate <=> other.estimate
end
```

The payoff for defining the spaceship operator and including Comparable is that you can from then on use the whole set of comparison methods on pairs of your objects. In this example, bid1 wins the contract; it’s less than (as determined by <) bid2:

作为include Comparable 和 def <=> 的回报，我们得到了一整套的比较方法：

```ruby
2.5.0 :001 > load './bid.rb'
 => true
2.5.0 :002 > bid1 = Bid.new
 => #<Bid:0x00007fa935829ac0>
2.5.0 :003 > bid1.estimate = 100
 => 100
2.5.0 :004 > bid2 = Bid.new
 => #<Bid:0x00007fa9351165a8>
2.5.0 :005 > bid2.estimate = 105
 => 105
2.5.0 :006 > bid1 < bid2
 => true
2.5.0 :007 >
```

还有 between?() 方法

```ruby
2.5.0 :007 > bid3 = Bid.new; bid3.estimate = 120
 => 120
2.5.0 :008 > bid2.between?(bid1, bid2)
 => true
2.5.0 :009 >
```
-

**Inspection object capabilities**

The methods you see when you call methods on an object include its singleton methods—those that you’ve written just for this object—as well as any methods it can call by virtue of the inclusion of one or more modules anywhere in its ancestry. All these methods are presented as equals: the listing of methods flattens the method lookup path and only reports on what methods the object knows about, regardless of where they’re defined.

一个object的方法中也包含他的 singleton method

```ruby
2.5.0 :012 > str = "string"
 => "string"
2.5.0 :013 > str.methods.include?(:shout)
 => false
2.5.0 :014 > def str.shout; end
 => :shout
2.5.0 :015 > str.methods.include?(:shout)
 => true
2.5.0 :016 >
```

ruby 直接提供了一个专门用于查看 singelton method 的方法 `singleton_methods`

```ruby
2.5.0 :018 > str.singleton_methods
 => [:shout]
2.5.0 :019 >
```

我们也可以将 :shout 方法写入一个 module 然后让 class String include 这个module ， 那么 所有的 string 对象都会拥有这个 instance method

```ruby
2.5.0 :023 >
2.5.0 :024 > str = "New string"
 => "New string"
2.5.0 :025 > module StringExtras
2.5.0 :026?>   def shout
2.5.0 :027?>     self.upcase + "!!!"
2.5.0 :028?>     end
2.5.0 :029?>   end
 => :shout
2.5.0 :030 > class String
2.5.0 :031?>   include StringExtras
2.5.0 :032?>   end
 => String
2.5.0 :033 > str.methods.include?(:shout)
 => true
2.5.0 :034 >
```

Any object can tell you what methods it knows. In addition, class and module objects can give you information about the methods they provide.

Module 和 class 也是 object 所以也可以对他使用 methods

```ruby
2.5.0 :036 > module Demo
2.5.0 :037?>   def mountain
2.5.0 :038?>     end
2.5.0 :039?>   end
 => :mountain
2.5.0 :040 > Demo.instance_methods
 => [:mountain]
2.5.0 :041 >
```

注意要用 instance methods

虽然 module 不能 instantiated 但是可以包含 instance methods 当然使用 Extend 的时候这些 methods 会变成 class methods

在查询一个对象的方法集合时也是可以传参数的， 传 false 会滤掉那些由继承和include进来的方法。

```ruby
2.5.0 :041 > String.instance_methods.count
 => 184
2.5.0 :042 > String.instance_methods(false).count
 => 128
2.5.0 :043 >
```
-

ruby 也提供简单的查看不同权限类别的 methods 的 方法

![](https://ws4.sinaimg.cn/large/006tNc79gy1fo1cc7j20wj30hb0bqgo3.jpg)

The last of these, public_instance_methods, is a synonym for instance_methods.

`public_instance_methods` 和 `instance_methods` 是同义词

在搜寻一个对象的 methods 之前

想清楚这个对象处于什么层级，他是一个 module / class 还是某个 常规的 object 实例 …

-

**Summary**

In this chapter you’ve seen


- Ruby’s literal constructors
ruby 的字符构建器

- Syntactic sugar converting methods into operators
ruby如何将方法符号化

- “Destructive” methods and bang methods
具有'破坏性'的方法

- Conversion methods (to_s and friends)
转换对象类型的系列方法

- The inspect and display methods
inspect 和 display 方法

- Boolean values and Boolean objects
boolean 值和 Boolean 对象

- The special object nil
一个特殊的对象 nil

- Comparing objects and the Comparable module
ruby中的比较是如何发生的

- Examining an object’s methods
检视一个对象的方法
