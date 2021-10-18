---
title:  "Algorithms 101 - 3 - recursion"
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

- Recursion is when a function calls itself.      
递归是一种会call到自身的函数
- Every recursive function has two cases: the base case and the recursive case.      
每一个递归函数都有两种case: base case 和 递归case
- A stack has two operations: push and pop.     
针对堆栈的操作有两种： push 和 pop
- All function calls go onto the call stack.
所有函数呼叫都会在这个呼叫的 call stack 上
- The call stack can get very large, which takes up a lot of memory.     
当call stack 变得非常长的时候，会占用很多的内存

---

Recursion中文译作递归。是很多算法中都会用到的编程技术。

 > Many important algorithms use recursion, so it’s important to understand the concept.

---

#### 1 Recursion is when a function calls itself.

Recursion function/method 是指那些会在自身内部再次call到方法本身的 function/method.

书中给的从嵌套箱子中找钥匙的例子有点让人疑惑。直接用一个简单的代码(用ruby)示例说明：

```ruby
def recursive_sum(list)
  if list == []
    return 0
  else
    return list.shift + recursive_sum(list) # 这里就call回到自己本身
  end
end

puts recursive_sum [1,2,3,4]
```

拆开一步一步看：

recursive_sum [1,2,3,4] (第1步)
- else: return 1 + recursive_sum([2,3,4]) (return 并没有完成，挂起，进入recursion第2步)
  - recursive_sum [2,3,4]
    - else: return 2 + recursive_sum([3,4]) (return 并没有完成，挂起，进入recursion第3步)
      - recursive_sum [3,4]
        - else: return 3 + recursive_sum([4]) (return 并没有完成，挂起，进入recursion第4步)
          - recursive_sum [4]
            - else: return 4 + recursive_sum([]) (return 并没有完成，挂起，进入recursion第5步)
              - recursive_sum []
                - if: return 0, 这一步 return 完成，上一步第5步中被挂起的 `recursive_sum([])` 返回0
              - 第5步中 return (4 + 0) = 4, 第4步中的 `recursive_sum([4])` 拿到结果 4
            - 第4步中 return (3 + 4) = 1, 第3步中的 `recursive_sum([3,4])` 拿到结果 7
          - 第3步中 return (2 + 7) = 1, 第2步中的 `recursive_sum([2,3,4])` 拿到结果 9
        - 第2步中 return (1 + 9) = 10, 第1步中的 `recursive_sum([1,2,3,4])` 拿到结果 10
      - 第1步中 else 分支的 return **拿到最终结果 10**， 退出function。

#### 2 Every recursive function has two cases: the base case and the recursive case.

**base case：** 即设定好的让 recursion 能在最后停下来的条件。上面例子中就是 if 分支对应的代码

**recursive case:** 即设定好的让recursion继续循环下去的条件。上面例子中即是 else 分支对应的代码，能让recursion逐渐收拢或说base case靠近。


[wikipedia中recursion的定义](https://en.wikipedia.org/wiki/Recursion#base_case)

> In mathematics and computer science, a class of objects or methods exhibit recursive behavior when they can be defined by two properties:    
A simple **base case** (or cases)—a terminating scenario that does not use recursion to produce an answer     
（recursive case）A set of rules that reduce all other cases toward the base case

base case对应的中文理解最好不是'基础条件'或'基本条件', 我倾向于理解为'触底条件'，这样容器理解他实际是一个临界条件/状态，是stack堆到最高处即将开始回归的点。


#### 3 The call stack in Recursion

可以使用视觉化的方式来理解call stack。将其想象为一个不断累加的积木，来看上面代码实例的call stack结构。

|第1步|第2步|第3步|第4步|第5步|
|:-:|:-:|:-:|:-:|:-:|
|||||recursive_sum []|
||||recursive_sum [4]|recursive_sum [4]|
|||recursive_sum [3,4]|recursive_sum [3,4]|recursive_sum [3,4]|
||recursive_sum [2,3,4]|recursive_sum [2,3,4]|recursive_sum [2,3,4]|recursive_sum [2,3,4]|
|recursive_sum [1,2,3,4]|recursive_sum [1,2,3,4]|recursive_sum [1,2,3,4]|recursive_sum [1,2,3,4]|recursive_sum [1,2,3,4]|


可以看到从第一层开始，call stack逐层堆叠，其中每一层存在的call stack都说明这个function/method还未完成，处于挂起状态。

在第5步时触及 base case 后，call stack 不会再向上堆叠。而是向下回归，逐步完成每一步被挂起的 function/method。就像把积木一个一个逐层拿下来。也就是call stack最上层的funciton/method执行完之后，下面的才能相继得以完成。

wikipedia 上 stack 的示意图

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/Lifo_stack.png
)

**需要注意的是在整个 call stack 中，function/method 之间可以传递对象**， 上面例子中则是用于计算的那个 array

> This is the big idea behind this section: when you call a function from another function, the calling function is paused in a partially completed state. All the values of the variables for that function are still stored in memory.”

#### 4 stack 的得与失

使用 stack 的一个风险是，可能会用掉很多的内存，当stack堆叠层数很多时，每一步都被挂起，每一步都要存储信息，这就可能导致占用很多内存。两种解决方法：

1 使用 loop 而不用 recursive 的写法

2 使用 `trail recursion` 方法，这个方法超出本书讨论范围，而且只能在某些语言中使用。

** Loop 与 Recursion **

上面array求和的例子使用loop也可以做到：

```ruby
def loop_sum(list)
  acc = 0
  i = 0
  while i < list.length
    acc += list[i]
    i += 1
  end
  return acc
end
```

这引出了什么情况使用 loop 什么情况使用 recursion 这个问题。实际情况是处理相同的任务loop可能更节省内存（变量一直在动态变化，而不是每个循环都要存，也不会有多个function/method挂起），recursive fucntion/method 比较易读。书上给出了一个 Stackoverflow 上的答案。

https://stackoverflow.com/questions/72209/recursion-or-iteration/72694

> Loops may achieve a performance gain for your program. Recursion may achieve a performance gain for your programmer. Choose which is more important in your situation!

很多重要的算法使用 recursion 所以理解他的概念很重要 -- Recursion is when a function calls itself.

#### 5 All function calls go onto the call stack

所有函数的呼叫都会进入调用堆栈。

书中对此没有详细解释，我的理解是，实际我们在写一个函数的时候，在其内部不出意料地会用到其他函数，有些很基础的函数可能都没意识到，比如 `+` `==` 或者如 `delete` `push` 等。至少在Ruby中，同一个名称的method在不同Class中可能有不同的处理方式，比如从一个string中delete一个字母和从array中delete一个element肯定是不同的。 所以这些基本的函数也可以算作stack中的一层。

---

#### recap:

- Recursion is when a function calls itself
- Every recursive function has two cases: the base case and the recursive case
- A stack has two operations: push and pop (这个push不是array中的从尾部注入，而是在stack顶端叠加一层，pop则是拿掉最顶上的那层)
- All function calls go onto the call stack 所有函数的调用都会进入调用堆栈
- The call stack can get very large, which takes up a lot of memory

---

Exercise 3.1

Suppose I show you a call stack like this.

What information can you give me, just based on this call stack?

Now let’s see the call stack in action with a recursive function.

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-17+%E4%B8%8B%E5%8D%8811.35.57.png
)

greet function 先被叫到，带着变数name； 接着greet2也带着变数name被叫到；在当前时刻greet是挂起的未完成状态；当前位置是在 greet2 中；在greet2执行完后，greet 将会继续执行

3.2

Suppose you accidentally write a recursive function that runs forever. As you saw, your computer allocates memory on the stack for each function call. What happens to the stack when your recursive function runs forever?

stack会一直叠加。
