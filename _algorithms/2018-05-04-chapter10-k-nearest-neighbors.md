---
title:  "Algorithms 101 - 10 - k-nearest neighbors"
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

- You learn to build a classification system using the k-nearest neighbors algorithm.
学习如何使用 k-nearest neighbors 算法建立一个分类系统

- You learn about feature extraction.  
学习特征提取的概念

- You learn about regression: predicting a number, like the value of a stock tomorrow, or how much a user will enjoy a movie.  
学习(统计)回归，预测一个数字，比如明天某只股票的值，或者一个用户有多喜欢一部电影

- You learn about the use cases and limitations of k-nearest neighbors.  
了解 k-nearest neighbors 的案例以及边界

---

#### 1 区分橘子和葡萄柚

假设你手上有一个水果，看起来又像橘子，又像葡萄柚，你要如何确定它到底是哪种。

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/1200px-Grapefruit-Whole-%26-Split.jpg
)

你知道葡萄柚与橘子相比的一个特征是 **更大更红**，于是你可以基于这两个特征做一个图表

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-30+%E4%B8%8B%E5%8D%883.43.20.png
)

- x 轴从左至右是尺寸从小到大
- y 轴从下至上是橘色到红色

基于这两个特征，橘子由于更小更偏橘色，所以集中分布在左下方，而葡萄柚集中分布在右上方。这时你只要看看你拿到的这个水果在哪一堆里面就可以知道他属于什么了。

**如果这个水果看起来相对‘中立’怎么办**

根据大小和颜色你将手中的水果标示到了图上，结果发现它在两堆水果之间的位置，你无法直接弄明白他是属于 orange 还是 grapefruit。

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-30+%E4%B8%8B%E5%8D%883.49.22.png
)

这时你可以看看离他最近的n个neighbors, 然后看这 n 个 neighbors 中属于哪一类的更多，那么这个水果就很可能是那一类。

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-30+%E4%B8%8B%E5%8D%883.54.00.png
)

从选取的3个临近的点来看，其中有两个都是橘子，所以你把这个水果归为了橘子。

> You just used the k-nearest neighbors (KNN) algorithm for classification! The whole algorithm is pretty simple.

**这就是 KNN 背后的逻辑，简单，优美。**

#### 2 Building a recommendations system

假设你为 [Netfix](https://www.netflix.com) 工作, 你想要为用户建立一个电影推荐系统。抽象地看，这和前面分类水果的例子是同一类问题。

同样的，先把用户定位在图表上。

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-30+%E4%B8%8B%E5%8D%884.22.02.png
)

> These users are plotted by similarity, so users with similar taste are plotted closer together. Suppose you want to recommend movies for Priyanka. Find the five users closest to her.

这些用户在图表中的位置是基于他们口味的相似度进行排列的。假设你现在要为 Priyanka 推荐一些电影。你可以先找到离他最近的几个用户。

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-30+%E4%B8%8B%E5%8D%884.32.57.png
)

只要是这5个用户很喜欢的电影，就可以作为推荐电影推荐给Priyanka。

**但问题是，所谓的similarity相似度是怎么得出来的？**

#### 3 Feature extraction - 特征提取

##### 3.1 similarity among fruits

在之前 orange 和 grapefruit 的例子中，定位水果的两个指标很清楚，1 颜色，2 体积

这两个标准就是用于比较的 特征 features ，这些特征都可以量化。

根据这两个features我们可以在图上标出每个水果的位置。比如现在有 A B C 三个颜色大小不同的水果，根据这两个特征我们将其标出。

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-30+%E4%B8%8B%E5%8D%884.39.47.png
)

现在想要衡量这三个水果各自之间的相似度，应该如何进行？

一个方法是可以计算他们之间的 distances.

在这个坐标系中，计算两点之间的距离可以使用 毕达哥拉斯 公式。

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-30+%E4%B8%8B%E5%8D%884.45.50.png
)

`x1-x2` 实际是两点在 x 方向上的距离， `y1-y2`则是他们在y方向上的距离。这个公式其实也就是勾股定理的运用，两个直角边平方和的开放就是斜边的长，在这个例子中就是两点间的直线距离。（两个用户如果在同一个类型上的电影的评分差的越多，那么算出来他们的distance就越远，如果他们在所有类型电影上的评分都很不同，那么算出来他们的距离就很远）

根据公式，就可以算出每两个点之间的距离。

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-30+%E4%B8%8B%E5%8D%884.49.17.png
)

> The distance formula confirms what you saw visually: fruits A and B are similar.

根据算出来的结果，距离越近也就是数值越小的，相似度越高，A 和 B 就具有更高的相似度。

##### 3.2 what's the features for Netfix users

水果的两个特征很简单，颜色和尺寸，但用户的特征呢？

- 用户有哪些特征？
- 从什么地方可以获取用户特征的数据？
- 哪些是能够量化并作为坐标轴标注的？
- 需要多少个特征？

很多问题需要思考。

**从用户对电影的类型偏好上提取可量化的特征**

在用户注册Netfix时，网站会要求用户对各种类型（喜剧，动作，恐怖，科幻......）的电影进行一个喜好度的评分，比如你喜欢喜剧，就给喜剧5颗星，你对科幻没什么感觉，就可能给3颗星等等，每个用户对类型的偏好是不同的，而星级评定对这个方面的特征进行了简单的量化。

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-30+%E4%B8%8B%E5%8D%884.59.59.png
)

如果是3维空间，可以想象把所有对象放到一个3维坐标中

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/3d-simi.jpg
)

接着基于每个用户的这些评分，每个用户就可以对应到一个集合的数字，比如

`Priyanka (3,4,4,1,4)`

当然每个数字对应的是一个类型的电影，可以用hash来代表

> Priyanka and Justin like Romance and hate Horror. Morpheus likes Action but hates Romance (he hates when a good action movie gets ruined by a cheesy romantic scene). Remember how in oranges versus grapefruit, each fruit was represented by a set of two numbers? Here, each user is represented by a set of five numbers.      

>A mathematician would say, instead of calculating the distance in two dimensions, you’re now calculating the distance in five dimensions. But the distance formula remains the same.

之前水果的例子，每个水果只对应两个数字，而这里一个用户有5个。从数学上看，前面的例子是2维的，现在则是5维的，但在距离计算公式上，二者是一样的。

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-04-30+%E4%B8%8B%E5%8D%885.03.51.png
)

而这里算出的结果依然代表两个对象之间（在该特征坐标体系中）的相似度。

基于这些计算结果，我们就可以进行电影推荐。比如在所有用户中，A 和 C 之间的相似度最高，也就是坐标系中的距离最短，那么 A 喜欢的电影就可以推荐给 C, 反之亦然。

当然实际的案例中不会这么简单，推荐电影需要的相似度可能是一个范围，推荐电影就会从多个用户收集到。

##### 3.3 用户距离的简单代码实现

```ruby
class User
  attr_accessor :name, :category_ratings

  def initialize(name)
    @name = name
    @loved_movies = []
    @category_ratings = Hash.new(0)
  end

  def distance_between(another_user)
    diffs = []
    self.category_ratings.each do |key, value|
      diffs << value - another_user.category_ratings[key]
    end
    distance = Math.sqrt(diffs.reduce { |acc, diff| acc + diff**2 })
    p "Distance between #{name} and #{another_user.name} is #{distance.round(2)}"
  end
end

user1 = User.new("Xullnn")
user2 = User.new("Mark")

user1.category_ratings["comedy"] = 5
user1.category_ratings["action"] = 4
user1.category_ratings["drama"] = 3
user1.category_ratings["horror"] = 0
user1.category_ratings["romance"] = 3

user2.category_ratings["comedy"] = 4
user2.category_ratings["action"] = 3
user2.category_ratings["drama"] = 5
user2.category_ratings["horror"] = 5
user2.category_ratings["romance"] = 2

user1.distance_between(user2)
```

返回的结果是

```ruby
"Distance between Xullnn and Mark is 5.66"
```

#### 4 Regression

Regression 在不同的学科中有不同的含义。算法中谈到的回归与数据很相关，应该更倾向于统计学中的定义。

牛津字典中的含义

> a measure of the relation between the mean value of one variable (e.g., output) and corresponding values of other variables (e.g., time and cost).

对某个变量均值与其他相关变量之间关系的测量

wikipedia 上的含义

> In statistical modeling, regression analysis is a set of statistical processes for estimating the relationships among variables. Wikipedia

在统计模型中，回归分析是一系列的用来预估变量之间关系的统计处理过程。


比如你想了解变量 A 在一段时期内平均值与另外几个变量 X, Y, Z 之间的关系。换句话说就是你想了解 X,Y,Z 的变化会怎样影响 A 的表现。再具体一点比如

- A 可以是标普500的走势，xyz可以是美元对人民币的汇率变化，中国股市的走势，沙哈拉沙漠的最高气温。
- A 可以是某个餐馆的销售额，xyz可以是天气好坏，当地物价的变化，当地发生的抢劫偷窃案件次数。

X Y Z 当然应该选取那些与 A 直接相关的变量，但现实中相关和因果本来就是一个很复杂的问题，一些很不靠谱的  X Y Z 可能也会呈现出与 A 的相关性。当然这个话题扯远了。

数据科学中的回归分析示意

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/438px-Linear_regression.svg.png
)

##### 4.1 Predicting how a user will rate a movie

之前使用 KNN 只是推荐电影。如果想要预测某个用户对某部电影的评分，应该怎么做？ 还是用到离他最近的n个用户。

最简单的做法就是找到离他最近的n个用户对这部电影的评分，然后取算术平均值，比如离这个用户最近的几个用户对电影 A 的评分是

```ruby
Justin: 5
Jc: 4
Joey: 4
Lanc: 5
Chris: 3
```

那么把这几个值加起来除以5就得到4.2, 你就可以猜这个用户对这部电影的评分很可能是 4.2。 这就叫**回归**。

这也是你能利用 KNN 做的两件最基本的事情

- 分类：将对象并入某一个类群
- 回归：预测某种回应（表现）

##### 4.2 You have a bakery

**How many loaves should you make?**

假设你有一个面包店，你每天都会做新鲜面包，你试图预测每天应该作多少面包条。现在你有许多可选特征：

- 天气好坏程度，从1到5代表最坏到最好
- 工作日还是节假日，1或0
- 今天是否有体育比赛

而且你知道过往时期内，这些feature不同组合，对应的面包条销量。比如

```
(weather, day, game)

A: (5,1,0) => 300
B: (3,1,1) => 225
C: (1,1,0) => 75
D: (4,0,1) => 200
E: (4,0,0) => 150
F: (2,0,0) => 50
```

那么今天的天气不错(4), 是个周末(1), 没有比赛(0)，那么要你预测今天面包条销量你怎么做？

还是使用 KNN, 假设 k = 4

还是通过公式，你先算出了最近的4个neighbors是 ABDE

然后你将ABDE 4个集合对应的销量算平均值，得到 218.75, 这便是你作出的预测

**Cosine similarity**

之前的例子都使用的是 distance 作为分类或预测的指标。这是否是最好的标准？另一个常用的相似度评定方法是 cosine similarity 余弦相似度。

假设有两个用户他们事实上具有很高的相似度，但是他们在给电影评分时具有不同的判定风格。一个倾向于给他所有比较喜欢的电影都评价5分，另一个则相对保守，他只把5分留给那些他最最喜欢的少数电影。 比如对于电影 A， 他们都喜欢，但一个给了5分，一个只给了4分，如果使用距离公式他们很可能就不会被算作 nearest neighbors，但事实上他们的口味相同。

使用 余弦相似度，会先把用户数据计算为矢量，然后不会去测量两个矢量之间的距离，而是测量他们之间的角度。这样矢量的长度就不会是决定因素，而是矢量之间的角度。

矢量快速回顾: https://www.khanacademy.org/math/linear-algebra/vectors-and-spaces/vectors/v/vector-introduction-linear-algebra


wikipedia 上关于余弦定理页面的截图

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/Snip20180501_2.png
)


#### 5 Picking good features - 选取好的特征

之前给用户推荐电影时，我们用到了不同用户对电影分类的喜好评级。但如果我们不适用这个指标，而是给用户看很多猫的照片，然后让他们对这些猫进行评分。那么你得到的数据集会是怎么样的？ 会做出一个很糟糕的推荐引擎，因为你提取的这些特征与用户的电影偏好没有联系。

也或者你让观众给电影评分时，只给出了 ABC 三部电影让他们评分，而且这3部还是一个系列的续集，那么这也不会告诉你太多关于观众电影偏好的信息。

在使用 KNN 时，选择什么样的特征是很重要的，比如

- 特征与你要推荐的电影直接相关
- 特征应该没有偏见，或说客观全面，比如你只让用户对喜剧电影评分，那么这就不会告诉你他们是否喜欢动作电影

使用电影评分来计算推荐电影是否是一个好的方式？ 也许我对电视剧 A 的评分比 B 高，但我却在花更多的时间看 B。应该如何改进这种推荐系统？

回到面包店的例子，是否还有其他好的特征？ 比如当你印发传单后销量的上升？或者星期一时应该做更多的面包条？

这些现实案例没有标准条件，需要考虑的特征需要自己考虑。

#### 6 Introduction to machine learning - 机器学习

KNN 是一种很有用的算法，他也将你引入了机器学习的神奇世界。 机器学习的目的是为了让你的计算机变得更加聪明，你已经看过一个机器学习的例子了：那就是前面建立电影推荐系统的例子。来看看其他一些例子。

##### 6.1 OCR - Optical Character Recognition - 视觉符号识别

使用视觉符号识别，计算机可以读出一张图片上的文字，Google 就使用 ocr 来使图书电子化，那么OCR的基本原理是什么？ 假设图片上有这么一个东西

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-05-01+%E4%B8%8A%E5%8D%881.20.16.png
)

你如何识别？也是使用 KNN

- 检视大量的包含数字的图片，然后提取出每个数字的（不同）特征（的值）
- 当你拿到一个新的包含数字的图片时，同样提取相同的特征，然后据此计算他与其他包含数字的图片的距离，找到最近的 neighbor 那么就是这个数字

OCR 用来识别数字的特征就可能会是， Curve, Point 和 Line

![](https://s3-ap-southeast-1.amazonaws.com/image-for-articles/image-bucket-1/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7+2018-05-01+%E4%B8%8A%E5%8D%881.20.46.png
)

然后就利用 KNN 算出它与其他数字的距离。

> Feature extraction is a lot more complicated in OCR than the fruit example. But it’s important to understand that even complex technologies build on simple ideas, like KNN.

OCR 用到的特征提取会比水果分类那个例子复杂得多，但重要的一点是明白即使复杂的技术也是以简单的思想为基础，比如 KNN。 使用同样的思想我们可以实现语音识别或面部识别，这些都是机器学习在发挥作用。

**training**

实现 OCR 的第一步--让电脑检视大量包含数字的图片，并提取出特征，这一步叫 **training** 训练。大多数机器学习算法都有一个训练步骤：在你能使用计算机完成特定任务前，你需要先训练他，比如下面例子中提到的垃圾邮件的过滤，就包含训练的步骤。


**Building a span filter**

垃圾邮件过滤使用的另一个简单的算法叫做 朴素贝叶斯分类器 Naive Bayes Classifier ，基本的训练类似这样

比如你有很多邮件主题，你可以将每一封邮件的主题拿出来，拆成单个单词，然后看这个单词在垃圾邮件中出现的概率有多高，接着综合这些单词出现在垃圾邮件中的概率。这就很类似 KNN 中的分类。

朴素贝叶斯分类器 也可以用在之前水果分类的例子上，你有一个又大又红的水果，那么就可以计算他有多大的概率是葡萄柚。

这是又一个简单而又十分有效的算法。

**Predicting the stock market - 预测股票市场**

有些事情也是机器学习做不好的，比如预测股票的走势，你实际不太可能找到有效的特征，至少说不会有长期都有效的特征来训练计算机预测股市。这是因为股市牵涉的变量太多，也因为它是一个二级混沌系统，也就是你的预测行为本身就会改变股市走势。

---

#### recap

- KNN is used for classification and regression and involves looking at the k-nearest neighbors.       
KNN 使用最近的k个neighbors点来进行分类和回归预测
- Classification = categorization into a group.       
分类即是将对象并入一个类群。
- Regression = predicting a response (like a number).         
回归可以预测某种回应/表现
- Feature extraction means converting an item (like a fruit or a user) into a list of numbers that can be compared.            
特征提取意味着将某个对象抽象成一系列可以用来进行比较的特征数字
- Picking good features is an important part of a successful KNN algorithm.          
选取好的特征对于KNN是很重要的

---

Exercises

10.1

In the Netflix example, you calculated the distance between two different users using the distance formula. But not all users rate movies the same way. Suppose you have two users, Yogi and Pinky, who have the same taste in movies. But Yogi rates any movie he likes as a 5, whereas Pinky is choosier and reserves the 5s for only the best. They’re well matched, but according to the distance algorithm, they aren’t neighbors. How would you take their different rating strategies into account?

- 先对每个用户对所有类型电影评分进行一个综合考量。
- 比如某些用户对所有电影类型的评分中最高的只有3颗星，那么可以对他们的所有评分按比例提升。比如使用 final_rating = init_rating * (5/3)
- 然后按照这个计算后的评分来进行空间位置的排列，最后计算相似度

10.2

Suppose Netflix nominates a group of “influencers.” For example, Quentin Tarantino and Wes Anderson are influencers on Netflix, so their ratings count for more than a normal user’s. How would you change the recommendations system so it’s biased toward the ratings of influencers?

- 可以先把 influencers 划分几个等级比如 1，2，3
- 然后将 level 1 的用户的距离与其他所有用户的距离减少 30%
- 将 level 2 的用户的距离与其他所有用户之间的距离减少 20%
- 类似的 level 3 减少 10%

10.3

Netflix has millions of users. The earlier example looked at the five closest neighbors for building the recommendations system. Is this too low? Too high?

我的回答是错误的：我刚开始觉得是 too high, 因为如果有上百万个人的数据，那么最近的5个之间和除去这5个以外的最近的95个距离的差距应该是很小的，那么这个5个的代表性就足够了，选取太多会增加运算量。

但作者说，是太少。如果只选择少量用户，那么推荐电影的结果可能是被扭曲的，一个简单的原则是，如果你有n个用户，那么使用 n 开二次方个最近的neighbors。这个说法更加合理。
