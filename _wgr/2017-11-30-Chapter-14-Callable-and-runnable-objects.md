---
title:  "Rubyist-c14-Callable and runnable objects"
categories: [Ruby/Rails ℗]
tags: [Ruby & Rails, Notes of Rubyist]
---

*注：这一系列文章是《The Well-Grounded Rubyist》的学习笔记。*



---

This chapter covers

- Proc objects as anonymous functions  作为匿名函数的 Proc 对象

- The lambda method for generating functions 用来生成函数的 lambda 方法

- Code blocks  { code block }

- The Symbol#to_proc method  Symbol class 中的 to_proc 方法

- Method objects  作为方法的对象

- Bindings 捆绑

- The eval family of methods 方法的 eval 家族

- Threads 线程

- Executing external programs 执行外部程序

![](https://ws4.sinaimg.cn/large/006tNc79gy1foi3whny3nj30bb0cjad1.jpg)

In addition to the basic, bread-and-butter method calls that account for most of what happens in your program, Ruby provides an extensive toolkit for making things happen in a variety of ways. You need two or more parts of your code to run in parallel? Create some Thread objects and run them as needed. Want to choose from among a set of possible functions to execute, and don’t have enough information in advance to write methods for them? Create an array of Proc objects—anonymous functions—and call the one you need. You can even isolate methods as objects, or execute dynamically created strings as code.

除了那些最基本的方法，ruby 提供了一大堆工具来是程序运转起来。 你需要有两部分的代码同时运行？ 可以按照你的需要建立一些 Thread 对象。想要从一系列可能用到的功能中选择一些来使用，但没有足够的时间来为这些组合功能写 methods? 创建一些 Proc 对象 ——匿名函数——然后任你支配使用。你甚至可以把 methods 独立作为对象，或者灵活的把写好的 string 作为代码使用。

This chapter is about objects that you can call, execute, or run: threads, anonymous functions, strings, and even methods that have been turned into objects. We’ll look at all of these constructs along with some auxiliary tools—keywords, variable bindings, code blocks—that make Ruby’s inclusion of callable, runnable objects possible.

Be warned: runnable objects have been at the forefront of difficult and changeable topics in recent versions of Ruby. There’s no getting around the fact that there’s a lot of disagreement about how they should work, and there’s a lot of complexity involved in how they do work. Callable and runnable objects differ from each other, in both syntax and purpose, and grouping them together in one chapter is a bit of an expedient. But it’s also an instructive way to view these objects.

这一章的内容是关于那些你能够 呼叫，执行 或 运行的 对象objects : threads 线程，匿名函数，字串，甚至那些被转换为对象的methods。 了解这些构造我们需要一些辅助工具——keywords, variable , bingidngs ,code blocks ， 这些使得ruby能够包含这些可呼叫可执行的对象。

作为警告：可执行对象的话题是 最近几个版本的ruby 最难也最富争议的话题。这其中很多内容都还存在各方争议，这些内容的使用也涉及到更多的复杂性。 可呼叫 和 可执行 的对象是两个不同的东西，不管是在语法上还是目的上，把他们两个放到一章中讨论有点仓促而不太合时宜, 不过对于了解他们二者来说还是很具启发性的。

-

**Basic anonymous functions: The Proc class**

-

At its most straightforward, the notion of a callable object is embodied in Ruby through objects to which you can send the message call, with the expectation that some code associated with the objects will be executed. The main callable objects in Ruby are Proc objects, lambdas, and method objects.

Proc objects are self-contained code sequences that you can create, store, pass around as method arguments, and, when you wish, execute with the call method. Lambdas are similar to Proc objects. Truth be told, a lambda is a Proc object, but one with slightly special internal engineering. The differences will emerge as we examine each in turn. Method objects represent methods extracted into objects that you can, similarly, store, pass around, and execute.
We’ll start our exploration of callable objects with Proc objects.

最为最直白的解释， ruby 中 callable objects 可呼叫对象的 标志 是 那些你能够 送 "call" 信息给他们的 对象objects， 也就是 使用 call 方法可以触发与这些对象相关的代码的执行。ruby中主要的 可呼叫对象是 Proc 对象， lambdas , 以及 method 对象。

Proc 对象是自身内部包含代码的对象，你可以将 Proc 对象作为参数传递，并在想使用时使用 .call 执行其包含的代码。

lambda 跟Proc 对象类似，实际上一个 lambda 就是一个 Proc 对象，只是内部结构有所不同。后面会提到这些不同。

```ruby
2.5.0 :001 > l = lambda { "a lambda" }
 => #<Proc:0x00007fc8811454c8@(irb):1 (lambda)>
2.5.0 :002 > l.class
 => Proc
```

method objects 代表一类能够被存储，传递，以及执行的对象。

我们会首先介绍 Proc 对象。

-

**Proc objects**

-

Understanding Proc objects thoroughly means being familiar with several things: the basics of creating and using procs; the way procs handle arguments and variable bindings; the role of procs as closures; the relationship between procs and code blocks; and the difference between creating procs with Proc.new, the proc method, the lambda method, and the literal lambda constructor ->. There’s a lot going on here, but it all fits together if you take it one layer at a time.

全面理解 Proc 对象需要知悉这几个方面：

1 创建和使用 procs 对象的基本方法；

2 procs 对象处理变数的方式以及变数的绑定；

3 procs 作为 closures 的角色

4 procs 对象和 code block 之间的关系

5 Proc.new 和 proc， 以及 lambda，还有 " -> " 这几种建立 procs 对象的方法的区别

内容很多，但是如果一次搞清楚一个层面问题也不大。

先来看使用 new 建立 proc 的例子

```ruby
2.5.0 :001 > p = Proc.new { puts "Inside a proc's block." }
 => #<Proc:0x00007fca680736d8@(irb):1>
2.5.0 :002 > p.call
Inside a proc's block.
 => nil
2.5.0 :003 > p.class
 => Proc
2.5.0 :004 >
```

That’s the basic scenario: a code block supplied to a call to Proc.new becomes the body of the Proc object and gets executed when you call that object. Everything else that happens, or that can happen, involves additions to and variations on this theme.
Remember that procs are objects. That means you can assign them to variables, put them inside arrays, send them around as method arguments, and generally treat them as you would any other object. They have knowledge of a chunk of code (the code block they’re created with) and the ability to execute that code when asked to. But they’re still objects.

上面是最基础的场景，建立 proc 时传入的 block 在使用 call 时被执行。其他一切变化都是基于这个基础机制。

记住 procs 是对象objects。 这意味着你可以将他们赋值给变数，将他们放入 array 中，将他们作为method 的参数送出，就如你如何对待其他对象一样。 他们具有接受一个 block 代码段以及用call 呼出执行的功能，但他们仍然是 对象objects。

-

The `proc` method

-

The proc method takes a block and returns a Proc object. Thus you can say proc { puts "Hi!" } instead of Proc.new { puts "Hi!" } and get the same result. Proc.new and proc used to be slightly different from each other, with proc serving as a synonym for lambda (see section 14.2) and the proc/lambda methods producing specialized Proc objects that weren’t quite the same as what Proc.new produced. Yes, it was confusing. But now, although there are still two variants of the Proc object, Proc.new and proc do the same thing, whereas lambda produces the other variant. At least the naming lines up more predictably.

使用 `proc` 方法也可以生成一个新的 proc 对象

```ruby
Proc.new 和 proc 两种方法之间有细微的区别， proc 方法和 lambda 方法是同义词，他们生成的proc 对象和 Proc.new 生成的有所不同。proc 和 lambda 生成的 proc 是 Proc对象的两个变种， 但在这里 Proc.new 和 proc 做的是同样的事，lambda 方法产生出的是另一个变种。

Perhaps the most important aspect of procs to get a handle on is the relation between procs and code blocks. That relation is intimate and turns out to be an important key to further understanding.

对于理解 proc 来说，最核心的是理解 proc 对象和 code block 的关系。

procs and blocks and how they differ

procs 对象和 block 的区别

```ruby
2.5.0 :006 > [1,2,3].each { |x| puts x * 10 }
10
20
30
 => [1, 2, 3]
2.5.0 :007 >
2.5.0 :008 > def call_a_proc(&block)
2.5.0 :009?>   block.call
2.5.0 :010?> end
 => :call_a_proc

2.5.0 :012 > call_a_proc { puts "I am the block or Proc ... or something." }
I am the block or Proc ... or something.
 => nil
2.5.0 :013 >
```

当你建立一个 proc 对象时，你必须要给出一个 block， 但是反过来不是每个 block 都需要依赖于 proc。

第一个例子中使用了一个code block但并没有建立一个proc对象。第二个例子则是一个method捕捉到一个block 然后将其具化为一个proc对象。

我们可以在方法内部使用 block.class 来看下是否有新的proc被生成

```ruby
2.5.0 :020 > def cap_proc(&block)
2.5.0 :021?>   puts block.class
2.5.0 :022?>   block.call
2.5.0 :023?> end
 => :cap_proc
2.5.0 :024 > cap_proc { puts "In a block" }
Proc
In a block
 => nil
2.5.0 :025 >
```

But it’s also possible for a proc to serve in place of the code block in a method call, using a similar special syntax:

我们也可以把一个 proc 对象作为参数传到 method 里

```ruby
2.5.0 :027 > p = Proc.new { |x| puts x.upcase }
 => #<Proc:0x00007fca681058d0@(irb):27>
2.5.0 :028 >
2.5.0 :029 > p
 => #<Proc:0x00007fca681058d0@(irb):27>
2.5.0 :030 >
2.5.0 :031 > %w{David Black}.each(&p)
DAVID
BLACK
 => ["David", "Black"]
2.5.0 :032 >
```

But the question remains: exactly what’s going on with regard to procs and blocks? Why and how does the presence of (&p) convince each that it doesn’t need an actual code block?
To a large extent, the relation between blocks and procs comes down to a matter of syntax versus objects.

但问题是： 这和 procs 与 block 有什么关系？
(&p)的出现为什么就能让 each 方法知道后面不需要跟一个 block 了
从很大程度上讲， blocks 和 procs 之间的区别跟多的是 句法上的区别，而不是 object 层面的区别。

-

**Syntax (blocks) and objects (procs)**

句法与对象

-

An important and often misunderstood fact is that a Ruby code block is not an object. This familiar trivial example has a receiver, a dot operator, a method name, and a code block:

一个常见的误解是认为 code block 不是 object。下面这一小段代码有一个 receiver, 一个`.`操作符，一个method名称，以及一个 code block 。

```ruby
2.5.0 :034 > [1,2,3].each { |x| puts x * 10 }
10
20
30
 => [1, 2, 3]
2.5.0 :035 >
```

这个代码示例中， receiver 是一个array对象， 但 {block} 不是，它只是执行method 的句法中的一个构成部分。

You can put code blocks in context by thinking of the analogy with argument lists. In a method call with arguments
你可以把code block和 argument list 联系起来理解，在一个带argument的方法呼叫中

```
puts c2f(100)
```

the arguments are objects but the argument list itself—the whole (100) thing—isn’t an object. There’s no ArgumentList class, and there’s no CodeBlock class.

当我们使用 puts c2f(200) 时， 包含括号在内的 (200) 是 argument list ， 内部的200是对象，但 argument list 整体并不是一个 object。 没有一个叫 ArgumentList 的 class ，当然也没有一个叫 CodeBlock 的 class.

Things get a little more complex in the case of block syntax than in the case of argument lists, though, because of the way blocks and procs interoperate. An instance of Proc is an object. A code block contains everything that’s needed to create a proc. That’s why Proc.new takes a code block: that’s how it finds out what the proc is supposed to do when it gets called.

但在 block 的语法中事情相对复杂一点，这是由于 block 和 procs 之间的相互配合。 一个 Proc 的实例是一个 object 。一个 code block 中包含创建一个 proc 所需要的所有内容。这也是为什么 Proc.new 接受一个 code block: 这也是为什么 一个proc 在被 call 时知道自己要做什么。

One important implication of the fact that the code block is a syntactic construct and not an object is that code blocks aren’t method arguments. The matter of providing arguments to a method is independent of whether a code block is present, just as the presence of a block is independent of the presence or absence of an argument list. When you provide a code block, you’re not sending the block to the method as an argument; you’re providing a code block, and that’s a thing unto itself. Let’s take another, closer look now at the conversion mechanisms that allow code blocks to be captured as procs, and procs to be pressed into service in place of code blocks.

Code block 是句法结构的一部分这个陈述中的重要隐含意义是：他不是一个 method arguments 。
Method call 中是否跟 block 和 是否传 argument 是两件独立的事。 当你写了一个 code block 并不是将这个 block 作为参数传给了 method，你只是提供了一个 block。让我们看看 code blocks 被捕获为 procs 的机制，以用 procs 替代code block 的方法。

—

Block-proc conversions

—

block 和 proc 之间的 转换

Conversion between blocks and procs is easy—which isn’t too surprising, because the purpose of a code block is to be executed, and a proc is an object whose job is to provide execution access to a previously defined code block. We’ll look first at block-to-proc conversions and then at the use of procs in place of blocks.

二者之间的转换比较简单。因为 block 就是用来执行的，而 proc 是一个可以提供预先定义好的可执行的block的对象。

—

Capturing a code block as a proc

将 code block 捕获为 proc 对象

—

```ruby
2.5.0 :036 > def capture_block(&block)
2.5.0 :037?>   block.call
2.5.0 :038?> end
 => :capture_block
2.5.0 :039 > capture_block { puts "Inside the block." }
Inside the block.
 => nil
2.5.0 :040 >
```

What happens is a kind of implicit call to Proc.new, using the same block. The proc thus created is bound to the parameter block.

Figure 14.1 provides an artist’s rendering of how a code block becomes a proc. The first event (at the bottom of the figure) is the calling of the method capture_block with a code block. Along the way, a new Proc object is created (step 2) using the same block. It’s this Proc object to which the variable block is bound, inside the method body (step 3).

上面的例子是一种 隐含的使用 Proc.new 的方式，使用的还是那个 block ，这样 { block } 就绑给了 capture_block 方法后的参数list 中的 &block。

下面的图提供了一个老手勾画的 code block 如何变成 proc 对象的过程图。

![](https://ws1.sinaimg.cn/large/006tNc79gy1foi936qkk2j30fa07c74n.jpg)

第一个事件是 呼叫 capture_block时  后面跟了一个 block

接下来在第二步会有一个 proc 对象使用 Proc.new 方法被创造出来，使用的就是 之前给出的那个 block

最后第三步，这个 block 也就是绑给 capture_block 参数list中的那个 block 在method内部被 `call`ed

The syntactic element (the code block) thus serves as the basis for the creation of an object. The "phantom" step of creating the proc from the block also explains the need for the special &-based syntax. A method call can include both an argument list and a code block. Without a special flag like &, Ruby has no way of knowing that you want to stop binding parameters to regular arguments and instead perform a block-to-proc conversion and save the results.

作为句法结构一部分的 block 在这种情况下被作为了创造 object 的基础。这种method后直接跟 block 创造出 proc 的方法也解释了为什么要在指代 block 的那个 variable 前加上 & 符号，因为有的方法是 即接受参数也接受block 的，如果不做区分，ruby 无法判别。

```ruby
2.5.0 :041 > def capture_block(block)
2.5.0 :042?>   block.call
2.5.0 :043?>   end
 => :capture_block
2.5.0 :044 >
2.5.0 :045 > capture_block { puts "In a block" }
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):45
        1: from (irb):41:in `capture_block'
ArgumentError (wrong number of arguments (given 0, expected 1))
2.5.0 :046 >
```

The & also makes an appearance when you want to do the conversion the other way: use a Proc object instead of a code block.

当你使用这种方式进行二者之间的转换时 & 符号也会出现：使用 Proc 对象替代 code block

-

**Using procs for blocks**

-

Here’s how you might call capture_block using a proc instead of a code block:

下面就是如果在 执行 capture_block 方式时使用 proc 作为参数传入 而不跟 code block 的示例

The key to using a proc as a block is that you actually use it instead of a block: you send the proc as an argument to the method you’re calling. Just as you tag the parameter in the method definition with the & character to indicate that it should convert the block to a proc, so too you use the & on the method-calling side to indicate that the proc should do the job of a code block.

这里的核心是，可以用 proc 对象来代替一个 block: 将 proc 对象作为参数传给 method ，只不过也要使用 & 符号加在指代proc的那个vairable 前面，注意在将 proc 赋值给 p 时前面是没有 & 符号。但在作为参数传入时需要。

```ruby
2.5.0 :048 > def capture_block(&block)
2.5.0 :049?>   block.call
2.5.0 :050?> end
 => :capture_block
2.5.0 :051 >
2.5.0 :052 > capture_block { puts "Inside a block." }
Inside a block.
 => nil
2.5.0 :053 > p = Proc.new { puts "Inside a block within a proc" }
 => #<Proc:0x00007fca6709f090@(irb):53>
2.5.0 :054 > capture_block(&p)
Inside a block within a proc
 => nil
2.5.0 :055 >
```

当我们把 proc 作为一个参数传入而实际功能是替代 block 时，如果后面再跟一个 block 就会报错

```ruby
2.5.0 :055 > capture_block(&p) { puts "Extra block." }
Traceback (most recent call last):
        1: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
SyntaxError ((irb):55: both block arg and actual block given)
2.5.0 :056 >
```

An interesting subplot is going on here. Like many Ruby operators, the & in &p is a wrapper around a method: namely, the method to_proc. Calling to_proc on a Proc object returns the Proc object itself, rather like calling to_s on a string or to_i on an integer.

一个次要情节是。就像ruby 中的很多 operators ， & 符号是 to_proc 方法的 壳. 我们可以用 &p.to_proc 来代替 &p 。 但对一个 proc 使用 to_proc 返回的是proc自己，而不像对一个 integer 使用 to_s。而且要注意如果to_proc 是用在 arguments list 中也要给指代 proc 的 variable 加上&

```ruby
2.5.0 :058 > capture_block(&p.to_proc)
Inside a block within a proc
 => nil
2.5.0 :059 >
```

-

the proc serves as a regular argument to the method. You aren’t triggering the special behavior whereby a proc argument does the job of a code block.
Thus the & in capture_block(&p) does two things: it triggers a call to p’s to_proc method, and it tells Ruby that the resulting Proc object is serving as a code block stand-in. And because to_proc is a method, it’s possible to use it in a more general way.

这类是 proc 作为常规参数传入的情况，这种情况下我们并没有触发什么特殊的行为，你只是用 作为 argument 的 proc 代替了 block 的工作

capture_block(&p) 实际做了两件事：

1 对 p 使用了 to_proc 方法

2 告诉 ruby 最后 proc 对象会作为 block 来使用。

因为 to_proc 是一个 method , 所以会有更泛化的用途

-

Generalizing to_proc

泛化 to_proc 方法

-

In theory, you can define to_proc in any class or for any object, and the & technique will then work for the affected objects. You probably won’t need to do this a lot; the two classes where to_proc is most useful are Proc (discussed earlier) and Symbol (discussed in the next section), and to_proc behavior is already built into those classes. But looking at how to roll to_proc into your own classes can give you a sense of the dynamic power that lies below the surface of the language.

理论上，你可以在任何一个 class 中(重新)定义 to_proc ，" & " 的技术也可以直接迁移。当然我们不会经常这么做，to_proc 方法最常用到的 classes 是 Proc 和 Symbol。

![](https://ws4.sinaimg.cn/large/006tNc79gy1foj67wd8whj307q06bwev.jpg)

to_proc 的行为也内建在了这两个 classes 当中。不过看下怎么将  to_proc 移植到你自己写的 class 当中能让你对语言背后的灵活性有更好的理解。

```ruby
class Person
  attr_accessor :name

  def self.to_proc
    Proc.new { |person| person.name }
  end

end

d = Person.new
d.name = "David"
m = Person.new
m.name = "Matz"

puts [d,m].map(&Person)
```

输出

```ruby
2.5.0 :001 > load './to_proc.rb'
David
Matz
 => true
```

The best starting point, if you want to follow the trail of breadcrumbs through this code, is the last line . Here, we have an array of two Person objects. We’re doing a map operation on the array. As you know, Array#map takes a code block. In this case, we’re using a Proc object instead. That proc is designated in the argument list as &Person. Of course, Person isn’t a proc; it’s a class. To make sense of what it sees, Ruby asks Person to represent itself as a proc, which means an implicit call to Person’s to_proc method .

That method, in turn, produces a simple Proc object that takes one argument and calls the name method on that argument. Person objects have name attributes . And the Person objects created for purposes of trying out the code, sure enough, have names . All of this means that the mapping of the array of Person objects ([d,m]) will collect the name attributes of the objects, and the entire resulting array will be printed out (thanks to puts).

最后一行开始看， d 和 m 是两个 Person 对象，他们都有 name 这个属性。
[d,m].map 后不用 block 而是传入 &Person 这里由于 & 的出现， ruby 会把 Person 作为proc 对待，也就是对它(Person) 使用 to_proc ， 也就是我们写的 class 层级版本的 self.to_proc。

在 Person 层级的 to_proc 中， Proc.new 后的 block 接受一个 parameter 也就是 [array].map 每次 拿出的那个 Person 对象，然后对这个对象使用 .name 也就是读取他的 name attribute，map的return值是一个新的经过block处理的array，所以

最后加上 puts 方法，印出了两个 对象的 name

这里如果把最后行 argument list 中的 &Person 翻译一下其实也就是

```ruby
puts [d,m].map(&(Proc.new { |person| person.name }))
```

It’s a long way around. And the design is a bit loose; after all, any method that takes a block could use &Person, which might get weird if it involved non-person objects that didn’t have a name method. But the example shows you that to_proc can serve as a powerful conversion hook. And that’s what it does in the Symbol class, as you’ll see next.

这里绕了很大一个圈子，设计上也比较松散； 毕竟，所有能够接受 block 的method 都可以使用 &Person ，因为我们定义好了 Person 的 to_proc， 如果前面的 enumerator 中是与 Person 无关的也没有 name 属性的对象，那么事情就会变得诡异。但是这个例子显示出 to_proc 方法作为转换桥梁的强大力量。在 Symbol class 中，他也是这么做的。

-

Using Symbol#to_proc for conciseness

-

to_proc 在Symbol 中的用法主要是：

```ruby
2.5.0 :003 > %w{david black}.map(&:capitalize)
 => ["David", "Black"]
2.5.0 :004 >
```

:capitalize 会作为 message 依次送给 array 中的元素，上面的代码我们也可以这么写

```ruby
2.5.0 :006 > %w{david black}.map { |e| e.capitalize }
 => ["David", "Black"]
2.5.0 :007 >
```

但是前者更简洁。

If you just saw &:capitalize or a similar construct in code, you might think it was cryptic. But knowing how it parses—knowing that :capitalize is a symbol and & is a to_proc trigger—allows you to interpret it correctly and appreciate its expressiveness.

如果你看到 &:method 或者类似的结构，你可能觉得很神秘。不过一旦你明白了怎么解析，事情就很清楚了： :capitalize 是一个 symbol 而 & 是 to_proc 触发器

The Symbol#to_proc situation lends itself nicely to the elimination of parentheses:

Symbol#to_proc 允许后面传 &:method 的时候省略 括号

```ruby

2.5.0 :001 > %w{david black}.map &:capitalize
 => ["David", "Black"]

2.5.0 :002 >

```

By taking off the parentheses, you can make the proc-ified symbol look like it’s in code-block position. There’s no necessity for this, of course, and you should keep in mind that when you use the to_proc & indicator, you’re sending the proc as an argument flagged with & and not providing a literal code block.

Symbol#to_proc is, among other things, a great example of something that Ruby does for you that you could, if you had to, do easily yourself. Here’s how.

通过去掉 括号， map 后面跟的 &:method 看起来似乎应该是用 { } 包裹的，但记住当我们使用 & 这个 to_proc 触发器时，我们是在把 proc 对象作为参数传入并用他替代了 block 的功能，所以不要再在后面使用 curly brace { }

Symbol#to_proc 方法是 ruby 给我们的很顺手的工具之一

回顾一下之前的例子

%w{ David black }.map { |name| name.send(:capitalize) }

%w{ David black }.map { |name| name.capitalize }

%w{ David black }.map(&:capitalize)

%w{ David black }.map &:capitalzie

Normally, you wouldn’t write it that way, because there’s no need to go to the trouble of doing a send if you’re able to call the method using regular dot syntax. But the send-based version points the way to an implementation of Symbol#to_proc. The job of the block in this example is to send the symbol :capitalize to each element of the array. That means the Proc produced by :capitalize#to_proc has to send :capitalize to its argument. Generalizing from this, we can come up with this simple (almost anticlimactic, one might say) implementation of Symbol#to_proc:

通常我们不会使用 .send(:method) 一是因为我们知道要使用的方法的名称，二是我们使用 点号 . 就可以方便的完成，但是使用 send 的例子让我们看到了完整的动作是 把 :method 分别送给每一个对象。理解了上面的过程我们就可以自己造一个简单的 Symbol#to_proc

This method returns a Proc object that takes one argument and sends self (which will be whatever symbol we’re using) to that object.

下面的 to_proc 方法最后会返回一个 Proc对象(Proc.new)， 接受一个参数并把 :symbol 实例对象自己送给这个接受的参数(或说yield到block中的那个对象)

```ruby
class Symbol
  def to_proc
    Proc.new { |obj| obj.send(self) }
  end
end
```

You can try the new implementation in irb. Let’s throw in a greeting from the method so it’s clear that the version being used is the one we’ve just defined:

我们加入一行信息来标记这个自定义的 to_proc

```ruby
class Symbol
  def to_proc
    puts "In the new Symbol#to_proc !"
    Proc.new { |obj| obj.send(self) }
  end
end
```

from the directory to which you’ve saved it, pull it into irb using the –I (include path in load path) flag and the -r (require) flag:

```ruby
⮀ irb --simple-prompt -I. -r sym_to_proc
>> %w{david black}.map(&:capitalize)
In the new Symbol#to_proc !
=> ["David", "Black"]
>>
```

`-I. -r`的意思是 include 并且 require 给出的路径中的文件

You’re under no obligation to use the Symbol#to_proc shortcut (let alone implement it), but it’s useful to know how it works so you can decide when it’s appropriate to use.
One of the most important aspects of Proc objects is their service as closures: anonymous functions that preserve the local variable bindings that are in effect when the procs are created. We’ll look next at how procs operate as closures.”

在遇到上面那些情况时，我们并不需要强迫自己使用 &:method 语法，但是了解怎么用以及它是怎么运作能让我们在选择的时候有坚实的选择依据。

另一个关于 Proc 对象的重要特性是他的 封闭性 closure： 当 proc 对象被建立时，外部的 local variable 是会关联到 匿名函数内部的。

-

Procs as closures

-

我们知道在一个 method 内部使用的 variable 和 method 外部的 variable 即使是同名称，他们之间也是互不影响的。

You’ve also seen that code blocks preserve the variables that were in existence at the time they were created. All code blocks do this:

你也见过在 block 内部使用 local variable 的情况

```ruby
2.5.0 :001 > m = 10
 => 10
2.5.0 :002 > [1,2,3].each { |e| puts e * m }
10
20
30
 => [1, 2, 3]
2.5.0 :003 >
```

但 m 被修改后，block中的m也会被修改

```ruby
2.5.0 :002 > m = 10
 => 10

2.5.0 :004 > p = Proc.new { |x| puts x * m }
 => #<Proc:0x00007fc2f28c7ed8@(irb):4>
2.5.0 :005 > [1,2,3].map &p
10
20
30
 => [nil, nil, nil]

2.5.0 :006 > m = 20
 => 20

2.5.0 :007 > [1,2,3].map &p
20
40
60
 => [nil, nil, nil]
2.5.0 :008 >
```

This behavior becomes significant when the code block serves as the body of a callable object:

当 code block 作为一个 callable object 的主体时 ，这个特性变得十分重要

```ruby
2.5.0 :003 > def multiply_by(m)
2.5.0 :004?>   Proc.new { |x| puts x * m }
2.5.0 :005?> end
 => :multiply_by
2.5.0 :006 > mult = multiply_by(10)
 => #<Proc:0x00007fd80503cac0@(irb):4>
2.5.0 :007 > mult.call(12)
120
 => nil
2.5.0 :008 >
```

In this example, the method multiply_by returns a proc that can be called with any argument but that always multiplies by the number sent as an argument to multiply_by. The variable m, whatever its value, is preserved inside the code block passed to Proc.new and therefore serves as the multiplier every time the Proc object returned from multiply_by is called.

上面的例子中 multiply_by(m) 方法会接受一个参数m，生成一个proc 对象并把 m 一直存在 proc 内部，每一次使用这个方法时都会用到这个预存进去的m

Proc objects put a slightly different spin on scope. When you construct the code block for a call to Proc.new, the local variables you’ve created are still in scope (as with any code block). And those variables remain in scope inside the proc, no matter where or when you call it.

在这一点上 proc 和 code block 的情况是一样的

注意看下面两个 a 的情境

```ruby
def call_some_proc(p)
  a = "irrevelant 'a' in method scope"
  puts a
  p.call
end   

a = "'a' to be used in Proc block"
p = Proc.new { puts a }
p.call
call_some_proc(p)
```

输出

```ruby
2.5.0 :020 > p.call
'a' to be used in Proc block
 => nil
2.5.0 :021 > call_some_proc(p)
irrevelant 'a' in method scope
'a' to be used in Proc block  # p.call inside :call_some_proc
 => nil
```

As in the previous example, there’s an a in the method definition 1 and an a in the outer (calling) scope 3. Inside the method is a call to a proc. The code for that proc, we happen to know, consists of puts a. Notice that when the proc is called from inside the method 2, the a that’s printed out isn’t the a defined in the method; it’s the a from the scope where the proc was originally created:

在定义 call_some_proc(p) 的时候 method 内部有一个 a ， 然在在 method 外部有一个 a 紧跟着在 p 这个 proc 中用到了这个 a ，实际上这个a在生成 Proc.new 时封存在了 proc 对象内部，所以在

p.call 不管在哪里输出的都是 第 7 行那个 a

The Proc object carries its context around with it. Part of that context is a variable called a to which a particular string is assigned. That variable lives on inside the Proc.”

Proc对象带着自己的背景行走，在第7行定义的那个 a 就这样一直 “住” 在了 proc 内部。

这种留存 变数 的特性叫做 closure （闭包，关闭，封闭，等。。。）。创造一个 closure 就像打包一个行李箱：不管你走了多远，打开这个行李箱，里面的东西还是你之前放进去的。 当你打开一个 closure 时，里面的内含物就是你创造这个closure 时放进去的东西。closures 很重要，因为他保存着一个程序的部分运行状态(partial running state of a program)。 当 method 最后返回时一个超出范围的变量可能会带来一些有趣的状况——如果使用closure 你可以将variable 值留存下来并用在后续的计算中。

A piece of code that carries its creation context around with it like this is called a closure. Creating a closure is like packing a suitcase: wherever you open the suitcase, it contains what you put in when you packed it. When you open a closure (by calling it), it contains what you put into it when it was created. Closures are important because they preserve the partial running state of a program. A variable that goes out of scope when a method returns may have something interesting to say later on—and with a closure, you can preserve that variable so it can continue to provide information or calculation results.

The classic closure example is a counter. Here’s a method that returns a closure (a proc with the local variable bindings preserved). The proc serves as a counter; it increments its variable every time it’s called:

经典的 closure 使用案例是 counter 计数器，这里有一个最后会返回一个闭包closure（也就是内部存有 local variable 的 proc ） 的方法。 proc 在这里作为 counter 使用； 每一次呼叫到它时，都会累计一次数值

The logic in the proc involves adding 1 to n ; so the first time the proc is called, it evaluates to 1; the second time to 2; and so forth. Calling make_counter and then calling the proc it returns confirms this: first 1 is printed, and then 2 . But a new counter starts again from 1; the second call to make_counter  generates a new, local n, which gets preserved in a different proc. The difference between the two counters is made clear by the third call to the first counter, which prints 3 . It picks up where it left off, using the n variable that was preserved inside it at the time of its creation.

make_counter 最后的返回值是一个 proc 对象

c = make_counter 实际就是存入了一个 proc 对象

对 c 使用 .call 实际就是在执行一次 proc 内部的 block 也就是 n += 1

但 d = make_counter 这一步生成了一个新的 proc 那么 n 也就不再是之前 c 里面的那个了, 所以这里回到了 1 (23行)

```ruby
def make_counter
  n = 0
  Proc.new { n += 1 }
end

c = make_counter
puts c.call
puts c.call

d = make_counter
puts d.call      # d
puts c.call      # c
```

输出结果是

```ruby
1
2
1
3
```

c 和 d 在刚刚使用 make_counter 时都是一个新的 proc 对象，block内部代码是 `n += 1`

每一次使用 `.call` 代码就执行一次，数字累加1

最后再  call 了一次 c , 仍然在前两次的基础上累加 n ，返回 3

-

Proc parameters and arguments

-

Here’s an instantiation of Proc, with a block that takes one argument:

这里有一个 Proc 实例，跟着一个接受一个参数的block

```ruby
2.5.0 :001 > p = Proc.new { |x| puts "Called with argument #{x}" }
 => #<Proc:0x00007f85b1185450@(irb):1>
2.5.0 :002 > p.call(100)
Called with argument 100
 => nil
2.5.0 :003 > p.call(55)
Called with argument 55
 => nil
2.5.0 :004 >
```

Procs differ from methods, with respect to argument handling, in that they don’t care whether they get the right number of arguments. A one-argument proc, like this

Proc 对象和 method 不同，在处理参数这方面来讲，proc 对象不会验证参数的数量，也就是传入的参数尽量处理，处理不了就返回 nil ， 而不会像 method 那样验证参数的数量

```ruby
2.5.0 :010 > p = Proc.new { |x| p x }
 => #<Proc:0x00007fc2f1894610@(irb):10>
2.5.0 :011 > p.call
nil
 => nil
2.5.0 :012 > p.call(1,2,3,4)
1
 => 1
2.5.0 :013 >
```

-

Creating functions with lambda and “ -> ”

-

Like Proc.new, the lambda method returns a Proc object, using the provided code block as the function body:

跟 Proc.new 一样，lambda 方法可以返回一个 proc 对象，使用给出的 block 作为函数的主体

```ruby
2.5.0 :015 > p = lambda { puts "A lambda" }
 => #<Proc:0x00007fc2f1044b90@(irb):15 (lambda)>
2.5.0 :016 > p.call
A lambda
 => nil
2.5.0 :017 >
```

As the inspect string suggests, the object returned from lambda is of class Proc. But note the (lambda) notation. There’s no Lambda class, but there is a distinct lambda flavor of the Proc class. And lambda-flavored procs are a little different from their vanilla cousins, in three ways.”

注意在 使用这个方法生成的 proc 对象内部的末尾有一个 (lambda) 标记，ruby 中并没有一个叫 Lambda 的 class, 但 Proc class 内部有一个 lambda 调味包。 Lambda 味道的 proc 对象在三个方面有所不同

First, lambdas require explicit creation. Wherever Ruby creates Proc objects implicitly, they’re regular procs and not lambdas. That means chiefly that when you grab a code block in a method, like this

- 首先， lambdas(指lambda 味道的proc) 需要明确的建立步骤。不管 ruby 在什么地方建立了 Proc 对象，他们都是普通的procs对象，不是 lambdas，也就是说当我们通过

`def method(&block)`
的方法在method内部抓到一个 code block 时。 抓到的只是普通的 proc

the Proc object you’ve grabbed is a regular proc, not a lambda.

```ruby
2.5.0 :019 > def cap_proc(&block)
2.5.0 :020?>   puts block.class
2.5.0 :021?>   block.call
2.5.0 :022?> end
 => :cap_proc
2.5.0 :023 >
2.5.0 :024 > cap_proc { puts "I am a block." }
Proc
I am a block.
 => nil
```

- 第二， lambdas 在处理 return 时与 proc 不同。如果 return 出现在 lambda 内部的 block 中，那么 return 之后只会退出 这个 lambda 对象，而不会退出整个 method ； 但如果 return 出现在 proc 内部的block中，会直接完成并退出 method。

Second, lambdas differ from procs in how they treat the return keyword. return inside a lambda triggers an exit from the body of the lambda to the code context immediately containing the lambda. return inside a proc triggers a return from the method in which the proc is being executed. Here’s an illustration of the difference:

```ruby
def return_test
  l = lambda { return }
  l.call
  puts "Still here!"
  p = Proc.new { return }
  p.call
  puts "You will not see this message."
end

return_test
# => Still here
```
Warning

Because return from inside a (non-lambda-flavored) proc triggers a return from the enclosing method, calling a proc that contains return when you’re not inside any method produces a fatal error. To see a demo of this error, try it from the command line: ruby -e 'Proc.new { return }.call’.

注意，由于普通 proc 内的return 会有退出 method 的动作，一个block中包含有 return 的proc如果不在 method 内部context下被 call 到，会报错

而 lambda 版本的则不会

proc对象的情况
```ruby
2.5.0 :026 > p = Proc.new { puts "some"; return }
 => #<Proc:0x00007fc2f1080898@(irb):26>
2.5.0 :027 > p.call
some
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):27
        1: from (irb):26:in `block in irb_binding'
LocalJumpError (unexpected return)
2.5.0 :028 >
```

lambda对象的情况
```ruby
2.5.0 :030 > l = lambda { puts "some"; return }
 => #<Proc:0x00007fc2f10a3230@(irb):30 (lambda)>
2.5.0 :031 > l.call
some
 => nil
2.5.0 :032 >
```

- 第三点不同，也是最重要的，lambda 版本的 proc 不像普通的 proc 他们会验证 参数的数量

```ruby
2.5.0 :034 > l = lambda { |x| p x }
 => #<Proc:0x00007fc2f10ade10@(irb):34 (lambda)>
2.5.0 :035 > l.call(100)
100
 => 100
2.5.0 :036 > l.call(100,200)
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):36
        1: from (irb):34:in `block in irb_binding'
ArgumentError (wrong number of arguments (given 2, expected 1))
2.5.0 :037 > l.call
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):37
        1: from (irb):34:in `block in irb_binding'
ArgumentError (wrong number of arguments (given 0, expected 1))
2.5.0 :038 >
```

lambda 的使用中 参数多了少了都不行

-

The “stabby lambda” constructor,  ->

lambda的箭头构造符

-

The lambda constructor (nicknamed the “stabby lambda”) works like this:

Lambda constructor (lambda 构造符) 昵称是 stabby lambda 是这样工作的

```ruby
2.5.0 :040 > l = -> { puts "Hi, I am stabby." }
 => #<Proc:0x00007fc2f1070308@(irb):40 (lambda)>
2.5.0 :041 > l.call
Hi, I am stabby.
 => nil
2.5.0 :042 >
```

If you want your lambda to take arguments, you need to put your parameters in parentheses after the ->, not in vertical pipes inside the code block

如果你想要 这种方式构建出来的 lambda 接受参数，你需要在箭头后用括号把参数框起来，而不是在 code block 中使用两个竖线

```ruby
2.5.0 :040 > l = -> { puts "Hi, I am stabby." }
 => #<Proc:0x00007fc2f1070308@(irb):40 (lambda)>
2.5.0 :041 > l.call
Hi, I am stabby.
 => nil
2.5.0 :042 > l = ->(x,y) { p x,y }
 => #<Proc:0x00007fc2f2921a28@(irb):42 (lambda)>
2.5.0 :043 > l.call("one", "two")
"one"
"two"
 => ["one", "two"]
2.5.0 :044 > l = -> { |x,y| p x,y }
Traceback (most recent call last):
        1: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
SyntaxError ((irb):44: syntax error, unexpected '|'
l = -> { |x,y| p x,y }
         ^
(irb):44: syntax error, unexpected '|', expecting '='
l = -> { |x,y| p x,y }
             ^)
2.5.0 :045 >
```

A bit of history: the stabby lambda exists in the first place because older versions of Ruby had trouble parsing method-style argument syntax inside the vertical pipes. For example, in Ruby 1.8 you couldn’t use default-argument syntax like this:

一小段历史：-> 这个构造符的出现是因为之前在 旧版本的 ruby 中 ，使用 lamdba 方法构建 proc 时 block 中放 参数的竖线之间无法正常解析一些常规的参数传入格式，比如无法使用 default value

我们现在可以这么做，但在早些版本中就不行
```ruby
2.5.0 :047 > l = lambda { |a, b=1| "This doesn't work in Ruby 1.8 -- syntax error." }
 => #<Proc:0x00007fc2f292cf90@(irb):47 (lambda)>
2.5.0 :048 >
```
想这个格式的参数传入  在1.8版本的 lambda 方法中是会报错的。

The problem was that Ruby didn’t know whether the second pipe was a second delimiter or a bitwise OR operator. The stabby lambda was introduced to make it possible to use full-blown method-style arguments with lambdas:

当时的问题出在 当时的 lambda 方法无法分辨 block 中的 第二根竖线是一个分隔符，还是 半个 OR （逻辑操作符）。于是引进了 -> 来使用括号版本的传参数格式，下面这种句法就可以正确地在 1.8 中完成参数的操作

```ruby
2.5.0 :050 > l = ->(a, b=1) { "This works in 1.8" }
 => #<Proc:0x00007fc2f10d5230@(irb):50 (lambda)>
2.5.0 :051 >
```

Eventually, the parser limitation was overcome; you can now use method-argument syntax, in all its glory, between the vertical pipes in a code block. Strictly speaking, therefore, the stabby lambda is no longer necessary. But it attracted a bit of a following, and you’ll see it used fairly widely.

最终，bug 修复了。lambda 方法后的block 中可以正常使用各种参数格式了，逻辑上 -> 也不再需要了，但它却一直留存了下来。

In practice, the things you call most often in Ruby aren’t procs or lambdas but methods. So far, we’ve viewed the calling of methods as something we do at one level of remove: we send message to objects, and the objects execute the appropriately named method. But it’s possible to handle methods as objects, as you’ll see next.

lambda 和 proc 本质上都是 proc 对象，只不过他们有三点区别：1 lambda 只能通过明确的步骤新建不能再 method call过程中被间接建立。2 二者block中return的行为不同，lambda中只退出block而proc中会直接退出所在method。3 lambda参数验证更加严格

在实践中，其实最长用到的是 method 而不是 lambda 和 proc。到目前为止我们都只是在同一个层级上探寻如何 呼叫一个方法：我们送出 message 给一个 object, 然后 object 进行对应的执行。但我们是可以把 method 当做 object 对待的，这也是后面的内容。

-

**Methods as objects**

-

Methods don’t present themselves as objects until you tell them to. Treating methods as objects involves objectifying them.

Methods 并不以对象身份代表他们自己，除非你告诉他们这么做。把 methods 当做 objects 需要先对象化 objectify 他们。

-

Capturing Method objects

捕获method对象

-

You can get hold of a Method object by using the `method` method with the name of the method as an argument (in string or symbol form):”

你可以通过使用 method 方法来拿到一个 Method 对象，并把你需要 对象化的method名称作为参数(以string 或者 symbol 格式)传入。


At this point, you have a Method object—specifically, a bound Method object: it isn’t the method talk in the abstract, but rather the method talk specifically bound to the object c. If you send a call message to meth, it knows to call itself with c in the role of self:

下面的例子中，我们有了一个 method 对象——具体的说，一个绑定的 method 对象，它不是一个抽象的 talk 方法，更像是 talk 方法绑给了对象 c。使用 call 可以执行 method 对象

```ruby
2.5.0 :001 > class C
2.5.0 :002?>   def talk
2.5.0 :003?>     puts "Method-grabbing test! self is #{self}"
2.5.0 :004?>   end
2.5.0 :005?> end
 => :talk
2.5.0 :006 > c = C.new
 => #<C:0x00007f8906166a98>
2.5.0 :007 > meth = c.method(:talk)
 => #<Method: C#talk>
2.5.0 :008 > meth.call
Method-grabbing test! self is #<C:0x00007f8906166a98>
 => nil
2.5.0 :009 > meth.class
 => Method
2.5.0 :010 >
```

You can also unbind the method from its object and then bind it to another object, as long as that other object is of the same class as the original object (or a subclass):

你也可以从一个 对象上 解绑一个 method 然后绑到另外一个 object 身上， 只要新的object 是原来 class 或者是 原来 class 的 subclass

```ruby
2.5.0 :010 > class D < C
2.5.0 :011?> end
 => nil
2.5.0 :012 > d = D.new
 => #<D:0x00007f8906013ab0>
2.5.0 :013 > unbound = meth.unbind
 => #<UnboundMethod: C#talk>
2.5.0 :014 > meth
 => #<Method: C#talk>
2.5.0 :015 > unbound.bind(d).call
Method-grabbing test! self is #<D:0x00007f8906013ab0>
 => nil
2.5.0 :016 >
```

Here, the output tells you that the method was, indeed, bound to a D object (d) at the time it was executed:

根据上面 self 的输出可以看到 self 是一个 D 的实例对象， method 就是绑在这个对象上的。

`Method-grabbing test! self is #<D:0x007fb589063e48>`

而之前绑在 C 的实例对象上时，self 则是

`Method-grabbing test! self is #<C:0x007fb58915b210>`

To get hold of an unbound method object directly without having to call unbind on a bound method, you can get it from the class rather than from a specific instance of the class using the instance_method method. This single line is equivalent to a method call plus an unbind call:

拿到 未绑定的 method 对象的另一种不使用 unbind 的方法是直接在 class 上使用 instance_method 方法接 方法名称的symbol。

注意拿方法对象使用的是单数形式

```ruby
2.5.0 :018 > unbound_meth = C.instance_method(:talk)
 => #<UnboundMethod: C#talk>
2.5.0 :019 > C.instance_methods.size
 => 59
2.5.0 :020 >
```

-

The rationale(逻辑依据) for methods as objects

-

There’s no doubt that unbinding and binding methods is a specialized technique, and you’re not likely to need more than a reading knowledge of it. But aside from the principle that at least a reading knowledge of anything in Ruby can’t be a bad idea, on some occasions the best answer to a “how to” question is, “With unbound methods.”
Here’s an example. The following question comes up periodically in Ruby forums:

Suppose I’ve got a class hierarchy where a method gets redefined:

毫无疑问 捆绑和解绑method 到 object 上是一个很特殊的技术，特殊到几乎只会读到而不会用到。但在 ruby 中，对任何事情有所了解总没有坏处。在某些情形下回答一个“如何。。。”问题的最好答案会是 “使用解绑的方法”

下面有一个例子，这个话题会周期性地在 ruby 社区中被提起。

Suppose I’ve got a class hierarchy where a method gets redefined:

假设我们有这样一个 class 层级结构, 其中牵涉到 method 的覆盖

```ruby
class A
  def a_method
    puts "Definition in class A."
  end
end

class B < A
  def a_method
    puts "Definition in class B (subclass of A)."
  end
end

class C < B

end
```

现在我们实例化一个 C

```ruby
2.5.0 :003 > c = C.new
 => #<C:0x00007f84d584ca18>
2.5.0 :004 >
```


Is there any way to get that instance of the lowest class to respond to the message (a_method) by executing the version of the method in the class two classes up the chain?

By default, of course, the instance doesn’t do that; it executes the first matching method it finds as it traverses the method search path:

那么有没有可能让 c 对象选择性地执行 继承链条中指定版本的 a_method ? 通常来说是不行的。lookup path 中遇到的第一个`a_method`方法会在 class B 中，所以直接使用也就会用到这个版本

```ruby
2.5.0 :004 > c.a_method
Definition in class B (subclass of A).
 => nil
2.5.0 :005 >
```

但是使用解绑和绑定技术就可以实现版本跳跃

```ruby
2.5.0 :007 > A.instance_method(:a_method).bind(c).call
Definition in class A.
 => nil
2.5.0 :008 > c.a_method
Definition in class B (subclass of A).
 => nil
2.5.0 :009 >
```

这样就执行到了 A 中定义的 a_method

也可以直接在 C 里写一个方法来直接呼叫 A 中的 :a_method

```ruby
class A
  def a_method
    puts "Definition in class A."
  end
end

class B < A
  def a_method
    puts "Definition in class B (subclass of A)."
  end
end

class C < B
  def call_original
    A.instance_method(:a_method).bind(self).call
  end
end
```

This is an example of a Ruby technique with a paradoxical status: it’s within the realm of things you should understand, as someone gaining mastery of Ruby’s dynamics, but it’s outside the realm of anything you should probably do. If you find yourself coercing Ruby objects to respond to methods you’ve already redefined, you should review the design of your program and find a way to get objects to do what you want as a result of and not in spite of the class/module hierarchy you’ve created.
Still, methods are callable objects, and they can be detached (unbound) from their instances. As a Ruby dynamics inductee, you should at least have recognition-level knowledge of this kind of operation.

这是ruby技术中一个相对矛盾的点：这部分内容属于你应该知道的，能够增加对ruby灵活性理解的但又几乎不会用到的内容。如果出现上面示例中出现的那种情况，你已经搭建好了 class 层级，但是你在某些场景下想要用到特定 class 中的某个同名方法，这时使用 绑定和解绑 method 方式更为恰当，因为如果你在这个阶段再去修改 class 层级结构，会动到太多的东西。

当然，methods 可以是 callable objects， 他们也能独立于他们的 instances 实例。作为 对ruby灵活性的基本了解，你至少有应该能够识别这类操作。

We’ll linger in the dynamic stratosphere for a while, looking next at the eval family of methods: a small handful of methods with special powers to let you run strings as code and manipulate scope and self in some interesting, use-case-driven ways.

我们还会在 灵活性 这个话题中逗留一段时间，下一步会探讨关于  method 中的 eval family : 一小撮具有特殊能力的，能够让你把 string 当做代码运行和操作，并控制范围，同时也很有趣的 method 方法，这是一种应用驱动型的方式。

-

Alternative techniques for calling callable objects

呼叫 callable 对象的另一种技术

-

目前为止我们只使用过 .call 方法来执行 callable objects ， 但还要其他方法可用。

One is the square-brackets method/operator, which is a synonym for call. You place any arguments inside the brackets:

一个是使用 方括号 [ ] 方法(或说操作符)， 和 .call 是同义词，但 .call(arg) 是参数跟在后面，而使用方括号直接把参数放在方括号里，相当于把 call 和 (arg) 融合在一起：

```ruby
2.5.0 :011 > lam = lambda { |x,y| x * y }
 => #<Proc:0x00007f84d60182d8@(irb):11 (lambda)>
2.5.0 :012 > twelve = lam[3,4]
 => 12
2.5.0 :013 > lam.call(3,4)
 => 12
2.5.0 :014 >
```

如果没有参数，直接使用空的方括号，其实完整的是 `.[]` 这又是ruby给的 syntactic sugar

```ruby
2.5.0 :016 > p = Proc.new { puts "Instead of ... call" }
 => #<Proc:0x00007f84d4953548@(irb):16>
2.5.0 :017 > p[]
Instead of ... call
 => nil
2.5.0 :018 > p.[]
Instead of ... call
 => nil
2.5.0 :019 >
```

另外一种语法是 点号 加 括号 .(arg)

```ruby
2.5.0 :028 > lam.(5,6)
 => 30

 2.5.0 :031 > p.()
 Instead of ... call
  => nil
```

Note the dot before the opening parenthesis. The () method has to be called using a dot; you can’t just append the parentheses to a Proc or Method object the way you would with a method name. If there are no arguments, leave the parentheses empty.

注意点号在括号前面，不能直接在 proc对象后带括号参数，如果没有参数，使用空括号。

-

The eval family of methods

-

Like many languages, Ruby has a facility for executing code stored in the form of strings at runtime. In fact, Ruby has a cluster of techniques to do this, each of which serves a particular purpose but all of which operate on a similar principle: that of saying in the middle of a program, “Whatever code strings you might have read from the program file before starting to execute this program, execute this code string right now.

像许多其他语言一样， Ruby 也可以在程序运行时把 以string格式存储的代码 实际执行。实际上， ruby 有一堆这类技术，每一中技术都有特殊的目的，但所有这些技术都基于一个类似的原则：当程序在运行中时 “开始执行这段程序前不管你在程序文件中读到了什么string格式的代码，都立马执行他们”

The most straightforward method for evaluating a string as code, and also the most dangerous, is the method eval. Other eval-family methods are a little softer, not because they don’t also evaluate strings as code but because that’s not all they do. instance_eval brings about a temporary shift in the value of self, and class_eval (also known by the synonym module_eval) takes you on an ad hoc side trip into the context of a class-definition block. These eval-family methods can operate on strings, but they can also be called with a code block; thus they don’t always operate as bluntly as eval, which executes strings.

最直接的一个把 string 内容作为 代码执行的,也是最危险的方法是 eval。其他 eval谱系的方法更温和一点，倒不是因为他们不把string内容当做 code 而是他们不仅仅只做这一点工作。
instance_eval 会给自身带来一些临时性的转变。
class_eval （也叫 module_eval）会把你带入 class 定义背景中。
这些 eval 谱系的方法都是针对 string 的操作，但是他们也可以跟 block， 这样他们不需要像 eval 方法那样死板，只能执行 string。

-

Executing arbitrary strings as code with eval

使用 `eval` 把任意的string作为代码执行

-

```ruby
2.5.0 :034 > eval("2+2")
 => 4
2.5.0 :035 >
```

最简单的用法是这样。

eval is the answer, or at least one answer, to a number of frequently asked questions, such as, “How do I write a method and give it a name someone types in?” You can do so like this:

如果你想写一个方法，但是方法名称又用户端输入的名称，那么 eval 可以

```ruby
print "Method name: "
m = gets.chomp
eval("def #{m}; puts 'Hi.'; end")
eval(m)
```

第 3 行那里容易明白是在定义方法

第 4 行那里其实 也是执行 stirng —— m 就是双引号包裹方法名称——中的代码，相当于在 irb 中 直接输入了 method name

-

The Binding class and eval-ing code with a binding

-

Ruby has a class called Binding whose instances encapsulate the local variable bindings in effect at a given point in execution.

And a top-level method called binding returns whatever the current binding is.

The most common use of Binding objects is in the position of second argument to eval. If you provide a binding in that position, the string being eval-ed is executed in the context of the given binding. Any local variables used inside the eval string are interpreted in the context of that binding.
Here’s an example. The method use_a_binding takes a Binding object as an argument and uses it as the second argument to a call to eval. The eval operation, therefore, uses the local variable bindings represented by the Binding object:

Ruby 有一个名为 Binding 的 class , 它的 instances 封装了给定执行环境中的本地变量绑定值。

一个叫做 binding 的顶层方法会返回绑定的任何值。

```ruby
2.5.0 :036 > binding
 => #<Binding:0x00007f84d30213e0>
2.5.0 :037 > binding
 => #<Binding:0x00007f84d4946460>
2.5.0 :038 > binding
 => #<Binding:0x00007f84d505b6d8>
2.5.0 :039 >
```

使用 Binding 对象最常用的是作为， eval 方法参数中的第二个值。如果你这么做了，那么 eval 执行 string 中的代码时会以 第二个参数中绑定的值作为参考标准。 任何在 eval 的 string中的 本地变量 将会以第二个绑定值作为解析的基础。

这里有一个例子。 use_a_binding 方法中 eval 第二个参数位置给出了一个 Binding 对象，eval 将会使用以 Binding对象为代表的本地变量。

```ruby
2.5.0 :041 > def use_a_binding(b)
2.5.0 :042?>   eval("puts str", b)
2.5.0 :043?> end
 => :use_a_binding
2.5.0 :044 >
2.5.0 :045 > str = "I am a string in top-level binding."
 => "I am a string in top-level binding."
2.5.0 :046 > use_a_binding(binding)
I am a string in top-level binding.
 => nil
2.5.0 :047 >
```

Ruby doc:

These binding objects can be passed as the second argument of theKernel#eval method, establishing an environment for the evaluation.

作为eval 方法的第二个参数，这些 binding 对象相当于在给 eval 中string 代码建立 指定的运行环境。

The output of this snippet is "I'm a string in top-level binding!". That string is bound to the top-level variable str. Although str isn’t in scope inside the use_a_ binding method, it’s visible to eval thanks to the fact that eval gets a binding argument of the top-level binding, in which str is defined and bound.

Thus the string "puts str", which otherwise would raise an error (because str isn’t defined), can be eval-ed successfully in the context of the given binding.

最后的输出是 str 那个字串。str 是 top-level 中的本地变量， 虽然 str 的作用域不包含在 :use_a_binding 方法内部，但在 执行 :use_a_binding 时 eval 方法穿透了限制，直接从 top level 拿到了变量值。

如果不是这样，:use_a_binding 内部单独执行的 puts str 是会报错的。

eval gives you a lot of power, but it also harbors dangers—in some people’s opinion, enough danger to rule it out as a usable technique.”

Eval 方法很强大，但也有危险性，在有些人看来，这种危险程度严重到可以不把他视作一种有用的技术。


-

The dangers of eval

-

Executing arbitrary strings carries significant danger—especially (though not exclusively) strings that come from users interacting with your program. For example, it would be easy to inject a destructive command, perhaps a system call to `rm –rf /*`, into the previous example.”

执行任意内容的 string 可能带来重大的危险——尤其是执行那些由用户端传来的string 内容。比如说，有人可能输入极具破坏性的代码，比如在 system 层面执行 `rm -rf /*`， 在之前的例子中。

eval can be seductive. It’s about as dynamic as a dynamic programming technique can get: you’re evaluating strings of code that probably didn’t even exist when you wrote the program. Anywhere that Ruby puts up a kind of barrier to absolute, easy manipulation of the state of things during the run of a program, eval seems to offer a way to cut through the red tape and do whatever you want.


eval 方法可以很吸引人。它十分灵活：当你运行程序时，他可以去执行之前跟本没有写在 程序 中的内容。不管ruby 在哪里试图阻止程序的运行， eval 方法都可以提供方法切断这根红线，让你做任何你想做的事。

But as you can see, eval isn’t a panacea. If you’re running eval on a string you’ve written, it’s generally no less secure than running a program file you’ve written. But any time an uncertain, dynamically generated string is involved, the dangers mushroom.

但如你所见到的 eval 并不是万能钥匙。如果你用 eval 方法执行那些你自己写的内容，那么并不存在什么安全性问题，但是如果 string 内容的来源不明确，那么就存在潜在威胁。

实际上我们很难清除掉用户端输入的内容中存在危险的部分。 Ruby 中有个 global variable 叫做 $SAFE, 可以阻挡一些危险行为，比如恶意地文件写入等，但最安全的方法是不使用 eval

其实很容易找到一些高手程序员从来没有使用过 eval 也不打算 eval ， 但最后这还是取决于你。

最后看下更多 eval 谱系的方法，他们可以做一些更加强硬的操作，但他们也有相对缓和的功能，供实际使用。

-

The instance_eval method

-

instance_eval is a specialized cousin of eval. It evaluates the string or code block you give it, changing self to be the receiver of the call to instance_eval:

instance_eval 是 eval 方法的特殊近亲。 他拿到你给出的 string 或 block 后，将self指代变为当前使用 instance_eval 的那个receiver

```ruby
2.5.0 :047 > p self
main
 => main
2.5.0 :048 > a = []
 => []
2.5.0 :049 > a.instance_eval { p self }
[]
 => []
2.5.0 :050 >
```

instance_eval is mostly useful for breaking into what would normally be another object’s private data—particularly instance variables. Here’s how to see the value of an instance variable belonging to any old object (in this case, the instance variable of @x of a C object):”

instance_eval 最有用的突破点是可以读到其他对象的私有数据——尤其是 instance variable。

```ruby
2.5.0 :005 > class C
2.5.0 :006?>   def initialize
2.5.0 :007?>     @x = 1
2.5.0 :008?>   end
2.5.0 :009?> end
 => :initialize
2.5.0 :010 > c = C.new
 => #<C:0x00007fe08b861c58 @x=1>
2.5.0 :011 > c.instance_eval { puts @x }
1
 => nil
2.5.0 :012 >
```

This kind of prying into another object’s state is generally considered impolite; if an object wants you to know something about its state, it provides methods through which you can inquire. Nevertheless, because Ruby dynamics are based on the changing identity of self, it’s not a bad idea for the language to give us a technique for manipulating self directly.

这类刺探其他对象状态的行为往往是不礼貌的；如果 objects 有什么东西是想让你知道的，那么他会定义一些 methods 来让你读取。尽管如此，ruby 还是给了我们一个方法来连接和操作 `self` 指代的对象 。


-

The instance_exec method

-


instance_eval has a close cousin called instance_exec. The difference between the two is that instance_exec can take arguments. Any arguments you pass it will be passed, in turn, to the code block.

instance_exec 则是 instance_eval 的近亲。不同在于 instance_exec 可以接受参数，任何你传入的参数都会送到 block 中。

```ruby
2.5.0 :014 > string = "A sample string"
 => "A sample string"
2.5.0 :015 > string.instance_exec("s") { |arg| self.split(arg) }
 => ["A ", "ample ", "tring"]
2.5.0 :016 >
```

通常我们不会这么做，如果我们知道分隔字符的话。要记住 他们哪个方法接受参数，哪个不接受

也许instance_eval最常用的地方是简化赋值操作的代码。

现在我们有这样一个 class

```ruby
class Person
  def initialize(&block)
    instance_eval(&block)
  end

  def name(name = nil)
    @name ||= name
  end

  def age(age=nil)
    @age ||= age
  end
end
```

那么我们就可以使用下面的代码给实例赋值

```ruby
2.5.0 :002 > david = Person.new do
2.5.0 :003 >   name "David"
2.5.0 :004?>   age 55
2.5.0 :005?> end
 => #<Person:0x00007fc30a0bd220 @name="David", @age=55>
2.5.0 :006 >
```

这里的关键在于 Person 中有 instance_eval 的那一行， 只要是 Person.new 后跟的 block 都会执行到 self 也就是 Person 的实例身上。

这样可以省略掉 写 person = Person.new; person.name = “David”; person.age = 55 这样的代码。

The result is that you can say name "David" instead of person.name = "David". Lots of Rubyists find this kind of miniature DSL (domain-specific language) quite pleasingly compact and elegant.

许多ruby 开发者发现这有点像微型 DSL ，十分紧凑优雅。

instance_eval (and instance_exec) will also happily take a string and evaluate it in the switched self context. However, this technique has the same pitfalls as evaluating strings with eval, and should be used judiciously if at all.

The last member of the eval family of methods is class_eval (synonym: module_eval).

instance_eval 和 instance_exec 方法也可以接受 string 然后作为代码执行，但是也要注意前面提到的安全问题，谨慎。

最后一个 eval 谱系的方法是 class_eval 也叫 module_eval

-

Using class_eval

-

In essence, class_eval puts you inside a class-definition body:

核心的来看， class_eval 方法将你置于 定义 class 的行为中

```ruby
2.5.0 :008 > c = Class.new
 => #<Class:0x00007fc30c032bf0>
2.5.0 :009 > c.class_eval do
2.5.0 :011 >   def some_method
2.5.0 :012?>     puts "Created in class_eval."
2.5.0 :013?>   end
2.5.0 :014?> end
 => :some_method

2.5.0 :016 > c_instance = c.new
 => #<#<Class:0x00007fc30c032bf0>:0x00007fc30a112a68>
2.5.0 :017 > c_instance.some_method
Created in class_eval.
 => nil
 ```

But you can do some things with class_eval that you can’t do with the regular class keyword:

Evaluate a string in a class-definition context
Open the class definition of an anonymous class
Use existing local variables inside a class-definition body

The third item on this list is particularly noteworthy.

但 class_eval 可以做一些使用 class 关键词不能做的事

- 使用 string 定义一个 class

- 打开一个匿名的class

- 在定义class时使用一个已经存在的本地变量 (因为class_eval 用到的是一个 block)

第三个用途尤其值得重视

When you open a class with the class keyword, you start a new local-variable scope. But the block you use with class_eval can see the variables created in the scope surrounding it. Look at
the difference between the treatment of var, an outer-scope local variable, in a regular class-definition body and a block given to class_eval:

当我们使用 class 关键词打开一个 class 时，就开启了一个新的本地变量的域。但是使用 class_eval 就可以把当前域中的变量拿来用。来看看一个本地变量 var 在不同方法中的行为区别

这是常规的方法，尝试在 C 内部拿到 外面定义的 var 变量

```ruby
2.5.0 :020 > var = "initialized variable"
 => "initialized variable"
2.5.0 :021 > class C
2.5.0 :022?>   puts var
2.5.0 :023?>   end
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):21
        1: from (irb):22:in `<class:C>'
NameError (undefined local variable or method `var' for C:Class)
2.5.0 :024 >
```

这是使用 class_eval 的结果

```ruby
2.5.0 :025 > C.class_eval do
2.5.0 :026 >     puts var
2.5.0 :027?>   end
initialized variable
 => nil
```

上面的方法相对于只是在 class C 内部环境中执行 puts var ， 但是如果是在 block 中 的method definition body中使用 var 就报错了

```ruby
2.5.0 :028 > C.class_eval do
2.5.0 :029 >   def talk
2.5.0 :030?>     puts var
2.5.0 :031?>   end
2.5.0 :032?> end
 => :talk
2.5.0 :033 > C.new.talk
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):33
        1: from (irb):30:in `talk'
NameError (undefined local variable or method `var' for #<C:0x00007fc30a123d40>)
2.5.0 :034 >
```

Like any def, the def inside the block starts a new scope—so the variable var is no longer visible.

这是因为 {block} 可以看做 C 中的一层域，但是 这层域中的任何 def 又会是一个新的域，所以 var 无法穿透层。

如果你硬要把外面的 variable 塞进去，那么要在 block 中使用另一种定义方法的method 叫 define_method 然后嵌套一个 block

```ruby
2.5.0 :036 > C.class_eval do
2.5.0 :037 >   define_method("talk") do
2.5.0 :038 >     puts var
2.5.0 :039?>   end
2.5.0 :040?> end
 => :talk
2.5.0 :041 > C.new.talk
initialized variable
 => nil
2.5.0 :042 > C.class_eval { define_method("speak") { puts var } }
 => :speak
2.5.0 :043 > C.new.talk
initialized variable
 => nil
2.5.0 :044 >
```

You won’t see techniques like this used as frequently as the standard class- and method-definition techniques. But when you see them, you’ll know that they imply a flattened scope for local variables rather than the new scope triggered by the more common class and def keywords.”

当然很少会看到这么搞的，但是当你看到这样的代码时你会知道 这些本地变量是 来自底层的而不是 class 关键词或 def 开启的新的域中的。

define_method is an instance method of the class Module, so you can call it on any instance of Module or Class. You can thus use it inside a regular class-definition body (where the default receiver self is the class object) if you want to sneak a variable local to the body into an instance method. That’s not a frequently encountered scenario, but it’s not unheard of.
Ruby lets you do lightweight concurrent programming using threads. We’ll look at threads next.

define_method 是一个来自 `class Module` 中的实例方法，所以你能在任何 class 或者 module 中使用。这样你可以把外部域中的变量用在定义 class 内部的方法中。虽然这不常见，但并不是没有出现过。

Ruby 可以用线程实现多个轻量程序的同时运行，这是下面会讲到的内容。

-

Parallel execution with threads

-

Ruby’s threads allow you to do more than one thing at once in your program, through a form of time sharing: one thread executes one or more instructions and then passes control to the next thread, and so forth. Exactly how the simultaneity of threads plays out depends on your system and your Ruby implementation. Ruby will try to use native operating-system threading facilities, but if such facilities aren’t available, it will fall back on green threads (threads implemented completely inside the interpreter). We’ll black-box the green-versus-native thread issue here; our concern will be principally with threading techniques and syntax.

Ruby 的线程让你能够在同一时间运行多个程序，通过时间的共享：一个线程执行一个或多个指令然后将其传递给另一个线程，如此往复。但具体这些线程是如何工作的取决于你的系统和你的ruby 程式。ruby 会尝试使用本地操作系统中的线程功能，但如果这些功能不可用，就会转用 green threads ,也就是 解析器 内部的线程功能。我们将会把关于 green thread 和 native thread 的话题封存起来；主要只关注如何使用线程功能，以及相关的语法。

Creating threads in Ruby is easy: you instantiate the Thread class. A new thread starts executing immediately, but the execution of the code around the thread doesn’t stop. If the program ends while one or more threads are running, those threads are killed.

在 ruby 中新建线程很简单：实例化 Thread class。 一个新的线程即刻开始运行，但是围绕线程的程序并不会终端。当一个或多个线程在运行中时，整个程序中断，这些线程也会终止。

Here’s a kind of inside-out example that will get you started with threads by showing you how they behave when a program ends:

下面是一个内部表面的例子，展示了一些基本的线程行为

```ruby
Thread.new do
  puts "Staring the thread"
  sleep 1
  puts "At the end of the thread"
end

puts "Outside the thread"
```

上面 Thread.new do 和 puts "Outside the thread" 是同时开始运行的

```ruby
Outside the thread
Starting the thread
At the end of the thread
```

如果不使用线程代码从上至下执行， puts "Outside the thread" 会最后印出，但使用线程改变执行时间点， top-level 中是一条线， thread 中是一条线

Thread.new takes a code block, which constitutes the thread’s executable code. In this example, the thread prints a message, sleeps for one second, and then prints another message. But outside of the thread, time marches on: the main body of the program prints a message immediately (it’s not affected by the sleep command inside the thread), and then the program ends. Unless printing a message takes more than a second—in which case you need to get your hardware checked! The second message from the thread will never be seen. You’ll only see this:

Thread.new 接受一个block，作为可执行代码的主体。在这个例子中，这个线程印出了一些字符，停顿了1秒然后又印出一些字符。但在线程之外，时间并没有停止，而是在继续向前，irb（线程之下的）主体 puts 了一行信息，这个信息是即时印出的，不受线程中 sleep 1 的影响。

如果想要完成线程的任务执行，需要用到 join 方法，最简单的方式是将线程对象存入一个 variable 然后对 variable 使用 join 方法。让我们用这种方式来修改上面的代码

```ruby
t = Thread.new do
 puts "Starting the thread"
 sleep 1
 puts "At the end of the thread"
end

puts "Outside the thread"
t.join
```

```ruby
Outside the thread
Starting the thread
At the end of the thread
```

Join 的意思是暂停当前的主线程，让给出的(使用join)线程执行完毕然后继续主线程

这是 ruby doc 中开头对 Thread 的概述

---

Threads are the Ruby implementation for a concurrent programming model.

Programs that require multiple threads of execution are a perfect candidate for Ruby's Thread class.

For example, we can create a new thread separate from the main thread's execution using ::new.

```ruby
thr = Thread.new { puts "Whats the big deal" }
```

Then we are able to pause the execution of the main thread and allow our new thread to finish, using join:

```ruby
thr.join #=> "Whats the big deal"
```

If we don't call thr.join before the main thread terminates, then all other threads including thr will be killed.

Alternatively, you can use an array for handling multiple threads at once, like in the following example:

```ruby
threads = []
threads << Thread.new { puts "Whats the big deal" }
threads << Thread.new { 3.times { puts "Threads are fun!" } }
```

After creating a few threads we wait for them all to finish consecutively.

threads.each { |thr| thr.join }

---


In addition to joining a thread, you can manipulate it in a variety of other ways, including killing it, putting it to sleep, waking it up, and forcing it to pass control to the next thread scheduled for execution.

除了 join 线程，我们还可以终止线程，使其休眠sleep， 唤醒，强制下一个线程开始执行等。

-

Killing , stopping, and starting threads

-

使用 kill ， exit , 或者 terminate 命令都可以终止线程，三个等价。或者，如果你在线程当中，可以直接对 Thread 使用 kill 也就是 class method 层级。

当线程中出现报错时你可能会想终止线程。这里有个例子，虽然有点做作但是足够简单来演示这个过程。从3个文件(part00, p art01, part02)中读取内容到 text 变量中，如果任何一个文件没有被找到，那么终止线程:

现在设定好背景条件，part00文件存在，而 part01 不存在

![](https://ws2.sinaimg.cn/large/006tNc79gy1fokecljosyj309w01pa9y.jpg)

下面是实际运行的代码

当出现错误时，rescue 流将分支引向 Thread.exit

```ruby
puts "Trying to read in some files..."
t = Thread.new do
text = []
  (0..2).each do |n|

    begin
      File.open("part0#{n}") do |f|
        text << f.readlines
      end
      rescue Errno::ENOENT
      puts "Message form thread: Failed on n=#{n}"
      Thread.exit
    end

  end

end

t.join
puts "Finished!"
```

t.join 是为了让线程与 irb 中的运行时间串联，让 线程 完毕后再继续 irb后面的代码

```ruby
⮀ ruby kill_thread.rb
Trying to read in some files...
Message form thread: Failed on n=1
Finished!
```

终止线程的不同命令

```ruby
stop → nil
Stops execution of the current thread, putting it into a “sleep'' state, and schedules execution of another thread.

exit → thr or nil

kill → thr or nil

terminate → thr or nil
Terminates thr and schedules another thread to be run.
If this thread is already marked to be killed, exit returns the Thread.
If this is the main thread, or the last thread, exits the process.
```

-

Fibers: A twist on threads

-

除了 线程，ruby 还有一个 class Fiber。 Fibers 类似指向内部的 code block: 他们可以来回多次地yiled到执行环境中。

一个 fiber 对象可以使用  Fiber.new 来创造，接受一个 block。 在你告诉 fiber 执行 resume 前，不会发生任何事。从 block 内部，你可以挂起 fiber， 使用 Fiber.yield 你可以把控制权交给执行环境。

In addition to threads, Ruby has a Fiber class. Fibers are like reentrant code blocks: they can yield back and forth to their calling context multiple times.

A fiber is created with the Fiber.new constructor, which takes a code block. Nothing happens until you tell the fiber to resume, at which point the code block starts to run. From within the block, you can suspend the fiber, returning control to the calling context, with the class method Fiber.yield.

Here’s a simple example involving a talking fiber that alternates control a couple of times with its calling context:

下面是一个例子，演示控制权如何在 fiber 和 calling context 运行环境之间多次轮换。

```ruby
f = Fiber.new do
 puts "Hi."
 Fiber.yield
 puts "Nice day."
 Fiber.yield
 puts "Bye."
end

f.resume # puts "Hi."

puts "Back to the fiber:"
f.resume # puts "Nice day"

puts "One last message from the fiber:"
f.resume # puts "Bye"

puts "That's all."
```

运行结果

```ruby
⮀ ruby fiber.rb
Hi.
Back to the fiber:
Nice day.
One last message from the fiber:
Bye.
That's all.
```

Among other things, fibers are the technical basis of enumerators, which use fibers to implement their own stop and start operations.

Fibers 是构建 enumerator 的技术基础，用来控制 停止 和 开始的 动作。

```ruby
= Fiber.yield

(from ruby site)
------------------------------------------------------------------------------
  Fiber.yield(args, ...) -> obj

------------------------------------------------------------------------------

Yields control back to the context that resumed the fiber, passing along any
arguments that were passed to it. The fiber will resume processing at this
point when resume is called next. Any arguments passed to the next resume will
be the value that this Fiber.yield expression evaluates to.
```

-

**A threaded date server**

-

The date server we’ll write depends on a Ruby facility that we haven’t looked at yet: TCPServer. TCPServer is a socket-based class that allows you to start up a server almost unbelievably easily: you instantiate the class and pass in a port number. Here’s a simple example of TCPServer in action, serving the current date to the first person who connects to it:

我们将要写的 日期服务器 会依靠一个我们没提到过的 ruby 功能： TCPServer. 这是一个基于接口的 class, 它让你能够简单到不可思议地启动一个服务器： 你初始化这个 class 然后设定一个 port 数值。 这里有个简单的例子，他会提供日期信息给第一个连接到它的人。

![](https://ws3.sinaimg.cn/large/006tNc79gy1fom1t8hse5j30de06iq4u.jpg)

书中给出 telnet 相关库  在2.5.0已经从 standard library 中移除变成了一个 gem。
此部分直接截图原文：

![](https://ws3.sinaimg.cn/large/006tNc79gy1fom1tmnzy5j30de07wgo3.jpg)

![](https://ws2.sinaimg.cn/large/006tNc79gy1fom1tt30wjj30de07ntbt.jpg)

![](https://ws1.sinaimg.cn/large/006tNc79gy1fom1tztk0zj30de07xq6g.jpg)

![](https://ws1.sinaimg.cn/large/006tNc79gy1fom1u51kl2j30de08h412.jpg)

-

Thread and variables

-

Threads run using code blocks, and code blocks can see the variables already created in their local scope. If you create a local variable and change it inside a thread’s code block, the change will be permanent:

线程的运行依赖 block ， block 中可以看到那些已经存在于本地的变量。如果你在线程的 block 中修改了 variable , 那么这种修改会是永久的。

```ruby
2.5.0 :001 > a = 1
 => 1
2.5.0 :002 > Thread.new { a = 2 }
 => #<Thread:0x00007ff892105a30@(irb):2 run>
2.5.0 :003 > a
 => 2
2.5.0 :004 >
```

You can see an interesting and instructive effect if you stop a thread before it changes a variable, and then run the thread:

如果你在一个 thread 修改一个变量之前就终止这个线程，你会看到一些有意思的事情
接上面的例子 a开始等于2

```ruby
2.5.0 :003 > a
 => 2
2.5.0 :004 > t = Thread.new { Thread.stop; a = 3 }
 => #<Thread:0x00007ff8920809e8@(irb):4 run>
2.5.0 :005 > a
 => 2
2.5.0 :006 > t.run
 => #<Thread:0x00007ff8920809e8@(irb):4 dead>
2.5.0 :007 > a
 => 3
2.5.0 :008 >
```

这里block中的 `a=3` 算是 Thread 停止后在 top level 中执行的？

Global variables remain global, for the most part, in the face of threads. That goes for built-in globals, such as $/ (the input record separator), as well as those you create yourself:”

全局变量保持他们的全域特性，在thread 中也是。不管是那些内建的全局变量，比如行分隔符号 $/ 还是其他你自己写的。

```ruby
2.5.0 :002 > $/
 => "\n"
2.5.0 :003 > $var = 1
 => 1
2.5.0 :004 > Thread.new { $/ = "new_line"; $var = 2 }
 => #<Thread:0x00007fdf7798c1b0@(irb):4 run>
2.5.0 :005 > $/
 => "new_line"
2.5.0 :006 > $var
 => 2
2.5.0 :007 >
```

But some globals are thread-local globals—specifically, the $1, $2, ..., $n that are assigned the parenthetical capture values from the most recent regular expression–matching operation. You get a different dose of those variables in every thread. Here’s a snippet that illustrates the fact that the $n variables in different threads don’t collide:

但有些全局变量只对于线程本身具有全域性——具体的说，像 $1, $2 … $n 这些在正则表达式中默认的 capture中匹配结果 赋值的全域变量。 在线程中也有这样的情况，这里有一个例子演示在不同的 thread 中，同名 global variable 不会冲突。

```ruby
2.5.0 :009 > /(abc)/.match("abc")
 => #<MatchData "abc" 1:"abc">
2.5.0 :010 > $1
 => "abc"
2.5.0 :011 > t = Thread.new do
2.5.0 :012 >       /(def)/.match "def"
2.5.0 :013?>       puts "$1 in thread is #{$1}."
2.5.0 :014?>     end.join
$1 in thread is def.
 => #<Thread:0x00007fdf7797efb0@(irb):11 dead>
2.5.0 :015 >
2.5.0 :016 > $1
 => "abc"
2.5.0 :017 >
```

The rationale for this behavior is clear: you can’t have one thread’s idea of $1 overshadowing the $1 from a different thread, or you’ll get extremely odd results. The $n variables aren’t really globals once you see them in the context of the language having threads.

In addition to having access to the usual suite of Ruby variables, threads also have their own variable stash—or, more accurately, a built-in hash that lets them associate symbols or strings with values. These thread keys can be useful.”

上面的例子的基本逻辑很清晰：你不能因为一个线程中存在 $1 而覆盖掉其他线程中的 $1，不然会很乱。$n 类型的变量处于 线程 语境下时，他们并不是绝对全域的。而在 top level 中他们处于同一个背景运行，所以有相互影响。

除了 ruby 中常用的变量类型，线程还有属于他们自身的专有变量——或者更准确地说，一个内建的能让线程和 string/symbol 联系起来的 hash？？？？ 这些 thread keys 很有用

-

**Manipulating thread keys**

-

Thread keys 主要是用来存储线程专有值的 hash。 这些 keys 必须是 string/symbol。 你可以通过使用方括号加 值 句法来取得对应的key ， 也可以拿到 keys 的清单, 使用 .keys 方法。

Thread keys are basically a storage hash for thread-specific values. The keys must be symbols or strings. You can get at the keys by indexing the thread object directly with values in square brackets. You can also get a list of all the keys (without their values) using the keys method.
Here’s a simple set-and-get scenario using a thread key:

下面是一个使用 thread key 来 设置-查询 的模拟状况

```ruby
2.5.0 :001 > t = Thread.new do
2.5.0 :002 >     Thread.current[:message] = "Hello"
2.5.0 :003?>   end
 => #<Thread:0x00007f92e5155d68@(irb):1 run>
2.5.0 :004 > t.join
 => #<Thread:0x00007f92e5155d68@(irb):1 dead>
2.5.0 :005 > p t.keys
[:message]
 => [:message]
2.5.0 :006 > puts t[:message]
Hello
 => nil
```

`current` 返回当前 thread 对象

```ruby
= Thread.current

(from ruby site)
------------------------------------------------------------------------------
  Thread.current   -> thread

------------------------------------------------------------------------------

Returns the currently executing thread.

  Thread.current   #=> #<Thread:0x401bdf4c run>


(END)
```

Threads seem to loom large in games, so let’s use a game example to explore thread keys further: a threaded, networked rock/paper/scissors (RPS) game. We’ll start with the (threadless) RPS logic in an RPS class and use the resulting RPS library as the basis for the game code.

线程常常在游戏中出现，我们用一个游戏相关的例子进一步了解 thread keys :  一个线程化的，相互连接的 石头剪刀布游戏。我们先将基本逻辑放到一个没有线程的 RPS class 中，然后把这个 class 作为库，引用来用作代码的基础部分。

-

A basic rock/paper/scissors logic implementation

The next listing shows the RPS class, which is wrapped in a Games module (because RPS sounds like it might collide with another class name). Save this listing to a file called rps.rb.
Listing 14.3. RPS game logic embodied in Games::RPS class

```ruby
module Games
  class RPS
    include Comparable
    WINS = [%w{rock sicssors}, %{scissors paper}, %w{paper rock}]
    attr_accessor :move

    def initialize(move)
      @move = move.to_s
    end

    def <=>(other)
      if move == other.move
        0
      elsif WINS.include?([move, other.move])
        1
      elsif WINS.include?([other.move, move])
        -1
      else
        raise ArgumentError, "Something wrong!"
      end
    end

    def play_with(other)
      if self > other
        self
      elsif other > self
        other
      else
        false
      end
    end

  end
end
```

每个 新建的 RPS 的实例会包含一个 @move 实例变量，里面存储了这个实例出的是什么
Include Comparable 和 def <=>(arg) 是为了定义两个 RPS实例之间的比较是比的什么
Play 方法中用到的 大于小于逻辑是基于上面写的 spaceship 的定义

Using the RPS class in a threaded game

The following listing shows the networked RPS program. It waits for two people to join, gets their moves, reports the result, and exits. Not glitzy—but a good way to see how thread keys might help you.

下面的代码就是“联网”的对战。他需要等待两个人共同参与，报出他们出的是什么，最后报告结果，退出。 没那么华丽，但是可以很好地演示 thread keys 的用途。

这部分代码用到了 socket ，贴上原文

![](https://ws3.sinaimg.cn/large/006tNc79gy1fonuj79wodj30de07qtcd.jpg)

-

Issuing system commands from inside ruby programs

从ruby 程序内部使用系统层级命令

-

You can issue system commands in several ways in Ruby. We’ll look primarily at two of them: the system method and the `` (backticks) technique. The other ways to communicate with system programs involve somewhat lower-level programming and are more system-dependent and therefore somewhat outside the scope of this book. We’ll take a brief look at them nonetheless, and if they seem to be something you need, you can explore them further.

Ruby 中可以有多种方式使用系统层级的命令。我们主要看两种： system 方法和 ` ` 字符命令。 其他能够与系统进行底层交流的内容超出了本书的讨论范围，我们只会简要的提一下。

-

The system method and backticks

-

The system method calls a system program. Backticks (``) call a system program and return its output. The choice depends on what you want to do.

system 方法可以呼叫一个系统命令，` ` 符号命令呼叫一个命令并返回输出值，使用哪一个具体看你的需要。

Executing system programs with the system method

To use system, send it the name of the program you want to run, with any arguments. The program uses the current STDIN, STDOUT, and STDERR. Here are three simple examples. cat and grep require pressing Ctrl-d (or whatever the “end-of-file” key is on your system) to terminate them and return control to irb. For clarity, Ruby’s output is in bold and user input is in regular font:

把要执行的系统命令以参数形式传给 system( )

```ruby
2.5.0 :008 > system("date")
2018年 2月21日 星期三 10时16分01秒 CST
 => true
2.5.0 :009 > system("cat")
I am trying on the screen for the cat command.    # keyboard input
I am trying on the screen for the cat command.
 => true
2.5.0 :010 > system("grep 'D'")
 => false
2.5.0 :011 > system("grep 'D'")
one                                               # keyboard input
two                                               # keyboard input
David                                             # keyboard input
David
 => true
2.5.0 :012 >
```

When you use system, the global variable $? is set to a Process::Status object that contains information about the call: specifically, the process ID of the process you just ran and its exit status. Here’s a call to date and one to cat, the latter terminated with Ctrl-c. Each is followed by examination of $?:

当你使用 system 方法时， $? 会存储 Process::Status 对象，里面包含了这次呼叫的信息： 具体的有 进程ID，以及退出信息。来看看运行 date 和 cat 时的情况

```ruby
2.5.0 :001 > system("cat")
 => true
2.5.0 :002 > $?
 => #<Process::Status: pid 37986 exit 0>
2.5.0 :003 > system("date")
2018年 2月21日 星期三 10时21分01秒 CST
 => true
2.5.0 :004 > $?
 => #<Process::Status: pid 37987 exit 0>
2.5.0 :005 >
```

下面是运行不存在的 命令

```ruby
2.5.0 :007 > system("datee")
 => nil
2.5.0 :008 > $?
 => #<Process::Status: pid 37988 exit 127>
2.5.0 :009 >
```

`$?` 变量是对 thread 具有本地特性的，如果你在一个线程中呼叫一个系统命令，对应的 $? 变量不会影响另一个线程中的 $? 。

```ruby
2.5.0 :001 > system("date")
2018年 2月21日 星期三 10时22分37秒 CST
 => true
2.5.0 :002 > $?
 => #<Process::Status: pid 38027 exit 0>
2.5.0 :003 > Thread.new { system("datee"); p $? }.join
#<Process::Status: pid 38028 exit 127>
 => #<Thread:0x00007fbdfa010580@(irb):3 dead>
2.5.0 :004 >
2.5.0 :005 > $?
 => #<Process::Status: pid 38027 exit 0>
2.5.0 :006 >
```

第一个基底线程中的 system(“date”)生成的 Process::Status 对象存在了 这个线程中的 $? 变数中，新线程中同样的操作也生成了一个 $? 变量，不过这个变量没有影响之前那个，第二个线程结束后，在基地线程中查看 $? 的值和之前一样。

The Process::Status object reporting on the call to date is stored in $? in the main thread . The new thread makes a call to a nonexistent program , and that thread’s version of $? reflects the problem . But the main thread’s $? is unchanged . The thread-local global variable behavior works much like it does in the case of the $n regular-expression capture variables—and for similar reasons. In both cases, you don’t want one thread reacting to an error condition that it didn’t cause and that doesn’t reflect its actual program flow.

$？ 的特性和 正则表达式中 $n 的情况十分类似。这两种情况中，我们都不想由于变量之间的相互影响，一个线程对不是他引起的错误作出回应，这无法真实反映实际的程序流，也会引起混乱。

-

Calling system programs with backticks

-

To issue a system command with backticks, put the command between backticks. The main difference between system and backticks is that the return value of the backtick call is the output of the program you run:

` ` 和 system 的区别在于，system 最后会return返回 true false nil 等值，但 ` ` return 的值就是运行结果。

```ruby
2.5.0 :008 > d = `date`
 => "2018年 2月21日 星期三 10时24分57秒 CST\n"
2.5.0 :009 > puts d
2018年 2月21日 星期三 10时24分57秒 CST
 => nil
2.5.0 :010 > output = `cat`
I am trying into cat. Since I am using backticks,
I won't see each line echoed back as I type it,
Instead cat's output is going into the
varibale output.
 => "I am trying into cat. Since I am using backticks,\nI won't see each line echoed back as I type it,\nInstead cat's output is going into the\nvaribale output.\n"
2.5.0 :011 > puts output
I am trying into cat. Since I am using backticks,
I won't see each line echoed back as I type it,
Instead cat's output is going into the
varibale output.
 => nil
2.5.0 :012 >
```

System 方法运行不存在的命令会返回 => nil
而 ` ` 则 raise an exception

在关于 $? 方法的表现，二者一致

-

Some system command bells and whistles

There’s yet another way to execute system commands from within Ruby: the %x operator. %x{date}, for example, will execute the date command. Like the backticks, %x returns the string output of the command. Like its relatives %w and %q (among others), %x allows any delimiter, as long as bracket-style delimiters match: %x{date}, %x-date-, and %x(date) are all synonymous.

另一种运行系统命令的方法是使用 %x加分隔符。

```ruby
2.5.0 :013 > %x{date}
 => "2018年 2月21日 星期三 10时27分39秒 CST\n"
2.5.0 :014 > %x-date-
 => "2018年 2月21日 星期三 10时27分50秒 CST\n"
2.5.0 :015 >
```

注意和 %w 这类方法一样，分隔符无所谓是什么，只要成对。

` ` 和 %x 两种方法都可以使用 ruby 解析符号

```ruby
2.5.0 :017 > cmd = "date"
 => "date"
2.5.0 :018 > `#{cmd}`
 => "2018年 2月21日 星期三 10时28分36秒 CST\n"
2.5.0 :019 > %x-#{cmd}-
 => "2018年 2月21日 星期三 10时28分54秒 CST\n"
2.5.0 :020 >
```

Backticks are extremely useful for capturing external program output, but they aren’t the only way to do it. This brings us to the third way of running programs from within a Ruby program: open and Open.popen3.

` ` 符号在捕获外部程序输出时十分有用，但这不是唯一方式。这里有另一个从ruby内部运行程序的方法:

Open 和 Open.popen3

-

Communication with programs via open and popen3

使用 open 和 popen3 与程序进行交流

-

Using the open family of methods to call external programs is a lot more complex than using system and backticks. We’ll look at a few simple examples, but we won’t plumb the depths of the topic. These Ruby methods map directly to the underlying system-library calls that support them, and their exact behavior may vary from one system to another more than most Ruby behavior does.

使用 open 谱系的方法比之前提到的两种复杂得多。我们简单了解不会太深入。这些ruby方法可能与底层的系统库有关，具体行为在不同操作系统之间可能不同。

-

Talking to external programs with open

使用 open 与外部程序交谈

-

You can use the top-level open method to do two-way communication with an external program. Here’s the old standby example of cat:”

你可以使用top-level 的 open 方法与外部程序进行双向的交流。

```ruby
2.5.0 :001 > d = open("|cat", "w+")
 => #<IO:fd 12>
2.5.0 :002 > d.puts "Hello to cat"
 => nil
2.5.0 :003 > d.gets
 => "Hello to cat\n"
2.5.0 :004 > d.close
 => nil
2.5.0 :005 >
```

The call to open is generic; it could be any I/O stream, but in this case it’s a two-way connection to a system command . The pipe in front of the word cat indicates that we’re looking to talk to a program and not open a file. The handle on the external program works much like an I/O socket or file handle. It’s open for reading and writing (the w+ mode), so we can write to it and read from it . Finally, we close it .

注意 open 后括号里的 cat 前有一个 竖线，这告诉计算机，我们不是要在ruby 中进行一个普通的 I/O操作，并不是要以 w+ 模式打开一个叫 cat 的文件。而是在进行一个和系统命令的双向交流，这种对待外部程序的方式和我们在 ruby I/O 操作中的文件操作很像。同样有 w+ 模式，让我们可以写可以读，最后还需要关闭。

也可以使用 block 格式

```ruby
2.5.0 :005 > open("|cat", "w+") { |p| p.puts("Hi"); p.gets }
 => "Hi\n"
2.5.0 :006 >
```

另一个更加强有力的双向交流命令是 Open3.popen3

-

Two-way communication with Open3.popen3

-

The Open3.popen3 method opens communication with an external program and gives you handles on the external program’s standard input, standard output, and standard error streams. You can thus write to and read from those handles separately from the analogous streams in your program.
Here’s a simple cat-based example of Open.popen3:

Open3.popen3 方法处理外部程序的方式让你可以 操作外部程序的 标准输出 输入 以及 错误流。 这样你可以以类似的手法分开处理这些流。

```ruby
2.5.0 :005 > open("|cat", "w+") { |p| p.puts("Hi"); p.gets }
 => "Hi\n"
2.5.0 :006 > require 'open3'
 => true
2.5.0 :007 > stdin, stdout, stderr = Open3.popen3("cat")
 => [#<IO:fd 11>, #<IO:fd 12>, #<IO:fd 14>, #<Process::Waiter:0x00007fe69e90d210 sleep>]
2.5.0 :008 > stdin.puts("Hi.\nBye")
 => nil
2.5.0 :009 > stdout.gets
 => "Hi.\n"
2.5.0 :010 > stdout.gets
 => "Bye\n"
2.5.0 :011 >
```

After loading the open3 library , we make the call to Open3.popen3, passing it the name of the external program . We get back three I/O handles and a thread . (You can ignore the thread.) These I/O handles go into and out of the external program. Thus we can write to the STDIN handle  and read lines from the STDOUT handle . These handles aren’t the same as the STDIN and STDOUT streams of the irb session itself.”

我们将 Open3.popen3 拿到的值分别赋值给三个变量。 拿到3个 I/O 对象和 1个线程，可以不用管这个线程。 这3个对象的流都从外部程序进出。这样就可以从 外部的 STDIN 和 STDOUT 读写。注意这些 STDIN 和 STDOUT 和ruby的 irb 中的是不同的。

The next example shows a slightly more elaborate use of Open.popen3. Be warned: in itself, it’s trivial. Its purpose is to illustrate some of the basic mechanics of the technique—and it uses threads, so it reillustrates some thread techniques too. The following listing shows the code.”

下面是一些更加详尽的用法示例，中间插入了一些线程的内容。

Using Open.popen3 and threads to manipulate a cat session

```ruby
require 'open3'
stdin, stdout, stderr = Open3.popen3("cat")

t = Thread.new do
  loop { stdin.puts gets }      # in
end

u = Thread.new do
  n = 0
  str = ""
  loop do
    str << stdout.gets          # out
    n += 1
    if n % 3 == 0
      puts "---------------\n"
      puts str
      puts "---------------\n"
      str = ""
    end
  end
end

t.join
u.join
```

![](https://ws1.sinaimg.cn/large/006tNc79gy1fonved7atlj30de06o75z.jpg)


The program opens a two-way pipe to cat and uses two threads to talk and listen to that pipe. The first thread, t , loops forever, listening to STDIN—your STDIN, not cat’s—and writing each line to the STDIN handle on the cat process. The second thread, u , maintains a counter (n) and a string accumulator (str). When the counter hits a multiple of 3, as indicated by the modulo test , the u thread prints out a horizontal line, the three text lines it’s accumulated so far, and another horizontal line. It then resets the string accumulator to a blank string and goes back to listening.

这个程序打开了一个双向的 cat命令 管道，使用了两个线程来输入 talk 和 获得 listen 管道传来的内容。

第一个 t 线程永远循环 stdin.puts gets 会将每次从 terminal（系统层面）键入的一行信息存入 stdin
第二个线程u， 内部有一个计数器，每次有新的一行内容 push 到了 str 内，就 +1， 每3次清空一次 str , 注意不管输入的内容是什么都算一行，直接回车也算一行内容。


As stated, we’re not going to go into all the details of Open.popen3. But you can and should keep it in mind for situations where you need the most flexibility in reading from and writing to an external program.

就像我们之前所说我们不会太深入了解 open3 但是要记住他的应用场景，那就是 ruby 程式需要和外部程序进行灵活交流的时候。

-

## Summary

In this chapter you’ve seen


- Proc objects
proc 对象

- The lambda “flavor” of process
特殊的proc对象 lambda

- Code block-to-proc (and reverse) conversion
block 和 proc 对象之间的转换

- Symbol#to_proc
`&:method` 方法简化 block， 以及 to_proc 方法在 Symbol 中的应用

- Method objects
method 对象

- Bindings
捆绑

- eval, instance_eval, and class_eval
三种将 string 作为程序代码执行的方法

- Thread usage and manipulation
线程的使用

- Thread-local “global” variables
线程相关的变数特性

- The system method
在ruby程序内部使用系统层级的命令

- Calling system commands with backticks
使用 `` 符号使用系统命令

- The basics of the open and Open.popen3 facilities
open 和 Open.popen3 功能

Objects in Ruby are products of runtime code execution but can, themselves, have the power to execute code. In this chapter, we’ve looked at a number of ways in which the general notion of callable and runnable objects plays out. We looked at Proc objects and lambdas, the anonymous functions that lie at the heart of Ruby’s block syntax. We also discussed methods as objects and ways of unbinding and binding methods and treating them separately from the objects that call them. The eval family of methods took us into the realm of executing arbitrary strings and also showed some powerful and elegant techniques for runtime manipulation of the program’s object and class landscape, using not only eval but, even more, class_eval and instance_eval with their block-wise operations.
ruby中的对象是代码执行后的产出物，同时他们自己又可以反过来执行某些代码。 在这一章中我们了解了许多 callable 和 runnable 对象。 我们看了 Porc 对象和 lambda ，ruby 最核心的 block 语法中的匿名函数。我们了解了把 method 作为对象并把他们绑定给指定对象的技术。 eval 谱系让我们可以把任意的string内容作为代码执行，同时让我们可以在运行中修改对象和class蓝图，使用 class_eval 和 instance_eval 配合 block

Threads figure prominently among Ruby’s executable objects; every program runs in a main thread even if it spawns no others. We explored the syntax and semantics of threads and saw how they facilitate projects like multiuser networked communication. Finally, we looked at a variety of ways in which Ruby lets you execute external programs, including the relatively simple system method and backtick technique, and the somewhat more granular and complex open and Open.popen3 facilities.
线程在ruby的可执行对象中占有重要位置；每一个程序的执行都会在一个主要的线程当中，及时他是从其他线程中分出来的一支。 我们探索了线程使用的语法和语义，并且看到了如何使用线程让多个user进行联网交互。 最后我们看了几种不同的执行外部程序的方式，比如 `system` 和 '``'技术，以及更加精细一点的 Open.popen3 和 open

There’s no concrete definition of a callable or runnable object, and this chapter has deliberately taken a fairly fluid approach to understanding the terms. On the one hand, that fluidity results in the juxtaposition of topics that could, imaginably, be handled in separate chapters. (It’s hard to argue any direct, close kinship between, say, instance_eval and Open.popen3.) On the other hand, the specifics of Ruby are, to a large extent, manifestations of underlying and supervening principles, and the idea of objects that participate directly in the dynamism of the Ruby landscape is important. Disparate though they may be in some respects, the topics in this chapter all align themselves with that principle; and a good grounding in them will add significantly to your Ruby abilities.
关于 callable 和 runnable objects 并没有一个具体的定义，这一种我们用一种灵活的方式了解了这个术语。 一方面，这种灵活性让他与其他章的内容并列起来，但又可以单独写成一章。另一个方面，从很大程度上讲，Ruby的许多细节显现出了许多底层的原则，以及对对象为核心的思想在ruby的整个图景中是很重要的。 从不同的方面来看，这章中的许多话题都指向整个原则，对这些内容的掌握会很有助于对Ruby的学习。

At this point we’ll turn to our next—and last—major topic: runtime reflection, introspection, and callbacks.
