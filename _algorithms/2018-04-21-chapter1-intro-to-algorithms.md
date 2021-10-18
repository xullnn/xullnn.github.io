---
title:  "Algorithms 101 - 1 - intro to algorithms"
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

### 主要内容：

- Binary search is a lot faster than simple search.      
二分法搜索比普通搜索快很多（只对于有序列表来说）
- O(log n) is faster than O(n), but it gets a lot faster once the list of items you’re searching through grows.      
O(log n) 比 O(n) 快很多，在搜索对象变多时，这种优势更明显
- Algorithm speed isn’t measured in seconds.      
算法的速度并不是以秒为单位衡量
- Algorithm times are measured in terms of growth of an algorithm.       
算法复杂度的衡量基于计算量如何增加
- Algorithm times are written in Big O notation.      
算法复杂度用 Big O notation 表示

---

每一个代码片段都可以被称作一个 algorithm；很多常用的重要算法很可能在你所喜欢的语言中找到对应的实践；算法的选择是取舍的过程；有些问题到目前都还没有很有效的算法，只能拿到近似结果。

---

#### 1 Binary search is a lot faster than simple search.

工作前提（重要！）： binary search 是针对 **ordered list 有序列表** 的搜索算法，这是谈论前提。

假设要找到 **ordered_list** 中有没有 x 这个值

##### 1.1 如何工作:

 - 前提：list 已经做过排序
 - 用index作为位置标记
 - ordered list最左边的位置是0(as l_index)，最右边的是 list.length - 1 (as h_index)
 - 第一步猜ordered_list中间位置那个值
   - 方法是 mid_index = (l_index + h_index) / 2，奇数相除会抹掉小数部分保留整数
   - 用 ordered_list[mid_index] 与 x 进行比较
 - 基于上面的比较结果可以分成三种可能情况
   - 1 刚好相等，那么找到了，搜索完成
   - 2 猜测值比 x 大
     - 将 l_index 移到 (mid_index + 1) 位置， h_index 不动，再按之前取中间值的方法猜
   - 3 猜测值比 x 小
     - 将 l_index 移到 (mid_index - 1) 位置， h_index 不动，再按之前取中间值的方法猜
  - 重复上面的步骤直至找到x，或者没有找到结果，完成搜索。

##### 1.2 python代码示例:

```python
def binary_search(ordered_list, item):
  low = 0
  high = len(ordered_list) - 1

  while low <= high:
    mid = (low + high)/2
    guess = ordered_list[mid]
    if guess == item:
        return mid
    if guess > item:
        high = mid - 1
    else:
        low = mid + 1
  return None

my_list = [1,3,5,7,9]

print binary_search(my_list, 3) #=> 4
print binary_search(my_list, -1) #=> None
```

用ruby写

```ruby
def binary_search(ordered_list, item)
  l_index = 0
  h_index = ordered_list.length - 1

  while l_index <=  h_index
    mid_index = (l_index + h_index)/2
    guess = ordered_list[mid_index]
    if guess == item
      return "found item at index: #{mid_index}"
    elsif guess < item
      l_index = mid_index + 1
    else
      h_index = mid_index - 1
    end
  end

  return "Not found"
end
```

**代码自释疑：**

- 注意这里的 low, hight, mid 都指的是 index，而不是具体值
- 只有当1 找到目标值；2 low > high (index)时，才会停止搜索
- 这也是为什么下面的每次一index移动都会+1或-1
  - 如果不这么做，给出一个list以外的值或端点值时，搜索将在每次范围收缩到最后两个值时陷入无限循环
   - 如果给出9
     - step1: i = (0+4)/2 = 2, list[2] = 5, too low, low = 2
     - step2: i = (2+4)/2 = 3, list[3] = 7, too low, low = 3
     - step3: i = (3+4)/2 = 3, list[3] = 7, too low, low = 3
     - step ... 从上一步开始 index 就卡在3一直循环
   - 如果给出 -1
     - step1: i = (0+4)/2 = 2, list[2] = 5, too high, high = 2
     - step2: i = (0+2)/2 = 1, list[1] = 3, too high, high = 1
     - step3: i = (0 + 1)/2 = 0, list[0] = 1, too high, high= 0
     - step4: i = (0 + 0)/2 = 0, list[0] = 1, too high, high= 0
     - step ... 从上一步开始 index 就卡在0一直循环
- 为什么每次 index 的 +1 和 -1 不会导致错过某个值？
  - 首先，每次对比取的那个中点index对应的值(已经用于与目标值比较所以)已经被排除，所以
   - too low 时，最低index可以不落在之前的中点index上，可以向右收缩一位
   - too high 时，最高index可以不落在之前的中点index上，可以向左收缩一位
  - 其次，左右端点index所在的项最终都会拿出来作比较
     - 不管搜索多少次，最后会收缩到端点index是相邻数字，比如 2和3
     - 因为二者相加再相除会刨去小数，拿到的会是较小的那个端点
       - 如目标index是2，那么 (2+3)/2 = 2 搜索成功
     - 如果不是，那么下一步就会变成端点index都落在右边较大那个index
       - 如目标index是3，那么 (2+3)/2 = 2 会too low，左边的index会+1，然后得到两个端点index都是3
       - (3+3)/2 = 3 搜索完成
     - 至此最后剩余的两个端点index所在的值都拿来比较过了
     - 再下一步不管目标值是落在集合左边还是右边，左右端点index会交错，导致while loop遇到false中断
  - 因此端点值无论怎么搜索是被包含在搜索项中的，从上一次的中点index收缩一步，并不会错过任何项


wikipedia 上 binary search 的示意图

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/470px-Binary_Search_Depiction.svg.png
)

#### 2 O(log n) is faster than O(n), but it gets a lot faster once the list of items you’re searching through grows.

##### 2.1 Big O notation

Big O notation 是用来描述一个算法快慢（算法复杂度）的术语， O 指的是 operation，代表步骤或操作（不是以时间为单位）。

> Big O notation lets you compare the number of operations. It tells you how fast the algorithm grows.

O(n), O(logn) ... 括号中的的值越大代表算法复杂度越高。

wikipedia 上关于不同 Big O notation 随着查找对象增加，算法复杂度的增加曲线

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/512px-Comparison_computational_complexity.svg.png
)

##### 2.2 O(log n) 与 O(n)

从 含有n个对象的 ordered_list 中搜索一个值 x 是否存在
 - 从头开始一个一个找算法复杂度是 O(n)
 - 使用 binary search 搜索，算法复杂度是  O(log n)

在ordered_list中对象数量较少时，算法复杂度相差不大，但随着列表中对象数量增加，binary search的优势会越来越明显。

|list中的对象数量|O(n)需要的搜索次数|O(log n)需要的搜索次数|
|:-:|:-:|:-:|
|10|10|4|
|100|100|7|
|1 billion|1 billion|30|

#### 3 Algorithm speed isn’t measured in seconds.

每增加一次搜索，算法复杂度 +1，等于多需要一步，每一步需要的单位时间因条件而不同。Big O notation 不是以时间作为单位。

#### 4 Traveling salesperson problem

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-16+%E4%B8%8B%E5%8D%884.54.55.png
)

> This is one of the unsolved problems in computer science. There’s no fast known algorithm for it, and smart people think it’s impossible to have a smart algorithm for this problem. The best we can do is come up with an approximate solution.


一个还没找到有效算法的问题。地图上给出若干个点，要如何用最短的路程走完所有的点。
 - 如果给出4个点, 会有 4! = 24 种路线组合
 - 如果给出6个点，会有 6! = 720 种路线组合
 - 如果给出8个点，有 40320 种路线组合
 - 如果给出 100 个点 ...


![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-16+%E4%B8%8B%E5%8D%884.55.30.png
)

#### 5 wikipedia 上的算法清单

https://en.wikipedia.org/wiki/List_of_algorithms

---

Recap:

- Binary search is a lot faster than simple search.   
- O(log n) is faster than O(n), but it gets a lot faster once the list of items you’re searching through grows.
- Algorithm speed isn’t measured in seconds.
- Algorithm times are measured in terms of growth of an algorithm.
- Algorithm times are written in Big O notation.
