---
title:  "Algorithms 101 - 8 - greedy algorithm"
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

- You learn how to tackle the impossible: problems that have no fast algorithmic solution (NP-complete problems).      
学习如何处理不可能解决的问题：那些没有有效快速算法可以解决的问题(NP-complete problems)
- You learn how to identify such problems when you see them, so you don’t waste time trying to find a fast algorithm for them.      
学习如何识别 NP-complete problems, 这样你不用耗费时间去找最有效解决方案
- You learn about approximation algorithms, which you can use to find an approximate solution to an NP-complete problem quickly.     
学习近似算法，可以得到用来解决NP-complete problems的近似答案的算法
- You learn about the greedy strategy, a very simple problem-solving strategy.      
学习greedy策略，一种简单的问题解决策略

---

> A greedy algorithm is an algorithmic paradigm that follows the problem solving heuristic of making the locally optimal choice at each stage with the hope of finding a global optimum.

https://en.wikipedia.org/wiki/Greedy_algorithm

greedy algorithm 是一种算法范式，这类范式遵循启发式的问题解决思路，每一步决策都做出当前能找到的最佳选择，以此希望最终得到一个全局的最佳解。

#### 1 The classroom scheduling problem

现在有这样一张课表，问怎么选课可以选到最多门

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-25+%E4%B8%8B%E5%8D%884.33.27.png
)

方法很简单，选择一门最早结束的课，然后从剩下的能选的课中继续选最早结束的一门，直至没课可选。

这即是 greedy algorithm 的基本思路，每次都在当前这一步选择能见范围内的最优选择。

> In technical terms: at each step you pick the locally optimal solution, and in the end you’re left with the globally optimal solution.

#### 2 Greedy algorithm doesn't promise a best solution every time

提出了一个使用 greedy algorithm 没能找到最佳解的例子。

一个贼去偷东西
- 贼的包总共能装35磅赃物
- 现在店里有3件东西
  - stereo 重 30磅 值 3000
  - laptop 重 20磅 值 2000
  - guitar 重 15磅 值 1500

贼的目的是偷到的东西的金额最大化，所以它的greedy algorithm是
- 先选择一个最值钱的
- 之后每次选能装下的最值钱的

结果是

step1: stereo 最值钱 3000， 装进去， 包还剩 5 磅
step2: 另外两件重量都大于 5 磅，于是装完了

最后得到的赃物价值 3000

但实际上如果装 laptop 和 guitar 那么刚好装满 35 磅，得到了价值 3500的东西，也就是greedy algorithm 没能做出最佳选择。

> sometimes, perfect is the enemy of good. Sometimes all you need is an algorithm that solves the problem pretty well. And that’s where greedy algorithms shine, because they’re simple to write and usually get pretty close.

有时完美是好的敌人。很多时候我们需要的只是一个能很好解决问题的方法而不是一个绝对完美的方法。这也是greedy algorithm 能派上用场的地方，因为它简单，而且通常能得到接近最佳解的方案。

#### 3 The set-covering problem

给出了一个关于最佳覆盖策略的例子。

假设你要播出一个广播，广播的覆盖需要借助广播站，在美国各州散落有诸多广播站
- 每一个广播站可以覆盖附近的2~3个州
- 某些广播站的覆盖范围有部分重叠

现在目标是使用尽量少的广播站覆盖到目标州（比如你选中了十几个州），以此节约成本。

图上示意这个状态如下：

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-25+%E4%B8%8B%E5%8D%884.59.37.png
)

##### 3.1 exact algorithm

如果要找出**确切**的最佳解应该怎么做？

step1: 将所有的station作排列组合，不是两两组合，而是找出从 1..n 个station的组合，比如有station: A, B, C, D, E, F, G，他们所有的组合是(用ruby表示)：

```ruby
2.5.0 :007 > stations = %w[A B C D E F G]
 => ["A", "B", "C", "D", "E", "F", "G"]

2.5.0 :008 > stations.combination(1).to_a
 => [["A"], ["B"], ["C"], ["D"], ["E"], ["F"], ["G"]]
2.5.0 :009 > stations.combination(1).to_a.size
 => 7

2.5.0 :010 > stations.combination(2).to_a
 => [["A", "B"], ["A", "C"], ["A", "D"], ["A", "E"], ["A", "F"], ["A", "G"], ["B", "C"], ["B", "D"], ["B", "E"], ["B", "F"], ["B", "G"], ["C", "D"], ["C", "E"], ["C", "F"], ["C", "G"], ["D", "E"], ["D", "F"], ["D", "G"], ["E", "F"], ["E", "G"], ["F", "G"]]
2.5.0 :011 > stations.combination(2).to_a.size
 => 21

2.5.0 :012 > stations.combination(3).to_a
 => [["A", "B", "C"], ["A", "B", "D"], ["A", "B", "E"], ["A", "B", "F"], ["A", "B", "G"], ["A", "C", "D"], ["A", "C", "E"], ["A", "C", "F"], ["A", "C", "G"]...........................
2.5.0 :013 > stations.combination(3).to_a.size
 => 35

2.5.0 :014 > stations.combination(4).to_a.size
 => 35

2.5.0 :015 > stations.combination(5).to_a.size
 => 21

2.5.0 :016 > stations.combination(6).to_a.size
 => 7

2.5.0 :017 > stations.combination(7).to_a.size
 => 1
```

`7+21+35+35+21+7+1` = 127 约等于 2**7 = 128 种组合

总共有127种不同数量的station的组合方式，每一种都有一个加总的覆盖范围。
- 找出覆盖范围符合你需要的所有组合
- 从中找出station最少的那个

**也就是说要从n个station中组合出最符合要求的组合，run times至少是 `O(2^n)`**，这类覆盖问题，或说需要进行排列组合的问题，要求出确切的最佳解，都需要先把所有可能的组合列出来。

在n相对小的时候还可以计算，但随着n的增大，总的组合数量会骤增，此时采用 exact algorithm 就不是好的选择了。比如 n = 20的时候 组合总数量达到 1048567。

作者给出的例子是，假设你一秒可以处理完10个组合，那么当n增大时需要的不同耗时：

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-25+%E4%B8%8B%E5%8D%887.41.49.png
)

当station数量达到100时，如果要遍历所有可能找到确切的最佳解，需要无数年。

##### 3.2 Approximation algorithm - 近似算法

**Greedy algorithm 是Approximation algorithms中的一种**

总体的贪婪策略是：

1 筛查一遍所有station, 找到能够最多覆盖到目标states的station, 选中它，然后将它覆盖到的 states 排除；

2 继续筛查所有的station, 找到能够最多覆盖到剩余目标states的station, 选中它，然后将它覆盖到的 states 排除, 如此往复，直到目标states被清空。

这里可以不需要将已经选中的 station 排除，因为下一次筛查时它已经无法覆盖到未覆盖目标states。

>This is called an approximation algorithm. When calculating the exact solution will take too much time, an approximation algorithm will work. Approximation algorithms are judged by
- How fast they are
- How close they are to the optimal solution

这种处理手法就是近似算法。当 exact 算法会耗费太多时间时，近似算法可能有用。对近似算法的评估主要考量两个方面：

- 这个算法有多快
- 他与实际的最佳解 exact algorithm 得出的结果相差多少

在广播覆盖的案例上，其算法复杂度只有 `O(n^2)`，假设最后把所有station都选中了才达到覆盖要求那么
- 选中所有stations的过程需要n次
- 在每次当中，都把每个station的覆盖率筛查了一遍，这又是n

所以最后 run times 是 n * n = n^2

##### 3.3 Code fo approximation algorithm

根据上面的思路，每一次从所有station中筛查最大覆盖的过程，相当于一次求交集的操作。书中用了 python 的 `set()` 方法使用 set 对象来进行这个操作。

1 首先将需要覆盖的states放入一个set

`states_needed = set(["mt", "wa", "or", "id", "nv", "ut", "ca", "az"])`

2 接着使用 hash 来指定每个station能覆盖到的states

```python
stations = {}
stations["kone"] = set(["id", "nv", "ut"])
stations["ktwo"] = set(["wa", "id", "mt"])
stations["kthree"] = set(["or", "nv", "ca"])
stations["kfour"] = set(["nv", "ut"])
stations["kfive"] = set(["ca", "az"])
```

3 最后需要一个set来记录已经选中的station

`final_stations = set()`


4 代码实现

```python
while states_needed:
    best_station = None
    states_covered = set()
    for station, states in stations.items():
        covered = states_needed & states
        if len(covered) > len(states_covered):
            best_station = station
            states_covered = covered
    states_needed -= states_covered
final_stations.add(best_station)

print final_stations
```

这个代码不太好读。可以看下面ruby带注释的版本，实际就是遍历一次，往最终结果中加一个 station，直至覆盖到所有需要覆盖的states

得到的结果是 `set(['ktwo', 'kthree', 'kone', 'kfive'])`

**In ruby**

```ruby
require 'set'

uncovered_states = Set.new(["mt", "wa", "or", "id", "nv", "ut", "ca", "az"])

stations = {}
stations["kone"] = Set.new(["id", "nv", "ut"])
stations["ktwo"] = Set.new(["wa", "id", "mt"])
stations["kthree"] = Set.new(["or", "nv", "ca"])
stations["kfour"] = Set.new(["nv", "ut"])
stations["kfive"] = Set.new(["ca", "az"])
final_stations = Set.new

while !uncovered_states.empty?
  selected_station = nil
  base_covering_increment = Set.new

  # Until add one more station to final_stations
  # It will check all the stations, see which one can cover uncovered_states the most
  # This ensures every time we make the currently best choice
  stations.each do |station, covering|
    current_covering_increment =  covering & uncovered_states
    # While we find a station can cover more uncovered_states than previous-
    # record(i.e base_covering_increment)
    # We update the base_covering_increment to current_covering_increment
    if current_covering_increment.length > base_covering_increment.length
      selected_station = station
      base_covering_increment = current_covering_increment
    end
  end

  uncovered_states -= base_covering_increment
  p final_stations << selected_station
end


# Assuming we finally add all the station to final_stations
  # That we looped n times(n is the number of stations)
# Then in every loop, we traversed every station to ensure the maximal coverage
  # This also take n times

# So, this algorithm's run times is n * n = n**2
```

#### 4 NP-complete problems

##### 4.1 Talk about traveling salesperson problem

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-16+%E4%B8%8B%E5%8D%884.54.55.png
)

之前提到过这个问题，目前还不能找到一个很有效的算法能找到最佳解，尤其当站点很多的时候。

**A -> B 的路程和 B -> A 的路程相等吗？**

可以视作不同，在现实情况中也可能确实不同。比如两个城市之间，来回的主干道可能相同，但靠近各自的区域内可能存在很多单行道，上高速需要绕行的道路也不同，这就导致了两个方向的耗时其实是不同的。

那么在只有两个点的时候，traveling salesperson problem 表面上看上去只有1条路，但实际上选择的起点不同，其路程也是不同的。

那就是说即使线路不同，选择不同的起点，实际也是不同的方案。

如果是ABC三个点，那么如果要遍历3个点，可能的方案会是 ABC ACB BAC BCA CBA CAB 这6种方案是不同的，图面上看比如ABC和CBA线路是一样的，只是起点不同，方向不同。这种特性实际增加了解出 traveling salesperson problem 所需要的计算量。

这里实际是一个阶乘的计算，选起点时有3种可能，选第二个点时剩2种，最后剩一种，也即是 3! = 3*2*1 = 6

同样，这类问题跟上面的states覆盖的问题类似，当n比较小的时候还可以算出确切的解，但当n慢慢增大的时候，总计算量会骤增，这时使用近似算法更为可行。

而这类问题就称作 NP-complete problems，而这类问题具有 的特性就是 NP-compeleteness

Here’s the short explanation of NP-completeness: some problems are famously hard to solve. The traveling salesperson and the set-covering problem are two examples. A lot of smart people think that it’s not possible to write an algorithm that will solve these problems quickly.

对 NP-completeness 的简单解释：有些问题是出了名的难解。比如 traveling salesperson 问题和集合覆盖问题。许多聪明人都认为不可能写出一个能快速解决这类问题的算法。

##### 4.2 Approximating

如果要采用近似算法来求解 traveling salesperson problem 那就是

1 随意选一个起点，从这个起点出发找到最近的点

2 从上一步选择的点再选择一个最近的点，如此往复，直至遍历

##### 4.3 如何识别 NP-complete problems

一些识别点：

- 当n很小的时候处理起来很快，但n增大时，计算量不成比例的陡增
- 需要求 n 的所有排列组合这类问题
- 问题中包含了对顺序的要求，也许也是
- 问题中包含了集合的概念，并且很难处理，也可能是
- 问题如果能用集合覆盖或traveling salesperson problem的模式描述，那么也可能是

当遇到这类问题时，不要费力去求完美的解，而要使用近似算法。


---

#### Recap

- Greedy algorithms optimize locally, hoping to end up with a global optimum.
Greedy 算法每次求本地最佳解，期望最后得到一个全局最佳解

- NP-complete problems have no known fast solution.    
NP-complete 问题没有可知的快速解决方法

- If you have an NP-complete problem, your best bet is to use an approximation algorithm.   
如果遇到 NP-complete 问题， 使用近似算法

- Greedy algorithms are easy to write and fast to run, so they make good approximation algorithms.    
Greedy algorithms 简单，快速，且能快速拿到近似解。


---

Exercises

8.1

You work for a furniture company, and you have to ship furniture all over the country. You need to pack your truck with boxes. All the boxes are of different sizes, and you’re trying to maximize the space you use in each truck. How would you pick boxes to maximize space? Come up with a greedy strategy. Will that give you the optimal solution?

每次都选能装下的最大的那个装，这可能不是最佳解。

8.2

You’re going to Europe, and you have seven days to see everything you can. You assign a point value to each item (how much you want to see it) and estimate how long it takes. How can you maximize the point total (seeing all the things you really want to see) during your stay? Come up with a greedy strategy. Will that give you the optimal solution?

每次都选point最高的那个，这个方法也可能不是最佳解，这和前面贼偷东西是以一个道理。

---

For each of these algorithms, say whether it’s a greedy algorithm or not.

8.3

Quicksort

不是

8.4

Breadth-first search

不是

8.5

Dijkstra’s algorithm

是

https://stackoverflow.com/questions/14038011/dijkstras-algorithm-a-greedy-or-dynamic-programming-algorithm

8.6

A postman needs to deliver to 20 homes. He needs to find the shortest route that goes to all 20 homes. Is this an NP-complete problem?

是

8.7

Finding the largest clique in a set of people (a clique is a set of people who all know each other). Is this an NP-complete problem?

是

8.8

You’re making a map of the USA, and you need to color adjacent states with different colors. You have to find the minimum number of colors you need so that no two adjacent states are the same color. Is this an NP-complete problem?

是
