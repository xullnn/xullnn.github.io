---
title:  "Rubyist-c12-File and IO operations"
categories: [Ruby/Rails ℗]
tags: [Ruby & Rails, Notes of Rubyist]
---

*注：这一系列文章是《The Well-Grounded Rubyist》的学习笔记。*



---

This chapter covers
 
* Keyboard input and screen output
键盘输入与屏幕输出

* The IO and File classes
IO 与 File 类

* Standard library file facilities, including FileUtils and Pathname
standard library 中的文件处理功能，包裹 FileUtils 和 Pathname

* The StringIO and open-uri library features
StringIO 与 open-uri 库

As you’ll see once you dive in, Ruby keeps even file and I/O operations object-oriented. Input and output streams, like the standard input stream or, for that matter, any file handle, are objects. Some I/O-related commands are more procedural: puts, for example, or the system method that lets you execute a system command. But puts is only procedural when it’s operating on the standard output stream. When you puts a line to a file, you explicitly send the message “puts” to a File object.

随着学习的深入，我们会发现 ruby 的 文件层面 和 I / O 操作 都是面向对象风格的。输入和输出流，比如标准的输出流或者说任何的文件操作都是对象。有些 I / O 相关的命令更加具有程序性： 比如说 puts , 或者系统相关的method 。 但是 puts 只在它作为标准输出流时表现出这种程序性。当你对一个 文件file puts 一行内容时，你实际上是在 用 puts 送出一行 message 给一个 File 对象。


The memory space of a Ruby program is a kind of idealized space, where objects come into existence and talk to each other. Given the fact that I/O and system command execution involve stepping outside this idealized space, Ruby does a lot to keep objects in the mix.

Ruby程式的内存空间类似一种理想的空间场所，objects可以在这里存在并相互交谈。  但涉及到 I / O 和 系统system 层面的操作，不可避免的要踏出这个理想的空间， ruby 为了在这种情况下保持面向对象性做出了很多努力。


You’ll see more discussion of standard library (as opposed to core) packages in this chapter than anywhere else in the book. That’s because the file-handling facilities in the standard library—highlighted by the FileUtils, Pathname, and StringIO packages—are so powerful and so versatile that they’ve achieved a kind of quasi-core status. The odds are that if you do any kind of file-intensive Ruby programming, you’ll get to the point where you load those packages almost without thinking about it.

在这章里，你会比在书中其他地方更多地看到 关于 standard library 的讨论。这是因为 FileUtils, Pathname , StringIO 这些库所提供的关于文件层面的操作是十分强大的，其用途接近准core 的程度。更多的可能性是如果你会在你的ruby程序中频繁用到文件层面的操作，那么你几乎想也不会想的就引入这些相关的库。

-

**How Ruby’s I / O systems is put together**
Ruby I/O 系统是如何构成的

-

The IO class handles all input and output streams either by itself or via its descendant classes, particularly File. To a large extent, IO’s API consists of wrappers around system library calls, with some enhancements and modifications. The more familiar you are with the C standard library, the more at home you’ll feel with methods like seek, getc, and eof?. Likewise, if you’ve used another high-level language that also has a fairly close-fitting wrapper API around those library methods, you’ll recognize their equivalents in Ruby. But even if you’re not a systems or C programmer, you’ll get the hang of it quickly.

`class IO` 或者他的子类特别是 `class File` 负责处理所有的输入输出流。大范围上看， IO 的API从系统层面借用了很多东西，在此基础上进行了一些修改和提升。如果你对 [C standard library](https://en.wikipedia.org/wiki/C_standard_library)很熟悉的话你就会发现跟 `seek`, `getc`, `eof?` 这些方法很熟悉。 但如果你使用的另一种高级语言但同样使用的是从libc中借用的方法，你会发现他们和 ruby 中对应的方法很相似。 但是即使你不是一个系统开发者或者C语言使用者，你也会很快上手。

-

**The IO class**

```ruby
2.5.0 :001 > File.ancestors
 => [File, IO, File::Constants, Enumerable, Object, Kernel, BasicObject]
2.5.0 :002 >
```

IO objects 代表可读或可写的，与磁盘，键盘，屏幕以及其他设备的**连接**。你可以像对待其他 object 那样对待他，向它送出信息，然后他return 值给你。

当一个ruby程序开始运行时， 它就明白什么是 标准输入 与 输出 以及 错误流。 这三种流都被封装在 IO 的实例instances当中。

```ruby
2.5.0 :002 > STDERR.class
 => IO
2.5.0 :003 > STDERR.puts 'Problem!'
Problem!
 => nil
2.5.0 :004 > STDERR.write 'Problem!\n'
Problem!\n => 10
2.5.0 :005 >
```

STDERR - standard error

STDIN - standard input

STDOUT - standard output

这是三个常量只要程序一开始就已经设置好了。STDERR是一个 IO object. 如果一个 IO object 被打开，你就可以使用 puts 来向他写入信息，无论你送出什么信息都会写到 这个 IO object 的输出流中。

除了 puts , IO objects 还有 print 和 write 方法。如果你 write 信息给一个 IO object, 不会出现自动换行的输出，会在你写入的信息后跟上信息的长度。

IO 作为一个 ruby class , 很自然地会 混入 module, 值得一提的是，混入了 Enumerable module, 因此 IO object 是可以枚举的。

-

**IO objects as enumerables**
作为可枚举对象的IO objects

-

An enumerable, as you know, must have an each method so that it can iterate. IO objects iterate based on the global input record separator, which, as you saw in connection with strings and their each_line method in section 10.7, is stored in the global variable $/.
如我们之间提到的，一个可枚举的对象，必须有自己的`each`逻辑，他才能进行迭代操作。 IO对象的迭代操作基于全域的输入分隔符，也就是之前我们在对string使用`each_line`时看到的 `$/` 也就是换行符号。
```ruby
2.5.0 :006 > $/
 => "\n"
```

```ruby
2.5.0 :007 > STDIN
 => #<IO:<STDIN>>
2.5.0 :008 > STDIN.object_id
 => 70200548658380
2.5.0 :009 > STDIN.object_id
 => 70200548658380
2.5.0 :010 > STDIN.object_id
 => 70200548658380
2.5.0 :011 >
```

STDIN 作为constant 他的id不变，但可以看到它是 IO 的实例对象

In the following examples, Ruby’s output is indicated by bold type; regular type indicates keyboard input. The code performs an iteration on STDIN, the standard input stream. (We’ll look more closely at STDIN and friends in the next section.) At first, STDIN treats the newline character as the signal that one iteration has finished; it thus prints each line as you enter it:

下面的例子演示了一次对 STDIN 的迭代操作，也就是standard input流。首先 STDIN 会把换行符号作为一步迭代的结束标志，这样他印出的就和你当初输入的相同：

```ruby
2.5.0 :013 > STDIN.each { |line| p line }
This is line 1
"This is line 1\n"
This is line 2
"This is line 2\n"
All seperated by $/, which is a newline character
"All seperated by $/, which is a newline character\n"
```

正常情况下ruby 在进行 STDIN 的iteration 操作时，每次键入 回车键 都会被识别为 line 的分隔标志

但如果我们像上次一样把 $/ 的值改一下  改成字串 “NEXT”

```ruby
2.5.0 :003 > $/
 => "\n"
2.5.0 :004 > $/ = "-NEXT-"
 => "-NEXT-"
2.5.0 :005 > STDIN.each { |line| p line }
This is the first line.  # entered return button
                         # entered return button
                         # entered return button
This is the fourth line.
Until I write -NEXT-
"This is the first line.\n\n\nThis is the fourth line.\nUntil I write -NEXT-"
```

注意中间的的两个空行加上第一行末尾的换行符号，虽然每一次换行都向字串中加入了一个 `\n` 但ruby已经不再把他作为溢出的换行标志，而成为了内容的一部分，只有当你手动输入 `-NEXT-` 时，实际换行才会发生，之前所有的内容才会被作为一行来解读，虽然看起来敲击了多次回车，但回车只是向内容中加入 `/n` ，在 `$/` 被修改以后已经不作为换行标志。

So $/ determines an IO object’s sense of “each.” And because IO objects are enumerable, you can perform the usual enumerable operations on them. (You can assume that $/ has been returned to its original value in these examples.)

$/ 的值决定了 IO object 关于 each 的认识，由于 IO objects 具有可枚举性，那我们也可以对其使用常用的枚举操作。下面的例子中 $/ 的值已经被还原为默认值

The ^D notation indicates that the typist entered Ctrl-d at that point:

敲击 control D 来完成输入

```ruby
2.5.0 :002 > STDIN.select { |line| line =~ /\A[A-Z]/ }
We're only interested in
lines that begin with
Uppercase letters.
 => ["We're only interested in\n", "Uppercase letters.\n"]
2.5.0 :003 > STDIN.map { |line| line.reverse }
senil esehT
terces a niatnoc
.egassem
 => ["\nThese lines", "\ncontain a secret", "\nmessage."]
2.5.0 :004 >
```

—-

**STDIN, STDOUT, STDERR**

STDIN, STDOUT, STDERR对象
—-

If you’ve written programs and/or shell scripts that use any kind of I/O piping, then you’re probably familiar with the concept of the standard input, output, and error streams. They’re basically defaults: unless told otherwise, Ruby assumes that all input will come from the keyboard, and all normal output will go to the terminal. Assuming, in this context, means that the unadorned, procedural I/O methods, like puts and gets, operate on STDOUT and STDIN, respectively.
Error messages and STDERR are a little more involved. Nothing goes to STDERR unless someone tells it to. So if you want to use STDERR for output, you have to name it explicitly:

如果你已经使用过 I / O 相关的命令行，你应该对 standard input , output , error 三种 streams 有所了解，他们都是默认设置，除非人为进行其他设置，ruby默认所有 input 都来自键盘，所有 output 都输出到 terminal 终端。在这种假设下， puts 对应的 STDOUT ， gets 对应的 STDIN 。

错误流  STDERR 的情况稍微复杂一些，如果没有送任何信息给它， 它不会有任何输出，除非你明确指定错误信息给他

```ruby
if condition
  STDERR.puts "There's a problem."
end
```

In addition to the three constants, Ruby also gives you three global variables: $stdin, $stdout, and $stderr.

除了上面提到的 3 个常量对象， Ruby 也给出了三个 global variables

```
$stdin
$stdout
$stderr
```

—-

**The standard I/O global variables**

—-

$stdin 对应 STDIN

$stdout  对应 STDOUT

$stderr 对应 STDERR

```ruby
2.5.0 :003 > $stdin
 => #<IO:<STDIN>>
2.5.0 :004 > $stdout
 => #<IO:<STDOUT>>
2.5.0 :005 > $stderr
 => #<IO:<STDERR>>
2.5.0 :006 > $stdin == STDIN
 => true
2.5.0 :007 > $stdout == STDOUT
 => true
2.5.0 :008 > $stderr == STDERR
 => true
```

之前说过 ruby 默认情况下会将所有输出指向 terminal

如果现在我们想要把所有的 输出  以及 错误信息输出 都写进一个文件，那么我们可以直接修改 上面提到的 $stdout 和 $stderr 的指向来实现

```ruby
2.5.0 :001 > new_path = File.open("./record", "w")
 => #<File:./record>
2.5.0 :002 > old_stdout = $stdout
 => #<IO:<STDOUT>>
2.5.0 :003 > $stdout = new_path   # things changed at this moment
2.5.0 :004 > z = 10/0
2.5.0 :005 > $stderr = $stdout
2.5.0 :006 > puts "Now puts method will not show you anything in terminal."
2.5.0 :007 > puts "So as an error message"
2.5.0 :008 > z = 10/0
2.5.0 :009 > new_path.close
```

从第3行那里开始terminal 中不再印出return值，所有的内容都被输出到了指定的文件对象中

```ruby
=> #<File:./record>   # First stdout after changing path
[1mTraceback[m (most recent call last):
       3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
       2: from (irb):4
       1: from (irb):4:in `/'
[1mZeroDivisionError ([4mdivided by 0[0;1m)[m
=> #<File:./record>
Now puts method will not show you anything in terminal.
=> nil
So as an error message
=> nil
[1mTraceback[m (most recent call last):
       3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
       2: from (irb):8
       1: from (irb):8:in `/'
[1mZeroDivisionError ([4mdivided by 0[0;1m)[m
```

改变输出路径后，所有原本应该在 terminal 中印出的信息都转而输出到了指定的这个文件中。

![](https://ws1.sinaimg.cn/large/006tKfTcgy1foccyau1e0j30bz01uaa8.jpg)

old_stdout 是为了保存原始的变量值

$stdout = new_path 让标准输出不再指向 terminal 而是指向 new_path 包含的文件对象


Of course, you can also send standard output to one file and standard error to another. The global variables let you manipulate the streams any way you need to.

当然，使用上面的方法我们也可以将 标准输出 和 错误信息输出 导向两个不同的地方


—-

**A little more about keyboard input**

—

关于键盘输入，键盘输入的实现大多数情况下是使用  gets 和 getc， getc 只拿一个 character

还有一点不同的是

我们可以直接使用

gets 拿到一行输入值

但无法直接使用 getc 拿到字符输入，而必须加上 STDIN ，使用 STDIN.getc

在两个例子中，输入的信息都被缓存了，敲击回车键后，输入才会确认。

If for some reason you’ve got $stdin set to something other than the keyboard, you can still read keyboard input by using STDIN explicitly as the receiver of gets:

像之前示范的那样，如果你将 $stdin 设为了其他值，你仍然可以使用 STDIN.gets 接受来自 键盘 的输入， 即使 $stdin 被修改了

Assuming you’ve followed the advice in the previous section and done all your standard I/O stream juggling through the use of the global variables rather than the constants, STDIN will still be the keyboard input stream, even if $stdin isn’t.


```ruby
2.5.0 :001 > lines = gets
"Using gets to get a line"
 => "\"Using gets to get a line\"\n"
2.5.0 :002 > lines
 => "\"Using gets to get a line\"\n"
2.5.0 :003 > char = getc
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):3
NameError (undefined local variable or method `getc' for main:Object
Did you mean?  gets)
2.5.0 :004 > char = STDIN.getc
No quotation mark arround
 => "N"
2.5.0 :005 > char
 => "N"
2.5.0 :006 > char = STDIN.getc
 => "o"
2.5.0 :007 > char = STDIN.getc
 => " "
2.5.0 :008 > char = STDIN.getc
 => "q"
2.5.0 :009 >
```

—

**Basic file operations**

—

The built-in class File provides the facilities for manipulating files in Ruby. File is a subclass of IO, so File objects share certain properties with IO objects, although the File class adds and changes certain behaviors.

ruby内建的 File class提供了我们文件操作的功能。File是IO的子类，所以 File 的实例具有特定的 IO 特性，当然 File 也添加了一些变化。


We’ll look first at basic file operations, including opening, reading, writing, and closing files in various modes. Then, we’ll look at a more “Rubyish” way to handle file reading and writing: with code blocks. After that, we’ll go more deeply into the enumerability of files, and then end the section with an overview of some of the common exceptions and error messages you may get in the course of manipulating files.

我们将会首先着眼于基本的 file 操作，包括（各种模式下的） 打开，读取，写入，关闭 。
接着我们将会了解如何以更加 Rubyish 的方式进行file读写：使用 block 。 最后我们将会深入关于 file 的 enumerability 枚举特性的内容，以及常见的进行文件操作时的报错信息。

—-

The basics of reading from files

Reading from a file can be performed one byte at a time, a specified number of bytes at a time, or one line at a time (where line is defined by the $/ delimiter). You can also change the position of the next read operation in the file by moving forward or backward a certain number of bytes or by advancing the File object’s internal pointer to a specific byte offset in the file.

我们可以一次只读取文件中一个字节的内容，或指定长度的内容，或者一次一行（依赖于$/作为分隔符）。我们也可以改变读取的指针，向前或向后移动指定个字符的位置。

新建一个 File 实例的最直观方法是使用 File.new

如果文件不存在，将会报错

```ruby
2.5.0 :010 > f = File.new('/rubyist/nonexist.rb')
Traceback (most recent call last):
        4: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        3: from (irb):10
        2: from (irb):10:in `new'
        1: from (irb):10:in `initialize'
Errno::ENOENT (No such file or directory @ rb_sysopen - /rubyist/nonexist.rb)
2.5.0 :011 >
```

With no associated block, File.open is a synonym for ::new. If the optional code block is given, it will be passed the opened file as an argument and the File object will automatically be closed when the block terminates. The value of the block will be returned from File.open.

If a file is being created, its initial permissions may be set using the perm parameter. See ::new for further discussion.

如果没有给出关联的 block， File.open 和 File.new 是同义的。如果给出的 block，那么file对象将会作为 parameter argument 传入 block，在block执行完成后，文件对象将自动执行 close 动作不再需要手动执行。

假设 file 已经存在，你将得到一个可读的文件

现在有这个文件 /rubyist/code/ticket2.rb

使用 File.new(#file_path) 拿到这个 文件对象 后，有很多method 可以输出文件中的内容，比如使用 read, 会以一行字串的格式输出文件内容

(If the file doesn’t exist, an exception will be raised.) At this point, you can use the file instance to read from the file. A number of methods are at your disposal. The absolute simplest is the read method; it reads in the entire file as a single string:

```ruby
2.5.0 :004 > f = File.new('/Users/caven/Notes & Articles/Note of Rubyist/code examples/ticket2.rb')
 => #<File:/Users/caven/Notes & Articles/Note of Rubyist/code examples/ticket2.rb>
2.5.0 :005 > f.read
 => "class Ticket\n  def initialize(venue, date)\n    @venue = venue\n    @date = date\n  end\n\n  def price=(price)\n    @price = price\n  end\n\n  def venue\n    @venue\n  end\n\n  def date\n    @date\n  end\n\n  def price\n    @price\n  end\nend\n"
2.5.0 :006 >
```

at your disposal
任意使用；任你自由支配；听你差遣

这是 ticket2.rb 中原本的内容

```ruby
class Ticket
  def initialize(venue, date)
    @venue = venue
    @date = date
  end

  def price=(price)
    @price = price
  end

  def venue
    @venue
  end

  def date
    @date
  end

  def price
    @price
  end
end
```

Although using read is tempting in many situations and appropriate in some, it can be inefficient and a bit sledgehammer-like when you need more granularity in your data reading and processing.
We’ll look here at a large selection of Ruby’s file-reading methods, handling them in groups: first line-based read methods and then byte-based read methods.

虽然 .read 很简单，但是它不能提供很好的输出结构，下面会讲到一些文件读取方法，有基于 line 的，有基于 字节 的。

—-

Close your file handles

—-
When you’re finished reading from and/or writing to a file, you need to close it. File objects have a close method (for example, f.close) for this purpose. You’ll learn about a way to open files so that Ruby handles the file closing for you, by scoping the whole file operation to a code block. But if you’re doing it the old-fashioned way, as in the examples involving File.new in this part of the chapter, you should close your files explicitly. (They’ll get closed when you exit irb too, but it’s good practice to close the ones you’ve opened.)

当我们 读完 或者 写完 一个文件时，你需要关闭他。 File 对象有 close 方法来完成，比如上面的例子使用 f.close。 我们将会提到使用 block 来处理文件 ruby 会自动帮你 关闭 文件。但如果你偏爱使用 File.new 这种方式，记得要关闭，虽然在我们退出 irb 后， ruby 也会自动关闭文件，但是主动记得在编辑后关闭任然是好习惯。

—-


**Line-based file reading**

基于 行 的文件读取

—-

gets  方法读取文件中的下一行

readline也可以读下一行，它和 gets 的区别在于， gets 读到文件末尾时返回 nil, 前者则会报错 fatal error

```ruby
2.5.0 :007 > f.gets
 => nil
2.5.0 :008 > f.rewind
 => 0
2.5.0 :009 > f.read
 => "class Ticket\n  def initialize(venue, date)\n    @venue = venue\n    @date = date\n  end\n\n  def price=(price)\n    @price = price\n  end\n\n  def venue\n    @venue\n  end\n\n  def date\n    @date\n  end\n\n  def price\n    @price\n  end\nend\n"
2.5.0 :010 > f.gets
 => nil
2.5.0 :011 > f.readline
Traceback (most recent call last):
        3: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        2: from (irb):11
        1: from (irb):11:in `readline'
EOFError (end of file reached)
2.5.0 :012 >
```

前面对 f 对象使用了 read 读完了整个文件，指针已经到了末尾，所以gets会是nil， file对象也有 rewind 倒带方法

```ruby
2.5.0 :012 > f.rewind
 => 0
2.5.0 :013 > f.gets
 => "class Ticket\n"
2.5.0 :014 > f.gets
 => "  def initialize(venue, date)\n"
2.5.0 :015 > f.readline
 => "    @venue = venue\n"
2.5.0 :016 >
```

If you want to get the entire file at once as an array of lines, use readlines (a close relative of read). Note also the rewind operation, which moves the File object’s internal position pointer back to the beginning of the file:

readlines(注意复数)可以一次将所有行放入一个 array 一行就是一个 element

```ruby
2.5.0 :016 > f.readlines
 => ["    @date = date\n", "  end\n", "\n", "  def price=(price)\n", "    @price = price\n", "  end\n", "\n", "  def venue\n", "    @venue\n", "  end\n", "\n", "  def date\n", "    @date\n", "  end\n", "\n", "  def price\n", "    @price\n", "  end\n", "end\n"]
2.5.0 :017 > f.readlines.class
 => Array
2.5.0 :018 >
```


Keep in mind that File objects are enumerable. That means you can iterate through the lines one at a time rather than reading the whole file into memory. The each method of File objects (also known by the synonym each_line) serves this purpose:

不要忘记 File 对象具有可枚举性，这意味着我们可以一步一步进行迭代操作，而不是每次都要一次性读完一个文件。 使用 File class 中的 each 或者 each_line 就可以达到这个目的

```ruby
2.5.0 :019 > f.rewind
 => 0
2.5.0 :020 > f.each { |line| puts "Next line is: #{line}" }
Next line is: class Ticket
Next line is:   def initialize(venue, date)
Next line is:     @venue = venue
Next line is:     @date = date
Next line is:   end
Next line is:
Next line is:   def price=(price)
Next line is:     @price = price
Next line is:   end
Next line is:
Next line is:   def venue
Next line is:     @venue
Next line is:   end
Next line is:
Next line is:   def date
Next line is:     @date
Next line is:   end
Next line is:
Next line is:   def price
Next line is:     @price
Next line is:   end
Next line is: end
 => #<File:/Users/caven/Notes & Articles/Note of Rubyist/code examples/ticket2.rb>
2.5.0 :021 >
```

-

**Byte- and character-based file reading**

字节 以及 字符粒度的 file 读取

-

f.getc 可以拿到下一个 character 字符

```ruby
2.5.0 :023 > f.rewind
 => 0
2.5.0 :024 > f.getc
 => "c"
2.5.0 :025 > f.ungetc("X")
 => nil
2.5.0 :026 > f.gets
 => "Xlass Ticket\n"
2.5.0 :027 >
```

ungetc 会送到给定字符给之前的那个位置，这部分变化的内容会存在缓存中
不会对文件内容本身有改变

```ruby
= File.ungetc

(from ruby site)
=== Implementation from IO
------------------------------------------------------------------------------
  ios.ungetc(string)   -> nil

------------------------------------------------------------------------------

Pushes back one character (passed as a parameter) onto ios, such that a
subsequent buffered character read will return it. Only one character may be
pushed back before a subsequent read operation (that is, you will be able to
read only the last of several characters that have been pushed back). Has no
effect with unbuffered reads (such as IO#sysread).

  f = File.new("testfile")   #=> #<File:testfile>
  c = f.getc                 #=> "8"
  f.ungetc(c)                #=> nil
  f.getc                     #=> "8"


(END)
```
Every character is represented by one or more bytes. How bytes map to characters depends on the encoding. Whatever the encoding, you can move byte-wise as well as character-wise through a file, using getbyte. Depending on the encoding, the number of bytes and the number of characters in your file may or may not be equal, and getc and getbyte, at a given position in the file, may or may not return the same thing.

每一个字符 character 占用一个或多个字节，这取决于当前字符集使用的编码。不管是什么编码，ruby中都可以进行字节粒度上的操作，以某一个指针位置作为起始点，一个字节的内容和 一个字符的内容 可能是一样的 也可能是不一样的

```ruby
2.5.0 :032 > f.readchar
 => "d"
2.5.0 :033 > f.readbyte
 => 101
2.5.0 :034 >
```

readchar  和 readbyte 在读到文件对象末尾时，都会报错。

“指针”的存在说明 File object 是对自己内部指向的位置有记录追踪的。

—-

**Seeking and querying file position**

—-

The File object has a sense of where in the file it has left off reading. You can both read and change this internal pointer explicitly, using the File object’s pos (position) attribute and/or the seek method.

File 对象有一个 pos (position) 属性，以及 seek 方法来处理内部指针位置

```ruby
2.5.0 :035 > f.rewind
 => 0
2.5.0 :036 > f.pos
 => 0
2.5.0 :037 > f.gets
 => "class Ticket\n"
2.5.0 :038 > f.pos
 => 13
2.5.0 :039 >
```

使用gets 读取一行之后 指针位置从起始位置0 变为了13

0 到 13 这个长度是以 byte 字节为单位的，我们可以手动指定位置

```ruby
2.5.0 :039 > f.pos = 7
 => 7
2.5.0 :040 > f.readline
 => "icket\n"
2.5.0 :041 >
```

直接使用 pos =  赋值操作

seek 方法配合 几个(位置)常量可以进行三种操作

1 指定相对于开头的位置，f.seek(20, IO::SEEK_SET) 。也可以直接 f.seek(20) 或使用 pos=

2 指定相对于当前位置的位置， f.seek(5, IO::SEEK_CUR)

3 指定相对于末尾的位置， f.seek(-10, IO::SEEK_END)

注意最后一行 使用的数字是 负值

```ruby
2.5.0 :041 > f.rewind
 => 0
2.5.0 :042 > f.seek(20)
 => 0
2.5.0 :043 > f.pos
 => 20
2.5.0 :044 > f.seek(5, IO::SEEK_CUR)
 => 0
2.5.0 :045 > f.pos
 => 25
2.5.0 :046 > f.seek(-10, IO::SEEK_END)
 => 0
2.5.0 :047 > f.pos
 => 213
2.5.0 :048 >
```

—-

之前的很多方法都是 IO 这个 class 中的， 实际上 File 这个 class 本身也有针对其实例的读取方法

**Reading files with File class methods**

A little later, you’ll see more of the facilities available as class methods of File. For now, we’ll look at two methods that handle file reading at the class level: File.read and File.readlines.

先看两个  class 层级的 methods

File.read 和 File.readlines

In the first case, you get a string containing the entire contents of the file. In the second case, you get an array of lines.
These two class methods exist purely for convenience. They take care of opening and closing the file handle for you; you don’t have to do any system-level housekeeping. Most of the time, you’ll want to do something more complex and/or more efficient than reading the entire contents of a file into a string or an array at one time. Given that even the read and readlines instance methods are relatively coarse-grained tools, if you decide to read a file in all at once, you may as well go all the way and use the class-method versions.

这个两个方法和之前提到的 read, readlines方法的功能相同，他们的存在只是为了简化操作。使用这个两个 class 层级的方法，我们可以不用先使用 File.new 实例化一个 File 对象，在对其进行读取操作。我们可以直接使用这两个 class methods 进行读取

```ruby
2.5.0 :001 > f = File.read("/Users/caven/Notes & Articles/Note of Rubyist/code examples/ticket2.rb")
 => "class Ticket\n  def initialize(venue, date)\n    @venue = venue\n    @date = date\n  end\n\n  def price=(price)\n    @price = price\n  end\n\n  def venue\n    @venue\n  end\n\n  def date\n    @date\n  end\n\n  def price\n    @price\n  end\nend\n"
2.5.0 :002 > f.class
 => String
2.5.0 :003 > ff = File.readlines("/Users/caven/Notes & Articles/Note of Rubyist/code examples/ticket2.rb")
 => ["class Ticket\n", "  def initialize(venue, date)\n", "    @venue = venue\n", "    @date = date\n", "  end\n", "\n", "  def price=(price)\n", "    @price = price\n", "  end\n", "\n", "  def venue\n", "    @venue\n", "  end\n", "\n", "  def date\n", "    @date\n", "  end\n", "\n", "  def price\n", "    @price\n", "  end\n", "end\n"]
2.5.0 :004 > ff.class
 => Array
2.5.0 :005 >
```

—

**Low level I / O methods**

底层的 I/O 方法

—

```
sysseek
sysread
syswrite
```

这三个 method 是系统层级的方法，sys- 类方法执行的是原生的，未缓存的数据，不要将他们与高层级的方法混起来使用。

比如 print 等

—-

Writing to files

—-


Writing to a file involves using puts, print, or write on a File object that’s opened in write or append mode. Write mode is indicated by w as the second argument to new. In this mode, the file is created (assuming you have permission to create it); if it existed already, the old version is overwritten. In append mode (indicated by a), whatever you write to the file is appended to what’s already there. If the file doesn’t exist yet, opening it in append mode creates it.

写入信息到一个文件会 对一个 以 write 或 append 模式打开的文件对象 使用 puts print write 方法。

w  代表 write only 模式, 作为 File.new 的第二个参数

在这个模式下，如果文件不存在，那么会新建一个文件，如果存在，那么旧文件中的内容会被写入的新内容直接覆盖掉。

在 a (append) 模式下，如果文件不存在，也会创建新文件，如果已经有同名文件，那么写入的内容将会 附加在已有内容之后。

注意在不给出第二个参数(mode)时，使用不存在的文件名将会报错

```ruby
2.5.0 :005 > f = File.new("data.out", "w")
 => #<File:data.out>
2.5.0 :006 > f.puts "David A. Black, Rubyist"
 => nil
2.5.0 :007 > f.close
 => nil
2.5.0 :008 > puts File.read("data.out")
David A. Black, Rubyist
 => nil
2.5.0 :009 > f = File.new("data.out", "a")
 => #<File:data.out>
2.5.0 :010 > f.puts "This time open f with 'a' mode."
 => nil
2.5.0 :011 > f.close
 => nil
2.5.0 :012 > puts File.read("data.out")
David A. Black, Rubyist
This time open f with 'a' mode.
 => nil
2.5.0 :013 >
```

Ruby lets you economize on explicit closing of File objects—and enables you to keep your code nicely encapsulated—by providing a way to perform file operations inside a code block. We’ll look at this elegant and common technique next.

Ruby 让我们可以使用block 来简化 关闭文件的操作


—-

**Using blocks to scope file operations**

—-

使用 File.new 来创建 file object 有一个缺点是每次都需要手动关闭文件。ruby 为此提供的方案是 使用 File.open 加 block 的组合，block 执行完毕后会自动关闭文件。

现在我们有这样一个文件 records.txt

```ruby
Pablo Casals|Catalan|cello|1876-1973
Jascha Heifetz|Russian-American|violin|1901-1988
Emanuel Feuermann|Austrian-American|cello|1902-1942
```

进行如下操作

```ruby
2.5.0 :001 > File.open("records.txt") do |f|  # records.txt is being in current directory
2.5.0 :002 >     while record = f.gets
2.5.0 :003?>     name, nationality, instrument, dates = record.chomp.split('|')
2.5.0 :004?>     puts "#{name} (#{dates}), who was #{nationality}, played #{instrument}."
2.5.0 :005?>     end
2.5.0 :006?>   end
Pablo Casals (1876-1973), who was Catalan, played cello.
Jascha Heifetz (1901-1988), who was Russian-American, played violin.
Emanuel Feuermann (1902-1942), who was Austrian-American, played cello.
 => nil
2.5.0 :007 >
```

The program consists entirely of a call to File.open along with its code block. (If you call File.open without a block, it acts like File.new.) The block parameter, f, receives the File object. Inside the block, the file is read one line at a time using f. The while test succeeds as long as lines are coming in from the file. When the program hits the end of the input file, gets returns nil, and the while condition fails.
Inside the while loop, the current line is chomped so as to remove the final newline character, if any, and split on the pipe character. The resulting values are stored in the four local variables on the left, and those variables are then interpolated into a pretty-looking report for output:

整个程式在  File.open 起头的block 完成。 Block parameter |f| 代表了这个 file object.

While … end 是一个无限循环， record = f.gets 会一次会拿文件中的一行内容。当循环到最后一行之后 f.gets 会返回 nil ， 这时 while loop 结束

拿到每行内容后，以 | 为分隔符号 split 内容，分别赋值给 name , nationality, instrument, dates

record.chomp 会吃掉一行末尾的换行符号

—-

**File enumerability**

—-

```ruby
2.5.0 :008 > File.ancestors
 => [File, IO, File::Constants, Enumerable, Object, Kernel, BasicObject]
2.5.0 :009 > File.ancestors[3]
 => Enumerable
2.5.0 :010 >
```

Enumerable 是 File 父元素链中的一环，File对象具有可枚举性，这也是为什么我们能在上一个例子中使用 loop 对文件内容进行操作。

Ruby gracefully stops iterating when it hits the end of the file.
As enumerables, File objects can perform many of the same functions that arrays, hashes, and other collections do. Understanding how file enumeration works requires a slightly different mental model: whereas an array exists already and walks through its elements in the course of iteration, File objects have to manage line-by-line reading behind the scenes when you iterate through them. But the similarity of the idioms—the common use of the methods from Enumerable—means you don’t have to think in much detail about the file-reading process when you iterate through a file.

Most important, don’t forget that you can iterate through files and address them as enumerables. It’s tempting to read a whole file into an array and then process the array. But why not just iterate on the file and avoid wasting the space required to hold the file’s contents in memory?

Ruby会在到达文件末尾位置时自动停止迭代操作。

作为可枚举的物件， file 对象 可以进行很多像 array 和 hash 能进行的迭代操作，一个区别是 file object 的迭代是以 行 为单位进行的。虽然我们可以先将一个file object 中的 content 全部读出来放到一个 array 中，然后再进行其他操作，但是我们没有必要这样浪费内存。

现在有这样一个文件 members.txt

```ruby
David Black male 55
Caven Xu male 18
Lee Hans female 23
```

如果我们想要把文件中的所有人的 年龄信息加总起来

首先我们可以按照之前提到的先将信息提取到外部 array 中然后进行操作

```ruby
# File.readlines('members.txt') actually is an array
2.5.0 :018 > total_age = File.readlines('members.txt').inject(0) do |total, line|
2.5.0 :019 >     count += 1
2.5.0 :020?>     fields = line.split
2.5.0 :021?>     age = fields[3].to_i
2.5.0 :022?>     total + age # return value will be the next acc's value
2.5.0 :023?>   end
=> 96
2.5.0 :024 > puts "Average age is: #{total_age/count}"
Average age is: 32
=> nil
2.5.0 :025 >
```

我们也可以只使用 File 对象的枚举操作在文件本身完成上面的任务

```ruby
2.5.0 :028 > count = 0
 => 0
2.5.0 :029 > total_ages = File.open("members.txt") do |f|
2.5.0 :030 >     f.inject(0) do |total, line|
2.5.0 :031 >       count += 1
2.5.0 :032?>       fields = line.split
2.5.0 :033?>       age = fields[3].to_i
2.5.0 :034?>       total + age
2.5.0 :035?>     end
2.5.0 :036?>   end
 => 96
2.5.0 :037 >
```

—

**File I / O exceptions and errors**

—

When something goes wrong with file operations, Ruby raises an exception. Most of the errors you’ll get in the course of working with files can be found in the Errno namespace: Errno::EACCES (permission denied), Errno::ENOENT (no such entity—a file or directory), Errno:EISDIR (is a directory—an error you get when “you try to open a directory as if it were a file), and others. You’ll always get a message along with the exception:

常见错误都是以 Errno 作为开头的 namespace

- Errno::EACCES 权限不够

- Errno::ENOENT 没有指定的对象

- Errno::EISDIR —is a directory

```ruby
2.5.0 :037 > File.open("unknown")
Traceback (most recent call last):
        4: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        3: from (irb):37
        2: from (irb):37:in `open'
        1: from (irb):37:in `initialize'
Errno::ENOENT (No such file or directory @ rb_sysopen - unknown)
2.5.0 :038 >
```

Errno 系列错误不仅包含与文件相关的错误，也包含系统层级的错误，这些错误可能会使用数字来代表

Each Errno exception class contains knowledge of the integer to which its corresponding system error maps. You can get these numbers via the Errno constant of each Errno class—and if that sounds obscure, an example will make it clearer:

```ruby
2.5.0 :040 > Errno::ENOTDIR::Errno
 => 20
2.5.0 :041 >
```

You’ll rarely, if ever, have to concern yourself with the mapping of Ruby’s Errno exception classes to the integers to which your operating system maps errors. But you should be aware that any Errno exception is basically a system error percolating up through Ruby. These aren’t Ruby-specific errors, like syntax errors or missing method errors; they involve things going wrong at the system level. In these situations, Ruby is just the messenger.

通常情况下我们很少去关注这些系统错误的编号。但有一点要明确的是任何 Errno 错误基本都是从系统层面 渗透 到ruby这里的，syntax errors, missing method errors, 这些都不是 ruby 特有的，都包含系统层级的错误，在这些情境中，ruby 只是一个信使。

—-

**Querying IO and File objects**

—-

IO 和 File 这两个 class 中都有querying 相关的methods. 后者中包含的更多

The File class also has some query methods. In some cases, you can get the same information about a file several ways:

```ruby
2.5.0 :003 > File.size('/Users/caven/Notes & Articles/Note of Rubyist/code examples/ticket2.rb')
 => 223
2.5.0 :004 > FileTest.size('/Users/caven/Notes & Articles/Note of Rubyist/code examples/ticket2.rb')
 => 223
2.5.0 :005 > File::Stat.new('/Users/caven/Notes & Articles/Note of Rubyist/code examples/ticket2.rb').size
 => 223
2.5.0 :006 >
```

—-

Getting information form the File class and the FileTest module

—-

File and FileTest offer numerous query methods that can give you lots of information about a file. These are the main categories of query: What is it? What can it do? How big is it?”

对文件的 query 主要三个方面，是什么？ 能做什么？ 有多大？

The methods available as class methods of File and FileTest are almost identical; they’re mostly aliases of each other. The examples will only use FileTest, but you can use File too.

File 和 FileTest 中关于 querying 的方法名称几乎都是一样的

Here are some questions you might want to ask about a given file, along with the techniques for asking them. All of these methods return either true or false except size, which returns an integer. Keep in mind that these file-testing methods are happy to take directories, links, sockets, and other filelike entities as their arguments. They’re not restricted to regular files:

多数这类 methods 都返回 boolean 值， 除了 size , 而且这些方法能处理很多类型的 类文件 对象， 并不一定严格限制于普通的文件类型。

`FileTest.directory?()`  判断给出对象是否是一个路径

`FileTest.file?()`  判断给出对象是否是一个文件

`FileTest.symlink?()`  判断给出对象是否是一个 symbolic link (Returns true if the named file is a symbolic link.)

```ruby
2.5.0 :007 > FileTest.directory?('/users/caven/')
 => true
2.5.0 :008 > FileTest.file?('/users/caven/')
 => false
2.5.0 :009 > FileTest.symlink?('/users/caven/')
 => false
2.5.0 :010 >
```

也可以测试一个文件是否 可读， 可写， 或 可执行

```ruby
2.5.0 :011 > FileTest.readable?('/users/caven/')
 => true
2.5.0 :012 > FileTest.writable?('/users/caven/')
 => true
2.5.0 :013 > FileTest.executable?('/users/caven/')
 => true
2.5.0 :014 >
```

This family of query methods includes world_readable? and world_writable?, which test for more permissive permissions. It also includes variants of the basic three methods with `_real` appended. These test the permissions of the script’s actual runtime ID as opposed to its effective user ID.

这类方法还有类似的 world_readable? , world_writable? 等，用于在权限限制更严格的情况下使用。

`FileTest.size(“/home/users/dblack/setup")` 测试文件大小

`FileTest.zero?(“/tmp/tempfile”)`  测试文件是否为空

—-

Getting file information with Kernel#test

—-

Among the top-level methods at your disposal (that is, private methods of the Kernel module, which you can call anywhere without a receiver, like puts) is a method called test. You use test by passing it two arguments: the first represents the test, and the second is a file or directory. The choice of test is indicated by a character. You can represent the value using the ?c notation, where c is the character, or as a one-character string.

关于查询文件信息的高等级（那些靠近顶部的module中的方法）的methods 当中，有一个叫 test。

test  接受两个参数，第一个参数 代表测试的内容，第二个是要测的对象

```ruby
2.5.0 :014 > test(?e, '/users/caven/')
 => true
2.5.0 :015 >
```

`?e` 语义上相当于  exist？

类似的还有

`?d` 对应 directory?
`?f` 测试对象是否是一个 regular file
`?z` 测试大小是否为 0

For every test available through Kernel#test, there’s usually a way to get the result by calling a method of one of the classes discussed in this section. But the Kernel#test notation is shorter and can be handy for that reason.

这些短小的 代表符号 在之前提到的 class 中几乎都可以找到对应的方法，但是  Kernel#test 加 标记的用法更加短小方便

—

除了 FileTest 和 File 中有查询文件信息的方法，另一个 class File::Stat 中也有 （statistical）

两种方法新建 File::Stat 对象

1 使用 File::Stat.new(#file/dir)

2 使用 File.open(#file/dir) { |f| f.stat }

```ruby
2.5.0 :018 > File::Stat.new('/users/caven/')
 => #<File::Stat dev=0x1000004, ino=733544, mode=040755, nlink=73, uid=503, gid=20, rdev=0x0, size=2336, blksize=4194304, blocks=0, atime=2018-02-11 14:04:04 +0800, mtime=2018-02-11 14:04:04 +0800, ctime=2018-02-11 14:04:04 +0800, birthtime=2016-12-11 13:17:41 +0800>
2.5.0 :019 > File.open('/users/caven/') { |d| d.stat }
 => #<File::Stat dev=0x1000004, ino=733544, mode=040755, nlink=73, uid=503, gid=20, rdev=0x0, size=2336, blksize=4194304, blocks=0, atime=2018-02-11 14:04:04 +0800, mtime=2018-02-11 14:04:04 +0800, ctime=2018-02-11 14:04:04 +0800, birthtime=2016-12-11 13:17:41 +0800>
2.5.0 :020 >
```

The screen output from the File::Stat.new method shows you the attributes of the object, including its times of creation (ctime), last modification (mtime), and last access (atime).

这个方法会显示关于此对象的很多统计信息，包括建立时间，修改时间，最后一次方法时间等

The code block given to File.open in this example, {|f| f.stat }, evaluates to the last expression inside it. Because the last (indeed, only) expression is f.stat, the value of the block is a File::Stat object. In general, when you use File.open with a code block, the call to File.open returns the last value from the block. Called without a block, File.open (like File.new) returns the newly created File object.

注意第二种使用 block 的方法，这行代码最后返回的值会是 执行完 block 中的代码的值
Block 中的 f 指代的是一个 file object ,对他使用了 .stat 方法
这和先单独赋值，再使用效果相等

```ruby
2.5.0 :020 > f = File.open('/users/caven/')
 => #<File:/users/caven/>
2.5.0 :021 > f.stat
 => #<File::Stat dev=0x1000004, ino=733544, mode=040755, nlink=73, uid=503, gid=20, rdev=0x0, size=2336, blksize=4194304, blocks=0, atime=2018-02-11 14:04:04 +0800, mtime=2018-02-11 14:04:04 +0800, ctime=2018-02-11 14:04:04 +0800, birthtime=2016-12-11 13:17:41 +0800>
2.5.0 :022 >
```

Much of the information available from File::Stat is built off of UNIX-like metrics, such as inode number, access mode (permissions), and user and group ID. The relevance of this information depends on your operating system. We won’t go into the details here because it’s not cross-platform; but whatever information your system maintains about files is available if you need it.”

File::Stat 方法返回的信息中很多是基于 UNIX-like 标准的，在不同的操作系统中可能会有不同。

—-

Directory manipulation with the Dir class

class Dir 对文件路径进行操作

—-

使用 .new  新建一个 Dir instance

```ruby
2.5.0 :028 > d = Dir.new('/users/caven/rubyist/')
Traceback (most recent call last):
        4: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        3: from (irb):28
        2: from (irb):28:in `new'
        1: from (irb):28:in `initialize'
Errno::ENOENT (No such file or directory @ dir_initialize - /users/caven/rubyist/)
2.5.0 :029 >
```

注意这里的 new 不是 新建路径 的意思，而是根据已有路径建立一个 Dir instance
如果输入的路径是不存在的会报错

```ruby
caven@caven ⮀ ~ ⮀ pwd
/Users/caven
caven@caven ⮀ ~ ⮀ mkdir rubyist
caven@caven ⮀ ~ ⮀ irb
2.5.0 :001 > d = Dir.new('/users/caven/rubyist/')
=> #<Dir:/users/caven/rubyist/>
2.5.0 :002 > d
=> #<Dir:/users/caven/rubyist/>
2.5.0 :003 >
```

The most common and useful Dir-related technique is iteration through the entries (files, links, other directories) in a directory.

Dir 相关操作中最常用的是拿到里面的内容进行 迭代操作

有两个方法

`.entries`

`glob`

区别是 glob 不会拿到路径中的 隐藏文件，在 UNIX-like 系统中就是以点号起头的文件夹 ‘ . ’， 比如 .git 这类。

.entries 的使用方法有两种，一种是 instance method 格式，一种是 class method 格式

```ruby
2.5.0 :004 > dir = Dir.new('/Users/caven/Notes & Articles/Note of Rubyist')
 => #<Dir:/Users/caven/Notes & Articles/Note of Rubyist>

2.5.0 :005 > dir.entries
 => [".", "..", "Chapter 3 Organizing objects with classes.md", "Chapter 14. Callable and runnable objects.md", "Chapter 15. Callbacks, hooks, and runtime introspection.md", ".DS_Store", "Chapter 2  Objects , methods, and local variables.md", "chapter 12. File and I O operations.md", "Chapter 8. Strings, symbols, and other scalar objects.md", "Chapter 13. Object individuation.md", "readme.md", "Chapter 5 The default object (self), scope, and visibility.md", "Chapter 11. Regular expressions and regexp-based string operations.md", "Chapter 9 Collection and container objects.md", "Chapter 7 Built-in essentials.md", "Chapter 10 Collection central- Enumerable and Enumerator.md", "Chapter 6 Control-flow techniques.md", "Chapter 4 modules and program organization.md", "code examples", "Chapter 1  Bootstrapping your ruby literacy.md"]

2.5.0 :006 > Dir.entries('/Users/caven/Notes & Articles/Note of Rubyist')
 => [".", "..", "Chapter 3 Organizing objects with classes.md", "Chapter 14. Callable and runnable objects.md", "Chapter 15. Callbacks, hooks, and runtime introspection.md", ".DS_Store", "Chapter 2  Objects , methods, and local variables.md", "chapter 12. File and I O operations.md", "Chapter 8. Strings, symbols, and other scalar objects.md", "Chapter 13. Object individuation.md", "readme.md", "Chapter 5 The default object (self), scope, and visibility.md", "Chapter 11. Regular expressions and regexp-based string operations.md", "Chapter 9 Collection and container objects.md", "Chapter 7 Built-in essentials.md", "Chapter 10 Collection central- Enumerable and Enumerator.md", "Chapter 6 Control-flow techniques.md", "Chapter 4 modules and program organization.md", "code examples", "Chapter 1  Bootstrapping your ruby literacy.md"]
2.5.0 :007 >
```

Note that the single- and double-dot entries (current directory and parent directory, respectively) are present, as is the hidden .document entry. If you want to iterate through the entries, only processing files, you need to make sure you filter out the names starting with dots.
Let’s say we want to add up the sizes of all non-hidden regular files in a directory. Here’s a first iteration (we’ll develop a shorter one later):

注意返回文件夹array 中，一个点号和 两个点号的项。

```ruby
2.5.0 :008 > Dir.entries('/users/')
 => [".", "..", ".localized", "Shared", "caven", "Guest"]
2.5.0 :009 >
```

现在如果我们想要把所有非隐藏的常规文件（不是文件夹）大小加总起来

```ruby
=> #<Dir:/users>
2.5.0 :023 > entries = d.entries
=> [".", "..", ".localized", "Shared", "caven", "Guest"]
2.5.0 :024 > entries.delete_if { |entry| entry =~ /^\./ }
=> ["Shared", "caven", "Guest"]
2.5.0 :025 > entries.map! { |entry| File.join(d.path, entry) }
=> ["/users/Shared", "/users/caven", "/users/Guest"]
2.5.0 :026 > entries.delete_if { |entry| !File.file?(entry) }
=> []
2.5.0 :027 > puts entries.inject(0) { |acc, entry| acc + File.size(entry) }
0    # cause we got an empty array in the previous step
=> nil
```

第一个 delete_if 移除掉了以 点号开头的文件
map! + File.join是为了让 array 中的每个项都变成绝对路径，方便后面计算大小

若使用 glob 可以简化代码

Globbing in Ruby takes its semantics largely from shell globbing, the syntax that lets you do things like this in the shell:

Ruby 中的globbing操作从 shell 中借用了很多语义

像这类 * 星号的使用

`ls *.rb`

![](https://ws4.sinaimg.cn/large/006tKfTcgy1fochwzozavj30k803rdgm.jpg)


The details differ from one shell to another, of course; but the point is that this whole family of name-expansion techniques is where Ruby gets its globbing syntax. An asterisk represents a wildcard match on any number of characters; a question mark represents one wildcard character. Regexp-style character classes are available for matching.

不同的 shell 中可能细节上有区别，但核心是 ruby 借用了这些语义中的很多内容，* 星号代表任意数目的任意字符，问号代表一个字符，和 regexp 中有所区别

To glob a directory, you can use the Dir.glob method or Dir.[] (square brackets). The square-bracket version of the method allows you to use index-style syntax, as you would with the square-bracket method on an array or hash. You get back an array containing the result set:

使用Dir的 `.[ ]` 或 `.glob` 方法可以 拿到匹配的文件对象array

```ruby
2.5.0 :001 > Dir['./*tion.rb']
 => ["./enum_protection.rb", "./partition.rb"]
2.5.0 :002 >
```

另一种 就是使用 Dir.glob( ) , glob 与 .[ ] 不同的是 glob( ) 不仅可以匹配文件路径，还可以给出选项 flag 过滤结果。

```ruby
2.5.0 :001 > Dir.glob('*info*')
 => []
2.5.0 :002 > Dir.glob('*info*', File::FNM_DOTMATCH)
 => [".information"]
2.5.0 :003 > Dir.glob('*info*', File::FNM_DOTMATCH | File::FNM_CASEFOLD)
 => [".information", "Info", ".INFO"]
2.5.0 :004 >
```

一个参数作为匹配字符，后面的则是过滤选项

The flags are, literally, numbers. The value of File::FNM_DOTMATCH, for example, is 4. The specific numbers don’t matter (they derive ultimately from the flags in the system library function fnmatch). What does matter is the fact that they’re exponents of two accounts for the use of the OR operation to combine them.

File::FNM_DOTMATCH 和 File::FNM_CASEFOLD 都是系统库中的选项，也可以用数字代表

```ruby
2.5.0 :004 > Dir.glob('*info*', 4)
 => [".information"]
2.5.0 :005 >
```

Flags 选项之间还可以使用 竖线 | 添加选项， 语义上是 or

-

As you can see from the first two lines of the previous example, a glob operation on a directory can find nothing and still not complain. It gives you an empty array. Not finding anything isn’t considered a failure when you’re globbing.

需要注意 使用 Dir.glob 和 Dir[ ] 方法如果没有匹配返回的是空 array 对象，而不是 nil 如果要将匹配结果作为boolean逻辑判断需要小心

—

如果不需要 flags 来进行过滤那么使用 Dir[ ] 和 Dir.glob 效果是差不多的，除非你需要更精细的匹配，多数简单情况可以直接使用 Dir[ ]

因为 Dir相关的方法默认不包含以点号 . 开头的隐藏文件，所以对应到上面提到的使用 entries 计算非隐藏常规文件大小的操作可以简化

```ruby
2.5.0 :007 > dir = '/users/caven/'
 => "/users/caven/"
2.5.0 :008 > entries = Dir["#{dir}/*"].select { |entry| File.directory?(entry) }
 => ["/Users/caven//Reading", "/Users/caven//Music", "/Users/caven//CavenHome", "/Users/caven//Calibre 书库", "/Users/caven//rubyist",......]
2.5.0 :009 >
2.5.0 :010 > puts entries.inject(0) { |acc, entry| acc + File.size(entry) }
13504
 => nil
2.5.0 :011 >
```

使用 Dir 的方法少了 将相对路径转换为绝对路径的步骤，还有过滤隐藏文件的步骤

—

Directory manipulation and querying

—

Here, we’ll create a new directory (mkdir), navigate to it (chdir), add and examine a file, and delete the directory (rmdir):”

下面我们会新建`mkdir`一个路径，然后切换`chdir`到这个路径，加入并检视一个文件，然后删除`rmdir`这个路径

```ruby
2.5.0 :018 > new_dir = '/tmp/newdir'
 => "/tmp/newdir"
2.5.0 :019 > newfile = 'newfile'
 => "newfile"
2.5.0 :020 > Dir.mkdir(new_dir)
 => 0
2.5.0 :021 > Dir.chdir(new_dir) do
2.5.0 :022 >     File.open(newfile, 'w') do |f|
2.5.0 :023 >       f.puts "Sample file in new directory"
2.5.0 :024?>     end
2.5.0 :025?>   puts "Current directory: #{Dir.pwd}"
2.5.0 :026?>   p Dir.entries(".")
2.5.0 :027?>   File.unlink(newfile)
2.5.0 :028?> end
Current directory: /private/tmp/newdir
[".", "..", "newfile"]
 => 1
2.5.0 :029 > Dir.rmdir(new_dir)
 => 0
2.5.0 :030 > print "Does #{new_dir} still exist?"
Does /tmp/newdir still exist? => nil
2.5.0 :031 > if File.exist?(new_dir)
2.5.0 :032?>   puts "Yes"
2.5.0 :033?> else
2.5.0 :034?>   puts "No"
2.5.0 :035?> end
No
 => nil
2.5.0 :036 >
```

例子中使用到的方法都跟shell 中很像， 比如 Dir.mkdir 对应 make directory, chdir 对应 change directory , rmdir 对应 remove directory

unlink  方法 其实就是 delete 方法 删除

As promised in the introduction to this chapter, we’ll now look at some standard library facilities for manipulating and handling files.

下面我们会看一些 standard library 中处理文件的功能

-

**File tools from the standard library**

std lib 中的文件处理工具

-

File handling is an area where the standard library’s offerings are particularly rich. Accordingly, we’ll delve into those offerings more deeply here than anywhere else in the book. This isn’t to say that the rest of the standard library isn’t worth getting to know, but that the extensions available for file manipulation are so central to how most people do file manipulation in Ruby that you can’t get a firm grounding in the process without them.

We’ll look at the versatile FileUtils package first and then at the more specialized but useful Pathname class. Next you’ll meet StringIO, a class whose objects are, essentially, strings with an I/O interface; you can rewind them, seek through them, getc from them, and so forth. Finally, we’ll explore open-uri, a package that lets you “open” URIs and read them into strings as easily as if they were local files.

Standard lib 中尤其提供了很多关于文件的操作，因此这部分会是本书中最深入 standard lib 的内容。但这并不是说standard lib 的其他部分内容不重要。只不过这部分关于文件操作的内容很核心也很重要，如果不介绍他们，我们关于文件操作内容的学习就称不上有较好的基础。
我们会学习 功能齐全的 FileUtils 库，以及比较特化的 class Pathname
然后会学习 StringIO, 这个 class 的实例对象实际上是 带有 I / O 接口的 string 对象，我们可以对其进行 rewind ， seek , getc 等操作

最后我们将会探索 open-uri ，这个库让我们能更好的以 string 的方式处理 URIs

—

The FileUtils module

—

FileUtils 中的很多方法也是从 UNIX-like 系统中借鉴而来的比如

`FileUtils.rm_rf` 模仿  rm -rf (force unconditional recursive removal of a file or directory)

You can create a symbolic link from filename to linkname with `FileUtils.ln_s(filename, linkname)`, much in the manner of the ln -s command.

copying, moving, and deleting files

FileUtils provides several concise, high-level methods for these operations. The cp method emulates the traditional UNIX method of the same name. You can cp one file to another or several files to a directory:

FileUtils 提供了很多简洁，高层及的方法。比如 `cp` 方法就模仿了同名称的传统的 UNIX 方法。你可以 `cp` 一个文件到另一个或多个文件到一个路径中

比如下面的例子

cp 拷贝一个文件到另一个文件(并且更改了文件后缀名)

mkdir 新建了文件夹

这些用法都和 unix 系统中的操作很类似

```ruby
2.5.0 :041 > require 'fileutils'
 => true
2.5.0 :042 > FileUtils.cp("baker.rb", "baker.rb.bak")
 => nil
2.5.0 :043 > FileUtils.mkdir("backup")
 => ["backup"]
2.5.0 :044 > FileUtils.cp(["ensure.rb", "super.rb"], "backup")
 => ["ensure.rb", "super.rb"]
2.5.0 :045 > Dir["backup/*"]
 => ["backup/super.rb", "backup/ensure.rb"]
2.5.0 :046 >
```

注意在 terminal 中（不是在irb），我们使用的 mkdir, cd 等操作是在电脑的系统层面上，而这里提到的关于文件的操作都是在 ruby 这个大背景下的，不要混淆范围。

对应的 还有 mv 用来移动文件，rm用来删除文件

```ruby
2.5.0 :046 >
2.5.0 :047 > FileUtils.mv("baker.rb.bak", "backup")
 => 0
2.5.0 :048 > Dir["backup/*"]
 => ["backup/super.rb", "backup/baker.rb.bak", "backup/ensure.rb"]
2.5.0 :049 > File.exist?("backup/super.rb")
 => true
2.5.0 :050 > FileUtils.rm("backup/super.rb")
 => ["backup/super.rb"]
2.5.0 :051 > File.exist?("backup/super.rb")
 => false
2.5.0 :052 >
```

The `rm_rf` method recursively and unconditionally removes a directory:”

rm_rf 用来无条件删除文件

注意用来测试文件是否存在的 exist? 是 File(core) 中的 方法

```ruby
2.5.0 :052 > FileUtils.rm_rf("backup")
 => ["backup"]
2.5.0 :053 > File.exist?("backup")
 => false
2.5.0 :054 >
```

FileUtils gives you a useful toolkit for quick and easy file maintenance. But it goes further: it lets you try commands without executing them.

FileUtils 中除了上面提到的方法，还有让我们 try 一个方法而不用实际执行

-

The DryRun and NoWrite modules

-

If you want to see what would happen if you were to run a particular FileUtils command, you can send the command to FileUtils::DryRun. The output of the method you call is a representation of a UNIX-style system command, equivalent to what you’d get if you called the same method on FileUtils:

如果你想知道执行一个 FileUtils 中的方法对应的 UNIX 格式(也可以理解为在terminal中)是怎样的，你将一个命令作为参数送给 FileUtils::DryRun, 将会返回你执行方法的 UNIX 格式

```ruby
2.5.0 :056 > FileUtils::DryRun.rm_rf("filename")
rm -rf filename
 => nil
2.5.0 :057 > FileUtils::DryRun.ln_s("backup", "backup_link")
ln -s backup backup_link
 => nil
2.5.0 :058 >
```

If you want to make sure you don’t accidentally delete, overwrite, or move files, you can give your commands to FileUtils::NoWrite, which has the same interface as FileUtils but doesn’t perform any disk-writing operations:

在执行一个动作前如果你怕引起无法逆转的后果，可以在 FileUtils::NoWrite后执行你想执行的命令，这样你可以看到模拟的结果而不会进行实际的读写

```ruby
2.5.0 :060 > FileUtils::NoWrite.rm("/Users/caven/Notes & Articles/Note of Rubyist/code examples/.INFO")
 => nil
2.5.0 :061 > File.exist?("/Users/caven/Notes & Articles/Note of Rubyist/code examples/.INFO")
 => true
2.5.0 :062 >
```

—-

**The Pathname class**

—-

The Pathname class lets you create Pathname objects and query and manipulate them so you can determine, for example, the basename and extension of a pathname, or iterate through the path as it ascends the directory structure.

Pathname 类让你可以建立新的 pathname 对象，然后对其进行查询和操作，比如一个路径的当前路径名称以及拓展名等，或者沿着这个路径向上进行迭代操作

Pathname objects also have a large number of methods that are proxied from File, Dir, IO, and other classes. We won’t look at those methods here; we’ll stick to the ones that are uniquely Pathname’s.

Pathname对象同时还有很多方法是从 File， Dir, IO 以及其他classes中借来的。 我们这里不会提到，我们只提那些只在 Pathname中才有的方法。

记得先  `require 'pathname'`

```ruby
2.5.0 :062 > path = Pathname.new("/Users/caven/Notes & Articles/Note of Rubyist/code examples/.INFO")
Traceback (most recent call last):
        2: from /Users/caven/.rvm/rubies/ruby-2.5.0/bin/irb:11:in `<main>'
        1: from (irb):62
NameError (uninitialized constant Pathname)
2.5.0 :063 > require 'pathname'
 => true
2.5.0 :064 > path = Pathname.new("/Users/caven/Notes & Articles/Note of Rubyist/code examples/.INFO")
 => #<Pathname:/Users/caven/Notes & Articles/Note of Rubyist/code examples/.INFO>
2.5.0 :065 > path.basename
 => #<Pathname:.INFO>
2.5.0 :066 > path.dirname
 => #<Pathname:/Users/caven/Notes & Articles/Note of Rubyist/code examples>
2.5.0 :067 > path.extname
 => ""
2.5.0 :068 > path
 => #<Pathname:/Users/caven/Notes & Articles/Note of Rubyist/code examples/.INFO>
2.5.0 :069 >
```


对一个 Pathname 对象使用某些方法 返回的值是一个 新的Pathname 对象， 如果想要看 string 格式的版本，使用 puts 加对象

```ruby
2.5.0 :076 > path
 => #<Pathname:/Users/caven/Notes & Articles/Note of Rubyist/code examples>
2.5.0 :077 > puts path
/Users/caven/Notes & Articles/Note of Rubyist/code examples
 => nil
2.5.0 :078 >
```

The Pathname object can also walk up its file and directory structure, truncating itself from the right on each iteration, using the ascend method and a code block:

`ascend` 方法可以从当前路径开始，一级一级地向上遍历每一个路径

```ruby
2.5.0 :079 > path
 => #<Pathname:/Users/caven/Notes & Articles/Note of Rubyist/code examples>
2.5.0 :080 >
2.5.0 :081 > path.ascend do |dir|
2.5.0 :082 >     puts "Next level up: #{dir}"
2.5.0 :083?>   end
Next level up: /Users/caven/Notes & Articles/Note of Rubyist/code examples
Next level up: /Users/caven/Notes & Articles/Note of Rubyist
Next level up: /Users/caven/Notes & Articles
Next level up: /Users/caven
Next level up: /Users
Next level up: /
 => nil
2.5.0 :084 >
```

The key behavioral trait of Pathname objects is that they return other Pathname objects. That means you can extend the logic of your pathname operations without having to convert back and forth from pure strings. By way of illustration, here’s the last example again, but altered to take advantage of the fact that what’s coming through in the block parameter dir on each iteration isn’t a string (even though it prints out like one) but a Pathname object:

关于 Pathname 的一个主要特点是上面提到的他总是返回一个 object 而不是一个 string ，所以我们可以在 block 中连续使用针对 object 的方法

```ruby
2.5.0 :085 > path
 => #<Pathname:/Users/caven/Notes & Articles/Note of Rubyist/code examples>
2.5.0 :086 > path.ascend do |dir|
2.5.0 :087 >     puts "Ascended to #{dir.basename}"
2.5.0 :088?>   end
Ascended to code examples
Ascended to Note of Rubyist
Ascended to Notes & Articles
Ascended to caven
Ascended to Users
Ascended to /
 => nil
2.5.0 :089 >
```
—

The StringIO class

—

The StringIO class allows you to treat strings like IO objects. You can seek through them, rewind them, and so forth.

StringIO class 让我们可以像对待 IO 对象一样对待 string , 可以seek , rewind, 等，这些方法都是实例化IO对象时传入文件，然后对object进行的操作

假设我们现在想写一个 module ，专门用来将一个文件中不是注释（不以`#`开头）的内容导入到另一个文件中，那么我们写的 module 可能是这样：

```ruby
module DeCommenter

  def self.decomment(infile, outfile, comment_re = /\A\s*#/)
    infile.each do |inline|
      outfile.print inline unless inline =~ comment_re
    end
  end

end
```

infile 代表原始的那个文件对象， outfile 代表将要写入的文件对象，comment_re 是默认的识别注释的 regular expression

如果以上面的 module 为基础，我们进行的实际操作会是这样

```ruby
File.open("myprogram.rb") do |infile|
  File.open("target.rb", "w") do |outfile|
    DeCommenter.decomment(infile,outfile)
  end
end
```

这里实际做的就是分别拿到两个文件对象，一个作为 源， 一个作为输出容器，然后将作为源的对象的迭代中匹配到的内容写入输出对象。

实际测试一下 module DeCommenter

先将 module 放到 decommenter.rb 这个rb文件中

`decommenter.rb`

```ruby
module DeCommenter

  def self.decomment(infile, outfile, comment_re = /\A\s*#/)
    infile.each do |inline|
      outfile.print inline unless inline =~ comment_re
    end
  end

end
```

然后在文件 decomment-demo.rb 中写测试

```ruby
require 'stringio' # standard lib
require_relative 'decommenter' # module DeCommenter

string = <<EOM
# This is a comment.
This isn't a comment.
# This is.
    # So is this.
This is also not a comment.
EOM

infile = StringIO.new(string)
outfile = StringIO.new("")

DeCommenter.decomment(infile, outfile)
puts "Test succeeded" if outfile.string == <<EOM
This isn't a comment.
This is also not a comment.
EOM
```

首先要 require 两个需要的库, 是个是 ruby的 'stringio'， 一个是我们自己写的module

string 包含的内容 被注入到 infile 这个 StringIO 对象中， outfile对象新建时用到了空字符串

```ruby
2.5.0 :001 > load './decomment-demo.rb'
Test succeeded
 => true
2.5.0 :002 >
```

最后返回的结果，测试成功

-

—-


The open-uri library

—-

The open-uri standard library package lets you retrieve information from the network using the HTTP and HTTPS protocols as easily as if you were reading local files. All you do is require the library (require 'open-uri') and use the Kernel#open method with a URI as the argument. You get back a StringIO object containing the results of your request:

open-uri 库让我们直接通过命令以 http / https 协议拿到资源信息，就像在读取一个本地文件一样

在require 库之后，使用 `Kernel#open` 方法传入URI地址，就可以拿到一个 StringIO 对象包含requst的内容。

```ruby
2.5.0 :003 > require "open-uri"
 => true
2.5.0 :004 > rubypage = open("http://rubycentral.org")
 => #<StringIO:0x00007f97a5920920 @base_uri=#<URI::HTTP http://rubycentral.org>, @meta={"connection"=>"keep-alive", "x-frame-options"=>"sameorigin", "x-xss-protection"=>"1; mode=block", "content-type"=>"text/html;charset=utf-8", "content-length"=>"6675", "server"=>"WEBrick/1.3.1 (Ruby/2.1.3/2014-09-19)", "date"=>"Sun, 11 Feb 2018 11:27:17 GMT", "via"=>"1.1 vegur"}, @metas={"connection"=>["keep-alive"], "x-frame-options"=>["sameorigin"], "x-xss-protection"=>["1; mode=block"], "content-type"=>["text/html;charset=utf-8"], "content-length"=>["6675"], "server"=>["WEBrick/1.3.1 (Ruby/2.1.3/2014-09-19)"], "date"=>["Sun, 11 Feb 2018 11:27:17 GMT"], "via"=>["1.1 vegur"]}, @status=["200", "OK "]>
2.5.0 :005 > puts rubypage.gets
<!doctype html>
 => nil
2.5.0 :006 > puts rubypage.gets
<html lang="en">
 => nil
2.5.0 :007 > puts rubypage.gets
  <head>
 => nil
2.5.0 :008 >
```

Require 之后，我们使用 open 方法 带上地址作为参数，直接拿到了整个页面的代码，注意返回的不是 string 而是一个 StringIO 对象，包含了关于对象的很多属性，而content 并没有全部写在里面

通过 gets 我们就可以一行一行拿到返回的信息

通过IO 相关（在StringIO对象上基本都可以用）的方法可以以各种方式读取对象中的 content

```ruby
2.5.0 :008 > rubypage.size
 => 6675
2.5.0 :009 > rubypage.readlines.size
 => 129
2.5.0 :010 >
```

## Summary

In this chapter you’ve seen

- I/O (keyboard and screen) and file operations in Ruby
ruby 中的IO操作

- File objects as enumerables
作为可枚举对象的File 实例对象

- The STDIN, STDOUT, and STDERR objects
STDIN STDOUT, 以及 STDERR 对象

- The FileUtils module
std lib 中的 module FileUtils

- The Pathname module
std lib 中的 module Pathname

- The StringIO class
std lib 中的 class IO

- The open-uri module
std lib 中的 module open-uri

I/O operations are based on the IO class, of which File is a subclass. Much of what IO and File objects do consists of wrapped library calls; they’re basically API libraries that sit on top of system I/O facilities.
I/O操作是基于IO class的，File 是他的subclass. IO 和 File 中的许多方法都借鉴自系统层面的 I/O 功能。

You can iterate through Ruby file handles as if they were arrays, using each, map, reject, and other methods from the Enumerable module, and Ruby will take care of the details of the file handling. If and when you need to, you can also address IO and File objects with lower-level commands.
你可以想对待array一样对file对象进行迭代操作，使用 each, map, reject, 等来自 module Enumerable 的方法。 不过只要你需要，你也可以对 IO 和 File 对象进行低层级的操作。

Some of the standard-library facilities for file manipulation are indispensable, and we looked at several: the FileUtils module, which provides an enriched toolkit for file and disk operations; the StringIO class, which lets you address a string as if it were an I/O stream; the Pathname extension, which allows for easy, extended operations on strings representing file-system paths; and open-uri, which makes it easy to “open” documents on the network.
很多std lib中的文件操作功能是不可获取的，我们看过一些： module FileUtils 提供了丰富的文件和硬盘层面的操作； class StringIO 能够让你像对待一个 I/O stream 一样对待string。 Pathname 让我们能以简单，可拓展的方式对文件路径进行操作。最后 open-uri 让我们能够方便地打开网络上的资源。

We also looked at keyboard input and screen output, which are handled via IO objects—in particular, the standard input, output, and error I/O handles. Ruby lets you reassign these so you can redirect input and output as needed.
我们也了解了键盘输入和屏幕输出，他们是通过 IO 对象——准确的说是 stdin stdout stderr对象来进行 I/O 操作的。 Ruby 让你能够通过重新给对应的 I/O 对象赋值重新定向输出和输入的位置。
