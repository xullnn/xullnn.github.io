---
title:  "Algorithms 101 - 9 - dynamic-programming"
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

- You learn dynamic programming, a technique to solve a hard problem by breaking it up into subproblems and solving those subproblems first.  
学习动态规划，一种通过将难题分解成子问题，然后通过先解决子问题最后达到解决整个问题的方法。

- Using examples, you learn to how to come up with a dynamic programming solution to a new problem.  
使用例子学习动态规划

---

开始看到 'dynamic programming' 以为是某种写程序的动态方法（翻译成中文是动态规划）。后面才发现，指的其实一种解决问题的思路，这种思路会在代码上体现出来。

---

#### 1 The knapsack problem

在greedy algorithm那章提到了这个问题，当时是为了说明 greedy algorithm 对于某些问题会失效。

这属于一个 NP-complete problem，也就是当n很小的时候，可以用穷尽所有可能的方式找到确切的最佳解，而当n逐步变大时，使用遍历所有可能的方式会使计算量陡增，使得这种方式不可取。

这章对问题作了一点简化，将三种商品 Guitar, Laptop， Stereo 的重量改为了1，3，4 磅，knapsack的容量改为了4磅。

||重量|价值|
|:-:|:-:|:-:|
|Guitar|1|1500|
|Laptop|3|2000|
|Stereo|4|3000|

##### 1.1 simple algorithm

step1: 找出商品的所有可能组合 2^3 = 8     
step2: 算出所有组合各自的重量    
step3: 找到重量小于等于4磅的所有组合    
step4: 从上面一步的结果中找出价值最大的组合，即结果    

这里的run time 实际可以算作 2^n + n + n + n = 2^n + 3n

或者可以近似算作 O(2^n)

最后结果是 [Laptop, Guitar] => 价值 3500

##### 1.2 greedy algorithm

step1: 找出能装下的最贵的，那就是 Stereo, 价值3000     
step2: 从剩余容量中再选最贵的放进去，没有空间了，于是结果就是 Stereo

这种方法的 run time 是 O(n)

最后结果是 [Stereo] => 3000

##### 1.3 dynamic programming

上面两种方式中，Greedy algorithm 比 simple algorithm 快的多，但只拿到了近似最佳解, miss 掉了实际最佳解。

而 simple algorithm 找到了最佳解，但在 n 很大的时候变得不可取。

另外一种思路即是 dynamic programming

**Every dynamic-programming algorithm starts with a grid.**

使用 dynamic-programming 算法时通常都会用到表格。

|item\Weight bearing|1|2|3|4|
|:-:|:-:|:-:|:-:|:-:|
|Guitar|||||
|Stereo|||||
|Laptop||||||

这个表格中横轴 1 2 3 4 是假想的 knapsack 装载重量，从最低的1磅到4磅

纵轴是要装的东西，第一行只能装前1行的items, 第2行可以装前2行中的items, 第3行可以装前3行包含的items，以此类推

表格中的每一格都要填，内容是装的东西以及价值总和

**The Guitar row**

先填吉他那行

Guitar 的重量是 1 磅， 价值 1500

- 所以第1行第1栏可以容下一个Guitar, 是 G: 1500
- 第2栏到第4栏虽然容量越来越大，但吉他只有一把，所以都是 G: 1500，最后表格是

|item\Weight bearing|1|2|3|4|
|:-:|:-:|:-:|:-:|:-:|
|Guitar|G: 1500|G: 1500|G: 1500|G: 1500|
|Stereo|||||
|Laptop||||||

**The Stereo row**

接下来是音响的那行

Stereo 重4磅， 值 3000， 现在是第2行，那么前两行的items也就是 Guitar 和 Stereo 都可以装

- 第2行第1栏，装不下 Stereo, 所以只能装一个 Guitar
- 第2栏以及第3栏，也不能装Stereo，但够装Laptop，不过Laptop在第2行还不可用，所以123都是 G: 1500
- 第4栏，刚好可以装下 Guitar，价值也更大，所以更新为 S: 3000

|item\Weight bearing|1|2|3|4|
|:-:|:-:|:-:|:-:|:-:|
|Guitar|G: 1500|G: 1500|G: 1500|G: 1500|
|Stereo|G: 1500|G: 1500|G: 1500|S: 3000|
|Laptop||||||

**The Laptop row**

Laptop 重 3 磅， 值 2000

现在是第3行了，所以三个items都可选用

- 第1栏还是只能装 Guitar
- 第2栏还是只能装1个Guitar
- 第3栏刚好够装1个Laptop 更新为 L: 2000
- 第4栏可以装1个Laptop 加 1个Guitar 更新为 G & L: 3500

|item\Weight bearing|1|2|3|4|
|:-:|:-:|:-:|:-:|:-:|
|Guitar|G: 1500|G: 1500|G: 1500|G: 1500|
|Stereo|G: 1500|G: 1500|G: 1500|S: 3000|
|Laptop|G: 1500|G: 1500|L: 2000|G & L: 3500|

**The formula**

这里填写每一格的时候实际是有公式的。

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-26+%E4%B8%8B%E5%8D%886.50.20.png
)

整个过程有点像 Dijkstra's 算法的逐行更新。

针对knapsack这个具体案例，上面那个公式的步骤是

1 i 代表行row，j代表列column, 第2行第3列表示为 Cell[2][3]

2 在当前某一格 Cell[i][j], 会算出两个值
 - 第一个值是用，这一行新增的可选item的价值 加上 剩余容量对应的item的价值，或者表示为 `value of Cell[i-1][j-(current item's weight)]`
  - 比如Cell[3][4]: 新增可选item的值是 Laptop 2000
  - 加上: Cell[3-1][3-3] = Cell[2][0] 对应的items的重量，等于0，因为没有这一格，实际也是因为装了 Laptop 后已经没有空间
  - 如果是Cell[4][4] 后一个加上的就是 Cell[3-1][4-3] = Cell[2][1], 是一把 Guitar
  - 这里找差值为什么要到上一行 Cell[i-1] 中去找，当前row中不是也有1磅对应的格子吗， 为什么不用 `Cell[i][j-(item's weight)]`?
    - 想象一下如果 Laptop 和 Guitar 是一样重的，那么在第3行第1，2格我也可以填 Laptop, 到第3格的时候，我就会填两个 Laptop ，但Laptop只有1个，这样就出错了。所以至少要到上一行中去找到符合差值重量的那个item

- 第二个值是当前column上一行对应的那个value，也就是同等容量的上一次items总价值记录

3 把上面拿到的两个值进行比较，如果新算出来那个更大，那么更新，否则，继承。

表格记录在这里的作用是，**我们将每一步的结果存储了下来**，当我们要去拿一个差值重量的item时，不需要再进行一次搜索, 这会增加 O(n) 的复杂度，当然这个例子中只有3个item一眼就可以看到，但如果当item数量到达100或更多时，这种直接定位到指定位置的方法很高效，类似从 array 中根据索引拿对象。

如果将上述公式写成ruby代码：

```ruby
class Item
  attr_accessor :name, :weight, :price
end

class Knapsack
  attr_accessor :items, :capacity, :table

  def initialize(capacity)
    @items = []
    @capacity = capacity
    @table = Hash.new([0, [nil]])
  end

  def fill_items
    return "No available items" if items.empty?
    items.each_with_index do |item, index|
      row = index + 1
      (1..capacity).each do |column|
        previous_max_value = table[[row-1, column]][0]
        previous_max_name = table[[row-1, column]][1]
        if column < item.weight
          table[[row, column]] = table[[row-1, column]]
        elsif column == item.weight
          new_value = item.price
          new_value >= previous_max_value \
            ? table[[row, column]] = [new_value, [item.name]] \
            : table[[row, column]] = [previous_max_value, [previous_max_name]]
        else
          diff_weight = column - item.weight
          diff_item_name = table[[row-1, diff_weight]][1]
          diff_item_value = table[[row-1, diff_weight]][0]
          new_value = item.price + diff_item_value
          if diff_item_value == 0
            table[[row, column]] = [new_value, [item.name]]
          else
            table[[row, column]] = [new_value, [diff_item_name[0], item.name]]
          end
        end
      end
    end
  end


  def find_best_combinations
    sorted_table = table.sort_by { |k, v| v[0] } # return an array
    max_combination_price = sorted_table[-1][1][0]
    p best_combinations = table.select { |k, v| v[0] == max_combination_price }
  end


end


guitar = Item.new; guitar.weight = 1; guitar.price = 1500; guitar.name = "guitar"
laptop = Item.new; laptop.weight = 3; laptop.price = 2000; laptop.name = "laptop"
stereo = Item.new; stereo.weight = 4; stereo.price = 3000; stereo.name = "stereo"

knapsack = Knapsack.new(4)
knapsack.items = [stereo,laptop,guitar]
knapsack.fill_items
knapsack.find_best_combinations
```

最后输出结果是 `{[3, 4]=>[3500, ["laptop", "guitar"]]}`

可以尝试使用其他item进行测试

中间的 `fill_items` 方法冗长，其中大部分代码是为了正确记录当前格子中的价格是由哪两种商品组成。

为了避免以后自己都看不懂或者重构的可能，注释一下

```ruby

# @table = Hash.new([0, [nil]]) 的作用

  # 后面会使用 table[row][column] 这样的格式来拿对应的格子中的信息
  # 格子中包含的信息有 1 装下的商品总价， 2 构成这个价格是哪些商品
    # 因此，一个格子中的信息单用一个 string 不能灵活的处理
    # 所以至少是一个 array, 而商品构成又很可能是多个所以 array 中的第二个element又需要是一个 array
  # 在填写空格的时候，会涉及到比较的问题
    # 1 当当前column对应的knapsack承重大于当前row商品的重量时
    # 会取重量差值，然后去上一行找对应的 knapsack 对应的该重量的商品价值，尝试与当前item价格相加
      # 这里又可能有3种情况 1 上一行中没有差值对应的column, 2 找到了但是重量是0，也就是什么也装不下， 3 有价格，有商品
      # 当上一行中不存在这样一个对应column时，如果不用Hash.new([0, [nil]])让不存在的格子填入一个默认值，那么就会报错
      # 当然可以再使用条件式去处理这种报错，但会更繁杂

    # 2 填完当前格之后，会需要去跟同column的上一行比较，也就是上一次记录的最大值
      # 这里要考虑的是填第一行的时候，上一行是不存在的
      # 所以其实每一次比较都是用 Hash.new的默认值array中的第一个 0 去比较的
      # 不然去拿不存在的格子会返回一个 nil, 用nil去比较会报错
  # 因此，中间可能出现这么多可能的状况，那还不如直接一开始就固定好格式，都是一个嵌套array
  # 第一个元素是总价，第二个是商品构成
  # 并且设好默认值，不能存在的格子的价格都设为0， 商品构成中写 nil

def fill_items
  return "No available items" if items.empty?
  items.each_with_index do |item, index|
    row = index + 1      # row 其实就是 item 的 index + 1
    (1..capacity).each do |column|
      previous_max_value = table[[row-1, column]][0] # 在处理每一格的时候，先准备好要用作比较的上一次记录的最大值和其商品构成
      previous_max_name = table[[row-1, column]][1]  # 方便后面添加
      # 这里拆分三种比较情况主要是为了方便 table 中商品构成那部分的处理
      if column < item.weight                              
        table[[row, column]] = table[[row-1, column]]          # 当当前column容量装不下当前item的时候，直接继承上一行中的最大值
      elsif column == item.weight                              # 当刚好可以装下时，就需要比较
        new_value >= previous_max_value \                        # 如果当前item价格大于等于之前记录的最高价，将当前item信息作为当前格子信息
          ? table[[row, column]] = [new_value, [item.name]] \    # 如果当前item价格小于之前记录的最高价，那么就要继承之前的总价和商品构成
          : table[[row, column]] = [previous_max_value, [previous_max_name]]
      else                                                     # 最后是column承重大于item重量时，就需要求差值，然后去找上一行对应承重的格子中的信息
        diff_weight = column - item.weight   # 前把可能存在的差值格子中的信息提取出来，先算差值
        diff_item_name = table[[row-1, diff_weight]][1] # 再拿商品名称
        diff_item_value = table[[row-1, diff_weight]][0]  # 再拿总价
        new_value = item.price + diff_item_value # 算差值格子中总价与当前item价格的和。这里没有再写代码去处理差值格子不存在的情况，这种情况下拿到的价格会是 0 ， 具体说明看前面对 table 默认值设定的说明
        if diff_item_value == 0 # 当差值不存在对应的格子时，将当前item信息作为当前格子信息
          table[[row, column]] = [new_value, [item.name]]
        else  # 当差值存在时，说明新总价是由两部分价格构成，所以要汇总两个格子的信息
          table[[row, column]] = [new_value, [diff_item_name[0], item.name]]
        end
      end
    end
  end
end
```

##### 1.4 关于knapsack的dynamic programming 解法的说明

1.4.1 三个item的处理顺序是否必须从重量最轻的到最重的？

不需要，把上面 `knapsack.items = [stereo,laptop,guitar]` 里面item的顺序打乱，然后多试几次看看是否得到相同的结果。

`knapsack.items = [stereo,laptop,guitar].shuffle`

偶尔会出现
`{[2, 4]=>[3500, ["laptop", "guitar"]], [3, 4]=>[3500, [["laptop", "guitar"]]]}`

这样的结果，这其实就是从轻到重放置item出现的结果，在第二行其实就出现了最佳组合，直到最后一个cell [3,4] 也没有出现更大的组合，所以 [3,4] 直接继承了这个结果。

1.4.2 增加 item 会不会影响结果正确性？

如果代码逻辑正确，是不会出现问题的，可以测试一下，加两个item，Headphone和necklace

+++

```ruby
headphone = Item.new; headphone.weight = 2; headphone.price = 500; headphone.name = "headphone"
necklace = Item.new; necklace.weight = 1; necklace.price = 2500; necklace.name = "necklace"

knapsack.items = [stereo,laptop,guitar,headphone,necklace].shuffle
```

有趣的是，每运行一次，结果都可能不同，虽然最高总价相同，但可能会有不同的组合。

```ruby
{[3, 4]=>[4500, ["laptop", "necklace"]], [4, 4]=>[4500, ["headphone", "guitar"]], [5, 4]=>[4500, [["headphone", "guitar"]]]}

{[5, 4]=>[4500, ["headphone", "necklace"]]}

{[3, 4]=>[4500, ["necklace", "laptop"]], [5, 4]=>[4500, ["necklace", "guitar"]]}
```

上面是3次执行的结果，由于item排列方式的不同，最后拿到的组合也可能不同。在写的算法中，如果后面出现了新组合与前面最高价相同，是会更新此cell中的商品构成的。由结果也可以看出算法存在一个缺点是，只保证每次至少找出一个符合要求的最佳组合，但无法保证找出所有可能的最佳组合。

1.4.3 如果item或knapsack的重量包含小数会有影响吗？

从操作逻辑上讲是不会的，但是，注意我们写的算法中

`(1..capacity).each do |column|`

这里是一种简化的情况，每一列对应一个整数的承重磅数

这也是我们后面可以简化的使用差值去对应 cell 拿信息的原因。这里有几种情况

- 当column仍然保持整数，从1依次递增，item的重量变为包含小数，那么差值就可能不是整数，算法中那种定位方式会失效
- 当column保持整数，但不按1递增，比如 1, 3, 5, 7 ，明显差值定位也会失效
- 当column包含小数，item保持整数，同样的差值定位失效
- 当二者都包含小数，同样的差值定位失效

差值定位能正确工作，是我们能正确更新cell信息的基础之一，所以上面的算法其实是很简化的版本。如果要处理小数的问题，需要重新考虑如何正确定位cell的问题。

**和给array排序这类处理简单对象的算法不同，对于dynamic programming对待具体问题需要重新思考算法怎么写。**

#### 2 另一个使用 dynamic programming 方式解决问题的例子-Optimizing your travel itinerary

##### 2.1 问题描述

假设你现在要计划一次旅行，你的可选目的地有 A B C D E 五个，每个目的地消耗的游览时间从半天到两天不等，而你对这几个目的地都有一个评分。你的时间有限，现在你想弄清楚选择哪几个目的地才可以最大化这次旅行的总体评分。（书中给的目的地是具体地名，这里简化为字母）

现在来看看具体的情况

|attraction|time costs(day)|rating|
|:-:|:-:|:-:|
|A|0.5|7|
|B|0.5|6|
|C|1|9|
|D|2|9|
|E|0.5|8|

现在你只有2天游览时间

##### 2.2 规划表格

首先找到限制条件，那就是游览时间，这是一个固定值，可以将这个值作为 column 的组成

那么rows对应的就是每一个目的地，每一格中包含的信息就是 当前的评分总和，以及目的地构成

其实与前面 knapsack 的例子很像。

|attraction\time|0.5|1|1.5|2|
|:-:|:-:|:-:|:-:|:-:|
|A|||||
|B|||||
|C|||||
|D|||||
|E||||||

##### 2.3 代码实现

有几个关键点
- 表格仍然使用hash来构建，这样每一格中可以存储的信息更加灵活
- 这次 row 和 column 需要单独的计数来实现
- 注意 integer 和 float 的转换
- 想出一种方法能定位到差值对应的subsolution所在cell, 这里恰好可以使用差值除以0.5来获得column的偏移数量

代码实现

```ruby
class Destination
  attr_accessor :name, :time_cost, :weight
  def initialize(name,time_cost,weight)
    @name = name
    @time_cost = time_cost
    @weight = weight
  end
end

class Schedule
  attr_accessor :limitation, :destinations, :table, :subtimes

  def initialize(limitation)
    @limitation = limitation
    @destinations = []
    @subtimes = make_subtimes
    @table = Hash.new([0, [nil]])
  end

  def make_subtimes
    t = 0.5
    @subtimes = []
    while t <= limitation
      @subtimes << t
      t += 0.5
    end
    @subtimes
  end

  def fill_destinations
    destinations.each.with_index do |destination, index|
      row = index + 1
      subtimes.each.with_index do |subtime, index|
        column = index + 1
        previous_max_weight = table[[row-1, column]][0]
        previous_max_name = table[[row-1, column]][1][0]
        if subtime < destination.time_cost
          table[[row, column]] = table[[row-1, column]]
        elsif subtime == destination.time_cost
          current_weight = destination.weight
          current_weight >= previous_max_weight \
          ? table[[row, column]] = [current_weight, [destination.name]] \
          : table[[row, column]] = table[[row-1, column]]
        else
          diff_time = subtime - destination.time_cost
          offset_column = (diff_time/0.5).to_i
          diff_weight = table[[row-1, offset_column]][0]
          diff_destinations = table[[row-1, offset_column]][1]
          if diff_weight == 0
            table[[row, column]] = table[[row-1, column]]
          else
            new_weight = diff_weight + destination.weight
            new_destinations = [destination.name] + diff_destinations
            table[[row, column]] = [new_weight, new_destinations]
          end
        end
      end
    end
  end

  def find_best_combinations
    sorted_table = table.sort_by { |k, v| v[0] }
    best_combinations_weight = sorted_table[-1][1][0]
    p best_combinations = table.select { |k,v| v[0] == best_combinations_weight }
  end

end

a = Destination.new("A",0.5,7)
b = Destination.new("B",0.5,6)
c = Destination.new("C",1,9)
d = Destination.new("D",2,9)
e = Destination.new("E",0.5,8)

schedule = Schedule.new(2)
schedule.destinations = [a,b,c,d,e].shuffle
schedule.fill_destinations
schedule.find_best_combinations
```

##### 2.4 Dynamic programming 只是一种近似解法

上面的例子中，每次执行前 destinations 都被打乱，最后结果可能有两种，一种最终得分是24， 另一种是 23

`{[5, 4]=>[23, ["E", "B", "C"]]}`
或
`{[5, 4]=>[24, ["C", "E", "A"]]}`

在这个简单的例子中，item数量很少，24是实际最佳解，23虽然不是，但也很接近了。但这也提醒了一点，Dynamic programming 只是一种求近似答案的思路。

[wikipedia中approximation algorithm的页面中](https://en.wikipedia.org/wiki/Approximation_algorithm)也提到了 Dynamic programming 是一种近似算法的范式。

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/Snip20180428_3.png
)

对于 [NP-complete problems](https://en.wikipedia.org/wiki/NP-completeness#NP-complete_problems) ，使用遍历算法不可取，所以才会 approximation algorithms 来平衡 run time 和 solution。 对于这个例子， Dynamic programming 方法得到的solution可能并不稳定，就如上面出现的不同情况。

dynamic programming 需要把大问题拆分成大小不同的子问题，然后解决并存储每一个子问题的解法，利用已有的子问题解法组合出更大一点的子问题解法，最后拿到整个问题的近似解。

整个过程中可变的是如何拆分子问题。比如一个问题的整体尺度是10，那么可以选择拆成`1，2，3...10`， 也可以拆成 `2,4,6...10`, 或者 `5..10`。拆的越细，run time 就越大，但可能就越接近最佳解，拆得粗则反之。 但这不是说拆的越细就越好，需要综合考虑。

比如上面 destination 的例子
- 单个 destination 的耗时最小是 0.5，最小步长也是0.5，这时你把两天拆成 `0.1, 0.2, 0.3 ...1.0...1.1....2.0` 这样就很多余。
- 如果目的地有1000个，而且destinations单位时间内对应的评分差距并不大，你可能就不需要拆得那么细，这样可以减少运算量。

#### 3 中场小结

目前为止看到关于 Dynamic programming 的关键点

- Dynamic programming 可以用于解决存在某个特定限制条件的问题。比如上面例子中背包的重量限制，旅行的时间限制
- Dynamic programming 只能用于那些能够被拆分成独立小问题的问题，而且这些小问题之间不会相互影响。

对于一个现实问题，识别他是否可以使用 dynamic programming 方式求解，以及规划出适合的解决方法是相对困难的，下面是一些建议：

- 每一个 dynamic programming solution 都会用到表格
- 每个cell中的信息往往就是你需要优化的答案
- 每一个cell都是一个子问题，因此要思考如何将你的问题拆分成子问题，这会帮助你确定x轴和y轴使用什么变量。

#### 4 Longest common substring 与 Longest common subsequence

两个问题名字接近但很不同。

**[Longest common substring](https://en.wikipedia.org/wiki/Longest_common_substring_problem)**

Longest common substring 求的是两个string之间的最大连续字母集， 翻译成中文是 最长公共子字串。比如

`OPQRS`
和
`QRSOP`

的Longest common substring 就是  QRS

**Longest common subsequence**

Longest common subsequence 翻译成中文是 最长公共子序列

这里不好理解子序列和子集的区别
- 子序列包含了顺序的要求
- 但又不要求符合要求的字母相邻

比如

`CDEF`

和

`BCDXF`

他们的 longest common substring 是 CD

而他们的 longest common subsequence 是 CDF , 中间把D和F隔开的X并不影响F被包含进去，因为在顺序上两个字串中的 F 都出现在 D 之后

Longest common subsequence 常被用于生物领域，比如对比基因序列的相似度等。其他方面也有重要的应用：

> The longest common subsequence problem is a classic computer science problem, the basis of data comparison programs such as the diff utility, and has applications in bioinformatics. It is also widely used by revision control systems such as Git for reconciling multiple changes made to a revision-controlled collection of files.

wikipedia

##### 4.1 code of Longest common substring

可以把字串看做很多字母的集合，然后求最大交集

思路是两个单词的字母分别作为 row 和 column

逐行比较，如果出现相同字母，则基于 table[[row-1, column-1]] 的值+1， 如果出现不匹配，填0

这样中间有断开不匹配的字母就会归零

下面是如何填表的伪代码

```ruby
s1 = "publish"
s2 = "fisher"

s1.each_char.with_index do |a, i|
  row = i + 1
  s2.each_char.with_index do |b, n|
    column = n + 1
    if a == b
      table[[row, column]] = 1 + table[[row-1, column-1]]
    else
      table[[row, column]] = 0
    end
end
```

##### 4.2 code of Longest common subsequence

书中给出的例子只是计数，也就是算最长的common subsequence的长度，而没有记录具体是什么样的 subsequence。

表的划分还是和上面一样，使用单个字母

先看下书中给出的用于填表的伪代码

```python
if word_a[i] == word_b[j]:
  cell[i][j] = cellp[i-1][j-1] + 1
else:
  cell[i][j] = max(cell[i-1][j], cell[i][j-1])
```

匹配到字母时的操作和substring一样，从取左上方的值+1

不匹配时的操作是取左边一格和上边一格两个值中较大的那个

公式给的很简单，但没有具体说明公式是如何得出的，以及为什么在表格中这样操作可以成功。

下图是两个字串 `CGATCA`  和  `ACTGTA` 寻找 longest common subsequence 的过程

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/lcss.png
)

下面是用ruby写的找出两个字串之间的所有 longest common subsequence 的代码

```ruby
s1 = "CGATCT"
s2 = "ACTGTA"

all_css = []

s1.length.times do |n|
# starting with different letter, we may get different subsequences
  subsequence = ""
  start = 0
  s1[n..-1].each_char do |a|
    if i = s2[start..-1] =~ Regexp.new(a) # 不能直接用 /a/ !!!
      subsequence << a
      start = start + i + 1
    end
  end

  all_css << subsequence
end

p all_css
longest_length =  all_css.map(&:length).max
p all_lcss = all_css.select{ |e| e.length == longest_length }

```

输出结果是

```ruby
["CGA", "GA", "ATT", "TT", "CT", "T"]
["CGA", "ATT"]
```

其实这个算法有遗漏，后面会提到。

##### 4.3 关于表格处理的公式推导问题

公式很直白，很清楚的知道每一个表格怎么填。但花了大量时间也没能彻底搞清楚这个公式是怎么一步步构建出来的。

初看这个问题的时候觉得不会太复杂，也就是两个字串之间的比较，总共就那么多个字母，能有多复杂。但慢下来去思考每一个不能想清楚的细节，发现里面包含的知识点太多，这也不是一个简单的问题。

wikipedia中还有这么一段

> Notice that the LCS is not necessarily unique; for example the LCS of "ABC" and "ACB" is both "AB" and "AC". Indeed, the LCS problem is often defined to be finding all common subsequences of a maximum length. This problem inherently has higher complexity, as the number of such subsequences is exponential in the worst case, even for only two input strings.

两个字串的LCSs不一定只有一个(比如上面代码中的例子)。实际上，LCSs问题也通常是为了找到所有最长的公共子序列。这个问题本身就具有很高的复杂度，最坏的情况中这样的公共子序列有很多，即使只是针对两个字串。

##### 4.4 ruby中查找longest common subsequence的另一种笨办法

首先降一级思考什么是 一个字串的 subsequnece 其实就是 一个单词中所有字母的 有顺序的组合，长度从1个到整个单词的长度，在ruby中可以用 `combination` 方法找到

比如 `s1 = "CGATCT"` 的所有 subsequence

```ruby
def cal_subsequences(string)
  string_letters = string.split("")
  subsequences = []
  n = 1
  while n < string.length
    combinations = string_letters.combination(n).to_a
    combinations.map! { |c| c.join }
    subsequences += combinations
    n += 1
  end
  subsequences
end
```

可以算出

```ruby
["C", "G", "A", "T", "C", "T", "CG", "CA", "CT", "CC", "CT", "GA", "GT", "GC", "GT", "AT", "AC", "AT", "TC", "TT", "CT", "CGA", "CGT", "CGC", "CGT", "CAT", "CAC", "CAT", "CTC", "CTT", "CCT", "GAT", "GAC", "GAT", "GTC", "GTT", "GCT", "ATC", "ATT", "ACT", "TCT", "CGAT", "CGAC", "CGAT", "CGTC", "CGTT", "CGCT", "CATC", "CATT", "CACT", "CTCT", "GATC", "GATT", "GACT", "GTCT", "ATCT", "CGATC", "CGATT", "CGACT", "CGTCT", "CATCT", "GATCT"]
62
```

总共有62个subsequences。

如果把两个字串的 subsequneces 都算出来，然后求交集，就可以拿到他们共同的 subsequences, 接着在找到其中最长的。

```ruby
s1 = "CGATCT"
s2 = "ACTGTA"

def cal_subsequences(string)
  string_letters = string.split("")
  subsequences = []
  n = 1
  while n < string.length
    combinations = string_letters.combination(n).to_a
    combinations.map! { |c| c.join }
    subsequences += combinations
    n += 1
  end
  subsequences
end

p common_sequences = cal_subsequences(s1) & cal_subsequences(s2)
p longest = common_sequences.map(&:length).max
p common_sequences.select { |s| s.length == longest }
```

结果是

```ruby
["C", "G", "A", "T", "CG", "CA", "CT", "GA", "GT", "AT", "AC", "TT", "CGA", "CGT", "CTT", "ATT", "ACT"]
3
["CGA", "CGT", "CTT", "ATT", "ACT"]
```

最后结果比之前手工演算的又多出了3个，找到了所有的 longest common subsequence， 这里的关键是要保持顺序，所以不能用 permutation。

这个方法的run time很高，尤其字串很长的时候，但他能找出所有的子序列。

这里需要再提一次 **Dynamic programming 只是一种近似解法** , 例子中用的表格可以算出 longest common subsequence 的长度，也可以找出所有的 longest common subsequence

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/lcss_grid.jpg
)


#### 5 dynamic programming 动态规划的其他用途

- 生物学家用 lcss 来寻找DNA片段中的相似之处。基于此推测动物或疾病之间的相似度。
- 我们常用的 `git diff` 这类命令背后的原理就用到了 Dynamic programming
- 之前我们了解了string之间的相似度，另一个与string相关的的[levenshtein distance](https://en.wikipedia.org/wiki/Levenshtein_distance) 计算从一个string变为另一个string需要的最少操作，以此判断两个string之间的相似度，这种方法也被广泛使用，比如拼写检查，还有版权检测。
- 很多文字编辑软件中的自动换行，比如word, 它是如何确定哪里换行以尽量保持文本宽度的一致性？ 也是用到了 dynamic programming

---

#### recap

- Dynamic programming is useful when you’re trying to optimize something given a constraint.     
当你需要优化一个含有限制条件的问题的答案时，动态规划很有用
- You can use dynamic programming when the problem can be broken into discrete subproblems.      
动态规划适用于那些能够被拆分成独立小问题的大问题
- Every dynamic-programming solution involves a grid.      
所有动态规划的解决都需要用到表格
- The values in the cells are usually what you’re trying to optimize.      
表格中每一个格子中的值就是你在尝试优化的值
- Each cell is a subproblem, so think about how you can divide your problem into subproblems.      
每一个格子是一个子问题，所以要思考如何拆分问题
- There’s no single formula for calculating a dynamic-programming solution.      
对于动态规划类的解决方法，并没有一个统一的公式
