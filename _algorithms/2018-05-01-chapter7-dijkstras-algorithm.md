---
title:  "Algorithms 101 - 7 - dijkstra's algorithm"
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

- We continue the discussion of graphs, and you learn about weighted graphs: a way to assign more or less weight to some edges.   
继续讨论 graphs 这种数据结构, 不过是带有weight权重的graphs: 这种graphs会给edges赋予不同的weight
- You learn Dijkstra’s algorithm, which lets you answer “What’s the shortest path to X?” for weighted graphs.     
将会学习 Dijkstra 算法，用来计算两点之间最小weight的问题。

---

说明：此章内容理解比较依赖对graph整体图景的把握，作者为了表达上的具体生动，使用了很多具象的名称附加到graph上。个人认为反而增加的理解难度，尤其对非英语母语的人。因此代码示例会使用另外一个例子，这个例子取自 youtube 上的一个教学视频，讲解相对清楚。其他部分内容会综合书中讲解展开。

视频地址：  https://www.youtube.com/watch?v=5GT5hYzjNoo

---

#### 1 导言

首先回顾前面breadth first search的内容。在breadth first search中，我们以源vertex作为起点，逐层扫描neighbor节点，直至找到目标对象或路径。在整个过程中每个edge被视作完全相等的。这是一种相对理想的状态，实际情况中，两两对象之间的距离，或抵达成本，或其他成本往往是不同的。

A到B以及A到C,同样都只经过1个edge
- 但A到B可能是100米
- B到C可能是50米

那么就可以说这两个edge具有不同的weight。

对应到两点之间的乘车问题，空间最省的不一定是时间最省的。
- A -> C -> D 总路程是 50km， 总耗时100分钟。(省道)
- A -> B -> D 总路程是 100km, 但总耗时也许只要50分钟。(高速)

所以将什么属性作为edge的weight也是视具体要解决的问题，或优先要考虑的因素而定。可以把每段路程的耗时作为weight也可以把每段路程的长度作为weight。甚至可以把每段路程的舒适程度或风景好坏程度作为weight。

书中例子使用的是两点之间的耗时作为weight。

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-24+%E4%B8%8B%E5%8D%883.27.58.png
)

这种在graph上计算edge带weight的问题的算法之一就是， Dijkstra's algorithm。

https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm

**weighted graph 和 unweighted graph**

根据名称，定义就很清楚了。

#### 2 Working with Dijkstra’s algorithm

##### 2.1 Dijkstra's algorithm's basic steps

基于找到两点间最省时的例子，Dijkstra 算法遵循的几个（循环）基本步骤是：

每个node的节点值指的是从起点node到达这个node所历经的所有edges的weight的总和，而起点node到达某node的路径可能有很多条，那么可能的weight就有很多个。

1. 找到最目前最省时的node,如果是刚开始时就是源节点，可以把此时的weight视作0

2. 找到当前node的所有neighbors, 用当前最省时node的weight分别加上到达其各个neighbor的的weight值。然后比对更新
- 如果某个neighbor还没有weight值，那么就把算出来的值作为他的weight保留
- 如果某个neighbor已经有了weight值
  - 如果算出来新的weight比原有的小，就取代之
  - 否则仍然保留原来的weight

3. 排除刚刚作为源节点的node, 留下剩余节点，重复上面的过程，先找到weight最低的node，然后计算，更新，直至所有node都被作为当前最低weight的node处理过之后

4. 计算最终结果

##### 2.2 Meeting cycles and negative weights

**关于cycle**

之前提到 Dijkstra's algorithm 无法处理graph中存在cycle的情况。这是一个错误陈述。

https://stackoverflow.com/questions/43394847/dijkstras-algorithm-and-cycles

如果使用一个array来逐步记录已经作为中心节点处理过的 nodes, 那么不仅edge全是正数的cycle，连**某些**带负数的cycle也可以处理。

**关于negative weight**

而关于negative weight, 某些情况下下dijkstra's algorithm可以处理，有些则不能。下面这些回答中包含两种情况，问题中包含的情况，negative weight 没有影响到最后结果的正确性，而回答中给出了一个会影响结果的例子。

Negative weights using Dijkstra's Algorithm

https://stackoverflow.com/questions/6799172/negative-weights-using-dijkstras-algorithm?rq=1

https://stackoverflow.com/questions/13159337/why-doesnt-dijkstras-algorithm-work-for-negative-weight-edges

但cycle和negative weight的情况相对特殊，下面讨论都以排除这两种情况为前提。

##### 2.3 Trading for a piano

书上给出的例子：

Rama is trying to trade a music book for a piano.

“I’ll give you this poster for your book,” says Alex. “It’s a poster of my favorite band, Destroyer. Or I’ll give you this rare LP of Rick Astley for your book and $5 more.” “Ooh, I’ve heard that LP has a really great song,” says Amy. “I’ll trade you my guitar or drum set for the poster or the LP.

“I’ve been meaning to get into guitar!” exclaims Beethoven. “Hey, I’ll trade you my piano for either of Amy’s things.”

Perfect! With a little bit of money, Rama can trade his way from a piano book to a real piano. Now he just needs to figure out how to spend the least amount of money to make those trades. Let’s graph out what he’s been offered.”

摘录来自: Aditya Y. Bhargava. “Grokking Algorithms: An illustrated guide for programmers and other curious people。” iBooks.

Rama 手里有1本book，他想用这本 book 去交换些什么东西（实际他也许并不知道他最后可能换到1台piano）接下来的剧情是：
- Alex 愿意无条件用 poster 换 Rama的 book
- Alex 同时也愿意收取 Rama 5块钱把自己的 LP 换成 Rama 的 book
- Amy 愿意用自己的Guitar(收15块) 或 Drum(收35块) 换 Alex 的 LP
- Beethoven 愿意用自己的piano 换 Amy 的 Guitar(收20块) 或 Drum(收10块)

这整个是一个交叉的网状结构，使用graph将其在图面上表达出来才能较好理解其中关系。

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-24+%E4%B8%8B%E5%8D%887.54.23.png)


回顾一下 Dijkstra's algorithm 的套路

1. 找到最目前weight最小的node,如果是刚开始时就是源节点，可以把此时的weight视作0

2. 找到当前node的所有neighbors, 用当前最省时node的weight分别加上到达其各个neighbor的的weight值。然后比对更新
- 如果某个neighbor还没有weight值，那么就把算出来的值作为他的weight保留
- 如果某个neighbor已经有了weight值
  - 如果算出来新的weight比原有的小，就取代之
  - 否则仍然保留原来的weight

3. 排除刚刚作为源节点的node, 留下剩余节点，重复上面的过程，先找到weight最低的node，然后计算，更新，直至所有node都被作为当前最低weight的node处理过之后

4. 计算最终结果


表格化的计算过程：

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/piano.jpg
)

简单描述这个过程：

第一步：
- 将 book 作为中心节点， 并把他的 weight 设为0，记录下其parent node，还是 book, 也可以理解从 book 到 book 的weight 是 0。这一步相当于设置一个初始状态。
- 然后计算从 book 节点到其所有neighbors的weight，将他们的parent都记为book。book不能直接到达的点设为 Infinity
- 将 book 加入 processed nodes 数组，锁定book节点的weight值，不再更新。
- 从此行剩余的节点中找出 weight 最低的那个-- Poster， 将其作为下一次计算的中心节点

第二步：
- 将 Poster 作为中心节点。
- 然后计算从 Poster 节点到其所有neighbors的weight
  - 如果算出来的值小于之前这个neighbor节点的记录值，那么更新其weight以及parent(设为poster, 因为你经过poster找到到达这个neighbor更短的线路)
  - 如果算出来的值大于等于其neighbor之前的weight值，那么保持不变
  - 不能抵达的仍然保持 Infinity
- 将 poster 加入 processed nodes 数组，锁定poster节点的weight值，不再更新。
- 从此行剩余的节点中找出 weight 最低的那个-- LP ， 将其作为下一次计算的中心节点

如此循环，直至中心计算节点到达目标 piano。

##### 2.4 代码实现思路

这类带有指向的结构作者同样使用了 hash table 的方式。

1 首先使用一个 costs hash 来追踪每个node当前的weight值
  - 比如对应到上面book-piano的第一步就记录为
  `costs = { "book" => 0, "poster" => 0, "LP" => 5, "Guitar" => Infinity, "Drum" => Infinity, "Piano" => Infinity }`

2 同样使用一个 parents hash 来追踪每一个node的 parent 变化
`parents = { "book" => nil, "poster" => "book", "LP" => "book", "Guitar" => nil, "Drum" => nil, "Piano" => nil}`

3 还需要一个 hash 来记录每个 edge 的weight值，但edge没有名称，所以加上一层嵌套用 `{中心节点 => { neighbor1 => D1, neighbor2 => D2 }}` 这样的结构模拟
比如 `graph = { "book" => { "Lp" => 5, "Poster" =>0 }, "Poster" => { "Guitar" => 30, "Drums" => 35 } ...... }` 这样一直记完所有节点

4 用一个 Array 来记录已经当做中心节点处理过的 nodes `proccessed_nodes = []`


**hash tables的使用方法**

- costs hash 是一个会不断更新的 hash, 随着不断找到新的 weight 更低的路径，取得某个node当前的weight值只用 `costs[node]`
- parents hash 的更新跟 costs 同步，因为新的路径表明着更换了新的parent node
- 如果要取得某一段edge的weight, 使用 graph hash 比如 `graph['post']['Guitar']` 可以拿到从 poster 到 Guitar 这段edge的weight
- 使用 array 记录已经当做中心节点处理过的 node 的原因是
  - 每一次当做中心节点的node,都是从前一步中选出的最低weight所在的node，这个node将被视作到它的最小weight，以后不再更新
  - 记录下这部分node，可以避免遇到cycle陷入循环或重复处理某些nodes。

利用上面的 hash 和 array 我们就将整个 graph 结构抽象了出来，下一步就只需要用代码模拟 Dijkstra's algorithm 的循环步骤

##### 2.5 简化版案例的 python 伪代码

书中给出了一个更简化的例子

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-24+%E4%B8%8B%E5%8D%889.03.05.png
)


同样需要先把节点以及节点之间的edge抽象为 hash table, 步骤省略。看伪代码

python:

```python
def find_lowest_cost_node(costs):
  lowest_cost = float("inf")
  lowest_cost_node = None
  for node in costs:
    cost = costs[node]
    if cost < lowest_cost and node not in processed:
      lowest_cost = cost
      lowest_cost_node = node
  return lowest_cost_node


node = find_lowest_cost_node(costs) # 初始化 costs
while node is not None:
  cost = costs[node]
  neighbors = graph[node]
  for n in neighbors.keys():
    new_cost = cost + neighbors[n]
    if costs[n] > new_cost:
      costs[n] = new_cost
      parents[n] = node
  processed.append(node)
  node = find_lowest_cost_node(costs) # 找到下一个中心节点
```

#### 3 Ruby 代码实现

Ruby 代码graph基于前面提到的视频，其graph是这样的

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-21+%E4%B8%8B%E5%8D%8811.02.40.png
)

当然这里已经给出结果，具体过程可以看原视频。

**注：代码中对象的命名尽量使用表意的名称，所以会比较长，但看起来会比较好理解**


##### 3.1 无 class 封装版本

注意这里准备各种hash的过程有些是在不同 methods 中利用 graph_segments hash 生成，这样灵活度会高些

不然每次要改3个hash

```ruby
from_a = { "a" => { "b"=>8, "d"=>5, "c"=>2 } }
from_b = { "b" => { "d"=>2, "f"=>13 } }
from_c = { "c" => { "d"=>2, "e"=>5 } }
from_d = { "d" => { "b"=>2, "e"=>1, "f"=>6, "g"=>3 } }
from_e = { "e" => { "g"=>1 } }
from_f = { "f" => { "g"=>2, "h"=>3 } }
from_g = { "g" => { "f"=>2, "h"=>6 } }
from_h = { "h" => { "h"=>0 }}

graph_segments = [from_a, from_b, from_c, from_d, from_e, from_f, from_g, from_h].reduce { |graph, hash|  graph.merge! hash }

# ---------------------------------------------------------

def all_nodes(graph_segments)
  graph_segments.keys
end

def initialize_costs(all_nodes, source_vertex)
  costs = { source_vertex => 0 }
  (all_nodes - [source_vertex]).each { |node| costs[node] = Float::INFINITY }
  costs
end

def initialize_parents(nodes)
  parents = {}
  nodes.each { |node| parents[node] = nil }
  parents
end

def calculate_costs(graph_segments, source_vertex)
    nodes = all_nodes(graph_segments)
    current_proccessing_node = source_vertex
    unproccessed_nodes = nodes
    costs = initialize_costs(nodes, source_vertex)
    parents = initialize_parents(nodes)

    while unproccessed_nodes.include?(current_proccessing_node)
      lowest_cost = costs[current_proccessing_node]
      neighbors = graph_segments[current_proccessing_node].keys

        neighbors.each do |neighbor|
          new_cost = lowest_cost + graph_segments[current_proccessing_node][neighbor]
          if new_cost < costs[neighbor]
            costs[neighbor] = new_cost
            parents[neighbor] = current_proccessing_node
          end
        end

      unproccessed_nodes -= [current_proccessing_node]
      proccessed_nodes = nodes - unproccessed_nodes
      lowest_cost = costs.values_at(*(unproccessed_nodes)).min
      possible_lowest_cost_nodes = costs.select { |k, v| v == lowest_cost }
        proccessed_nodes.each do |proccessed_node|
          possible_lowest_cost_nodes.delete(proccessed_node)
        end
      current_proccessing_node = possible_lowest_cost_nodes.key(lowest_cost)
    end

    puts "\nFinal updated costs from source_vertex is: \n #{costs}"
    puts "\nFollowing the lowest cost path, every node's parent is: \n #{parents} \n"
end

calculate_costs(graph_segments, "a")


# Notice towarding the end of calculate_costs method, there is a possible_lowest_cost_nodes
# The operations below aim to avoid situation like this:
# At some point in costs, there might have multi nodes point to a same value
# If these nodes include a proccessed one, it should have cleared out from
# the unproccessed_nodes array
# But if we use current_proccessing_node = costs.key(lowest_cost)
# to update the node that will be handled in next loop, it may choose
# the proccessed one.
# Thus will lead while condition fail, then the whole procedure is broken

# The solution is choosing next current_proccessing_node only from unproccessed_nodes
```

结果

```ruby
Final updated costs from source_vertex is:
 {"a"=>0, "b"=>6, "c"=>2, "d"=>4, "e"=>5, "f"=>8, "g"=>6, "h"=>11}

Following the lowest cost path, every node's parent is:
 {"a"=>nil, "b"=>"d", "c"=>"a", "d"=>"c", "e"=>"d", "f"=>"g", "g"=>"e", "h"=>"f"}
```

##### 3.2 使用 class 封装

这里将 Graph 抽成一个 class, 这样每一个新的 graph 都可以用一个 Graph 的 instance 代表

将 dijkstra's algorithm 写成一个 instance method 这样可以对不同的 graph 都进行计算，适用度更广。


```ruby
# For every new Graph object
# graph_segments is the hash we need to give, based on it, we get ` :nodes, :weights, :parents` while initializing a new Graph instance
# Except for `:nodes` attribute, all the other attributes are implemented by hash.


class Graph
  attr_accessor :nodes, :graph_segments, :weights, :parents

  def initialize(graph_segments)
    @graph_segments = graph_segments
    @weights = { }
    @nodes = graph_segments.keys
    @nodes.each { |node| @weights[node] = Float::INFINITY }
    @parents = {}
    @nodes.each { |node| @parents[node] = nil }
  end


  def calculate_weights_from(source_vertex)
      weights[source_vertex] = 0
      current_proccessing_node = source_vertex
      unproccessed_nodes = nodes

      while unproccessed_nodes.include?(current_proccessing_node)
        lowest_weight = weights[current_proccessing_node]
        neighbors = graph_segments[current_proccessing_node].keys

          neighbors.each do |neighbor|
            new_weight = lowest_weight + graph_segments[current_proccessing_node][neighbor]
            if new_weight < weights[neighbor]
              weights[neighbor] = new_weight
              parents[neighbor] = current_proccessing_node
            end
          end

        unproccessed_nodes -= [current_proccessing_node]
        proccessed_nodes = nodes - unproccessed_nodes
        lowest_weight = weights.values_at(*(unproccessed_nodes)).min
        possible_lowest_weight_nodes = weights.select { |k, v| v == lowest_weight }
          proccessed_nodes.each do |proccessed_node|
            possible_lowest_weight_nodes.delete(proccessed_node)
          end
        current_proccessing_node = possible_lowest_weight_nodes.key(lowest_weight)
      end

      puts "\nFinal updated weights from source_vertex is: \n #{weights}"
      puts "\nFollowing the lowest weight path, every node's parent is: \n #{parents} \n"
  end

end


from_a = { "a" => { "b"=>8, "d"=>5, "c"=>2 } }
from_b = { "b" => { "d"=>2, "f"=>13 } }
from_c = { "c" => { "d"=>2, "e"=>5 } }
from_d = { "d" => { "b"=>2, "e"=>1, "f"=>6, "g"=>3 } }
from_e = { "e" => { "g"=>1 } }
from_f = { "f" => { "g"=>2, "h"=>3 } }
from_g = { "g" => { "f"=>2, "h"=>6 } }
from_h = { "h" => { "h"=>0 }}

graph_segments = [from_a, from_b, from_c, from_d, from_e, from_f, from_g, from_h].reduce { |graph, hash|  graph.merge! hash }

graph = Graph.new(graph_segments)
graph.calculate_weights_from("a")
```

这里的结果和上面没有class的一样，这里并不一定要把 `a` 作为 souurce_vertex， 可以使用其他 vertex

比如 c: `graph.calculate_weights_from("c")`

```ruby
Final updated weights from source_vertex is:
 {"a"=>Infinity, "b"=>4, "c"=>0, "d"=>2, "e"=>3, "f"=>6, "g"=>4, "h"=>9}

Following the lowest weight path, every node's parent is:
 {"a"=>nil, "b"=>"d", "c"=>nil, "d"=>"c", "e"=>"d", "f"=>"g", "g"=>"e", "h"=>"f"}
```

注意这里某些点对应的是 Infinity, 这是因为用于计算的 graph 是 directed graph 就是有向的，这意味着从某些点出发是不能到达某些点的。在定义 graph_segments 的时候，实际就定义好了 edges 的方向。比如 c 节点当时是这样定义的

`from_c = { "c" => { "d"=>2, "e"=>5 } }`

那么c就只能往 d 或者 e 走， 而 d 和 e 相关的 edges 也是有方向的，这就导致从 c 出发是无法到达 a 的，所以距离是 INFINITY

同样在定义 h 节点时，他没有neighbors, 也就是只有 f 和 h 指向他，而他自己没有指向任何其他节点，所以如果你从 h 出发，那么除它本身对应的weight是0以外，其他节点应该都是 INFINITY

`graph.calculate_weights_from("h")`

```ruby
Final updated weights from source_vertex is:
 {"a"=>Infinity, "b"=>Infinity, "c"=>Infinity, "d"=>Infinity, "e"=>Infinity, "f"=>Infinity, "g"=>Infinity, "h"=>0}

Following the lowest weight path, every node's parent is:
 {"a"=>nil, "b"=>nil, "c"=>nil, "d"=>nil, "e"=>nil, "f"=>nil, "g"=>nil, "h"=>nil}
```

---

#### Recap

作为回顾，可以再看下 wikipedia 上Dijkstra's algorithm 的 gif 图，他和breadth-first search的基本行为模式类似，都是逐层展开。

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/Dijkstra_Animation.gif
)

- Breadth-first search is used to calculate the shortest path for an unweighted graph.     
广度优先搜索只适用于 unweighted graph
- Dijkstra’s algorithm is used to calculate the shortest path for a weighted graph.     
Dijkstra's algorithm 可以用于 weighted graph 的计算
- Dijkstra’s algorithm works when all the weights are positive.      
当所有edge的weight 是正数时，Dijkstra's algorithm 可以很好的工作（负数状态其实不太会在现实中出现）

---

附：

一个将 graph 相关算法用 ruby 写出来的 git repo

https://github.com/brianstorti/ruby-graph-algorithms
