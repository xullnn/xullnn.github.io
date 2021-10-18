---
title:  "Algorithms 101 - 5 - hash tables"
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

#### 主要内容：

- hash table 的构造
- 影响hash table performance 的因素

---

可以使用 [hash table的wikipedia页面](https://en.wikipedia.org/wiki/Hash_table) 帮助理解这一章内容。

#### 1 什么是 Hash table

> You can make a hash table by combining a hash function with an array.

一个 hash function 和 array 配合就可以得到一个 hash table

wiki上的解释：

In computing, a hash table (hash map) is a data structure which implements an associative array abstract data type, a structure that can map keys to values. A hash table uses a hash function to compute an index into an array of buckets or slots, from which the desired value can be found.

hash table 是一种数据结构，它通过关联另一个 array 实现一种抽象数据，这种结构可以通过keys找到对应的values。Hash table 会使用一个hash function 来计算他应该到关联array的哪个index去找对应的value。

**The idea of hashing**

The idea of hashing is to distribute the entries (key/value pairs) across an array of buckets. Given a key, the algorithm computes an index that suggests where the entry can be found:

hash table的实现思想是将键值对分散到一个array空间中。给出一个key,通过算法(hash function)计算出数据所在的 index。

**Hash table的核心构成要素**

1 hash function
2 关联的 array（values存在里面）

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/Hash_table_3_1_1_0_1_0_0_SP.svg
)

#### 2 Hash functions

> A hash function is a function where you put in a string and you get back a number.

hash函数能接受一个string然后return一个数字。这里的string就是key,返回的数字就是value对应的index。

##### 2.1 hash function的特性

hash functions 指的是一类functions，而不是只有一种。吃进string后如何计算给出的数字，各个hash function之间并没有统一的算法。但有两个重要的约束：

1 输出要具有一致性 consistency

每次接受到相同的string(key)时，输出的结果应该是一样的，比如第一次给出 `apple` 给出结果是 4, 第二次还是给 `apple` 却又给出2，这样hash table无法工作。

2 输出要有差异性

字面上与第一点矛盾。但这里的前提不一样，差异性的前提是输入不同的key，比如 `apple`, `phone`, `shell` 这类不同的输入要有不同的输出。如果不管给什么key都返回同一个index，那么 hash table 也失去了意义。

##### 2.2 为什么 hash function 知道地址

书中一直讲hash table的运作原理，对这一点没重点提。

反过来想就清楚了，在提取value之前，肯定要先存储，在存储的过程中hash function就计算好了位置。下次提取的时候给出同样的key,那么算出来的位置应该是一样的，这样就能拿到正确的value,这也是上面提到的特性1的体现。

##### 2.3 为什么 hash function 不会给出超出 array index 范围的 index

> The hash function knows how big your array is and only returns valid indexes. So if your array is 5 items, the hash function doesn’t return 100 ... that wouldn’t be a valid index in the array.

hash function 知道'挂靠'的array有多大，所以给出index的时候会在这个范围内。

#### 3 Hash table 的特点

> Hash tables are probably the most useful complex data structure you’ll learn. They’re also known as hash maps, maps, dictionaries, and associative arrays.

hash table 是目前为止提到的最有用的复杂数据结构。它有时也被称作 hash maps, dictionaries, 或 associative array

##### 3.1 我们不用自己手动去构造hash table

前面提到 hash table 的两个重要构成部分是

- hash function
- 用于存储value的array

但实际应用中，我们并不需要人工去指定需要使用的 hash function 以及找到一块可用的 array 存储空间。因为多数编程语言中都以及帮我们做好的这一步，我们只需要直接用。

##### 3.2 hash table 很快

当我们给出key时，通过hash function 我们一步就拿到了对应value的index, run times 是 O(1)。

#### 4 Hash table 的应用

##### 4.1 hash table 用于查找

> Hash tables are great when you want to
- Create a mapping from one thing to another thing - 制造对象之间的一一映射关系
- Look something up - 查找对象

Hash table 的应用很广，比如电话簿就是典型的应用场景，你给出一个名字，直接就可以查找到号码。

另一个典型的应用是将网址翻译为 IP 地址，也叫 DNS resolution ，但hash table不是这项工作的唯一实现方式。

> For any website you go to, the address has to be translated to an IP address.

##### 4.2 用于防止重复

书中用一个投票的例子来比喻，一个投票活动中，每一个人只能投一次票，不能重复投，但多个投票人可以投向同一个人。

这个情景中投票的人相当于 key, 候选人(被投票的人)则是value

在hash table中，key 不能重复。用代码演示上述过程就是

```ruby
def check_voter(name)
  if voted?(name)
    puts "Kick them out"
  else
    voted?(name) = true
    puts "Let them vote."
  end
end
```

hash table 可能是这样 `{"Xullnn" => true, "Wix" => true ...}`， 这里不会有 false 的情况。

原理是这样的：

- 投票前拿着名字去找，找到了，阻止投票
- 没找到，让他投

注意，这里每种情况的run time都是 O(1)

而如果使用另一种策略，建立一个array或list来存储已经投过票的人的名字，那么每次投票前都要对这个 array/list 进行一次 simple search， 那么每次都是 O(n)。

##### 4.2 用作cache

很多大型网站都使用 hash table 原理进行 cache, 比如一些常用的页面 login, about, help, policies 等。将这些常用的网页都以hash table存起来：

- 如果客户访问的是这些网页，那么就直接可以返回内容，服务器不需要额外的计算
- 如果请求的页面包含了一些需要计算的内容，那么服务器再计算后返回

实际一个网页中也会用到这种机制，因为一个网站的主体部分是一样的，只有其中某些部分是客户相关的内容。

> This is how caching works: websites remember the data instead of recalculating it.

用代码表示上述过程就是

```ruby
cache = {}
def get_page(url)
  if cache.get(url)
    return cache[url]
  else
    data = get_data_from_server(url)
    cache[url] = data
    return data
  end
end
```

`else` 分支中又将你访问过的页面存储起来，下次你在访问的时候，又可以直接提取。

Caching is a common way to make things faster. All big websites use caching. And that data is cached in a hash!

Caching 是一种常用的提速方法，所有大型网站都使用 caching, 而这些数据都 cache 在hash table 中

---

#### 5 Collisions

##### 5.1 什么是 Collision

hash function 计算index的方式通常不是按0,1,2,3.. 这样线性分布的。而是根据某种规则比如根据给出 key 的首字母分配一个范围内的某个index。 比如 array 的index 是 0..260， 那么一个hash 算法就可以将所有首字母为'a'的key的所有value存在 0..10 之间， 同样的 'b'开头的存入 11..20 如此一直到z。

但实际情况中，出现的key不可能总是平均分布的，总会出现某个首字母的key超出10个，这样再存入相同首字母的kev/value时，之前的value就被覆盖了。

> This is called a collision: two keys have been assigned the same slot.

##### 5.2 怎么处理 Collision

> The simplest one is this: if multiple keys map to the same slot, start a linked list at that slot.

最简单的方法是从发生collision那个slot,延伸出一个 linked list 出来（注意linked list不需要内存中的连续空间）。基于 linked list 的工作方式，只要当前对象持有下一个对象的地址，就可以称作开始了一个 linked list。

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-19+%E4%B8%8B%E5%8D%887.19.46.png
)

但一种最坏的设想是，所有的key都是以某个字母开头的，那么array中剩余的slot就全是空的。而linked list查找对象的run times是 O(n)，所以hash table也就失去了快的特性。

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-19+%E4%B8%8B%E5%8D%887.23.35.png
)

但一个hash function如果是这样估计没有人会用。但这里举这个极端的例子是为了说明两点：

- hash function 十分重要。理想情况下，hash function应该将keys对应的values尽量平均地分布到array中。
- 如果collision不可避免的出现了并且某一支变得很长，那么会变得很慢。所以要选用一个好的hash function。

#### 6 Performance

前面提到了一个好的hash function应该尽量的避免collision。那么应该如何选择好的 hash function 来提高hash table的速度？

##### 6.1 hash table 的 average case 和 worst case

||average case|worst case|
|:-:|:-:|:-:|
|search|O(1)|O(n)|
|insert|O(1)|O(n)|
|delete|O(1)|O(n)|

> In the average case, hash tables take O(1) for everything. O(1) is called **constant time.** You haven’t seen constant time before. It doesn’t mean instant. It means the time taken will stay the same, regardless of how big the hash table is. For example, you know that simple search takes linear time.

wikipedia 上对 constant time的解释：

An algorithm is said to be constant time (also written as O(1) time) if the value of T(n) is bounded by a value that does not depend on the size of the input. For example, accessing any single element in an array takes constant time as only one operation has to be performed to locate it.

constant time（常量时间）指的是如果一个算法的 O(1) 的用时不论在 n 是多大的时候都是恒定的时长，那么这个时长就是 constant time.

hash table 的average case的Big O notation曲线画出来就是

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-19+%E4%B8%8B%E5%8D%887.36.45.png
)

> See how it’s a flat line? That means it doesn’t matter whether your hash table has 1 element or 1 billion elements-getting something out of a hash table will take the same amount of time.

不管hash table中存了多少个键值对, 只要给出key， hash function 只需要 O(1) 就可以定位到value， 其他对象并不会对这个过程有任何影响。

##### 6.2 如何提高hash table效能

这个问题实际上就是如何避免collision

书中提到避免collision的两个要点：

- A low 'load factor' (https://en.wikipedia.org/wiki/Hash_table#Key_statistics)
- A good hash function

##### 6.2.1 load factor

**load factor = n/k**

n is the number of entries occupied in the hash table.

k is the number of buckets.

实际就是 buckets/slots 被占用的多少。

如果array有10个空位，其中3个存储了value，那么 load factor 就是 0.3

> Load factor measures how many empty slots remain in your hash table.

当 load factor 达到1时，也就位置刚好被占满的情况。

**load factor > 1**

当 load factor 大于1时就说明 array 位置不够用了，这时就需要进行 resizing 操作。

> You need to resize this hash table. First you create a new array that’s bigger. The rule of thumb is to make an array that is twice the size.

resizing就需要重新建立一个array,这个array的空间是之前的两倍。

**resizing when load factor > 0.7**

实际情况是当 load factor 大于0.7的时候就要进行resizing操作。

**很明显的是，resizing是成本很高的操作。**

##### 6.2.2 A good hash function

> A good hash function distributes values in the array evenly.

之前提到过好的 hash function 应该能尽量的平均分配空间。坏的就是那些容易产生 collision的function。

> What is a good hash function? That’s something you’ll never have to worry about-old men (and women) with big beards sit in dark rooms and worry about that.

但好的hash function不是我们需要关注的问题，**我们不需要自己写hash function**。

##### 6.3 performance总结

上面提到的两种方法

- resizing 的方法是在出现collision时，直接重新迁移到更大的空间中。
- good hash function是通过优化分配方式来尽量避免collision

实际情况中应该是基于应用需要两个方法会结合起来用。

---

#### recap

Hash tables are a powerful data structure because they’re so fast and they let you model data in a different way. You might soon find that you’re using them all the time:

- You can make a hash table by combining a hash function with an array.        
将一个hash function和array组合起来可以得到一个hash table
- Collisions are bad. You need a hash function that minimizes collisions.      
collision 不是好东西。我们需要最小化collision的hash function。
- Hash tables have really fast search, insert, and delete.      
hash tables 快快快。
- Hash tables are good for modeling relationships from one item to another item.      
hash table 能很好的模拟对象之间的关系模型。
- Once your load factor is greater than .07, it’s time to resize your hash table.      
当hash table的 load factor大于0.7时，就应该进行 resizing 处理。
- Hash tables are used for caching data (for example, with a web server).      
hash tables可以用于网页缓存。
- Hash tables are great for catching duplicates.      
hash table 可以用来防止重复。

----

Exercises

It’s important for hash functions to consistently return the same output for the same input. If they don’t, you won’t be able to find your item after you put it in the hash table!

Which of these hash functions are consistent?

下列哪些 hash function 是具有一致性的？

1 returns '1' for all input

`f(x) = 1`

2 returns a random number every time

`f(x) = rand()`

3 returns the index fo the next empty slot in the hash table

`f(x) = next_empty_slot()`

4 uses the length of the string as the index

`f(x) = len(x)`

---

先回顾一下什么是 hash function 的一致性

一致性指的是输出的一致性，也就是当输入相同的key时，应该每次都输出同样的index

然后再来看。

1 虽然很蠢，但确实具有一致性

2 随机化，不具有一致性

3 不具有随机性，slot的占有情况可能随时在变

4 具有一致性，因为输入相同的key时，其长度是不会变的

所以是 1 和 4

---

It’s important for hash functions to have a good distribution. They should map items as broadly as possible. The worst case is a hash function that maps all items to the same slot in the hash table.

Suppose you have these four hash functions that work with strings:

Return “1” for all input.
Use the length of the string as the index.
Use the first character of the string as the index. So, all strings starting with a are hashed together, and so on.
Map every letter to a prime number: a = 2, b = 3, c = 5, d = 7, e = 11, and so on. For a string, the hash function is the sum of all the characters modulo the size of the hash. For example, if your hash size is 10, and the string is “bag”, the index is 3 + 2 + 17 % 10 = 22 % 10 = 2.

For each of these examples, which hash functions would provide a good distribution? Assume a hash table size of 10 slots.

hash function的分布性是很重要的特性。 他们应该尽量分散存储对象。最坏的情景是将所有 keys 都指向同一个slot。

假设你有下列4个hash function:

```
1 所有input都 return '1'
2 使用key的lenght作为index
3 使用首字母作为index基础
4 先将每个字母对应到一个质数，比如 a = 2, b = 3, c = 5, d = 7, e = 11, and so on. 一个key的index的算法是将这个 string 中所有字母对应的质数加起来，然后对hash size求余数。 比如 key 是 'bag', hash table 有10个slot位置，那么首先 b = 3, a = 2, g = 17， 先将质数加起来等于 22， 然后对10求余数， 22 % 10 = 2，2就是bag对应的index
```

假设hash size 是10，对于下面每一个应用场景，上述4个hash function那些能提供较好的分布性。

5.5

A phonebook where the keys are names and values are phone numbers. The names are as follows: Esther, Ben, Bob, and Dan.

```
1可以排除；
2似乎可以，但名字的长度的分布应该是正态分布，也就是名字很长和很短的人都很少，这部分人会浪费掉一些slot,导致中间长度的人名对应的slot会比较拥挤。
3可以，比如每2-3个字母对应一个slot
4也可以，相对随机

最后选 3和4
```


5.6

A mapping from battery size to power. The sizes are A, AA, AAA, and AAAA.

```
1排除
2可以，key总共就那么几个，而且每个的长度都不一样
3不行，首字母都是A
4 算一下: 四种size分别算出来是 2 4 6 8，对10求余数每个都不一样，所以可以

最后选 2 和 4
```


5.7

A mapping from book titles to authors. The titles are Maus, Fun Home, and Watchmen.

```
1排除
2不太好，后两本书的长度一样
3可以，首字母不同
4可以

最后是 3和4
```

书上给的是 234

```ruby
2.5.0 :001 > "fun home".length
 => 8
2.5.0 :002 > "watchmen".length
 => 8
```
