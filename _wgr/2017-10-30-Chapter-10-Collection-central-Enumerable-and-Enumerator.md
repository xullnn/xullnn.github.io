---
title:  "Rubyist-c10-Collection central Enumerable and Enumerator"
categories: [Ruby/Rails ℗]
tags: [Ruby & Rails, Notes of Rubyist]
---

*注：这一系列文章是《The Well-Grounded Rubyist》的学习笔记。*



---

This chapter covers


- Mixing Enumerable into your classes
将 Enumerable module 混入 class

- The use of Enumerable methods in collection objects
在collection objects上使用枚举相关的methods

- Strings as quasi-enumerable objects
string作为准枚举对象

- Sorting enumerables with the Comparable module
引入 Comparable module 来对可枚举对象进行内部排序

- Enumerators
enumerator 作为具有枚举知识的对象

-

All collection objects aren’t created equal—but an awful lot of them have many characteristics in common. In Ruby, common characteristics among many objects tend to reside in modules. Collections are no exception: collection objects in Ruby typically include the Enumerable module.
ruby 中的 collection 类一般都 include 了 Enumerable 这个 module

Classes that use Enumerable enter into a kind of contract: the class has to define an instance method called each, and in return, Enumerable endows the objects of the class with all sorts of collection-related behaviors. The methods behind these behaviors are defined in terms of each. In some respects, you might say the whole concept of a "collection" in Ruby is pegged to the Enumerable module and the methods it defines on top of each.
那些 include 了 enumerable 的 classes , 就像签订好了一个合约，只要他们在自己的 class 中定义好一个 instance method — each , 就可以获得 enumerable 拥有的所有能力。可以说 ruby 中所有与 collection 有关的概念都离不开 Enumerable module , 而Enumerable 则是以 each 为基础构建起来的。

You’ve already seen a bit of each in action. Here, you’ll see a lot more. Keep in mind, though, that although every major collection class partakes of the Enumerable module, each of them has its own methods too. The methods of an array aren’t identical to those of a set; those of a range aren’t identical to those of a hash. And sometimes collection classes share method names but the methods don’t do exactly the same thing. They can’t always do the same thing; the whole point is to have multiple collection classes but to extract as much common behavior as possible into a common module.
之前我们见过几次 `each` ，接下来我们会看更多。但记住，虽然每一个主要的collection相关类都引入了 Enumerable ，但他们各自都有自己的 methods。 array, set, range, hash, 这些 collection 中的方法都不是完全一样的。 有时候各个collection class中有些同名的methods，但这些方法并不是完全一样的。enumerable 做的只是尽可能的抽象出不同 classes 中通用的逻辑，综合成一个 module 供不同 classes 使用。

-

In addition to the Enumerable module, in this chapter we’ll look at a closely related class called Enumerator. Enumerators are objects that encapsulate knowledge of how to iterate through a particular collection. By packaging iteration intelligence in an object that’s separate from the collection itself, enumerators add a further and powerful dimension to Ruby’s already considerable collection-manipulation facilities.

除了 Enumerable 这个 module ， 我们还会了解一个叫 Enumerator 的类。 一个enumerator 就是一个获得了如何进行对一个collection 对象进行迭代操作的知识的 对象。通过将迭代操作的智慧（知识，功能）注入collection后的整体作为一个新的object——与原来的collection分离开——enumerator 将ruby原本就很强大的 collection 相关的操作提升了一个维度。

```ruby
2.5.0 :002 > Array.new.each
 => #<Enumerator: []:each>
2.5.0 :003 > Hash.new.each
 => #<Enumerator: {}:each>
2.5.0 :004 > Range.new(1,9).each
 => #<Enumerator: 1..9:each>
2.5.0 :005 > require 'set'
 => true
2.5.0 :006 > Set.new.each
 => #<Enumerator: #<Set: {}>:each>
2.5.0 :007 >
```

http://ruby-doc.org/core-2.5.0/Enumerator.html


-

涉及到的几个核心词汇：

	•	enumerable

中文翻译： （可）枚举（的），（可）遍历（的）
复数形式代表可进行枚举操作的一类collections

able to be counted by one-to-one correspondence with the set of all positive integers.
在正整数范围内能够被一个接一个处理（的能力）。

![](https://ws4.sinaimg.cn/large/006tNc79gy1fo6pgjs5wpj30i50gzdhs.jpg)

-

•	enumerator

中文翻译： 预备枚举状态的object，或说枚举功能和collection融合后形成的新 object

![](https://ws2.sinaimg.cn/large/006tNc79gy1fo6phu685ej30hq0gvabv.jpg)

-

•	enumerate

枚举，遍历

![](https://ws1.sinaimg.cn/large/006tNc79gy1fo6pihcm3fj30c90krwhu.jpg)


-

•	iterate  迭代计算（操作）

•	iteration 前者的名词形式

•	iterator 进行迭代计算的方法(method)

重复演算

the repetition of a process or utterance.

repetition of a mathematical or computational procedure applied to the result of previous application, typically as a means of obtaining successively closer approximations to the solution of a problem.

（基于前一次计算结果的）重复演算


![](https://ws4.sinaimg.cn/large/006tNc79gy1fo6pkqno8rj30ce0k6n0r.jpg)

-

**Garining enuerability through each**

Exactly what each does will vary from one class to another. In the case of an array, each yields the first element, then the second, and so forth. In the case of a hash, it yields key/value pairs in the form of two-element arrays. In the case of a file handle, it yields one line of the file at a time. Ranges iterate by first deciding whether iterating is possible (which it isn’t, for example, if the start point is a float) and then pretending to be an array. And if you define an each in a class of your own, it can mean whatever you want it to mean—as long as it yields something. So each has different semantics for different classes. But however each is implemented, the methods in the Enumerable module depend on being able to call it.

`each` 具体做的工作在不同class 中有所区别。在定义不同class的each时就会有所区别。

- 在 array 中， each 从第一个 element 开始拿取
- 在 hash 中， 他将每个键值对当做一个 含有两个元素的mini array, 然后沿用 array 的特性。
- 在 file 文件中， 它每次处理一行内容
- 在 range 中， 它首先判断这个 range 是否具备枚举资格，如果可以，他将 range 当做 array 处理


—

如果是自定义的 class ， 想要获得 enumerability 需要两个操作

1 include Enumerable

2 def each

```ruby
class Rainbow
  include Enumerable

  def each
    yield "red"
    yield "orange"
    yield "yellow"
    yield "green"
    yield "blue"
    yield "indigo"
    yield "violet"
  end

end
```

输出

```ruby
2.5.0 :002 > load './rainbow.rb'
 => true
2.5.0 :003 > r = Rainbow.new
 => #<Rainbow:0x00007fee7706ae60>
2.5.0 :004 > r.each do |color|
2.5.0 :005 >     puts "Next color: #{color}"
2.5.0 :006?>   end
Next color: red
Next color: orange
Next color: yellow
Next color: green
Next color: blue
Next color: indigo
Next color: violet
 => nil
2.5.0 :007 >
```

定义好 each 之后，自动获得了很多相关methods， find 这个method 而不需要自己再去定义

```ruby
2.5.0 :007 > y_color = r.find { |c| c.start_with?('y') }
 => "yellow"
2.5.0 :008 >
```

使用 .instance_methods 可以查看 我们自己写的 class Rainbow 中有多少方法是我们自己写的（实际我们只写了一个each），有多少是 include Enumerable 后获得的。

```ruby
2.5.0 :014 > Rainbow.instance_methods.count
 => 114
2.5.0 :015 > Rainbow.instance_methods(false).count
 => 1
2.5.0 :016 >
```

自己写的 class 相对特殊，可以使用 ruby 内建的class尝试，不过测试前要看看这个class是否只 include 了 Enumerable 这个 module

![](https://ws3.sinaimg.cn/large/006tNc79gy1fo6q6w79vwj309q050mx5.jpg)

```ruby
2.5.0 :016 > (Array.instance_methods - Array.instance_methods(false)).count
 => 83
2.5.0 :017 >
```

—

Some of the methods in Ruby’s enumerable classes are actually overwritten in those classes. For example, you’ll find implementations of map, select, sort, and other Enumerable instance methods in the source-code file array.c; the Array class doesn’t simply provide an each method and mix in Enumerable (though it does do that, and it gains behaviors that way). These overwrites are done either because a given class requires special behavior in the face of a given Enumerable method, or for the sake of efficiency. We’re not going to scrutinize all the overwrites. The main point here is to explore the ways in which all of the collection classes share behaviors and interface.

Enumerable 中的有些 methods 在某些 class 中是被 overwrite 了的，比如 map, select, sort 等一些方法在 Array 中是被重写的，而不是全都include enumerable 就直接使用的。这既是因为也许某些 class 需要一些特殊的功能，也可能是出于对运算效率的考虑。但我们的重点会放在 不同collections 是如何共享这些 methods 以及 接口的

-

**Enumerable boolean queries**

A number of Enumerable methods return true or false depending on whether one or more element matches certain criteria. Given an array states, containing the names of all the states in the United States of America, here’s how you might perform some of these Boolean queries:

![](https://ws2.sinaimg.cn/large/006tNc79gy1fo6r0kgkw5j30ld0bqq96.jpg)

假设名为 states 的 array 包含了所有美国的 州名称

1 Does the array include Louisiana?
判断是否包含一个州叫 Louisiana

2 Do all states include a space?
是否所有州的名字都包含空格

3 Does any state include a space?
有没有州的名字中包含一个空格的

4 Is there one, and only one, state with "West" in its name?
是否有且只有一个州的名字中包含 West

5 Are there no states with "East" in their names?
是否没有任何一个州的名字中包含 East

—

如果 collection 是 hash , key 是州全名，value 是缩写，那么上面的测试有所改变

Hash#include? 拿到的是 keys, hash的枚举操作会以键值对为基本单位

```ruby
# Does hash include Louisiana?
>> states.include?("Louisiana")  这个刚好不用变化

# Do all states include a space?
>> states.all { |state, abbr| state =~ / / }
state是key , abbr 是value(州名称缩写)

# Is there one , and only one, state with "West" in its name?
>> states.one? { |states, abbr| state =~ /West/ }


还有一个方式是使用 .keys 拿到所有的州名称，然后操作和 array 相同

# Do all states include a space?
>> states.keys.all? { |state, abbr| state =~ / / }
```

Generating the entire keys array in advance, rather than walking through the hash that’s already there, is slightly wasteful of memory. Still, the new array contains the key objects that already exist, so it only "wastes" the memory devoted to wrapping the keys in an array. The memory taken up by the keys themselves doesn’t increase.


基于已经存在的 hash ，用 keys 生成新的 array 有一点浪费内存，但是，这里多使用到的内存，只是将 key objects 包裹起来的那个 array 容器， 这些 key objects 本身并没有产生新的副本而浪费内存。

-

**hashes iterate with two-elements arrays**

在枚举 hash 时，如果只使用一个 block parameter 比如

hash.each { |key_value| # }

那么 每一个 key_value 会是一个 array 这和前面提到的 Ruby处理 hash 枚举操作的机制对应

```ruby
2.5.0 :022 > hash = Hash[1,2,3,4,5,6,7,8]
 => {1=>2, 3=>4, 5=>6, 7=>8}
2.5.0 :023 > hash.each { |mini_array| p mini_array }
[1, 2]
[3, 4]
[5, 6]
[7, 8]
 => {1=>2, 3=>4, 5=>6, 7=>8}
2.5.0 :024 >
```

—

set 的枚举操作和 array 很像，对array能进行的boolean query , set 几乎都能有相同的操作

但是对于 range 来说，则有些不同。

—

之前提到过 如果 range 的起点和终点都是 float 那么这个 range 会被视作是 无限的，如果起点和终点都是整数，那么range 则很像 array

```ruby
2.5.0 :026 > range = Range.new(1,10)
 => 1..10
2.5.0 :027 > range.one? { |n| n ==5 }
 => true
2.5.0 :028 > range.none? { |n| n % 2 == 0 }
 => false
2.5.0 :030 > infi_range = Range.new(1.0,10.0)
 => 1.0..10.0
2.5.0 :031 > infi_range.one? { |n| n == 5 }
Traceback (most recent call last):
        4: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        3: from (irb):31
        2: from (irb):31:in `one?'
        1: from (irb):31:in `each'
TypeError (can't iterate from Float)
2.5.0 :032 >
```

如果起始点都是 float ，使用 each 在语义上会变得没有意义，无限当中的每一个 在逻辑上存在漏洞，因此会返回 TypeError 。 注意不是 NoMethodError 这说明 each 存在于 Range class 中，但是不能处理 float 类型的 range

如果 range 的起点是 整数， 终点是 float , 此 range 仍然会被视作 整数range 最后一位浮点数会舍去小数点后数字，并把整数部分纳入 range 范围，因为原始的 float 始终是比舍去后的整数大的

```ruby
2.5.0 :035 > range = Range.new(1, 15.7)
 => 1..15.7
2.5.0 :036 > range.one? { |n| n == 15 }
 => true
2.5.0 :037 >
```

**Enumerable searching and selecting**

All of them are iterators: they all expect you to provide a code block. The code block is the selection filter.

所有的 enumerable searching and selecting 方法都需要跟随一个 block 作为过滤器

根据具体匹配情况，返回的值可能是单个 object , 可能是 array ， 也可能是 nil

-

find (detect)

返回**第一个**遇到的匹配项

```ruby
2.5.0 :041 > array = (1..9).to_a
 => [1, 2, 3, 4, 5, 6, 7, 8, 9]
2.5.0 :042 > array.find { |n| n > 2 }
 => 3
2.5.0 :043 > array.find { |n| n < 2 }
 => 1
2.5.0 :044 >
```

Arrays serve generically as the containers for most of the results that come back from enumerable selecting and filtering operations, whether or not the object being selected from or filtered is an array. There are some exceptions to this quasi-rule, but it holds true widely.

array 通常作为多个 enumerable selecting and filtering 结果的封装容器，虽然这不是绝对的，但多数情况下是按这个准则运行的

以前面的 class Rainbow 为例

```ruby
2.5.0 :001 > load './rainbow.rb'
 => true
2.5.0 :002 > r = Rainbow.new
 => #<Rainbow:0x00007ff52383cfc8>
2.5.0 :003 > r.select { |c| c.size == 6 }
 => ["orange", "yellow", "indigo", "violet"]
2.5.0 :004 > r.map { |c| c[0,3] }
 => ["red", "ora", "yel", "gre", "blu", "ind", "vio"]
2.5.0 :005 > r.drop_while { |c| c.size < 5 }
 => ["orange", "yellow", "green", "blue", "indigo", "violet"]
2.5.0 :006 > r
 => #<Rainbow:0x00007ff52383cfc8>
2.5.0 :007 >
```

只要过选择或过滤结果是 多个 那么结果都被封装在一个 array 中

—

The array is the most generic container and therefore the logical candidate for the role of universal result format. A few exceptions arise. A hash returns a hash from a select or reject operation. Sets return arrays from map, but you can call map! on a set to change the elements of the set in place. For the most part, though, enumerable selection and filtering operations come back to you inside arrays.

用array 封装 选择过滤结果有一些例外

hash 的 select 和 reject 操作返回的仍然是 hash

set 的 map 操作返回 array , 但是无法使用 map!

不过大多数情况下，多个返回值仍然使用 array 来封装，这是最符合逻辑的做法

```ruby
2.5.0 :009 > hash = Hash[1,2,3,4,5,6,7,8]
 => {1=>2, 3=>4, 5=>6, 7=>8}
2.5.0 :010 > hash.select { |key, value| key > 3 }
 => {5=>6, 7=>8}
```

—

find_all

返回所有找到的值

find_all 如果没有匹配，返回的不是nil 而是空的 array [ ]

```ruby
2.5.0 :017 > array = (1..9).to_a
 => [1, 2, 3, 4, 5, 6, 7, 8, 9]
2.5.0 :018 > array.find_all { |e| e > 5 }
 => [6, 7, 8, 9]
2.5.0 :019 >
```

-

(Arrays, hashes, and sets have a bang version, select!, that reduces the collection permanently to only those elements that passed the selection test. There’s no find_all! synonym; you have to use select!.)

find_all 没有 bang! 版本，如果想要 in-place 过滤操作，使用 select!

—

reject  , reject!
用来反向选择

```ruby
2.5.0 :019 > array
 => [1, 2, 3, 4, 5, 6, 7, 8, 9]
2.5.0 :020 > array.reject { |e| e > 5 }
 => [1, 2, 3, 4, 5]
2.5.0 :021 >
```

-

**get the hang of it 掌握窍门**

selecting on threequal matches with grep

http://ruby-doc.org/core-2.5.0/Enumerable.html#method-i-grep

The Enumerable#grep method lets you select from an enumerable object based on the case equality operator, ===. The most common application of grep is the one that corresponds most closely to the common operation of the command-line utility of the same name, pattern matching for strings:

grep 的执行基于 case equality operator ===

grep可以从 collection 中选择出符合条件的 元素，并总是返回 array

```ruby
2.5.0 :018 > colors
 => ["red", "orange", "yellow", "green", "blue", "indigo", "violet"]
2.5.0 :019 > colors.grep(/o/)
 => ["orange", "yellow", "indigo", "violet"]
2.5.0 :020 >
```

但 grep 有其他更强大的功能

```ruby
2.5.0 :022 > miscellany = [75,"hello",10..20,"bye",[1,2],[3,4,5],2..8,99]
 => [75, "hello", 10..20, "bye", [1, 2], [3, 4, 5], 2..8, 99]
2.5.0 :023 > miscellany.grep(String)
 => ["hello", "bye"]
2.5.0 :024 > miscellany.grep(Array)
 => [[1, 2], [3, 4, 5]]
2.5.0 :025 > miscellany.grep(Range)
 => [10..20, 2..8]
2.5.0 :026 > miscellany.grep(Integer)
 => [75, 99]
2.5.0 :027 > miscellany.grep(75..99)
 => [75, 99]
2.5.0 :028 > miscellany.grep(100..101)
 => []
```

在一个混合了多种 对象类型的array 中， 通过 grep 可以

给出 class 比如 String , 返回所有 String 实例, 给出 Range 则返回所有的 ranges

给出一个 range 则返回这个 range 范围内的integer数值

如果没有匹配项仍然返回 空 array

—

In general, the statement enumerable.grep(expression) is functionally equivalent to this:

实际上 grep() 操作进行的是下面这类操作

enumerable.select { |element| expression === element }


In other words, it selects for a truth value based on calling ===. In addition, grep can take a block, in which case it yields each element of its result set to the block before returning the results:

也可以说 grep 是在使用 === 进行过滤和选择操作

collection.grep(expression) { #block }

的形式都可以改写成 两个 block 串联的格式

collection.select { |item| expression === item }.map { #block }

注意第一个 block 中的 expression 在 === 之前

```ruby
2.5.0 :030 > colors
 => ["red", "orange", "yellow", "green", "blue", "indigo", "violet"]
2.5.0 :031 > colors.grep(/o/) { |c| c.capitalize }
 => ["Orange", "Yellow", "Indigo", "Violet"]
2.5.0 :032 > colors.select { |c| /o/ === c }.map { |x| x.capitalize }
 => ["Orange", "Yellow", "Indigo", "Violet"]
2.5.0 :033 >
```

—

grep_v 是反选版的 grep

—

Again, you’ll mostly see (and probably mostly use) grep as a pattern-based string selector. But keep in mind that grepping is pegged to case equality (===) and can be used accordingly in a variety of situations.

grep 最常用的情景是作为 string 内容的选择器

但要记住 grep 是基于 === 而工作的， 而 === 是一个适用范围很广的方法

![](https://ws2.sinaimg.cn/large/006tNc79gy1fo6tcfyq1tj30920dsdgy.jpg)

-

Whether carried out as select or grep or some other operation, selection scenarios often call for grouping of results into clusters or categories. The Enumerable #group_by and #partition methods make convenient provisions for exactly this kind of grouping.

select 和 grep 能够一次拿到多个结果。 group_by 和 partition 则可以用来重新组织产出的结果

group_by  返回的是一个 hash
你选择了一个维度来排序 collection 那么 key 会是以此维度为标准的探测结果，value 是得出结果所纳入的 elements

```ruby
2.5.0 :037 > colors
 => ["red", "orange", "yellow", "green", "blue", "indigo", "violet"]
2.5.0 :038 > colors.group_by { |c| c.size }
 => {3=>["red"], 6=>["orange", "yellow", "indigo", "violet"], 5=>["green"], 4=>["blue"]}
2.5.0 :039 >
```

在上面的 block 中， color 代表了 array 中每一个 颜色的string,
group_by … color.size 测量了所有单个 element 的字符数，然后将相同字符数的 elements 归为一个 array 作为对应 key 的 value

The block {|color| color.size } returns an integer for each color. The hash returned by the entire group_by operation is keyed to the various sizes (3, 4, 5, 6), and the values are arrays containing all the strings from the original array that are of the size represented by the respective keys.

-


The partition method is similar to group_by, but it splits the elements of the enumerable into two arrays based on whether the code block returns true for the element. There’s no hash, just an array of two arrays. The two arrays are always returned in true/false order.

`partition` 返回的不是 hash 而是 array 根据 block 中给出的条件，他将匹配 和 不匹配的 两组结果分别装到两个 array 中 然后总的封装到一个 array 中

```ruby
2.5.0 :039 > colors
 => ["red", "orange", "yellow", "green", "blue", "indigo", "violet"]
2.5.0 :040 > colors.partition { |c| c.size > 4 }
 => [["orange", "yellow", "green", "indigo", "violet"], ["red", "blue"]]
2.5.0 :041 >
```

来看一个利用 partition 的例子

```ruby
class Person

  attr_accessor :age

  def initialize(options)
    self.age = options[:age]
  end

  def teenager?
    (13..19) === age
  end

end
```

查找 teenagers

```ruby
2.5.0 :047 > people = 10.step(25,3).map { |n| Person.new(:age=>n) }
 => [#<Person:0x00007fecf0849ee8 @age=10>, #<Person:0x00007fecf0849e98 @age=13>, #<Person:0x00007fecf0849e48 @age=16>, #<Person:0x00007fecf0849df8 @age=19>, #<Person:0x00007fecf0849da8 @age=22>, #<Person:0x00007fecf0849d58 @age=25>]

2.5.0 :049 > teens = people.partition { |person| person.teenager? }
 => [[#<Person:0x00007fecf0849e98 @age=13>, #<Person:0x00007fecf0849e48 @age=16>, #<Person:0x00007fecf0849df8 @age=19>], [#<Person:0x00007fecf0849ee8 @age=10>, #<Person:0x00007fecf0849da8 @age=22>, #<Person:0x00007fecf0849d58 @age=25>]]
2.5.0 :050 > teens.class
 => Array
2.5.0 :051 > teens.each { |group| p group.size }
3
3
 => [[#<Person:0x00007fecf0849e98 @age=13>, #<Person:0x00007fecf0849e48 @age=16>, #<Person:0x00007fecf0849df8 @age=19>], [#<Person:0x00007fecf0849ee8 @age=10>, #<Person:0x00007fecf0849da8 @age=22>, #<Person:0x00007fecf0849d58 @age=25>]]
2.5.0 :052 >
```
10.step(25,3) 从10开始 以3为最小单位 数到 25

上面的例子中 people 拿到了所有 Person 的 instances

之后在使用 partition 配合 定义好的 teenagers? 方法进行过滤，将结果分为两个 subclasses

再进行后续操作

—

Collections are born to be traversed, but they also contain special-status individual objects: the first or last in the collection, and the greatest (largest) or least (smallest). Enumerable objects come with several tools for element handling along these lines.

collections 是为了被走访而生
但它先天具有几个特殊的状态点,比如

first

last

least

greatest

The object returned by first is the same as the first object you get when you iterate through the parent object. In other words, it’s the first thing yielded by each. In keeping with the fact that hashes yield key/value pairs in two-element arrays, taking the first element of a hash gives you a two-element array containing the first pair that was inserted into the hash (or the first key inserted and its new value, if you’ve changed that value at any point):


first 返回的结果事实上和 iterate 一个collection拿取的第一个对象相同, 换句话说，first 拿到的对象和 each 方法 yield 给 block 的是同一个对象。

```ruby
2.5.0 :059 > array
 => ["one", "two", "three", "four", "five"]
2.5.0 :060 > array.each do |e|
2.5.0 :061 >   p "The same!" if array.last == e
2.5.0 :062?>   p "The diff!" if array.last != e
2.5.0 :063?> end
"The diff!"
"The diff!"
"The diff!"
"The diff!"
"The same!"
 => ["one", "two", "three", "four", "five"]
2.5.0 :064 >
```

根据前面提到的 each 处理 hash 的方法是把每个键值对看做是一个小array,因此对应到 hash 时， first 返回的是一个 mini array

需要注意  Enumerable中并没有 last 这个 method, last只在 array 和 range 中有

![](https://ws4.sinaimg.cn/large/006tNc79gy1fo6u0nzv0ej309c057q3d.jpg)

这是因为对于遍历来说，开头总是在逻辑上合理的，有没有结尾则是不确定的

-

模拟一个掷骰子的 class

```ruby
class Die
  include Enumerable

  def each
    loop do
      yield rand(6) + 1
    end
  end

end
```

The loop uses the method Kernel#rand. Called with no argument, this method generates a random floating-point number n such that 0 <= n < 1. With an argument i, it returns a random integer n such that 0 <= n < i.

rand 会产生一个 0 到 1 之间的浮点数, 如果传入一个参数n，则返回一个 0 到 n(不含n) 之间的随机整数

But the main point is that Die#each goes on forever. If you’re using the Die class, you have to make provisions to break out of the loop. Here’s a little game where you win as soon as the die turns up 6:

但如果使用 each 进行遍历操作， 掷骰子的操作是不会停的，除非人为设置一个终止条件

```ruby
d = Die.new

d.each do |number|
  puts "You get number: #{number}."
  if number == 6
    puts "You win!"
    break
  end
end
```

输出结果

```ruby
⮀ ruby die.rb
You get number: 6.
You win!
 ⮀ ruby die.rb
You get number: 1.
You get number: 5.
You get number: 4.
You get number: 2.
You get number: 4.
You get number: 2.
You get number: 5.
You get number: 1.
You get number: 4.
You get number: 5.
You get number: 2.
You get number: 4.
You get number: 1.
You get number: 5.
You get number: 6.
You win!
 ⮀ ruby die.rb
You get number: 5.
You get number: 4.
You get number: 1.
You get number: 3.
You get number: 2.
You get number: 3.
You get number: 6.
You win!
 ⮀
```


For the same reason—the unreachability of the end of the enumeration—an enumerable class with an infinitely yielding each method can’t do much with methods like select and map, which don’t return their results until the underlying iteration is complete. Occasions for infinite iteration are, in any event, few; but observing the behavior and impact of an endless each can be instructive for what it reveals about the more common, finite case.

同样的，如果一个迭代过程没有终点，或说一个引入了 Enumerable 但是 each 方法中会无限 yielding 的 class, 是不能进行 select 或 map 操作的，这两个方法无法在底层的迭代计算完成前进行下一步。不过无限迭代的情况很少，但是观察each中可能存在的这种情况，能让我们更好理解'有限的情况'。

-

Keep in mind, though, that some enumerable classes do have a last method: notably, Array and Range. Moreover, all enumerables have a take method, a kind of generalization of first, and a companion method called drop.
许多可枚举的classes都有 `last` 方法，比如 Array 和 Range。但**所有的**可枚举对象都有 `take` 和 对应的 `drop` 方法

take 和 drop 是一组对应的方法

```ruby
2.5.0 :003 > infinite_range = Range.new(1.0, 10.0)
 => 1.0..10.0
2.5.0 :004 > infinite_range.take(2)
Traceback (most recent call last):
        4: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        3: from (irb):4
        2: from (irb):4:in `take'
        1: from (irb):4:in `each'
TypeError (can't iterate from Float)
2.5.0 :005 > enum_range = Range.new(1, 10)
 => 1..10
2.5.0 :006 > enum_range.take(2)
 => [1, 2]

2.5.0 :008 > enum_range
 => 1..10
2.5.0 :009 > enum_range.take
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):9
        1: from (irb):9:in `take'
ArgumentError (wrong number of arguments (given 0, expected 1))
```

take(n) 拿取 collection 中前 n 个元素 产生一个新副本

drop(n) 是前者的反选

```ruby
2.5.0 :013 > enum_range.drop(2)
 => [3, 4, 5, 6, 7, 8, 9, 10]
2.5.0 :014 > enum_range
 => 1..10
2.5.0 :015 >
```

—

另一对筛选元素的方法是

take_while

drop_while

`take_while` 从 collection 的第一个元素开始拿符合条件的元素，遇到第一次匹配失败时停止拿取。注意这个过程是线性加一次性的，和 select 不同。

```ruby
2.5.0 :038 > array
 => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
2.5.0 :039 > array.take_while { |x| x < 3 } # failed at 3, so took 1, 2
 => [1, 2]
2.5.0 :040 > array.take_while { |x| x > 3 } # failed at 1, so took nothing
 => []

2.5.0 :042 > array.drop_while { |x| x < 3 } # failed at 3, so dropped 1,2 left the rest
 => [3, 4, 5, 6, 7, 8, 9, 10]
2.5.0 :043 >
```

The take and drop operations are a kind of hybrid of first and select. They’re anchored to the beginning of the iteration and terminate once they’ve satisfied the quantity requirement or encountered a block failure.

注意 take/drop 和 select/find_all 这类方法的区别

take和drop 会在遇到  第一次 失败时终止，而select/find_all 则是找到collection 中所有符合条件的项

-

min 和 max 的工作默认基于 spaceship comparison operator

```ruby
2.5.0 :004 > array = (1..5).to_a
 => [1, 2, 3, 4, 5]
2.5.0 :005 > array.max
 => 5
2.5.0 :006 > array.min
 => 1
2.5.0 :007 > %w{ Ruby C APL Smalltalk }.min
 => "APL"
2.5.0 :008 >
```

上面的例子中 max 和 min 是在 string 元素之间的比较，比较的内容是开头字母的序数大小

```ruby
2.5.0 :024 > array
 => ["Ruby", "C", "APL", "Smalltalk"]
2.5.0 :025 > array.each do |e|
2.5.0 :026 >     puts e.ord
2.5.0 :027?>   end
82
67
65  # min
83
 => ["Ruby", "C", "APL", "Smalltalk"]
2.5.0 :028 >
```

Minimum and maximum are determined by the <=> (spaceship comparison operator) logic, which for the array of strings puts "APL" first in ascending order. If you want to perform a minimum or maximum test based on nondefault criteria, you can provide a code block:
由于 max 和 min 是基于 <=> 的逻辑，如果想要选择基于自定义的逻辑， 可以在后面跟一个 block 然后在内部重写 比较逻辑

```ruby
2.5.0 :036 > array.min { |l, r| l.size <=> r.size }
 => "C"
2.5.0 :037 > array.max { |l, r| l.size <=> r.size }
 => "Smalltalk"
2.5.0 :038 >
```
上面的方法要使用两个 block parameter 一个代表 space ship 左边的对象，一个代表右边

ruby 提供了方法来简化这种操作，那就是 max_by 和 min_by 方法

```ruby
2.5.0 :040 > array
 => ["Ruby", "C", "APL", "Smalltalk"]
2.5.0 :041 > array.min_by { |e| e.size }
 => "C"
2.5.0 :042 > array.min_by { |e| e[-1].ord }
 => "C"
2.5.0 :043 > array.max_by { |e| e[-1].ord }
 => "Ruby"
2.5.0 :044 >
```
后两种情况是基于每个元素的倒数第一个字母的序数

-

Keep in mind that the min/max family of enumerable methods is always available, even when using it isn’t a good idea. You wouldn’t want to do this, for example:

min/max 的可使用范围很广，但并不是任何时候都适合使用

```ruby
2.5.0 :002 > die = Die.new
 => #<Die:0x00007fc88a1185c8>
2.5.0 :003 > die.max

^CTraceback (most recent call last):
        6: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        5: from (irb):3
        4: from (irb):3:in `max'
        3: from /Users/caven/Notes & Articles/Note of Rubyist/code examples/die.rb:6:in `each'
        2: from /Users/caven/Notes & Articles/Note of Rubyist/code examples/die.rb:6:in `loop'
        1: from /Users/caven/Notes & Articles/Note of Rubyist/code examples/die.rb:8:in `block in each'
IRB::Abort (abort then interrupt!)
2.5.0 :004 >
```

记住 max/min 对所有 include enumerable 的 class 都有效
但对于无线循环或含有不确定性的情况来说仍然是无意义的，如果执行这类操作，程序将被挂起。

The infinite loop with which `Die#each` is implemented won’t allow a maximum value ever to be determined. Your program will hang.

—

对 hash 来说， 默认情况下 min / max 以 key 作为比较标准， 不过在 min_by / max_by 的帮助下，我们仍然可以自己决定用什么作为比较标准

```ruby
2.5.0 :040 > hash
 => {"a"=>"Java", "b"=>"Ruby", "c"=>"Html", "d"=>"Coffee"}

2.5.0 :042 > hash.min
 => ["a", "Java"]

2.5.0 :045 > hash.max
 => ["d", "Coffee"]

2.5.0 :046 > hash.min_by { |key, value| key.object_id }
 => ["d", "Coffee"]

2.5.0 :047 > hash.max_by { |key, value| value.length }
 => ["d", "Coffee"]
2.5.0 :048 >
```

记得 each 处理hash的方法是会把 每一个键值对看做一个小array

从上面返回的结果也可以看出这种对待方式

-


—

At this point, we’ve looked at examples of each methods and how they link up to a number of methods that are built on top of them. It’s time now to look at some methods that are similar to each but a little more specialized. The most important of these is map. In fact, map is important enough that we’ll look at it separately in its own section. First, let’s discuss some other each relatives.

目前介绍的 methods 都是以each 为基础的构建起来的， Enumerable 中的另一个与 each 很类似的 方法 map 值得专门介绍。先来介绍一些与 each 相关的methods.

—

relatives of each

—

Enumerable makes several methods available to you that are similar to each, in that they go through the whole collection and yield elements from it, not stopping until they’ve gone all the way through (and in one case, not even then!). Each member of this family of methods has its own particular semantics and niche. The methods include reverse_each, each_with_index, each_slice, each_cons, cycle, and inject. We’ll look at them in that order.

Enumerable module 中定义了几个与 each 类似的 methods。

他们也会走访collection并且从中yield元素出来，他们也会遍历整个collection, 每一个 method 都有自己特有的作用和地位。

```ruby
reverse_each
each_with_index
each_slice
each_cons
cycle
inject
```

—

revers_each 会首先反转整个 collection 然后再遍历里面的元素

```ruby
2.5.0 :052 > [1,2,3,4].reverse_each { |e| p e * 10 }
40
30
20
10
 => [1, 2, 3, 4]
```
注意不要将 revers_each 用在无限集合中，因为你不知道终点在哪儿，反转就不可能

—

each_with_index

常用于 array

需要注意的是并不是所有 collection 都有 index

比如 hash 虽然使用 each_with_index 可以进行 类似 index 的操作，但实际上 hash 本身并没有index 在使用 each_index 测试时可以看到这一点

```ruby
=> {"a"=>"Java", "b"=>"Ruby", "c"=>"Html", "d"=>"Coffee"}
2.5.0 :064 > hash.each_with_index { |(key, value), index| p "#{index} :#{key} --> #{value} " }
"0 :a --> Java "
"1 :b --> Ruby "
"2 :c --> Html "
"3 :d --> Coffee "
=> {"a"=>"Java", "b"=>"Ruby", "c"=>"Html", "d"=>"Coffee"}
2.5.0 :065 >

2.5.0 :065 > hash.each_index
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):65
NoMethodError (undefined method `each_index' for {"a"=>"Java", "b"=>"Ruby", "c"=>"Html", "d"=>"Coffee"}:Hash
Did you mean?  each_with_index)
2.5.0 :066 >
```

each_with_index 可以用，但它有点被弃用的倾向，现在更多的是在使用 each 加上 with_index， each.with_index()

如果with_index() 传入参数，可以规定 index 从哪个数字开始

这样当需要 index 变为从1开始时， 就不需要单独去做一次  + 1 的处理

```ruby
2.5.0 :069 > hash.each.with_index(101) { |(key, value), index| p "#{index} :#{key} --> #{value} " }
"101 :a --> Java "
"102 :b --> Ruby "
"103 :c --> Html "
"104 :d --> Coffee "
 => {"a"=>"Java", "b"=>"Ruby", "c"=>"Html", "d"=>"Coffee"}
2.5.0 :070 >
```

-

对 array [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] 来说

each_slice(n) 每次拿下n个元素，中间没有重叠

each_cons(n) 也是每次拿n个元素，但每次只往后移动一步，这样每次拿到的元素都有 n-1 个与之前的重合

```ruby
2.5.0 :075 > array
 => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
2.5.0 :076 > array.each_slice(3) { |sub_array| p sub_array }
[1, 2, 3]
[4, 5, 6]
[7, 8, 9]
[10]
 => nil
2.5.0 :077 > array.each_cons(5) { |sub_array| p sub_array }
[1, 2, 3, 4, 5]
[2, 3, 4, 5, 6]
[3, 4, 5, 6, 7]
[4, 5, 6, 7, 8]
[5, 6, 7, 8, 9]
[6, 7, 8, 9, 10]
 => nil
2.5.0 :078 >
```

-

cycle()  如果不传 参数 会无限走访一个 collection

如果给出指定整数，那么将会走访n遍

以此 class 为例

```ruby
class PlayingCard

  SUITS = %w[clubs diamonds hearts spades] #4 花色
  RANKS = %w[2 3 4 5 6 7 8 9 10 J Q K A] #13 数字

  class Deck
    attr_reader :cards
    def initialize(n=1)
      @cards = []
      SUITS.cycle(n) do |s|
        RANKS.cycle(1) do |r|
          @cards << "#{r} of #{s}"
        end
      end
    end
  end

end
```

默认情况下 n = 1， cycle(1) 遍历一次

如果给出 3 那么牌的张数就变为之前的 3倍

```ruby
2.5.0 :010 > cards = PlayingCard::Deck.new
 => #<PlayingCard::Deck:0x00007fbf040bc7d0 @cards=["2 of clubs", "3 of clubs", "4 of clubs", "5 of clubs", "6 of clubs", "7 of clubs", "8 of clubs", "9 of clubs", "10 of clubs", "J of clubs", "Q of clubs", "K of clubs", "A of clubs", "2 of diamonds", "3 of diamonds", "4 of diamonds", "5 of diamonds", "6 of diamonds", "7 of diamonds", "8 of diamonds", "9 of diamonds", "10 of diamonds", "J of diamonds", "Q of diamonds", "K of diamonds", "A of diamonds", "2 of hearts", "3 of hearts", "4 of hearts", "5 of hearts", "6 of hearts", "7 of hearts", "8 of hearts", "9 of hearts", "10 of hearts", "J of hearts", "Q of hearts", "K of hearts", "A of hearts", "2 of spades", "3 of spades", "4 of spades", "5 of spades", "6 of spades", "7 of spades", "8 of spades", "9 of spades", "10 of spades", "J of spades", "Q of spades", "K of spades", "A of spades"]>
2.5.0 :011 > cards = PlayingCard::Deck.new.cards.count
 => 52
2.5.0 :012 > cards = PlayingCard::Deck.new(3).cards.count
 => 156
2.5.0 :013 >
```

cycle(n) 的效果跟 n 个 each loop 嵌套是一样的(可以用n.times 嵌套 each)

-

inject 和 reduce 是累加计算方法(alias)
http://ruby-doc.org/core-2.5.0/Enumerable.html#method-i-reduce

block 接受两个参数，第一个参数是起始累加值，第二个代表每一个 item

如果不给出参数，默认从0开始算

```ruby
2.5.0 :015 > [1,2,3,4].inject(0) { |acc, e| p acc }
0
0
0
0
 => 0
2.5.0 :017 > [1,2,3,4].inject(0) { |acc, e| p acc + e }
1
3
6
10
 => 10
2.5.0 :018 > [1,2,3,4].reduce(5) { |acc, e| p acc }
5
5
5
5
 => 5
2.5.0 :019 > [1,2,3,4].reduce(5) { |acc, e| p acc + e }
6
8
11
15
 => 15
2.5.0 :020 >
```

**map (collect)**

注意 `map` 返回的是一个新的 array 副本

`each` 返回的是 receiver 本身

```ruby
= Enumerable.map

(from ruby site)
------------------------------------------------------------------------------
  enum.map     { |obj| block } -> array
  enum.map                     -> an_enumerator

------------------------------------------------------------------------------

Returns a new array with the results of running block once for every
element in enum.

If no block is given, an enumerator is returned instead.

  (1..4).map { |i| i*i }      #=> [1, 4, 9, 16]
  (1..4).collect { "cat"  }   #=> ["cat", "cat", "cat", "cat"]


(END)
```

map 是有写在 Enumerable 中的， 但 each 没有，记得之前提到了使一个class获得enumerability 的方式是先 include Enumerable 然后在这个 class 中定义 each 方法规定遍历操作每一次 yield 什么东西给 block

`ri Enumerable.each`

```ruby
Enumerable.each not found, maybe you meant:

Enumerable#each_cons
Enumerable#each_entry
Enumerable#each_slice
Enumerable#each_with_index
Enumerable#each_with_object
(END)

```

Whatever enumerable it starts with, map always returns an array. The returned array is always the same size as the original enumerable. Its elements consist of the accumulated result of calling the code block on each element in the original object in turn.

不管 collection 是什么， map 返回的总是 array， 而且array 中的元素数量总是和之前 collection 中原有的相同

map 将 collection 中每一个元素经过 block 的计算后放到原来的位置，但注意他使用的不是 replace 而是建了新的副本。

使用 &符号加上 method名称的 :symbol 作为map后的参数，可以省去后面写 block 的代码
`each` 使用&:method 也可以对内容元素进行操作，但要记得each的最终返回值是receiver itself所以看到的结果好像是没有变化的

```ruby
2.5.0 :003 > names = %w{ruby html java coffee}
 => ["ruby", "html", "java", "coffee"]
2.5.0 :004 > names.map(&:capitalize)
 => ["Ruby", "Html", "Java", "Coffee"]
2.5.0 :005 > names.each(&:capitalize)
 => ["ruby", "html", "java", "coffee"]
2.5.0 :006 > names.each(p &:capitalize)
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):6
        1: from (irb):6:in `each'
ArgumentError (wrong number of arguments (given 1, expected 0))
2.5.0 :007 >
```

map 和 each 的一个重大区别是

map 返回的是每一次block返回值构成的 新object

each 返回的是collection 本身，虽然中间每一步都有计算，但它没有保存任何东西，算过了就丢掉了

如果在 map 的block 中使用了 puts ，而最后返回的结果是每一次 block 执行的返回值（return value），那么得到的将会是一整个 array 的 nil

因为 puts 返回的总是 nil

```ruby
2.5.0 :009 > puts 1
1
 => nil
2.5.0 :010 > array = [1,2,3,4]
 => [1, 2, 3, 4]
2.5.0 :011 > array.map { |e| e * 10 }
 => [10, 20, 30, 40]
2.5.0 :012 > array.map { |e| puts e * 10 }
10
20
30
40
 => [nil, nil, nil, nil]
2.5.0 :013 > p 1
1
 => 1
2.5.0 :014 > array.map { |e| p e * 10 }
10
20
30
40
 => [10, 20, 30, 40]
2.5.0 :015 >
```

-

string 作为'准collection'的情况

-

bit 指计算机的二进制位

(Computing)a unit of information expressed as either a 0 or 1 in binary notation
(计算机)比特，二进制位


byte 指的是 字节，作为储存单元的一组字符串

: a unit of computer information that is equal to eight bits — see also gigabyte, kilobyte, megabyte

—

You can iterate through the raw bytes or the characters of a string using convenient iterator methods that treat the string as a collection of bytes, characters, code points, or lines. Each of these four ways of iterating through a string has an each–style method associated with it. To iterate through bytes, use each_byte:

我们可以以字节byte为单位或者以单个字母为单位处理一个字串，以类似 collection 的方式对待 string 。

字节

字母

字母编码号

每一行

都可以作为处理单位

-

each_byte 可以拿到字串中所有1个字节的字符的 序数

```ruby
2.5.0 :007 > "s".bytesize
 => 1
2.5.0 :008 > "1".bytesize
 => 1
2.5.0 :009 > "1".ord
 => 49
2.5.0 :010 > "a".ord
 => 97
2.5.0 :011 > "1abc".each_byte { |b| p b }
49
97
98
99
 => "1abc"
2.5.0 :012 >
```

each_char 则拿每个单独的字母

```ruby
2.5.0 :012 > "1abc".each_char { |b| p b }
"1"
"a"
"b"
"c"
 => "1abc"
2.5.0 :013 >
```

each_codepoint 拿的是单个 字母或符号 注意不是每一个符号的长度都是 1 byte 所以 each_byte 拿到一个多字节符号会将其拆解为byte长度的多个编号，而 codepoint 识别的是content 层级的单独字母符号

Iterating by code point provides character codes (integers) at the rate of exactly one per character:

```ruby
2.5.0 :013 > "£".bytesize
 => 2
2.5.0 :014 > "€".bytesize
 => 3
2.5.0 :015 > "100€".each_byte { |b| p b }
49
48
48
226
130
172
 => "100€"
2.5.0 :016 > "100€".each_codepoint { |b| p b }
49
48
48
8364
 => "100€"
2.5.0 :017 >
```

如果使用 each_byte

那么 "." 点号算一个 byte

而 "€" 则会被拆成三个 byte

而使用 each_codepoint 则两个符号都只视作一个独立对象

Due to the encoding, the number of bytes is greater than the number of code points (or the number of characters, which is equal to the number of code points).

由于字符集编码的原因，上面例子中总的字节数会比总的code point（字面上的字符数量）大，因为有的字符从byte层面看不止一个 byte 的长度, 而 code point 是有几个字符就算几个。

-

The string is split at the end of each line—or, more strictly speaking, at every occurrence of the current value of the global variable $/. If you change this variable, you’re changing the delimiter for what Ruby considers the next line in a string:

ruby 是以换行符号(默认是`\n`)来识别每一行的，更准确的说是以 global variable $/  来作为识别点的，如果我们修改 $/ 的值，就可以 overwrite 换行符号

默认情况下的行识别

```ruby
2.5.0 :022 > string
 => "Hello.\nI am Ruby.\nWho are u?"
2.5.0 :023 > string.each_line { |l| puts l }
Hello.
I am Ruby.
Who are u?
 => "Hello.\nI am Ruby.\nWho are u?"
2.5.0 :024 >
```

覆盖 `$\` 后

```ruby
2.5.0 :032 > new_string.each_line { |l| puts l }
Hello.%%
I am Ruby.%%
Who are u?
 => "Hello.%%I am Ruby.%%Who are u?"
2.5.0 :033 > $/
 => "%%"
2.5.0 :034 > new_string.each_line { |l| puts l.chomp }
Hello.
I am Ruby.
Who are u?
 => "Hello.%%I am Ruby.%%Who are u?"
2.5.0 :035 >
```
但这样改写会在每一行后留下原来的换行符号?

—

Even though Ruby strings aren’t enumerable in the technical sense (String doesn’t include Enumerable), the language thus provides you with the necessary tools to traverse them as character, byte, code point, and/or line collections when you need to.

虽然 string 并不具有 enumerable 属性，也没有 include Enumerable , ruby也同样让我们能以类似 collection 的方式来对待string

之前提到的
```ruby
each_byte
each_char
each_copoint
each_line
```
都是在拆解一个字串对象

ruby 还提供了 复数形式的 methods 让我们可以直接以 array 形式，拿到拆解指定单元后组成的新array
```ruby
bytes
chars
codepoints
lines
```

```ruby
2.5.0 :001 > string = "Hello.\nI am Ruby.\nWho are u?"
 => "Hello.\nI am Ruby.\nWho are u?"
2.5.0 :002 > string.lines
 => ["Hello.\n", "I am Ruby.\n", "Who are u?"]
2.5.0 :003 > string.bytes
 => [72, 101, 108, 108, 111, 46, 10, 73, 32, 97, 109, 32, 82, 117, 98, 121, 46, 10, 87, 104, 111, 32, 97, 114, 101, 32, 117, 63]
2.5.0 :004 > string.chars
 => ["H", "e", "l", "l", "o", ".", "\n", "I", " ", "a", "m", " ", "R", "u", "b", "y", ".", "\n", "W", "h", "o", " ", "a", "r", "e", " ", "u", "?"]
2.5.0 :005 > string.codepoints
 => [72, 101, 108, 108, 111, 46, 10, 73, 32, 97, 109, 32, 82, 117, 98, 121, 46, 10, 87, 104, 111, 32, 97, 114, 101, 32, 117, 63]
2.5.0 :006 >
```

-

**Sorting enumerables**

-


If you have a class, and you want to be able to arrange multiple instances of it in order, you need to do the following:
1.  Define a comparison method for the class (<=>).
2.  Place the multiple instances in a container, probably an array.
3.  Sort the container.
The key point is that although the ability to sort is granted by Enumerable, your class doesn’t have to mix in Enumerable. Rather, you put your objects into a container object that does mix in Enumerable. That container object, as an enumerable, has two sorting methods, sort and sort_by, which you can use to sort the collection.


如果你有一个自定义的 class 而你想要对这个 class 下的多个 instances 进行排序，那么需要三步设置

1 定义好 spaceship operator <=>

2 将你要排序的 instances 放入array 或其他 container 中

3 最后进行排序

需要注意的是，虽然排序的方法是在 enumerable module 中的，但是在你自定义的 class 中并不需要 incldue 它， 因为在排序前你需要把你的 instances 放入 ruby 的 collection 中，而ruby的 collection 默认都include了 enumerable

对于排序操作来说 主要的是 sort 和 sort_by 这个两个方法，大多数排序都是在 array 中进行的。只有少量案例会在 hash 中，返回的是 两个元素的mini array 的 nested array ——是以hash中的key或者其他标准进行的排序的

—

But what if you want to sort, say, an array of Painting objects?

```ruby
>> [pa1, pa2, pa3, pa4, pa5].sort
```

For paintings to have enough knowledge to participate in a sort operation, you have to define the spaceship operator (see section 7.6.2): Painting#<=>. Each painting will then know what it means to be greater or less than another painting, and that will enable the array to sort its contents. Remember, it’s the array you’re sorting, not each painting; but to sort the array, its elements have to have a sense of how they compare to each other. (You don’t have to mix in the Comparable module; you just need the spaceship method. We’ll come back to Comparable shortly.)

如果现在有一个 Painting class 中的 instance 需要进行排序。我们必须首先定义好 `<=>`。 之后每个 instance 就会知道他们和其他 instance 之间的大小比较是基于什么标准的，接着一个array的painting instances 就可以进行排序。 记住你是在对 array 中所有对象进行排序，不是单独的instance，只不过为了给array进行排序，你需要让其中的元素知道相互之间应该怎么比较。（你不需要 include Comparable, 只需要定义好<=>）

Let’s say you want paintings to sort in increasing order of price, and let’s assume paintings have a price attribute. Somewhere in your Painting class you would do this:

加入我们想让 paitings 以 价格 这个属性作为排序标准，那么我们可以：

```ruby
def <=>(other_painting)
  self.price <=> other_painting.price
end   
```

对于 integer 或 字母顺序来说， 排序的逻辑是很简单的，也容易实现，但如果想要自定义排序标准，则需要重新定义 spaceship operator <=>  设置好比较的内容是什么

比如 class Person 有三个 attributes :

name

age

height

那么这三个属性都可以作为排序的标准，需要手动指定作为标准的是哪个属性

```ruby
class Person

  attr_accessor :name, :age, :height

  def initialize(name)
    @name = name
  end

  def <=>(another_person)
    self.height <=> another_person.height
  end
end

p1 = Person.new("One")
p1.age = 22
p1.height = 180

p2 = Person.new("Two")
p2.age = 25
p2.height = 179

p3 = Person.new("Three")
p3.age = 33
p3.height = 176

p4 = Person.new("Four")
p4.age = 18
p4.height = 199

[p1,p2,p3,p4].sort.map { |person| p person.name + ", height: #{person.height}" }

```

上面的例子中将 height 作为了比较标准

```ruby
by spaceship.rb
"Three, height: 176"
"Two, height: 179"
"One, height: 180"
"Four, height: 199"
```

A more fleshed-out account of the steps involved might go like this:

1.  Teach your objects how to compare themselves with each other, using <=>.

2.  Put those objects inside an enumerable object (probably an array).

3.  Ask that object to sort itself. It does this by asking the objects to compare themselves to each other with <=>.

If you keep this division of labor in mind, you’ll understand how sorting operates and how it relates to Enumerable.

如果用文字来详细描述：

1 “教会”对象们如何在相互之间进行比较(这步实际是在定义一对一的比较逻辑)

2 将这些要排序的对象放入 具有被走访能力的容器

3 进行比较排序

-

**Where the Comparable module fits into enumerable sorting (or doesn’t)**

When we first encountered the spaceship operator, it was in the context of including Comparable and letting that module build its various methods (>, <, and so on) on top of <=>. But in prepping objects to be sortable inside enumerable containers, all we’ve done is define <=>; we haven’t mixed in Comparable.

第一次见到 `<=>` 时，是我们 include Comparable 之后定义 <=> 来使自己写的 class 下的 instance 能够使用各种用于比较的方法。

但如果我们只是想把 instances 放入容器进行排序，那么就只需要定义好 spaceship

The whole picture fits together if you think of it as several separate, layered techniques:

整幅画面是这样的：

If you define <=> for a class, then instances of that class can be put inside an array or other enumerable for sorting.
如果你为一个class定义了 <=> ，那么这个class中的实例就可以放入具有枚举功能的容器中进行内部排序。

If you don’t define <=>, you can still sort objects if you put them inside an array and provide a code block telling the array how it should rank any two of the objects. (This is discussed next in section 10.8.2.)
如果你没有定义 <=> ，但你把多个实例放入一个array中使用 sort 方法，但在后面跟上带有 <=> 逻辑的block，那么也可以进行排序。

If you define <=> and also include Comparable in your class, then you get sortability inside an array and you can perform all the comparison operations between any two of your objects (>, <, and so on), as per the discussion of Comparable in chapter 9.
如果你既定义了 <=> 又 include 了 Comparable。那么你同时获得了排序功能和单个instance 之间的各种对比方法。

—

<=> 一个只能进行排序
<=> 加上 Comparable 既能比较，又能排序

—

**Defining sort-order logic with a block**

另一种 给出排序规则的方法是 sort 后跟一个 block, 接受两个参数，分别代表被比较的两个对象 然后把比较对象置于 <=> 两边

如果 class 中本就定义过了 <=>  那么这个方法会覆盖掉之前的定义

以前面的 class Person 为例

我们去掉原来定义的 <=> ，改用 携带spaceship逻辑的block 来实现排序

```ruby
class Person

  attr_accessor :name, :age, :height

  def initialize(name)
    @name = name
  end

 # def <=>(another_person)
 #   self.height <=> another_person.height
 # end
end


p1 = Person.new("One")
p1.age = 22
p1.height = 180

p2 = Person.new("Two")
p2.age = 25
p2.height = 179

p3 = Person.new("Three")
p3.age = 33
p3.height = 176

p4 = Person.new("Four")
p4.age = 18
p4.height = 199

# [p1,p2,p3,p4].sort.map { |person| p person.name }
r = [p1,p2,p3,p4].sort do |a,b|
  a.age <=> b.age
end

r.map { |person| p "#{person.name}, age: #{person.age}" }
```

结果

```ruby
ruby spaceship.rb
"Four, age: 18"
"One, age: 22"
"Two, age: 25"
"Three, age: 33"
```

这个例子中 class 中没有定义 <=> 而是直接用一个 block 来做了这件事,告诉ruby 使用 age 进行排序

当然这里也可以写成 { #block } 形式

[p1,p2…].sort { |a,b| a.age <=> b.age }

You can use this code-block form of sort to handle cases where your objects don’t have a <=> method and therefore don’t know how to compare themselves to each other. It can also come in handy when the objects being sorted are of different classes and by default don’t know how to compare themselves to each other. Integers and strings, for example, can’t be compared directly: an expression like "2" <=> 4 causes a fatal error. But if you do a conversion first, you can pull it off:

这种block 中嵌入 <=> 定义的方法既可以用在 class 中没有定义 <=> 的情况，也可以用在比较对象默认情况下不具有可比性的情况，比如 string 和 integer 的比较

["2",1,5,"3",4,"6"] 这个array 中既含有 string 数值，也含有 integer 数字， 如果直接进行排序或比较，ruby不知道该怎么做

```ruby
2.5.0 :001 > ["2", 1.5, "3", 4, "6"].sort
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):1
        1: from (irb):1:in `sort'
ArgumentError (comparison of String with 1.5 failed)
2.5.0 :002 > ["2", 1.5, "3", 4, "6"].sort { |a, b| a.to_i  <=> b.to_i}
 => [1.5, "2", "3", 4, "6"]
```

可以把所有元素进行预处理之后再进行排序

注意 block 中的类型转换 to_i to_s 等操作并不会改变被排序的对象本身，而且最后返回的结果各个子元素仍然保持着自身原有的类型， integer 仍然是 integer ， string 仍然是 string

sort 方法返回的是新的 array 没有改变 receiver 。只有bang！版本的 sort! 才会这么做

```ruby
sort → new_ary
sort { |a, b| block } → new_ary
```

—

sort_by 是 sort + block 的变形版

它必须要在后面跟一个 block

但只需要一个 block parameter 定义好 比较排序 之前的预处理使用什么操作

```ruby
2.5.0 :004 > ["2", 1.5, "3", 4, "6"].sort_by { |e| e.to_i }
 => [1.5, "2", "3", 4, "6"]
2.5.0 :005 >
```

也可以使用 &:method 简化代码

```ruby
2.5.0 :006 > ["2", 1.5, "3", 4, "6"].sort_by(&:to_i)
 => [1.5, "2", "3", 4, "6"]
2.5.0 :007 > ["2", 1.5, "3", 4, "6"].sort_by(&:to_s)
 => [1.5, "2", "3", 4, "6"]
2.5.0 :008 >
```

All we have to do in the block is show (once) what action needs to be performed to prep each object for the sort operation. We don’t have to call to_i on two objects; nor do we need to use the <=> method explicitly.

  —

  Enumerator

  Enumerators and the next dimension of enumerability

  —

  An iterator is a method that yields one or more values to a code block. An enumerator is an object, not a method.

  iterator 是一个指的 method 比如 each， map 等
  enumerator 指的是 准备(进行遍历的)状态的 object


  At heart, an enumerator is a simple enumerable object. It has an each method, and it employs the Enumerable module to define all the usual methods—select, inject, map, and friends—directly on top of its each.

  一个 enumerator 是一个简单的具有遍历性质的对象，它拥有 each 方法，它雇用 enumerable module 来获得各种建立在 each 之上的方法

  —

An enumerator isn’t a container object. It has no “natural” basis for an each operation, the way an array does (start at element 0; yield it; go to element 1; yield it; and so on). The each iteration logic of every enumerator has to be explicitly specified. After you’ve told it how to do each, the enumerator takes over from there and figures out how to do map, find, take, drop, and all the rest.

一个 enumerator 不是一个容器对象，比如 array , 他不具有 array 的自然属性，比如有从 0 开始的 index。

each方法如何走访这个 enumerator 需要明确指出，之后才能进行其他的 map find take drop 这些相关的操作。


An enumerator is like a brain in a science-fiction movie, sitting on a table with no connection to a body but still able to think. It just needs an “each” algorithm, so that it can set into motion the things it already knows how to do. And this it can learn in one of two ways: either you call Enumerator.new with a code block, so that the code block contains the each logic you want the enumerator to follow; or you create an enumerator based on an existing enumerable object (an array, a hash, and so forth) in such a way that the enumerator’s each method draws its elements, for iteration, from a specific method of that enumerable object.

注意 enumerator 并不是一定要在 如有被走访能力的 collection 的基础上才能生成，比如 array hash , 我们现在是在单独谈 enumerator 这个 Class

一个 enumerator 就像一颗科幻电影中放置在桌子上的没有身体的大脑，虽然不能指挥身体，但它具有思考和学习能力，他所需要的只是一个 each 算法的植入，在这个算法基础上他就能知道很多事情该怎么做。

一个空白大脑(enumerator)获得each算法的方式有两种：

1 直接使用 Enumerator.new { #block } ， 在 block 中植入 each 的逻辑

2 在本身具有 enumerable 的 collection 的基础上生长出来，这些collection 原本就已经定义好了各自的 each 所以可以直接拿来用

—

主要的篇幅会放在后者，如果第一个方法理解起来太难，可以跳过。

—

使用 new 新建一个 enumerator 实例对象

```ruby
2.5.0 :010 > e = Enumerator.new do |y|
2.5.0 :011 >   y << 1
2.5.0 :012?>   y << 2
2.5.0 :013?>   y << 3
2.5.0 :014?> end
 => #<Enumerator: #<Enumerator::Generator:0x00007fab37980820>:each>
2.5.0 :015 >
```

y是什么？

y is a yielder, an instance of Enumerator::Yielder, automatically passed to your block. Yielders encapsulate the yielding scenario that you want your enumerator to follow. In this example, what we’re saying is when you (the enumerator) get an each call, please take that to mean that you should yield 1, then 2, then 3. The << method (in infix operator position, as usual) serves to instruct the yielder as to what it should yield. (You can also write y.yield(1) and so forth, although the similarity of the yield method to the yield keyword might be more confusing than it’s worth.) Upon being asked to iterate, the enumerator consults the yielder and makes the next move—the next yield—based on the instructions that the yielder has stored.

y是一个产出器(yielder)， Enumerator::Yielder 的实例
他的作用是设置 enumerator 每次拿出来处理的是什么东西, 或说枚举时拿出元素的顺序
当 enumerator 要进行走访操作时，他会咨询y 这个yielder 每一步拿出什么来，这些内容也就是之前我们存在yielder 当中的内容

![](https://ws4.sinaimg.cn/large/006tKfTcgy1fo8tpcgqj3j309e02xt8o.jpg)

注意 y 只是作为 block parameter 不是必须用 y

```ruby
2.5.0 :002 > e = Enumerator.new do |s|
2.5.0 :003 >     s << 1
2.5.0 :004?>   s << 2
2.5.0 :005?>   s << 3
2.5.0 :006?>   end
 => #<Enumerator: #<Enumerator::Generator:0x00007fd38091dd08>:each>
2.5.0 :007 >
2.5.0 :008 > e.to_a
 => [1, 2, 3]
2.5.0 :009 >
```

如果对 enumerator 实例 e 进行其他操作

```ruby
2.5.0 :016 > e.class
 => Enumerator
2.5.0 :017 > e.to_a
 => [1, 2, 3]
2.5.0 :018 > e.map { |x| x * 10 }
 => [10, 20, 30]
2.5.0 :019 > e.select { |x| x > 1 }
 => [2, 3]
2.5.0 :020 > e.take(2)
 => [1, 2]
2.5.0 :021 > p e
#<Enumerator: #<Enumerator::Generator:0x00007fab37980820>:each>
 => #<Enumerator: #<Enumerator::Generator:0x00007fab37980820>:each>
2.5.0 :022 >
```

我们可以把之前创建 enumerator 的中间三步写成 block

```ruby
e = Enumerator.new do |y|
  (1..3).each { |n| y << n }
end
```

注意我们不是直接送信息给 生成enumerator的block，而是送给 yielder

```ruby
2.5.0 :010 > ee = Enumerator.new do
2.5.0 :011 >     yield 1
2.5.0 :012?>   yield 2
2.5.0 :013?>   yield 3
2.5.0 :014?>   end
 => #<Enumerator: #<Enumerator::Generator:0x00007fd38108b180>:each>
2.5.0 :015 >
2.5.0 :016 > ee.to_a
Traceback (most recent call last):
        6: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        5: from (irb):16
        4: from (irb):16:in `to_a'
        3: from (irb):16:in `each'
        2: from (irb):16:in `each'
        1: from (irb):11:in `block in irb_binding'
LocalJumpError (no block given (yield))
2.5.0 :017 >
```

Rather, you populate your yielder (y, in the first examples) with specifications for how you want the iteration to proceed at such time as you call an iterative method on the enumerator.

你将执行标准植入了yielder 这个顾问，这样 enumerator 就知道在执行走访类方法时怎么做

—

Every time you call an iterator method on the enumerator, the code block gets executed once. Any variables you initialize in the block are initialized once at the start of each such method call. You can trace the execution sequence by adding some verbosity and calling multiple methods:

每当对 enumerator 执行走访类方法时，Enumerator.new do |y|的block 都会被执行一次。任何在 block 中初始化的变数，会在每一次执行某个迭代方法时被再次初始化。

我们可以在 block 内部放入一行印出信息的代码要验证block的执行

```ruby
2.5.0 :019 > e = Enumerator.new do |y|
2.5.0 :020 >     puts "Starting up the block!"
2.5.0 :021?>   (1..3).each { |n| y << n }
2.5.0 :022?>   puts "Exiting the block!"
2.5.0 :023?>   end
 => #<Enumerator: #<Enumerator::Generator:0x00007fd38107f308>:each>
2.5.0 :024 >
2.5.0 :025 > e.to_a
Starting up the block!
Exiting the block!
 => [1, 2, 3]
 2.5.0 :026 > e.select { |x| x > 1 }
 Starting up the block!
 Exiting the block!
  => [2, 3]
 2.5.0 :027 >
```

You can see that the block is executed once for each iterator called on e.

每当这个 enumerator 进行走访操作时，都会执行一次新建它时内部的 block ，也可以把这部分 block 视作一个存储有自身each 逻辑的信息块。 每次走访都要加载这个 信息块（yielder相关的信息）来知道程序的运行。

It’s also possible to involve other objects in the code block for an enumerator. Here’s a somewhat abstract example in which the enumerator performs a calculation involving the elements of an array while removing those elements from the array permanently:
我们也可以将其他object卷入 enumerator 的block中。这里有一个抽象的例子，将 enumerator 作为计算器，对一个 array 中的元素执行计算，并在之后将该元素从array中剔除

```ruby
array = [1,2,3,4,5]

e = Enumerator.new do |y|
  puts "Inner block"
  total = 0
  until array.empty?         # it's like a predefined code
    puts "Innermost block..."
    total += array.pop
    y << total
  end
end
```

这里的一个关键点是 array 被拿到了 e 内部进行pop操作，而e内部是一个 block 嵌套 conditional loop 的结构。

基于上面的代码，如果执行

```ruby
p e.take(3)
p array
p e.to_a



会得到

```ruby
Inner block
Innermost block...
Innermost block...
Innermost block...
[5, 9, 12]

[1, 2]

Inner block
Innermost block...
Innermost block...
[2, 3]
```

take 属于iterator，所以 e 在 call `take` 的时候， e 的内部block会整体执行一次

一个不容易理解的点是 `until array.empty?`

这里代码的语义是在 array 被 pop 腾空之前这个 loop 不会停下来，那么应该是 enumerator 内部的block 只要得到执行 array 就会被清空， 不管使用的是什么 iterator

但实际情况不是，使用 `e.take(3)` 之后最内层的 loop 在 array 被情况之前停下来了，只做了三次循环（对应给出的参数3）。但这里如果把 until 下的 loop 展开为 array.size 个重复的代码片段，就跟之前用到的

```ruby
y << 1
y << 2
y << 3
...
```
是一个结构了，这里写的向 yielder 中注入对象的代码，只是在规定 enumerator 进行 yield 操作时拿出对象的顺序，但并不是每次都要拿完，比如使用 `take(n)` 就只会拿 yielder 中的前n个，放在 until loop 中好像就只执行了前n次循环。

如果要展开例子中的 until 就是：

```ruby
array = [1,2,3,4,5]

e = Enumerator.new do |y|
  puts "Inner block"
  total = 0    

    puts "Innermost block..."
    total += array.pop
    y << total

    puts "Innermost block..."
    total += array.pop
    y << total

    puts "Innermost block..."
    total += array.pop
    y << total

    puts "Innermost block..."
    total += array.pop
    y << total

    puts "Innermost block..."
    total += array.pop
    y << total

end
``

或者写 `array.size.times do ...`


理解了这一点，就可以理解对于上面的例子来说，iterator 会用到几个 e 中的元素，就会动到几个 array 中的元素，而不是每次都全部排光，除了那些会动到所有元素的迭代方法。比如 to_a

```ruby
array = [1,2,3,4,5]

e = Enumerator.new do |y|
  puts "Inner block"
  total = 0
  until array.empty?
    puts "Innermost block..."
    total += array.pop
    y << total
  end
end

p e.to_a

p array
```

to_a 方法会走完所有 yielder 中存的对象，所以我们应该会得到一个 空 array

```ruby
Inner block
Innermost block...
Innermost block...
Innermost block...
Innermost block...
Innermost block...
[5, 9, 12, 14, 15]
[]
```

如上， enumerator 内部的整体 block 被执行了一次，而 `y << object` 的操作执行完了所有次数，也就是array.size次

The take operation produces a result array of two elements (the value of total for two successive iterations) and leaves a with three elements. Calling to_a on e, at this point, causes the original code block to be executed again, because the to_a call isn’t part of the same iteration as the call to take. Therefore, total starts again at 0, and the until loop is executed with the result that three values are yielded and a is left empty.

`take` 操作产生出了一个有2个元素的array ， 剩下了3个元素。 接下来使用 `to_a` 会重新执行 e 内部的 block ， 那么 total 会回到从0开始的状态。

-

**Attaching enumerators to other objects**

—

The other way to endow an enumerator with each logic is to hook the enumerator up to another object—specifically, to an iterator (often each, but potentially any method that yields one or more values) on another object. This gives the enumerator a basis for its own iteration: when it needs to yield something, it gets the necessary value by triggering the next yield from the object to which it is attached, via the designated method. The enumerator thus acts as part proxy, part parasite, defining its own each in terms of another object’s iteration.

另一种给 enumerator 植入遍历逻辑的方法是将其挂靠到其他对象上。准确的说，挂靠到另一个对象的走访方法(iterator)上。通常这个方法是 each 但理论上只要是一次能产出一个或多个value的方法都可以。 这就给了 enumerator 进行走访操作的基础，当它需要yield一个值时，他会通过触发他挂靠的那个对象的产出逻辑。这时的 enumerator 的行为像一个 代理或寄生物，通过另一个对象的走访过程来定义自己的走访方式。

-


http://ruby-doc.org/core-2.5.0/Object.html#method-i-enum_for

You create an enumerator with this approach by calling enum_for (a.k.a. to_enum) on the object from which you want the enumerator to draw its iterations. You provide as the first argument the name of the method onto which the enumerator will attach its each method. This argument defaults to :each, although it’s common to attach the enumerator to a different method, as in this example:

这种（第二种）创建 enumerator 的方式是使用 :enum_for 或 :to_enum 方法。默认情况下这个 method 是 :each， 但也可以挂到这个对象的其他 iterate 方法上

```ruby
2.5.0 :001 > names = %w{David Black Yukihiro Matsumoto}
 => ["David", "Black", "Yukihiro", "Matsumoto"]
2.5.0 :002 > names.to_enum(:select)
 => #<Enumerator: ["David", "Black", "Yukihiro", "Matsumoto"]:select>
2.5.0 :003 > names.enum_for(:select)
 => #<Enumerator: ["David", "Black", "Yukihiro", "Matsumoto"]:select>
2.5.0 :004 >
```

对 array 使用 enum_for(:select)  意味着我们想要将 names array 的select 方法绑定到 enumerator 中

Specifying :select as the argument means that we want to bind this enumerator to the select method of the names array. That means the enumerator’s each will serve as a kind of front end to array’s select:

结果是生成的 enumerator 的each会像是 names的select操作的前端输出

```ruby
2.5.0 :006 > e.each { |x| x.include?('a') }
 => ["David", "Black", "Matsumoto"]
2.5.0 :007 >
```

之前提过如果想要让自己写的 class 获得被走访的功能，需要先 include Enumerable 然后 写好each方法——也就是让ruby知道这个class实例对应的each的yielding逻辑。 而这里使用的 enum_for(:method) 做的事就像是在使用指定对象的某个iterator的逻辑去作为这个enumerator的each逻辑

You can also provide further arguments to enum_for. Any such arguments are passed through to the method to which the enumerator is being attached. For example, here’s how to create an enumerator for inject so that when inject is called on to feed values to the enumerator’s each, it’s called with a starting value of "Names: ":

:enum_for 可以接受额外的参数，这个参数会在每次enumerator 呼叫each时，传给 enumerator 附着的那个 iterative method。这里有一个例子，基于names array的:inject方法生成了一个enumerator, 那么当对enumerator的each产出的每一个对象使用inject方法时，就可以用到传入的参数作为 accumulator 的起始对象

```ruby
2.5.0 :011 > names
 => ["David", "Black", "Yukihiro", "Matsumoto"]
2.5.0 :012 > e = names.enum_for(:inject, "Names: ")
 => #<Enumerator: ["David", "Black", "Yukihiro", "Matsumoto"]:inject("Names: ")>

2.5.0 :014 > e.each { |acc, e| acc << "#{e}... " } # 这里其实可以直接把 each 看做是 inject ， acc 就是之前enum_for拿到的参数
 => "Names: David... Black... Yukihiro... Matsumoto... "
2.5.0 :015 >
```

上面的例子还有一个关注点是 return 值

之前说过 each 不管是进行什么操作，最后会返回 receiver , map 返回新副本array

但我们用 inject 作为 enumerator 的each逻辑之后，return 值也同时变为了 inject 方法的return值。

```ruby
= Array.inject

(from ruby site)
=== Implementation from Enumerable
------------------------------------------------------------------------------
  enum.inject(initial, sym) -> obj
  enum.inject(sym)          -> obj
  enum.inject(initial) { |memo, obj| block }  -> obj
  enum.inject          { |memo, obj| block }  -> obj

------------------------------------------------------------------------------

Combines all elements of enum by applying a binary operation,
specified by a block or a symbol that names a method or operator.

The inject and reduce methods are aliases. There is no
performance benefit to either.

If you specify a block, then for each element in enum the block is
passed an accumulator value (memo) and the element. If you specify a
symbol instead, then each element in the collection will be passed to the
named method of memo. In either case, the result becomes the new value
for memo. At the end of the iteration, the final value of memo
is the return value for the method.

If you do not explicitly specify an initial value for
memo, then the first element of collection is used as the initial
value of memo.

  # Sum some numbers
  (5..10).reduce(:+)                             #=> 45
  # Same using a block and inject
  (5..10).inject { |sum, n| sum + n }            #=> 45
  # Multiply some numbers
  (5..10).reduce(1, :*)                          #=> 151200
  # Same using a block
  (5..10).inject(1) { |product, n| product * n } #=> 151200
  # find the longest word
:
```

注意这段：

At the end of the iteration, the final value of memo
is the return value for the method.
作为整个迭代操作的最终返回值，会是所有叠加操作的总的结果值

If you do not explicitly specify an initial value for
memo, then the first element of collection is used as the initial
value of memo.

When you create the enumerator, the arguments you give it for the purpose of supplying its proxied method with arguments are the arguments—the objects—it will use permanently. So watch for side effects. (In this particular case, you can avoid the side effect by adding strings—string + "#{name}..."—instead of appending to the string with <<, because the addition operation creates a new string object. Still, the cautionary tale is generally useful.)

当你使用 :enum_for() 创建enumerator时传入的额外参数，喂给代理method，这个enumerator 将会一直使用使用这个参数。在下面的例子中， acc 在一开始代表的是 “Names ” 这个string 但是 block 中的每一次操作都是 push , 也就是改变了参数对象本身的content，所以下一次进行同样的操作时，上一次的操作结果会成为这一次的起始参数, 就会变成一个很长的起始 accumulator。但这个情况时针对这个特殊的例子而言，在这个例子中如果要避免这种叠加情况可以使用 + 加号，因为 + method 返回的是副本，而没有改变原来的object

```ruby
2.5.0 :017 > e.each { |acc, e| acc << "#{e}... " }
 => "Names: David... Black... Yukihiro... Matsumoto... David... Black... Yukihiro... Matsumoto... "
2.5.0 :018 > e.each { |acc, e| acc << "#{e}... " }
 => "Names: David... Black... Yukihiro... Matsumoto... David... Black... Yukihiro... Matsumoto... David... Black... Yukihiro... Matsumoto... "
2.5.0 :019 > names
 => ["David", "Black", "Yukihiro", "Matsumoto"]
2.5.0 :020 > e = names.enum_for(:inject, "Names ")
 => #<Enumerator: ["David", "Black", "Yukihiro", "Matsumoto"]:inject("Names ")>
2.5.0 :021 > e.each { |acc, e| acc + "#{e}... " }
 => "Names David... Black... Yukihiro... Matsumoto... "
2.5.0 :022 > e.each { |acc, e| acc + "#{e}... " }
 => "Names David... Black... Yukihiro... Matsumoto... "
2.5.0 :023 > e.each { |acc, e| acc + "#{e}... " }
 => "Names David... Black... Yukihiro... Matsumoto... "
2.5.0 :024 >
```

记住在 enum_for() 后除了 :method 以外的其他参数都会传递给 挂靠的 method ，但不是所有的 iterative methods 都可以接受参数，所以多余的参数有时反而会引起错误。

```ruby
2.5.0 :026 > names
 => ["David", "Black", "Yukihiro", "Matsumoto"]
2.5.0 :027 > ee = names.enum_for(:map, "prefix")
 => #<Enumerator: ["David", "Black", "Yukihiro", "Matsumoto"]:map("prefix")>
2.5.0 :028 > ee.each { |e| p e  }
Traceback (most recent call last):
        4: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        3: from (irb):28
        2: from (irb):28:in `each'
        1: from (irb):28:in `map'
ArgumentError (wrong number of arguments (given 1, expected 0))
2.5.0 :029 >
```

-

You can call Enumerator.new(obj, method_name, arg1, arg2...) as an equivalent to obj.enum_for(method_name, arg1, arg2...). But using this form of Enumerator.new is discouraged. Use enum_for for the method-attachment scenario and Enumerator.new for the block-based scenario described in section 10.9.1.

这种挂靠的方式也可以使用 Enumerator.new(object, method, arg1, arg2 …) 这种句法实现，效果和 object.enum_for(method, arg1, arg2 …) 一样。

```ruby
2.5.0 :029 > e = Enumerator.new(names, :inject, "Names ")
(irb):29: warning: Enumerator.new without a block is deprecated; use Object#to_enum
 => #<Enumerator: ["David", "Black", "Yukihiro", "Matsumoto"]:inject("Names ")>
2.5.0 :030 > e
 => #<Enumerator: ["David", "Black", "Yukihiro", "Matsumoto"]:inject("Names ")>
2.5.0 :031 > e.each { |acc, x| acc + "#{x}... " }
 => "Names David... Black... Yukihiro... Matsumoto... "
2.5.0 :032 >
```

-

**Implicit creation of enumerators by blockless iterator calls**

另一种不使用 block 的创建 enumerator 的方法

-

—

By definition, an iterator is a method that yields one or more values to a block. But what if there’s no block?

The answer is that most built-in iterators return an enumerator when they’re called without a block. Here’s an example from the String class: the each_byte method (see section 10.7). First, here’s a classic iterator usage of the method, without an enumerator but with a block:

根据定义，迭代计算函数会每次 产出 一个或多个值 传给 block

但是如果没有跟 block呢？

他们会跟产生出一个 enumerator

许多 enumerable module 中的 method 都有这个效果，这么做的主要目的是可以将这些 methods 串接起来

```ruby
2.5.0 :037 > "string".each_byte
 => #<Enumerator: "string":each_byte>
2.5.0 :038 > "string".each_byte.select
 => #<Enumerator: #<Enumerator: "string":each_byte>:select>
2.5.0 :039 > "string".each_byte.select.inject
Traceback (most recent call last):
        7: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        6: from (irb):39
        5: from (irb):39:in `inject'
        4: from (irb):39:in `each'
        3: from (irb):39:in `select'
        2: from (irb):39:in `each'
        1: from (irb):39:in `each_byte'
LocalJumpError (no block given)
2.5.0 :040 >
```

但是有些 iterator 后必须要跟 block ，比如上面的 inject ，如果不跟就会报错。

—

Enumerator semantics and uses

—

Perhaps the hardest thing about enumerators, because it’s the most difficult to interpret visually, is how things play out when you call the each method. We’ll start by looking at that; then, we’ll examine the practicalities of enumerators, particularly the ways in which an enumerator can protect an object from change and how you can use an enumerator to do fine-grained, controlled iterations. We’ll then look at how enumerators fit into method chains in general and we’ll see a couple of important specific cases.

enumerator 难以理解的地方在于，他很难用视觉化的方法来解析当使用 each 时，对象是怎么被 “挤”出来的。
我们会首先了解上面提到的这点。
然后检查 enumerator 的实践，特别是 enumerator 如何保护对象不被改变，以及如何使用 enumerator 进行精细的，可控的，迭代操作。
最后会看下enumerator 的迭代方法是怎么串接使用的。

—

How to use an enumerator’s each method

—

之前提到过如果将一个 迭代方法 挂靠到一个enumerator 上，这个挂靠的方法实际上决定了 对 enumerator使用each产生的实际效果。

把 map 挂靠到 array 生成一个 enumerator 后，each 的行为就变成了 map 的效果。（map 返回新副本，each 返回reciever）

这里挂靠了 map 的 array 已经不是原来的 array 了，而是一个新的 植入了 “map” 芯片的 enumerator

```ruby
2.5.0 :042 > array = %w{cat dog rabbit}
 => ["cat", "dog", "rabbit"]
2.5.0 :043 > e = array.map
 => #<Enumerator: ["cat", "dog", "rabbit"]:map>
2.5.0 :044 > e1 = array.enum_for(:map)
 => #<Enumerator: ["cat", "dog", "rabbit"]:map>
2.5.0 :045 > e.each { |x| x.upcase }
 => ["CAT", "DOG", "RABBIT"]
2.5.0 :046 >
```

注意这里 array.map 的效果和 array.enum_for(:map) 的效果是一样的

—

the un-overriding phenomenon 逆重写现象

如果一个 class 定义好了 each 然后 include 了 Enumerable 那么他的实例会自动获得一系列的迭代方法 比如 map select inject 等，所有这些方法都建立在 each 的基础之上。

但是 有些class 中的特定 迭代方法 是被 override 了的。
比如 hash的select

![](https://ws2.sinaimg.cn/large/006tKfTcgy1fo93h4oyn2j310n08rn1f.jpg)

If a class defines each and includes Enumerable, its instances automatically get map, select, inject, and all the rest of Enumerable’s methods. All those methods are defined in terms of each.
But sometimes a given class has already overridden Enumerable’s version of a method with its own. A good example is Hash#select. The standard, out-of-the-box select method from Enumerable always returns an array, whatever the class of the object using it might be. A select operation on a hash, on the other hand, returns a hash:

如果一个class定义了each并 include 了 Enumerable，那么他的实例就自动获得了 map , select , inject 等一些列迭代方法。 所有这些method都是建立在each的逻辑之上的。但有时一些class在写了each后会继续重写一些迭代方法，以更好的适用于自己的class。一个例子是 Hash#select 方法。 原本在 Enumerable 中 select 默认返回的是 array , 但是hash虽然 include 了 Enumerable 但是class Hash中重写了这个 method,  让返回的值变成了 hash

e = h.enum_for(:each) 和 e =  h.to_enum 等价

```ruby
2.5.0 :048 > h = {"cat" => "feline", "dog" => "canine", "cow" => "bovine"}
 => {"cat"=>"feline", "dog"=>"canine", "cow"=>"bovine"}
2.5.0 :049 > h.each { |unit| p unit }
["cat", "feline"]
["dog", "canine"]
["cow", "bovine"]
 => {"cat"=>"feline", "dog"=>"canine", "cow"=>"bovine"}
2.5.0 :050 > h.select { |k, v| k =~ /c/ } # returns a hash, not an array
 => {"cat"=>"feline", "cow"=>"bovine"}
```

So far, so good (and nothing new). And if we hook up an enumerator to the select method, it gives us an each method that works like that method:

如果你把一个 enumerator 挂给 select 方法，那么这个enumerator 的each 逻辑就会被置换

```ruby
2.5.0 :054 > e = h.enum_for(:select)
 => #<Enumerator: {"cat"=>"feline", "dog"=>"canine", "cow"=>"bovine"}:select>
2.5.0 :055 > e.each { |k, v| k =~ /c/ }
 => {"cat"=>"feline", "cow"=>"bovine"}
2.5.0 :056 >
```

But what about an enumerator hooked up not to the hash’s select method but to the hash’s each method? We can get one by using to_enum and letting the target method default to each:

但如果一个 enumerator 不是挂到了 hash 的 select 方法上而是 hash 的each方法上？我们只需要使用不带参数的 `to_enum` 就可以做到。

```ruby
2.5.0 :058 > h
 => {"cat"=>"feline", "dog"=>"canine", "cow"=>"bovine"}
2.5.0 :059 > h.to_enum
 => #<Enumerator: {"cat"=>"feline", "dog"=>"canine", "cow"=>"bovine"}:each>
2.5.0 :060 >
```

Hash#each, called with a block, returns the hash. The same is true of the enumerator’s each—because it’s just a front end to the hash’s each. The blocks in these examples are empty because we’re only concerned with the return values:

Hash中的each最后返回的是 原来的hash receiver ， 这和 Enumerable 中的 each 相同。

```ruby
= Hash.each

(from ruby site)
------------------------------------------------------------------------------
  hsh.each      {| key, value | block } -> hsh
  hsh.each_pair {| key, value | block } -> hsh
  hsh.each                              -> an_enumerator
  hsh.each_pair                         -> an_enumerator

------------------------------------------------------------------------------

Calls block once for each key in hsh, passing the key-value
pair as parameters.

If no block is given, an enumerator is returned instead.

  h = { "a" => 100, "b" => 200 }
  h.each {|key, value| puts "#{key} is #{value}" }

produces:

  a is 100
  b is 200


(END)
```

所以跟的 block 中进行了什么操作不会影响最终的 return 值，即使是一个空的 { # block }

```ruby
2.5.0 :069 > h
 => {"cat"=>"feline", "dog"=>"canine", "cow"=>"bovine"}
2.5.0 :070 > h.each {}
 => {"cat"=>"feline", "dog"=>"canine", "cow"=>"bovine"}
2.5.0 :071 > e
 => #<Enumerator: {"cat"=>"feline", "dog"=>"canine", "cow"=>"bovine"}:each>
2.5.0 :072 > e.each {}
 => {"cat"=>"feline", "dog"=>"canine", "cow"=>"bovine"}
2.5.0 :073 >
```

So far, it looks like the enumerator’s each is a stand-in for the hash’s each. But what happens if we use this each to perform a select operation?

目前为止，好像 e 的 each 和 hash 的 each 是一样的。 但如果我们使用这个each去进行select 操作会怎么样？

```ruby
2.5.0 :075 > e # e = h.to_enum(:each)  # 这里实际是用 Enumerator#each 替换掉了 Hash#each , 所以相关的建立在each上的iterator 都被改变了
 => #<Enumerator: {"cat"=>"feline", "dog"=>"canine", "cow"=>"bovine"}:each>
2.5.0 :076 > e.select { |k, v| k =~ /c/ }
 => [["cat", "feline"], ["cow", "bovine"]]
2.5.0 :077 >
```

我们得到了一个 array 而不再是 hash

Why? If e.each is pegged to h.each, how does the return value of e.select get unpegged from the return value of h.select?
The key is that the call to select in the last example is a call to the select method of the enumerator, not the hash. And the select method of the enumerator is built directly on the enumerator’s each method. In fact, the enumerator’s select method is Enumerable#select, which always returns an array. The fact that Hash#select doesn’t return an array is of no interest to the enumerator.
关键点在 最后一次使用 select 时， 用到的并不是 Hash#select 而使用的是 Enumerable#select ， h.enum_for(:each) 使h的select 回到的原始的 enumerable 版本，返回 array

In this sense, the enumerator is adding enumerability to the hash, even though the hash is already enumerable. It’s also un-overriding Enumerable#select; the select provided by the enumerator is Enumerable#select, even if the hash’s select wasn’t. (Technically it’s not an un-override, but it does produce the sensation that the enumerator is occluding the select logic of the original hash.)
在这个意义上看，h.enum_for(:each) 在传递 走访能力 给hash,  即使 hash 本身就有走访功能（默认内建）。而这么做的实际结果是破坏了 Hash#select 重写的功能，让 select 回到了更上游的版本。

The lesson is that it’s important to remember that an enumerator is a different object from the collection from which it siphons its iterated objects. Although this difference between objects can give rise to some possibly odd results, like select being rerouted through the Enumerable module, it’s definitely beneficial in at least one important way: accessing a collection through an enumerator, rather than through the collection itself, protects the collection object from change.
讲这些内容的目的是，要记住 enumerator 和 collection 是完全不同的概念。这种挂靠 走访函数 生成 enumerator 而不是 直接对原始 collection 进行操作的方法，保护了 collection 的原始性。


—

Protecting objects with enumerators
使用 enumerator来保护 对象

—

ruby 当中，有些方法返回新副本不改变原来的 object , 有些方法则会改变原来的 object。

后者比如说 `array << obj`

你可以选择 duplicate 一次对象 然后作为 method 实际的 receiver 来操作，另一个选择是 使用 to_enum 将 receiver 变成一个 enumerator 新副本

当把一个 array 变成 enumerator 之后， 这个 e (代表 enumerator) 会很乐意对内部的物件进行迭代计算，但它不吸收任何改变。如果你尝试改变这个 e 的内容，比如使用 << 向他推内容，将会报 fatal 错误。在这个层面看，e 有点像是一道防火墙。

之前用到的 扑克牌 的例子中， Deck 有一个 attr_reader :cards

```ruby
class PlayingCard

  SUITS = %w[clubs diamonds hearts spades] #4 花色
  RANKS = %w[2 3 4 5 6 7 8 9 10 J Q K A] #13 数字

  class Deck
    attr_reader :cards
    def initialize(n=1)
      @cards = []
      SUITS.cycle(n) do |s|
        RANKS.cycle(1) do |r|
          @cards << "#{r} of #{s}"
        end
      end
    end
  end
end
```

在 PlayingCard::Deck 的 instance 的 cards 中可以存很多副新牌，但是由于他只是个 array , 那么就可以有很多种方法向这个array内部注入给中信息。

但严肃的来说，作为一副可用的牌，内容是不能随意改动的。当然我们可以使用 freeze 方法将其冻结，不过 enumerator 的存在提供了另一种方法。

这次不需要用到 reader attribute :cards ，而是 定义一个实例方法 def cards , 让他返回 @cards.to_enum ， 一个 挂靠了 :each 的array


```ruby
class PlayingCard

  SUITS = %w[clubs diamonds hearts spades] #4 花色
  RANKS = %w[2 3 4 5 6 7 8 9 10 J Q K A] #13 数字

  class Deck
    def cards
      @cards.to_enum # 省略了 (:each)
    end

    def initialize(n=1)
      @cards = []
      SUITS.cycle(n) do |s|
        RANKS.cycle(1) do |r|
          @cards << "#{r} of #{s}"
        end
      end
    end
  end
end
```

现在新建一副牌之后再想往 @cards 中注入信息就会报错了

```ruby
2.5.0 :004 > deck = PlayingCard::Deck.new
 => #<PlayingCard::Deck:0x00007fdb4a1a8650 @cards=["2 of clubs", "3 of clubs", "4 of clubs", "5 of clubs", "6 of clubs", "7 of clubs", "8 of clubs", "9 of clubs", "10 of clubs", "J of clubs", "Q of clubs", "K of clubs", "A of clubs", "2 of diamonds", "3 of diamonds", "4 of diamonds", "5 of diamonds", "6 of diamonds", "7 of diamonds", "8 of diamonds", "9 of diamonds", "10 of diamonds", "J of diamonds", "Q of diamonds", "K of diamonds", "A of diamonds", "2 of hearts", "3 of hearts", "4 of hearts", "5 of hearts", "6 of hearts", "7 of hearts", "8 of hearts", "9 of hearts", "10 of hearts", "J of hearts", "Q of hearts", "K of hearts", "A of hearts", "2 of spades", "3 of spades", "4 of spades", "5 of spades", "6 of spades", "7 of spades", "8 of spades", "9 of spades", "10 of spades", "J of spades", "Q of spades", "K of spades", "A of spades"]>
2.5.0 :005 > deck.cards << "Fake Card!"
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):5
NoMethodError (undefined method `<<' for #<Enumerator:0x00007fdb49835500>)
2.5.0 :006 >
```

—

Because enumerators are objects, they have state. Furthermore, they use their state to track their own progress so you can stop and start their iterations. We’ll look now at the techniques for controlling enumerators in this way.

由于 enumerator 也是 objects， 那么他就有状态，进一步说，他们能够用这个 状态 来追踪记录自己的进程，那么我们就能利用这个特性来 终止或者开始 enumerator 内部的迭代计算。下面就看看如果控制这个内部过程。

—

**Fine-grained iteration with enumerators**

enumerator 的精细迭代操作

—

Enumerators maintain state: they keep track of where they are in their enumeration. Several methods make direct use of this information. Consider this example:

enumerator 保有自己的状态，他们追踪记录自己正处于走访中的哪一步。有一些 methods 直接使用到了这个特性：

```ruby
2.5.0 :002 > names = %w{ David Yukihiro Caven }
 => ["David", "Yukihiro", "Caven"]
2.5.0 :003 > e = names.to_enum
 => #<Enumerator: ["David", "Yukihiro", "Caven"]:each>
2.5.0 :004 > puts e.next
David
 => nil
2.5.0 :005 > puts e.next
Yukihiro
 => nil
2.5.0 :006 > puts e.next
Caven
 => nil
2.5.0 :007 > puts e.next
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):7
        1: from (irb):7:in `next'
StopIteration (iteration reached an end)
2.5.0 :008 >
2.5.0 :009 > e.rewind
 => #<Enumerator: ["David", "Yukihiro", "Caven"]:each>
2.5.0 :010 > puts e.next
David
 => nil
```

next 会一步一个地走访 e 内的对象，走到末尾时，会报出  reach the end 错误，这时使用  rewind 倒回方法， 就像给磁带倒带一样，走访点又回到了开头处。

  cast/shed/throw light on
   : to help to explain (something) : to make it possible to understand or know more about (something)

 at will
  : when you want or in a way that you want

This point also sheds light on the difference between an enumerator and an iterator. An enumerator is an object, and can therefore maintain state. It remembers where it is in the enumeration. An iterator is a method. When you call it, the call is atomic; the entire call happens, and then it’s over. Thanks to code blocks, there is of course a certain useful complexity to Ruby method calls: the method can call back to the block, and decisions can be made that affect the outcome. But it’s still a method. An iterator doesn’t have state. An enumerator is an enumerable object.

上面的例子帮助说明了 enumerator 和 iterator 之间的区别

an enumerator 是一个 object ，但它保有自己的状态，他知道自己处于迭代计算的哪一步

an iterator 是一个方法，当我们呼叫它时时，他就完整执行一次

-

Adding enumerability with an enumerator

-

An enumerator can add enumerability to objects that don’t have it. It’s a matter of wiring: if you hook up an enumerator’s each method to any iterator, then you can use the enumerator to perform enumerable operations on the object that owns the iterator, whether that object considers itself enumerable or not.
一个 enumerator 可以将枚举功能传递给一个没有这个功能的对象。 如果你可以把一个enumerator的each方法绑定给任何迭代方法，那么这个enumerator 就可以在拥有这个迭代方法的对象的身上执行枚举操作，不管这个对象原来是否具有可枚举特性。

When you hook up an enumerator to the String#bytes method, you’re effectively adding enumerability to an object (a string) that doesn’t have it, in the sense that String doesn’t mix in Enumerable. You can achieve much the same effect with classes of your own. Consider the following class, which doesn’t mix in Enumerable but does have one iterator method:
等你把一个 enumerator 绑给 string 对象的 bytes 方法是，你就在给string对象增加他所没有的枚举功能，String 并没有 include Enumerable 。 你也可以在自己写的class中实现这个过程，看下面这个class, 他没有 include Enumerable 但它确实有迭代方法

```ruby
module Music
  class Scale # 音阶  
    NOTES = %w{c c# d d# e f f# g a a# b}  # it's actually an array

    def play
      NOTES.each{ |note| yield note }
    end
  end
end
```

Given this class, it’s possible to iterate through the notes of a scale

给出这个class, 他是有可能遍历所有音阶(an array of string)对象的

```ruby
2.5.0 :002 > scale = Music::Scale.new
 => #<Music::Scale:0x00007fbc5d03d790>
2.5.0 :003 > scale.play { |note| puts "Next note is #{note}." }
Next note is c.
Next note is c#.
Next note is d.
Next note is d#.
Next note is e.
Next note is f.
Next note is f#.
Next note is g.
Next note is a.
Next note is a#.
Next note is b.
 => ["c", "c#", "d", "d#", "e", "f", "f#", "g", "a", "a#", "b"]
2.5.0 :004 >
```

But the scale isn’t technically an enumerable. The standard methods from Enumerable won’t work because the class Music::Scale doesn’t mix in Enumerable and doesn’t define each:

但是 Scale 实例本身并不是一个可枚举的对象。 Enumerable 中的标准枚举相关方法并不能起作用因为它没有 include Enumerable 也没有定义 each

```ruby
2.5.0 :004 > scale
 => #<Music::Scale:0x00007fbc5d03d790>
2.5.0 :005 > scale.map { |note| note.upcase }
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):5
NoMethodError (undefined method `map' for #<Music::Scale:0x00007fbc5d03d790>
Did you mean?  tap)
2.5.0 :006 >
```

Now, in practice, if you wanted scales to be fully enumerable, you’d almost certainly mix in Enumerable and change the name of play to each. But you can also make a scale enumerable by hooking it up to an enumerator.
从实践上看如果你想要 scale 获得完整的可枚举，你应该 mix Enumerable 然后定义好 each。 但你也可以通过把他挂到一个 enumerator 上来实现这一点。

Here’s how to create an enumerator for the scale object, tied in to the play method:
看下如果为 scale 实例建立一个enumerator 并将 play 方法绑进去

```ruby
2.5.0 :008 > scale
 => #<Music::Scale:0x00007fbc5d03d790>
2.5.0 :009 > enum = scale.enum_for(:play)
 => #<Enumerator: #<Music::Scale:0x00007fbc5d03d790>:play>
2.5.0 :010 >
```

The enumerator, enum, has an each method; that method performs the same iteration that the scale’s play method performs. Furthermore, unlike the scale, the enumerator is an enumerable object; it has map, select, inject, and all the other standard methods from Enumerable. If you use the enumerator, you get enumerable operations on a fundamentally non-enumerable object:

一个 enumerator 默认就带有自己的each逻辑的；

```ruby
2.5.0 :016 > scale.to_enum(:play).respond_to?(:each)
 => true
2.5.0 :017 >
```

rdoc

```ruby
= Enumerator.each

(from ruby site)
------------------------------------------------------------------------------
  enum.each { |elm| block }                    -> obj
  enum.each                                    -> enum
  enum.each(*appending_args) { |elm| block }   -> obj
  enum.each(*appending_args)                   -> an_enumerator
```

enumerator 默认的each实际上和 Sacle 中的 play 做的事是一样的：一次 yield 一个note对象出来

更进一步，enumerator 本身就可以执行各种默认的迭代方法，比如 map, select, inject 等

如果你使用这个 enumerator 而不是原来的scale对象，那么你就可以在一个从根本上不具有枚举特性的对象身上进行各种枚举操作。

（这里相当于把 enumerator 默认的each逻辑，置换成了play的逻辑，也就是从NOTES array中一次yield一个元素出来，这里实际也用到了array的each）

这里第一次 to_enum/enum_for 用到了非遍历类的method, 实际上 to_enum/enum_for 后跟的用来置换默认逻辑的 method 可以是任何方法，你可以在生成 enumerator 时这么做，但是这么做不保证后面会有什么状况，也可以猜到会有很多错误情况。所以之前书中的例子一直都给的是常规的遍历方法。

```ruby
2.5.0 :003 > array = [1,2,3,4]
 => [1, 2, 3, 4]
2.5.0 :004 > array.to_enum(:clear)
 => #<Enumerator: [1, 2, 3, 4]:clear>
2.5.0 :005 > array.to_enum(:==)
 => #<Enumerator: [1, 2, 3, 4]:==>
2.5.0 :006 > array.to_enum(:size)
 => #<Enumerator: [1, 2, 3, 4]:size>
2.5.0 :007 > array.to_enum(:puts)
 => #<Enumerator: [1, 2, 3, 4]:puts>
2.5.0 :008 >
```

接着上面的例子

```ruby
2.5.0 :008 > scale
 => #<Music::Scale:0x00007fbc5d03d790>
2.5.0 :009 > enum = scale.enum_for(:play)
 => #<Enumerator: #<Music::Scale:0x00007fbc5d03d790>:play>

2.5.0 :017 > p enum.map { |note| note.upcase }
["C", "C#", "D", "D#", "E", "F", "F#", "G", "A", "A#", "B"]
 => ["C", "C#", "D", "D#", "E", "F", "F#", "G", "A", "A#", "B"]
2.5.0 :018 > p enum.select { |note| note.include?("f") }
["f", "f#"]
 => ["f", "f#"]
2.5.0 :019 >
```

Attaching an enumerator to a non-enumerable object like the scale object is a good exercise because it illustrates the difference between the original object and the enumerator so sharply. But in the vast majority of cases, the objects for which enumerators are created are themselves enumerables: arrays, hashes, and so forth. Most of the examples in what follows will involve enumerable objects (the exception being strings). In addition to taking us into the realm of the most common practices, this will allow us to look more broadly at the possible advantages of using enumerators.

将一个 enumerator 绑到一个不具有enumerability的对象上是一个好的练习，因为二者之间的区别如此之大。

但在 ruby 中大多数具有 enumerability 是生来就有的，比如 array hash 等的实例

`include Enumerable` 加上 `def each` 可以使得一个class拥有基于你自己each逻辑的一整套枚举方法。

而将普通object变为一个enumerator并绑一个自己method的过程其实和标准的过程很类似。 可以说 object to enum 的过程就相当于在 object.class 中引入了 Enumerale 这个module， 而默认的enum的each可能不适用于你自己的实例，所以你要自己绑一个合理的方法。

-

Economizing on intermediate objects

-

像  array.each.inject 或 array.map.select

这样的连接是没有意义的，但某些method 则可以很好的运用

```ruby
2.5.0 :025 > names = %w{ David Black Yukihiro Matsumote }
 => ["David", "Black", "Yukihiro", "Matsumote"]
2.5.0 :026 > names.each_slice(2).map { |first, last| "First name: #{first}, last name: #{last}" }
 => ["First name: David, last name: Black", "First name: Yukihiro, last name: Matsumote"]
2.5.0 :027 >
```
上面的例子中 each_slice(2)  然 enumerator 知道了一次从 array 中拿出两个元素拿给 map 来处理

each_slice 用法回顾

```ruby
2.5.0 :028 > names.each_slice(2) { |one, two| puts one.upcase + " " + two }
DAVID Black
YUKIHIRO Matsumote
 => nil

2.5.0 :030 > names.each_slice(4) { |a,b,c,d| puts a.downcase + " " + b.capitalize + " " + c.downcase + " " + d.upcase }
david Black yukihiro MATSUMOTE
 => nil
2.5.0 :031 >
```

再来看一个例子

```ruby
2.5.0 :034 > string.each_byte.map { |b| b + 1 }
 => [66, 115, 99, 106, 117, 115, 98, 115, 122, 33, 116, 117, 115, 106, 111, 104, 47]
2.5.0 :035 >
```

map 让返回结果直接是在一个 array 中，如果不使用map 那么我们很可能要先要造一个空 array 然后以此把 迭代每一步的结果 推进去

```ruby
2.5.0 :035 > string
 => "Arbitrary string."
2.5.0 :036 > array = []
 => []
2.5.0 :037 > string.each_byte { |b| array << b + 1 }
 => "Arbitrary string."
2.5.0 :038 > array
 => [66, 115, 99, 106, 117, 115, 98, 115, 122, 33, 116, 117, 115, 106, 111, 104, 47]
2.5.0 :039 >
```

注意  string.each_byte 返回的是一个 enumerator ，它预制好了每一步拿出什么东西

比如这里拿出的是每个字母的序号而不是字母本身

这样的串接就简化了代码，同时在语义上也能够理解

-

Enumerable methods that take arguments and return enumerators, like each_slice, are candidates for this kind of compression or optimization Even if an enumerable method doesn’t return an enumerator, you can create one for it, incorporating the argument so that it’s remembered by the enumerator. You’ve seen an example of this technique already, approached from a slightly different angle, in section 10.9.2:

有些枚举方法（不带block时）接受参数并返回一个带参数的 enumerator。 比如 each_slice(n) 就是这类方法。 即使一个枚举方法不返回一个enumerator ， 你都可以帮他创造一个，并把参数带进去，这样参数就留存在了这个 enumerator 内部，比如前面用到的 inject + 'Names ' 的例子

```ruby
2.5.0 :040 > e = names.enum_for(:inject, "Names: ")
 => #<Enumerator: ["David", "Black", "Yukihiro", "Matsumote"]:inject("Names: ")>
2.5.0 :041 >
```

The enumerator remembers not only that it’s attached to the inject method of names but also that it represents a call to inject with an argument of "Names"
这个enumerator 不仅记住了它是被绑给 names 的 inject 方法的，同时他也可以代表带着参数 "Names" 对 inject 方法的使用。

In addition to the general practice of including enumerators in method chains, the specialized method with_index—one of the few that the Enumerator class implements separately from those in Enumerable—adds considerable value to enumerations.

除了通常的串接使用 enumerator 的方法，另一个 with_index 方法，它是少数 Enumerator class 单独实现的方法之一。给迭代操作添加了不少价值。

—

**Indexing enumerables with with_index**

—

```ruby
2.5.0 :043 > ('a'..'z').map.with_index(100) { |letter, index| [letter, index] }
 => [["a", 100], ["b", 101], ["c", 102], ["d", 103], ["e", 104], ["f", 105], ["g", 106], ["h", 107], ["i", 108], ["j", 109], ["k", 110], ["l", 111], ["m", 112], ["n", 113], ["o", 114], ["p", 115], ["q", 116], ["r", 117], ["s", 118], ["t", 119], ["u", 120], ["v", 121], ["w", 122], ["x", 123], ["y", 124], ["z", 125]]
2.5.0 :044 >
```

Note that it’s map.with_index (two methods, chained), not map_with_index (a composite method name). And with_index can be chained to any enumerator. Remember the musical scale from section 10.10.4? Let’s say we enumerator-ize the play method:

注意是 map.with_index （两个串起来的方法）而不是 一个单独的 map_with_index

```ruby
2.5.0 :044 > ('a'..'z').map_with_index(100) { |letter, index| [letter, index] }
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):44
NoMethodError (undefined method `map_with_index' for "a".."z":Range)
2.5.0 :045 >
```

with_index 可以与任何 enumerator 串接

记得前面的 play music 的例子吗

现在把 play 内部代码修改一下

```ruby
module Music

  class Scale
    NOTES = %w{c c# d d# e f f# g a a# b}

    def play
      # NOTES.each {|note| yield note}
      NOTES.to_enum  # Now when we call `play`, scale instance will become an enumerator(with :each)
    end
  end

end
```

测试

```ruby
2.5.0 :004 > scale = Music::Scale.new
 => #<Music::Scale:0x00007fb4f588c730>
2.5.0 :005 > scale.play.with_index { |note, i| puts "Note #{i} is: #{note}." }
Note 0 is: c.
Note 1 is: c#.
Note 2 is: d.
Note 3 is: d#.
Note 4 is: e.
Note 5 is: f.
Note 6 is: f#.
Note 7 is: g.
Note 8 is: a.
Note 9 is: a#.
Note 10 is: b.
 => ["c", "c#", "d", "d#", "e", "f", "f#", "g", "a", "a#", "b"]
2.5.0 :006 >
```
当我们单独对 scale 对象使用 play 的时候，实际上在做的就是对他使用 to_enum(:each)或 enum_for(:each)， play 只是一个方法名称的 '壳'。看下面的代码

```ruby
2.5.0 :006 > scale
 => #<Music::Scale:0x00007fb4f588c730>
2.5.0 :007 > scale.play
 => #<Enumerator: ["c", "c#", "d", "d#", "e", "f", "f#", "g", "a", "a#", "b"]:each>
2.5.0 :008 >
```

留心之前在 play 内部写的是 `NOTES.each {|note| yield note}` ， 这个版本中对 scale对象使用play是不能把他变成 enumerator 的。

```ruby
2.5.0 :003 > scale = Music::Scale.new
 => #<Music::Scale:0x00007f96088534c8>
2.5.0 :004 > scale.play
Traceback (most recent call last):
        5: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        4: from (irb):4
        3: from /Users/caven/Notes & Articles/Note of Rubyist/code examples/deliver_enumerability.rb:7:in `play'
        2: from /Users/caven/Notes & Articles/Note of Rubyist/code examples/deliver_enumerability.rb:7:in `each'
        1: from /Users/caven/Notes & Articles/Note of Rubyist/code examples/deliver_enumerability.rb:7:in `block in play'
LocalJumpError (no block given (yield))
2.5.0 :005 >
```

如果要在这个版本中使用 play.with_index 需要把 scale 转为enum并植入play逻辑

```ruby
2.5.0 :006 > scale.enum_for(:play).each.with_index
 => #<Enumerator: #<Enumerator: #<Music::Scale:0x00007f96088534c8>:play>:with_index>
2.5.0 :007 > scale.enum_for(:play).each.with_index(100) { |s, index| puts "#{index}: #{s}" }
100: c
101: c#
102: d
103: d#
104: e
105: f
106: f#
107: g
108: a
109: a#
110: b
 => ["c", "c#", "d", "d#", "e", "f", "f#", "g", "a", "a#", "b"]
2.5.0 :008 >
```

这部分涉及的几个关键对象

1 普通的不具有遍历功能的对象（class中没有mix Enumerable 也没有定义 each）
2 普通object的class中写了某个method，其内部逻辑规划 yield 对象给 block
3 普通object使用enum_for()植入2中提到的method逻辑
4 普通object的method内部使用enum_for不带参数（实际默认是使用了Enumerator中的:each）

**1 是后面3中变化的基础**

**2 可以做的是，他后面可以跟 block 因为method在yield对象出来，对应最初版本我们写的**
```ruby
def play
  NOTES.each { |note| yield note }
end
```
这里play方法就是在一次yield一个NOTES中的对象，当然他也用到了Array#each，如果想写的再原生一点，可以用到之前写loop的方式写 play
```ruby
def play
  acc = 0
  until acc == NOTES.size
    yield NOTES[acc]
    acc += 1
  end
end
```
然后测试
```ruby
2.5.0 :001 > load './deliver_enumerability.rb'
 => true
2.5.0 :002 > scale = Music::Scale.new
 => #<Music::Scale:0x00007ffe11021608>
2.5.0 :003 > scale.play { |note| p note }
"c"
"c#"
"d"
"d#"
"e"
"f"
"f#"
"g"
"a"
"a#"
"b"
 => nil
```
这里换了种写放，但是play中的基本逻辑还是一次yield一个NOTES中的对象出来。

虽然这里scale利用play模仿遍历操作，但它并不是一个enumerator，如果后面不跟block，yield就会引起报错，他也不能使用each,map,select等 Enumerable中的各种遍历方法。

```ruby
2.5.0 :004 > scale.play
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):4
        1: from /Users/caven/Notes & Articles/Note of Rubyist/code examples/deliver_enumerability.rb:9:in `play'
LocalJumpError (no block given (yield))
2.5.0 :005 >
```

**3 普通object使用enum_for()植入2中提到的method逻辑**

这里play中的代码不变，但是外部使用 enum_for 将其变成了enumerator， 作用类似在 class Scale 中 `include Enumerable`。 接着植入了 play 逻辑，这一步的作用就类似写了一个each方法用的是 play 中的逻辑。按照这个逻辑，enum = scale.to_enum(:play) 可以从each开始，使用很多遍历方法，当然each在这里表现出的行为和2中 scale.play 应该是一样的。

```ruby
2.5.0 :009 > scale
 => #<Music::Scale:0x00007ffe11021608>
2.5.0 :010 > enum = scale.enum_for(:play)  # same result as scale.play {...}
 => #<Enumerator: #<Music::Scale:0x00007ffe11021608>:play>
2.5.0 :011 > enum.each { |note| p note }
"c"
"c#"
"d"
"d#"
"e"
"f"
"f#"
"g"
"a"
"a#"
"b"
 => nil
2.5.0 :012 >
```

可以试试这种情况下的 map , select

```ruby
2.5.0 :012 > enum
 => #<Enumerator: #<Music::Scale:0x00007ffe11021608>:play>
2.5.0 :013 > enum.map { |note| note.capitalize }
 => ["C", "C#", "D", "D#", "E", "F", "F#", "G", "A", "A#", "B"]
2.5.0 :014 > enum.select { |note| note =~ /c/ }
 => ["c", "c#"]
2.5.0 :015 >
```

情况在意料之中

那么试试 index 相关的方法

```ruby
2.5.0 :016 > enum.map.with_index { |n, i| [i, n] }
 => [[0, "c"], [1, "c#"], [2, "d"], [3, "d#"], [4, "e"], [5, "f"], [6, "f#"], [7, "g"], [8, "a"], [9, "a#"], [10, "b"]]
2.5.0 :017 >
```

是可以的，因为 enum 本身是enumerator(从scale转变而来)


但我们不能对 scale.play 使用each, 以及index 相关的方法
```ruby
2.5.0 :019 > scale
 => #<Music::Scale:0x00007ffe11021608>
2.5.0 :020 > scale.play.with_index
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):20
        1: from /Users/caven/Notes & Articles/Note of Rubyist/code examples/deliver_enumerability.rb:9:in `play'
LocalJumpError (no block given (yield))
``
scale + play 的组合只是一个普通object在模拟 枚举 操作。

**4 普通object的method内部使用enum_for不带参数（实际默认是使用了Enumerator中的:each）**

当我们把 play 内部的代码改为
```ruby
def play
  NOETS.to_enum
end
```

我们实际在做的和3中做的类似，这里通过play方法我们直接拿到的一个从NOTES这个array 转变过去的 enumerator

```ruby
2.5.0 :002 > scale = Music::Scale.new
 => #<Music::Scale:0x00007fb23582dbd0>
2.5.0 :003 > scale.play
 => #<Enumerator: ["c", "c#", "d", "d#", "e", "f", "f#", "g", "a", "a#", "b"]:each>
2.5.0 :004 >
```

实际 scale.play 的后续操作就是对一个array版enum的操作，跟scale对象的联系变弱了。

注意这和3中的区别，3中play里写的是yield 逻辑，接着我们是把 scale实例转为enumerator，接着植入play作为each逻辑

```ruby
2.5.0 :007 > scale
 => #<Music::Scale:0x00007ffe11021608>
2.5.0 :008 > scale.to_enum(:play)
 => #<Enumerator: #<Music::Scale:0x00007ffe11021608>:play>
```

3中实际更接近是在 scale 对象本身进行的枚举操作

而4中做的更像借scale的壳，对一个array进行操作

-

最后总的来说，你可以将任何一个object变为一个enumerator, 但之后这个enumerator能够实际进行枚举操作的前提是，你定义好了他的each逻辑，或者你找到了一个method作为他的each的替换逻辑。不然他就只是拥有一个enumerator的壳

```ruby
2.5.0 :002 > object = Object.new
 => #<Object:0x00007fd4f511a270>
2.5.0 :003 > object.to_enum
 => #<Enumerator: #<Object:0x00007fd4f511a270>:each>
2.5.0 :004 > bare_enum = object.to_enum
 => #<Enumerator: #<Object:0x00007fd4f511a270>:each>
2.5.0 :005 > bare_enum.map { |n| p n }
Traceback (most recent call last):
        4: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        3: from (irb):5
        2: from (irb):5:in `map'
        1: from (irb):5:in `each'
NoMethodError (undefined method `each' for #<Object:0x00007fd4f511a270>)
2.5.0 :006 >
```

-

回到最初的枚举操作的赋能方式。`include Enumerable` + `def each`， 这和后面作的所有关于 enumerator 的变化在逻辑上是贯连的。 枚举操作需要一个基础的yielding逻辑，你可以仅借用这个逻辑(跟block)来模拟枚举操作，但这样能做的不多。而在这个基础上如果把操作对象转为enumerator那么在你给出的yielding基础上，Enumerator就可以作出很多变化。

-

**Exclusive-or operations on strings with enumerators**

???

-

**Lazy enumerators**

-

Lazy enumerator 让我们能够有选择地部分枚举无限集合，而在之前的例子中我们看到这种情况是会失败的。

我们将会用到  Float::INFINITY 这个代表无限大的常量

Lazy enumerators make it easy to enumerate selectively over infinitely large collections. To illustrate what this means, let’s start with a case where an operation tries to enumerate over an infinitely large collection and gets stuck. What if you want to know the first 10 multiples of 3? To use an infinite collection we’ll create a range that goes from 1 to the special value Float::INFINITY. Using such a range, a first approach to the task at hand might be

常规情况下想要 select 出1到无穷大这个 range 中 前10个 能被3整除的数 程序是会挂起的。

```ruby
2.5.0 :012 > (1..Float::INFINITY).select { |n| n % 3 == 0 }
^CTraceback (most recent call last):
        4: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        3: from (irb):12
        2: from (irb):12:in `select'
        1: from (irb):12:in `each'
IRB::Abort (abort then interrupt!)
2.5.0 :013 > (1..Float::INFINITY).select { |n| n % 3 == 0 }.first(10)
^CTraceback (most recent call last):
        4: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        3: from (irb):13
        2: from (irb):13:in `select'
        1: from (irb):13:in `each'
IRB::Abort (abort then interrupt!)
2.5.0 :014 >
```

You can get a finite result from an infinite collection by using a lazy enumerator. Calling the lazy method directly on a range object will produce a lazy enumerator over that range:

我们可以使用 lazy 来让一个无限集合变为一个 有限的(至少表面上) enumerator

```ruby
2.5.0 :018 > (1..Float::INFINITY).select
 => #<Enumerator: 1..Infinity:select>
2.5.0 :019 > (1..Float::INFINITY).lazy
 => #<Enumerator::Lazy: 1..Infinity>
2.5.0 :020 > (1..Float::INFINITY).lazy.select
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):20
        1: from (irb):20:in `select'
ArgumentError (tried to call lazy select without a block)
2.5.0 :021 > (1..Float::INFINITY).lazy.select { |n| n % 3 ==0 }.first(10)
 => [3, 6, 9, 12, 15, 18, 21, 24, 27, 30]
2.5.0 :022 >
```

这次我们顺利拿到的想要的结果

As a variation on the same theme, you can create the lazy select enumerator and then use take on it. This allows you to choose how many multiples of 3 you want to see without hard-coding the number. Note that you have to call force on the result of take; otherwise you’ll end up with yet another lazy enumerator, rather than an actual result set:

作为上面例子的变化，我们可以创建好一个 每次都只拿能被3整除的数的 enumerator , 然后对他使用 take()  这样我们可以更灵活地拿到任意个结果。注意你必须在take后跟上force,不然你最后得到的还会是一个 lazy enumerator， 而不是你想要的结果 array

```ruby
2.5.0 :022 > enum = (1..Float::INFINITY).lazy.select { |n| n % 3 ==0 }
 => #<Enumerator::Lazy: #<Enumerator::Lazy: 1..Infinity>:select>
2.5.0 :023 > enum.take(5)
 => #<Enumerator::Lazy: #<Enumerator::Lazy: #<Enumerator::Lazy: 1..Infinity>:select>:take(5)>
2.5.0 :024 > enum.take(5).force
 => [3, 6, 9, 12, 15]
2.5.0 :025 >
```

-

**FizzBuzz with a lazy enumerator**

-

Fizz buzz is a group word game for children to teach them about division. Players take turns to count incrementally, replacing any number divisible by three with the word "fizz", and any number divisible by five with the word “buzz".

The FizzBuzz problem, in its classic form, involves printing out the integers from 1 to 100 ... except you apply the following rules:
fizzbuzz游戏的经典玩法是只在1..100范围内玩：

If the number is divisible by 15, print "FizzBuzz".
Else if the number is divisible by 3, print "Fizz".
Else if the number is divisible by 5, print "Buzz".
Else print the number.

如果数字能被 15 整除 印出 FizzBuzz

如果数字能被 3 整除 印出 Fizz

如果数字能被 5 整除 印出 Buzz

其他情况直接印出这个数字

如果我们不想只在100以内玩这个游戏，想涉及更大的数字？

```ruby
def fb_calc(i)
  case 0
  when i % 15
    "FizzBuzz"
  when i % 3
    "Fizz"
  when i % 5
    "Buzz"
  else
    i.to_s
  end
end


def fb(n)
  (1..Float::INFINITY).lazy.map { |i| fb_calc(i) }.first(n)
end
```

利用 fb_calc(i) 方法 配合 lazy ，我们可以很容易的基于无限集合对前 n 个数字进行这个游戏

```ruby
2.5.0 :008 > fb(120)
 => ["1", "2", "Fizz", "4", "Buzz", "Fizz", "7", "8", "Fizz", "Buzz", "11", "Fizz", "13", "14", "FizzBuzz", "16", "17", "Fizz", "19", "Buzz", "Fizz", "22", "23", "Fizz", "Buzz", "26", "Fizz", "28", "29", "FizzBuzz", "31", "32", "Fizz", "34", "Buzz", "Fizz", "37", "38", "Fizz", "Buzz", "41", "Fizz", "43", "44", "FizzBuzz", "46", "47", "Fizz", "49", "Buzz", "Fizz", "52", "53", "Fizz", "Buzz", "56", "Fizz", "58", "59", "FizzBuzz", "61", "62", "Fizz", "64", "Buzz", "Fizz", "67", "68", "Fizz", "Buzz", "71", "Fizz", "73", "74", "FizzBuzz", "76", "77", "Fizz", "79", "Buzz", "Fizz", "82", "83", "Fizz", "Buzz", "86", "Fizz", "88", "89", "FizzBuzz", "91", "92", "Fizz", "94", "Buzz", "Fizz", "97", "98", "Fizz", "Buzz", "101", "Fizz", "103", "104", "FizzBuzz", "106", "107", "Fizz", "109", "Buzz", "Fizz", "112", "113", "Fizz", "Buzz", "116", "Fizz", "118", "119", "FizzBuzz"]
2.5.0 :009 >
```

Without creating a lazy enumerator on the range, the map operation would go on forever. Instead, the lazy enumeration ensures that the whole process will stop once we’ve got what we want.

如果没有在range的基础上建立lazy enumerator， map 操作会无限进行下去。

```ruby
2.5.0 :009 > fb(20)
 => ["1", "2", "Fizz", "4", "Buzz", "Fizz", "7", "8", "Fizz", "Buzz", "11", "Fizz", "13", "14", "FizzBuzz", "16", "17", "Fizz", "19", "Buzz"]
2.5.0 :010 >
```

**Summary**

In this chapter you’ve seen
 

- The Enumerable module and its instance methods
Enumerale module 和它的实例方法

- Using Enumerable in your own classes
在你自己的class中使用 Enumerable

- Enumerator basics
enumerator 基础

- Creating enumerators
构造enumerator

- Iterating over strings
对string 继续迭代操作？？？

- Lazy enumerators

This chapter focused on the Enumerable module and the Enumerator class, two entities with close ties. First, we explored the instance methods of Enumerable, which are defined in terms of an each method and which are available to your objects as long as those objects respond to each and your class mixes in Enumerable. Second, we looked at enumerators, objects that encapsulate the iteration process of another object, binding themselves—specifically, their each methods—to a designated method on another object and using that parasitic each-binding to deliver the full range of enumerable functionality.
这章聚焦于 module Enumerable 和 class Enumerator， 两个有着紧密关联的实体。

首先了解了 module Enumerale 中的实例方法， 也是那些建立在 each 逻辑基础之上的的方法，这些方法适用于所有include了Enumerable 并且能 respond_to?(:each).

接着我们了解了 enumerator 对象，他封装了其他对象（或默认的）的迭代逻辑，将自身绑给——准确的说是他对应的`each`方法——指定的对象并使用'代理的each逻，并以这个each为基础完成其他一整套的 enumerate 操作。

Enumerators can be tricky. They build entirely on Enumerable; and in cases where an enumerator gets hooked up to an object that has overridden some of Enumerable’s methods, it’s important to remember that the enumerator will have its own ideas of what those methods are. It’s not a general-purpose proxy to another object; it siphons off values from one method on the other object.
enumerator 有时很奇怪。他整个建立在 Enumerable的基础上； 但在有些情况下一个enumerator又可以绑给某个override了Enumerable中的枚举方法的对象（比如hash的select），重要的是记住一个enumerator有他自己对不同methods的理解。 它(enumerator)并不是对另一个对象的简单代理；它是从另一个oject身上汲取一个method的知识。
