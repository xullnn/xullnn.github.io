---
title:  "Algorithms 101 - 6 - breadth first search"
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

#### 主要内容:

- You learn how to model a network using a new, abstract data structure: graphs.
将会学习如何使用一种新的抽象数据类型 graphs 来构建网络模型

- You learn breadth-first search, an algorithm you can run on graphs to answer questions like, “What’s the shortest path to go to X?”
学习广度优先搜索，这是一种用于 graphs 数据结构上的算法，用他你可以回答诸如"两点之间最短路径"的问题。

- You learn about directed versus undirected graphs.
学习有向图形和无向图形。

- You learn topological sort, a different kind of sorting algorithm that exposes dependencies between nodes.
学习拓扑搜索，一种不同的，可以揭露节点之间的从属依赖关系的算法。（也是用于graphs数据结构上）

---

ruby-graph-algorithm

https://github.com/brianstorti/ruby-graph-algorithms

breadth-first search 可以找到两节点间的最短距离，但这里的最短距离可以映射到很多事情上比如：

- 写一个AI跳棋程序计算取得胜利的最少步数。
- 写一个使用最少步骤修正拼写错误的拼写检查器。
- 从关系网中找到离你最近的医生。

---

#### 1 Graphs 数据类型

> In mathematics, and more specifically in graph theory, a graph is a structure amounting to a set of objects in which some pairs of the objects are in some sense "related".

在数学中，准确的说是在图论中，graph 是一种结构表达。他能够模拟出一系列对象中某些对象存在'关联'的结构。

-- https://en.wikipedia.org/wiki/Graph_(discrete_mathematics)

##### 1.1 从A到B地，最少的换乘次数

假设从A点到B点有很多条可能的线路，每个节点代表一次换乘，找到最少换乘次数的路线。

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-24+%E4%B8%8A%E5%8D%8811.03.58.png
)

解这类问题的方法是：
- 将问题以图表方式表达
- 使用 breadth-first search

##### 1.2 What is graphs

> A graph models a set of connections.

graph可以模拟一系列连接。

graph 的基本结构是 node 和 edge，node指发生连接的对象， edge 是用线表示nodes之间的关系。

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-24+%E4%B8%8A%E5%8D%8811.14.07.png
)

##### 1.3 Neighbor

上面graph中的 edge 右边有一个箭头，这代表了关系的走向。edge 有箭头的graph称作，directed graph 有向图形。而紧邻当前对象的，箭头所指对象被称为当前对象的neighbor。A指向B 那么 B是A的neighbor，但A不是B的neighbor。neigbor关系具有方向性。

graphs是一种模拟不同事物之间联系的表达方式。


#### 2 Breadth first search

不同于之前用过的binary search， breadth-first search 是用在图形上的算法，他帮助我们解决两类问题：

- 从节点 A 到 B 是否有可用路径。
- 从A到B的最短路径。

##### 2.1 Is there a path?

假设你是一个芒果果园园主，你想要在你的朋友网络中找到关系最近的芒果卖家。初看这个问题不像是'is there a path'这类问题，但实际上可以把你要找到的芒果卖家设为一个关系网络中具有具体特征的node， 然后你要找出你的关系网中是否有路径可以到达这样一个节点。

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-24+%E4%B8%8B%E5%8D%8812.55.59.png
)

这类搜索中，你不仅要搜索你的直接朋友，你还要搜索你朋友的朋友，甚至更多层关系。

每一对关系中，当前节点的人的朋友就可以视作他的neighbor节点。

> With this algorithm, you’ll search your entire network until you come across a mango seller. This algorithm is breadth-first search.

这种搜索的方式就是广度优先搜索。

##### 2.2 Finding the shortest path

对应到找芒果卖家的案例就是找到离我最近的芒果卖家。"Can you find the closest mango seller?"

这类搜索中你的直接朋友即算作第一层级的连接, first level connection，朋友的朋友是 second level connection 以此类推。

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-24+%E4%B8%8B%E5%8D%881.13.28.png
)

**搜索是从第一层级开始，在搜索完整个第一层级后，才会搜索第二层级。** 这样当网络中有多个符合条件的节点/路径时， 你将总是找到最近的那个。

我们可以把要搜索的节点放到一个队列中`queue`中，先放第一层的，然后后面一层一层放。然后从queue中依次拿出进行搜索。

##### 2.3 Queue

`Queue` 类似真实世界中人们排队的情形，先来的排在前面，后来的排后面，出队的时候是排在前面的先出。也就是 First in First out。

> Queues are similar to stacks. You can’t access random elements in the queue. Instead, there are two only operations, enqueue and dequeue.

上面案例中搜索芒果的案例中，第一层的节点最先被加入 queue, 当搜索开始时，先拿出来的也是第一层的节点。这一点和 Stack 不同，Stack中积压的function是，最后一个也就是最上层的完成后才能进行前面的，直至Stack发源的那个function。 当queue有一点和stack相同的是，对象的完成都必须遵循一个顺序，不能随机的取出对象。

> The queue is called a FIFO data structure: First In, First Out. In contrast, a stack is a LIFO data structure: Last In, First Out.

#### 3 Finding the mango seller

这一小节将用代码实现找到芒果卖家的案例。

##### 3.1 用hash table建立关系网模型

一个问题是如何实现关系的指向 比如 a 指向 b， 作者提到的是用 Hash table。由于可能存在一个节点可能存在指向多个节点的问题，而同一个hash中key具有唯一性，所以可以将其neighbor放到一个array中。

python

```python
graph = {}
graph["you"] = ["alice", "bob", "claire"]
```

到到末端节点也就是往下没有朋友时就使用空 array

```python
graph["Some"] = []
```

完成整个hash table

```python
graph["you"] = ["alice", "bob", "claire"]
graph["bob"] = ["anuj", "peggy"]
graph["alice"] = ["peggy"]
graph["claire"] = ["thom", "jonny"]
graph["anuj"] = []
graph["peggy"] = []
graph["thom"] = []
graph["jonny"] = []
```

**directed graph 和 undirected graph**， 之前提到的当一个节点指向另一个节点时，这类graph叫directed graph 有向graph，而如果两个节点相互指向，则是undirected graph无向graph。

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-24+%E4%B8%8B%E5%8D%881.41.52.png
)

在 undirected graph 中，两个节点互为neighbor

> An undirected graph doesn’t have any arrows, and both nodes are each other’s neighbors. For example, both of these graphs are equal.

##### 3.2 代码实现

python伪代码
```python
  def search(name):
    search_queue = deque() # 新建queue
    search_queue += graph[name] # 中心节点的所有neighbor
    searched = []
    while search_queue:
      person = search_queue.popleft() # 拿出一个neighbor
      if not person in searched:
        if person_is_seller(person):
          print person + " is a mango seller!"
          return True
        else:
          search_queue += graph[person] # 若不是seller，把他的朋友加到queue中
          searched.append(person)
    return  False

  search("you")
```

大体思路是先把中心节点的neigbors加到queue中，然后依次拿出来比对，比对成功时即退出function返回true, 比对失败一个就把这个node的neighbors加到queue中，这样如果第一层级的neighbors搜索全部失败之后，第一层级所有人的neighbors也全部加到 queue中，while loop 会进行进直到 queue中排空。

`if not person in searched:` 条件的作用是，在关系网中可能存在互为neighbor的情况，那么搜索过程中就可能陷入循环在两个对象上一直交换，不断将对方加到queue中。所以存储一个已经处理过的对象，这样可以直接跳过处理过的对象。

##### 3.3 Running time

如果你进行上述搜索，那么你会历经每一个 edge, 所以算法复杂度至少是 O(n of edges)

同时你还要在queue中不断注入搜索节点，那么算法复杂度又要加上 O(n of friend)

所以是 O(n of edges + n of nodes)

在graph的属于中，每个节点也叫做 vertex ，所以 breadth first search 的算法复杂度表达为

**O(V+E)**

> and it’s more commonly written as O(V+E) (V for number of vertices, E for number of edges).

#### 4 Ruby 代码的一种实现

尝试用ruby写出上述过程，但不同的是没有使用hash table来模拟关系网，是用 class 以及对象属性来模拟。

```ruby
# Every new Person instance will get a random name
# will set :is_seller to false
# will get an empty array's friends
class Person
  attr_accessor :name, :is_seller, :friends
  def initialize
    @name = ('a'..'z').to_a.sample(5).join.capitalize!
    @is_seller = false
    @friends = []
  end
end

def make_friends(n)
  friends = []
  n.times { friends << Person.new}
  return friends
end

# create central node person
central_person = Person.new; central_person.name = "Center_node"

# make 4 friends for central person
central_person.friends = make_friends(4)

# for each central person's friends, make 3 friends for them
# thus we get 1 + 4 + 4*3 == 17 person in all levels
central_person.friends.each { |f| f.friends = make_friends(3) }

# Randomly choose one person as seller in the second level
seller = central_person.friends.sample.friends.sample
seller.is_seller = true
puts "This time seller is: #{seller.name}"


def search_seller(center)
  search_queue = Queue.new
  search_queue << center
  searched = []
  while search_queue # or say until search_queue.empty?
    person = search_queue.pop
    if person.is_seller
      puts "#{person.name} is seller!"
      return true
    else
      if !person.friends.empty? && !searched.include?(person) # this avoids error when touching end point person
        person.friends.each { |f| search_queue << f }
        searched << person
      end
    end
  end
  puts "No seller"
  return false
end

search_seller(central_person)
```

[将过程注释出来](https://gist.github.com/gitXullnndish/f65f36ab990ab805ad53febc435ac558)，可以看到搜索的顺序是按层级展开的

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/Snip20180420_1.png
)

---

#### Recap

- Breadth-first search tells you if there’s a path from A to B.      
广度优先搜索告诉你从A到B是否有路径。
- If there’s a path, breadth-first search will find the shortest path.      
广度优先搜索告诉你两点之间的最短路径。
- If you have a problem like “find the shortest X,” try modeling your problem as a graph, and use breadth-first search to solve.      
如果有类似找到到X的最短路径的问题，可以将问题抽象为 graph, 然后使用广度优先搜索。
- A directed graph has arrows, and the relationship follows the direction of the arrow (rama -> adit means “rama owes adit money”).     
有向graph具有箭头指向，表示的关系也遵循这个指向。
- Undirected graphs don’t have arrows, and the relationship goes both ways (ross - rachel means “ross dated rachel and rachel dated ross”).     
无向graph没有箭头(或说两边都有箭头)，表示双向关系。
- Queues are FIFO (First In, First Out).        
Queues 是先进先出
- Stacks are LIFO (Last In, First Out).    
Stacks是后进先出。
- You need to check people in the order they were added to the search list, so the search list needs to be a queue. Otherwise, you won’t get the shortest path.      
进行广度优先搜索时，搜索的顺序很重要，所以我们用Queue来处理。
- Once you check someone, make sure you don’t check them again. Otherwise, you might end up in an infinite loop.     
一旦你搜寻过某个目标了，要确保你不会再次搜索他，不然可能会陷入无限循环。

---
