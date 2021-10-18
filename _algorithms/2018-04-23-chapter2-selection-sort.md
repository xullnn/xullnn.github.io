---
title:  "Algorithms 101 - 2 - selection sort"
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

### 主要内容

- Your computer’s memory is like a giant set of drawers.       
电脑的内存就像一大堆位置固定的抽屉
- When you want to store multiple elements, use an array or a list.      
当你想存储多个对象时，使用array 或 list
- With an array, all your elements are stored right next to each other.      
使用 array 存储多个对象，所有对象都会相邻地排列
- With a list, elements are strewn all over, and one element stores the address of the next one.      
使用列表list, 对象可以在内存中分散存储，每一个对象都会持有下一个对象的地址
- Arrays allow fast reads.     
array 允许更快的读取
- Linked lists allow fast inserts and deletes.      
链表允许更快的写和删
- All elements in the array should be the same type (all ints, all doubles, and so on).      
array中的所有对象应该是同一种type

---

#### 1 Your computer’s memory is like a giant set of drawers.

**内存的工作原理：**

计算机的内存就像很多格固定的抽屉。每一个空位有一个地址address，查找一个对象最快的方法是知道这个对象所在的地址，直接拿着地址去找。

> This is basically how your computer’s memory works. Your computer looks like a giant set of drawers, and each drawer has an address.”

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-17+%E4%B8%8B%E5%8D%882.22.57.png
)

每一次想要往内存中存入对象时，都需要向内存请求空间，然后内存会给你一个地址。如果要一次存入多个对象，则有两种方式来处理。arrays and linked lists：

#### 2 With an array, all your elements are stored right next to each other.

array的特点是必须作为一个整体存在于内存中，也就是前后两个对象需要‘物理上’相邻，这就要求内存中有连续的空位才能放置array。

比如有一个 array = [7,8,9]，其在内存中就要占据3个连续的，地址相邻的空位，中间不能有其他对象。


#### 3 With a list, elements are strewn all over, and one element stores the address of the next one.

linked list 链表的特性是，每一个当前位置的对象都持有它后面那个对象的地址信息，或说指向他后面那个对象，这样通过一层层的指向将多个对象的信息串在一起。比如要以链表格式存 7，8，9 三个对象到内存中，这三个对象可以分散的存储在相隔很远的地址，找的时候只要知道第一个对象的地址，就可以找到后面的对象。

> Each item stores the address of the next item in the list. A bunch of random memory addresses are linked together.

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-17+%E4%B8%8B%E5%8D%882.40.48.png
)

#### 4 Arrays 和 Linked lists 各自的特性导致他们在读写上的效能差异

差异不等于优劣。

##### 4.1 Arrays allow fast reads.

Array 在内存中必须是多个相邻的地址空间，那么在读写(删)方面的特点是：

- Reading
  - 快，找到array后从第一个对象的地址直接就可以推算出第n个对象的地址，这也是index的作用。
  https://en.wikipedia.org/wiki/Array_data_structure
- Writing
  - 能够分配到足够的连续内存空间时
    - 当要写入对象到array头部时，需要将后面所有对象移动一次，这是最慢的。
    - 当要写入对象到array中部时，这是次慢的。
    - 当要写入对象到array尾部时，相对快一点。
  - array 前后都没有内存空间时
    - 要到内存中其他地方重新找一个有足够连续地址的空间。
    - 下一次空间又不够的时候，又要重复上述过程。
    - 可以第一次就多请求冗余的地址备用，但这会浪费内存。
- Deleting
  - 慢，同样牵涉到移动剩余对象地址的问题。


##### 4.2 Linked lists allow fast inserts and deletes.

Linked list中每一个对象都持有下一个对象的地址，那么在读写(删)方面的特点是：

- Reading
  - 慢。如果要读的对象在最后，需要从第一个对象开始查，查完整个list才能知道最后那个对象的地址
- Writing
  - 快。
    - 如果是在中间位置写入，那么只用将写入对象的地址与插入位置前一个对象持有的地址交换就可以了。
- Deleting
  - 快。原理和写入类似。只用把被删对象手里拿的地址去替换掉他前一个对象记录的地址。

#### 5 Trade-offs

两种数据结构的run times比较

||Array|Linked list|
|:-:|:-:|:-:|
|reading|O(1)|O(n)|
|insertion|O(n)|O(1)|
|deleting|O(n)|O(1)|


array 还是 linked list? 看情况。 Array 允许随机读取(random access)，而 Linked list 只允许顺序读取(sequential access)。现实中 array 用得更多，因为很多情况下需要用到随机读取。Array 和 Linked list 也被用来构造其他数据结构。

> A lot of use cases require random access, so arrays are used a lot. Arrays and lists are used to implement other data structures, too.

选用那种数据结构要看实际应用中CRUD各自的频率，综合考虑选用哪种更有效率。

#### 6 Selection sort

selection sort 选择排序的逻辑是定好分类标准后，新建一个容器，每次从原容器中找到最符合标准的项放入新容器中，直至原容器中所有的项被移走。

比如数据库中有一个表，有2个columns，第1个column存储音乐作家的名字，第二个column存储该作家作品被播放的次数，总共有n个音乐家。现在要将播放次数从高到低对音乐家名字进行排序。

selection sort的做法是建一个新表
- 第1步，从原表中找到最高的，移到新表中
- 第2步，从原表中找到最高的，移到新表中
- 第n步，重复以上

这个排序的算法复杂度是 O(nxn)。但实际上从第二次开始，原容器中的项在逐渐减少，实际情况应该是：

`n + (n-1) + (n-2) + (n-3) + ... (n-n)`

> You’re right that you don’t have to check a list of n elements each time. You check n elements, then n – 1, n - 2 ... 2, 1. On average, you check a list that has ½ n elements. The runtime is O(n × ½ n). But constants like ½ are ignored in Big O notation (again, see chapter 4 for the full discussion), so you just write O(n × n) or O(n2).”

在Big O notation的衡量标准中，1/2 这类常量是会被略掉的。

selection sort 很简单，但是算法复杂度高，后面会介绍 Quick sort.

pyton 代码示例将array中的数字从小到大排列

```python
# find one smallest value in an array
# every execution O(n)
def findSmallest(arr):
    smallest = arr[0]
    smallest_index = 0
    for i in range(1, len(arr)):
        if arr[i] < smallest:
            smallest = arr[i]
            smallest_index = i
    return smallest_index

# sorting
# arr.length * O(n)
def selectionSort(arr):
    newArr = []
    for i in range(len(arr)):
        smallest = findSmallest(arr)
        newArr.append(arr.pop(smallest))
    return newArr

print selectionSort([5,3,6,2,10])

```

---

#### recap:

- Your computer’s memory is like a giant set of drawers.
- When you want to store multiple elements, use an array or a list.
- With an array, all your elements are stored right next to each other.
- With a list, elements are strewn all over, and one element stores the address of the next one.
- Arrays allow fast reads.
- Linked lists allow fast inserts and deletes.
- All elements in the array should be the same type (all ints, all doubles, and so on).

---
Exercises

2.1

Suppose you’re building an app to keep track of your finances.

Every day, you write down everything you spent money on. At the end of the month, you review your expenses and sum up how much you spent. So, you have lots of inserts and a few reads. Should you use an array or a list?

频繁的写入使用 linked list 更快。

2.2

Suppose you’re building an app for restaurants to take customer orders. Your app needs to store a list of orders. Servers keep adding orders to this list, and chefs take orders off the list and make them. It’s an order queue: servers add orders to the back of the queue, and the chef takes the first order off the queue and cooks it.

Would you use an array or a linked list to implement this queue? (Hint: Linked lists are good for inserts/deletes, and arrays are good for random access. Which one are you going to be doing here?)

用 linked list 更快。每次写入都是 O(1), 由于每次拿单子也只拿第一个所以也是 O(1)

2.3

Let’s run a thought experiment. Suppose Facebook keeps a list of usernames. When someone tries to log in to Facebook, a search is done for their username. If their name is in the list of usernames, they can log in. People log in to Facebook pretty often, so there are a lot of searches through this list of usernames. Suppose Facebook uses binary search to search the list. Binary search needs random “access—you need to be able to get to the middle of the list of usernames instantly. Knowing this, would you implement the list as an array or a linked list?

array 才允许随机存取，这样才能直接定位到中间位置的项

2.4

People sign up for Facebook pretty often, too. Suppose you decided to use an array to store the list of users. What are the downsides of an array for inserts? In particular, suppose you’re using binary search to search for logins. What happens when you add new users to an array?

- array的写入 run times 是 O(n)
- 使用 binary_search 的前提是array已经被排序，所以注入新用户之后又需要排一次序


2.5

In reality, Facebook uses neither an array nor a linked list to store user information. Let’s consider a hybrid data structure: an array of linked lists. You have an array with 26 slots. Each slot points to a linked list. For example, the first slot in the array points to a linked list containing all the usernames starting with a. The second slot points to a linked list containing all the usernames starting with b, and so on.

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-17+%E4%B8%8B%E5%8D%883.28.01.png
)

Suppose Adit B signs up for Facebook, and you want to add them to the list. You go to slot 1 in the array, go to the linked list for slot 1, and add Adit B at the end. Now, suppose you want to search for Zakhir H. You go to slot 26, which points to a linked list of all the Z names. Then you search through that list to find Zakhir H.

Compare this hybrid data structure to arrays and linked lists. Is it slower or faster than each for searching and inserting? You don’t have to give Big O run times, just whether the new data structure would be faster or slower.

用于searching时各种结构的run times
 - 混合结构是 O(1+log(n))
 - array 是 O(log(n)) 可以算与混合结构相等
 - list 是 O(n)

用于writing时各种结构的run times
 - 混合结构是 O(1+1)
 - array 是 O(log(n))
 - list 是 O(1) 可以算和混合结构相等


相较于纯array：混合结构搜索时与array相等，比list快。写入时比array快，与list相等。

相较于纯linked list：混合结构搜索时比list快，与array相等。写入时与list相等，比array快。

所以不管在哪个方面，这种array+list的混合结构都是等于或快于array或list，整体会更快。
