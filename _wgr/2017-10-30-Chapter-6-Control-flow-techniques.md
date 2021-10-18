---
title:  "Rubyist-c6-Control flow techniques"
categories: [Ruby/Rails ℗]
tags: [Ruby & Rails, Notes of Rubyist]
---

*注：这一系列文章是《The Well-Grounded Rubyist》的学习笔记。*



---

This chapter covers
 
- Conditional execution
条件式执行

- Loops and looping techniques
循环以及循环技术

- Iterators
迭代器

- Exceptions and error handling
例外以及错误处理

Ruby’s control-flow techniques include the following:
ruby的分支流程控制技术包括下面这些：
 
Conditional execution —Execution depends on the truth of an expression.
基于true of false的条件控制

Looping —A single segment of code is executed repeatedly.
循环-重复执行一个代码片段

Iteration —A call to a method is supplemented with a segment of code that the method can call one or more times during its own execution.
迭代过程-对方法的调用会补充一段代码，该方法可以在自己的执行过程中调用一次或多次

Exceptions —Error conditions are handled by special control-flow rules.
例外-对错误情况的特殊流程控制

We’ll look at each of these in turn. They’re all indispensable to both the understanding and the practice of Ruby. The first, conditional execution (if and friends), is a fundamental and straightforward in almost any programming language.
条件式执行几乎是所有编程语言中最基础最直白的一种流程控制技术。

Looping is a more specialized but closely related technique, and Ruby provides you with several ways to do it. When we get to iteration, we’ll be in true Ruby hallmark territory. The technique isn’t unique to Ruby, but it’s a relatively rare programming language feature that figures prominently in Ruby. Finally, we’ll look at Ruby’s extensive mechanism for handling error conditions through exceptions. Exceptions stop the flow of a program, either completely or until the error condition has been dealt with. Exceptions are objects, and you can create your own exception classes, inheriting from the ones built in to Ruby, for specialized handling of error conditions in your programs.
循环是一种更加特殊但也相关的技术，ruby提供了几种完成方式。 当我们进行迭代操作时，就进入了ruby标志性的技术领域。这项技术并不是ruby独有的，但是ruby中极少量的非常重要的组成部分。最后我们会了解ruby的错误处理机制。例外会终止程序流，可能是直接终止也可能继续处理这个例外。 例外也是对象，你可以建立自己的exception类，让他继承自ruby内建的,专门用来处理例外的类。

-

ruby 中的条件式最重要的是两类
	0.	 if 家族
	0.	case 状态机制

—

You can also put an entire if clause on a single line, using the then keyword after the condition:

```ruby
2.5.0 :008 > n = 11
 => 11
2.5.0 :009 > if n > 10 then puts "bigger" end
bigger
 => nil
```

可以使用 if … then 的句法串接一个条件式


if (something is true) then (do something)


—

You can also use semicolons to mimic the line breaks, and to set off the end keyword:

```ruby
if x > 10; puts x; end
```

一个多行的条件式，也可以使用 分号 ; 在一行中完成表达

—

用来测试 否定条件可以使用 not 或 叹号 exclamation !  以及 unless

但要注意句法和 符号优先级

`unless x == 1`

`if not x == 1`  和 `if !(x == 1)` 是正确的

但后一个不能省去括号写成 `!x == 1` , 这样写整个句义都改变了

—

在单独的 否定条件中 ，使用 unless 是容易理解的，但是如果是复合条件，最好不要使用  unless … if 的组合。虽说使用上没有问题，但是更难以理解，应该换用 if … else … 可以达到同样目的的结构，同时更好理解


```ruby

unless x > 100
  puts "Small number"
else
  puts "Big number"
end
```

versus

```ruby
if x <= 100
  puts "Small number"
else
  puts "Big number"
end
```

if 也可以直接跟在一行代码后面

```ruby
puts "That is a big one." if x > 9999
```

这种用法让简短的条件式在一行就表述完成，而不用写成零碎的三行

但这个用法最好不要用在很长的一行代码中，反而会增加阅读难度

-

对于 local variable 的条件赋值，即使在 false 的条件包裹中，某个 local variable 没有赋值成功，但它也会由不存在状态变为存在状态

而不是和 随意命名的一个变数一样 出现 undefined 的情况

```ruby
2.5.0 :002 > if false
2.5.0 :003?>   x = 1
2.5.0 :004?> end
 => nil
2.5.0 :005 > x
 => nil
2.5.0 :006 > y
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):6
NameError (undefined local variable or method `y' for main:Object)
```

上面的 代码中 x 在否定条件下并没有被赋值成功

但是在此叫到时并没有出现 undefined 的情况，而是返回 nil

但是另一个 y 变量从没出现过的则出现 error

不过 x 被赋值为 nil 并不会对程序运行造成任何影响

None of this happens with class, instance, or global variables. All three of those variable types are recognizable by their appearance (@@x, @x, $x). But local variables look just like method calls. Ruby needs to apply some logic at parse time to figure out what’s what, to as great an extent as it can.

You also have to keep your wits about you when using assignment syntax in the test part of a conditional.

但对于 global, class 以及 instance variable 来说情况不同。这几种变量即使没有赋值过，键入了也不会报错，只会返回nil。但是local variable在语法上看起来跟呼叫一个方法是一样的，我们ruby需要在运行时尽最大努力搞清楚什么是什么。

条件式也可以结合 赋值 或者 匹配动作一起使用

单纯的赋值式 放在 if 后面会引起 warning 虽然 程序仍然可以执行。。。

```ruby
2.5.0 :010 > a = 1
 => 1
2.5.0 :011 > if x = 1
2.5.0 :012?>   puts "Using assignment as condition."
2.5.0 :013?>   end
(irb):11: warning: found = in conditional, should be ==
Using assignment as condition.
 => nil
```

通常不太可能出现上面的用法 记住只要 if 后面所放代码最终的返回值不是 nil 或者 false 都会视作 true

当配合 regular expression 时 这种用法可以发挥作用

```ruby
2.5.0 :001 > name = 'caven xu'
 => "caven xu"
2.5.0 :002 > if m = /ve/.match(name)
2.5.0 :003?>   puts "Found it: #{m.inspect}"
2.5.0 :004?> else
2.5.0 :005?>   puts "Found nothing."
2.5.0 :006?> end
Found it: #<MatchData "ve">
 => nil
2.5.0 :007 >
```

-

**Case statements**

A case statement starts with an expression—usually a single object or variable, but any expression can be used—and walks it through a list of possible matches. Each possible match is contained in a when statement consisting of one or more possible matching objects and a segment of code. When one of the terms in a given when clause matches, that when is considered to have "won," and its code segment is executed. Only one match, at most, can win.

case statements are easier to grasp by example than by description. The following listing shows a case statement that tests a line of keyboard input and branches based on its value.

一个case陈述以某个表达开头-通常是一个单独的object会变量，但你可以使用任何表达-接着这个表达会去匹配多个可能的情况。 每一个when后都是一次匹配，包含一个或多个用来进行匹配的对象，以及对应的代码片段。当某个when后的匹配成功时，这里的代码片段就会得到执行。 最多只能有一个`when`胜出。`case` 的用法直接用例子演示更好理解，下面的例子就基于一次键盘输入进行条件判断。


```ruby
print "Exit the program? (yes or no): "
answer = gets.chomp
case answer
when "yes"
  puts "Good-bye!"
  exit
when "no"
  puts "OK, we'll continue"
else
  puts "That's an unknown answer -- assuming you mean 'no'"
  exit
end

puts "Continuing with program......"
```

两次不同输入的结果

```ruby
2.5.0 :001 > load './case.rb'
Exit the program? (yes or no): yes
Good-bye!
⮀ irb
2.5.0 :001 > load './case.rb'
Exit the program? (yes or no): blablabla
That's an unknown answer -- assuming you mean 'no'
⮀
```

You can put more than one possible match in a single when, as this snippet shows:
在 when 后面也可以跟多个 条件，使用逗号隔开，和 or 的作用相同

```ruby
when "Yes", "yes", "Y", "y"
  puts "Continue"
```

The comma between multiple conditions in a when clause is a kind of "or" operator; this code will say "Good-bye!" and exit if answer is either "y" or "yes".

-

**How `when` works**

The basic idea of the case/when structure is that you take an object and cascade through a series of tests for a match, taking action based on the test that succeeds. But what does match mean in this context? What does it mean, in our example, to say that answer matches the word yes, or the word no, or neither?
`case/when` 结构的基本思想是 使用一个对象 然后进行一些列的匹配，然后基于成功的匹配进行后续的行动。在这个语境下`match`是什么含义？

Ruby has a concrete definition of match when it comes to when statements.
Ruby 针对`when`的用法有对`match`明确的定义。

Every Ruby object has a case equality method called === (three equal signs, sometimes called the threequal operator). The outcome of calling the === method determines whether a when clause has matched.
ruby的每一个对象都有一个 case equality 方法叫做 `===` 也叫'three equal signs', 或'threequal operator'。`===` 方法的输出结果决定了一个 `when` 判断是否成功匹配

You can see this clearly if you look first at a case statement and then at a translation of this statement into threequal terms. Look again at the case statement in listing 6.1. Here’s the same thing rewritten to use the threequal operator explicitly:
如果你先看一个 `case` 的用法，然后将其转为 `===` 的表达方式就可以看得很清楚。 还是以之前的那个`case`案例作为演示

```ruby
print "Exit the program? (yes or no): "
answer = gets.chomp
case answer
when "yes"
  puts "Good-bye!"
  exit
when "no"
  puts "OK, we'll continue"
else
  puts "That's an unknown answer -- assuming you mean 'no'"
  exit
end
puts "Continuing with program......"
```

转为 `===` 版本

```ruby
if "yes" === answer
  puts "Good-bye!"
  exit
elsif "no" === answer
  puts "OK, we'll continue"
else
  puts "That's an unknown answer-assuming you meant 'no'"
end
puts "Continuing with program......"
```

实际上 `"yes" === answer` 是加了 syntactic sugar 的版本，完整的是 `"yes".===(answer)`

但ruby 的 syntactic sugar 让我们能够使用更简单的格式

That’s the logic of the syntax. But why does
为什么`"yes" === answer`方法最后返回的会是 true 或者 false 呢？

return true when answer contains "yes"?
为什么不是 answer 中只要包含有完整的 'yes'字串就返回 true 呢？

```ruby
2.5.0 :003 > a = "yessss"
 => "yessss"
2.5.0 :004 > "yes" === a
 => false
```

上面的例子可以看到 `===` 对于字串的比较需要绝对匹配


The method call returns true because of how the threequal method is defined for strings. When you ask a string to threequal itself against another string (string1 === string2), you’re asking it to compare its own contents character by character against the other string and report back true for a perfect match, or false otherwise.

`===`这么工作的原因是因为它是针对String进行的操作。但你对2个string进行`===`操作时，你就是在看他们包含的内容是否绝对完全一致(perfect match)，不是的话就会返回 false

The most important point in this explanation is the phrase “for strings.” Every class (and, in theory, every individual object, although it’s usually handled at the class level) can define its own === method and thus its own case-equality logic. For strings and, indeed, for any object that doesn’t override it, === works the same as == (the basic string-equals-some-other-string test method). But other classes can define the threequal test any way they want.
上面表述中最重要的词语是"for strings"。理论上说，ruby中的每一个class(甚至每一个object)都可以定义自己的 `===`方法。对于 string 以及其他没有重新定义`===`的对象来说，`===` 的含义和 `==` 是一样的。但其他classes事可以重新定义`===`的逻辑的。
![](https://ws3.sinaimg.cn/large/006tKfTcly1fnxow4s1vnj30uc0t4tbe.jpg)

case/when logic is thus really object === other_object logic in disguise; and object === other_object is really object. === (other_object) in disguise. By defining the threequal method however you wish for your own classes, you can exercise complete control over the way your objects behave inside a case statement.

case/when 逻辑就是建立在 `===` 的工作基础之上，通过改写 `===` 的逻辑你可以改变 `case/when` 的用法。

**Programming objects’ case statement behavior**

Let’s say we decide that a Ticket object should match a when clause in a case statement based on its venue. We can bring this about by writing the appropriate threequal method. The following listing shows such a method, bundled with enough ticket functionality to make a complete working example.

假设我们想让`when` 基于 class Ticket 的实例的 `:venue` 这个属性来进行匹配判断。 我们需要在 class Ticket 中改写 `===`。

```ruby
class Ticket
  attr_accessor :venue, :date

  def initialize(venue, date)
    self.venue = venue
    self.date = date
  end

  def ===(other_ticket)
    self.venue == other_ticket.venue
  end
end

t1 = Ticket.new("Town Hall", "12/09")
t2 = Ticket.new("New York", "12/05")
t3 = Ticket.new("Town Hall", "12/01")

puts "case based on #{t1.venue}"

case t1
when t2
  puts "Same location as t2."
when t3
  puts "Same location as t3."
else
  puts "All in different location."
end
```
输出结果

```ruby
2.5.0 :002 > load './tri_equal.rb'
case based on Town Hall
Same location as t3.
 => true
```

The match is found through the implicit use of the === instance method of the Ticket class . Inside the case statement, the first when expression  triggers a hidden call to ===, equivalent to doing this:
上面例子中用到了我们自己在 class Ticket 中写的 `===` 方法， 当我们使用`when`的时候实际触发了 `===` 方法，这相当于是在做:

```ruby
if t1 === t2
```

Because the === method returns true or false based on a comparison of venues, and ticket2’s venue isn’t the same as ticket1’s, the comparison between the two tickets returns false. Therefore, the body of the corresponding when clause isn’t executed.

因为 `===` 方法会基于 venue 值的比较(`==`)结果返回 true/false，由于 t2的venue 和 t1的venue值不一样，所以比较结果会返回false，那么对应的代码片段就不会执行。

This kind of interflow between method definitions (===) and code that doesn’t look like it’s calling methods (case/when) is typical of Ruby. The case/when structure provides an elegant way to perform cascaded conditional tests; and the fact that it’s a bunch of === calls means you can make it do what you need by defining the === method in your classes.
这种看起来并不像在定义方法（`===`）以及并不像是在呼叫方法(case/when)的风格是典型的ruby做派。case/when 结构用优雅的方式完成了层叠的条件测试；而且你可以通过定义自己的 === 来完成不同的操作。

The case statement also comes in a slightly abbreviated form, which lets you test directly for a truth value: case without a case expression.
case 方法还有另一种 缩写格式， 直接基于true进行判断： 在 `case` 后不写任何陈述

**The simple case truth test**

If you start a case statement with the case keyword by itself—that is, with no test expression—followed by some when clauses, the first when clause whose condition is true will be the winner. Assuming an object user with first_name and last_name methods, you could imaginably write a case statement like this:

如果你以单独的 `case` 开头后面什么都不带，那么后面第一个 `when` 后是 true 的分支胜出。 假设有个 user对象有 first_name 和 last_name 属性，那么可以有这样的写法：

```ruby
case
when user.first_name == "David", user.last_name == "Black"
  puts "You might be David Black."
when Time.now.wday == 5
  puts "You're not David Black, but at least it's Friday!"
else
  puts "You're not David Black, and it's not Friday."
end
```

The simple case keyword in this manner is an alternate way of writing an if statement. In fact, any case statement can be written as an if statement. case statements with explicit arguments to case are often considerably shorter than their if counterparts, which have to resort to calling === or other comparison methods. Those without explicit test arguments are usually no shorter than the equivalent if statements; for instance, the previous example would be written like this using if:

这种 case 的用法可以用来替代多个 if + elsif 的分支。实际上任何 case 结构都可以写成 if 格式。实际上带有参数传给 `case`(case 后带陈述)的情况用if会写更多代码，用if会每次都写两个比较对象。比如改写上面的例子：

```ruby
if user.first_name == "David" or user.last_name == "Black"
  puts "You might be David Black."
elsif Time.now.wday == 5
  puts "You're not David Black, but at least it's Friday!"
else
  puts "You're not David Black, and it's not Friday."
end
```

如果 把case结构看作一个整体:

```ruby
class User
  attr_accessor :last_name, :first_name
end

user = User.new
user.first_name, user.last_name = "Caven", "Xu"

puts case
     when user.first_name == "David", user.last_name == "Black"
      "You might be David Black."
     when Time.now.wday == 5
      "You're not David Black, but at least it's Friday!"
     else
      "You're not David Black, and it's not Friday."
     end
```

输出是

```ruby
2.5.0 :001 > load './puts_case.rb'
You're not David Black, and it's not Friday.
 => true
```

如果没有 else 所有的匹配都 miss 那么：

```ruby
2.5.0 :001 > load './puts_case.rb'

 => true
2.5.0 :002 >
```

`puts` 印出了一个空行，那么说明整个case返回的是 `nil`

**Repeating actions wtih loops**


`loop` 后可以直接跟 block

```ruby
loop { repeatedly running code }
```

或

```ruby
loop do
  repeatedly running code
end
```

`break` 用来打断循环(loop)，注意不是打断 block ，也不是 method。

```ruby
2.5.0 :001 > n = 1
 => 1
2.5.0 :002 > loop do
2.5.0 :003 >     n += 1
2.5.0 :004?>   puts n
2.5.0 :005?>   break if n > 9
2.5.0 :006?>   end
2
3
4
5
6
7
8
9
10
 => nil
```

Another technique skips to the next iteration of the loop without finishing the current iteration. To do this, you use the keyword next:

使用 `next` 可以让迭代计算进入下一步迭代计算开头。

```ruby
2.5.0 :002 > x = 1
 => 1
2.5.0 :003 > loop do
2.5.0 :004 >     x += 1
2.5.0 :005?>   puts x
2.5.0 :006?>   next unless x > 10 # means while x <= 10 jump back to the begining of next iteration step(in this case, line 004)
2.5.0 :007?>   break
2.5.0 :008?> end
2
3
4
5
6
7
8
9
10
11
 => nil
2.5.0 :009 >
```

上面的例子中 当 x > 10 时, `next` 失效， 代码继续往下走到达 `break` 退出 loop， next的意思是回到下一次迭代计算的开头，而不是继续往下。

`break`, `exit` 的区别

- `break`

```ruby
n = 1
loop do
  n += 1
  puts n
  break  if n == 5
  puts "Inside loop body, after break, whether this line will appear?"
end
```

输出

```ruby
2.5.0 :002 > load './break.rb'
2
Inside loop body, after break, whether this line will appear?
3
Inside loop body, after break, whether this line will appear?
4
Inside loop body, after break, whether this line will appear?
5
 => true
```

- `exit`

```ruby
n = 1
loop do
  n += 1
  puts n
  exit  if n == 5
  puts "Inside loop body, after exit, whether this line will appear?"
end
```
输出

```ruby
2.5.0 :002 > load './exit.rb'
2
Inside loop body, after exit, whether this line will appear?
3
Inside loop body, after exit, whether this line will appear?
4
Inside loop body, after exit, whether this line will appear?
5
 caven@caven ⮀ ~/Notes & Articles/Note of Rubyist/code examples ⮀ ⭠ 01-Rubyist± ⮀
```

注意，exit 前面部分的输出和 break 一样，但最后他导致退出了 irb

一个`break` 可以打破一个loop， 如果是嵌套 loop， 那break只会打破它所在层级的loop


loop

unless

if

break

next

while

until

可以有很多种组合使用

-

**The `while` keyword**

```ruby
x = 1
while x < 5
  x += 1
  #code
end
```

```ruby
2.5.0 :002 > x = 1
 => 1
2.5.0 :003 > while x < 5
2.5.0 :004?>   x += 1
2.5.0 :005?>   puts x
2.5.0 :006?>   end
2
3
4
5
 => nil
```

while … end 会在当 x < 5 时，一直循环。 注意和 if 的区别——if 不是loop，是流程控制关键词

while 也可以放到后面，跟 end 一起

但需要在前面加上 begin 不然 ruby 不知道整个 loop 是从哪里开始的，因为 while 被移到末尾后没有其他标示来指明 loop 的开端

```ruby
2.5.0 :002 > n = 1
 => 1
2.5.0 :003 > begin
2.5.0 :004?>   n += 1
2.5.0 :005?>   puts n
2.5.0 :006?> end while n < 5
2
3
4
5
 => nil
2.5.0 :007 >
```

-

但 while 在最后时可能会导致某些特殊情况，因为代码执行时从上至下的，如果末尾的 while 指定的条件 miss 了，前面的代码还是会执行到 while 之前

```ruby
2.5.0 :004 > n = 10
 => 10
2.5.0 :005 > begin
2.5.0 :006?>   puts n
2.5.0 :007?> end while n < 9
10
 => nil
2.5.0 :008 >
```

-

until 直到

```ruby
2.5.0 :008 > n = 1
 => 1
2.5.0 :009 > until n > 5 #keep looping until n is greater than 5(means 6)
2.5.0 :010?>   n += 1
2.5.0 :011?>   puts n
2.5.0 :012?> end
2
3
4
5
6
 => nil
2.5.0 :013 >
```

until 也和 while 一样可以用到 loop 的末尾，但要配合 begin 指明 loop 的开头

—

if / unless

while / until

都可以在一行之内完成表述

但前提要分清楚

if 和 unless 不是循环逻辑，是条件判断关键词

while 和 until 以及 loop 是循环逻辑

In addition to looping unconditionally (loop) and conditionally (while, until), you can loop through a list of values, running the loop once for each value. Ruby offers several ways to do this, one of which is the keyword for.

除了无条件循环(loop)和有条件循环(while, until)，我们可以把一个列表中的对象拿出来进行循环操作，一次拿一个。 ruby 提供了多种方式来实现，其中一个是使用 `for` 关键词

`for x in array { block }` 和 `array.each { block }` 效果相同。

**Iterators and code blocks**

The control-flow techniques we’ve looked at so far involve controlling how many times, or under what conditions, a segment of code gets executed. In this section, we’ll examine a different kind of control-flow facility. The techniques we’ll discuss here don’t just perform an execute-or-skip operation on a segment of code; they bounce control of the program from one scope to another and back again, through iteration.

之前了解的 control-flow 技术都只是关于在什么条件下，一个代码片段被执行多少次。接下来会学习另一种 control-flow 技术。 它不仅仅是 执行或跳过 一段代码；他会从一个scope内交出对程序的控制权，接着再拿回去继续——通过迭代操作过程。

The ingredients of iteration
迭代计算的原料

In focusing on movement between local scopes, it may sound like we’ve gone back to talking about method calls. After all, when you call a method on an object, control is passed to the body of the method (a different scope); and when the method has finished executing, control returns to the point right after the point where the method call took place.

We are indeed back in method-call territory, but we’re exploring new aspects of it, not just revisiting the old. We’re talking about a new construct called a code block and a keyword by the name of yield.

着眼于本地scope的转移，好像是之前关于 method call 的话题。 毕竟，当你对某个object call一个method的时候，控制权就被交到了method内部（一个新的scope）； 当method执行完成之后，控制权会交回给 整个method calling 发生的背景。

我们确实又回到了 method-call 的话题范围，但是我们在探索关于他的一个新的方面。我们在谈论一个新的结构叫做`code block` 以及一个新的 keyword 叫 `yield`

之前看到过 `loop { puts "Looping forever" }` 这样的代码。

The word loop and the message in the string clue you in as to what you get if you run it: that message, printed forever. But what exactly is going on? Why does that puts statement get executed at all—and why does it get executed in a loop?

puts 后的字串被永远循环执行。但是这里到底发生了什么？ 为什么puts被一直执行，为什么它能在一个loop中执行。

The answer is that loop is an iterator. An iterator is a Ruby method that has an extra ingredient in its calling syntax: it expects you to provide it with a code block. The curly braces in the loop example delimit the block; the code in the block consists of the puts statement.

答案是 `loop` 是一个迭代(发生)器。 ruby 中，一个迭代器是一个其呼叫语法中包含额外'原料'的方法：迭代器方法会期望你提供一个block。两个花括号{} 构成了block。

The loop method has access to the code inside the block: the method can call (execute) the block. To do this from an iterator of your own, you use the keyword yield. Together, the code block (supplied by the calling code) and yield (invoked from within the method) are the chief ingredients of iteration.

loop itself is written in C (and uses a C function to achieve the same effect as yield). But the whole idea of looping suggests an interesting exercise: reimplementing loop in pure Ruby. This exercise will give you a first glimpse at yield in action.

`loop` 方法有权限拿到 block 中的代码： 它可以执行block中的代码。你可以通过使用 `yield` 关键词来使你的迭代器方法进行这个操作。 合起来，code block 和 `yield` 是迭代计算的主要构成部分。

`loop` 方法本身是用 C 语言写的（也用C语言的功能到达和yield相同的效果）。 但整个loop的思想引出了一个有趣的练习：用纯ruby的方式重新实现loop功能。 这个练习会让你初步了解 `yield`

The job of loop is to yield control to the code block, again and again, forever. Here’s how you might write your own version of loop:

`loop`的工作是将控制权交给code block， 并且不断重复这个工作，直到永远。

下面是我们自己写的 loop 版本

```ruby
def my_loop
  while true
    yield
  end
end
```
或者更短一点

```ruby
def my_loop
  yield while true
end
```

接着就可以使用它来做循环操作

```ruby
my_loop {puts "My-looping forever!"}
```

By providing a code block, you’re giving my_loop something—a chunk of code—to which it can yield control. When the method yields to the block, the code in the block runs, and then control returns to the method. Yielding isn’t the same as returning from a method. Yielding takes place while the method is still running. After the code block executes, control returns to the method at the statement immediately following the call to yield.

通过提供一个 code block ， 你提供给了`my_loop`一段代码，让`my_loop`能让出控制权给这段代码片段。 当method让步给block的时候，block中的代码就开始执行，接着控制权又交回给method。 这里的'yield'和从一个method返回不一样, yield 是在方法内部仍在运转时发生的。当code block执行完之后，也就是紧跟着 yield， 控制权又交回给了 method。

The code block is part of the method call—that is, part of its syntax. This is an important point: a code block isn’t an argument. The arguments to methods are the arguments. The code block is the code block. They’re two separate constructs. You can see the logic behind the distinction if you look at the full picture of how method calls are put together.

code block 是method call 的其中一部分——也就是其句法构成的一部分。 这是很重要的一点： code block 不是参数(argument)。参数是参数，跟code block是两个概念。 如果你看到了method call的全景你就能了解二者背后的区别。

**The anatomy of a method call**

Every methdo call in Ruby has the following syntax:
ruby中的每一个method call 都有如下句法：


- A receiver object or variable (defaulting to self if absent)
一个receiver对象或者变数（如果没有会默认是`self`）

- A dot (required if there’s an explicit receiver; disallowed otherwise)
点号 `.` (如果有receiver这是必须的)

- A method name (required)
方法名称

- An argument list (optional; defaults to ())
一个参数列表（可选；默认是`()`）

- A code block (optional; no default)
一个code block(可选，非默认就有)

Note in particular that the argument list and the code block are separate. Their existence varies independently. All of these are syntactically legitimate Ruby method calls:

注意 code block 和 argument list 是分开列出的。 他是不同的存在，以下所有这些都是ruby中从句法说合法的 method calls:

```ruby
loop { puts "Hi" }
loop() { puts "Hi" }

string.scan(/[^,]+/)
string.scan(/[^,]+/) { |word| puts word }
```

The last example shows a block parameter, word. We’ll get back to block parameters presently.) The difference between a method call with a block and a method call without a block comes down to whether or not the method can yield. If there’s a block, then it can; if not, it can’t, because there’s nothing to yield to.

最后一个例子展示了关于'block parameter'的用法，也就是block中出现的那个`|word|`，之后我会提到他。 带block的method call和不带block的method call决定了这个method能不能`yield`。如果有block就可以 yield 如果没有就不能，因为没有 block 那么就没有 yield 的对象。

Furthermore, some methods are written so they’ll at least do something, whether you pass them a code block or not. String#split, for example, splits its receiver (a string, of course) on the delimiter you pass in and returns an array of the split elements. If you pass it a block, split also yields the split elements to the block, one at a time. Your block can then do whatever it wants with each substring: print it out, stash it in a database column, and so forth.

进一步说，不管有没有block，method都能做些什么。 `String#split` 方法，能够将 receiver 字串按你给出的分隔识别符号拆解成一个array的substrings。如果后面接着 block 那么split会把分割好的元素传给 block， 一次一个。在block中你可以对这些substring进行后续你需要的操作。

If you learn to think of the code block as a syntactic element of the method call, rather than as one of the arguments, you’ll be able to keep things straight as you see more variations on the basic iteration theme.

Earlier you saw, in brief, that code blocks can be delimited either by curly braces or by the do/end keyword pair. Let’s look more closely now at how these two delimiter options differ from each other.

当你学会了将code block视为method call的句法构成的一部分而不是参数时，你将会在面对其他迭代操作的变形时更好地理解到底发生了什么。

**Curly braces vs do/end in code block syntax**

```ruby
2.5.0 :001 > array = [1, 2, 3]
 => [1, 2, 3]
2.5.0 :002 > array.map { |n| n * 10 }
 => [10, 20, 30]
2.5.0 :003 > array.map do |n| n * 10 end
 => [10, 20, 30]
2.5.0 :004 >
2.5.0 :005 > puts array.map { |n| n * 10 }
10
20
30
 => nil
2.5.0 :006 > puts array.map do |n| n * 10 end
#<Enumerator:0x00007fbc5d94c980>
 => nil
```

在前两个代码例子中，使用花括号和do/end的效果是一样的。

But look at what happens when we use the outcome of the map operation as an argument to puts. The curly-brace version prints out the [10,20,30] array (one item per line, in keeping with how puts handles arrays) . But the do/end version returns an enumerator—which is precisely what map does when it’s called with no code block . (You’ll learn more about enumerators in chapter 10. The relevant point here is that the two block syntaxes produce different results.)

但在加上 `puts` 的案例中，我把 map 操作整个作为 puts 的参数。 { } 版本印出了 [10,20,30]，但 do/end 版本只返回了一个 enumerator，跟map后不跟block返回的一样。

第一个实际上是： `puts(array.map {|n| n * 10 })`

第二个实际上则是： `puts(array.map) do |n| n * 10 end` 或 `puts(array.map) {|n| n *10}`

In the second case, the code block is interpreted as being part of the call to puts, not the call to map. And if you call puts with a block, it ignores the block. So the do/end version is really equivalent to
第二个案例中，code block被视作了puts 方法语法的一部分，puts 是会无视他后面跟的block的。所以实际第二个操作像是`puts array.map` 而第一个操作是在 `puts [10,20,30]`

这也是为什么第二个案例直接返回了一个 enumerator

The call to map using a do/end–style code block illustrates the fact that if you supply a code block but the method you call doesn’t see it (or doesn’t look for it), no error occurs: methods aren’t obliged to yield, and many methods (including map) have well-defined behaviors for cases where there’s a code block and cases where there isn’t. If a method seems to be ignoring a block that you expect it to yield to, look closely at the precedence rules and make sure the block really is available to the method.

第二个案例也说明了，如果你给一个method 提供了 code block，但是这个方法不需要或无视block，那么什么都不会发生也不会报错： method 并都是要yield把控制权交给block的。许多如`map`这样的方法是预先定义好了有block和没block的行为的。如果一个method没有理会你给出的block，那么先检查一下优先级规则，接着查下这个method 是否接受block。

-

8.times do 或 8.times { }

中的 times method 实际是 class Integer 中的一个 instance method
http://ruby-doc.org/core-2.5.0/Integer.html#method-i-times

`ri Integer.times`

```ruby
= Integer.times

(from ruby site)
------------------------------------------------------------------------------
  int.times {|i| block }  ->  self
  int.times               ->  an_enumerator

------------------------------------------------------------------------------

Iterates the given block int times, passing in values from zero to int - 1.

If no block is given, an Enumerator is returned instead.

  5.times {|i| print i, " " }   #=> 0 1 2 3 4


(END)
```

我们也可以借用 Integer 这个 class 来泡制一个自己的 my_times 版本

```ruby
2.5.0 :002 > class Integer
2.5.0 :003?>   def my_times
2.5.0 :004?>     c = 0
2.5.0 :005?>     until c == self
2.5.0 :006?>       yield(c)
2.5.0 :007?>       c += 1
2.5.0 :008?>     end
2.5.0 :009?>     self
2.5.0 :010?>   end
2.5.0 :011?> end
 => :my_times
2.5.0 :012 > 3.my_times { |c| puts "I am in iteration #{c} !" }
I am in iteration 0 !
I am in iteration 1 !
I am in iteration 2 !
 => 3
2.5.0 :013 >
```

**The importance of being each**

The idea of each is simple: you run the each method on a collection object, and each yields each item in the collection to your code block, one at a time. Ruby has several collection classes, and even more classes that are sufficiently collection-like to support an each method. You’ll see two chapters devoted to Ruby collections. Here, we’ll recruit the humble array for our examples.

`each`背后的思想很简单：对一个 collection 对象使用 each 方法， each 每次yield一个元素给block，一次一个。 ruby有几个collection类，另外还有几个'类collection' class也能使用 each 方法。 后面我们会用两章时间来介绍 collection。这里我们暂时用简单的array作为例子。

```ruby
2.5.0 :002 > array = [1,2,3]
 => [1, 2, 3]
2.5.0 :003 > array.each { |e| puts "The block just got handed #{e}." }
The block just got handed 1.
The block just got handed 2.
The block just got handed 3.
 => [1, 2, 3]
```

注意不管中间执行了什么, each 最后 return 的是执行 each 的原来的 receiver

可以这么测试

```ruby
2.5.0 :005 > array == array.each { |e| puts "The block just got handed #{e}." }
The block just got handed 1.
The block just got handed 2.
The block just got handed 3.
 => true
2.5.0 :006 >
```

也可以看 object_id，each 最后return的是同一个对象

```ruby
2.5.0 :006 > (array.each { |e| puts "The block just got handed #{e}." }).object_id
The block just got handed 1.
The block just got handed 2.
The block just got handed 3.
 => 70317091944200
2.5.0 :007 > array.object_id == (array.each { |e| puts "The block just got handed #{e}." }).object_id
The block just got handed 1.
The block just got handed 2.
The block just got handed 3.
 => true
2.5.0 :008 >
```

之前用 while 写了自己的 my_loop，也用 until 和 yield 实现了自己的 `my_times`

To implement my_each, we’ll take another step along the lines of iteration refinement. With my_loop, we iterated forever. With my_times, we iterated n times. With my_each, the number of iterations—the number of times the method yields—depends on the size of the array.

We need a counter to keep track of where we are in the array and to keep yielding until we’re finished. Conveniently, arrays have a size method, which makes it easy to determine how many iterations (how many “rotations in the air”) need to be performed. As a return value for the method, we’ll use the original array object:

为了实现自己的 `my_each`，迭代操作的次数将会基于 array 中元素的数量。

我们需要一个计数器来追踪操作到了array中的具体哪一个元素，直到遍历。array 有一个size方法能很便捷地知道迭代操作的总次数。跟原版的each类似，我们也将最初的receiver作为最终的return值。

```ruby
2.5.0 :002 > class Array
2.5.0 :003?>   def my_each
2.5.0 :004?>     c = 0
2.5.0 :005?>     until c == size
2.5.0 :006?>       yield(self[c])
2.5.0 :007?>       c += 1
2.5.0 :008?>     end
2.5.0 :009?>     self
2.5.0 :010?>   end
2.5.0 :011?> end
 => :my_each

2.5.0 :012 > array = [1,2,3]
 => [1, 2, 3]
2.5.0 :013 > array.my_each { |e| puts "The block just got handed #{e}." }
The block just got handed 1.
The block just got handed 2.
The block just got handed 3.
 => [1, 2, 3]
2.5.0 :014 >
```

An interesting exercise is to define my_each using the existing definition of my_times. You can use the size method to determine how many iterations you need and then perform them courtesy of my_times, like so:
一个有趣的联系是通过我们之前写的`my_times`来写`my_each`。这里就使用 size 来替代my_times中的 integer次数：

```ruby
class Array
  def my_each
    size.my_times do |i|
      yield self[i]
    end
    self
  end
end
```

We’ve successfully implemented at least a simple version of each. The nice thing about each is that it’s so vanilla: all it does is toss values at the code block, one at a time, until it runs out. One important implication of this is that it’s possible to build any number of more complex, semantically rich iterators on top of each. We’ll finish this reimplementation exercise with one such method: map, which you saw briefly in section 6.3.4. Learning a bit about map will also take us into some further nuances of code block writing and usage.

我们完成了一个简版的 each。 关于each很好的一点是： 他所做的只是把值抛给code block，一次一个，直到用完。 由这一点引申出的是，我们有可能在each的基础上构建出更多的，更加复杂的迭代操作方法。我们将以重新实现 `map` 为例来演示.

**From each to map**

Like each, map walks through an array one element at a time and yields each element to the code block. The difference between each and map lies in the return value: each returns its receiver, but map returns a new array. The new array is always the same size as the original array, but instead of the original elements, the new array contains the accumulated return values of the code block from the iterations.

Here’s a map example. Notice that the return value contains new elements; it’s not just the array we started with:

`map` 和 `each` 的迭代操作过程都一样，一次拿出一个元素。不同的是 map 最后返回的不是 receiver， 而是将每一步迭代操作的结果汇总在一个新 array 中。

```ruby
2.5.0 :001 > names = ["David", "Alan", "Black"]
 => ["David", "Alan", "Black"]
2.5.0 :002 > names.each { |n| n.upcase }
 => ["David", "Alan", "Black"]
2.5.0 :003 > names.map { |n| n.upcase }
 => ["DAVID", "ALAN", "BLACK"]
2.5.0 :004 > names
 => ["David", "Alan", "Black"]
2.5.0 :005 >
```
但要注意 map 并没有直接改变原有的 receiver 而是返回新的array， 除非使用了 map

```ruby
2.5.0 :005 > names = ["David", "Alan", "Black"]
 => ["David", "Alan", "Black"]
2.5.0 :006 > names.object_id == (names.map { |n| n.upcase }).object_id
 => false
2.5.0 :007 > names.object_id == (names.map! { |n| n.upcase }).object_id
 => true
2.5.0 :008 >
```

The piece of the puzzle that map adds to our analysis of iteration is the idea of the code block returning a value to the method that yielded to it. And indeed it does: just as the method can yield a value, so too can the block return a value. The return value comes back as the value of the call to yield.
`map` 向 迭代操作拼图中添加的一块拼图是，code block 会将代码执行结果的值重新返回给 yield 他的code block , 他确实也是这么做的：就如 method 能产出一个值，block也可以return一个值。

To implement my_map, then, we have to arrange for an accumulator array, into which we’ll drop the return values of the successive calls to the code block. We’ll then return the accumulator array as the result of the entire call to my_map.
Let’s start with a preliminary, but not final, implementation, in which we don’t build on my_each but write my_map from scratch. The purpose is to illustrate exactly how mapping differs from simple iteration. We’ll then refine the implementation.
为了实现`my_map`， 需要安排一个累计数组(accumulator array)， 我们会把 code block 返回的值存入这个 accumulator array. 我们先以一个预备性的版本，我们不以my_each作为基础，而是从头开始写。 目的是为了演示 map 和简单的迭代操作有什么不同。接下来我们会改良代码。

第一个版本：

```ruby
2.5.0 :001 > class Array
2.5.0 :002?>   def my_map
2.5.0 :003?>     c = 0
2.5.0 :004?>     acc = []
2.5.0 :005?>     until c == size
2.5.0 :006?>       acc << yield(self[c])
2.5.0 :007?>       c += 1
2.5.0 :008?>     end
2.5.0 :009?>     acc
2.5.0 :010?>   end
2.5.0 :011?> end
 => :my_map
2.5.0 :012 >
```

使用效果

```ruby
2.5.0 :012 > names = ["David", "Alan", "Black"]
 => ["David", "Alan", "Black"]
2.5.0 :013 > names.my_map { |name| name.upcase }
 => ["DAVID", "ALAN", "BLACK"]
2.5.0 :014 > names
 => ["David", "Alan", "Black"]
2.5.0 :015 >
```

But our implementation of my_map fails to deliver on the promise of my_each—the promise being that each serves as the vanilla iterator on top of which the more complex iterators can be built. Let’s reimplement map. This time, we’ll write my_map in terms of my_each.
但是这个版本没有兑现对 `my_each` 的承诺——我们承诺过更加复杂的迭代操作可以建立在 each 的基础之上。现在我们写一个基于 my_each 的版本。

Building map on top of each

Building map on top of each is almost startlingly simple:

```ruby
2.5.0 :002 > class Array
2.5.0 :003?>   def my_each
2.5.0 :004?>     n = 0
2.5.0 :005?>     until n == size
2.5.0 :006?>       yield(self[n])
2.5.0 :007?>       n += 1
2.5.0 :008?>      end
2.5.0 :009?>     self
2.5.0 :010?>   end
2.5.0 :011?>
2.5.0 :012?>   def my_map
2.5.0 :013?>     acc = []
2.5.0 :014?>     my_each { |e| acc << yield(e) } # omited self
2.5.0 :015?>     acc
2.5.0 :016?>   end
2.5.0 :017?> end
 => :my_map

2.5.0 :019 >
2.5.0 :020 > names = %w{David Alan Black}
 => ["David", "Alan", "Black"]
2.5.0 :021 > names.my_map { |name| name.upcase }
 => ["DAVID", "ALAN", "BLACK"]
2.5.0 :022 > names
 => ["David", "Alan", "Black"]
2.5.0 :023 >
```

We piggyback on the vanilla iterator, allowing my_each to do the walk-through of the array. There’s no need to maintain an explicit counter or to write an until loop. We’ve already got that logic; it’s embodied in my_each. In writing my_map, it makes sense to take advantage of it.
以普通迭代方法为基础，允许 my_each 遍历array。 这样我们都不再需要一个 counter 计数器或者写 until 循环。 我们已经拿到了基本的逻辑功能； 它被嵌入在 my_each 中。


There’s much, much more to say about iterators and, in particular, the ways Ruby builds on each to provide an extremely rich toolkit of collection-processing methods. We’ll go down that avenue in chapter 10. Here, meanwhile, let’s delve a bit more deeply into some of the nuts and bolts of iterators—starting with the assignment and scoping rules that govern their use of parameters and variables.
对于 迭代方法 还有很多可用说的，尤其是 ruby 如果以each为基础，建立起大量的针对collection处理的工具。 这些在第10章再说。下面会更加深入地了解某些迭代方法-首先以 赋值 和scope 规则开始，他们控制着 parameters 和 variable 的使用。

**Block parameters and variable scope**

block parameter 是 block 中两根竖线中间的对象， block parameter 不定只有一个，他和普通method 的参数列表一样，可以有多个，也可以有多种，包括 sponge args

```ruby
2.5.0 :002 > def block_args_unleashed
2.5.0 :003?>   yield(1,2,3,4,5)
2.5.0 :004?> end
 => :block_args_unleashed

2.5.0 :005 > block_args_unleashed do |a, b=1, *c, d, e|
2.5.0 :006 >     puts "Arguments: "
2.5.0 :007?>   p a, b, c, d, e
2.5.0 :008?> end
Arguments:
1
2
[3]
4
5
 => [1, 2, [3], 4, 5]
```

关于 scope 的内容相对复杂一点

从之前写我们自己的 my_each 的案例中可以看到在一个 method 中， 在block内部是可以拿到外面的local variable的。

```ruby
2.5.0 :002 > def block_scope_demo
2.5.0 :003?>   x = 100
2.5.0 :004?>   1.times do
2.5.0 :005 >       puts x
2.5.0 :006?>     end
2.5.0 :007?>   end
 => :block_scope_demo
2.5.0 :008 >
2.5.0 :009 > block_scope_demo
100
 => 1
2.5.0 :010 >
```

那么赋值的情况也是可以通透的

```ruby
2.5.0 :001 > def block_scope_demo
2.5.0 :002?>   x = 100
2.5.0 :003?>   1.times do
2.5.0 :004 >       x = 200
2.5.0 :005?>     end
2.5.0 :006?>   puts x
2.5.0 :007?>   end
 => :block_scope_demo
2.5.0 :008 >
2.5.0 :009 > block_scope_demo
200
 => nil
2.5.0 :010 >
```

Blocks, in other words, have direct access to variables that already exist (such as x in the example). However, block parameters (the variable names between the pipes) behave differently from non-parameter variables. If you have a variable of a given name in scope and also use that name as one of your block parameters, then the two variables—the one that exists already and the one in the parameter list—are not the same as each other.

也就是说block 可以直接使用已经存在的变量。但是block中的 block parameter 和 外面拿进来的 variable 是不一样的，他们又属于不同的 scope

```ruby
2.5.0 :001 > def block_local_parameter
2.5.0 :002?>   x = 100
2.5.0 :003?>   [1,2,3].each do |x|
2.5.0 :004 >     puts "Parameter x is #{x}"
2.5.0 :005?>     x += 10
2.5.0 :006?>     puts "Reassigned to x in block; it's now #{x}"
2.5.0 :007?>   end
2.5.0 :008?>   puts "Outer x is still #{x}"
2.5.0 :009?> end
 => :block_local_parameter
2.5.0 :010 >
2.5.0 :011 > block_local_parameter
Parameter x is 1
Reassigned to x in block; it's now 11
Parameter x is 2
Reassigned to x in block; it's now 12
Parameter x is 3
Reassigned to x in block; it's now 13
Outer x is still 100
 => nil
2.5.0 :012 >
```

上面的例子中 block 中由于使用了 x 作为 block parameter ， 那么外面的 x 在内部就被盖掉了，即使block内的重新赋值也不影响block外的 x 。所以如果block外的变数名称和block内的parameter名称一样时，外部的变量并不会影响到内部。

```ruby
2.5.0 :014 > def block_local_variable
2.5.0 :015?>   x = "Original x!"
2.5.0 :016?>   3.times do |n ;x| # n would be 0, 1, 2, 3 ...
2.5.0 :017 >       x = n
2.5.0 :018?>     puts "x in the block is now #{x}"
2.5.0 :019?>   end
2.5.0 :020?>   puts "x after the block ended is #{x}"
2.5.0 :021?> end
 => :block_local_variable
2.5.0 :022 >
2.5.0 :023 > block_local_variable
x in the block is now 0
x in the block is now 1
x in the block is now 2
x after the block ended is Original x!
 => nil
2.5.0 :024 >
```

上面的例子中block的 parameter list 中 x 前加上了 `;` 使他的scope被限制在 block 内部，这样就不会影响到 外部的variable

The variables listed after the semicolon aren’t considered block parameters; they don’t get bound to anything when the block is called. They’re reserved names—names you want to be able to use as temporary variables inside the block without having to check for name collisions from outside the block.”

`;x` 并不会被视作 block parameter，他只是当做block code执行时会用到的对象。这是保留名称reserved name，是你能在block内部作为临时用途而不会影响到外部的名称。即使你在 block 的list中写了 reserved names 而实际后面没有用到，也不会报错

```ruby
2.5.0 :025 > def block_local_variable
2.5.0 :026?>   x = "Original x!"
2.5.0 :027?>   3.times do |n ;x|
2.5.0 :028 >       puts "Inside block, without calling x"
2.5.0 :029?>     end
2.5.0 :030?>   end
 => :block_local_variable
2.5.0 :031 >
2.5.0 :032 > block_local_variable
Inside block, without calling x
Inside block, without calling x
Inside block, without calling x
 => 3
2.5.0 :033 >
```

In sum, three basic “flavors” of block variable are available to you:
以下对象在block中是可以用到的

- Local variables that exist already when the block is created
当block建立前就已经存在的 本地变量

- Block parameters, which are always block-local
block中的 block parameter 总是只在block 内部有效

- True block-locals, which are listed after the semicolon and aren’t assigned to but do protect any same-named variables from the outer scope
加在 block parameter list 里面的带 `;`的标识符，只对于block内部有效

With these tools at hand, you should be able to engineer your blocks so they do what you need them to with respect to variables and scope, and so you don’t “clobber” any variables from the outer scope that you don’t want to clobber.

Ruby’s iterators and code blocks allow you to write and use methods that are engineered to share their own functionality with their callers. The method contains some logic and procedure, but when you call the method, you supply additional code that fills out the logic and individualizes the particular call you’re making. It’s an elegant feature with endless applications. We’ll come back to iterators when we examine collection objects in detail in chapters 10 and 11.

有了对block内外的variable和parameter的理解，现在就能让block做你所想做的了。

ruby的迭代方法和code block让receiver能够共享他们的功能。method中包含了一些逻辑和程序，但当你呼叫method时，你再带上附加的 code(block) 来丰富逻辑，并且个性化你正在进行的操作。 这是一个可以有无限应用的优雅功能。

**Error handling and executions**

Way back in chapter 1, we looked at how to test code for syntax errors:
第一章的时候，我们知道使用 `-cw` 来检查一个文件中的代码是否有语法错误

`$ ruby -cw filename.rb`

```ruby
ruby -cw baker.rb
Syntax OK
```

Passing the -cw test means Ruby can run your program. But it doesn’t mean nothing will go wrong while your program is running. You can write a syntactically correct program—a program that the interpreter will accept and execute—that does all sorts of unacceptable things. Ruby handles unacceptable behavior at runtime by raising an exception.

`-cw` 可以检查语法，但语法正确并不能确保程序运行一定不出错。ruby通过 raise an exception 来处理不接受的行为。

An exception is a special kind of object, an instance of the class Exception or a descendant of that class. Raising an exception means stopping normal execution of the program and either dealing with the problem that’s been encountered or exiting the program completely.

Which of these happens—dealing with the problem or aborting the program—depends on whether you’ve provided a rescue clause. If you haven’t provided such a clause, the program terminates; if you have, control flows to the rescue clause.

exception是一类特殊的objects， 它是 class Exception 的instance或者继承自 class Exception 的classes 的实例。 raising an exception 就是停止当前执行进程，或者处理遇到的问题，或者退出程序。

是继续处理exception还是直接退出程序，取决于你提供了什么样的rescue线索。 如果你没有提供rescue线索，那么程序终止，如果提供了程序流向`rescue`分支。

比如用某个数字除以0

```ruby
2.5.0 :001 > 1/0
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):1
        1: from (irb):1:in `/'
ZeroDivisionError (divided by 0)
2.5.0 :002 >
```

引起的错误是'ZeroDivisionError (divided by 0)'

ZeroDivisionError is the name of this particular exception. More technically, it’s the name of a class—a descendant class of the class Exception. Ruby has a whole family tree of exceptions classes, all of them going back eventually to Exception.

ZeroDivisionError 是特定的错误名称。技术上讲 它是一个 class 名称- 继承自 Exception 的一个class。 Ruby有一整个家族的 excepton classes， 所有这些类都可以向上追溯到 Exception 这个顶层excetpin类。



常见的 exception classes 有

RuntimeError
NoMethodError
NameError
IOError
Errno::error
TypeError
ArgumentError
…

—


|Exception name |Common reason(s)|How to raise it|
|:---|:---|:---|
|RuntimeError	|The default exception raised by the raise method.`raise` 的默认exception class	|Raise|
|NoMethodError	|An object is sent a message it can’t resolve to a method name; the default method_missing raises this exception.	当送了一个无法识别的message给object的时候，`method_missing` 默认使用这个类 |a = Object.new a.some_unknown_method_name|
|NameError	|The interpreter hits an identifier it can’t resolve as a variable or method name.出现了一个既不能识别为变数也不能识别为方法的名称	|a = some_random_identifier|
|IOError	|Caused by reading a closed stream, writing to a read-only stream, and similar operations.	|STDIN.puts("Don't write to STDIN!")|
|Errno::error	|A family of errors relates to file I/O.	文件读写相关的操作错误 |File.open(-12)|
|TypeError	|A method receives an argument it can’t handle.一个method 接收到了一个他无法处理的参数	|a = 3 + "can't add a string to a number!|

-

如何查看一个 class subclasses

http://syedhumzashah.com/posts/fetching-all-descendants-of-a-ruby-class

```ruby
2.5.0 :002 > class Class
2.5.0 :003?>   def descendants
2.5.0 :004?>     ObjectSpace.each_object(Class).select { |k| k < self } << self
2.5.0 :005?>   end
2.5.0 :006?> end
 => :descendants
2.5.0 :007 >
2.5.0 :008 > StandardError.descendants.count
 => 179
2.5.0 :009 > Exception.descendants.count
 => 198
2.5.0 :010 >
```

-


使用 begin … end 包裹 rescue 可以限制 rescue 的管辖范围，如果想 rescue 监视整个 method 可以不用 begin ... end

```ruby
def divide
  print "Enter a number: "
  n = gets.to_i

  begin
    result = 100/n
  rescue
    puts "Your number didn't work, Was it Zero? "
  end

  puts "100/#{n} equal to #{result}."
end

divide
```

不会引起 exception 的情况

```ruby
2.5.0 :010 > load './d_by_zero.rb'
Enter a number: 2
100/2 equal to 50.
 => true
```

会引发 exception 的情况

```ruby
2.5.0 :011 > load './d_by_zero.rb'
Enter a number: 0
Your number didn't work, Was it Zero?
100/0 equal to .
 => true
```

上面的例子中，虽然输入 0 让整个 flow 进入了 rescue 分支， 但最后那行 puts 结果还是执行了，处理这种情况可以在rescue 分支加上return 直接从method退出, 这样如果参数给的有问题就不会印出结果行。

```ruby
def divide
  print "Enter a number: "
  n = gets.to_i

  begin
    result = 100/n
  rescue
    puts "Your number didn't work, Was it Zero? "
    return
  end

  puts "100/#{n} equal to #{result}."
end

divide
```

现在如果给错误的参数

```ruby
2.5.0 :002 > load './d_by_zero.rb'
Enter a number: 0
Your number didn't work, Was it Zero?
 => true
2.5.0 :003 >
```

用 raise 可以引出 exception

```ruby
2.5.0 :003 > raise "Rasing runtime error without given specific exception class."
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):3
RuntimeError (Rasing runtime error without given specific exception class.)
2.5.0 :004 >
2.5.0 :005 > raise ArgumentError, "Rasing an exception with an given exception class"
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):5
ArgumentError (Rasing an exception with an given exception class)
2.5.0 :006 >
```

如果 rails 后面不写明 error 的 class 直接跟错误信息字串，ruby 默认 raise RuntimeError

由于 exception 事实上也是 某个 error class 的实例对象

所以是可以将这个对象 存入变数，然后进行其他操作的，比如查看这个对象（这个错误）的运行轨迹 backtrace 和 错误信息 message 等

但这里不用等号赋值

使用 `=>` 跟在 rescue 后面，指向需要赋予的变数

```ruby
def fussy_method(x)
  raise ArgumentError, "I need a number under 10" unless x < 10
# raise "I need a number under 10" unless x < 10
end

begin
  fussy_method(20)
rescue ArgumentError => x
  puts "That was not a acceptable number!"
  puts "\nHere's the backtrace for this exception object: \n"
  puts x.backtrace
  puts "\n"
  puts "And here's the exception object's message: \n"
  puts x.message
end
```

执行结果

```ruby
ruby raise.rb
That was not a acceptable number!

Here's the backtrace for this exception object:
raise.rb:2:in `fussy_method'
raise.rb:7:in `<main>'

And here's the exception object's message:
I need a number under 10
```

虽然在 raise 的时候 后面跟的是 error 的 class 比如 RuntimeError 或者 ArgumentError 等，但实际这里隐藏了实例化的过程

我们拿到的 exception 是某个 exception class 的 instance

```ruby
2.5.0 :001 > begin
2.5.0 :002?>   raise ArgumentError, "I am an instance rather than a class"
2.5.0 :003?>   rescue => x
2.5.0 :004?>   end
 => nil
2.5.0 :005 > x.message
 => "I am an instance rather than a class"
2.5.0 :006 > x.class
 => ArgumentError
2.5.0 :007 > x.inspect
 => "#<ArgumentError: I am an instance rather than a class>"
2.5.0 :008 >
```

在程式跑完之前，可以再次 raise 之前的 exception 而不用给出任何其他信息，只用再写一次 `raise`

```ruby
def fussy_method(x)
  raise ArgumentError, "I need a number under 10" unless x < 10
# raise "I need a number under 10" unless x < 10
end

begin
  fussy_method(20)
rescue ArgumentError => x
  puts "That was not a acceptable number!"
  puts "\nHere's the backtrace for this exception object: \n"
  puts x.backtrace
  puts "\n"
  puts "And here's the exception object's message: \n"
  puts x.message
  puts "Raise again!"
  raise
end
```

输出

```ruby
ruby raise.rb
That was not a acceptable number!

Here's the backtrace for this exception object:
raise.rb:2:in `fussy_method'
raise.rb:7:in `<main>'

And here's the exception object's message:
I need a number under 10
Raise again!
Traceback (most recent call last):
	1: from raise.rb:7:in `<main>'
raise.rb:2:in `fussy_method': I need a number under 10 (ArgumentError)
```

在一段程式中使用 ensure 可以创造一个“无论发生情况一定要执行”的分支

没有 ensure 分支的情况

```ruby
def promise(x)
  raise ArgumentError, "x is to big..." unless x < 10
  rescue ArgumentError => exception
  3.times { puts exception.message, exception.class }
  return
  puts "May I have your attention?"
  puts "Did this line is executed?"
  #ensure
  puts "I promised doing this."
end

promise(10)
```

return 之后的代码不会执行

```ruby
uby ensure.rb
x is to big...
ArgumentError
x is to big...
ArgumentError
x is to big...
ArgumentError
```

加上ensure分支

```ruby
def promise(x)
  raise ArgumentError, "x is to big..." unless x < 10
  rescue ArgumentError => exception
  3.times { puts exception.message, exception.class }
  return
  puts "May I have your attention?"
  puts "Did this line is executed?"
  ensure
    puts "I promised doing this."
end

promise(10)
```

输出结果是

```ruby
ruby ensure.rb
x is to big...
ArgumentError
x is to big...
ArgumentError
x is to big...
ArgumentError
I promised doing this.
```
虽然`return`和`ensure`之间的代码被跳过了，但ruby确保了 ensure 分支里的代码得到执行。

-

之前提到 所有 exception 的先祖都可以追溯到 Exception 这个 class

那么我们就可以 自己造一个 exception class 然后让它继承自 Exception 那么我们就可以让这个自定义的 exception class 拥有ruby 内建 exception class 的特性


```ruby
2.5.0 :001 > class MyError < Exception
2.5.0 :002?> end
 => nil
2.5.0 :003 > begin
2.5.0 :004?>   raise MyError, "Message from MyError :)"
2.5.0 :005?>   rescue MyError => x
2.5.0 :006?>   puts "Just raised an exception #{x}."
2.5.0 :007?>   puts "This exception's class is: #{x.class}."
2.5.0 :008?>   puts "Its ancestor classes are: #{x.class.ancestors}."
2.5.0 :009?>   puts "The exception message is: #{x.message}."
2.5.0 :010?> end
Just raised an exception Message from MyError :).
This exception's class is: MyError.
Its ancestor classes are: [MyError, Exception, Object, Kernel, BasicObject].
The exception message is: Message from MyError :).
 => nil
2.5.0 :011 >
```

但这里有一点要注意 rescue 后面要写明是 MyError (line 005)因为 MyError 不在ruby 内建的 exception classes 中，不然 x 会是空的

this approach lets you pinpoint your rescue operations. Once you’ve created MyNewException, you can rescue it by name

如果想让 exception class 的描述性更好可以使用 module 造 namespace

```ruby
module CustomExceptions
  class MyError < Exception
  end
end
```

-

ruby 中control flow 有三个视角：

	•	 conditionals 条件流程控制
if , elsif , else , unless ,  case/when

	•	loops 循环操作
loop,  for , while , until

	•	iterators 迭代操作
each, map …

	•	exceptions 例外处理
raise, rescue, ensure

-

In this chapter you’ve seen

- Conditionals (if/unless and case/when) 条件式

- Loops (loop, for, while, and until) 循环

- Iterators and code blocks, including block parameters and variables 迭代方法与code blocks, 包括 block parameter 和 变数

- Examples of implementing Ruby methods in Ruby 使用ruby实现某些ruby方法

- Exceptions and exception handling 例外处理

-

 Conditionals move control around based on the truth or falsehood of expressions. Loops repeat a segment of code unconditionally, conditionally, or once for each item in a list. Iterators—methods that yield to a code block you provide alongside the call to the method—are among Ruby’s most distinctive features. You’ve learned how to write and call an iterator, techniques you’ll encounter frequently later in this book (and beyond).
 条件式基于true/false的判断移交程序的控制权。loops有条件或无条件地重复执行一个代码片段，或者一次拿出list中的一个对象进行处理。 Iterators迭代方法，让步给给定的code block-这也是ruby最特别的功能。 你已经学习了如果使用和写一个迭代方法，之后你会遇到很多这方面内容。

Exceptions are Ruby’s mechanism for handling unrecoverable error conditions. Unrecoverable is relative: you can rescue an error condition and continue execution, but you have to stage a deliberate intervention via a rescue block and thus divert and gain control of the program where otherwise it would terminate. You can also create your own exception classes through inheritance from the built-in Ruby exception classes.

exception 是ruby处理不可恢复的错误情况的机制。 不可恢复是相对的： 你可以 rescue 一个错误， 但是你必须谨慎安排好 rescue 后的流程，这样增加对程序中可能出错的地方的控制权。 你还可以建立自己的exception类，只要你使他继承自ruby内建的相关exception classes
