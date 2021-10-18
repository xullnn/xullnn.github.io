---
title:  "Algorithms 101 - 11 - where to go next | further learning"
categories:
  - Work
tags:
  - programming
  - algorithm
  - 算法
  - reading notes
layout: post
---

*算法入门笔记，基于《Grokking Algorithms: An illustrated guide for programmers and other curious people》这本书的内容*

#### 主要内容

简要提及了一些之前没有提到或展开的重要算法或数据结构。

- Trees - 树（一种数据结构）
- Inverted indexes （反向索引）
- The Fourier transform （傅里叶变换）
- Parallel Algorithms （平行算法）
  - MapReduce
  - Bloom filters and HyperLogLog
- The SHA algorithms （Secure Hash Algorithm）
- Locality-sensative hashing - 局部敏感hash function
- Diffie-Hellman key exchange 迪菲-赫尔曼密钥交换
- Linear programming - 线性规划

---

#### 1 Tree

这里的Tree指的是在计算机科学中的一种**数据结构**。

Tree (data structure), a widely used computer data structure that emulates a tree structure with a set of linked nodes

Tree(数据结构)，指的是一种广泛应用的计算机数据结构，它使用一系列相互连接的节点构成一种类似自然界的树的结构。

**binary search tree**

之前提到过的facebook的例子，如果所有的用户名称存储在一个array中，当一个新用户注册时，就需要搜索整个array来确认新注册的用户名是否已经存在，当然如果是个ordered array, 那么就只有 O (log n) 的算法复杂度。

问题是当有新用户注册时，就需要对这个array进行重新排序，因为array占据的是存储介质中的连续slots空间，写入原array就会写在array的尾部。

有没有什么方法可以直接将新用户写入到array中正确的slot,让之后不再需要排序操作？ **binary search tree** 数据结构可以实现。

>  A binary search tree (BST) is a binary tree where each node has a Comparable key (and an associated value) and satisfies the restriction that the key in any node is larger than the keys in all nodes in that node's left subtree and smaller than the keys in all nodes in that node's right subtree.

Algorithms (4th Edition) 4th Edition       
by Robert Sedgewick,‎ Kevin Wayne

二叉搜索树是一种二叉树状的数据结构，树中的节点时可比较的key(并且有对应的value)，同时每个节点的两个子节点遵守key大的在右边，小的在左边的规则。

二叉树搜索数据结构下，每一次搜索都会将搜索范围缩小一半，所以对于searching的算法复杂度是 O (log n)。这一点上与 sorted array 相比没有差别。但是在 insertion 和 deletion 操作中则不同，

sorted array 的insertion/deletion操作会是 O (n), 而binary search tree 的 insertion/deletion操作的算法复杂度是 O(log n), 这一点上快了很多。

**downsides**

一是无法进行随机读取，比如对于array,你可以说要要拿第50个对象。但对于binary search tree则不行。所有类型的操作实际都需要先搜索。

二是可能存在树结构的失衡。也就是某个根节点的一个分支比另一个长很多。

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-05-02+%E4%B8%8B%E5%8D%883.29.26.png
)

最极端的情况就是从一个根节点出发，之后所有的对象都只分布在一侧分支上。

有一类特殊的 [self-balancing binary search tree](https://en.wikipedia.org/wiki/Self-balancing_binary_search_tree) 能够自动平衡树的结构，比如 [red-black tree](https://en.wikipedia.org/wiki/Red%E2%80%93black_tree)。

**应用**

binary search tree 还有很多变种形式，那些是应用中使用较多的？ [B-tree](https://en.wikipedia.org/wiki/B-tree)是一个例子。其他相关的例子还有

- [B-trees](https://en.wikipedia.org/wiki/B-tree)
- [red-black trees](https://en.wikipedia.org/wiki/Red%E2%80%93black_tree)
- [Heaps](https://en.wikipedia.org/wiki/Heap_(data_structure))
- [Splay trees](https://en.wikipedia.org/wiki/Splay_tree)

#### 2 Inverted indexes 反向索引

https://zh.wikipedia.org/wiki/%E5%80%92%E6%8E%92%E7%B4%A2%E5%BC%95

在array中，一个索引对应一条记录，比如

```
0: "it is what it is"
1: "what is it"
2: "it is a banana"
```

对于全文检索来说，这种索引实际不能提供太多有用的信息，因为检索是以记录为起点。 inverted index 则把上面那种索引方式反过来，记录特定内容在存储介质中的位置，像这样：

```
"a":      {2}
"banana": {2}
"is":     {0, 1, 2}
"it":     {0, 1, 2}
"what":   {0, 1}
```

进行搜索时，如果查找 "is" 马上就能知道在哪几个位置包含了这个单词，可以快速定位。

如果查找 "what is it" 这种包含多个单词的句子，则可以对句子中三个单词的反向索引的求交集。

统计一个单词在某段文字中出现了多少次实际就是集合中对象的数量，比如 `{0,1,2}` 则说明出现了3次。

**反向索引的典型应用是搜索引擎。**

#### 3 The Fourier transform

https://en.wikipedia.org/wiki/Fourier_transform

“The Fourier transform is one of those rare algorithms: brilliant, elegant, and with a million use cases.”

摘录来自: Aditya Y. Bhargava. “Grokking Algorithms: An illustrated guide for programmers and other curious people。” iBooks.

傅里叶变换是算法中很少见的那种：智慧，优雅，并且被广泛使用。

在better explained 上有一个很好的解释视频

https://betterexplained.com/articles/an-interactive-guide-to-the-fourier-transform/

使用傅里叶变换可以将一段音乐中不同频率的声音信号分离出来，而这些不同频率的声音可以对应到不同的乐器，分离频率的过程就实现了乐器声音的分离。

“The Fourier transform tells you exactly how much each note contributes to the overall song. So you can just get rid of the notes that aren’t important. ”

摘录来自: Aditya Y. Bhargava. “Grokking Algorithms: An illustrated guide for programmers and other curious people。” iBooks.

傅里叶变换在信号处理中很好用。上面提到可以分离音乐，他还可以用来压缩音乐。同样还是先将不同频率的声音信号分离出来，然后分析出哪些频率的声音对整首歌的构成有最大贡献，接着剔除那些没有贡献的或贡献很小（比如人的听觉无法感知）的信息。这样就在保证音乐效果的前提下减小了空间占用。

另一个应用是 JPG 文件压缩，也是同样的逻辑，只不过这次考量的贡献值是基于人类视觉。

傅里叶变换还被用于地震预测，DNA分析，还有用于音乐识别的网站[shazam](https://www.shazam.com/zh)

#### 4 Parallel algorithms 平行算法

包含3个话题

- MapReduce
- Bloom filters
- HyperLogLog

基于摩尔定律的预测，计算机的运算速度会越来越快，如果你写了一个算法，你想让他快一点，只需要等上几个月，因为计算机算力的增强可就可以提高整个算法的运算速度。但事实并非如此，计算机算力并没有照此趋势一直增加，现在的pc通过使用多核心cpu来增强运算能力。

这就涉及到一个问题，通常一个算法是在一个核心中持续计算的，现在你需要想想怎么让算法在多个核心上平行运行，以达到对计算机cpu的更好利用。

举例来说，目前能进行排序的算法的算法复杂度大概是 O (nlog n)，你不能使用 O(n) times 来对一个array 进行排序 -- 除非你使用平行算法。

**平行算法的设计很难**。 而且你很难保证设计出来的算法能正常工作，也很难预估带来的效能提升是什么样的。但有一件事是确定的 -- 带来的算法效能提升不是线性的。假设你的算法之前只能用一个核心，现在你改进后使他能在两个核心上同时运行，那么你几乎不可让运行时间变为原来的 1/2，出现这种现象的原因如下：

1 Overhead of managing the parallelism    

管理平行运行需要额外的资源消耗。举个简单的例子，比如你现在要对一个含有 1000 个items的array进行排序，你现在把工作分到了两个核心上，每个分 500 个对象，那么你排完序之后还需要对两个array进行合并，这一步操作又会耗费资源。

2 Loading balancing - 负载均衡

https://en.wikipedia.org/wiki/Load_balancing_(computing)

假设你有10个待处理任务，两个核心每个分到5个任务，但分配任务时，第一个核心拿到的多是简单的任务，他完成所有任务只需要10秒，而核心2拿到的都是比较难的任务，他完成所有任务需要50秒，那么当核心1完成任务后实际上有40秒时间都是空闲的，在等待核心2。最好的情况是两个核心拿到的任务的难度应该是差不多的，这一步分配是有难度的。

##### 4.1 MapReduce

有一类平行算法正变得越来越流行：**distributed algorithms** 分布式算法

当你的任务只需要少量核心来运算时，使用单台电脑是没有问题的，但如果你需要100个核心来执行任务以达到一个可以接受的运行时间时，怎么办？

你可以写一个可以跨计算机运行的平行算法，这种算法可以使用多台计算机上的执行一个算法，这样就可以使用很多核心并行处理。 **MapReduce** 就是其中一个常用的分布式算法，你可以使用开源工具 [Apache Hadoop](http://hadoop.apache.org/) 来实现MapReduce算法的应用。

**应用场景**

假设你数据库中有一个table，这个table中有万亿级别row的数据，你想对这个表执行一个复杂的sql查询。你不能在 MySQL 上执行这个任务，因为mysql在有几十亿行的表中查询就已经很吃力，这时你就可以借助 Hadoop 使用 MapReduce 算法。

再假设你有一个很长清单的任务需要处理，每个任务都需要10秒左右的运算时间，现在这个清单中有 1百万个这样的任务。如果你在一台计算机上执行这清单上的任务，可能需要几个月的时间，如果你现在同时在100台机器上执行，就可能只需要几天的时间。

“Distributed algorithms are great when you have a lot of work to do and want to speed up the time required to do it. MapReduce in particular is built up from two simple ideas: the map function and the reduce function.”

摘录来自: Aditya Y. Bhargava. “Grokking Algorithms: An illustrated guide for programmers and other curious people。” iBooks.

分布式算法适用于有很多工作需要做而你又需要减少时间消耗的场景。MapReduce方法在两个简单的思想上构建起来： `map` 函数和 `reduce` 函数。

map

The map function is simple: it takes an array and applies the same function to each item in the array.

reduce

The idea is that you “reduce” a whole list of items down to one item. With map, you go from one array to another.

ruby 中的map和reduce

```ruby
2.5.0 :003 > array = [1,2,3,4]
 => [1, 2, 3, 4]

2.5.0 :005 > mapped = array.map { |e| e**2 }
 => [1, 4, 9, 16]

2.5.0 :009 > reduced = array.reduce { |acc, e| acc + e**2 }
 => 30
```

MapReduce就是基于这两个简单的概念跨计算机执行复杂的数据查询，当你有一个很大的数据集时，MapReduce可以让你把查询时间从传统方式的几小时缩短到几分钟。

##### 4.2 Bloom filters and HyperLogLog

假设你是[reddit](https://zh.wikipedia.org/wiki/Reddit)的拥有者。当有用户提交新帖子的时候，你想先检查类似的内容是否之前就发表过。只有新鲜的内容才视作有价值的，所以你需要某种筛查机制。

或者假设你是google,你想爬网页。你只想爬那些你之前没有爬过的网页，你也需要一个筛查机制。

或者假设你在运行 bit.ly(一个提供缩短网址服务的公司), 你不想将用户定向至一些恶意网站，你手中有一个恶意网站的数据集，你在重定向用户之前会查询定向到的地址是否在这个数据集中。

https://zh.wikipedia.org/wiki/Bit.ly

https://zh.wikipedia.org/wiki/%E7%B8%AE%E7%95%A5%E7%B6%B2%E5%9D%80%E6%9C%8D%E5%8B%99

上面这些问题有一个共同点：都有一个很大的数据集。现在你拿到一个新item, 你想看看他是否在这个数据集中，你可以考虑使用一个hash table，比如google可以使用网站地址作为key, value 只包含`true` 或 `false`，这样算法复杂度只有 O(1)。但一个问题是，这个hash table会很大，像google这样的公司需要爬上万亿个网页，如果要存储所有这些网站的网址，那么需要巨大的存储空间。

##### 4.2.1 Bloom filters

[Bloom filter](https://en.wikipedia.org/wiki/Bloom_filter)是一个基于概率的数据结构，他用来判断一个对象是否在某个数据集中。和hash table查询不同，bloom filter 只能告诉你一个很可能的答案，或说大概率上正确的答案。

- 回答可能是 False positive的，也就是错误的判断给出的 item 已经包含在数据集中，而实际上没有
- 回答也可能是 False negative的，也就是错误的判断给出的 item 不在数据集中个，而实际上在数据集中

比如google爬网站如果使用bloom filter遇到 false positive （可以理解为假阳性），那么就是错误的判断一个网页已经爬过了，但实际没有。遇到 false negative，就是错误地判断一个网站没有爬过，而实际已经爬过了。

数据集中的数据越多，false positive 的概率越大。但bloom filter的优势是占用空间少。如果使用hash table，可能会存储大量的数据，而bloom filter就不需要。而对于某些应用场景，牺牲一点准确性并不会有什么太大的坏处，但却可以带来巨大的效能提升，那么就是值得的。比如bit.ly告诉用户这个短网址可能对应一个恶意网址，应该注意，这并不会有什么伤害。

##### 4.2.2 HyperLogLog

顺着平行算法的这条线，下一个算法是 [HyperLogLog](https://en.wikipedia.org/wiki/HyperLogLog)。这个算法用来解决从muiltiset(集合中运行对象重复出现)中查找出这个集合中大概有多少unique对象的问题。

假设google想要数一下 不同的搜索关键词 总共有多少个。或者亚马逊想要数一下用户每天输入的（非重复）搜索关键词有多少。回答这类问题需要大量的空间，对于google，你需要存储用户搜索过的关键词，每次有新搜索，你就需要查询数据集看这个新搜索是否已经在数据集中。

HyperLogLog 可以估算数据集中 unique elements 的数量。和 bloom filter 一样，HyperLogLog 给出的也是一个近似的答案，但它只占用很少的内存。如果你有一个很大的数据集用于查询，而你可以接受一个近似的答案，你可以查找probalilistic algorithms基于概率的算法的相关内容。

#### 5 The SHA algorithms

记得之前提到过的 hash table 的工作原理。 给出一个string key, 经过 hash function 的计算，给出value在内存中的位置。

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/Hash_table_3_1_1_0_1_0_0_SP.svg
)

这种方式只要给出key，只需要 O(1) time 就可以拿到对应的值。

SHA代表 [Secure Hash Algorithm](https://en.wikipedia.org/wiki/Secure_Hash_Algorithms)，也就是安全散列算法，这个术语中的 hash 不再指代hash function, 而是指 '散列'，也就是经过 SHA 这个hash function 计算后得出的一个字串。

- hash table 中的hash function是给出string返回位置
- SHA 本身就是一个hash function, 他也是接受一个string, 但返回的是一个经由SHA计算的 hash 散列。

在ruby中，将这种加密算法算出来的字串也称作 digest, standard library 中，有对应的生成 digest 的库，其中就包含 SHA

http://ruby-doc.org/stdlib-2.5.0/libdoc/digest/rdoc/index.html

```ruby
2.5.0 :002 > require 'digest'
 => true

2.5.0 :003 > Digest::SHA2.new(256).hexdigest 'abc'
 => "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"

2.5.0 :004 > Digest::SHA2.new(384).hexdigest 'abc'
 => "cb00753f45a35e8bb5a03d699ac65007272c32ab0eded1631a8b605a43ff5bed8086072ba1e7cc2358baeca134c825a7"

2.5.0 :005 > Digest::SHA2.new(512).hexdigest 'abc'
 => "ddaf35a193617abacc417349ae20413112e6fa4e89a97ea20a9eeee64b55d39a2192992a274fc1a836ba3c23a3feebbd454d4423643ce80e2a9ac94fa54ca49f"
2.5.0 :006 >
```

SHA 是一个家族的算法，包含 MD5, SHA-0, SHA-1, SHA-2, SHA-3。不同的算法应用场景不同，安全性之间也有差别。上面例子中的 256, 384, 512 指的是 output size(bits)，也就是算出来的hash长度，一般来说是越长越安全。


上面例子中 'abc' 即我们传给 SHA 的string, 后面很长的那串就是算出来的 hash 散列。

##### 5.1 comparing files

SHA 可以用来比较文件的一致性。比如AB两个人都下载了某个文件，现在二人想校验各自下载的文件是否完全一样，这时如果文件很大不方便传输，那么就可以双方都用 SHA 算出这个文件的 hash, 然后比较这个hash是否一样。

##### 5.2 checking passwords

SHA 的另一个应用是用于密码存储，很多应用都涉及到存储用户密码。如果gmail被黑客攻击了，拿到了数据库中所有的用户信息，那么黑客是否能进行进一步的操作？

不能，因为在数据库中存储的用户密码并不是用户原生的密码，而是经过SHA计算后得出的hash,gmail并不知道你的真实密码，你每次登陆输入密码的时候，都会由SHA生成hash, gmail是拿着这个 hash 到数据库中比对，确认你是否输入了正确的密码。

SHA 是一个 `one-way` 也就是单向的SHA，给出 string 可以算出 hash, 但反过来从 hash 出发是无法算出原始的 string 的。

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-05-03+%E4%B8%8B%E5%8D%882.26.22.png
)

##### 5.3 SHA 的 locality insensative 特性

SHA 算法有一个特点是，如果给出的字串只有少量的不同，算出来的 hash 就完全不同。这种特性可以描述为对局部变化不敏感。

```ruby
2.5.0 :004 > Digest::SHA2.new(256).hexdigest 'abc'
 => "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"

2.5.0 :005 > Digest::SHA2.new(256).hexdigest 'Abc'
 => "06d90109c8cce34ec0c776950465421e176f08b831a938b3c6e76cb7bee8790b"
2.5.0 :006 >
```

上面例子的字串中只有1个字母大小写不同，但算出的hash则完全看不出只有少量的差别。对于安全性来说，这是一个很好的特性，因为攻击者很难知道他猜的密码是否接近正确密码了。

但有时候我们想要相反的特性，也就是算出来的hash能够体现出原始string的差别程度。这也是 [Simhash](https://en.wikipedia.org/wiki/SimHash) 派上用场的地方。

wikipedia

> In computer science, SimHash is a technique for quickly estimating how similar two sets are. The algorithm is used by the Google Crawler to find near duplicate pages.

- SimHash可以用来快速估算两个集合的相似程度，google在爬网页时会用这种算法来筛查是近似的重复网页。
- 一个老师可以使用 SimHash 来检查学生提交的作业是否有抄袭嫌疑。
- [Scribd](https://zh.scribd.com/) （一个电子读物订阅网站）允许用户上传文档或书籍与其他人共享。这时它就可以使用 SimHash 来检查用户上传的内容是否存在版权侵犯嫌疑或与之前的内容重复。

“Simhash is useful when you want to check for similar items.”

摘录来自: Aditya Y. Bhargava. “Grokking Algorithms: An illustrated guide for programmers and other curious people。” iBooks.

在检查对象的相似度时， SimHash 很有用。

#### 6 Diffie-Hellman key exchange

https://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_key_exchange

最早的加密方式是给每个字母或数字对应一个密码，比如 a 对应 1, b 对应 2，这样如果要传输  dog 这个词，那么就使用 4,15,7，但这种方式很容易被破解，而且需要交流双方都有密码对照，如果密码对照丢失，就得重新再设计一套密码，如果要发送信息给很多人，那么就要复制很多份密码，发送出去，这个过程本身就不安全。从提来看这种方式安全性低，而且使用不便。

Diffie-Hellman 解决了这个问题。

- 双方都不需要有个密码本，也不需要见面交换这个密码本
- 被加密的信息极难被破解

Diffie-Hellman 加密有两个key, 一个是 **public key**， 另一个是 **private key**。

public key 可以公开发送给你的朋友，或其他人，你不需要隐藏他。 当你的朋友想要发送信息给你的时候，他们会用这个 public key 来加密信息，当你收到这个加密信息后，可以使用 private key 解开这个信息。而你是唯一拥有 private key 的人，所以只有你能揭开加密后的信息。其他人能做的只是将信息加密。

Diffie-Hellman 算法依旧在使用，比如继承他思想的加密方式 RSA。

https://en.wikipedia.org/wiki/RSA_(cryptosystem)

#### 7 Linear programming - 线性规划

线性规划用来优化某些方面具有限制的问题的答案。

比如

- 你的公司生产两种产品，T恤和手提包，做一件T恤需要1米的织物和5个纽扣，做一个手提包需要2米的织物和2个纽扣，你有11米的织物和20个纽扣。每件T恤能赚2美元，每件手提包能赚3美元。你应该怎么分配生成以达到利润最大化？ 这里你试图最大化利润，而被原料的数量限制。
- 你是一个政客，你想要最大化你的投票数量。你的研究显示，你平均需要花费1小时的努力以及2美元能获得一张来自SF的选票，需要花费1.5小时以及1美元获得一张来自芝加哥的选票。你的可用时间是50天，你的总预算是 1500美元，你应该怎么分配时间和金钱资源以获得最多数量的选票？ 这里你有两个限制，时间和钱。

之前的算法中有很多都是关于优化optimization的，他们与线性规划有什么关联？ 实际上所有 graph algorithms （基于graph这种数据结构的算法）都可以用线性规划实现。线性规划是一种更具普遍性的框架，graph 相关的问题只是他的一个子集。

线性规划使用 [Simplex algorithm](https://en.wikipedia.org/wiki/Simplex_algorithm) 单纯形算法，是一种复杂的算法。
