---
title: "On exploring Promise 1: thoughts about async and event loop model"
categories:
  - Work
tags:
  - programming
layout: post
---

### 1 From `setTimeout` to `Promise`

I remember vividly when I first stumbled on the term "asynchronous", the first thing jumped into my head was it must have something to do with my mobile phone" since I often *synchronize* my phone with my Mac. And our general notion about [sychronization](https://en.wikipedia.org/wiki/Synchronization) is that is a process that coordinates different parts of something in unison. So it's easy to think `async` as "to make things not to happen at the same time", but this is a bit different from what `async` means in web development.

As I kept learning programming, I had more and more terms about sync/async collected, such as "concurrency", "process", "main thread", "promise", "async function". Then I knew I can't jump on a time machine then travel back to the happy days when I just knew about how to use `setTimeout()` and `setInterval()`. And this feeling culminated when I tried to understand how `Promise` works with JavaScript. And I did spend a lot of time trying to understand how `Promise` works. (`Promise` refers to the general concept of promise in this article).

Most learning materials about `Promise` out there focus on how to use `Promise` and how good it is. When we just got a bit familiar and comfortable with some basic use of `setTimeout()` and `setInterval()`, as well as some basic use of [XHR](https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest). Then lots of people come to say "you know what, we've gotten a better tool to deal with async tasks, it's called `Promise`". After a while some other people tell you "you should try `async function` and `fetch` API, they are promise-based, they are awesome!". As a diligent student, you paid a lot of time reading through materials and going through the code examples again and again. But, you are still not so sure about how to use `Promise` as well as all the promise-based techniques. Why? I think there are several reasons:

- 1. don't have a decent understanding of "async", or think it as a very complicated concept
- 2. don't know how the browsers coordinate sync and async tasks
- 3. people who write introductions about `Promise` assume that all readers have known `1` and `2`,  also some key points about `Promise` are not noticed by beginners, therefore some mental gaps persist in the understanding of `Promise`.

I'll try to write a 2-part article to explore these points. The first part will focus on general idea of `async` and mental model of "event loop", the second part will share some key points I realized very late during my journey of learning `Promise`. I don't write too much about "how to use Promise", because there're many excellent materials about this on the internet, I think they do better than me.

### 2 A simple understanding of "async"

In fact it won't be so simple, otherwise I wouldn't have written these things hah. I have to confest that it needs patience to gain a well enough understanding of `Promise`, because it relates to many other concepts. And it's almost impossible to understand a concept without knowing other related ones. As [Daniel Dennett](https://en.wikipedia.org/wiki/Daniel_Dennett) would say:

> "You can't believe a dog has four legs without believing that legs are limbs and four is greater than three, etc."

#### 2.1 A feeling about async

Some of us make breakfast as a daily routine. Although everyone has his/her own preference, but if you don't change your breakfast too often as I do, you may prepare it in a relatively fixed procedure. As a lazy one, most of the time I have these as my breakfast: a cup of drip coffee, 2 boiled eggs, 1 sweet potato. And here're what I need to do(with time consumptions) every morning:

- heat water for brewing coffee (4 mins
- brew drip coffee (3 mins
- boil eggs (10 mins
- heat potato(pre-boiled and frozen) with microwave oven (2 mins

Intuitively we probably won't do these tasks sequentially. For example, when we are boiling eggs, we won't stare at the pot seeing the water boiling gradually and doing nothing else. Thus it may take us `3 + 4 + 10 + 2 = 19` minutes to make the breakfast. We all know we can do something else while we have started some previous tasks, especially some time-consuming tasks. Or we can say some tasks can be handled in parallel. One way to do things in this style may be like this:

```
|-------------- boil eggs --------------|
 |- heat potato -|
  |--- heat water ---|
                      |- brew coffee -|
```

By doing this we can have our breakfast only after 10 minutes. And the purpose of rearranging these tasks is similar to the purpose of "async" in programming.

Let's look at 2 description about async:

["asynchronous"](https://developer.mozilla.org/en-US/docs/Glossary/Asynchronous) from MDN:

> Asynchronous software design expands upon the concept by building code that allows a program to ask that a task be performed alongside the original task (or tasks), without stopping to wait for the task to complete.

The definition of "asynchrony" on [wikipedia](https://en.wikipedia.org/wiki/Asynchrony_(computer_programming)):

> Asynchrony, in computer programming, refers to the occurrence of events independent of the main program flow and ways to deal with such events.

No matter it's the "main/original" task or the "other/independent" tasks, they are just some tasks. *And "async" is just the way to coordinate these tasks so that they can be executed correctly and effectively.*

But what's the difference between "sync" and "async"? They are often involved with each other. When we say some code is executed synchronous we often mean that code is executed immediately and sequentially. And when we mention "async", it often implies that some "async" tasks deviate from the "sync" part to be execute somewhere else without disturbing "sync" part. But on the other side, there may be "sync" part resides in the "async" part.

We can first apply an oversimplified view of how sync and async are coordinated in a browser. That is, first handle the the sync things, then the async part.

#### 2.2 an oversimplified view: async goes after sync

A good starting point to develop a realization about the existence of sync and async in JavaScript is the "zero-delay" example with `setTimeout`:

```js
setTimeout(() => {
  console.log("I am the first line.");
}, 0);

// this line is only added for increasing the time consumption in between
for(let i = 0; i < 1000000000; i += 1 ) {};

console.log("I am the last line.");
```

If we don't have any notion about async with JavaScript we may expect the two messages to be printed out sequentially, just as the order they were written in code. However in this case, though the time delay of `setTimeout` is set to `0`, plus that we add a time-consuming operation in between, the message in `setTimeout` callback always goes after the `"I am the last line."`. The `0` didn't make sure `"I am the first line."` to be printed out right away. Because callback wrapped by `setTimeout` will be executed asynchronously. An oversimplified description of how this works is: the async part is executed after the sync part has finished executing. The async part here is the callback passed to `setTimeout`, everything else is the sync part. This is a typical example to prove the existence of sync and async parts.

But who makes the callback asynchronous? It's the `setTimeout` API. `Promise` also, has similar feature. Let's change the code example to use Promise:

```js
Promise.resolve("").then(() => console.log("I am the first line."));      // 1

// this line is only added for increase the time consuption in between
for(let i = 0; i < 1000000000; i += 1 ) {};                               // 2

console.log("I am the last line."); // this always gets printed out first // 3
```

The only change made here is the way we wrap the callback. And we get the messages printed out in the same order as the zero-delay one. For now we don't have to worry about what does the `Promise.resolve("")` do, just try to realize there is a distinction between sync and async, and the execution of sync and async code is coordinated in a certain way by the browser. It can be oversimplified as "async goes after sync".

#### 2.3 why the separation of sync and async makes sense

Let's recall the line `for(let i = 0; i < 1000000000; i += 1 ) {};`. This line may take several or more seconds to run in browser, that's why the two messages are both printed out after a short delay. Since sync code is executed sequentially which means lines of code are executed one after another, if there's some code that may take a very long time to finish running, all the code after that will wait for it. If we apply this scenario to the script behind a webpage(or say a tab of the browser), when some sync code is continuously executing, the page will get stuck and you'll find that you can do nothing with the page, it's just blocked. As we add more `0`s to `i < 1000000000`, the blocking time would increase at a substantial rate. It's just like the example of making breakfast, if all things have to be done one after another and boiling eggs needed 2 hours, a lot of time could be wasted.

A sensible way is to go through and set up all tasks as soon as possible, then outsource tasks that are time-consuming to somewhere else, just like how we change the way we make breakfast. Now take the code of incrementing `i` from `0` to `1000000000`, we can move it from the sync part to async part to eliminate the blocking experience in between. We can use `setTimeout` or `Promise` to do this:

```js
Promise.resolve("").then(() => console.log("I am the first line."));      // 1

// we can also do Promise.resolve("").then(() => for(let i = 0; i < 1000000000; i += 1 ) {});
setTimeout(() => { for(let i = 0; i < 1000000000; i += 1 ) {}}, 0);       // 2

console.log("I am the last line."); // this always gets printed out first // 3
```

Now the messages' printing order doesn't change, but the short period time of blocking disappears. Actually it doesn't disappear, it's just moved to the end of the execution. Because "async part goes after sync part", and we turned the counting operation into async task, so it's moved to the end of all the sync tasks. We can prove this by adding 2 or 3 more `0`s to the number then see if the browser is blocked after printing out the two messages.

#### 2.4 to be sync or to be async

Many tasks can be time-consuming like the counting number one, others like retrieving data from remote server, processing large amount of data. The separation of sync and async is just really a way to optimize the coordination of different tasks to provide user a smoother experience.

And of course not all async tasks will block the browser. Some kinds of async tasks may need a long time to perform, they may be handled by other parts of the browser and happen somewhere else. Blocking the browser in the middle or in the end is not always the case. The take away is there is a separation between sync and async, but the purpose of the making the separation is to find a way of better coordinating different kinds of tasks. Actually, the separation of sync and async are only made by humans conceptually, they both are just code, a time-consuming calculation can be set to sync, a `console.log()` task can be set to async, it all depends on you, the person who writes the code.
Counting to 1 billion may be slow now so we want to make it async. But what about 10 years later when the computation ability of our devices increase substantially, when downloading data of 100G only takes a few ms? At that time maybe nobody remembers sync/async because we have a very different notion about slow and fast, and we have new ways of doing things.

Back to our discussion......Async code goes after sync code, but how these two parts are coordinated in the browser, how this task is achieved? The answer is the [event loop model](https://developer.mozilla.org/en-US/docs/Web/JavaScript/EventLoop).

### 3 Mental model of Event Loop -- the mechanism to coordinate sync and async tasks

Imagine `async code goes after sync code` is a chunk of code in a function block, such as `function cycle() { async code goes after sync code }`. We put this code into a loop, then we get the "Event Loop" such as `while(true) { cycle() }`. Of course things are not so simple but it's also not so complicated.

#### 3.1 a feel about event loop

First let's check 2 descriptions about event loop.

According to [MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/EventLoop):

> JavaScript has a concurrency model based on an event loop, which is responsible for executing the code, collecting and processing events, and executing queued sub-tasks. This model is quite different from models in other languages like C and Java.

According to [whatwg](https://html.spec.whatwg.org/dev/webappapis.html#event-loops):

> To coordinate events, user interaction, scripts, rendering, networking, and so forth, user agents must use event loops as described in this section. Each agent has an associated event loop, which is unique to that agent.

Forget about these intimidating terms, just get a feel about it. But remember that "sync/async are just ways of coordinating different tasks".

#### 3.2 A demonstration about how event loop operates in browser

I prefer understanding event loop from a more demonstrating way, a good explanation is the video [What the heck is the event loop anyway?](https://www.youtube.com/watch?v=8aGhZQkoFbQ) by Philip Roberts.

*And you should really mentally go through the process demonstrated in the video before we can continue.*

#### 3.3 Components of event loop

One important thing we need to clarify is the relationship among JavaScript language, the browser, and the event loop. The browser is more than JavaScript language. JavaScript is just a core component of the browser, it's like the engine of it. The browser actually provides a whole suite of components to maintain an environment for the event loop model to be implemented. Let's zoom in to look at the components of event loop model:

- the main thread/stack: as the word "main" indicates, that's where we run our main tasks, or we can think of it as a place to run sync code
- a task queue: it's a place queued with tasks that are waiting to be executed in the main thread when the main thread is clear.
- web apis: the tools provided by the browser to schedule tasks sent from the main thread to the task queue

To put these components in operation, the event loop acts as an observer. It keeps an eye on the main thread, if all the tasks there are finished running, it let the oldest(the one that got queued earliest) task in the task queue pop out into the main thread, and then execute it, then the second earliest one, so on and so forth.

#### 3.4 run, event loop

Let's review the code example:

```js
setTimeout(() => { console.log("I am the first line.") }, 0);          // 1

for(let i = 0; i < 1000000000; i += 1 ) {};                            // 2

console.log("I am the last line.");                                    // 3
```

Except for the callback passed to `setTimeout` at line 1, all other code is synchronous, which means they be executed first, line by line from top to bottom.

Imagine that we first go through all the code. When code goes to line 1, `setTimeout` will set the callback aside to a scheduler or say timer, then the code in the main thread goes on executing, when code in the main thread has finished running, the scheduler(timer) starts counting for 0 second, then the callback will be put in the task queue. The work of event loop is to look at the main thread, if all sync code has finished running there, the first(oldest) task got queued in the task queue will be popped out then pushed in the main thread and be executed. And this process keeps running as if it's a "loop".

![](https://tva1.sinaimg.cn/large/007S8ZIlgy1gienkh1pi4g30hs0hsb2d.gif)

The event loop model explains why zero-delay callback doesn't have a real zero-delay. Because based on how the event loop operates, the real time delay is the never shorter than the `execution time of the main thread`.

#### 3.5 Problem, intention, concept, implementation

The event loop model was designed for solving certain kinds of problems. Different materials about event loop may introduce different terms like "stack", "heap", "main thread", "queue", "task queue", "micro-task queue", "macro-task queue", and it's tempting to dig deeper on these things. But we should realize the "Event Loop" is not a standard way of solving a problem, it's an abstract model, it's written [in the standard](https://html.spec.whatwg.org/multipage/webappapis.html#event-loops), but there isn't a single right way to implement it. Implementation details of event loop in one browser like say [Google Chrome](https://en.wikipedia.org/wiki/Google_Chrome) may be so different from others. What's in common is the event loop model. And If we see "ways of coordinating sync/async tasks" as a `Class`, then the mental model of "Event Loop" is a `Subclass` of it, and the implementation of event loop model for a specific browser is an `instance` of the `Subclass`.

If we understand event loop correctly at a high level, we can confidently predict how the sync and async code will be operated within an app, and write code with confidence.

### 4 Summary

Now we know the distinction between sync and async is not made by the code itself. "Async" is more of ways to coordinate various tasks, it's more of choices made by programmer.

Event loop is a way of coordinating different tasks in browsers. Although we ignored most implementation details to only keep an abstract mental model, but this model is quite reliable at this stage for us to set off the journey towards Promise. And above the concept of async, promises are all about making asynchronous code more readable and behave like synchronous code.
