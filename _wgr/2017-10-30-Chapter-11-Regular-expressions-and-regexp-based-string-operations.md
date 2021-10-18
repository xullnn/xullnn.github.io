---
title:  "Rubyist-c11-Regular expressions and regexp based string operations"
categories: [Ruby/Rails ℗]
tags: [Ruby & Rails, Notes of Rubyist]
---

*注：这一系列文章是《The Well-Grounded Rubyist》的学习笔记。*



---

This chapter covers

- Regular expression syntax

- Pattern-matching operations

- The MatchData class

- Built-in methods based on pattern matching

In this chapter, we’ll explore Ruby’s facilities for pattern matching and text processing, centering around the use of regular expressions. A regular expression in Ruby serves the same purposes it does in other languages: it specifies a pattern of characters, a pattern that may or may not correctly predict (that is, match) a given string. Pattern-match operations are used for conditional branching (match/no match), pinpointing substrings (parts of a string that match parts of the pattern), and various text-filtering techniques.
这一章着眼于Ruby的模式匹配（parttern matching）和 文本处理(text processing)功能，这部分内容以正则表达式为核心展开。 在Ruby中regular expression的作用和在其他编程语言中相同：给出一个文本模式，然后去匹配字串。pattern match 操作可以用于分支流程控制（基于匹配结果），可以用于精确定位substring, 以及其他各种文本过滤技术。

Regular expressions in Ruby are objects. You send messages to a regular expression. Regular expressions add something to the Ruby landscape but, as objects, they also fit nicely into the landscape.
正则表达式在ruby中也是对象。 你送一个 message 给他。Regular expression增加了Ruby的版图，但作为object， 它又与原有版图十分契合。

We’ll start with an overview of regular expressions. From there, we’ll move on to the details of how to write them and, of course, how to use them. In the latter category, we’ll look at using regular expressions both in simple match operations and in methods where they play a role in a “larger process, such as filtering a collection or repeatedly scanning a string.
我们先会对 regular expression 有个概览。 接着会了解如何写rexp， 如何用rexp。在使用方面，会涉及两个层级，一个是简单的匹配操作，以及那些会重复处理大量文本的情况，比如从collection中过滤信息或重复扫描一个字串。

**What are regular expressions?**

Regular expressions appear in many programming languages, with minor differences among the incarnations. Their purpose is to specify character patterns that subsequently are determined to match (or not match) strings. Pattern matching, in turn, serves as the basis for operations like parsing log files, testing keyboard input for validity, and isolating substrings—operations, in other words, of frequent and considerable use to anyone who has to process strings and text.
正则表达式出现在很多编程语言中，区别并不大。他存在的主要目的是描述字符模式，用来匹配字符。 Pattern matching 另一方面，也可以作为解析日志文件的基础，可以验证键盘输入的有效性，也可以用来分隔字符串，换句话说，只要是处理文本的工作都可能会用到。

Regular expressions have a weird reputation. Using them is a powerful, concentrated technique; they burn through a large subset of text-processing problems like acid through a padlock. They’re also, in the view of many people (including people who understand them well), difficult to use, difficult to read, opaque, unmaintainable, and ultimately counterproductive.
正则表达式的名声富有争议。他是一种强大的工具，浓缩的技术； 他与数量巨大的文本处理问题相关。 同时他在许多人眼中是难以使用的，难以阅读的，不透明的，不可维护的，以及会降低效率的。

You have to judge for yourself. The one thing you should not do is shy away from learning at least the basics of how regular expressions work and how to use the Ruby methods that utilize them. Even if you decide you aren’t a “regular expression person,” you need a reading knowledge of them. And you’ll by no means be alone if you end up using them in your own programs more than you anticipated.
优劣需要你自己判断。 但你不能一点都不学习regular expression基础，以及在ruby中如何使用它。 即使你认为你不是一个'正则表达式'的人，你也需要学习。而且你会发现你将会在你的程式中用到他，比你预期地更频繁，就如其他人经历过的一样。

A number of Ruby built-in methods take regular expressions as arguments and perform selection or modification on one or more string objects. Regular expressions are used, for example, to scan a string for multiple occurrences of a pattern, to substitute a replacement string for a substring, and to split a string into multiple substrings based on a matching separator.
Ruby中许多内建的方法接受 rexp 作为参数，然后以此为基础进行选择和修改一个或多个string对象。 正则表达式可以用来扫描以某种模式重复出现的字串，可以用来替换string中的指定部分，或者基于特定的点将string分隔开。

If you’re familiar with regular expressions from Perl, sed, vi, Emacs, or any other source, you may want to skim or skip the expository material here and pick up in section 11.5, where we talk about Ruby methods that use regular expressions. But note that Ruby regular expressions aren’t identical to those in any other language. You’ll almost certainly be able to read them, but you may need to study the differences (such as whether parentheses are special by default or special when escaped) if you get into writing them.
如果你对 Perl, sef, vi, Emacs 或其他语言中的rexp熟悉，你可以直接跳过解释部分直接进入 section 11.5。那里我们会开始讨论 Ruby 中使用 rexp 的方法。 但要注意 Ruby 中的 rexp 和其他语言中的并不完全一样。 你需要注意其中的区别。


-

**Writing regular expression**

-

Patterns of the kind specified by regular expressions are most easily understood, initially, in plain language. Here are several examples of patterns expressed this way:
所谓的pattern模式，其实是很好理解的，下面用语言描述几种简单的模式

- The letter a, followed by a digit
字母 'a' 后面带任何一个 数字

- Any uppercase letter, followed by at least one lowercase letter
任何一个至少跟有一个小写字母的大写字母

- Three digits, followed by a hyphen, followed by four digits
三个数字开头，后面跟着一个连字号，后面跟着4位数字

A pattern can also include components and constraints related to positioning inside the string:
模式还可以包含组件以及规定在字串中的匹配位置

- The beginning of a line, followed by one or more whitespace characters
在一行开头的位置，有一个或多个空格

- The character . (period) at the end of a string
一个字串末尾处的句号 .

- An uppercase letter at the beginning of a word
单词开头的大写字母

Pattern components like “the beginning of a line,” which match a condition rather than a character in a string, are nonetheless expressed with characters or sequences of characters in the regexp.
像 一行的开头 这样的组分匹配的是条件而不是具体字符内容，这部 条件 要写在regular expression 中的特定位置。

-

**Simple matching with literal regular expressions**

在 ruby 中 任何 regular expression 被视作 Regexp class 的一个实例

ruby中的 regular expression 使用两个斜线包裹

```ruby
2.5.0 :001 > //.class
 => Regexp
2.5.0 :002 >
```

The simplest way to find out whether there’s a match between a pattern and a string is with the match method. You can do this either direction—regexp objects and string objects both respond to match, and both of these examples succeed and print "Match!":

测试一个string和regexp之间是否有匹配的最好方法是使用 `match`方法。这两个对象可以颠倒顺序，string和regexp都 respond_to `match`，下面两个例子都是成功的。

```ruby
2.5.0 :004 > puts "Match!" if /abc/.match("The alphabet starts with abc.")
Match!
 => nil
2.5.0 :005 > puts "Match!" if "The alphabet starts with abc.".match(/abc/)
Match!
 => nil
2.5.0 :006 >
```

The string version of match (the second line of the two) differs from the regexp version in that it converts a string argument to a regexp. (We’ll return to that a little later.) In the example, the argument is already a regexp (/abc/), so no conversion is necessary.

string在前的版本和regexp在前的版本是不同的。string作为argument的版本会把 string 转换为一个 regexp 对象（这一点后面再提）。 如果是 regexp 作为参数则不会发生任何转。

除了 `match` ruby还有另一个类似的 `=~` 方法。

```ruby
2.5.0 :006 > puts "Match!" if /abc/ =~ ("The alphabet starts with abc.")
Match!
 => nil
2.5.0 :007 > puts "Match!" if "The alphabet starts with abc." =~ (/abc/)
Match!
 => nil
2.5.0 :008 >
```

match 和 =~ 既是 Regexp也是String 的instance method。

二者的区别在于， match 返回的是一个 matchdata 对象， =~ 返回的是匹配开始处的index

```ruby
2.5.0 :008 > "The alphabet starts with abc." =~ (/abc/)
 => 25
2.5.0 :009 > "The alphabet starts with abc.".match(/abc/)
 => #<MatchData "abc">
2.5.0 :010 >
```

关于 class MatchData 的内容后面再说。由于我们目前会更关注 match 的具体内容，而不是一个 index ， 所以后面的例子大多会用 `match`

-

**Building a pattern in a regular expression**

When you write a regexp, you put the definition of your pattern between the forward slashes. Remember that what you’re putting there isn’t a string but a set of predictions and constraints that you want to look for in a string.

The possible components of a regexp include the following:
 
- Literal characters, meaning “match this character”

- The dot wildcard character (.), meaning “match any character” (except \n, the newline character)

- Character classes, meaning “match one of these characters

当你写一个正则表达式时，要记住你不是在放字符进入，而是在放入一系列的用来寻找字符串的预测以及限制。

正则表达式的写法有

纯字母，意思是匹配这个字母

`.` 作为通配符，意思是匹配除了 `\n`换行符 之外的所有内容

字符集，意思是匹配这些字符集合中的任何一个

有些字符比较特殊，如果你要匹配他们需要用 backslash 做溢出 `\` 比如你想匹配字符中的问号 `?`

```ruby
2.5.0 :012 > "Am I?".match(/?/)
Traceback (most recent call last):
        1: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
SyntaxError ((irb):12: target of repeat operator is not specified: /?/)
2.5.0 :013 > "Am I?".match(/\?/)
 => #<MatchData "?">
2.5.0 :014 >
```

如果单写一个问号在 regexp 中, 会报错，因为没有作溢出的`?`意思有特殊的含义。

需要专门作溢出的有这些符号 `(^ $ ? . / \ [ ] { } ( ) + *)` ， 注意还有点号 `.`

-

The dot wildcard character(.)

-

之前提过点号 `.` 可以匹配除了换行符之外的任何字符，比如你想匹配 'deject' 和 'reject' 或者任何后面是 'eject'的单词 就可以使用

```ruby
2.5.0 :014 > array = %w{reject Reject Deject deject}
 => ["reject", "Reject", "Deject", "deject"]

2.5.0 :016 > array.each { |e| p e.match(/.eject/) }
#<MatchData "reject">
#<MatchData "Reject">
#<MatchData "Deject">
#<MatchData "deject">
 => ["reject", "Reject", "Deject", "deject"]
2.5.0 :017 >
```

你甚至可以匹配 '&eject' '%eject' '9eject' 等。

wildcard 匹配有时范围涵盖地会太广，这时使用字符清单character class会是好选择

-

Character classes

-

字符清单的标致是方括号 `[ ]`

`/[dr]eject/` 的意思是匹配以  'd' 或者 'r' 开头后面是 'eject' 的单词

```ruby
2.5.0 :018 > array = %w{reject Reject Deject deject 9eject %eject}
 => ["reject", "Reject", "Deject", "deject", "9eject", "%eject"]
2.5.0 :019 > array.each { |e| p e.match(/[dr]eject/) }
#<MatchData "reject">
nil
nil
#<MatchData "deject">
nil
nil
 => ["reject", "Reject", "Deject", "deject", "9eject", "%eject"]
2.5.0 :020 >
```

在字符清单中连续的多个字母可以使用 regexp 的 range 格式

比如 `/[a-z]/` 就代表所有的小写字母

如果想匹配一个 十六进制的数字，你会在一个字符清单中写多个 range， 注意range之间不用分隔符号

`/[A-Fa-f0-9]/`

-

character classes are longer than what they match

-

Even a short character class like [a] takes up more than one space in a regexp. But remember, each character class matches one character in the string. When you look at a character class like /[dr]/, it may look like it’s going to match the substring dr. But it isn’t: it’s going to match either d or r.

即使是最短的字符清单比如 `/[a]/` 也会占更多的位置。 但是要记住不管一个字符清单(无附加条件)有多长， 他match的都只是 一个字符， 像 `/[dr]/` 这样的清单看起来很像是在匹配 'dr' 这样两个连续的字母，但实际不是，他只是匹配 d 或 r 。

Sometimes you need to match any character except those on a special list. You may, for example, be looking for the first character in a string that is not a valid hexadecimal digit.
有时你想通过排除某些字符来得到反向的匹配，比如你想得到一个不是十六进制数字的其他什么字符

You perform this kind of negative search by negating a character class. To do so, you put a caret (^) at the beginning of the class. For example, here’s a character class that matches any character except a valid hexadecimal digit:
这种反向搜索可以使用 `^` 符号放在字符清单开头。比如下面就是匹配 '除了十六进制数字的其他字符' 的写法，注意是写在字符清单内部开头不是在括号外。

`/[^A-Fa-f0-9]/`

And here’s how you might find the index of the first occurrence of a non-hex character in a string:
或者你想找到一个 '除了十六进制数字的其他字符' 第一个匹配点的 index

```ruby
2.5.0 :002 > string = "ABC3934 is a hex number."
 => "ABC3934 is a hex number."
2.5.0 :003 > string =~ /[^A-Fa-f0-9]/
 => 7
2.5.0 :004 >
```

A character class, positive or negative, can contain any characters. Some character classes are so common that they have special abbreviations.

一个字符清单，不管是正选的还是反选的，都可以包含任何字符。有些字符清单由于太常用了，所以有了他们自己的缩写形式。

比如匹配 任何数字， 常规写法是

`/[0-9]/`

缩写形式可以用 \d

`/\d/`

注意这里甚至没有用方括号

另外两个不需要使用方括号而使用 backslash 溢出符号的 字符清单缩写是：

\w matches any digit, alphabetical character, or underscore (_).

\s matches any whitespace character (space, tab, newline).

`\w` 匹配任何数字，字母，以及 下划线 `_`

`\s` 匹配任何空白字符

Each of these predefined character classes also has a negated form. You can match any character that isn’t a digit by doing this:

所有这些字符清单的反选清单，只要把小写改成大写就是了，比如想选择 '除了数字以外的所有字符' 可以写：

`/\D/`

同样的 /\W/ 和 /\S/ 和小写的相反。

A successful call to match returns a MatchData object. Let’s look at MatchData objects and their capabilities up close.

下面要来看看 match 方法返回的 matchdata 所在的 class 了。

-

**Matching, substring captures, and MatchData**

-

```ruby
2.5.0 :006 > "abc".match /xyz/
 => nil
2.5.0 :007 > "abc".match /c/
 => #<MatchData "c">
2.5.0 :008 > "abc" =~ /c/
 => 2
2.5.0 :009 > "abc" =~ /xyz/
 => nil
2.5.0 :010 >
```

match 方法没有成功时 return value 是 nil

match 方法匹配到字符时 return value 是一个 MatchData 对象

-

Capturing submatches with parentheses

-

One of the most important techniques of regexp construction is the use of parentheses to specify captures.

The idea is this. When you test for a match between a string—say, a line from a file—and a pattern, it’s usually because you want to do something with the string or, more commonly, with part of the string. The capture notation allows you to isolate and save substrings of the string that match particular subpatterns.

regexp 中一个很重要的结构是作为捕获器的 `()`

基本思想是，当你在匹配一串字符时-比如一个文件中的一行-你想对这个string作一些修改，更常见的是，你想对string中的某一部分作修改。这时 括号`()`作为捕获器就可以存储分段匹配的结果。

比如说有这么一个字符串 "Peel,Emma,Mrs.,talented amateur"

From this string, we need to harvest the person’s last name and title. We know the fields are comma separated, and we know what order they come in: last name, first name, title, occupation.

To construct a pattern that matches such a string, we might think in English along the following lines:

现在我们想拿到这个字串中的 last name 和 称谓。 我们观察到字串中的信息是以逗号分隔的，也知道他们排布的顺序： last name, first name, title, occupation。 那么拆解步骤我们可以这么思考：

  First some alphabetical characters, 首先拿到一些字母

  then a comma, 接着一个逗号

  then some alphabetical characters, 接着又是一些字母

  then a comma, 接着一个逗号

  then either 'Mr.' or 'Mrs.' 然后是称为


We’re keeping it simple: no hyphenated names, no doctors or professors, no leaving off the final period on Mr. and Mrs. (which would be done in British usage). The regexp, then, might look like this:
假设名字中没有连字号，没有医生或教授，称谓末尾没有点号，那么就可以这么写 regexp

```ruby
/[A-Za-z]+,[A-Za-z]+,Mrs?\./
```

(The question mark after the s means match zero or one s. Expressing it that way lets us match either “Mr.” and “Mrs.” concisely.) The pattern matches the string, as irb attests:

末尾的 's' 后带的 '?' 问号， 意思是匹配 0 个或 1个 's'。 这么写可以同时匹配到 'Mr' 和 'Mrs'，下面测试

```ruby
2.5.0 :010 > /[A-Za-z]+,[A-Za-z]+,Mrs?\./.match "Peel,Emma,Mrs.,talented amateur"
 => #<MatchData "Peel,Emma,Mrs.">
2.5.0 :011 >
```

接下来我们要怎么拿到我们需要的 last name 'Peel' 以及 称谓？

这就是括号 capture 派上用场的地方

只需要把要捕获的部分分别用括号括起来就可以

```ruby
/([A-Za-z]+),([A-Za-z]+),Mrs?\./
```

接着测试

```ruby
2.5.0 :012 > /([A-Za-z]+),[A-Za-z]+,(Mrs?\.)/.match "Peel,Emma,Mrs.,talented amateur"
 => #<MatchData "Peel,Emma,Mrs." 1:"Peel" 2:"Mrs.">
2.5.0 :013 >
```

two things happen:
 
We get a MatchData object that gives us access to the submatches (discussed in a moment).
Ruby automatically populates a series of variables for us, which also give us access to those submatches.

发生了两件事

我们拿到了 MatchData 对象

ruby 自动给捕获器捕捉到的对象进行了变数赋值操作

The variables that Ruby populates are global variables, and their names are based on numbers: $1, $2, and so forth. $1 contains the substring matched by the subpattern inside the first set of parentheses from the left in the regexp. Examining $1 after the previous match (for example, with puts $1) displays Peel. $2 contains the substring matched by the second subpattern; and so forth. In general, the rule is this: after a successful match operation, the variable $n (where n is a number) contains the substring matched by the subpattern inside the nth set of parentheses from the left in the regexp.

Ruby 对capture结果进行的赋值操作对应的变量是 global variable 全域变量，这些变量的名称是基于整数的比如 `$1`, `$2`，等。 每一个变量对应一个捕获结果。直接呼叫变量就可以看到各个捕获器捕获的结果。 通常，规则是这样： 在一个成功的匹配之后， `$n` 代表regexp 中从左至右的第 n 个捕获器内匹配结果。

-

Note

If you’ve used Perl, you may have seen the variable $0, which represents not a specific captured subpattern but the entire substring that has been successfully matched. Ruby uses $0 for something else: it contains the name of the Ruby program file from which the current program or script was initially started up. Instead of $0 for pattern matches, Ruby provides a method; you call string on the MatchData object returned by the match. You’ll see an example of the string method in section 11.4.2.

如果你用过 Perl ， 你也许知道他使用 `$0` 来代表整个匹配结果。但ruby中 `$0` 代表其他东西：他存储这当前ruby程序或脚本初始化运行的文件。ruby用另一个 `method` 来代表整个匹配结果。

-

先继续看下前面的例子

```ruby
2.5.0 :012 > /([A-Za-z]+),[A-Za-z]+,(Mrs?\.)/.match "Peel,Emma,Mrs.,talented amateur"
 => #<MatchData "Peel,Emma,Mrs." 1:"Peel" 2:"Mrs.">
2.5.0 :013 > puts "Dear #{$2} #{$1}."
Dear Mrs. Peel.
 => nil
2.5.0 :014 >
```

The $n-style variables are handy for grabbing submatches. But you can accomplish the same thing in a more structured, programmatic way by querying the MatchData object returned by your match operation.

使用`$n`变量来抓取submatches很方便。但你可以以另一种更加结构化，程序化的方式达成同样的目的，使用 MatchData 对象查询的方法。

-

**Match success and failure**

-

当匹配失败时 match 会返回 nil, 成功时返回 matchdata 对象。从boolean判断的角度来看，前者会是false，后者会是true。Matchdata 对象中还存储着更多关于匹配的信息，比如 match开始处是第几个字符处，一个match覆盖到了多少个字符，以及在某个capture中匹配到了什么，等。

当然要使用 Matchdata 对象，要先把他存起来。假设你想从一串文字中抽取出一个电话号码，然后将邮编，号码等这些信息分组存储起来：

```ruby
string = "My phone number is (123) 555-1234."

# （3位数字）一个或多个空格 （3位数字）横线- （4位数字）
phone_re = /\((\d{3})\)\s+(\d{3})-(\d{4})/

m = phone_re.match(string)
unless m
  puts "There was no match, sorry."
  exit
end

print 'The whole string we started with: '
puts m.string

print 'The entire part of the string that matched: '
puts m[0]

puts 'The three captures: '
3.times do |index|
  puts "Capture ##{index + 1}: #{m.captures[index]}"
end

puts "Here's another way to get at the first capture:"
print "Capture #1: "
puts m[1]
```

`ruby pluck_phone.rb`

```ruby
The whole string we started with: My phone number is (123) 555-1234.
The entire part of the string that matched: (123) 555-1234
The three captures:
Capture #1: 123
Capture #2: 555
Capture #3: 1234
Here's another way to get at the first capture:
Capture #1: 123
```

上面的例子中

对matchdata对象使用 `string` 方法，返回用于匹配的字串整体（注意是匹配前的完整string）

对 matchdata 对象使用 `[0]` 返回整个匹配到的内容

接着用一个 `times` block ，从 matchdata.captures 中去拿对应的结果，注意captures中存储所有的分组捕获结果，index 从 `[0]` 开始。

最后我们又返回 matchdata 对象层级，用 `[1]` 拿到第一个捕获器内容。

-

Two ways of getting the captures

-

上面的例子中看到从 Matchdata 对象中拿指定的捕获结果有两种方式

- 从 matchdata 身上直接拿

- 从 matchdata.captures 里面拿

拿的方式都是用方括号，但要注意index的使用规则

matchdata中直接拿结果是从 `[1]` 开始，对应第一个capture。 而 `matchdata[0]` 对应的是整个匹配结果。

而 matchdata.captures 中拿则是从 `[0]` 开始，因为 matchdata.captures返回的是一个 array

因此这两行测试应该都是 true

```ruby
m[1] == m.captures[0]
m[2] == m.captures[1]
```

-

有时候捕获器数量多了可能会引起阅读上的困难，这时你要数清楚括号的数量，以及弄清结构

比如 `/((a)((b)c))/.match 'abc'`

结果是

```ruby
2.5.0 :008 > /((a)((b)c))/.match 'abc'
 => #<MatchData "abc" 1:"abc" 2:"a" 3:"bc" 4:"b">
2.5.0 :009 >
```
-

Named captures

-

使用 index 作为capture 的标记很方便，但是有另一种更加可读的方法，那就是给capture命名

Here’s an example. This regular expression will match a name of the form “David A. Black” or, equally, “David Black” (with no middle initial):

下面这个 regexp 会匹配 `Davdi A. Black` 或者 'David Black'

```ruby
2.5.0 :014 > re = /(?<first>\w+)\s+((?<middle>\w\.)\s+)?(?<last>\w+)/
 => /(?<first>\w+)\s+((?<middle>\w\.)\s+)?(?<last>\w+)/
2.5.0 :015 > m = re.match 'David A. Black'
 => #<MatchData "David A. Black" first:"David" middle:"A." last:"Black">
2.5.0 :016 > m = re.match 'David Black'
 => #<MatchData "David Black" first:"David" middle:nil last:"Black">
2.5.0 :017 >
```

从返回的 matchdata 对象中可以看到原来的数字标记变成了指定名称的标记

接着就可以使用 :名称 来取得对应的capture

```ruby
2.5.0 :023 > m = re.match 'David A. Black'
 => #<MatchData "David A. Black" first:"David" middle:"A." last:"Black">
2.5.0 :024 > m[:first]
 => "David"
2.5.0 :025 > m[:middle]
 => "A."
2.5.0 :026 >
```

named captures的好处是易读，缺点是你不能一眼看出有多少个 capture

-

Other MatchData information

-

matchdata中的其他信息

下面的例子基于上面给出pluck_phone的代码示例结果

```ruby
2.5.0 :002 > string = "My phone number is (123) 555-1234."
 => "My phone number is (123) 555-1234."
2.5.0 :003 > phone_re = /\((\d{3})\)\s+(\d{3})-(\d{4})/
 => /\((\d{3})\)\s+(\d{3})-(\d{4})/
2.5.0 :004 > m = phone_re.match(string)
 => #<MatchData "(123) 555-1234" 1:"123" 2:"555" 3:"1234">
```

pre_match, post_match, begin, end

```ruby
puts "Here's another way to get at the first capture:"
print "Capture #1: "
puts m[1]

print "The part of the string before the part that matched was: "
puts m.pre_match

print "The part of the string after the part that matched was: "
puts m.post_match

print "The second captures began at character "
puts m.begin(2)

print "The third capture ended at character "
puts m.end(3)
```

结果是

```ruby
The part of the string before the part that matched was: My phone number is
The part of the string after the part that matched was: .
The second captures began at character 25
The third capture ended at character 33
```

ruby基于capture把匹配结果分成了三部分，capture本身，以及capture之前，之后的部分。

begin(n) 和 end(n) 可以告诉你第 n 个capture开始或结束位置的character的位置序号

-

The global MatchData object `$~`

-

Whenever you perform a successful match operation, using either match or =~, Ruby sets the global variable $~ to a MatchData object representing the match. On an unsuccessful match, $~ gets set to nil. Thus you can always get at a MatchData object, for analytical purposes, even if you use =~.

任何一个成功的match，不管是用 `match` 还是 `=~` ， ruby 都生成了一个全域变量 `$~` 来代表这个match。如果是失败的match， `$~` 会是 nil。 使用 `$~` 你就可以在任何匹配后拿到 matchdata 对象， 即使是使用 `=~`

```ruby
2.5.0 :012 > /a/.match 'a'
 => #<MatchData "a">
2.5.0 :013 > $~
 => #<MatchData "a">
2.5.0 :014 > /x/ =~ 'x'
 => 0
2.5.0 :015 > $~
 => #<MatchData "x">
2.5.0 :016 >
```

-

**Fine-tuning regular expressions with quantifiers, anchors, and modifiers**

-

- quantifiers 量词

- anchors 锚

- modifiers 修饰语

-

Quantifiers let you specify how many times in a row you want something to match. Anchors let you stipulate that the match occur at a certain structural point in a string (beginning of string, end of line, at a word boundary, and so on). Modifiers are like switches you can flip to change the behavior of the regexp engine; for example, by making it case-insensitive or altering how it handles whitespace.

quantifiers量词让你可以指定一次匹配多少次某部分内容。 anchors锚让你规定匹配只在指定位置进行（字串的开头，一行的结束处，单词的边缘，等等）。修饰语就像一个能控制正则表达式引擎的开关；比如控制如何处理空白。

-

constraining matches with quantifiers

-

Zero or one `?`

0个(没有)或者有1个

Regexp notation has a special character to represent the zero-or-one situation: the question mark (?). The pattern just described would be expressed in regexp notation as follows:

比如前面的匹配 'Mr' 和 'Mrs' 两种情况的regexp

`?` 要跟在你要匹配的对象后面

`/Mrs?\.?/`

量词常用于多个数字的情况，比如匹配一个数字或两个数字

`/\d\d?/`

可以匹配 1, 2, 3 也可以匹配 12, 01, 等

-

Zero or more  `*`

0个(没有)或多个

A fairly common case is one in which a string you want to match contains white-space, but you’re not sure how much. Let’s say you’re trying to match closing </poem> tags in an XML document. Such a tag may or may not contain whitespace. All of these are equivalent:

一个常用的情况时你想匹配空格，但是你不确定到底有多少个。 假设你想匹配XML文件中的 </poem> 标签。 这个标签中可能有空格也可能没有，下面这写标签写法都是等价的

```
</poem>
< /poem>
</      poem>
</poem
>
```

In order to match the tag, you have to allow for unpredictable amounts of whitespace in your pattern—including none.
This is a case for the zero-or-more quantifier—the asterisk or star (*):

为了匹配到这类标签，你必须允许不确定个数的空白，同时包含没有空格的情况。

这时 `*` 就可以实现

```ruby
/<\s*\/\s*poem\s*>/
```

Each time it appears, the sequence \s* means the string being matched is allowed to contain zero or more whitespace characters at this point in the match. (Note the necessity of escaping the forward slash in the pattern with a backslash. Otherwise, it would be interpreted as the slash signaling the end of the regexp.)

每一次 `\s*` 出现就代表匹配0个或多个空格。记得 `/` 要溢出处理

Next among the quantifiers is one or more.

-

One or more `+`

(至少)1个或多个

比如一个或多个数字

```
/\d+/
```

matches any sequence of one or more consecutive digits:

匹配任何位置的连续数字

```ruby
2.5.0 :018 > /\d+/.match "There's a digit here somewh3re..."
 => #<MatchData "3">
2.5.0 :019 > /\d+/.match "No digits here, Moving along."
 => nil
2.5.0 :020 > /\d+/.match "Digits-R-Us 2345"
 => #<MatchData "2345">
2.5.0 :021 >
```

当然如果你加上capture括号 你可以用 global variable 拿到匹配结果

```ruby
2.5.0 :023 > /(\d+)/.match "Digits-R-Us 2345"
 => #<MatchData "2345" 1:"2345">
2.5.0 :024 > $1
 => "2345"
2.5.0 :025 >
```

但 `\d+` 在拿到第一个连续数字后就会停下来

```ruby
2.5.0 :025 > /(\d+)/.match "Digits-R-Us 2345 and 7890"
 => #<MatchData "2345" 1:"2345">
2.5.0 :026 >
```

But why match four digits when all you need to prove you’re right is one digit? The answer, as it so often is in life as well as regexp analysis, is greed.

但如果当你只需要匹配到一个数字时又为什么要去拿到连续的4个数字呢，这方面关于正则表达式的分析话题是关于 `greed` 的

看下面这两个例子

```ruby
2.5.0 :028 > string = "abc!def!ghi!"
 => "abc!def!ghi!"
2.5.0 :029 > match = /.+!/.match string
 => #<MatchData "abc!def!ghi!">
2.5.0 :030 > puts match[0]
abc!def!ghi!
 => nil
2.5.0 :031 > match = /.*!/.match string
 => #<MatchData "abc!def!ghi!">
2.5.0 :032 > puts match[0]
abc!def!ghi!
```

`/.+!/` 和 `/.*!/` 并没有在匹配到第一个感叹号`!`时停下来

`+` 是1个或多个， `*` 是0个或多个， `.` 是通配符

理解这个式子的关键是 `.` 匹配除了换行符号以外的所有字符（包括`!`），所以实际这两个式子可以分成两部分，前面的通配符部分，和末尾的一个单独的感叹号`!`。

`/.+!/` 对应的是 一个或多个 'abc!def!ghi' 以及末尾的 '!'

`/.*!/` 对应的是 0个或多个 'abc!def!ghi' 以及末尾的 '!'

至此，情况仍然符合之前提到的规则，这也是提到的 greedy 特性。

那么如果如果想要在第一个感叹号处就停下来? 那就在 `+` 或 `*` 后加上问号 `?`(0个或1个)

```ruby
2.5.0 :037 > match = /.+?!/.match string
 => #<MatchData "abc!">
2.5.0 :038 > match = /.*?!/.match string
 => #<MatchData "abc!">
2.5.0 :039 >
```

This version says, “Give me one or more wildcard characters, but only as many as you see up to the first exclamation point, which should also be included.” Sure enough, this time we get "abc!".

上面的式子意思是'找出连续1个或多个任意字符，但在遇到第一个感叹号时就停下来'

If we add the question mark to the quantifier in the digits example, it will stop after it sees the 2:

如果把问号加在之前匹配数字的例子上

```ruby
2.5.0 :042 > /(\d+)/.match 'Digits-R-US 2345'
 => #<MatchData "2345" 1:"2345">
2.5.0 :043 > /(\d+?)/.match 'Digits-R-US 2345'
 => #<MatchData "2" 1:"2">
2.5.0 :044 >
```

`\d+` 加上 `?` 后，就只匹配到1个数字

greedy 量词让你可以匹配尽可能多的内容

继续看下面这个例子

```ruby
2.5.0 :044 > /\d+5/.match 'Digits-R-US 2345'
 => #<MatchData "2345">
2.5.0 :045 >
```
If the one-or-more quantifier’s greediness were absolute, the \d+ would match all four digits—and then the 5 in the pattern wouldn’t match anything, so the whole match would fail. But greediness always subordinates itself to ensuring a successful match. What happens, in this case, is that after the match fails, the regexp engine backtracks: it unmatches the 5 and tries the pattern again. This time, it succeeds: it has satisfied both the \d+ requirement (with 234) and the requirement that 5 follow the digits that \d+ matched.

如果 one-or-more 量词`+`的贪吃性是绝对的。那么 `\d+`就应该匹配到 2345， +后面的5就拿不到数字，这样整个匹配就失败了。但实际上贪吃特性通常会降低自己的优先级来保证匹配的成功。上面例子中实际发生的是，匹配首先失败了，但 regexp 引擎又回到开头，`\d+`不去拿末尾的5，然后再次尝试匹配。这次匹配成功了。

Once again, you can get an informative X-ray of the proceedings by capturing parts of the matched string and examining what you’ve captured. Let’s let irb and the MatchData object show us the relevant captures:

你可以用括号capture来透视各部分匹配的是什么内容

```ruby
2.5.0 :045 > /(\d+)(5)/.match 'Digits-R-US 2345'
 => #<MatchData "2345" 1:"234" 2:"5">
2.5.0 :046 >
```

前面 'abc!def!ghi!' 的例子也可以这么理解。

In addition to using the zero-/one-or-more-style modifiers, you can also require an exact number or number range of repetitions of a given subpattern.

除了使用 0个或多个，以及1个或多个量词，你还可以给某个 parttern 指定明确的重复次数

-

specific numbers of repitions

-

/\d/ 匹配一个数字
/\d+/ 匹配1个或多个数字
/\d+8/ 匹配以8结尾的连续多个数字 比如 265876587788 会整个匹配
/\d+?8/ 匹配第一个8出现处之前的连续多个数字 比如 265876587788 匹配到 2658
```ruby
2.5.0 :046 > /\d+8/.match '265876587788'
 => #<MatchData "265876587788">
2.5.0 :047 > /\d+?8/.match '265876587788'
 => #<MatchData "2658">
2.5.0 :048 >
```
/\d{4}/ 匹配连续4个数字
/\d{3,7}/ 匹配连续的3到7个数字
/\d{3,}/ 匹配连续的3到任意多个数字
```ruby
2.5.0 :051 > /\d{4}/.match '123456789'
 => #<MatchData "1234">
2.5.0 :052 > /\d{3,7}/.match '123456789'
 => #<MatchData "1234567">
2.5.0 :054 > /\d{3,}/.match '123456789'
 => #<MatchData "123456789">
2.5.0 :055 >
```

对于重复个数的指定不只限于单个字符，也可以用于字符清单

```ruby
2.5.0 :057 > /([A-Z]){5}/.match 'David BLACK'
 => #<MatchData "BLACK" 1:"K">
2.5.0 :058 >
```

但这里原本期望 capture 拿到的应该是 'BLACK' 但是现在只拿到 'K'

It’s just "K". Why isn’t "BLACK" captured in its entirety?
The reason is that the parentheses don’t “know” that they’re being repeated five times. They just know that they’re the first parentheses from the left (in this particular case) and that what they’ve captured should be stashed in the first capture slot ($1, or captures[1] of the MatchData object). The expression inside the parentheses, [A-Z], can only match one character. If it matches one character five times in a row, it’s still only matched one at a time—and it will only “remember” the last one.
这是因为 `{}` 出现在 `()`的外面，相当于是对括号内的字符清单作了5次重复的匹配，([A-Z])一次只匹配一个字符。{5} 匹配的是连续字符，所以是从 last name 部分开始的。由于连续5次独立字符匹配，那么就只记录了最后一次匹配到的 'K'

In other words, matching one character five times isn’t the same as matching five characters one time.
换句话说, 5次匹配单独字符和 一次匹配5个字符是不同的

If you want to capture all five characters, you need to move the parentheses so they enclose the entire five-part match:
明白了这一点就只需要把 {5} 移到 () 内部就可以了，这样 [A-Z]{5} 才会作为一个整体表意。

```ruby
2.5.0 :058 > /([A-Z]{5})/.match 'David BLACK'
 => #<MatchData "BLACK" 1:"BLACK">
2.5.0 :059 >
```

要注意这类组合的区别，如果不清楚要提前在 irb 中实验各种情况。

-

**Regular expression anchors and assertions**

-

anchors 和 assertions 和字符是不同的概念，后者与内容相关，前两者是在匹配前对匹配模式做出的限制。

最常见的 anchor 是一行的开头 `^` 以及一行的结尾 `$`。比如你想要去掉文件中以 # 开头（前面可能还带有不确定数量的空格）的注释符号

```
/^/s*#/
```
意思是 '在一行开头处匹配0个或多个空格加#号'

The ^ (caret) in this pattern anchors the match at the beginning of a line. If the rest of the pattern matches, but not at the beginning of the line, that doesn’t count—as you can see with a couple of tests:

`^` 符号会让匹配只在一行开头处进行，中间字段的匹配不会生效

```ruby
2.5.0 :061 > comment_regexp = /^\s*#/
 => /^\s*#/
2.5.0 :062 > comment_regexp.match '     # Pure comment!'
 => #<MatchData "     #">
2.5.0 :063 > comment_regexp.match ' x = 1     # Code plus comment!'
 => nil
2.5.0 :064 >
```
注意用在字符清单内部的反选符号 `^` 和这里的一行开头处是同一个，但前者是用在字符清单内部的比如 `[^A-Z0-9]` 后者是单独放置的。

|Notation|Description|Example|Sample matching string|
|:-:|:-:|:-|:-|
|^|beginning of line|/^\s*#/|'# A Ruby comment line with leading spaces'|
|$|end of line|/\.$/|'one\ntwo\nthree.\nfour'|
|\A|beginning of string|/AFour score/|'Four score'|
|\z|end of string|/from the earth.\z/|'from the earth.'|
|\Z|end of string(except for final newline)|/from the earth.\Z/|'from the earth\n'|
|\b|word boundary|/\b\w+\b/|'!!!word***'(matches 'word')|

Note that \z matches the absolute end of the string, whereas \Z matches the end of the string except for an optional trailing newline. \Z is useful in cases where you’re not sure whether your string has a newline character at the end—perhaps the last line read out of a text file—and you don’t want to have to worry about it.

Hand-in-hand with anchors go assertions, which, similarly, tell the regexp processor that you want a match to count only under certain conditions.

注意 `\z`(小写) 匹配字串的绝对结尾处， `\Z`(大写) 匹配后面可能还有空行的字串结尾。大写的Z适用于那些 末尾有换行符号的字串--比如从另一个文件中读过来的一行。

-

Lookahead asssertions
前置(前瞻)断言

-

与 anchors 紧密关联的是 assertions。 当你想要让匹配只在特定条件下进行时，你就需要用到 assertions

比如你想匹配一个字串中的连续数字，但你只需要那些以点号`.`结尾的连续数字

One way to do this is with a lookahead assertion—or, to be complete, a zero-width, positive lookahead assertion. Here, followed by further explanation, is how you do it:
一个前置断言，完整的说是一个 zero-width 零跨度， positive 正向的 前置断言。


```ruby
2.5.0 :066 > str = '123 456. 789'
 => "123 456. 789"
2.5.0 :067 > m = /\d+(?=\.)/.match str
 => #<MatchData "456">
```

At this point, m[0] (representing the entire stretch of the string that the pattern matched) contains 456—the one sequence of numbers that’s followed by a period.


```ruby
2.5.0 :069 > m[0]
 => "456"
```

下面是一些相关术语


- Zero-width means it doesn’t consume any characters in the string. The presence of the period is noted, but you can still match the period if your pattern continues.
zero-width 零跨度，意思是不消费string中的任何内容。也就是点号`.`被识别到了，但是匹配内容中不包含它，并且如果你要进行后续的匹配，匹配不是从点号之后开始，而是从这个点号开始。

- Positive means you want to stipulate that the period be present. There are also negative lookaheads; they use (?!...) rather than (?=...).
positive 正向性 意思是你想要规定点号任然处于未被消费的状态。

- Lookahead assertion means you want to know that you’re specifying what would be next, without matching it.
前置断言意思是你想要指明识别点，而不是对他做匹配。

When you use a lookahead assertion, the parentheses in which you place the lookahead part of the match don’t count; $1 won’t be set by the match operation in the example. And the dot after the 6 won’t be consumed by the match. (Keep this last point in mind if you’re ever puzzled by lookahead behavior; the puzzlement often comes from forgetting that looking ahead isn’t the same as moving ahead.)

当你使用一个前置断言时，用来包裹他的括号并不会被当做一个 capture， 也就是`$1`不会是`(lookahead assertion)`匹配结果。6后面的点号和不会被算作匹配过的字符。

-

Lookbehind assertions

-

The lookahead assertions have lookbehind equivalents. Here’s a regexp that matches the string BLACK only when it’s preceded by “David”:

下面是一个例子，regexp 只会在前面内容是 'David' 的时候匹配 'BLACK'

`re = /(?<=David )BLACK/`

反过来如果只匹配前面不是 'David' 的 'BLACK'

`re = /(?<!David)BLACK/`

Once again, keep in mind that these are zero-width assertions. They represent constraints on the string (“David” has to be before it, or this “BLACK” doesn’t count as a match), but they don’t match or consume any characters.

再次注意这些都是 零跨度 断言。他们代表某些限制点，但并不会作为匹配的一部分。

```ruby
2.5.0 :071 > name = 'Mr. David BLACK'
 => "Mr. David BLACK"
2.5.0 :072 > re = /(?<=David )BLACK/
 => /(?<=David )BLACK/
2.5.0 :073 > re.match name
 => #<MatchData "BLACK">
2.5.0 :074 > re = /(?<!David )BLACK/
 => /(?<!David )BLACK/
2.5.0 :075 > re.match name
 => nil
2.5.0 :076 >
```

-

Non-capturing parentheses

If you want to match something—not just assert that it’s next, but actually match it—using parentheses, but you don’t want it to count as one of the numbered parenthetical captures resulting from the match, use the (?:...) construct. Anything inside a (?:) grouping will be matched based on the grouping, but not saved to a capture. Note that the MatchData object resulting from the following match only has two captures; the def grouping doesn’t count, because of the ?: notation:

如果想要一个 capture 括号不实际计入分组结果之一，那么在括号内部开头加上 `?:` 变成 `(?:)`

```ruby
2.5.0 :084 > str = 'abc def ghi'
 => "abc def ghi"
2.5.0 :085 > m = /(abc) (?:def) (ghi)/.match str
 => #<MatchData "abc def ghi" 1:"abc" 2:"ghi">
2.5.0 :086 > m = /(abc) def (ghi)/.match str
 => #<MatchData "abc def ghi" 1:"abc" 2:"ghi">
2.5.0 :087 >
```

Unlike a zero-width assertion, a (?:) group does consume characters. It just doesn’t save them as a capture.

和前面提到的 零跨度 断言不同。(?:) 作为实际匹配的一部分，会消耗字符内容。

-

conditional matches

-

While it probably won’t be among your everyday regular expression practices, it’s interesting to note the existence of conditional matches in Ruby 2.0’s regular expression engine (project name Onigmo). A conditional match tests for a particular capture (by number or name), and matches one of two subexpressions based on whether or not the capture was found.

虽然不常用，但是ruby 2.0开始包含了 conditional matches 条件匹配的内容。意思是基于前面的匹配结果来决定后面的匹配操作。

Here’s a simple example. The conditional expression (?(1)b|c) matches b if capture number 1 is matched; otherwise it matches c:

一个例子， `(?(1)b|c)` ， 意思是如果capture $1匹配成功，那么后续匹配b, 不然直接匹配 c
```ruby
2.5.0 :094 > re = /(a)?(?(1)b|c)/
 => /(a)?(?(1)b|c)/
2.5.0 :095 > re.match 'ab' # $1 succeeded, so continue matching 'b'
 => #<MatchData "ab" 1:"a">
2.5.0 :096 > re.match 'b' # $1 failed, so continue matching 'c', but still failed
 => nil
2.5.0 :097 > re.match 'c' # $1 failed, so continue matching 'c', matched
 => #<MatchData "c" 1:nil>
2.5.0 :098 >
```

You can also write conditional regular expressions using named captures. The preceding example would look like this:

你可以加上 named capture 的用法

```ruby
2.5.0 :100 > named_re =/(?<first>a)?(?(<first>)b|c)/
 => /(?<first>a)?(?(<first>)b|c)/
2.5.0 :101 > named_re.match 'ab'
 => #<MatchData "ab" first:"a">
2.5.0 :102 > named_re.match 'a'
 => nil
2.5.0 :103 > named_re.match 'b'
 => nil
2.5.0 :104 > named_re.match 'c'
 => #<MatchData "c" first:nil>
2.5.0 :105 >
```

Anchors, assertions, and conditional matches add richness and granularity to the pattern language with which you express the matches you’re looking for. Also in the language-enrichment category are regexp modifiers.

anchors, assertions, 以及条件匹配给模式的描述增肌了丰富性。当然还有接下来要提到的 modifier 修饰语 也有这个作用。

-

**Modifiers**

-

修饰语是放在 regexp 末尾`/`的一个字母。

`/abc/i`

i 的意思是规定这个式子对大小写敏感

常见的还有 m，意思是 multiline，他会让 `.` 通配符(匹配除了换行的其他所有字符)将换行符号也识别进去。他适用于 当你想要抓取一对括号`()`之间的所有内容，包括内容有换行的情况，比如 'some(muiltilines\nbetween\nparentheses)some' 括号中的所有内容。

```ruby
2.5.0 :107 > str = "This (including\nwhat's in parens\n) takes up three lines."
 => "This (including\nwhat's in parens\n) takes up three lines."
2.5.0 :108 > m = /\(.*?\)/m.match str
 => #<MatchData "(including\nwhat's in parens\n)">
2.5.0 :109 > m = /\(.*?\)/.match str
 => nil
2.5.0 :110 >
```

`?` 的作用是让 `.*`变成 non-greedy 的，也就是在识别到第一个 `)` 就停下来

Another often-used regexp modifier is x. The x modifier changes the way the regexp parser treats whitespace. Instead of including it literally in the pattern, it ignores it unless it’s escaped with a backslash. The point of the x modifier is to let you add comments to your regular expressions:

另一个常用的修饰语是 `x`， 他会改变regexp 对待空格的方式。 加上 x 会让regexp只把 `\s` 作为空格，regexp中写的空格将不再有效。这样让你能够给你的 regexp 内部加上注释而不影响匹配工作，比如

```ruby
/
\((\d{3})\)  # 3 digits inside literal parens (area code)
   \s        # One space character
(\d{3})      # 3 digits (exchange)
    -        # Hyphen
(\d{4})      # 4 digits (second part of number
/x
```

上面的几行也可以写成一行，也就是无注释的版本

```ruby
/\((\d{3})\)\s(\d{3})-(\d{4})/
```

但注意第一次见到 `x` 的人很容易被引诱，也就是感觉什么地方都应该加上注释，甚至一些很简单的式子

`/  (?<=  David\ )  BLACK  /x`

(Note the backslash-escaped literal space character, the only such character that will be considered part of the pattern.) But remember that a lot of programmers have trained themselves to understand regular expressions without a lot of ostensibly user-friendly extra whitespace thrown in. It’s not easy to un-x a regexp as you read it, if you’re used to the standard syntax.

For the most part, the x modifier is best saved for cases where you want to break the regexp out onto multiple lines for the sake of adding comments, as in the telephone number example. Don’t assume that whitespace automatically makes regular expressions more readable.
We’ll look next at techniques for converting back and forth between two different but closely connected classes: String and Regexp.”

注意使用 `x` modifier 时，只有 `\s` 会被作为空格的识别符号，但记住很多开发者训练他们自己去阅读没有注释以及额外空格的regexp。这么做会比较难，读起来会相对费力。

大多数情况下， `x` 是你想将regexp断行加上注释的好选择。但不要有'增加空白就会增加易读性'这个预设的前提。

下面我们会学习 String 和 Regexp 之间的相互转换。

-

**converting strings and regular expressions to each other**

-

/abc/ 并不代表 'abc' ，也并不只能匹配 'abc'，任何字串中的任何位置含有 'abc' 这个 substring 的 string 对象和它匹配都会成功。

虽然 string 和 regexp 之间视觉上有某些相似，但他们不是同一个概念。

-

string-to-regexp idioms

-

To begin with, you can perform string (or string-style) interpolation inside a regexp. You do so with the familiar #{...} interpolation technique:

在 regexp 内部，我们可以使用字串中使用的 interpolation

```ruby
2.5.0 :114 > str = "def"
 => "def"
2.5.0 :115 > /abc#{str}/
 => /abcdef/
2.5.0 :116 >
```

但当字串中包含一些在 regexp 中有特殊含义的符号时，情况会变得复杂一些

```ruby
2.5.0 :001 > str = 'a.c'
 => "a.c"
2.5.0 :002 > re = /#{str}/
 => /a.c/
2.5.0 :003 > re.match 'a.c'
 => #<MatchData "a.c">
2.5.0 :004 > re.match 'abc'
 => #<MatchData "abc">
2.5.0 :005 >
```

上面两种情况都匹配成功，点号 `.` 在字串中是没有特殊含义的，但是在regexp中则不同，他代表通配符。

But you can escape the special characters inside a string before you drop the string into a regexp. You don’t have to do this manually: the Regexp class provides a Regexp.escape class method that does it for you. You can see what this method does by running it on a couple of strings in isolation:

但是可以对string这类特殊符号做转变过程中的溢出，你不需要手动的做，ruby中的 class Regexp 中有对应的class method `Regexp.escape`。
```ruby
2.5.0 :007 > Regexp.escape 'a.c'
 => "a\\.c"
2.5.0 :008 > Regexp.escape '^abc'
 => "\\^abc"
2.5.0 :009 >
```
(irb doubles the backslashes because it’s outputting double-quoted strings. If you wish, you can puts the expressions, and you’ll see them in their real form with single backslashes.)

As a result of this kind of escaping, you can constrain your regular expressions to match exactly the strings you interpolate into them:

irb 中返回了两根溢出线 `\\` 那是因为返回的结果是双引号包裹的，你可以用 puts 印出就可以看到真正的格式了

```ruby
2.5.0 :009 > puts Regexp.escape '^abc'
\^abc
 => nil
```

有了溢出方法，你就可以直接利用 interpolation 生成你想要精确匹配的字串内容的 regexp 了

```ruby
2.5.0 :012 > str = 'a.c'
 => "a.c"
2.5.0 :013 > re = /#{Regexp.escape(str)}/
 => /a\.c/
2.5.0 :014 > re.match 'a.c'
 => #<MatchData "a.c">
2.5.0 :015 > re.match 'abc'
 => nil
2.5.0 :016 >
```

It’s also possible to instantiate a regexp from a string by passing the string to Regexp.new:

我们也可以在实例化一个 regexp 对象时将 string 对象作为参数传入

```ruby
2.5.0 :016 > Regexp.new('(.*)\s+Black')
 => /(.*)\s+Black/
2.5.0 :017 >
```

但这里要注意没有溢出，给出的string内容会直接转为相同的 regexp

或者你可以在argument list内部做溢出

```ruby
2.5.0 :019 > Regexp.new('Mr\. David Black')
 => /Mr\. David Black/
2.5.0 :020 > Regexp.new(Regexp.escape('Mr. David Black'))
 => /Mr\.\ David\ Black/
2.5.0 :021 >
```

得到的结果是等效的。

注意第二种方法中对空格也使用了 `\ ` 虽然只有在使用`x` modifier是才必要但也无害。

你也可以在 Regexp.new()时传入一个 regexp 对象，但只是得到同样的结果

```ruby
2.5.0 :024 > /abc/.object_id
 => 70178797470900
2.5.0 :025 > /abc/.object_id
 => 70178797480840
2.5.0 :026 > /abc/.object_id
 => 70178797463640
2.5.0 :027 >
```

同内容的 regexp 对象 object_id 也不一样

有一点要再次提醒的是，在双引号的string中，`\` 也是溢出符号的含义，所以如果你传入的双引号 string 中含有 `\` 那就要写 `\\`。而单引号就不需要

```ruby
2.5.0 :029 > puts 'Mr\.'
Mr\.
 => nil
2.5.0 :030 > puts "Mr\."
Mr.
 => nil
2.5.0 :031 > puts "Mr\"
2.5.0 :032"> "
Mr"
 => nil
2.5.0 :033 > puts "Mr\\."
Mr\.
 => nil
2.5.0 :034 >
```

-

**Going from a regular expression to a string**

-

Like all Ruby objects, regular expressions can represent themselves in string form. The way they do this may look odd at first:

就像ruby所有的对象，regexp 对象也可以用string格式表现自己，不过看起来有点奇怪

```ruby
2.5.0 :038 > puts /abc/
(?-mix:abc)
 => nil
```

This is an alternate regexp notation—one that rarely sees the light of day except when generated by the to_s instance method of regexp objects. What looks like mix is a list of modifiers (m, i, and x) with a minus sign in front indicating that the modifiers are all switched off.
这是一种少见的输出，只有在对 regexp 使用 to_s 方法的时候才会看到。  mix 是三个 modifiers `m` `i` 和 `x` 的组合，前面的 `-` 的含义是这些 modifiers 都处于关闭状态。

You can play with putsing regular expressions in irb, and you’ll see more about how this notation works. We won’t pursue it here, in part because there’s another way to get a string representation of a regexp that looks more like what you probably typed—by calling inspect or p (which in turn calls inspect):
你可以对这类情况进行探索，你将会看到跟多的关于这些符号如何工作的内容。 这里我们不会继续深入了，一部分是因为有另外一种方法来将 regexp 输出为你写的样子, 那就是 `p` 或者 `inspect`

```ruby
2.5.0 :041 > /abc/.inspect
 => "/abc/"
2.5.0 :042 > p /abc/
/abc/
 => /abc/
2.5.0 :043 >
```

Going from regular expressions to strings is useful primarily when you’re studying and/or troubleshooting regular expressions. It’s a good way to make sure your regular expressions are what you think they are.

At this point, we’ll bring regular expressions full circle by examining the roles they play in some important methods of other classes. We’ve gotten this far using the match method almost exclusively; but match is just the beginning.

string 和 regexp 之间的转换在你学习 regexp 的期间会帮助你排除问题。是一种很好的验证你写的regexp 就是你想要的东西的方法。

接下来我们会了解regular expression 在一些classes的某些methods中是怎样被用到的。 之前用到的 match 方法当然很明显，但是match才刚刚开始。

-

**Common methods that use regular expressions**

-

The payoff for gaining facility with regular expressions in Ruby is the ability to use the methods that take regular expressions as arguments and do something with them.

To begin with, you can always use a match operation as a test in, say, a find or find_all operation on a collection. For example, to find all strings longer than 10 characters and containing at least 1 digit, from an array of strings called array, you can do this:

Ruby中引入regexp功能的好处是可以将他作为参数使用，或者利用他做其他事。比如说在 `find` `find_all` 的block中使用匹配操作，找到长度大于10且至少含有1位数字的内容。

`array.find_all {|e| e.size > 10 and /\d/.match(e) }`

But a number of methods, mostly pertaining to strings, are based more directly on the use of regular expressions. We’ll look at several of them in this section.
但很多methods， 大多与string相关，而且直接与 regexp 的使用相关，后面我们会提到。

-

String#scan

-

The scan method goes from left to right through a string, testing repeatedly for a match with the pattern you specify. The results are returned in an array.

For example, if you want to harvest all the digits in a string, you can do this:

`scan` 方法从做至右走访一个字串，重复匹配你给出的 pattern。 结果会推到一个 array 中。比如你想要拿到一个字串中所有的数字，你可以：

```ruby
2.5.0 :044 > "testing 1 2 3 testing 4 5 6".scan /\d/
 => ["1", "2", "3", "4", "5", "6"]
2.5.0 :045 >
```

Note that scan jumps over things that don’t match its pattern and looks for a match later in the string. This behavior is different from that of match, which stops for good when it finishes matching the pattern completely once.

注意 `scan` 方法会跳过不匹配的内容，而拿到所有能匹配的项。 这就和 `match` 不一样，只要成功匹配完一次 regexp 中的内容就会停下来。

If you use parenthetical groupings in the regexp you give to scan, the operation returns an array of arrays. Each inner array contains the results of one scan through the string:

如果你使用括号`()`capture在scan操作中，你会得到一个array 的 array。 每个内部 array 都是一个匹配

```ruby
2.5.0 :045 > str = "Leopold Auer was the teacher of Jascha Heifetz."
 => "Leopold Auer was the teacher of Jascha Heifetz."
2.5.0 :046 > violinists = str.scan(/([A-Z]\w+)\s+([A-Z]\w+)/)
 => [["Leopold", "Auer"], ["Jascha", "Heifetz"]]
2.5.0 :047 >
```

This example nets you an array of arrays, where each inner array contains the first name and the last name of a person. Having each complete name stored in its own array makes it easy to iterate over the whole list of names, which we’ve conveniently stashed in the variable violinists:

这个例子返回了一个嵌套 array， 每一个内部array中包含 first name 和 last name。 拿到 array 结果后我们就可以进行后续的枚举操作

```ruby
2.5.0 :049 > violinists.each do |fname, lname|
2.5.0 :050 >     puts "#{lname}'s first name was: #{fname}"
2.5.0 :051?> end
Auer's first name was: Leopold
Heifetz's first name was: Jascha
 => [["Leopold", "Auer"], ["Jascha", "Heifetz"]]
2.5.0 :052 >
```

nested array 还可以这样用 block parameter 表示

```ruby
2.5.0 :052 > [[1,2], [3,4]].each do |a,b|
2.5.0 :053 >     p a, b
2.5.0 :054?>   end
1
2
3
4
 => [[1, 2], [3, 4]]
2.5.0 :055 > [[1,2,3], [3,4,5]].each do |a,b,c|
2.5.0 :056 >     p a,b,c
2.5.0 :057?>   end
1
2
3
3
4
5
 => [[1, 2, 3], [3, 4, 5]]
2.5.0 :058 >
```

The regexp used for names in this example is, of course, overly simple: it neglects hyphens, middle names, and so forth. But it’s a good illustration of how to use captures with scan.

String#scan can also take a code block—and that technique can, at times, save you a step. scan yields its results to the block, and the details of the yielding depend on whether you’re using parenthetical captures. Here’s a scan-block-based rewrite of the previous code:

当然上面名字的例子太过简单，他没有处理有连字号的情况，中间名，等其他情况。但他是一个很清楚的演示。

`String#scan` 方法也可以接受一个 block，这可以节省步骤。 scan 会送出结果给 block，yield的具体情况会基于你是否在 regexp 中使用了 `()` captures。 下面是一个示例：

```ruby
2.5.0 :058 > str = "Leopold Auer was the teacher of Jascha Heifetz."
 => "Leopold Auer was the teacher of Jascha Heifetz."
2.5.0 :059 > str.scan(/([A-Z]\w+)\s+([A-Z]\w+)/) do |fname, lname|
2.5.0 :060 >     puts "#{lname}'s first name was: #{fname}."
2.5.0 :061?>   end
Auer's first name was: Leopold.
Heifetz's first name was: Jascha.
 => "Leopold Auer was the teacher of Jascha Heifetz."
2.5.0 :062 >
```

Each time through the string, the block receives the captures in an array. If you’re not doing any capturing, the block receives the matched substrings successively. Scanning for clumps of \w characters (\w is the character class consisting of letters, numbers, and underscore) might look like this

每一次通过string, block都接收到一个 array（包含first&last name）。 如果你没有用 capture ，你想拿到每一个单独的单词，你可以使用 `\w` （代表任何字母，数字，以及下划线）

```ruby
2.5.0 :070 > str.scan(/\w+/) { |e| puts "Next number: #{e}" }
Next number: Leopold
Next number: Auer
Next number: was
Next number: the
Next number: teacher
Next number: of
Next number: Jascha
Next number: Heifetz
 => "Leopold Auer was the teacher of Jascha Heifetz."
2.5.0 :071 >
```

-

另一个常用的是 split

**Even more string scanning with the StringScanner class**

The standard library includes an extension called `strscan`, which provides the StringScanner class. StringScanner objects extend the available toolkit for scanning and examining strings. A StringScanner object maintains a pointer into the string, allowing for back-and-forth movement through the string using position and pointer semantics.
Here are some examples of the methods in StringScanner:

standard library 中有一个文件叫 strscan 其中包含 StringScanner 类。 StringScanner 对象拓展了对string的操作类型，他的内部有一个指向string的指针，允许你用相关的方法来移动这个指针。

```ruby
2.5.0 :001 > require 'strscan'
 => true
2.5.0 :002 > scanner = StringScanner.new("Testing string scanning")
 => #<StringScanner 0/23 @ "Testi...">
2.5.0 :003 > scanner.scan_until(/ing/)
 => "Testing"
2.5.0 :004 > scanner.pos
 => 7
2.5.0 :005 > scanner.peek(7)
 => " string"
2.5.0 :006 > scanner.unscan
 => #<StringScanner 0/23 @ "Testi...">
2.5.0 :007 > scanner.pos
 => 0
2.5.0 :008 > scanner.skip(/Test/)
 => 4
2.5.0 :009 > scanner.rest
 => "ing string scanning"
2.5.0 :010 >
```

这里的操作有点像 enumerator 中的 next 与 rewind 操作

```ruby
2.5.0 :011 > array = %w{one two three four}
 => ["one", "two", "three", "four"]
2.5.0 :012 > enum = array.to_enum
 => #<Enumerator: ["one", "two", "three", "four"]:each>
2.5.0 :013 > enum.next
 => "one"
2.5.0 :014 > enum.next
 => "two"
2.5.0 :015 > enum.next
 => "three"
2.5.0 :016 > enum.next
 => "four"
2.5.0 :017 > enum.next
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):17
        1: from (irb):17:in `next'
StopIteration (iteration reached an end)
2.5.0 :018 > enum.rewind
 => #<Enumerator: ["one", "two", "three", "four"]:each>
2.5.0 :019 > enum.next
 => "one"
2.5.0 :020 >
```

-

**String#split**

-

如果想把一个string劈成单独的字符单位（包括空格）

```ruby
2.5.0 :022 > "Ruby language.".split(//)
 => ["R", "u", "b", "y", " ", "l", "a", "n", "g", "u", "a", "g", "e", "."]
2.5.0 :023 >
```

split is often used in the course of converting flat, text-based configuration files to Ruby data structures. Typically, this involves going through a file line by line and converting each line. A single-line conversion might look like this:

`split` 常用于将基于普通文本的配置文件，转换成Ruby数据结构的形式。这项工作需要以行未单位检视文件，然后对每一行进行操作, 对其中一行的操作可能是这样的

```ruby
2.5.0 :025 > line = "first_name=david;last_name=black;country=usa"
 => "first_name=david;last_name=black;country=usa"
2.5.0 :026 > record = line.split(/=|;/)
 => ["first_name", "david", "last_name", "black", "country", "usa"]
2.5.0 :027 >
```

然后基于这个结果我们可以将其转换为 hash

```ruby
2.5.0 :028 > data = []
 => []
2.5.0 :029 > record = Hash[*line.split(/=|;/)]
 => {"first_name"=>"david", "last_name"=>"black", "country"=>"usa"}
2.5.0 :030 > data.push record
 => [{"first_name"=>"david", "last_name"=>"black", "country"=>"usa"}]
2.5.0 :031 >
```

注意这里 array 前面的 `*` 可以将一个array变为一个 bare list

得到 hash 结果后就可以进行方便的后续操作，比如将其存入数据库等

split方法除了匹配点之外，还接受第二个参数，限制总共返回多少个对象

```ruby
2.5.0 :033 > "a,b,c,d,e,f".split(/,/, 3)
 => ["a", "b", "c,d,e,f"]
2.5.0 :034 >
```

`split` stops splitting once it has three elements to return and puts everything that’s left (commas and all) in the third string.

In addition to breaking a string into parts by scanning and splitting, you can also change parts of a string with substitution operations, as you’ll see next.

当匹配到3个对象后 split 就停止继续产生新的对象，而把第三个对象以及后面的内容合并为一个对象，让结果中保持只有一个对象，末尾的那个返回值有点类似 sponge arguments

除了扫描和劈开string，还可以对string进行匹配和替换操作

-

**sub/sub! and gsub/gsub!**

-

`sub` and `gsub` (along with their bang, in-place equivalents) are the most common tools for changing the contents of strings in Ruby. The difference between them is that `gsub` (global substitution) makes changes throughout a string, whereas `sub` makes at most one substitution.

sub 和 gsub 以及他们的bang!版本是ruby中最常见的改变string内容的工具。区别是 gsub (global sub) 会改变string中所有匹配的位置，而sub只改变第一个匹配到的位置。

Single substitutions with sub

sub takes two arguments: a regexp (or string) and a replacement string. Whatever part of the string matches the regexp, if any, is removed from the string and replaced with the replacement string:

sub 接受两个参数

```ruby
2.5.0 :001 > "typigraphical error".sub(/i/, 'o')
 => "typographical error"
2.5.0 :002 >
```

或者你可以跟一个 block 来完成，sub() 还是要跟regexp, 然后匹配结果会作为 block parameter 传入 block ，修改工作在block中完成。

```ruby
2.5.0 :004 > "capitalize the first vowel".sub(/[aeiou]/) { |m| m.upcase }
 => "cApitalize the first vowel"
2.5.0 :005 >
```

If you’ve done any parenthetical grouping, the global $n variables are set and available for use inside the block.
如果你使用了 `()` capture 那么 `$n` 变量将会在 block 中可用

```ruby
2.5.0 :009 > "capitalize the first vowel".sub(/([aeiou])/) { |m| $1.upcase }
 => "cApitalize the first vowel"
2.5.0 :010 >
```

-

global substitutions with gsub

-

```ruby
2.5.0 :012 > 'capitalize every word'.gsub(/\b\w/) { |m| m.upcase }
 => "Capitalize Every Word"
2.5.0 :013 >
```

同样如果使用 `()` 也可以在block中拿到 `$n`

-

Using the captures in a replacement string

-

You can access the parenthetical captures by using a special notation consisting of backslash-escaped numbers. For example, you can correct an occurrence of a lowercase letter followed by an uppercase letter (assuming you’re dealing with a situation where this is a mistake) like this:

你可以在参数list用 `\n` 代表 `$n`

比如下面要调换 a 和 D 的位置

```ruby
2.5.0 :017 > 'aDvid'.sub(/([a-z])([A-Z])/, '\2\1')
 => "David"
2.5.0 :018 >
```

Note the use of single quotation marks for the replacement string. With double quotes, you’d have to double the backslashes to escape the backslash character.

注意第二个参数用的是单引号，因为单引号中的`\`不用作溢出处理，如果用双引号 要学写 `"\\2\\1"`

To double every word in a string, you can do something similar, but using gsub:
你可以通过 gsub 和 capture 以及 $n 的配合，让每一个单词出现两次（把一个单词匹配放入capture中，然后用两次 `\1` 中间加空格来完成重复操作）

```  ruby
>> "double every word".gsub(/\b(\w+)/, '\1 \1')
=> "double double every every word word
```

-

A global capture variable pitfall

-

Beware: You can use the global capture variables ($1, etc.) in your substitution string, but they may not do what you think they will. Specifically, you’ll be vulnerable to leftover values for those variables. Consider this example:

注意你可以使用 capture 以及生成的 $n 来进行操作，但有时结果可能不是你想要的。具体来说，你可能漏掉一些东西，例如

```ruby
2.5.0 :020 > /(abc)/.match 'abc'
 => #<MatchData "abc" 1:"abc">
2.5.0 :021 > 'aDvid'.sub(/([a-z])([A-Z])/, "#{$2}#{$1}")
 => "abcvid"
2.5.0 :022 >
```

这里第二个参数使用的是双引号加 interpolation 的格式，但很明显上面一个匹配的 $1 串到下面来了，所以在使用 capture 时最好使用 `'\n'` 的格式。

We’ll conclude our look at regexp-based tools with two techniques having in common their dependence on the case equality operator (===): `case` statements (which aren’t method calls but which do incorporate calls to the threequal operator) and Enumerable#grep.

作为结尾我们会看两个基于regexp的工具，他们都建立在 case equality operator 也就是 `===` 的基础之上： 那就是 case 声明以及 Enumerable#grep 方法。

**Case equality and grep**

As you know, all Ruby objects understand the === message. If it hasn’t been overridden in a given class or for a given object, it’s a synonym for ==. If it has been overridden, it’s whatever the new version makes it be.
所有的ruby objects都了解 `===` message。
```ruby
2.5.0 :024 > Object.new.respond_to?(:===)
 => true
2.5.0 :025 > "string".respond_to?(:===)
 => true
2.5.0 :026 > 1000.respond_to?(:===)
 => true
2.5.0 :027 > Array.new.respond_to?(:===)
 => true
2.5.0 :028 > Object.respond_to?(:===)
 => true
2.5.0 :029 > String.respond_to?(:===)
 => true
2.5.0 :030 > Integer.respond_to?(:===)
 => true
2.5.0 :031 > Array.respond_to?(:===)
 => true
2.5.0 :032 >
```
一个class中如果没有重写 `===` 那么他和 `==` 的意思是一样的。如果需要，任何一个class中都可以按自己的需求重写他。

Case equality for regular expressions is a match test: for any given regexp and string, regexp === string is true if string matches regexp. You can use === explicitly as a match test:

`===` case equality 对于 正则表达式来说是一个匹配测试方法： 给定任意 regexp 或 string 对象都可以用 `===` 进行匹配测试，return值是 true / false

```ruby
2.5.0 :041 > re.match string
 => #<MatchData "ab">
2.5.0 :042 > re === string
 => true
2.5.0 :043 > re =~ string
 => 0
2.5.0 :044 >
```
**注意return值的区别**

And, of course, you have to use whichever test will give you what you need: nil or MatchData object for match; nil or integer offset for =~; true or false for ===.

In case statements, === is used implicitly. To test for various pattern matches in a case statement, proceed along the following lines:

具体哪一种return值方便你的操作，你就选择哪一个方法。

在 `case` 条件式中， `===` 也被用到了。

```ruby
print "Continue? (y/n) "
answer = gets
case answer
when /^y/i
  puts "Great!"
when /^n/i
  puts "Bye!"
  exit
else
  puts "Huh?"
end
```

每一次使用 when 其实都是在 `/regexp/ === answer`

The other technique you’ve seen that uses the === method/operator, also implicitly, is `Enumerable#grep`. You can refer back to section 10.3.3. Here, we’ll put the spotlight on a couple of aspects of how it handles strings and regular expressions.
另一个使用到了 `===` 的操作是 `Enumerable#grep` 方法。我们看看他怎么处理 regexp 和 string。

```ruby
= Enumerable.grep

(from ruby site)
------------------------------------------------------------------------------
  enum.grep(pattern)                  -> array
  enum.grep(pattern) { |obj| block }  -> array

------------------------------------------------------------------------------

Returns an array of every element in enum for which Pattern ===
element. If the optional block is supplied, each matching element is
passed to it, and the block's result is stored in the output array.

  (1..100).grep 38..44   #=> [38, 39, 40, 41, 42, 43, 44]
  c = IO.constants
  c.grep(/SEEK/)         #=> [:SEEK_SET, :SEEK_CUR, :SEEK_END]
  res = c.grep(/SEEK/) { |v| IO.const_get(v) }
  res                    #=> [0, 1, 2]

(END)
```

`grep` does a filtering operation from an enumerable object based on the case equality operator (===), returning all the elements in the enumerable that return a true value when threequaled against `grep`’s argument. Thus if the argument to `grep` is a regexp, the selection is based on pattern matches, as per the behavior of `Regexp#===``:

`grep`方法基于 `===` 对能够枚举的对象进行过滤操作，所有匹配内容所在的element会放到一个 array 中。

```ruby
2.5.0 :003 > countries = %w[USA UK France Germany]
 => ["USA", "UK", "France", "Germany"]

2.5.0 :005 > countries.grep(/[a-z]/)
 => ["France", "Germany"]
2.5.0 :006 >
```
注意最后放进array的是一整个element而不是匹配到的单个字符，array每次拿一个element出来匹配 regexp 只要匹配成功，这个element就会被推到新的 array 中。

我们可以使用 select 达成同样的效果，不过稍微啰嗦一点

```ruby
2.5.0 :010 > countries.select { |e| /[a-z]/ === e }
 => ["France", "Germany"]
2.5.0 :011 >
```

你还可以在 grep() 后接block 对匹配到的 elements 做加工

```ruby
2.5.0 :011 > countries.grep(/[a-z]/) { |m| m.upcase }
 => ["FRANCE", "GERMANY"]
```

Keep in mind that grep selects based on the case equality operator (===), so it won’t select anything other than strings when you give it a regexp as an argument—and there’s no automatic conversion between numbers and strings. Thus if you try this

要记住 grep 操作是基于 `===` 所以当你用 regexp 作为匹配的一方时，另一方不能是除 string 以外的其他对象，因为regexp本身就是针对字串的操作

```ruby
2.5.0 :013 > [1,2,3].grep /1/
 => []
2.5.0 :014 > ['1',2,3].grep /1/
 => ["1"]
2.5.0 :015 >
```

-

## Summary

In this chapter you’ve seen


- The underlying principles behind regular expression pattern matching
regexp 匹配的底层原则

- The match and =~ techniques 前者返回matchdata object， 后者返回匹配开始处的序号

- Character classes 字符清单

- Parenthetical captures ()作为capture

- Quantifiers 量词 `?`0个或1个，`*`0个或多个, `+`1个或多个

- Anchors 锚，规定匹配发生的具体位置

- MatchData objects 各种拿取匹配结果的方法

- String/regexp interpolation and conversion 二者转换过程中的一些需要注意的点

- Ruby methods that use regexps: scan, split, grep, sub, gsub 那些使用到 regexp 的文本操作方法
