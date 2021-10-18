---
title:  "Rubyist-c8-Strings symbols and other scalar objects"
categories: [Ruby/Rails ℗]
tags: [Ruby & Rails, Notes of Rubyist]
---

*注：这一系列文章是《The Well-Grounded Rubyist》的学习笔记。*



---

This chapter covers

- String object creation and manipulation
string对象的建立和操作

- Methods for transforming strings
string的变换方法

- Symbol semantics
symbol 语义

- String/symbol comparison
string 和 symbol 的比较

- Integers and floats
整数和浮点数

- Time and date objects
时间相关的对象

The term scalar means one-dimensional. Here, it refers to objects that represent single values, as opposed to collection or container objects that hold multiple values. There are some shades of gray: strings, for example, can be viewed as collections of characters in addition to being single units of text. Scalar is to some extent in the eye of the beholder. Still, as a good first approximation, you can look at the classes discussed in this chapter as classes of one-dimensional, bite-sized objects, in contrast to the collection objects that will be the focus of the next chapter.
scalar 纯量的意思是单一维度。 这里指那些只代表单个值的对象，与那些内部存有多个对象的collection和container相对。 这里有些模糊地带：比如 string 能被视作多个字符的集合。 你可以近似地将这一章中提到的class当做 一维的， 比特尺度上的对象。

The built-in objects we’ll look at in this chapter include the following:

- Strings, which are Ruby’s standard way of handling textual material of any length string是ruby处理文字信息的默认类型

- Symbols, which are (among other things) another way of representing text in Ruby symbol 是另一种代表文本的类型

- Integers 整数

- Floating-point numbers 浮点数

- Time, Date, and DateTime objects
时间，日期，日期时间对象

All of these otherwise rather disparate objects are scalar—they’re one-dimensional, noncontainer objects with no further objects lurking inside them the way arrays have. This isn’t to say scalars aren’t complex and rich in their semantics; as you’ll see, they are.

这些不同的对象都是纯量-他们是一维的，不具内含性的。但这并不代表纯量对象不具有语义上的复杂性和丰富性。

**Working with strings**

Strings and symbols are deeply different from each other, but they’re similar enough in their shared capacity to represent text that they merit being discussed in the same chapter.

string 和 symbol 都可以用来代表 文本内容 但是从深处来说他们是很不同的东西

对 string 来说

单引号/双引号

在常规用途中是一样的，但是在一些情况下则不同，主要的一个区别是 ruby 的 interpolation 不能在 单引号中起作用

```ruby
2.5.0 :001 > puts "The result is #{1+1}"
The result is 2
 => nil
2.5.0 :002 > puts 'The result is #{1+1}'
The result is #{1+1}
 => nil
2.5.0 :003 >
```

想要在string内部使用引号，要使用 backslash `\'` or `\"` 溢出

```ruby
2.5.0 :006 > puts "Escaped interpolation: \"#{2+2}\"."
Escaped interpolation: "4".
 => nil
2.5.0 :007 >
```

Single- and double-quoted strings also behave differently with respect to the need to escape certain characters. The following statements document and demonstrate the differences. Look closely at which are single-quoted and which are double-quoted, and at how the backslash is used:

单双引号在溢出规则上也有不同。

```ruby
2.5.0 :009 > puts "Backslashes (\\) have to be escaped in double quotes."
Backslashes (\) have to be escaped in double quotes.
 => nil
2.5.0 :010 > puts 'You can just type \ once in a single quoted string.'
You can just type \ once in a single quoted string.
 => nil
2.5.0 :011 > puts "But whichever type of quotation symbol, such as \"."
But whichever type of quotation symbol, such as ".
 => nil
2.5.0 :012 > puts 'That applies to \' in single-quoted strings too.'
That applies to ' in single-quoted strings too.
 => nil
2.5.0 :013 > puts 'Backslash-n just looks like \n between single quotes.'
Backslash-n just looks like \n between single quotes.
 => nil
2.5.0 :014 > puts "But it means newline/nin a double-quoted string."
But it means newline/nin a double-quoted string.
 => nil
2.5.0 :015 > puts "But it means newline\nin a double-quoted string."
But it means newline
in a double-quoted string.
 => nil
2.5.0 :017 > puts 'Same with \t, which come out as \t with single quotes...'
Same with \t, which come out as \t with single quotes...
 => nil
2.5.0 :018 > puts "...but inwerts a tab character:\tinside double quotes."
...but inwerts a tab character:	inside double quotes.
 => nil
2.5.0 :019 > puts "You can escape the backslash to get \\n and \\t with double quotes."
You can escape the backslash to get \n and \t with double quotes.
 => nil
2.5.0 :020 >
```

**Other quoting mechanisms**


The alternate quoting mechanisms take the form %char{text}, where char is one of several special characters and the curly braces stand in for a delimiter of your choosing.

另一种产生 string 的syntax 是使用 %x{字串内容} , x 规定生成规则

%q 和 %Q, % 从生产内容上看都是生成双引号 string

但是 %q 内部行为和单引号相同，不能使用 interpolation

https://stackoverflow.com/questions/19782799/difference-between-q-q-in-ruby-string-delimiters

```ruby
2.5.0 :029 >
2.5.0 :030 > %Q{Hello}
 => "Hello"
2.5.0 :031 > %q{Hello}
 => "Hello"
2.5.0 :032 > %Q{1 + 1 equals: #{1+1}}
 => "1 + 1 equals: 2"
2.5.0 :033 > %q{1 + 1 equals: #{1+1}}
 => "1 + 1 equals: \#{1+1}"
2.5.0 :034 > %{1 + 1 equals: #{1+1}}
 => "1 + 1 equals: 2"
2.5.0 :035 >
```

这是一种宽松的句法，任何"可对应"的符号包裹都可以使用

甚至用两个前后对应的 冒号

```ruby
2.5.0 :041 > %=hello=
 => "hello"
2.5.0 :042 > %{hello}
 => "hello"
2.5.0 :043 > %?hello?
 => "hello"
2.5.0 :044 >
```

在内部内容不含有空格的情况下，两边使用空格是可以的，但最好不要这么做，空格本身可以是string内容中的一部分

```ruby
2.5.0 :004 > % What about this
Traceback (most recent call last):
        1: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
SyntaxError ((irb):4: syntax error, unexpected tIDENTIFIER, expecting end-of-input
% What about this
       ^~~~~)
2.5.0 :005 >
```

如果要在内容中包含与句法相同的符号 使用 backslash 溢出符号

而且还要考虑到溢出符号使用规则

```ruby
2.5.0 :008 > %q{Same delimiter } in single quotes.}
Traceback (most recent call last):
        1: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
SyntaxError ((irb):8: syntax error, unexpected keyword_in, expecting end-of-input
%q{Same delimiter } in single quotes.}
                    ^~)
2.5.0 :009 > %q{Same delimiter \} in single quotes.}
2.5.0 :010'> ^C
```

```ruby
2.5.0 :002 > %Q{Same delimiter \} in single quotes.}
 => "Same delimiter } in single quotes."
```
-

EOM 是用来处理多行string 的工具
https://stackoverflow.com/questions/10561177/what-does-mean-in-ruby



In computing, a here
document (here-document, here-text, heredoc, hereis, here-string or here-script) is a file literal or input streamliteral: it is a section of a source code file that is treated as if it were a separate file. The term is also used for a form of multiline string literals that use similar syntax, preserving line breaks and other whitespace (including indentation) in the text.

here document (here-document, here-text, heredoc, hereis, here-string or here-script) 的作用类似一个文本模拟器，把当前的输入界面模拟为一个真实文本，你所键入的文字，符号，空格等，都会被保留下来

https://en.wikipedia.org/wiki/Here_document

The expression <<EOM means the text that follows, up to but not including the next occurrence of "EOM." The delimiter can be any string; EOM (end of message) is a common choice. It has to be flush-left, and it has to be the only thing on the line where it occurs. You can switch off the flush-left requirement by putting a hyphen before the << operator:

摘录来自: David A. Black. "The Well-Grounded Rubyist, Second Edition"。 iBooks.
`<<EOM` / `EOM` 之间的内容都会被纳入 content ，但是二者必须左对齐

```ruby
2.5.0 :006 > text = <<EOM
2.5.0 :007"> This is the first line.
2.5.0 :008"> Then second line.
2.5.0 :009"> Done!
2.5.0 :010"> EOM
 => "This is the first line.\nThen second line.\nDone!\n"
2.5.0 :011 >
2.5.0 :012 > text = <<EOM
2.5.0 :013"> This is the first line.
2.5.0 :014">   EOM
2.5.0 :015"> EOM
 => "This is the first line.\n  EOM\n"
2.5.0 :016 >
```

使用 EOM 作为界标不是必须的只要是 `<<` 加对应字符都可以

```ruby
2.5.0 :017 >
2.5.0 :018 > text = <<TEXT
2.5.0 :019"> Delimiter can be any string
2.5.0 :020"> TEXT
 => "Delimiter can be any string\n"
2.5.0 :021 >
```

在 `<<` 后加上短破折号， delimiter 就不用必须左对齐

```ruby
2.5.0 :022 > text = <<-EOM
2.5.0 :023"> This is the first line.
2.5.0 :024">     EOM
 => "This is the first line.\n"
2.5.0 :025 >
```

By default, here-docs are read in as double-quoted strings. Thus they can include string interpolation and use of escape characters like \n and \t. If you want a single-quoted here-doc, put the closing delimiter in single quotes when you start the document. To make the difference clearer, this example includes a puts of the here-doc:

默认情况下，here docs 生成双引号string。 这样他也会遵循双引号的溢出规则，内部也可以使用 interpolation

如果想让这个对象以单引号方式处理，使用单引号包裹 `EOM`

```ruby
2.5.0 :002 > text = <<EOM
2.5.0 :003"> 1 + 1 equals: #{1+1}.
2.5.0 :004"> EOM
 => "1 + 1 equals: 2.\n"
2.5.0 :005 >
2.5.0 :006 > text = <<EOM
2.5.0 :007"> 1 + 1 equals:\n #{1+1}.
2.5.0 :008"> EOM
 => "1 + 1 equals:\n 2.\n"
2.5.0 :009 >
2.5.0 :010 > text = <<'EOM'
2.5.0 :011'> 1 + 1 equals: #{1+1}.
2.5.0 :012'> EOM
 => "1 + 1 equals: \#{1+1}.\n"
2.5.0 :013 >
```

不管内容如何变化，实际上 here doc 生成的整个字串对象，实际是一个 string 对象

```ruby
2.5.0 :014 > text.class
 => String
```

The <<EOM (or equivalent) doesn’t have to be the last thing on its line. Wherever it occurs, it serves as a placeholder for the upcoming here-doc. Here’s one that gets converted to an integer and multiplied by 10:
对here doc 使用to_i 和对一个String对象使用to_i 是一样的

```ruby
2.5.0 :017 > a = <<EOM.to_i * 10
2.5.0 :018"> 5
2.5.0 :019"> EOM
 => 50
2.5.0 :020 > puts a
50
 => nil
2.5.0 :021 >
```

You can even use a here-doc in a literal object constructor. Here’s an example where a string gets put into an array, creating the string as a here-doc:

甚至可以在构建对象的过程中使用 here doc

```ruby
2.5.0 :024 > array = [1,2,3,<<EOM,4]
2.5.0 :025"> This is here doc object.
2.5.0 :026"> EOM
 => [1, 2, 3, "This is here doc object.\n", 4]
2.5.0 :027 > p array
[1, 2, 3, "This is here doc object.\n", 4]
 => [1, 2, 3, "This is here doc object.\n", 4]
2.5.0 :028 >
```

And you can use the <<EOM notation as a method argument; the argument becomes the here-doc that follows the line on which the method call occurs. This can be useful if you want to avoid cramming too much text into your argument list:

还可以把 here doc 对象用在 arguments list 中

```ruby
2.5.0 :029 > def output(a,b,c)
2.5.0 :030?>   puts a,b,c
2.5.0 :031?> end
 => :output
2.5.0 :032 > output("Hello", "World", <<EOM)
2.5.0 :033"> if I had a very very very very long string argument to pass into.
2.5.0 :034"> EOM
Hello
World
if I had a very very very very long string argument to pass into.
 => nil
2.5.0 :035 >
```
**Basic string manipulation**

Basic in this context means manipulating the object at the lowest levels: retrieving and setting substrings, and combining strings with each other. From Ruby’s perspective, these techniques aren’t any more basic than those that come later in our survey of strings; but conceptually, they’re closer to the string metal, so to speak.

Basic 在这个背景下的意思是在基础层面对string对象进行操作： 检索和设置substring, 以及将string组合起来。 从ruby的视角看，这些技术没有之后我们会提到的那么基础，但是概念上他们是比较接近的。

string 的索引规则和 array 一样 从0开始，-1 是最后一个

```ruby
2.5.0 :038 > str = "I am a string."
 => "I am a string."
2.5.0 :039 > str[0]
 => "I"
2.5.0 :040 > str[-1]
 => "."
2.5.0 :041 > str[0,3]
 => "I a"
2.5.0 :042 >
```

空格也是 string 内容构成的一部分

```ruby
2.5.0 :043 > str[4]
 => " "
2.5.0 :044 >
```

string 后的方括号中 给两个参数 代表
从第一个index 开始后的总共几个字符
string[1..4] 代表从 index1开始的那个字符起，后面的3个字符（总共加起来是4个）

如果给出 arrange 则拿到的是 range 范围内的字符

```ruby
2.5.0 :045 > str[0..4]
 => "I am "
2.5.0 :046 > str[0...4]
 => "I am"
2.5.0 :047 > str[0,4]
 => "I am"
2.5.0 :048 >
```

但是要注意 range 的逻辑必须是 从左至右 的如果方向反了，则拿到空字符

```ruby
2.5.0 :050 > str[-2..2] # syntactic error
 => ""
2.5.0 :051 > str[-2,2] # from [-2]， get 2 char
 => "g."
```

方括号中传入string也可以作为 文本搜索器使用

```ruby
2.5.0 :054 > str["a string"]
 => "a string"
2.5.0 :055 > str["a piece"]
 => nil
2.5.0 :056 >
```

也可以放入 regular expression

```ruby
2.5.0 :060 > str[/\sstring/]
 => " string"
```

slice 和 slice! 用来切下 string的部分内容

```ruby
2.5.0 :065 > str.slice("I am")
 => "I am"
2.5.0 :066 > str
 => "I am a string."
2.5.0 :067 > str.slice!("I am")
 => "I am"
2.5.0 :068 > str
 => " a string."
2.5.0 :069 >
```
使用 `[]=` 方法可以替换掉指定内容

这个方法中 `[]` 的作用仍然是匹配 指定内容，所以可以适用上面提到的用法

```ruby
2.5.0 :077 > str = "I am a string."
 => "I am a string."
2.5.0 :078 >
2.5.0 :079 > str["."] = " technically."
 => " technically."
2.5.0 :080 > str
 => "I am a string technically."
2.5.0 :081 >
```

也可以使用 integer 和 regular expression 来匹配替换

append `<<` 方法在 字串的末尾加上 给出内容

```ruby
2.5.0 :086 > s = "Hello world"
 => "Hello world"
2.5.0 :087 > s << " again"
 => "Hello world again"
2.5.0 :088 > s
 => "Hello world again"
2.5.0 :089 > s + "!"
 => "Hello world again!"
2.5.0 :090 > s
 => "Hello world again"
2.5.0 :091 >
```

字串叠加也可以使用 interpolation

但是不要让代码太夸张

在 interpolation 中可以写任何 ruby 代码

```ruby
2.5.0 :002 > "My name is: #{class Person
2.5.0 :003?>   attr_accessor :name
2.5.0 :004?>   end
2.5.0 :005 > me = Person.new
2.5.0 :006 > me.name = 'Caven xu'
2.5.0 :007 > me.name
2.5.0 :008 > }."
 => "My name is: Caven xu."
2.5.0 :009 >
```

There’s a much nicer way to accomplish something similar. Ruby interpolates by calling to_s on the object to which the interpolation code evaluates.

ruby 的 interpolation 会自动对return的 message 使用 to_s

所以可以可以通过改写一个 class 中的 to_s 来自定义输出内容

```ruby
2.5.0 :001 > class Person
2.5.0 :002?>   attr_accessor :name, :age
2.5.0 :003?>   end
 => nil
2.5.0 :004 > p1 = Person.new
 => #<Person:0x00007fe948082d00>
2.5.0 :005 > p1.name, p1.age = "Caven xu", 18
 => ["Caven xu", 18]
2.5.0 :006 > "p1: #{p1}"
 => "p1: #<Person:0x00007fe948082d00>"
2.5.0 :007 >
2.5.0 :008 > class Person
2.5.0 :009?>   def to_s
2.5.0 :010?>     name + " is " + age.to_s + " years old."
2.5.0 :011?>   end
2.5.0 :012?> end
 => :to_s
2.5.0 :013 > "p1: #{p1}"
 => "p1: Caven xu is 18 years old."
2.5.0 :014 >
```

Using the to_s hook is a useful way to control your objects’ behavior in interpolated strings.
to_s 这个callback 可以方便的控制你的对象在 interpolated 中的输出

**Querying strings**

include?() 用来判断字串中是否包含给出内容

start_with?() 用来判断字串中是否以给出内容起头

end_with?() 同上相反

```ruby
2.5.0 :020 >
2.5.0 :021 > str = "Ruby is a cool language."
 => "Ruby is a cool language."
2.5.0 :022 > str.include?(" a")
 => true
2.5.0 :023 > str.start_with?("ruby")
 => false
2.5.0 :024 > str.end_with?("ge.")
 => true
2.5.0 :025 >
```

empty?() 用来判断一个字串内容是否为空

注意 空格 也可以是内容的一部分

```ruby
2.5.0 :028 > "".empty?
 => true
2.5.0 :029 > " ".empty?
 => false
2.5.0 :030 >
```

注意 blank? 是 Rails 的内容，不是ruby 本身的

```ruby
2.5.0 :032 > "".blank?
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):32
NoMethodError (undefined method `blank?' for "":String)
2.5.0 :033 >
```

size 返回字串长度

count() 则有很多种用法

可以 count 单个字母的出现次数

可以 count 大写/小写 字母范围内的字母的数量

```ruby
2.5.0 :045 > str
 => "Ruby is a cool language."
2.5.0 :046 > str.size
 => 24
2.5.0 :047 > str.count('a')
 => 3
2.5.0 :048 > str.count('a-u')
 => 17
2.5.0 :049 > str.count('R-Z')
 => 1
2.5.0 :050 > str.count('X-Z')
 => 0
2.5.0 :051 >
```

—

输入多个字母时，计算的并不是 字母组合 的出现次数，而是给出的这些单独字母的出现次数

```ruby
2.5.0 :054 > str = "What bit of advice would you give people?"
 => "What bit of advice would you give people?"
2.5.0 :055 > str.count("wi")
 => 4
2.5.0 :056 > str.count("wh")
 => 2
2.5.0 :057 > str.count("a-z")
 => 32
2.5.0 :058 > str.count("^a-z")
 => 9
2.5.0 :059 > str.size
 => 41
2.5.0 :060 > str.count("a-zA-Z")
 => 33
2.5.0 :061 >
```

"wh" 的意思不是指 "wh" 这两个连续字母出现次数，而是指 "w" 和 "h" 总共出现了多少次。

使用 否定 非 符号 ^ 可以输出相反的结果

记住 空格 也是内容的一部分，计数的时候也要算入。

ar-z 计算所有 字母a 加  r-z 所有小写字母的数量

("ad-z", "^o")  计算所有字母a 加上 d-z 所有小写字母的数量， 然后排除字母 o 的数量

("^b-zA-Z") 除了 b-z和A-Z 的其他字符数量（包括空格和标点）

```ruby
2.5.0 :065 > str.count("ad-z")
 => 30
2.5.0 :066 > str.count("ad-z", "^o")
 => 26
2.5.0 :067 > str.count("^b-zA-Z")
 => 10
2.5.0 :068 >
```

```ruby
=> "What bit of advice would you give people?"
2.5.0 :072 > str.index("W")
=> 0
2.5.0 :073 > str.index("e")
=> 17
2.5.0 :074 > str.rindex("e")
=> 39
2.5.0 :075 > str.index("t")
=> 3
2.5.0 :076 > str.rindex("t")
```


.index() 计算给出字母的首次出现的 index

.rindex() 计算给出字母最后一次出现的位置的index

从上面的规则可以推出，如果某个 字母 只在一串字符中出现一次 那么两个 methods 的返回结果是一样的

```ruby
2.5.0 :079 > str = "Single appearance."
 => "Single appearance."
2.5.0 :080 > str.index("l")
 => 4
2.5.0 :081 > str.rindex("l")
 => 4
2.5.0 :082 >
```

`.ord` 查看单个字母的 叙述编码 ordinal code

反过来查找某个 ordinal code 对应的字母使用 `.chr` （character）

```ruby
2.5.0 :085 > "a".ord
 => 97
2.5.0 :086 > "b".ord
 => 98
2.5.0 :087 > "abc".ord
 => 97
2.5.0 :088 > 97.chr
 => "a"
2.5.0 :089 > 98.chr
 => "b"
2.5.0 :090 >
```

**string comparing and ordering**

`<=>` 符号用来比较两个 对象

如果结果是大于 返回 1

小于 返回 -1

相等返回 0

The String class mixes in the Comparable module and defines a <=> method. Strings are therefore good to go when it comes to comparisons based on character code (ASCII or otherwise) order:

class String 是 include 了 Comparable 这个module的，也定义了 `<=>` 方法。 string 对象之间的比较实际是在比较 ordernal code

```ruby
2.5.0 :090 > "a" <=> "b"
 => -1
2.5.0 :091 > "a" > "b"
 => false
2.5.0 :092 > ".".ord
 => 46
2.5.0 :093 > ",".ord
 => 44
2.5.0 :094 > "." > ","
 => true
2.5.0 :095 >
```

Remember that the spaceship method/operator returns -1 if the right object is greater, 1 if the left object is greater, and 0 if the two objects are equal. In the first case in the previous sequence, it returns -1 because the string "b" is greater than the string "a". But "a" is greater than "A", because the order is done by character value and the character values for "a" and "A" are 97 and 65, respectively, in Ruby’s default encoding of UTF-8. Similarly, the string "." is greater than "," because the value for a period is 46 and that for a comma is 44. (See section 8.1.7 for more on encoding.)

`<=>` 方法基于左右两边对象的'大小' 返回 -1, 0, 1 。 在ruby默认的 UTF-8 字符集中， "." 大于 ","。

比较 integer 时 则比较的是他们的大小

```ruby
2.5.0 :103 > 100 <=> 200
 => -1
2.5.0 :104 > 100 <=> 100
 => 0
2.5.0 :105 > 200 <=> 100
 => 1
2.5.0 :106 >
```

Comparing two strings for equality

关于两个对象是否“相等”的比较 ruby 有三个 methods

==

eql?()

equal?()


== 和 eql? 比较的是 content

而 equal? 则比较给出的两个对象是否是 相同的 object

```ruby
2.5.0 :108 > x = "string"
 => "string"
2.5.0 :109 > y = "string"
 => "string"
2.5.0 :110 > x == y
 => true
2.5.0 :111 > x.eql?(y)
 => true
2.5.0 :112 > x.equal?(y)
 => false
2.5.0 :113 >
```

string transformation

string 在形式上的变化有三个类型：

case 大小写

formatting 格式（排版）

content 内容变化

-

case transformations

upcase 大写

downcase 小写

swapcase 是将大小写颠倒

capitalize 首字母大写

```ruby
2.5.0 :115 > "Hello World".swapcase
 => "hELLO wORLD"
2.5.0 :116 > "one two three".capitalize
 => "One two three"
2.5.0 :117 >
```

formatting transformations

严格的来说 formatting transformation 属于 content transformation 的一部分，但是它又没有改变原来存在的内容，只是增加内容以提高string呈现的形式

```ruby
2.5.0 :120 > str = "I am a string."
 => "I am a string."
2.5.0 :121 > str.rjust(25)
 => "           I am a string."
2.5.0 :122 > str.ljust(25)
 => "I am a string.           "
2.5.0 :123 > str.rjust(25,"_")
 => "___________I am a string."
2.5.0 :124 > str.ljust(25,"_")
 => "I am a string.___________"
2.5.0 :125 >
```

rjust() 和 ljust() 用来给左对齐或者右对齐字串

接受两个参数，第一个规定字串的左边或右边流出多少个空格位置, 第二个参数（可选）规定流出的空位用什么来填充

center() 的作用类似

```ruby
2.5.0 :126 > str.center(30,"_")
 => "________I am a string.________"
2.5.0 :127 > str.center(31,"_")
 => "________I am a string._________"
2.5.0 :128 >
```

奇数个空位多的1个字符放在右边

strip 和 rstrip 以及 lstrip

用来剔除 string 指定位置的 空格

```ruby
2.5.0 :010 > str.center(30)
 => "        I am a string.        "
2.5.0 :011 > str
 => "I am a string."
2.5.0 :012 >
2.5.0 :013 > new_str = str.center(30)
 => "        I am a string.        "
2.5.0 :014 > new_str.rstrip
 => "        I am a string."
2.5.0 :015 > new_str.lstrip
 => "I am a string.        "
2.5.0 :016 > new_str.strip
 => "I am a string."
2.5.0 :017 >
```

center 方法返回的值是一个 新的string对象，所以要把 center 之后新string赋值给一个变数

-

content transformations

chop 无条件吃掉 string 末尾一个字符

chomp默认情况下 只吃string 末尾的 \n 换行符号, 如果给出参数，则从末尾吃掉给出的字符。

```ruby
2.5.0 :025 > str
 => "I am a string.\n"
2.5.0 :026 > str.chop!
 => "I am a string."
2.5.0 :027 > str.chop!
 => "I am a string"
2.5.0 :028 > str.chop!
 => "I am a strin"
2.5.0 :029 >
2.5.0 :030 > str = "I am a string.\n"
 => "I am a string.\n"
2.5.0 :031 > str.chomp
 => "I am a string."
2.5.0 :032 > str.chomp
 => "I am a string."
2.5.0 :033 > str.chomp
 => "I am a string."
2.5.0 :034 >
```

如果chomp后跟一个参数，可以指定吃掉末尾的哪几个字符，如果给出的参数与字串末尾不符合，那么 chomp 不做任何动作

```ruby
2.5.0 :037 > str = "I am a string.\n"
 => "I am a string.\n"
2.5.0 :038 > str.chomp!("string.\n")
 => "I am a "
2.5.0 :039 >
2.5.0 :040 > str = "I am a string.\n"
 => "I am a string.\n"
2.5.0 :041 > str.chomp!("ing")
 => nil
2.5.0 :042 > str
 => "I am a string.\n"
2.5.0 :043 >
```

clear 可以清除掉 string 的 content

replace 替换内容

但两个 methods 都没有改变 string 的 object_id

-

delete 用来删掉指定内容，可以给出string，也可以给出 正则表达式，接收多个参数, 类似string的 count 方法

```ruby
2.5.0 :049 > str = "I am a string.\n"
 => "I am a string.\n"
2.5.0 :050 > str.delete("^A-Z")
 => "I"
2.5.0 :051 > str.delete("a-z", "^g")
 => "I   g.\n"
2.5.0 :052 >
```

-

crypt 用来给 字串内容加密

Another specialized string transformation is crypt, which performs a Data Encryption Standard (DES) encryption on the string, similar to the Unix crypt(3) library function. The single argument to crypt is a two-character salt string:
`crypt`方法会以某个加密标准对string进行加密。

```ruby
= String.crypt

(from ruby site)
------------------------------------------------------------------------------
  str.crypt(salt_str)   -> new_str

------------------------------------------------------------------------------

Applies a one-way cryptographic hash to str by invoking the standard
library function crypt(3) with the given salt string.  While the format and
the result are system and implementation dependent, using a salt matching the
regular expression \A[a-zA-Z0-9./]{2} should be valid and safe on any
platform, in which only the first two characters are significant.

This method is for use in system specific scripts, so if you want a
cross-platform hash function consider using Digest or OpenSSL instead.


(END)
```

```ruby
>> "David A. Black".crypt("34")
=> "347OEY.7YRmio"
```

Make sure you read up on the robustness of any encryption techniques you use, including crypt.
确保你清楚你所使用的加密标准或方法。

```ruby
2.5.0 :057 > "David".crypt
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):57
        1: from (irb):57:in `crypt'
ArgumentError (wrong number of arguments (given 0, expected 1))
2.5.0 :058 > "David".crypt("88")
 => "88zx7b3xzhSNw"
2.5.0 :059 > "David".crypt("12")
 => "12tLhgGrr31EE"
 2.5.0 :060 > "David".crypt("ox")
  => "oxPPKwEAETSdY"
 2.5.0 :061 >
```

`crypt` 要跟一个两位数的字串内容，这个内容会出现在返回的加密内容的开头

会生成一个加密的 副本

crypt 没有对应的bang! 版本

`succ` 方法(和`next`同义)

这个方法存在于多个class中

![](https://ws2.sinaimg.cn/large/006tKfTcgy1fo280er9oej30b0089jrp.jpg)

The last transformation technique we’ll look at is string incrementation. You can get the next-highest string with the succ method (also available under the name next). The ordering of strings is engineered to make sense, even at the expense of strict character-code order: "a" comes after "`" (the backtick character) as it does in ASCII, but after "z" comes "aa", not "{". Incrementation continues, odometer-style, throughout the alphabet:

get the next-hightest string 的意思没能理解

```ruby
= String.succ

(from ruby site)
------------------------------------------------------------------------------
  str.succ   -> new_str

------------------------------------------------------------------------------

Returns the successor to str. The successor is calculated by
incrementing characters starting from the rightmost alphanumeric (or the
rightmost character if there are no alphanumerics) in the string. Incrementing
a digit always results in another digit, and incrementing a letter results in
another letter of the same case. Incrementing nonalphanumerics uses the
underlying character set's collating sequence.

If the increment generates a ``carry,'' the character to the left of it is
incremented. This process repeats until there is no carry, adding an
additional character if necessary.

  "abcd".succ        #=> "abce"
  "THX1138".succ     #=> "THX1139"
  "<<koala>>".succ   #=> "<<koalb>>"
  "1999zzz".succ     #=> "2000aaa"
  "ZZZ9999".succ     #=> "AAAA0000"
  "***".succ         #=> "**+"

(END)
```

返回一个 successor 对象。 在string内容中包含数字或字母的时候，从最右边的字母数字开始增加。如果没有字母数字而是其他符号，就对最右边的一个符号做增加。

如果是数字就存在进位的情况

—

base:
（数字进位制中的）基数 A base is a system of counting and expressing numbers. The decimal system uses base 10, and the binary system uses base 2.

decimal 就是10进制

if you give it a positive integer argument in the range 2–36, the string you’re converting is interpreted as representing a number in the base corresponding to the argument.

如果对string内一个数字使用 to_i() 加参数（从2-36），会将给出的数值作为给定进制的数字，然后尝试以这进制转成10进制的数值，如果给出的数值在这个进制范围内不合法，那么返回 0.

比如 二进制 只有 1 和 0 两个数字，如果给出 "234".to_i(2) 会返回 0 ， 因为二进制的世界里不可能有 234 出现。

如果开头有连续的合法数字，后面不合法的会被忽略

```ruby
2.5.0 :002 > "234".to_i
 => 234
2.5.0 :003 > "234".to_i(2)
 => 0
2.5.0 :004 > "110100010".to_i(2)
 => 418
2.5.0 :005 > "1101000109876543".to_i(2)
 => 418
2.5.0 :006 >
```

如果参数是10 那返回的就是本身

后面的参数范围只能是 2-36

其中 8进制 和 16进制 的情况有专门的 methods

8进制是 `.oct`

16进制是 `.hex`

```ruby
= String.oct

(from ruby site)
------------------------------------------------------------------------------
  str.oct   -> integer

------------------------------------------------------------------------------

Treats leading characters of str as a string of octal digits (with an
optional sign) and returns the corresponding number.  Returns 0 if the
conversion fails.

  "123".oct       #=> 83
  "-377".oct      #=> -255
  "bad".oct       #=> 0
  "0377bad".oct   #=> 255

If str starts with 0, radix indicators are honored. See Kernel#Integer.

(END)
```

**String encoding**

The subject of character encoding is interesting but vast. Encodings are many, and there’s far from a global consensus on a single best one. Ruby 1.9 added a great deal of encoding intelligence and functionality to strings. The big change in Ruby 2 was the use of UTF-8, rather than US-ASCII, as the default encoding for Ruby scripts. Encoding in Ruby continues to be an area of ongoing discussion and development. We won’t explore it deeply here, but we’ll put it on our radar and look at some important encoding-related techniques.
字符编码的话题有趣但是很庞大。 编码有很多种，目前没有一个共识认为哪个是最好的。 ruby 1.9 引入了大量的关于 string 的编码内容。 ruby 2 的一个重要改变是使用了 UTF-8 编码， 而替代了原来的 US-ASCII，作为ruby的默认编码。ruby中编码相关内容还在不断的完善发展，这里我们不会太深入，只了解一些重要的方面。

使用  `puts __ENCODING__ `

可以查看当前的 编码模式

```ruby
2.5.0 :001 > __ENCODING__
 => #<Encoding:UTF-8>
2.5.0 :002 >
```

使用 `.encoding` 可以查看string对象的编码

使用 encode() 可以产生给定编码的字串副本

对应的有 bang! 版本的 encode!()

```ruby
2.5.0 :003 > str = "A piece of string."
 => "A piece of string."
2.5.0 :004 > str.encoding
 => #<Encoding:UTF-8>
2.5.0 :005 > str.encode!("US-ASCII")
 => "A piece of string."
2.5.0 :006 > str.encoding
 => #<Encoding:US-ASCII>
2.5.0 :007 >
```

To change the encoding of a source file, you need to use a magic comment at the top of the file. The magic comment takes the form

`# encoding: encoding`

where encoding is an identifier for an encoding. For example, to encode a source file in US-ASCII, you put this line at the top of the file:

如果想改变一个源文件的编码，使用`# encoding: encoding`在文件顶部

比如：

`# encoding: ASCII`

The encoding of a string is also affected by the presence of certain characters in a string and/or by the amending of the string with certain characters. You can represent arbitrary characters in a string using either the \x escape sequence, for a two-digit hexadecimal number representing a byte, or the \u escape sequence, which is followed by a UTF-8 code, and inserts the corresponding character.

The effect on the string’s encoding depends on the character. Given an encoding of US-ASCII, adding an escaped character in the range 0–127 (0x00-0x7F in hexadecimal) leaves the encoding unchanged. If the character is in the range 128–255 (0xA0-0xFF), the encoding switches to UTF-8. If you add a UTF-8 character in the range 0x0000–0x007F, the ASCII string’s encoding is unaffected. UTF-8 codes higher than 0x007F cause the string’s encoding to switch to UTF-8. Here’s an example:

一个字串中的某些内容的改变，也可能改变整个字串本身的编码。 你可以使用 \x(跟16进制的编码)或 \u(跟UTF-8编码)，嵌入一个string中。

对整个string的影响基于你所注入的内容的编码。如果向一个string中注入 编码号从0-127的字符，不会改变原string的编码。但如果注入的是编码号从 128-255 的字符，原string会最终变为 UTF-8 。如果你将编码是 0x0000–0x007F 范围内的 UTF-8 编码注入一个 ACSII 编码的字串，原string不会改变。 序数大于 0x007F 的UTF-8编码会将string变为 UTF-8 编码。

```ruby
2.5.0 :009 > s = "I love "
 => "I love "
2.5.0 :010 > s.encoding
 => #<Encoding:UTF-8>
2.5.0 :011 > s.encode!("US-ASCII")
 => "I love "
2.5.0 :012 > s.encoding
 => #<Encoding:US-ASCII>
2.5.0 :013 > s << " this: \u20AC."
 => "I love  this: €."
2.5.0 :014 > s.encoding
 => #<Encoding:UTF-8>
2.5.0 :015 >
```

**Symbols and their uses**

symbols 是 class Symbol 的 实例

```ruby
2.5.0 :002 > Symbol.new
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):2
NoMethodError (undefined method `new' for Symbol:Class)
2.5.0 :003 >
2.5.0 :004 > :computer
 => :computer
2.5.0 :005 > :computer.class
 => Symbol
2.5.0 :006 > "string".to_sym
 => :string
2.5.0 :007 >
```

symbol 的两个主要 特点是 不可变更性 和 唯一性

immutability

uniqueness

一旦一个 symbol 被创造出来，他就是本身 不可更改。而一个 string 可以更改内容而不变化 object_id

```ruby
2.5.0 :009 > sym = :abc
 => :abc
2.5.0 :010 > sym.object_id
 => 1200668
2.5.0 :011 > :abc.object_id
 => 1200668
2.5.0 :012 > "abc".to_sym.object_id
 => 1200668
2.5.0 :013 >
```

同内容的 symbol 也是同一个 对象，而不会像string 那样出现 相同 content 而不同 object_id 的情况

```ruby
2.5.0 :014 > "string".object_id
 => 70290369584900
2.5.0 :015 > "string".object_id
 => 70290357326320
2.5.0 :016 > "string".object_id
 => 70290356914740
2.5.0 :017 > :"string".object_id
 => 285788
2.5.0 :018 > :"string".object_id
 => 285788
2.5.0 :019 > :"string".object_id
 => 285788
2.5.0 :020 >
```

可以使用equal?() 方法来验证

```ruby
2.5.0 :020 > :"string".equal?(:string)
 => true
2.5.0 :021 >
```

symbol 具有不可更改性，一旦被创造出来，他本身就不能再变化

```ruby
2.5.0 :022 > :abc + :d
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):22
NoMethodError (undefined method `+' for :abc:Symbol)
2.5.0 :023 > :abc << :d
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):23
NoMethodError (undefined method `<<' for :abc:Symbol
Did you mean?  <)
2.5.0 :024 >
```

That’s not to say that there’s no symbol :abcd. There is, but it’s a completely different symbol from :abc. You can’t change :abc itself. Like an integer, a symbol can’t be changed. When you want to refer to 5, you don’t change the object 4 by adding 1 to it. You can add 1 to 4 by calling 4.+(1) (or 4 + 1), but you can’t cause the object 4 to be the object 5. Similarly, although you can use a symbol as a hint to Ruby for the generation of another symbol, you can’t alter a given symbol.
上面的例子并不是说不能有 `:bacd` 这个symbol 对象，而是说它和 `:abc` 是完全不一样的另一个对象，你不能通过改变 `:abc` 把他变为另一个 symbol 对象。就像一个 integer ， 你可以通过 4 + 1 （4.+(1)） 得到5这个结果，但你不能把 4 这个对象变成 5。


Because symbols are unique, there’s no point having a constructor for them; Ruby has no Symbol#new method. You can’t create a symbol any more than you can create a new integer. In both cases, you can only refer to them.

由于 symbol 具有唯一性，所以不存在`Symbol # new`这个method

-

symbol 与 variable 这类 identifier 的异同

In fact, one of the potential causes of confusion surrounding the Symbol class and symbol objects is the fact that symbol objects don’t represent anything other than themselves. In a sense, a variable name is more “symbolic” than a symbol.

一个微妙的差别是 symbol 不代表'自身以外'的其他东西，它只能代表它自己，但 variable 却可以代表很多东西

从这一点来说，一个变数更具有“象征性”

And a connection exists between symbol objects and symbolic identifiers. Internally, Ruby uses symbols to keep track of all the names it’s created for variables, methods, and constants. You can see a list of them, using the Symbol.all_symbols class method. Be warned; there are a lot of them! Here’s the tip of the iceberg:

这些具有象征性的识别符和 symbol 之间的联系是，只要被赋值或定义的识别符，包括变数，方法名称，常量，都会被 ruby 存入一个 有很多:symbol的列表

使用 `Symbol.all_symbols` 可以看到所有这些识别符，以symbol格式存在一个array中

```ruby
2.5.0 :026 > Symbol.all_symbols
 => [:!, :"\"", :"#", :"$", :%, :&, :"'", :"(", :")", :*, :+, :",", :-, :".", :/, :":", :";", :<, :"=", :>, :"?", :"@", :"[", :"\\", :"]", :^, :`, :"{", :|, ..... :proc, :lambda, :send, :__send__, :__attached__, :initialize ......]
```

每当新增了一个变数，method 或者 常量
这个列表都会将其收录

```ruby
2.5.0 :034 > Symbol.all_symbols.size
 => 3653
2.5.0 :035 > new_variable = "some new"
 => "some new"
2.5.0 :036 > def new_meth; end
 => :new_meth
2.5.0 :037 > Symbol.all_symbols.size
 => 3655
2.5.0 :038 >
```

但使用 incldue?() 来检查一个之前不存在的 identifier 时 将会 always 返回 true

因为在传这个参数的时候，事实上你就已经创造出了 对应的 symbol

每使用一次 include?() 都已经向列表中新增了这个symbol

可以随后查看列表中的 symbol 总数增量

```ruby
2.5.0 :037 > Symbol.all_symbols.size
 => 3655
2.5.0 :038 > :new_symbol
 => :new_symbol
2.5.0 :039 > Symbol.all_symbols.size
 => 3656
2.5.0 :040 > Symbol.all_symbols.include?(:unknown_sym)
 => true
2.5.0 :041 >
```

The symbol table is just that: a symbol table. It’s not an object table. If you use an identifier for more than one purpose—say, as a local variable and also as a method name—the corresponding symbol will still only appear once in the symbol table:

这个全是symbol的array，并不是一个装满object的表。但如果有同名的  variable 和 method 这个名称的 symbol 也只会出现一次

```ruby
2.5.0 :041 > Symbol.all_symbols.size
 => 3657
2.5.0 :042 > def made_up;end
 => :made_up
2.5.0 :043 > made_up = "made up"
 => "made up"
2.5.0 :044 > :made_up
 => :made_up
2.5.0 :045 > Symbol.all_symbols.size
 => 3658
2.5.0 :046 >
```

如果把一个 symbol 赋值给一个 variable 那么会一次新增两个 symbol 到列表中

```ruby
2.5.0 :045 > Symbol.all_symbols.size
 => 3658
2.5.0 :046 > double = :a_symbol
 => :a_symbol
2.5.0 :047 > Symbol.all_symbols.size
 => 3660
2.5.0 :048 >
```

-

ruby 运行过程中出现的任何 identifier 都会被增加到这个列表中。

由于 symbol 值代表其自身，没有更复杂的结构，所以他的优点是可以被快速的查找

Not only symbols matching variable and method names are put in the table; any symbol Ruby sees anywhere in the program is added. The fact that :my_symbol gets stored in the symbol table by virtue of your having used it means that the next time you use it, Ruby will be able to look it up quickly. And unlike a symbol that corresponds to an identifier to which you’ve assigned a more complex object, like a string or array, a symbol that you’re using purely as a symbol, like :my_symbol, doesn’t require any further lookup. It’s just itself: the symbol :my_symbol.

—

Symbols have a number of uses, but most appearances fall into one of two categories: method arguments and hash keys.

symbol 在 ruby 中最主要的两个用法是
1 作为 method 的 参数
2 作为 hash 的key

—

attr_* 系列参数就接受 symbol 作为参数

attr_accessor :name

attr_reader :age

send 这个method 也可以接受 symbol 作为参数

```ruby
2.5.0 :050 > "abc".upcase
 => "ABC"
2.5.0 :051 > "abc".send("upcase")
 => "ABC"
2.5.0 :052 > "abc".send(:upcase)
 => "ABC"
2.5.0 :053 >
```

多数情况下 接受 symbol 作为参数的 method 同样接受 string 版本的参数，但是使用 symbol 省去了将 string 转化为 :symbol 然后再去 list 中检索的步骤

At the same time, most methods that take symbols can also take strings. You can replace :upcase with "upcase" in the previous send example, and it will work. The difference is that by supplying :upcase, you’re saving Ruby the trouble of translating the string upcase to a symbol internally on its way to locating the method.

如果在定义一个方法时这个方法可以接受 string 和 symbol 那么最好写成两种都兼容的格式

When you’re writing a method that will take an argument that could conceivably be a string or a symbol, it’s often nice to allow both.

—

Ruby对于 hash 的 key ruby 没有作太多限制，但多数情况下都是 string 或者 symbol

Ruby puts no constraints on hash keys. You can use an array, a class, another hash, a string, or any object you like as a hash key. But in most cases you’re likely to use strings or symbols.

-

使用 symbol 作为 hash key 的理由有三个

1 symbol 对 ruby 来说速度更快，但在小数量数据的情况下不明显

2 symbol 视觉上更加干净，静止

3 可以用冒号在后的方式（语法） 输入键值对

-

之前提到过 :symbol 和其他 identifier 的异同，下面要提到 :symbol 和 string 的异同

ruby 的版更更新过程中，symbol 能做的变得越来越多，大部分都借鉴自 string 。但 symbol 的 immutable 和 uniqueness  特性是不变的。

Ruby 1.8.6

```ruby
>> Symbol.instance_methods(false).sort

=> ["===", "id2name", "inspect", "to_i", "to_int", "to_s", "to_sym"]
```

Ruby 2
````ruby
>> Symbol.instance_methods(false).sort

=> [:<=>, :==, :===, :=~, :[], :capitalize, :casecmp, :downcase, :empty?,
:encoding, :id2name, :inspect, :intern, :length, :match, :next, :size, :slice, :succ, :swapcase, :to_proc, :to_s, :to_sym, :upcase]
```

methods 越来越多，但其中没有 bang! 版本的, 因为 :symbol  不代表除自身以外的任何对象

任何改变都会是一个新的 symbol 而不是把现有的symbol 变成另一个 symbol

```ruby
2.5.0 :001 > x = :origin
 => :origin
2.5.0 :002 > x.object_id
 => 1200348
2.5.0 :003 > y = x.upcase
 => :ORIGIN
2.5.0 :004 > y
 => :ORIGIN
2.5.0 :005 > y.object_id
 => 70317527766680
2.5.0 :006 > z = y.downcase
 => :origin
2.5.0 :007 > z.equal?(x)
 => true
2.5.0 :008 >
```

:symbol 一旦改变就是存在了另一个新的 symbol

用索引index 取得 symbol 中的字符得到的是string格式的 字串

而不是一个”symbol 单位”

```ruby
2.5.0 :008 > x = :a_long_symbol
 => :a_long_symbol
2.5.0 :009 > x[3]
 => "o"
2.5.0 :010 > x[0,6]
 => "a_long"
2.5.0 :011 > x[2..6]
 => "long_"
2.5.0 :012 >
```

-

**Numeric objects**

数字类型的 对象

![](https://ws2.sinaimg.cn/large/006tNc79gy1fo336wg0mcj309j061mxj.jpg)

Numeric 是最高层级

下面分出了 Float 和 Integer

Integer 又分出了 Fixum 和 Bignum

但是 2.4以后的ruby 没有了 Fixum 和 Bignum 这两个 class ，一同并入了 Integer

原本针对不同大小的整数的优化并没有随着 class 的消失而取消，而是仍然被保留下来，这部分工作是在 “背后” 进行的。

https://stackoverflow.com/questions/21372649/what-is-the-difference-between-integer-and-fixnum/21411269#21411269

注：2.5 的数字类型的class再次发生了变化

```ruby
caven@caven ⮀ ~ ⮀ ruby -v
ruby 2.5.0p0 (2017-12-25 revision 61468) [x86_64-darwin17]
caven@caven ⮀ ~ ⮀ irb
2.5.0 :001 > class Class
2.5.0 :002?>   def descendants
2.5.0 :003?>     ObjectSpace.each_object(Class).select { |k| k < self } << self
2.5.0 :004?>     end
2.5.0 :005?>   end
=> :descendants
2.5.0 :006 > Numeric.ancestors
=> [Numeric, Comparable, Object, Kernel, BasicObject]
2.5.0 :007 > Numeric.descendants
=> [Complex, Rational, Float, Integer, Numeric]
2.5.0 :008 >
```

从最新的 ruby doc 中可以看到 Complex, Rational, Float, Integer 这4个classes的 parent 都是 Numeric

http://ruby-doc.org/core-2.5.0/Complex.html

http://ruby-doc.org/core-2.5.0/Rational.html

http://ruby-doc.org/core-2.5.0/Float.html

http://ruby-doc.org/core-2.5.0/Integer.html

-

Keep in mind that most of the arithmetic operators you see in Ruby are methods. They don’t look that way because of the operator-like syntactic sugar that Ruby gives them. But they are methods, and they can be called as methods:

数字类型的对象可以进行很多四则运算

使用常用的 + - * /  等符号

但要记住，这些符号其实都是 methods

只是 ruby 将他们写成了 符合人们平时使用习惯的版本

可以在自定义的class 中 override 这些符号，同时也就改变了 method 版本的功能

要注意在运算中如果全部都是整数，那结果也都是整数，不带小数点。带上小数的运算则总会返回带小数的结果。

```ruby
2.5.0 :010 > 10/3
 => 3
2.5.0 :011 > 10%3
 => 1
2.5.0 :012 > 10/3.00
 => 3.3333333333333335
2.5.0 :013 > 10%3.00
 => 1.0
2.5.0 :014 >
```

ruby 同样允许 非十进制的运算

比如

十六进制hexadecimal的整数运算 是在数字前加上前缀 0x

```ruby
2.5.0 :035 > 0x1
 => 1
2.5.0 :036 > 0x2
 => 2
2.5.0 :037 > 0x3
 => 3
2.5.0 :038 > 0x9
 => 9
2.5.0 :039 > 0x10
 => 16
2.5.0 :040 > 0x20
 => 32
2.5.0 :041 > 0x10 + 0x10
 => 32
2.5.0 :042 > 0x10 + 10
 => 26
2.5.0 :043 >
```

要注意只有加上前缀的数字才会以对应的进制对待，没有的仍然会被作为十进制对待

八进制octal 的整数运算则是在前面加上 0

string 中的 to_i 可以将 string 内容转换为对应进制的数值的十进制值

后面的参数只能 2-36 之前提到过

-

ruby中有三个对应的 class 来处理时间和日期

Date

Time

DateTime

-

使用 require “date” 可以得到 Date 和 DateTime 两个库的功能

require “time” 可以得到 Time 的库

如果想拿到全部的关于时间日期的功能则同时 require 二者

require 'date'

require 'time'

Here, the first line provides the Date and DateTime classes, and the second line enhances the Time class.

书中提到未来可能会将这部分功能合并到一个库

—

关于日期时间的操作主要涉及

how to instantiate data/time objects 如果和实例化时间/日期对象

how to query them 如何查询

how to convert them form one to another 如何转换格式

```ruby ``
2.5.0 :046 > require 'date'
 => true
2.5.0 :047 > Date.today
 => #<Date: 2018-02-03 ((2458153j,0s,0n),+0s,2299161j)>
2.5.0 :048 >  puts Date.today
2018-02-03
 => nil
2.5.0 :049 >
```

使用 Date.today 可以拿到 “今天这个对象” 但记得要先 拿到date 库

对这个 今天 使用puts 可以拿到 string 版本的格式，更加简化，只呈现主要信息

```ruby
2.5.0 :051 > Date.new(1999,12,28)
 => #<Date: 1999-12-28 ((2451541j,0s,0n),+0s,2299161j)>
2.5.0 :052 > Date.new(28,1999,12)
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):52
        1: from (irb):52:in `new'
ArgumentError (invalid date)
2.5.0 :053 > Date.new(28,12,1999)
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):53
        1: from (irb):53:in `new'
ArgumentError (invalid date)
2.5.0 :054 > Date.new(12,28,1999)
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):54
        1: from (irb):54:in `new'
ArgumentError (invalid date)
2.5.0 :055 >
```

使用 Date.new() 加参数的方式也可以生成 时间日期对象

如果 缺少月份 和 日 的参数，会默认为1

如果没有参数 则默认为-4712年1月1日

且这里的格式顺序必须是 年 月 日

```ruby
2.5.0 :056 > Date.new
 => #<Date: -4712-01-01 ((0j,0s,0n),+0s,2299161j)>
2.5.0 :057 > Date.new(1999)
 => #<Date: 1999-01-01 ((2451180j,0s,0n),+0s,2299161j)>
2.5.0 :058 > Date.new(12,28)
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):58
        1: from (irb):58:in `new'
ArgumentError (invalid date)
2.5.0 :059 >
```

另一种是 解析 `parse` 这个 method

他可以将给出的 符合表意的日期 转换为日期对象

```ruby
2.5.0 :060 > Date.parse("99/12/28")
 => #<Date: 1999-12-28 ((2451541j,0s,0n),+0s,2299161j)>
2.5.0 :061 > Date.parse("99 12 28")
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):61
        1: from (irb):61:in `parse'
ArgumentError (invalid date)
2.5.0 :062 > Date.parse("99-12-28")
 => #<Date: 1999-12-28 ((2451541j,0s,0n),+0s,2299161j)>
2.5.0 :063 > Date.parse("99 Dec 28th")
 => #<Date: 1999-12-28 ((2451541j,0s,0n),+0s,2299161j)>
2.5.0 :064 > Date.parse("991228")
 => #<Date: 1999-12-28 ((2451541j,0s,0n),+0s,2299161j)>
2.5.0 :065 >
```

注意： 如果是以两位数的方式给出年份，那么

大于等于69的年份会被解读为20世纪

小于69的会被解读为21世纪

```ruby
2.5.0 :067 > Date.parse('45-12-28')
 => #<Date: 2045-12-28 ((2468343j,0s,0n),+0s,2299161j)>
2.5.0 :068 > Date.parse('69-12-28')
 => #<Date: 1969-12-28 ((2440584j,0s,0n),+0s,2299161j)>
2.5.0 :069 >
```

实际上 ruby 可以转换很各种写法的日期，但使用时要注意 日 月 年 在转换中所处的位置

**Time objects**

使用 Time.new 可以生成当前时间点

```ruby
2.5.0 :075 > Time.new
 => 2018-02-03 13:54:03 +0800
2.5.0 :076 > Time.now
 => 2018-02-03 13:54:08 +0800
2.5.0 :077 > Time.at(100000000)
 => 1973-03-03 17:46:40 +0800
2.5.0 :078 > Time.local(2011,10,3,15,55,59)
 => 2011-10-03 15:55:59 +0800
2.5.0 :079 > Time.parse("March 22, 1985, 10:35 PM")
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):79
NoMethodError (undefined method `parse' for Time:Class)
2.5.0 :080 > require 'time'
 => true
2.5.0 :081 > Time.parse("March 22, 1985, 10:35 PM")
 => 1985-03-22 22:35:00 +0800
2.5.0 :082 >
```

![](https://ws2.sinaimg.cn/large/006tNc79gy1fo37y1uigoj30vr0gjgpz.jpg)

注意 Core 中有一个class 叫 Time， standard library 中还有一个 module 叫 Time

Time.at() 后面跟的参数的意思是， 基于GMT时区 1970 年 1月 1 日 00点 这个时间点，加上 多少秒的时间

```ruby
2.5.0 :084 > Time.at(5)
 => 1970-01-01 08:00:05 +0800
2.5.0 :085 >
```

这里之所以是 8 点是因为后面的 +0800

Time也有 parse method

-

DateTime 是 Date的subclass

但它的用法和 Date 有些不同

```ruby
2.5.0 :088 > Time.now
 => 2018-02-03 14:02:56 +0800
2.5.0 :089 > DateTime.now
 => #<DateTime: 2018-02-03T14:03:03+08:00 ((2458153j,21783s,956906000n),+28800s,2299161j)>
2.5.0 :090 > Date.now
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):90
NoMethodError (undefined method `now' for Date:Class
Did you mean?  new)
2.5.0 :091 >
2.5.0 :092 > puts DateTime.new
-4712-01-01T00:00:00+00:00
 => nil
2.5.0 :093 > puts Time.new
2018-02-03 14:03:29 +0800
 => nil
2.5.0 :094 >
```

Date/time query methods

Time 和 DateTime 对象可以拿到 从 年 到 秒 所有信息

Date 对象只能拿到 年 到 日

```ruby
2.5.0 :096 > dt = DateTime.now
 => #<DateTime: 2018-02-03T14:04:18+08:00 ((2458153j,21858s,896636000n),+28800s,2299161j)>
2.5.0 :097 > dt.year
 => 2018
2.5.0 :098 > dt.month
 => 2
2.5.0 :099 > dt.day
 => 3
2.5.0 :100 > dt.hour
 => 14
2.5.0 :101 > dt.sec
 => 18
2.5.0 :102 >
```

但要注意Time 对象拿 秒的方法是  sec 而不是 second

ruby 可以验证日期是星期几

```ruby
2.5.0 :102 > puts dt
2018-02-03T14:04:18+08:00
 => nil
2.5.0 :103 > dt.wday
 => 6
2.5.0 :104 > dt.monday?
 => false
2.5.0 :105 > dt.wednesday?
 => false
```

**Date/time formatting methods**

日期时间的格式化方法

All date/time objects have the `strftime` method, which allows you to format their fields in a flexible way using format strings, in the style of the Unix strftime(3) system library:

所有 关于时间的 对象都可以使用 strftime 方法来格式化自己

```ruby
2.5.0 :001 > dt = Time.now
 => 2018-02-03 14:09:27 +0800
2.5.0 :002 > dt.strftime("%Y %B %d")
 => "2018 February 03"
2.5.0 :003 > dt.strftime("%Y-%b-%d")
 => "2018-Feb-03"
2.5.0 :004 > dt.strftime("%Y-%m-%d")
 => "2018-02-03"
2.5.0 :005 >
```

使用百分号加字母来规定日期格式，中间的空格或者其他符号不影响结果 只影响格式

当然这种格式化输出可以精确到 秒

```ruby
2.5.0 :005 > dt.strftime("%Y-%m-%d %H时 %M分 %S秒")
 => "2018-02-03 14时 09分 27秒"
2.5.0 :006 >
```

百分号对应的 字母 含义：

![](https://ws3.sinaimg.cn/large/006tNc79gy1fo389s2vdmj30ef0c275z.jpg)

对于最后两个 %x 和 %c 要注意他们虽然方便，但是在不同的系统中可能出现 月和日 位置调换的情况，使用前考虑这个因素

```ruby
2.5.0 :006 > dt.strftime("%x")
 => "02/03/18"
2.5.0 :007 > dt.strftime("%c")
 => "Sat Feb  3 14:09:27 2018"
2.5.0 :008 >
```

In addition to the facilities provided by strftime, the Date and DateTime classes give you a handful of precooked output formats for specialized cases like RFC 2822 (email) compliance and the HTTP format specified in RFC 2616:

ruby 也提供了针对 email 标准格式 和 HTTP 标准格式的 预制时间规范方法

但要先require 'time'

```ruby
2.5.0 :010 > dt.rfc2822
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):10
NoMethodError (undefined method `rfc2822' for 2018-02-03 14:09:27 +0800:Time)
2.5.0 :011 > require 'date'
 => true
2.5.0 :012 > dt.rfc2822
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):12
NoMethodError (undefined method `rfc2822' for 2018-02-03 14:09:27 +0800:Time)
2.5.0 :013 > require 'time'
 => true
2.5.0 :014 > dt.rfc2822
 => "Sat, 03 Feb 2018 14:09:27 +0800"
2.5.0 :015 > dt.httpdate
 => "Sat, 03 Feb 2018 06:09:27 GMT"
2.5.0 :016 >
```

各个时间格式之间的转换

每个关于时间的对象 都可以 转换为另一种

如果转换中出现 信息缺失，比如 date 里没有关于 小时到秒的信息，那么缺少的信息为默认设为 0

```ruby
2.5.0 :018 > date = Date.today
 => #<Date: 2018-02-03 ((2458153j,0s,0n),+0s,2299161j)>
2.5.0 :019 > date.to_time
 => 2018-02-03 00:00:00 +0800
2.5.0 :020 > date.to_datetime
 => #<DateTime: 2018-02-03T00:00:00+00:00 ((2458153j,0s,0n),+0s,2299161j)>
2.5.0 :021 >
```

时间相关的对象 可以进行 四则运算

对于 Time

加 和 减 是以秒为单位进行的操作

对于 DateTime 加和减是以 天 为单位的操作

对于 DateTime 使用  >> 和 << 分别代表 前进 和 后退 多少个月份

```ruby
2.5.0 :023 > date = Date.today
 => #<Date: 2018-02-03 ((2458153j,0s,0n),+0s,2299161j)>
2.5.0 :024 > date + 1
 => #<Date: 2018-02-04 ((2458154j,0s,0n),+0s,2299161j)>
2.5.0 :025 > date >> 1
 => #<Date: 2018-03-03 ((2458181j,0s,0n),+0s,2299161j)>
2.5.0 :026 > date << 1
 => #<Date: 2018-01-03 ((2458122j,0s,0n),+0s,2299161j)>
2.5.0 :027 > time = Time.now
 => 2018-02-03 14:16:11 +0800
2.5.0 :028 > time + 1
 => 2018-02-03 14:16:12 +0800
2.5.0 :029 >
```

对于 Date

有 next next_year next_month() prev_day(), 等methods

```ruby
2.5.0 :034 > date = Date.new(2050,05,20)
 => #<Date: 2050-05-20 ((2469947j,0s,0n),+0s,2299161j)>
2.5.0 :035 > puts date.next
2050-05-21
 => nil
2.5.0 :036 > puts date.next_year
2051-05-20
 => nil
2.5.0 :037 > puts date.next_month
2050-06-20
 => nil
2.5.0 :038 > puts date.next_month(3)
2050-08-20
 => nil
2.5.0 :039 > puts date.prev_day
2050-05-19
 => nil
2.5.0 :040 > puts date.prev_day(10)
2050-05-10
 => nil
2.5.0 :041 >
```
Furthermore, date and date/time objects allow you to iterate over a range of them, using the upto and downto methods, each of which takes a time, date, or date/time object.

更进一步 日期时间相关的 objects 可以对两个时间点之间的  时间段 进行迭代操作

```ruby
2.5.0 :045 > puts date
2050-05-20
 => nil
2.5.0 :046 > hind_date = date + 7
 => #<Date: 2050-05-27 ((2469954j,0s,0n),+0s,2299161j)>
2.5.0 :047 > date.upto(hind_date) { |everyday| puts "#{everyday} is: #{everyday.strftime('%A')}" }
2050-05-20 is: Friday
2050-05-21 is: Saturday
2050-05-22 is: Sunday
2050-05-23 is: Monday
2050-05-24 is: Tuesday
2050-05-25 is: Wednesday
2050-05-26 is: Thursday
2050-05-27 is: Friday
 => #<Date: 2050-05-20 ((2469947j,0s,0n),+0s,2299161j)>
2.5.0 :048 >
```

日期是从当前点推向未来 使用 upto

推向过去则是 downto

-

## Summary

In this chapter you’ve seen

- String creation and manipulation
string对象的新建和操控

- The workings of symbols
symbol的工作

- Numerical objects, including floats and integers
数字类型的对象，包括整数和浮点数

- Date, time, and date/time objects and how to query and manipulate them
各类时间/日期对象，以及如何操纵他们

In short, we’ve covered the basics of the most common and important scalar objects in Ruby. Some of these topics involved consolidating points made earlier in the book; others were new in this chapter. At each point, we’ve examined a selection of important, common methods. We’ve also looked at how some of the scalar-object classes relate to each other. Strings and symbols both represent text, and although they’re different kinds of objects, conversions from one to the other are easy and common. Numbers and strings interact, too. Conversions aren’t automatic, as they are (for example) in Perl; but Ruby supplies conversion methods to go from string to numerical object and back, as well as ways to convert strings to integers in as many bases as 10 digits and the 26 letters of the English alphabet can accommodate.

简言之，我们涵盖了ruby中所有最重要的纯量对象的基本内容。 有些内容加深了对前面章节内容的理解，有些是新内容。在每一个环节我们都挑选了一些最常见最重要的methods。 我们也看到了某些纯量之间的关联。 string和symbol都可以代表文本，但他们又是不同类型的对象，而二者之间转化又是相对容易的。 当然这种转换不是自动的，就像在 Perl 语言中一样。ruby还提供了stirng和numeric之间的转换方法。

Time and date objects have a foot in both the string and numerical camps. You can perform calculations on them, such as adding n months to a given date, and you can also put them through their paces as strings, using techniques like the Time#strftime method in conjunction with output format specifiers.
time和date对象与string和numeric都有关联。你可以在时间/日期对象上进行加减操作，也可以 string formatting 他们， 使用 `Time#strftime`方法，配合格式化输出的语法。
