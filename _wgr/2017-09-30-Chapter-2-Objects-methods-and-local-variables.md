---
title:  "Rubyist-c2-Objects methods and local variables"
categories: [Ruby/Rails ℗]
tags: [Ruby & Rails, Notes of Rubyist]
---


*注：这一系列文章是《The Well-Grounded Rubyist》的学习笔记。*



---

But throughout, writing a Ruby program is largely a matter of engineering your objects so that each object plays a clear role and can perform actions related to that role.

我们对 object 所作的，总体上可以归为 1 向object 发出一段信息； 2 让object 执行某个动作。

写ruby程式更像是一场策划，导演。把合适的角色分配给合适的 object ， 并明确各个角色的职责，让他们各司其职。

In most object-oriented languages, including Ruby, every object is an example or instance of a particular class, and the behavior of individual objects is determined at least to some extent by the method definitions present in the object’s class.

在面向对象语言中，所有的对象都是特定 class 的某个实例，这些 对象 的行为基本都是由他们所属的 class 中定义的 method 决定的。

—

实际上 class 也是一类object。

—

ruby 中每一个刚出生的 object ，都会带有一些先天的能力，也就是一些基本的可执行的 method。 更重要的是，这些object可以在后天，“学会”一些能力，这个过程就是 def 一个mothod 的过程。

"教会"一个object 某个 method:

```ruby
2.5.0 :002 > obj = Object.new
 => #<Object:0x00007f80b784e8a8>
2.5.0 :003 > def obj.talk
2.5.0 :004?>   puts "I am an object."
2.5.0 :005?>   puts "(Do you an object?)"
2.5.0 :006?> end
 => :talk
2.5.0 :007 > obj.talk
I am an object.
(Do you an object?)
 => nil
2.5.0 :008 >
```

![](https://ws4.sinaimg.cn/large/006tNc79gy1fnqknll03kj30fp087myd.jpg)

The object obj understands, or responds to, the message talk. An object is said to respond to a message if the object has a method defined whose name corresponds to the message.

当一个object 能理解回应某个信息，那么可以说这个 object respond to 这个 message。

接上面的例子
```ruby
2.5.0 :009 > obj.respond_to?(:talk)
 => true
2.5.0 :010 >
```

关于参数

More precisely, the variables listed in the method definition are the method’s formal parameters, and the values you supply to the method when you call it are the corresponding arguments. (It’s common to use the word arguments, informally, to refer to a method’s parameters as well as a method call’s arguments, but it’s useful to know the technical distinction.)

parameter (技)参（变）数；参（变）量

argument 具体的参数值

**定义** method 时括号中列出的内容是 parameters
**呼叫** method 时传入的实际值被称为 arguments


ruby 中 除了 nil 和 false 以外的所有对象 使用 if 来判断，都会返回 True

```ruby
2.5.0 :010 > !!nil
 => false
2.5.0 :011 > !!false
 => false
2.5.0 :012 > !!1
 => true
2.5.0 :013 > !!""
 => true
2.5.0 :014 > !![]
 => true
```

注意 puts 最后的返回值是 nil
所以 `!!one` 最后返回的是 false ，这类逻辑判断要以最终返回值作为依据。
```ruby
2.5.0 :016 > def one
2.5.0 :017?>   puts "Hello."
2.5.0 :018?>   end
 => :one
2.5.0 :019 > !!one
Hello.
 => false
```

**几个重要的 先天 methods**

* object_id
* respond_to?()
* send(synonym: \__send__)

```ruby
2.5.0 :002 > obj = Object.new
 => #<Object:0x00007fbabd83f138>
2.5.0 :003 > obj.object_id
 => 70220010092700
2.5.0 :004 > obj.respond_to?(:respond_to?)
 => true
2.5.0 :005 > obj.send(:object_id)
 => 70220010092700
2.5.0 :006 > obj.send(:fake_meth)
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):6
NoMethodError (undefined method `fake_meth' for #<Object:0x00007fbabd83f138>)
2.5.0 :007 >
```

BasiceObject 是 Object 的 superclass

它的实例对象能做的事很少，甚至不能使用 methods 方法查看实例能用的方法。

```ruby
2.5.0 :001 > Object.superclass
 => BasicObject
2.5.0 :002 > BasicObject.new
(Object doesn't support #inspect)
 =>
2.5.0 :003 > BasicObject.new.methods
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):3
NoMethodError (undefined method `methods' for #<BasicObject:0x00007fa43084ec80>)
2.5.0 :004 >
```

不过在 class 层面，两个class 虽然是父子关系，但是他们的 class methods 的内容和数量都是一样的。

```ruby
2.5.0 :005 > Object.methods == BasicObject.methods
 => true
```

`send` 用来向一个对象送出一个message 或者说让对象执行一个 method

但与直接使用 点号 . 呼叫方法不同

send 在这里可以接受一个参数，在不确定输入值是什么的时候，比如 消息是由客户端送出的，那么send 就会把这个动态的消息送给对象

这种不确定的情境 配合使用 respond_to?() 可以简化代码

比如我们写了一个 class Ticket, 用户可以查询自己想查的内容

```ruby
  def answer(request)
    case request
    when "date"
      puts self.date
    when "seat"
      puts self.seat
    when "price"
      puts self.price
      # imagine that every ticket has hundreds of attributes
    else
      puts "No such info"
    end
  end

  def response(request)
    if self.respond_to?(request)
      puts self.send(request)
    else
      puts "No such info"
    end
  end
```
`answer` 方法只能针对固定的几个 attributes， 如果票的信息有很多种，那么代码会变得极其冗长。

而`response` 方法则直接根据用户的输入送 message 给 Ticket object 如果有对应的 attribute 就返回其值，没有就印出提示。其中就用到了 `send` 和 `respond_to?`的配合。


定义 method 的时候给参数列表中的参数前加星号 可以传入任意数量的参数 并以 array 的形式组织。

```ruby
2.5.0 :001 > def arbitrary_arg(a, b, *c)
2.5.0 :002?>   p a, b, c
2.5.0 :003?>   end
 => :arbitrary_arg
2.5.0 :004 > arbitrary_arg(1,2,3,4,5,6)
1
2
[3, 4, 5, 6]
 => [1, 2, [3, 4, 5, 6]]
2.5.0 :005 > arbitrary_arg(1,2) # 如果星号对应的参数没有给出，那么会视作空 array 对待
1
2
[]
 => [1, 2, []]
```

如果带星号的参数在中间,有几种情况:

当给出的参数个数大于 parameters 个数时，带星号的参数会尽量多地吸收传入的参数到自己的 array 中

当给出的参数个数等于 parameters 个数时，带星号的参数会把对应位置的参数带入 array

当给出参数的个数 比指定 parameters 个数少一个时 带星号的参数会把位置让出来， 让自己变成一个 空 array

当给出参数个数比指定 parameters 少两个或以上时，报错

```ruby
2.5.0 :001 > def sponge(a, b, *c, d)
2.5.0 :002?>   p a, b, c, d
2.5.0 :003?>   end
 => :sponge
2.5.0 :004 > sponge(1,2,3,4,5,6,7,8) # 参数富余
1
2
[3, 4, 5, 6, 7]
8
 => [1, 2, [3, 4, 5, 6, 7], 8]
2.5.0 :005 > sponge(1,2,3,4) # 参数对等
1
2
[3]
4
 => [1, 2, [3], 4]
2.5.0 :006 > sponge(1,2,3) # 少一个参数
1
2
[]
3
 => [1, 2, [], 3]
2.5.0 :007 > sponge(1,2) # 少两个参数
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):7
        1: from (irb):1:in `sponge'
ArgumentError (wrong number of arguments (given 2, expected 3+))
```

还有一种情况是 parameters 中既包括默认值设置，又包括 spongy 参数（带星号）

```ruby
2.5.0 :001 > def args_unleashed(a, b=1, *c, d, e)
2.5.0 :002?>   puts "Arguments:"
2.5.0 :003?>   p a, b, c, d, e
2.5.0 :004?> end
 => :args_unleashed
2.5.0 :005 > args_unleashed(1,2,3,4,5)
Arguments:
1
2
[3]
4
5
 => [1, 2, [3], 4, 5]
2.5.0 :006 > args_unleashed(1,2,3,4)
Arguments:
1
2
[]
3
4
 => [1, 2, [], 3, 4]
 2.5.0 :009 > args_unleashed(1,2,3)
Arguments:
1
1
[]
2
3
 => [1, 1, [], 2, 3]
2.5.0 :010 >
2.5.0 :007 > args_unleashed(1,2,3,4,5,6,7,8)
Arguments:
1
2
[3, 4, 5, 6]
7
8
 => [1, 2, [3, 4, 5, 6], 7, 8]
2.5.0 :008 > args_unleashed(1,2)
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):8
        1: from (irb):1:in `args_unleashed'
ArgumentError (wrong number of arguments (given 2, expected 3+))
```

可以说 这种情况下ruby 在做的是，合乎逻辑地，努力地，分配参数，尽量不让程序报错，直到它也无能为力为止

从上面只给 3个参数的情况可以看出这种 努力

因为 default value 和 sponge 参数都不是必须要传的，所以所有参数都分配给了 required 的参数。

几种参数的优先级排列是：

	•	required
	•	default-value
	•	sponge

  一个特例是不能以这种顺序排列 parameters

  `(x, *y, z=1）`

```ruby
2.5.0 :013 > def mm(x, *y, z=1)
2.5.0 :014?>   p x, y, z
2.5.0 :015?> end
Traceback (most recent call last):
        1: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
SyntaxError ((irb):13: syntax error, unexpected '=', expecting ')'
def mm(x, *y, z=1)
               ^)
```

it’s a syntax error, because there’s no way it could be correct. Once you’ve given x its argument and sponged up all the remaining arguments in the array y, nothing can ever be left for z. And if z gets the right-hand argument, leaving the rest for y, it makes no sense to describe z as “optional” or “default-valued.” The situation gets even thornier if you try to do something like the equally illegal `(x, *y, z=1, a, b)`. Fortunately, Ruby doesn’t allow for more than one sponge argument in a parameter list. Make sure you order your arguments sensibly and, when possible, keep your argument lists reasonably simple!

定义方法的时候这样排列参数会是一个句法错误，因为这种顺序逻辑上不成立。当x分别到参数后，中间的 *y 会吸收掉所有剩下的参数。如果 z 直接拿最右边的参数，那么作为 optional 的特性也就不成立。 这种情况在`(x, *y, z=1, a, b)`中也一样。ruby不允许参数列表中出现多于1个的sponge argument。确保你的参数列表合乎逻辑且尽量保持条理。（这段话存疑）

reference

（方便查询的）编号，标记，索引 A reference is something such as a number or a name that tells you where you can obtain the information you want.

在ruby 中

变数赋值的过程，并不是把等号右边的整个内容“装到” 左边的变数中

而是把右边内容整体给一个编号（可以理解为在内存中的位置标记） 让左边的变数记住

当把变数 继续赋值给 另一个变数时，也是给出的这个编号而不是实际内容

ruby 中的 replace 可以将已有编号位置的内容替换掉而不改变编号

而常用的 等号 赋值 = ， 则是用新内容（可以与原内容一样）的编号换掉原来的编号

```ruby
2.5.0 :017 > "string".object_id
 => 70106764008380
2.5.0 :018 > "string".object_id
 => 70106764058080
2.5.0 :019 > "string".object_id
 => 70106764148020
```
虽然string的内容相同，但他们是不同的对象。

```ruby
2.5.0 :002 > str = "string"
 => "string"
2.5.0 :003 > abc = str
 => "string"
2.5.0 :004 > str.object_id
 => 70131023811700
2.5.0 :005 > abc.object_id
 => 70131023811700
2.5.0 :006 > str.replace("hello")
 => "hello"
2.5.0 :007 > str.object_id
 => 70131023811700
2.5.0 :008 > abc.object_id
 => 70131023811700
2.5.0 :009 > str
 => "hello"
2.5.0 :010 > str = "world"
 => "world"
2.5.0 :011 > str.object_id
 => 70131019765580
2.5.0 :012 > abc.object_id
 => 70131023811700
2.5.0 :013 > str
 => "world"
2.5.0 :014 > abc
 => "hello"
 ```

在这几个原则下

使用 replace 可以让所有 “拿着” 这个编号的变数手里的内容同时改变

而使用 = 等号 则是将当前变数的编号和内容刷新，不会影响到之前拿着编号的变数

但就这个方面来说 replace 的操作更底层更有破坏力

但有一个例外是，对于数字类型的内容，同样的数值，内存中的编号也相同

所以无法使用 replace 来换掉对应编号的内容

```ruby
2.5.0 :001 > abc = 1.05
 => 1.05
2.5.0 :002 > abc.replace(3.14)
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):2
NoMethodError (undefined method `replace' for 1.05:Float)
```

从 rdoc 中也可以看到哪几种 类型 才有 replace method

![](https://ws1.sinaimg.cn/large/006tNc79gy1fnqsebkk8gj30bf08h3zf.jpg)

这些原则不只适用于 local variable 也适用于  其他类型的变数
class, global

对于 array 来说情况也符合这个逻辑

整个 array 拿着一个 编号
array 中的 每个 element 实际也只是一个编号

所以只要不去动到 array 中的任何一个 编号，那么 array 还是被认为是原来的 array 即使部分编号的 内容被 replace 了

```ruby
2.5.0 :001 > numbers = %w{one two three}
 => ["one", "two", "three"]
2.5.0 :002 > numbers.freeze
 => ["one", "two", "three"]
2.5.0 :003 > numbers[2].object_id
 => 70126305599800
2.5.0 :004 > numbers[2].replace("hello")
 => "hello"
2.5.0 :005 > numbers
 => ["one", "two", "hello"]
2.5.0 :006 > numbers.object_id
 => 70126305599780
2.5.0 :007 > numbers[2].object_id
 => 70126305599800
2.5.0 :008 >
```

即使单个改变的 array 中某个元素 array 本身的 编号也不变

更符合视觉意象的是把这里的 array 两边的  [      ]  理解为两个编号相同的的 界桩

无论这两个界桩之内的内容是增加了，减少了，或是中间没有东西，不管这两个界桩之间的距离有多远，这两个界桩的编号是不变的

直到用两个有新编号的界桩（样子可以看起来一模一样）换掉他们

按照这个逻辑，只要我不换掉这两个 [  ],里面的东西随便怎么弄,array 的编号是不动的。

即使给元素中某个位置重新赋值，且这个位置的编号变化了，但却对整体 array 的编号没有影响

即使 array 中所有的元素都被改变 array 本身的 编号也不会改变

除非重新给 array 整体赋值 编号才改变

### Summary
We’ve covered a lot of ground in chapter 2. In this chapter you saw
 
How to create a new object and define methods for it
如何新建一个对象并给他定义方法

The basics of the message-sending mechanism by which you send requests to objects for information or action
send 机制

Several of the important built-in methods that every Ruby object comes with: object_id, respond_to?, and send
3个内建的重要的关于ruby对象的基本方法,object_id, respond_to?, send

Details of the syntax for method argument lists, including the use of required, optional, and default-valued arguments
参数列表的细节，包括 required, default-valued, optional arguments

How local variables and variable assignment work
变数赋值是如何工作的

Ruby’s use of references to objects and how references play out when multiple variables refer to the same object
对象的引用以及多个变数引用同一个对象时这些引用如何工作。
