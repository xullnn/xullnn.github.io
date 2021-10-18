---
title:  "Algorithms 101 - 4 - quicksort"
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

- 首先讲解了 divide-and-conquer （先分解，再解决）的思考方式。
- 然后结合 Recursion 和 D&C 介绍quicksort的工作方式。

---

#### 1 Divide and conquer

##### 1.1 找到把一块地平均分成相等大小的正方形

有两点重要要求
- 找到的正方形尺寸能填满空地不留空白
- 找到的正方形尺寸是相对最大的，也就是不能切得太细

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-18+%E4%B8%8B%E5%8D%882.04.24.png)

这块地长宽分别是 1680 和 640 米。目标是找到能找出的最大的正方形尺寸将地全部等分，比如 1 x 1 的地块就可以做到，但这很可能不是最大的可能值，所以要通过某种计算来达到目的。

##### 1.2 思路

> How do you figure out the largest square size you can use for a plot of land? Use the D&C strategy! D&C algorithms are recursive algorithms. To solve a problem using D&C, there are two steps:


1.Figure out the base case. This should be the simplest possible case.

2.Divide or decrease your problem until it becomes the base case.


**1 找到 base case**

首先要找到 base case 即什么情况下我们可以停止计算，或说马上可以确定找到答案了？

当长是宽的整数倍时，比如 4:1 , 2:1 , 1:1 这些情况答案就是，以宽作为边长的正方形。

**2 找到 recursive case**

Now you need to figure out the recursive case.

找到一种方法能够不断接近可能的答案。

##### 1.3 实际操作

- 对长边取宽的余数
- 如果是0，那么就找到了答案 （base case）
- 如果不是，那么就将余数作为宽，之前一步的宽作为长
- 回到第一步

对应给出的例子就是

1680 % 640 == 400 != 0
长现在是 640， 宽是 400

640 % 400 == 240 != 0
长现在是 400，宽是 240

400 % 240 == 160 != 0
长现在是 240，宽是160

240 % 160 == 80 != 0
长现在是 160，宽是 80

160 % 80 == 0 触及 base case 找到答案

**80 x 80 的正方形符合要求。**

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-18+%E4%B8%8B%E5%8D%882.26.58.png
)

> D&C isn’t a simple algorithm that you can apply to a problem. Instead, it’s a way to think about a problem. Let’s do one more example.

D&C 不是某种具体的算法，而是一种思考问题的工具。

#### 2 使用 D&C 思考 array 求和

什么情况下求和最简单？ -- array中只有一个element的时候，直接返回array中的那个数字就可以了。

因此可以把这个条件作为 base case

接下来思路就是进行不断拆分，让array不断接近只有一个element的状态。那就每次都都拿出第一个element, 剩下继续拆分，每次都拿出第一个，如此循环，直到后面只剩一个。

比如 [2,3,4,5]
- [2], [3,4,5]
   - [3], [4,5]
    - [4], [5]  触及base case
    - 4 + 5 == 9
  - 3 + 9 == 12
- 2 + 12 = 14

写成代码：

```ruby
def recursive_sum(list)
  if list[1] == nil
    return list[0]
  else
    return list.shift + recursive_sum(list)
  end
end

puts recursive_sum [1,2,3,4]
```

也可以将 array 为空作为 base case

```ruby
def recursive_sum(list)
  if list == []
    return 0
  else
    return list.shift + recursive_sum(list)
  end
end

puts recursive_sum [1,2,3,4]
```

#### 3 Quicksort

主要讲 quicksort 如何给 array 进行排序

**D&C思路**

先找到 base case：
- 那就是array中只有1或0个element的时候，空的时候就留空，1个的时候就返回本身

再找 recursive case
- 要让 array中的element个数 不断接近0或1，还是要进行拆分
- 单纯的拆分显然不起作用，那就可以在拆分的时候进行大小分隔
- 每次拆分以某一个元素作为锚点，比他大的分到右边的新array中，小的反之
- 然后两边拆出来的 array 再进行上一步的操作，直到某一边只有1个或0个元素

wikipedia 中 quicksort 的释义gif

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/Sorting_quicksort_anim.gif
)

比如 [4,3,5,7,1]

初始将 4 作为切分锚点，书中的术语叫 **pivot**

- [3,1] + [4] + [5,7]
 - [1] + [3] + [] => [1,3]
   - [4] => [4]
     - [] + [5] + [7] => [5,7]
最后return到第一步，加起来就是

[1,3] + [4] + [5,7] == [1,3,4,5,7]

代码示例：

```ruby
def quick_sort(array)
  if array.size < 2
    return array
  else
    pivot = array[0]
    s_array, b_array = [],[]
    array[1..-1].each { |e| e < pivot ? s_array << e : b_array << e }
    return quick_sort(s_array) + [pivot] + quick_sort(b_array)
  end
end

p quick_sort [7,2,2,3,4,2,8,9]
# ==> [2, 2, 2, 3, 4, 7, 8, 9]
```

几点重要的说明

```
1 拆分左右array时，避免将 pivot 再次分配

array[1..-1].each { |e| e < pivot ? s_array << e : b_array << e }
这一行中的 array如果不加上[1..-1] 就会报错 stack level too deep (SystemStackError)
不管是使用 each 还是使用 select
如果每次不排除掉第一个元素，那么在拆分的时候会出现重复分配，陷入无限循环。

原因分析：

  在拆分左右两个array时，一边用的是 < 另一遍 else 就会是 >=
  那么当第一次拆分之后
    - 右边的 array 中会包含之前的 array[0]，以及剩下的 大于等于它的数字
     - 下一步拆右边这array时由于 array[0]仍然在右边array的第一个
     - 所以它又充当pivot，同时再次被放到右边的array中
     - 此时左边拆出来的是 [] ，中间是之前的 array[0], 右边是 array[0] + 其他所有大于等于他的数
     - 从这一步开始就会发现右边的 array 无论怎么拆大小都保持不变了，只是每一步把array[0] 拿出来当 pivot
  如果把左边的条件换成 <= 右边换成 > ，最后的结果也是一样

2 array中有重复的数字时

如果去掉条件中的等号

 array.each  do |e|
   s_array << e if e < pivot
   b_array << e if e > pivot
 end

 换成这样

 这种情况不会再报错，排序可以完成，但同时也丢掉了重复的数字，类似排序的同时作了uniq!处理。
 会得到 ==> [2, 3, 4, 7, 8, 9]

 如果要保留重复数字就在左右拆分前排除掉作为pivot的第一个数字。

 如果不需要保留则可以拆分时不用等号，直接滤掉。
```

纸上验证：

左边是拆分左右array时没有排除掉 pivot 的情况，总会陷入无限循环。

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/quicksort.jpg)


**Inductive proofs**

作者提到了归纳证明，也就是从之前的经验推导未来的情况。比如我能求出1个element的array的和，就能求出2个elements的array的和，就能求出3个elements的array的和，一直到 n 个 elements。

这里有一个可汗学院的视频。

https://www.khanacademy.org/math/algebra-home/alg-series-and-induction/alg-induction/v/proof-by-induction

#### 4 Quicksort 与其他算法的 Big O notation 对比

一个公式，用来计算一个算法的总耗时

c * n

> c is some fixed amount of time that your algorithm takes. It’s called the constant.

c 实际可以理解为每一步操作需要耗费的单位时间。

**对算法复杂度相差很远的算法来说，c 的大小其实无所谓，因为不同算法之间在 Big O notation 之间的差异大到不可想象。** 尤其是在 n 特别大的时候。但如果两种算法的Big O notation差异不大，那么可能就需要考虑constant的影响。

比如下面的例子，就算 binary search 的每一步耗时是 simple search的100倍，但最终还是 binary search 快的多的多。

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-18+%E4%B8%8B%E5%8D%884.02.08.png
)

#### 5 Average case vs. worst case

在 quicksort 中，算法的效能严重依赖于 pivot 的选择。还是求和的例子，给出两种方案

- 1 Recursion中每一步都选择 array[0] 作为 pivot
- 2 Recursion中每一步都选择中间的数字作为 pivot

如果 array 中有8个数字

**1 Recursion中每一步都选择 array[0] 作为 pivot**

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-18+%E4%B8%8B%E5%8D%884.06.59.png
)

这种方式stack的size 是 n，而每一步又可以算作 O(n), 因为每次都要比大小，左右两边的array并没有排序

**2 Recursion中每一步都选择中间的数字作为 pivot**

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-18+%E4%B8%8B%E5%8D%884.07.09.png)

这种方式 stack 的size 就只有 O(4), 而每一步又可以算作 O(n)

> The first example you saw is the worst-case scenario, and the second example is the best-case scenario. In the worst case, the stack size is O(n). In the best case, the stack size is O(log n).

第一种每次都选择头部element作为 pivot 是最差的情景，这种做法会导致算法最后的 复杂度是 O(n*n)

第二种每次选中间则是最好的情景，他的算法复杂度是 O(n*logn), log n 这里代表了 stack的层数

#### 6 The best case is also the average case

这句话的含义是如果每次都随机的选择某个element作为 pivot, 那么平均下来会发现，算法复杂度和上面提到的最优情况时一样的。

为什么不取中间那个？

**要注意上面提到的案例是一个已经排好序的array, 如果把 4 和 1 的位置对调，实际和最差的情况差不多（至少从第二步开始看）**。 真实的情况是，不可能给一个排好序的array再让你排序。所以选择中间那个不会保证每次都最优，随机选择会更好。

所以可以把我们之前的代码改一下，只改选pivot那步

```ruby
def quick_sort(array)
  if array.size < 2
    return array
  else
    pivot = array.sample
    s_array, b_array = [],[]
    array[1..-1].each { |e| e < pivot ? s_array << e : b_array << e }
    return quick_sort(s_array) + [pivot] + quick_sort(b_array)
  end
end
```

---

#### Recap

- **D&C** works by breaking a problem down into smaller and smaller pieces. If you’re using D&C on a list, the base case is probably an empty array or an array with one element.      
D&C 通过将问题拆解问题来解决。如果你对一个list使用 D&C，base case 很可能是空array 或者只有1个element 的array
- If you’re implementing quicksort, choose a **random** element as the pivot. The average runtime of quicksort is O(n log n)!      
如果你在使用 quicksort, 随机选择一个 element 作为 pivot,这样平均的 run time 是O(n logn)
- The constant in Big O notation can matter sometimes. That’s why quicksort is faster than merge sort.       
constant time 在 Big O notation 中有时比较重要。
- The constant almost never matters for simple search versus binary search, because O(log n) is so much faster than O(n) when your list gets big.      
对于 simple search 和 binary search, constant time 的差别几乎可以忽略，因为在 n 很大的时候二者的 run time 差的很多。

---

**merge sort**

from wikipedia

> An example of merge sort. First divide the list into the smallest unit (1 element), then compare each element with the adjacent list to sort and merge the two adjacent lists. Finally all the elements are sorted and merged.

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/Merge-sort-example-300px.gif
)

---


Exercises


4.1

Write out the code for the earlier sum function.

```ruby
def recursive_sum(array)
  if array[1] == nil
    return array[0]
  else
    return array.shift + recursive_sum(array)
  end
end
```

4.2

Write a recursive function to count the number of items in a list.

```ruby
def recursive_count(array)
  if array[1] == nil
    return 1
  else
    array.pop
    return 1 + recursive_count(array)
  end
end
```


4.3

Find the maximum number in a list.

```ruby
def find_max(array)
  if array.size == 1 # 也可以写 array[1] == nil
    return array[0]
  else
    array[0] >= array[1] ? array.delete_at(1) : array.delete_at(0)
    return find_max(array)
  end
end
```


4.4

Remember binary search from chapter 1? It’s a divide-and-conquer algorithm, too. Can you come up with the base case and recursive case for binary search?

How long would each of these operations take in Big O notation?

4.5

Printing the value of each element in an array.

O(n)

4.6

Doubling the value of each element in an array.

O(n)

4.7

Doubling the value of just the first element in an array.

O(1)

4.8

Creating a multiplication table with all the elements in the array. So if your array is [2, 3, 7, 8, 10], you first multiply every element by 2, then multiply every element by 3, then by 7, and so on.

`4!/(2!*(4-2)!)`

`n!/(2!*(n-2)!)`

https://www.khanacademy.org/math/precalculus/prob-comb/combinations/v/combination-formula

实际做出来的table是会有这么多对。

但如果只是单纯的两两相乘，那就是 n*n == O(n**2)
