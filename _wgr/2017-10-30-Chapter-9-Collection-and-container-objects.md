---
title:  "Rubyist-c9-Collection and container objects"
categories: [Ruby/Rails ℗]
tags: [Ruby & Rails, Notes of Rubyist]
---

*注：这一系列文章是《The Well-Grounded Rubyist》的学习笔记。*



---

## Chapter 9 Collection and container objects

Sequentially ordered collections with arrays
作为有序集合体的 array

Keyed collections with hashes
带有key的hash

Inclusion and membership tests with ranges
range 的内含测试

Unique, unordered collections with sets
作为唯一的，无序的集合体—— sets

Named arguments using hash syntax
使用hash 语法的 被命名的参数

—


Ruby represents collections of objects by putting them inside container objects. In Ruby, two built-in classes dominate the container-object landscape: arrays and hashes.

ruby 中有两种方式构建 collections : array , hash
分别对应 class Array, class Hash

另外要提到的还有 Range 和 Sets

Range 的特性较为综合，可以测试一个range中是否含有目标元素，返回 boolean ， 也可以对他进行某些 collection 可以进行的操作

Sets 不在 ruby core 中，在 standard library 中，他的存在填补了一些其他相关 class 没有覆盖到的空位


Ruby implements collections principally through the technique of defining classes that mix in the Enumerable module. That module gives you a package deal on methods that sort, sift, filter, count, and transform collections.

ruby 处理 collection 的主要手段是 引入 Enumerable 这个 module 进行一些列的 排序，筛查， 过滤， 计数，以及形式变化 等处理

Also, keep in mind that collections are, themselves, objects. You send them messages, assign them to variables, and so forth, in normal object fashion. They just have an extra dimension, beyond the scalar.

collections 也是 object ，也可以被赋值给变数，送message给他们，与纯量类型相比，他们只是多了个一个维度

-

Array 和 Hash 的比较

array的主要特点在于有序性，以及它可以包含任何object
hash的主要特点是 key/value 结构，但从2.0之后原本无序的hash 开始变得有序

Hashes in recent versions of Ruby are also ordered collections—and that’s a big change from previous versions, where hashes are unordered.

Hashes (or similar data storage types) are sometimes called dictionaries or associative arrays in other languages. They offer a tremendously—sometimes surprisingly—powerful way of storing and retrieving data.

hash在其他语言中有时被称作 dictionaries arrays 或者

associative arrays

它可以作为一种存取数据的强大工具

—

Arrays and hashes are closely connected. An array is, in a sense, a hash, where the keys happen to be consecutive integers. Hashes are, in a sense, arrays, where the indexes are allowed to be anything, not just integers. If you do use consecutive integers as hash keys, arrays and hashes start behaving similarly when you do lookups:

array 和 hash 是有紧密联系的

array 通过有序 index 来标记每个 element , 可以把 array 看做只使用连续integer作为 key 的 hash

反过来

也可以把hash 看做可以使用任意 object 作为 index 的 array

```ruby
2.5.0 :001 > array = ["ruby", "diamond", "emerald"]
 => ["ruby", "diamond", "emerald"]
2.5.0 :002 > hash = { 0=>"ruby", 1=>"diamond", 2=>"emerald" }
 => {0=>"ruby", 1=>"diamond", 2=>"emerald"}
2.5.0 :003 > array[0]
 => "ruby"
2.5.0 :004 > hash[0]
 => "ruby"
2.5.0 :005 >
```

之前提到实际 hash 在ruby中也是有序的，每一个键值对其实都有自己的 index
通过使用 with_index 对hash 进行操作就可以拿到 index

```ruby
2.5.0 :006 > hash.each.with_index { |(key, value), index| puts "Pair #{index} is: #{key} / #{value}." }
Pair 0 is: 0 / ruby.
Pair 1 is: 1 / diamond.
Pair 2 is: 2 / emerald.
 => {0=>"ruby", 1=>"diamond", 2=>"emerald"}
2.5.0 :007 >
```

The parentheses in the block parameters (key,value) serve to split apart an array. Each key/value pair comes at the block as an array of two elements. If the parameters were key,value,i, then the parameter key would end up bound to the entire [key,value] array; value would be bound to the index; and i would be nil. That’s obviously not what you want. The parenthetical grouping of (key,value) is a signal that you want the array to be distributed across those two parameters, element by element.

上的例子中的 block 中只需要两个参数，第一个参数（也就是括号中的内容）代表每个键值对，第二个代表 index 如果把参数拆成三个，key 会代表每个键值对，value 会代表 index ，而第三个 index 会是 nil

```ruby
2.5.0 :009 > hash.each.with_index { |key, value, index| puts "Pair #{index} is: #{key} / #{value}." }
Pair  is: [0, "ruby"] / 0.
Pair  is: [1, "diamond"] / 1.
Pair  is: [2, "emerald"] / 2.
 => {0=>"ruby", 1=>"diamond", 2=>"emerald"}
2.5.0 :010 >
```

array 和 hash 之间有很多不同形式的相互转换的 methods

Array

四种方式造一个 array

	•	Array.new
	•	[]
	•	Array
	•	%w{ }, %w[], %i{ } ……

  ```ruby
  2.5.0 :019 > Array.new
   => []
  2.5.0 :020 > Array.new(4)
   => [nil, nil, nil, nil]
  2.5.0 :021 > Array.new(4,"abc")
   => ["abc", "abc", "abc", "abc"]
  2.5.0 :022 >
  2.5.0 :023 > n = 0
   => 0
  2.5.0 :024 > Array.new(3) { n += 1; n * 10 }
   => [10, 20, 30]
  2.5.0 :025 > n = 0
   => 0
  2.5.0 :026 > Array.new 3 do
  2.5.0 :027 >     n += 1
  2.5.0 :028?>   n * 10
  2.5.0 :029?>   end
   => [10, 20, 30]
  2.5.0 :030 >
  2.5.0 :031 > %w{abc abc abc}
   => ["abc", "abc", "abc"]
  2.5.0 :032 > %w<abc abc abc>
   => ["abc", "abc", "abc"]
  2.5.0 :033 >
  ```

  注意小写的 %w 会解析为单引号，大写的 %W 会解析为双引号

  Array.new 的方法，可接受参数， block

  注意： 使用 Array.new(3,”something”) 方式生成的 array 中实际是同一个 object 被重复放置了 3次

```ruby
2.5.0 :036 > array.each { |e| puts e.object_id }
70192533262980
70192533262980
70192533262980
 => ["something", "something", "something"]
2.5.0 :037 >
```

和手写单独的每个 element 是不一样的

```ruby
2.5.0 :038 > array = ["something", "something", "something"]
 => ["something", "something", "something"]
2.5.0 :039 > array.each { |e| puts e.object_id }
70192541992180
70192541992160
70192541992140
 => ["something", "something", "something"]
2.5.0 :040 >
```

如果想让 生成的 同内容 element 是不同的 object 那么后面跟 block 也可以

```ruby
2.5.0 :043 > array = Array.new(3) { "abc" }
 => ["abc", "abc", "abc"]
2.5.0 :044 > array.each { |e| puts e.object_id }
70192537736720
70192537736700
70192537736680
 => ["abc", "abc", "abc"]
2.5.0 :045 >
```

-

The %i and %I array constructors

Just as you can create arrays of strings using %w and %W, you can also create arrays of symbols using %i and %I. The i/I distinction, like the w/W distinction, pertains to single- versus double-quoted string interpretation:

%i 和 %I 也可以用来生成元素是 symbol 的 array

```ruby
2.5.0 :047 > %i{ abc def xyz}
 => [:abc, :def, :xyz]
2.5.0 :048 > %I{ abc def xyz}
 => [:abc, :def, :xyz]
```
但要注意 %i 以单引号的方式行为，%I 以双引号的方式行为

```ruby
2.5.0 :057 > %i{#{1+1}, #{2+2}, #{3+3}}
 => [:"\#{1+1},", :"\#{2+2},", :"\#{3+3}"]
2.5.0 :058 > %I{#{1+1}, #{2+2}, #{3+3}}
 => [:"2,", :"4,", :"6"]
2.5.0 :059 >
```

每个空格为被作为 elements 之间的分隔标记，如果要使某个 element 中包含空格 要使用反斜线\加空格 作溢出

-

第二种生成array的方法是直接使用 literal constructor []

array 中可以包含任何 objects ，甚至包含 array 以及 nested array

The third way to create an array is with a method (even though it looks like a class name!) called Array. As you know from having seen the Integer and Float methods…

-

第三种是 使用 Array method 注意这里的 Array 不是代表 class

In addition to the Array method and the two uppercase-style conversion methods you’ve already seen (Integer and Float, the “fussy” versions of to_i and to_f), Ruby provides a few other top-level methods whose names look like class names: Complex, Rational, and String. In each case, the method returns an object of the class that its name looks like.

ruby中有一些method 是以 大写字母开头的，他看起来像是 class 或 constant ,但在一些语境下他们是 method ，但通常这些method返回的 object 就是与同名 class 对应的

这些 method 比如 Array, Integer, Float, Complex, Rational, String……

The String method is a wrapper around to_s, meaning String(obj) is equivalent to obj.to_s. Complex and Rational correspond to the to_c and to_r methods available for numerics and strings—except Complex and Rational, like Integer and Float, are fussy: they don’t take kindly to non-numeric strings. "abc".to_c gives you (0+0i), but Complex("abc") raises ArgumentError, and Rational and to_r behave similarly.


String() 实际是 挑剔版 的 to_s

Integer() 实际是 挑剔版的 to_i
```ruby
2.5.0 :006 > "123string789".to_i
 => 123
2.5.0 :007 > Integer("123string789")
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):7
        1: from (irb):7:in `Integer'
ArgumentError (invalid value for Integer(): "123string789")
2.5.0 :008 >
```

The Array method creates an array from its single argument. If the argument object has a to_ary method defined, then Array calls that method on the object to generate an array. (Remember that to_ary is the quasi-typecasting array conversion method.) If there’s no to_ary method, it tries to call to_a. If to_a isn’t defined either, Array wraps the object in an array and returns that:

`Array`方法接受一个单一参数对象。如果传入对象有 `to_ary` 方法，那么就使用`to_ary`， 如果没有就尝试使用 `to_a`， 如果还没有，那就直接用方括号包裹。

```ruby
2.5.0 :010 > "A piece of string.".respond_to?(:to_ary)
 => false
2.5.0 :011 > "A piece of string.".respond_to?(:to_a)
 => false

2.5.0 :013 > "A piece of string.".each_char.respond_to?(:to_a)
 => true
2.5.0 :014 > Array("A piece of string.".each_char)
 => ["A", " ", "p", "i", "e", "c", "e", " ", "o", "f", " ", "s", "t", "r", "i", "n", "g", "."]
2.5.0 :015 >
```

直接包裹的情况

```ruby
2.5.0 :016 > Array("A piece of string")
 => ["A piece of string"]
2.5.0 :017 >
```

Array 的工作方式是
1 只接受单一参数
2 如果参数类型有 :to_ary method 那么对参数执行 to_ary
3 如果参数没有 to_ary 尝试执行 to_a
4 如果 以上都没有，那么直接将 参数给出内容包裹进一个 []


-

Each of several built-in classes in Ruby has a class method called try_convert, which always takes one argument. try_convert looks for a conversion method on the argument object. If the method exists, it gets called; if not, try_convert returns nil. If the conversion method returns an object of a class other than the class to which conversion is being attempted, it’s a fatal error (TypeError).

有些内建的 class 都有一个 try_convert method 如果给出的 method 可以对应到 要操作的 object 那么会执行 method 如果没有，返回 nil
如果尝试转换的类型是非法的，那么报错

-

`[]=`  方法 是 array setter 可以指定（替换）那个 index 的内容

要记住这是ruby给的 syntactic sugar

```ruby
2.5.0 :019 > array = [1,2,3,4,5]
 => [1, 2, 3, 4, 5]
2.5.0 :020 > array[0] = "one"
 => "one"
2.5.0 :021 > array
 => ["one", 2, 3, 4, 5]
2.5.0 :022 > array.[]=(4,"five")
 => "five"
2.5.0 :023 > array
 => ["one", 2, 3, 4, "five"]
2.5.0 :024 >
```

如果 array 中原本有对应 index 的 element 那么新 element 将会取代旧的

如果 index 超过现有的，那么空位将由 nil 补上

```ruby
2.5.0 :026 > array
 => ["one", 2, 3, 4, "five"]
2.5.0 :027 > array[9] = "ten"
 => "ten"
2.5.0 :028 > array
 => ["one", 2, 3, 4, "five", nil, nil, nil, nil, "ten"]
2.5.0 :029 >
```

同样 使用 index 取得元素的 method 同样是 syntactic sugar

```ruby
2.5.0 :031 > array[3]
 => 4
2.5.0 :032 > array.[](3)
 => 4
2.5.0 :033 >
```

setter 和 retrieval 可以一次针对多个 elements 进行操作

```ruby
2.5.0 :035 > array[0,3]
 => ["one", 2, 3]
2.5.0 :036 > array[3,1]
 => [4]
2.5.0 :037 > array[1..5]
 => [2, 3, 4, "five", nil]
2.5.0 :038 > array[1...5]
 => [2, 3, 4, "five"]
2.5.0 :039 > array[1..3] = "multi", "sub", "operation"
 => ["multi", "sub", "operation"]
2.5.0 :040 > array
 => ["one", "multi", "sub", "operation", "five", nil, nil, nil, nil, "ten"]
2.5.0 :041 >
```

注意 [1,3] 的含义不是1到3，而是从index 1开始后面的连续3个 elements

使用单个 index 的时候，拿到的单个 object ， 使用多参数就拿到的是 array

```ruby
2.5.0 :043 > array[3]
 => "operation"
2.5.0 :044 > array[3,1]
 => ["operation"]
2.5.0 :045 >
```

array[x,y] 这个method 的一个同义词是 slice 但他有一个 bang!版本可以剔除掉指定元素

```ruby
2.5.0 :047 > array.slice(1,3)
 => ["multi", "sub", "operation"]
2.5.0 :048 > array
 => ["one", "multi", "sub", "operation", "five", nil, nil, nil, nil, "ten"]
2.5.0 :049 > array.slice!(1,3)
 => ["multi", "sub", "operation"]
2.5.0 :050 > array
 => ["one", "five", nil, nil, nil, nil, "ten"]
2.5.0 :051 >
```

另一个拿 元素 的method 是 values_at 注意这里使用的是传参数的格式

```ruby
2.5.0 :053 > array.values_at(1,3,5)
 => ["five", nil, nil]
2.5.0 :054 > array.values_at(1..5)
 => ["five", nil, nil, nil, nil]
2.5.0 :055 > array.values_at(9,1)
 => [nil, "five"]
2.5.0 :056 >
```

参数也可以是一个 range 对象，数字也可以不用从小到大排，输出的element顺序和参数list中的顺序相同

-

`.unshift()` 在array前端插入 element
`.push()` 在后端插入

注意 << 和 push 的不同之处在于，只有后者可以传多个参数

```ruby
2.5.0 :058 > array = [1,2,3,4]
 => [1, 2, 3, 4]
2.5.0 :059 > array.unshift 0, -1, -2
 => [0, -1, -2, 1, 2, 3, 4]
2.5.0 :060 > array
 => [0, -1, -2, 1, 2, 3, 4]
2.5.0 :061 > array.push 5, 6, 7
 => [0, -1, -2, 1, 2, 3, 4, 5, 6, 7]
2.5.0 :062 > array << 5,6,7
Traceback (most recent call last):
        1: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
SyntaxError ((irb):62: syntax error, unexpected ',', expecting end-of-input
array << 5,6,7
          ^)
2.5.0 :063 > array.push [7,8,9]
 => [0, -1, -2, 1, 2, 3, 4, 5, 6, 7, [7, 8, 9]]
2.5.0 :064 > 2.5.0 :058 > array = [1,2,3,4]
```

对应的 撤出元素 的方法有 shift 和 pop 一个是从前方撤出，一个是从后方撤出

而且撤出元素就不存在之前的 array 中了， 是 in-place 修改

```ruby
2.5.0 :003 > array = Array(1..6)
 => [1, 2, 3, 4, 5, 6]
2.5.0 :004 > array.shift
 => 1
2.5.0 :005 > array
 => [2, 3, 4, 5, 6]
2.5.0 :006 > array.pop
 => 6
2.5.0 :007 > array
 => [2, 3, 4, 5]
2.5.0 :008 >
```

shift 和 pop 可以撤出指定数量的 元素

```ruby
2.5.0 :008 > array = Array(1..9)
 => [1, 2, 3, 4, 5, 6, 7, 8, 9]
2.5.0 :009 > array.shift(3)
 => [1, 2, 3]
2.5.0 :010 > array
 => [4, 5, 6, 7, 8, 9]
2.5.0 :011 > array.pop(3)
 => [7, 8, 9]
2.5.0 :012 > array
 => [4, 5, 6]
2.5.0 :013 >
```

Several methods allow you to combine multiple arrays in various ways—something that, it turns out, is common and useful when you begin manipulating lots of data in lists. Remember that in every case, even though you’re dealing with two (or more) arrays, one array is always the receiver of the message. The other arrays involved in the operation are arguments to the method.

多个 array 的结合有多种方式，但是有一点要清楚，这种操作中 总有一个 array 是 receiver 而其他的 array 是参数，这里实际发生的是一个 method 的执行

array.concat(another_array) 直接抽取给出 array 的内容加到之前的 array 中，注意他与 push 和区别

```ruby
2.5.0 :016 > [1,2,3].concat [7,8,9]
 => [1, 2, 3, 7, 8, 9]
2.5.0 :017 > [1,2,3].push [7,8,9]
 => [1, 2, 3, [7, 8, 9]]
2.5.0 :018 >
```

push 和 concat 都是 in-place 改变

如果想要 return 的是一个副本 使用 `+` 方法

```ruby
2.5.0 :019 > a = [1,2,3]
 => [1, 2, 3]
2.5.0 :020 > b = [7,8,9]
 => [7, 8, 9]
2.5.0 :021 > a + b
 => [1, 2, 3, 7, 8, 9]
2.5.0 :022 > a
 => [1, 2, 3]
2.5.0 :023 > a.concat b
 => [1, 2, 3, 7, 8, 9]
2.5.0 :024 > a
 => [1, 2, 3, 7, 8, 9]
2.5.0 :025 >
```

replace 用来替代原有 array 的内容，但是要注意原来 array 只是 content 变了 object 还是原来那个 object

但参数只接受 另一个 array

```ruby
2.5.0 :027 > a = [1,2,3]
 => [1, 2, 3]
2.5.0 :028 > b = [7,8,9]
 => [7, 8, 9]
2.5.0 :029 > a.object_id
 => 70148136998400
2.5.0 :030 > a.replace b
 => [7, 8, 9]
2.5.0 :031 > a
 => [7, 8, 9]
2.5.0 :032 > a.object_id
 => 70148136998400
2.5.0 :033 >
```

要注意 变数之间的相互赋值 只是在传递 object 的编号，而不是 object 本身包含的 内容

```ruby
2.5.0 :035 > a = [1,2,3]
 => [1, 2, 3]
2.5.0 :036 > a.object_id
 => 70148145003760
2.5.0 :037 > b = a
 => [1, 2, 3]
2.5.0 :038 > c = b
 => [1, 2, 3]
2.5.0 :039 > b.object_id
 => 70148145003760
2.5.0 :040 > c.object_id
 => 70148145003760
2.5.0 :041 > a.replace ["string"]
 => ["string"]
2.5.0 :042 > a.object_id
 => 70148145003760
2.5.0 :043 > b
 => ["string"]
2.5.0 :044 > c
 => ["string"]
2.5.0 :045 >
```

replace 是 object内操作

用等号赋值一个新 array 是替代(或说覆盖) object 的操作

-

flatten / flatten! 用来给 array 降维， 默认的是直接降到最低维度，也可以给出降维层级

```ruby
2.5.0 :064 > nest = [1,2,[3,4,5],6,7,[8,9,[10,11]]]
 => [1, 2, [3, 4, 5], 6, 7, [8, 9, [10, 11]]]
2.5.0 :065 > nest.flatten
 => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
2.5.0 :066 > nest
 => [1, 2, [3, 4, 5], 6, 7, [8, 9, [10, 11]]]
2.5.0 :067 > nest.flatten(1)
 => [1, 2, 3, 4, 5, 6, 7, 8, 9, [10, 11]]
2.5.0 :068 > nest.flatten(2)
 => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
2.5.0 :069 > nest
 => [1, 2, [3, 4, 5], 6, 7, [8, 9, [10, 11]]]
2.5.0 :070 > nest.flatten!
 => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
2.5.0 :071 > nest
 => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
2.5.0 :072 >
```

reverse 和 reverse! 用来反转 array 中的内容, 也可以理解为把原来的 index 颠倒了

```ruby
2.5.0 :074 > array = Array(1..5)
 => [1, 2, 3, 4, 5]
2.5.0 :075 > array.reverse
 => [5, 4, 3, 2, 1]
2.5.0 :076 > array
 => [1, 2, 3, 4, 5]
2.5.0 :077 > array.reverse!
 => [5, 4, 3, 2, 1]
2.5.0 :078 > array
 => [5, 4, 3, 2, 1]
2.5.0 :079 >
```

join 用来把 array 的所有内容结合成一个 string， 如果给出参数，这个参数内容会作为 stirng 中 原本各个 array element 的分隔符

```ruby
2.5.0 :004 > array = Array(1..6)
 => [1, 2, 3, 4, 5, 6]
2.5.0 :005 > array.join
 => "123456"
2.5.0 :006 > array
 => [1, 2, 3, 4, 5, 6]
2.5.0 :007 > array.join("<<o>>")
 => "1<<o>>2<<o>>3<<o>>4<<o>>5<<o>>6"
2.5.0 :008 >
```

join 没有 bang! 版本

注意返回结果是 一个 字串

常用的分隔符是 comma 逗号

-

星号 * 跟 join 很像， 也可以用来组合 array 的内容返回 string

```ruby
2.5.0 :015 > array
 => [1, 2, 3, 4, 5, 6]
2.5.0 :016 > array * ""
 => "123456"
2.5.0 :017 > array * " "
 => "1 2 3 4 5 6"
2.5.0 :018 > array * ", "
 => "1, 2, 3, 4, 5, 6"
2.5.0 :019 > array * "<<o>>"
 => "1<<o>>2<<o>>3<<o>>4<<o>>5<<o>>6"
2.5.0 :020 > array
 => [1, 2, 3, 4, 5, 6]
2.5.0 :021 >
```

uniq 和 uinq! 用来剔除重复的内容

compact 和 compact! 可以用来剔除 array 中的 nil

```ruby
2.5.0 :004 > array = Array(1..9)
 => [1, 2, 3, 4, 5, 6, 7, 8, 9]
2.5.0 :005 > n = 0
 => 0
2.5.0 :006 > 4.times do
2.5.0 :007 >   array[n] = nil
2.5.0 :008?>   n += 2
2.5.0 :009?> end
 => 4
2.5.0 :010 > array
 => [nil, 2, nil, 4, nil, 6, nil, 8, 9]
2.5.0 :011 > array.compact
 => [2, 4, 6, 8, 9]
2.5.0 :012 > array
 => [nil, 2, nil, 4, nil, 6, nil, 8, 9]
2.5.0 :013 > array.compact!
 => [2, 4, 6, 8, 9]
2.5.0 :014 > array
 => [2, 4, 6, 8, 9]
2.5.0 :015 >
```

针对 array 的一些常用 querying methods

![](https://ws4.sinaimg.cn/large/006tKfTcgy1fo4u73tnmzj30hd08cq4v.jpg)

```ruby
2.5.0 :018 > array = [nil, 2, nil, 4, nil, 6, nil, 8, nil]
 => [nil, 2, nil, 4, nil, 6, nil, 8, nil]
2.5.0 :019 > array.size
 => 9
2.5.0 :020 > array.empty?
 => false
2.5.0 :021 > array.include?(nil)
 => true
2.5.0 :022 > array.count(nil)
 => 5
2.5.0 :023 > array.first
 => nil
2.5.0 :024 > array.first(3)
 => [nil, 2, nil]
2.5.0 :025 > array.last(5)
 => [nil, 6, nil, 8, nil]
2.5.0 :026 > array.sample
 => nil
2.5.0 :027 > array.sample(3)
 => [4, 6, 8]
2.5.0 :028 >
```

-

**Hash**

-

构建新 hash 的几种方式

	•	literal constructor { }
	•	Hash.new
	•	Hash.[]
	•	Hash

以上四种以常用程度排序

Hash.new 可以建立新的 空白 hash

如果Hash.new() 跟参数，那么给出的对象将会作为新key的默认值

使用新key返回了默认值，但并不因此而生产新的键值对

```ruby
2.5.0 :008 > h = Hash.new
 => {}
2.5.0 :009 > h[:one]
 => nil
2.5.0 :010 > h
 => {}
2.5.0 :011 > h = Hash.new("dvalue")
 => {}
2.5.0 :012 > h[:one]
 => "dvalue"
2.5.0 :013 > h
 => {}
2.5.0 :014 >
```

如果 Hash.new 后跟 block 来设置默认 value 则生成的键值对会存入 hash ，同时也可以自己指定 key/value

```ruby
2.5.0 :016 > h = Hash.new { |hash, key| hash[key] = "I am #{key}" }
 => {}
2.5.0 :017 > h[:one]
 => "I am one"
2.5.0 :018 > h[:two]
 => "I am two"
2.5.0 :019 > h[123]
 => "I am 123"
2.5.0 :020 > h
 => {:one=>"I am one", :two=>"I am two", 123=>"I am 123"}
2.5.0 :021 >
```

Hash.[]() 后面跟 偶数个 参数可以两类配对成键值对

```ruby
2.5.0 :023 > Hash.[](:one, :two, :three, :four)
 => {:one=>:two, :three=>:four}
2.5.0 :024 > Hash.[](:one, :two, :three, :four, :five)
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):24
        1: from (irb):24:in `[]'
ArgumentError (odd number of arguments for Hash)
2.5.0 :025 >
```

ruby 也提供了 syntactic sugar 可以使用 Hash[] 这样的格式

```ruby
2.5.0 :027 > Hash[:one,:two,:three,:four]
 => {:one=>:two, :three=>:four}

2.5.0 :030 > Hash.[]([[1,2], [3,4], [5,6]])
 => {1=>2, 3=>4, 5=>6}
2.5.0 :031 > Hash[[[1,2], [3,4], [5,6]]]
 => {1=>2, 3=>4, 5=>6}
2.5.0 :032 >
````
给出的参数对象如果是一个二维的nested array， 且内部的array中是成对的元素也可以生成相应的 hash

Hash 方法比较独特，必须，而且只能传入1个参数

如果传入的是 nil 或者 空白[] 会返回空 hash

如果传入的 对象 有to_hash 方法 则会对其执行 to_hash 如果没有，报错

```ruby
2.5.0 :042 > Hash(nil)
 => {}
2.5.0 :043 > Hash([ ])
 => {}
2.5.0 :044 > Hash([1,2])
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):44
        1: from (irb):44:in `Hash'
TypeError (can't convert Array into Hash)
2.5.0 :045 > Hash("string","string")
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):45
        1: from (irb):45:in `Hash'
ArgumentError (wrong number of arguments (given 2, expected 1))
2.5.0 :046 > Hash("string")
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):46
        1: from (irb):46:in `Hash'
TypeError (can't convert String into Hash)
2.5.0 :047 > string = "A string"
 => "A string"
2.5.0 :048 > def string.to_hash
2.5.0 :049?>   puts "After defining to_hash, it works."
2.5.0 :050?>   end
 => :to_hash
2.5.0 :051 > Hash(string)
After defining to_hash, it works.
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):51
        1: from (irb):51:in `Hash'
TypeError (can't convert String into Hash)
2.5.0 :052 >
```

The Hash method has slightly idiosyncratic behavior. If called with an empty array ([]) or nil, it returns an empty hash. Otherwise, it calls to_hash on its single argument. If the argument doesn’t have a to_hash method, a fatal error (TypeError) is raised.

不过这是最不常用的一种构建新 hash 的方法

-

新增键值对的方法 常规的是使用 hash[:key] = value 语法，但要记住这其实是 sugared 版本的 hash.[]=(:key, “value”)

```ruby
2.5.0 :057 > hash = Hash[:one,:two,:three,:four]
 => {:one=>:two, :three=>:four}
2.5.0 :058 > hash[:five] = :six
 => :six
2.5.0 :059 > hash
 => {:one=>:two, :three=>:four, :five=>:six}

2.5.0 :061 > hash.[]=(:seven, :eight) # []=() no space
 => :eight
2.5.0 :062 > hash
 => {:one=>:two, :three=>:four, :five=>:six, :seven=>:eight}
2.5.0 :063 > hash.store(:nine, :ten)
 => :ten
2.5.0 :064 > hash
 => {:one=>:two, :three=>:four, :five=>:six, :seven=>:eight, :nine=>:ten}
2.5.0 :065 >
```

When you’re adding to a hash, keep in mind the important principle that keys are unique. You can have only one entry with a given key. Hash values don’t have to be unique; you can assign the same value to two or more keys. But you can’t have duplicate keys.

hash 的 key 必须是唯一的，这里的唯一不仅指key不能是同一个object, 就连内容都不能一一，比如两个content相同但object_id 不同的string对象， value 的值可以重复

如果键入了同名称的key 后者键值对将会 覆盖前者

```ruby
2.5.0 :068 > hash
 => {:one=>:two, :three=>:four, :five=>:six, :seven=>:eight, :nine=>:ten}
2.5.0 :069 > hash[:one] = "Yi"
 => "Yi"
2.5.0 :070 > hash
 => {:one=>"Yi", :three=>:four, :five=>:six, :seven=>:eight, :nine=>:ten}
2.5.0 :071 > one = "one"
 => "one"
2.5.0 :072 > first = "one"
 => "one"
2.5.0 :073 > hash[one] = "dup_key"
 => "dup_key"
2.5.0 :074 > hash
 => {:one=>"Yi", :three=>:four, :five=>:six, :seven=>:eight, :nine=>:ten, "one"=>"dup_key"}
2.5.0 :075 > hash[first] = "new_key"
 => "new_key"
2.5.0 :076 > hash
 => {:one=>"Yi", :three=>:four, :five=>:six, :seven=>:eight, :nine=>:ten, "one"=>"new_key"}
2.5.0 :077 >
```

If you reassign to a given hash key, that key still maintains its place in the insertion order of the hash. The change in the value paired with the key isn’t considered a new insertion into the hash.

但这种同名 key 的覆盖 并不是完整意义上的覆盖，原来键值对在 hash 中的位置并不会改变，实际发生改变的只有 对应的 Value

取得 hash 值的 方法，除了 hash[:key] 语法 还可以使用
`fetch`
二者的区别在于，后者如果传入不存在的 key 会报错，而前者会返回 nil 或者之前设好的 value 的默认值

```ruby
2.5.0 :079 > hash = Hash.new("default_value")
 => {}
2.5.0 :080 > hash[:unkonw_key]
 => "default_value"
2.5.0 :081 > hash
 => {}
2.5.0 :082 > hash.fetch(:unknown_key)
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):82
        1: from (irb):82:in `fetch'
KeyError (key not found: :unknown_key)
2.5.0 :083 >
```

You can also retrieve values for multiple keys in one operation, with values_at:

一次传入多个keys取得多个 value 使用 values_at

```ruby
2.5.0 :091 > hash = Hash[1,2,3,4,5,6]
 => {1=>2, 3=>4, 5=>6}
2.5.0 :092 > hash = Hash[1,2,3,4,5,6,7,8,9,0]
 => {1=>2, 3=>4, 5=>6, 7=>8, 9=>0}
2.5.0 :093 > hash.values_at(1,7,9)
 => [2, 8, 0]
2.5.0 :094 >
```

hash 的默认值用法

当给设有默认值的hash 中传入陌生 key 时，虽然会返回默认值，但是并不会自动将这个键值对 加入 hash

```ruby
2.5.0 :096 > hash = Hash.new("default value")
 => {}
2.5.0 :097 > hash[:one] = "one"
 => "one"
2.5.0 :098 > hash
 => {:one=>"one"}
2.5.0 :099 > hash[:two]
 => "default value"
2.5.0 :100 > hash
 => {:one=>"one"}
2.5.0 :101 >
```

如果想让每次传入 陌生 key 时将这个键值对 注入 hash 那么要在

Hash.new { #block here }

后面加上 block (拿到return值而不仅仅是一个参数对象)

If you want references to nonexistent keys to cause the keys to come into existence, you can arrange this by supplying a code block to Hash.new. The code block will be executed every time a nonexistent key is referenced. **Two objects will be yielded to the block: the hash and the (nonexistent) key.**

```ruby
2.5.0 :107 > h = Hash.new { |self, key| self[key] = rand(1000) }
Traceback (most recent call last):
        1: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
SyntaxError ((irb):107: syntax error, unexpected keyword_self, expecting '|'
h = Hash.new { |self, key| self[key] = rand(1000)...
                ^~~~
(irb):107: Can't change the value of self
h = Hash.new { |self, key| self[key] = rand(1000) }
                    ^
(irb):107: syntax error, unexpected '|', expecting '='
h = Hash.new { |self, key| self[key] = rand(1000) }
                         ^
(irb):107: syntax error, unexpected '}', expecting end-of-input
..., key| self[key] = rand(1000) }
...                              ^)
2.5.0 :108 > h = Hash.new { |hash, key| hash[key] = rand(1000) }
 => {}
2.5.0 :109 > h[:one]
 => 540
2.5.0 :110 > h[:two]
 => 485
2.5.0 :111 > h
 => {:one=>540, :two=>485}
2.5.0 :112 >
```

代表hash对象本身的识别符不能使用 self

-

两个 hash 之间的组合

update 方法 会将后一个 hash 注入到前一个 hash 中，如果有同名 key ，将会进行覆盖操作

```ruby
2.5.0 :114 > h1 = { :one=>1000, :two=>2000 }
 => {:one=>1000, :two=>2000}
2.5.0 :115 > h2 = { :one => 999 }
 => {:one=>999}
2.5.0 :116 > h1.update(h2)
 => {:one=>999, :two=>2000}
2.5.0 :117 > h1
 => {:one=>999, :two=>2000}
2.5.0 :118 >
```

而 merge 则不会动到之前给出的任何一个 hash 而是产生一个新的 副本

```ruby
2.5.0 :117 > h1
 => {:one=>999, :two=>2000}
2.5.0 :118 > h3 = { :one => 888 }
 => {:one=>888}
2.5.0 :119 > h1.merge(h3)
 => {:one=>888, :two=>2000}
2.5.0 :120 > h1
 => {:one=>999, :two=>2000}
2.5.0 :121 >
```

merge 也有 bang! 版本，效果和 update 相同

-

**Hash transformations — hash to hash operations**

select 和 reject 是一对 对应的从 hash 中过滤信息的 methods

他们都只返回结果副本，不改变原来的 hash

对应的 他们也有 bang! 版本的 select! 和 reject! 这两个则会改变原来的 hash

```ruby
2.5.0 :131 > hash = Hash[1,2,3,4,5,6,7,8,9,0]
 => {1=>2, 3=>4, 5=>6, 7=>8, 9=>0}
2.5.0 :132 > hash.select { |k, v| k > 5 }
 => {7=>8, 9=>0}
2.5.0 :133 > hash
 => {1=>2, 3=>4, 5=>6, 7=>8, 9=>0}
2.5.0 :134 > hash.reject { |k, v| k < 5 }
 => {5=>6, 7=>8, 9=>0}
2.5.0 :135 > hash
 => {1=>2, 3=>4, 5=>6, 7=>8, 9=>0}
2.5.0 :136 >
2.5.0 :137 > hash.reject! { |k, v| k < 5 }
 => {5=>6, 7=>8, 9=>0}
2.5.0 :138 > hash
 => {5=>6, 7=>8, 9=>0}
2.5.0 :139 >
```

bang! 版本的 select! 和 reject! 有同效果的两个 methods

keep_if 和 delete_if

```ruby
2.5.0 :140 > hash = Hash[1,2,3,4,5,6,7,8,9,0]
 => {1=>2, 3=>4, 5=>6, 7=>8, 9=>0}
2.5.0 :141 > hash.keep_if { |k, v| v >= 6 }
 => {5=>6, 7=>8}
2.5.0 :142 > hash
 => {5=>6, 7=>8}
2.5.0 :143 >
2.5.0 :144 > hash = Hash[1,2,3,4,5,6,7,8,9,0]
 => {1=>2, 3=>4, 5=>6, 7=>8, 9=>0}
2.5.0 :145 > hash.delete_if { |k, v| k <= 5 }
 => {7=>8, 9=>0}
2.5.0 :146 > hash
 => {7=>8, 9=>0}
2.5.0 :147 >
```

invert 用来反转 hash 中的 key 和 value

注意 invert 没有 bang! 版本

```ruby
2.5.0 :150 > hash = Hash[1,2,3,4,5,6,7,8,9,0]
 => {1=>2, 3=>4, 5=>6, 7=>8, 9=>0}
2.5.0 :151 > hash.invert
 => {2=>1, 4=>3, 6=>5, 8=>7, 0=>9}
2.5.0 :152 > hash
 => {1=>2, 3=>4, 5=>6, 7=>8, 9=>0}
2.5.0 :153 > hash.invert!
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):153
NoMethodError (undefined method `invert!' for {1=>2, 3=>4, 5=>6, 7=>8, 9=>0}:Hash
Did you mean?  invert)
2.5.0 :154 >
```

还有一点需要注意的是 hash 中要求 key 的唯一性，但 hash 中可能有相同 values , 这种情况下的 invert 只会保留其中一个反转后的同名key ， 其他的将会被丢弃

```ruby
2.5.0 :157 > hash = Hash[1,2,2,2,3,2,4,2,5,2]
 => {1=>2, 2=>2, 3=>2, 4=>2, 5=>2}
2.5.0 :158 > hash.invert
 => {2=>5}
2.5.0 :159 > hash
 => {1=>2, 2=>2, 3=>2, 4=>2, 5=>2}
2.5.0 :160 >
```

一般来说会是后出现的覆盖前面的

hash.clear 用来清空 hash 且是 in-place 操作

hash.replace(another_hash) 用来替换原来hash 中的 content 也是 in-place 操作

```ruby
2.5.0 :165 > hash = Hash[1,2,2,2,3,2,4,2,5,2]
 => {1=>2, 2=>2, 3=>2, 4=>2, 5=>2}
2.5.0 :166 > hash.replace {:another => "hash"}
Traceback (most recent call last):
        1: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
SyntaxError ((irb):166: syntax error, unexpected =>, expecting '}'
hash.replace {:another => "hash"}
                       ^~
(irb):166: syntax error, unexpected '}', expecting end-of-input
...sh.replace {:another => "hash"}
...                              ^)
2.5.0 :167 > hash.replace ({:another => "hash"})
 => {:another=>"hash"}
2.5.0 :168 > hash
 => {:another=>"hash"}
2.5.0 :169 >
```

使用当把 某个 hash 对象作为参数传入的时候需要用括号包起来，因为如果不包，语法上会有歧义，ruby 不会知道你是传了一个 hash object 还是方法后面跟了一个 block

The rule in this case is that you must not only put curly braces around the hash but also put the entire argument list in parentheses. If you don’t, Ruby will think your hash is a code block.

当 hash 在参数list尾端时， ruby 允许我们省掉 { } 使用 key: value 这样的格式传入 hash 参数

另外一些 hash 的常用方法

```ruby
2.5.0 :171 > hash = Hash[1,2,2,2,3,2,4,2,5,2]
 => {1=>2, 2=>2, 3=>2, 4=>2, 5=>2}
2.5.0 :172 > hash.has_key?(4)
 => true
2.5.0 :173 > hash.include?(5)
 => true
2.5.0 :174 > hash.key?(4)
 => true
2.5.0 :175 > hash.member?(4)
 => true
2.5.0 :176 > hash.has_value?(2)
 => true
2.5.0 :177 > hash.empty?
 => false
2.5.0 :178 > hash.size
 => 5
2.5.0 :179 >
```
hash.has_key() 与 hash.include?() 与 hash.key?()  与 hash.member?() 是4个同义 methods

hash.has_value?() 与 hash.value?() 是2个同义 methods

hash.empty? 查询hash 是否为空

hash.size 和 .length查询键值对数量

-

If you call a method in such a way that the last argument in the argument list is a hash, Ruby allows you to write the hash without curly braces. This perhaps trivial-sounding special rule can, in practice, make argument lists look much nicer than they otherwise would.

当 hash 在作为argument list中的最后一个参数时，可以省掉 curly braces 和 parentheses 也可以使用常规的 hash 格式

```ruby
class City
  attr_accessor :name, :population, :age
end

def city_intro(name, info)
  c = City.new
  c.name = name
  c.population = info[:population]
  c.age = info[:age]
  puts c.name, c.population, c.age
end

city_intro "Newyork", population: 800000, age: 50

puts "-" * 30

city_intro "Omaha", {:population => 900000, :age => 80}

```

执行结果

```ruby
ruby hash_ar.rb
Newyork
800000
50
------------------------------
Omaha
900000
80
```

但如果 hash 是第一个参数，上面两个用法都不行

带 curly braces

当hash对象作为参数如果不是最后一个传入的，必须同时使用 parentheses 和 curly braces 的完整格式 ruby 才能正确识别

```ruby
class City
  attr_accessor :name, :population, :age
end

def city_intro(info, name)
  c = City.new
  c.name = name
  c.population = info[:population]
  c.age = info[:age]
  puts c.name, c.population, c.age
end

city_intro({:population => 9999, :age => 50}, "Hash first") # complete syntax
```

输出

```ruby
ruby hash_ar1.rb
Hash first
9999
50
```

不过仔细区分这类省略句法意义不大，完整的符号虽然更冗余，但是歧义更少，出错概率更低

Keep in mind that although you get to leave the curly braces off the hash literal when it’s the last thing in an argument list, you can have as many hashes as you wish as method arguments, in any position. Just remember that it’s only when a hash is in the final argument position that you’re allowed to dispense with the braces.

-

hash(必须是hash对象) 作为参数时，直接使用  named arg 可以省去在 method内“拆包裹”的步骤，直接通过 key 拿对应的值

定义方法时 使用 notation: 的语法，而不是 :symbol

注意 定义行是冒号在后

注意 方法中 没有冒号

```ruby
2.5.0 :003 > def show(a:, b:)
2.5.0 :004?>   puts a, b
2.5.0 :005?>   end
 => :show
2.5.0 :006 > show(a: "one", b: "two")
one
two
 => nil
2.5.0 :007 > show("one", "two")
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):7
        1: from (irb):3:in `show'
ArgumentError (wrong number of arguments (given 2, expected 0; required keywords: a, b))
2.5.0 :008 > show(a: "three")
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):8
        1: from (irb):3:in `show'
ArgumentError (missing keyword: b)
2.5.0 :009 >
```

注意上面的例子中，参数list中只能传 hash 对象，如果写method的时候 a:, b: 没有写默认参数value， 那么就必须传正确个数的 hash 对象

也可以把参数直接写成 hash 格式

但是 key 的名称必须一致

```ruby
2.5.0 :011 > show(:a => "one", :b => "two")
one
two
 => nil
2.5.0 :012 > show(:a => "one", :c => "two")
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):12
        1: from (irb):3:in `show'
ArgumentError (missing keyword: b)
2.5.0 :013 >
```

下面是定义方法时设置默认值的情况，这样传参数的时候就没那么严格了

```ruby
2.5.0 :015 > def add_default(a: "one", b: "two")
2.5.0 :016?>   puts a, b
2.5.0 :017?> end
 => :add_default
2.5.0 :018 >
2.5.0 :019 > add_default
one
two
 => nil
2.5.0 :020 > add_default(b: "hello")
one
hello
 => nil
2.5.0 :021 >
```

在常规的多参数 method 中， 带星号* 的arg 会吸掉多余的 args

而如果使用两个星号 **args 则会将多余的key/value参数吸收后并纳入一个 hash 中

```ruby
2.5.0 :027 > def meth(a: 1, b: 2, **c)
2.5.0 :028?>   p a,b,c
2.5.0 :029?>   end
 => :meth
2.5.0 :030 > meth(x: "one", y: "two")
1
2
{:x=>"one", :y=>"two"}
 => [1, 2, {:x=>"one", :y=>"two"}]
2.5.0 :031 >
```

但如果后面给出参数含有 非 key/value (hash) 内容

则会报错

```ruby
2.5.0 :032 > meth(x: "one", y: "two",[1,2])
Traceback (most recent call last):
        1: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
SyntaxError ((irb):32: syntax error, unexpected ')', expecting =>
meth(x: "one", y: "two",[1,2])
                             ^)
2.5.0 :033 > meth(x: "one", y: "two", "three", "four")
Traceback (most recent call last):
        1: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
SyntaxError ((irb):33: syntax error, unexpected ',', expecting =>
...th(x: "one", y: "two", "three", "four")
...                              ^
(irb):33: syntax error, unexpected ')', expecting end-of-input
...ne", y: "two", "three", "four")
...                              ^)
2.5.0 :034 >
```


当然可以把所有的参数使用方式放到一起，包括 &block 作为参数

```ruby
2.5.0 :036 > def m(x, y, *z, a: 1, b: 2, **c, &block)
2.5.0 :037?>   p x,y,z,a,b,c
2.5.0 :038?>   yield
2.5.0 :039?>   end
 => :m
2.5.0 :040 > m(1,2,3,4,5,b:10,c:20,e:30)
1
2
[3, 4, 5]
1
10
{:c=>20, :e=>30}
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):40
        1: from (irb):38:in `m'
LocalJumpError (no block given (yield))  # if used `yield` in definition body, we must give it a blcok
2.5.0 :041 > m(1,2,3,4,5,b:10,c:20,e:30) do
2.5.0 :042 >     3.times { p "yiled me!"}
2.5.0 :044?> end
1
2
[3, 4, 5]
1
10
{:c=>20, :e=>30}
"yiled me!"
"yiled me!"
"yiled me!"
 => 3
2.5.0 :045 >
2.5.0 :046 > m(1,2,3,4,5,b:10,c:20,e:30) { 3.times {p "yield me!"} }
1
2
[3, 4, 5]
1
10
{:c=>20, :e=>30}
"yield me!"
"yield me!"
"yield me!"
 => 3
2.5.0 :047 >
```

如果 argument list 中有 &block 但是 definition body 中没有写 yield， 那就可以不传 block

```ruby
2.5.0 :049 > def m(x, y, *z, a: 1, b: 2, **c, &block)
2.5.0 :050?>   p x,y,z,a,b,c
2.5.0 :051?> end
 => :m
2.5.0 :052 > m(1,2,3,4,5,b:10,c:20,e:30)
1
2
[3, 4, 5]
1
10
{:c=>20, :e=>30}
 => [1, 2, [3, 4, 5], 1, 10, {:c=>20, :e=>30}]
2.5.0 :053 >
```

`**c` 参数吸收掉了未知的 hash 对象

-

**Ranges**

A range is an object with a start point and an end point. The semantics of range operations involve two major concepts:

	•	Inclusion —Does a given value fall inside the range?
	•	Enumeration —The range is treated as a traversable collection of individual items.


range 有一个起点和终点， 它的两个核心特性是：

1 内含能力

2 可以走访性


The logic of inclusion applies to all ranges; you can always test for inclusion. The logic of enumeration kicks in only with certain ranges—namely, those that include a finite number of discrete, identifiable values. You can’t iterate over a range that lies between two floating-point numbers, because the range encompasses an infinite number of values. But you can iterate over a range between two integers.

内含能力是每一个 range 都具有的特性
但是走访性则有条件限制，比如我们无法遍历 起始点为 float 的range 因为理论上他们之间内含的浮点数是无限的。但如果 range 的起始点是 integer 则此range可以进行遍历操作

—

range 分为

inclusive range

和

exclusive range

两种，句法上的区别是 两个点 或者 三个点

如果使用 Range.new(m,n)  默认是 两个点的 情况

如果后面多传一个 true 则会生成 三个点的 range

```ruby
2.5.0 :055 > r = Range.new(1,100)
 => 1..100
2.5.0 :056 > r = Range.new(1,100,true)
 => 1...100
2.5.0 :057 > r = Range.new(1...99)
Traceback (most recent call last):
        4: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        3: from (irb):57
        2: from (irb):57:in `new'
        1: from (irb):57:in `initialize'
ArgumentError (wrong number of arguments (given 1, expected 2..3))
2.5.0 :058 >
```

Range.new 后不能直接给出一个 range

```ruby
2.5.0 :060 > 1..100.class
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):60
ArgumentError (bad value for range)
2.5.0 :061 > (1..100).class
 => Range
2.5.0 :062 > (1..100).class
 => Range
2.5.0 :063 > (1..100).object_id
 => 70261496206580
2.5.0 :064 > (1..100).object_id
 => 70261487574880
2.5.0 :065 > (1..100).object_id
 => 70261487539280
2.5.0 :066 >
```

range 对象不像 symbol 那样具有唯一性。同一范围的 range 可以是不同 object

```ruby
2.5.0 :068 > 1..100.include?(100)
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):68
NoMethodError (undefined method `include?' for 100:Integer)
2.5.0 :069 > (1..100).include?(100)
 => true
2.5.0 :070 > (1...100).include?(100)
 => false
2.5.0 :071 >
```

对 range 对象使用method时要使用 括号 将 range 对象包裹起来

**range inclusion logic**

使用 begin 和 end 可以查看 range 的始末数字

使用 exclude_end?  可以判断一个 range 是3个点(exclusive) 还是两个点(inclusive) 的range

```ruby
2.5.0 :073 > (1..10).begin
 => 1
2.5.0 :074 > (1..10).end
 => 10
2.5.0 :075 > (1..10).exclude_end?
 => false
2.5.0 :076 > (101...199).exclude_end?
 => true
2.5.0 :077 >
```


cover?()

include?()

member?()

是三个同名的检查内含的methods

```ruby
2.5.0 :079 > (1..10).include?(7)
 => true
2.5.0 :080 > (1..10).member?(7)
 => true
2.5.0 :081 > (1..10).cover?(7)
 => true
2.5.0 :082 >
```

include 和 member 的行为是相同的，但 cover 与前面两个有所区别

cover 会将 range 中的内容作为一个连续统一体对待

include 和 member 会将 range 中的内容理解为单独独立的对象

因此cover对于连续字母的检查返回 true

但同样的情况 inlcude 返回的是 false

```ruby
2.5.0 :088 > ('a'..'z').include?("rst")
 => false
2.5.0 :089 > ('a'..'z').member?("rst")
 => false
2.5.0 :090 > ('a'..'z').cover?("rst")
 => true
2.5.0 :091 > ('a'..'z').cover?("abcdefg")
 => true
2.5.0 :092 >
```

对于数字类型的 range 上面几个 内含检查 methods 的行为就是一致的

```ruby
2.5.0 :094 > (1..10).include?(5)
 => true
2.5.0 :095 > (1..10).member?(5)
 => true
2.5.0 :096 > (1..10).cover?(5)
 => true
2.5.0 :097 > (1..10).cover?(567)
 => false
2.5.0 :098 >
```

一个 range  a..b 用自然语言表述出来是 大于等于a 小于等于b 的范围

如果起点值大于终点值呢

ruby 允许存在 反向的 range

但是这个range 没有什么实际用途,

对反向 range 操作并不会出现 runtime error

但通常返回 false 这是一个 逻辑上的错误 ，而不是程序上的错误, 虽然可以造出这个 range ，而且能够拿到起点和终点，不过这个range中什么都不包含

```ruby
2.5.0 :100 > range = Range.new(100,1)
 => 100..1
2.5.0 :101 > range.include?(100)
 => false
2.5.0 :102 > range.include?(1)
 => false
2.5.0 :103 > range.include?(50)
 => false
2.5.0 :104 > range.begin
 => 100
2.5.0 :105 > range.end
 => 1
2.5.0 :106 >
```

反向 range 存在作用的一个特例是作为string或array index 的时候

不过只有当 range 的实际顺序是往后走的时候才会有效

```ruby
2.5.0 :108 > string = "I am a piece of string!"
 => "I am a piece of string!"
2.5.0 :109 > string[10...-1]
 => "ce of string"
2.5.0 :110 > string[10..9]
 => ""
2.5.0 :111 > string[10..1]
 => ""
2.5.0 :112 > array = %w{ a b c d e f g h}
 => ["a", "b", "c", "d", "e", "f", "g", "h"]
2.5.0 :113 > array[3..-1]
 => ["d", "e", "f", "g", "h"]
2.5.0 :114 > array[3..1]
 => []
2.5.0 :115 >
```

-

**Sets**

Set 并不在 ruby 的 core classes 中，是 standard library 中的一个class ， 需要 require 后才能使用

```ruby
2.5.0 :116 > require 'set'
 => true
2.5.0 :117 >
```

A set is a unique collection of objects. The objects can be anything—strings, integers, arrays, other sets—but no object can occur more than once in the set. Uniqueness is also enforced at the commonsense content level: if the set contains the string "New York", you can’t add the string "New York" to it, even though the two strings may technically be different objects. The same is true of arrays with equivalent content.

set 的特性是 可以包含任何 object 包括其他 sets

但其中不能有 相同的 content 或 object

这意味着 不同object_id 但相同 content 的对象是不能同时存在于一个 set 中的

而在 array 中同一个object被放置多次是可以的

```ruby
2.5.0 :119 > a = "one"
 => "one"
2.5.0 :120 > array = [a, "two"]
 => ["one", "two"]
2.5.0 :121 > array << a
 => ["one", "two", "one"]
2.5.0 :122 > array[0].object_id
 => 70261483943440
2.5.0 :123 > array[2].object_id
 => 70261483943440
2.5.0 :124 >
```

Internally, sets use a hash to enforce the uniqueness of their contents. When an element is added to a set, the internal hash for that set gets a new key.

set 在内部实现 uniqueness 的方式是使用 hash key 的唯一性特性
每当给set 注入一个新 object 时， set 会把这个 object 转换为一个 hash key ，这样不管 这个object是在id层面还是 content 层面重复，都不被允许
（content作为key？）

—


新建一个 set 可以使用 Set.new() ，参数小于等于1个

如果传入的是一维的 collection, 这个 collection 中的 elements 将会拆成这个 set 中单独的对象

```ruby
2.5.0 :126 > hash = Hash[1,2,3,4,5,6]
 => {1=>2, 3=>4, 5=>6}
2.5.0 :127 > set = Hash.new(hash)
 => {}
2.5.0 :128 > hash = Hash[1,2,3,4,5,6]
 => {1=>2, 3=>4, 5=>6}
2.5.0 :129 > set = Set.new(hash)
 => #<Set: {[1, 2], [3, 4], [5, 6]}>
2.5.0 :130 >
2.5.0 :131 > array = [1,2,3,4,5,6]
 => [1, 2, 3, 4, 5, 6]
2.5.0 :132 > set = Set.new(array)
 => #<Set: {1, 2, 3, 4, 5, 6}>
2.5.0 :133 > array = [1,2,3,3,2,1]
 => [1, 2, 3, 3, 2, 1]
2.5.0 :134 > set = Set.new(array)
 => #<Set: {1, 2, 3}>
2.5.0 :135 >
```

如果给出的是一个 hash 那么每对 键值对 将被包裹为一个 小的独立 array 放在 set 中

给出一维 array 变化不大，但如果给出的 array 中有重复的content将会被合并

合并后 set 中的同名object不是原来重复对象中的任何一个

```ruby
2.5.0 :137 > array = ["one", "one", "one", "one"]
 => ["one", "one", "one", "one"]
2.5.0 :138 > array.each { |e| p e.object_id }
70261487591360
70261487591120
70261487590720
70261487590700
 => ["one", "one", "one", "one"]
2.5.0 :139 > set = Set.new(array)
 => #<Set: {"one"}>
2.5.0 :140 > set.first.object_id
 => 70261483943480
2.5.0 :141 >
```

同样 Set.new(arg) 后可以跟一个 block 对 arg 进行操作

```ruby
2.5.0 :143 > names = %w{caven roger black summer}
 => ["caven", "roger", "black", "summer"]
2.5.0 :144 > set = Set.new(names) { |e| e.upcase }
 => #<Set: {"CAVEN", "ROGER", "BLACK", "SUMMER"}>
2.5.0 :145 >
```

-

**Manipulating set elements**

-

<< 用来向 set 中注入新对象

如果第二次注入相同的内容或对象，那么不会有任何改变

add 和 << 是同义词

```ruby
2.5.0 :156 > set = Set.new([1,2,3,4])
 => #<Set: {1, 2, 3, 4}>
2.5.0 :157 > set << {:one => "one"}
 => #<Set: {1, 2, 3, 4, {:one=>"one"}}>
2.5.0 :158 > set << "string"
 => #<Set: {1, 2, 3, 4, {:one=>"one"}, "string"}>
2.5.0 :159 > set.add([5,6,7])
 => #<Set: {1, 2, 3, 4, {:one=>"one"}, "string", [5, 6, 7]}>
2.5.0 :160 >
```

`add?` 方法的用法是，如果给出的 对象 已经存在于 set 中，那么返回nil 注入无效
如果 给出的对象是陌生的 那么效果和 add 与 << 相同

```ruby
2.5.0 :161 > set << "string"
 => #<Set: {1, 2, 3, 4, {:one=>"one"}, "string", [5, 6, 7]}>
2.5.0 :162 > set.add "string"
 => #<Set: {1, 2, 3, 4, {:one=>"one"}, "string", [5, 6, 7]}>
2.5.0 :163 > set.add? "string"
 => nil
2.5.0 :164 >
```

-

**set intersection, union, and difference**

set 之间的 交集，合集，以及差异

	•	intersection, aliased as & 求交集
	•	union, aliased as + and | 求合集
	•	difference, aliased as - 从前者中减去二者交集

Each of these methods returns a new set consisting of the original set, plus or minus the appropriate elements from the object provided as the method argument. The original set is unaffected.


这些方法返回的都是基于第一个 Set 的新的副本，不影响原来的两个 set

```ruby
2.5.0 :003 > set1 = Set.new([1,2,3,4,5,6,7])
 => #<Set: {1, 2, 3, 4, 5, 6, 7}>
2.5.0 :004 > set2 = Set.new([4,5,6,7,8,9,0])
 => #<Set: {4, 5, 6, 7, 8, 9, 0}>
2.5.0 :005 > set1 + set2
 => #<Set: {1, 2, 3, 4, 5, 6, 7, 8, 9, 0}>
2.5.0 :006 > set1 & set2
 => #<Set: {4, 5, 6, 7}>
2.5.0 :007 > set1 - set2 # 从set1 中减去 set2
 => #<Set: {1, 2, 3}>
2.5.0 :008 > set2 - set1
 => #<Set: {8, 9, 0}>
2.5.0 :010 > set1 ^ set2 # 合集中减去交集
 => #<Set: {8, 9, 0, 1, 2, 3}>
2.5.0 :011 >
```

-

merge() 可以将其他类型的 collection 并入 set

merge 之后的 set 还是原来那个 object_id 不变

```ruby
2.5.0 :006 > set = Set.new([1,2,3,4])
 => #<Set: {1, 2, 3, 4}>
2.5.0 :007 > set.object_id
 => 70188834259780
2.5.0 :008 > set.merge(["string", "in", "array"])
 => #<Set: {1, 2, 3, 4, "string", "in", "array"}>
2.5.0 :009 > set.object_id
 => 70188834259780
2.5.0 :010 > set.merge("must be collection object")
Traceback (most recent call last):
        4: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        3: from (irb):10
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/2.5.0/set.rb:433:in `merge'
        1: from /Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/2.5.0/set.rb:128:in `do_with_enum'
ArgumentError (value must be enumerable)
2.5.0 :011 >
```

Merging a hash into a set results in the addition of two-element, key/value arrays to the set—because that’s how hashes break themselves down when you iterate through them.

如果并入的是 hash 那么键值对仍然被拆成小的 array 来处理。注意传array的情况，同样会有降维操作，如果是一维array，那直接降成 bare list

```ruby
=> #<Set: {1, 2, 3, 4, "string", "in", "array"}>
2.5.0 :016 > set.merge([["string", "in", "array"]])
=> #<Set: {1, 2, 3, 4, "string", "in", "array", ["string", "in", "array"]}>
2.5.0 :017 > set.merge({:one => "one", :two => "two"})
=> #<Set: {1, 2, 3, 4, "string", "in", "array", ["string", "in", "array"], [:one, "one"], [:two, "two"]}>
2.5.0 :018 >
```

但直接传 bare list 不行，会被解析为 3 个单独参数

```ruby
2.5.0 :033 > array = %w[one two three]
 => ["one", "two", "three"]
2.5.0 :034 > set1
 => #<Set: {1, 2, 3, 4}>
2.5.0 :035 > set1.merge(*array)
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):35
        1: from /Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/2.5.0/set.rb:429:in `merge'
ArgumentError (wrong number of arguments (given 3, expected 1))
2.5.0 :036 > set1.merge(array)
 => #<Set: {1, 2, 3, 4, "one", "two", "three"}>
2.5.0 :037 >
```

suersets and subsets

—

子集 与 超集

可以理解为包含或被包含测试

set1.subset?(set2)

疑问语气的语序与代码相同
set1是set2 的子集吗？
陈述语气的语序与代码相反
set2是set1的子集

```ruby
2.5.0 :020 > set1 = Set.new([1,2,3,4,5,6])
 => #<Set: {1, 2, 3, 4, 5, 6}>
2.5.0 :021 > set2 = Set.new([3,4])
 => #<Set: {3, 4}>
2.5.0 :022 > set1.subset?(set2)
 => false
2.5.0 :023 > set1.superset?(set2)
 => true
2.5.0 :024 >
```

要注意 两个set 相同的情况

这种情况下两个 Set 互为子集和交集，任何subset? 和 superset?() 测试都是 true

如果想使用更加严格的测试可以使用 proper_subset? 和 proper_superset?

```ruby
2.5.0 :026 > set1 = Set.new([1,2,3,4])
 => #<Set: {1, 2, 3, 4}>
2.5.0 :027 > set2 = Set.new([1,2,3,4])
 => #<Set: {1, 2, 3, 4}>
2.5.0 :028 > set1.subset?(set2)
 => true
2.5.0 :030 > set1.superset?(set2)
 => true
2.5.0 :031 > set1.proper_superset?(set2)
 => false
2.5.0 :032 > set1.proper_subset?(set2)
 => false
2.5.0 :033 >
```

-

## Summary
In this chapter you’ve seen

How to create, manipulate, and transform collection objects, including


- Arrays

- Hashes

- Ranges

- Sets

  - Named arguments
