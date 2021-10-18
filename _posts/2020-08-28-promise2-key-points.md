---
title: "On exploring Promise 2: possible overlooked points about promise"
categories:
  - Work
tags:
  - programming
layout: post
---


This is part 2 of my exploring on promise. In part 1, I shared my thoughts about "async" and "event loop" as the basis to better understand promise. The main purpose of this part is share some points or say "blind spots" about promise that may impede your understanding of promise.

After a brief introduction about basic aspects of promise, I'll share a few links for learning how to use promise. Because have a basic sense about what is promise and how to use it is important for the main discussion in this article. You don't have to master "promise" after the studies, otherwise there wouldn't have been this article. I believe many beginners will leave mental gaps after being introduced with promise. Some key points are somehow omitted by most learning materials. Maybe they are too obvious to pros, but
not so obvious to newbies. It's more of a communication problem. I hope this article can help you recognize a few of these points and help you connect the dots from "async" to "promise".

**Terms in this article**

Based on different contexts, the word "promise" has different meanings, most of the difference can be distinguished with different writing forms but there're a few subtle ones may not be easily distinguished. In this post "promise" may in the forms of:

- plain lowercase "promise": the general concept of promise
- code quoted lowercase `promise`: an instance of a promise
- code quoted uppercase `Promise`: the `Promise` [constructor](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/Promise)

And `resolve(d)` and `fulfill(ed)` are used interchangeably.

### 1 Basic aspects about promise

#### 1.1 Sense of promise:

I want to start with different definitions of promise. For now we don't have to understand all the terms before we can continue. Here comes the definitions:

- [Promise/A+](https://promisesaplus.com/): A promise represents the eventual result of an asynchronous operation. The primary way of interacting with a promise is through its then method, which registers callbacks to receive either a promise's eventual value or the reason why the promise cannot be fulfilled.
- [MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise): A Promise is a proxy for a value not necessarily known when the promise is created. It allows you to associate handlers with an asynchronous action's eventual success value or failure reason.
- [wikipedia](https://en.wikipedia.org/wiki/Futures_and_promises): In computer science, future, promise, delay, and deferred refer to constructs used for synchronizing program execution in some concurrent programming languages. They describe an object that acts as a proxy for a result that is initially unknown, usually because the computation of its value is not yet complete.

So promise must have something to do with "async", and it's a representation/proxy for a future result. Bringing this high level sense of promise into the exploring of promise is necessary.

#### 1.2 use of promise

As I said, this part of work(use of promise) is excellently done by some pros, thank them a lot!

- https://web.dev/promises/

This article does a thorough explanation about the use of promise with code examples, along with some performance concerns. Inevitably you would come across some unacquainted terms. You can glimpse their definitions on wiki if you want to, but don't go too deep, focus on "how to use promise" and just get a feel about it. And you may want to read it multiple times as I did.

#### 1.3 States of promise

Promise is like a wrapper for asynchronous operations(tasks), and it holds the result of the task and based on how things are going, it stipulates a promise can be in one of [three states](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise):

- pending: the initial state, means the task is still processing and we don't know how things are going so far
- resolved: means the task is successfully fulfilled, and it may give us something we want such as data or just a message that indicates the task has succeeded.
- rejected: means the task failed, and reasonably a reason(often an error object) should be given to tell what was wrong

`pending` is when the async operation is still processing, `resolved(fulfilled)` and `rejected` are when the async operation is completed whether succeeded or failed, when a `promise`'s state is `resolved(fulfilled)` or `rejected`, we also say it's settled.

### 2 A few key points that may be overlooked

This part mainly shares with you some key points about promise. They are not overlooked by purpose, and you may feel so strange that you haven't noticed them. Because they are just some basic facts sit there for a long time.

#### 2.1 `Promise` constructor is used for creating promise, `then()` method is used for accessing promise

There's a concise description about the purpose of `Promise` constructor.

> [The Promise constructor is primarily used to wrap functions that do not already support promises.](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/Promise)

After reading a lot about how to use promise, we know that `Promise()` can create a `promise` and `then` is the way to chain subsequent operations. But being aware of the original designing purpose is also important, especially when you ask question like "Since `Promise()` and `then()` both return a promise, so what's the difference?". Maybe we should ask a more basic question: what a constructor is used for in JavaScript?

The answer is when we want to create a `promise`, the `Promise()` constructor is the first choice, not `then()`.We can say `Promise()` is primarily used to wrap functions that do not already support promises. Or we can say it's used for "Promisifying" something. And  `then()` is the way to chain promises, as well as the way to access the value of a `promise`. Though `then()` always returns a `promise`, we should not treat this behavior as its designing purpose. Seeing `then()` as the interface to access `promise`s is a more appropriate view.

#### 2.2 Code in `Promise` executes as soon as the promise is created

I think this is an important fact but most intro level materials don't mention. And this trapped me for a long time when I was trying to figure out how to use promise.

**the beginning of creation is the beginning of executing**

If we have a function that returns a `promise`:

```js
function makePromise() {
  new Promise((resolve, reject) => {
    // do sync thing one
    // do sync thing two
    // resolve or reject at a certain point
  })
};
```

When you execute `makePromise()`, `thing one` and `thing two` in the callback are beginning execution and are done synchronously immediately. I don't know why I had a tendency(don't know if others have too) to think all the code within the `Promise` constructor only begins executing as a whole at the settling point, the point when the `resolve` or `reject` are called. Realizing this is important for us to maintain the execution sequence of tasks and thinking about possible performance considerations.

**order of creation is not the guarantee of order of completion**

If we have a list of urls `[u1, u2, u3]` that don't depend on each other, means they can be loaded in parallel. But we want to get things from the 3 urls one after another, in the order of `1,2,3`. We may write something like this:

```js
function requestURL(url) {
  return new Promise((resolve, reject) => {
    let xhr = new XMLHttpRequest();
    xhr.open('GET', url);
    xhr.addEventListener('load', () => {
      let result = xhr.response;
      resolve(result);
    })
  });
};

[u1, u2, u3].forEach(url => {
  requestURL(url)
})
```

Although all the requests may succeed but the order of completion is not guaranteed. Why? Because `forEach` is sync and what we actually did can be seen as:

```js
requestURL(u1);
requestURL(u2);
requestURL(u3);
```

All `promise`s begin creating almost at the same time because the 3 function calls are executed synchronously, meanwhile all code within `Promise` constructor begins executing. `requestURL` returns a `promise`, but code written in `Promise` constructor won't pause executing. So the 3 requests begins at almost the same time but we don't know how much time each request would take, therefore we don't know the order completion.

**there's no waiting among multiple promises created independently**

Since a **promise chain** will be paused for `pending` promises, it's easy to transfer this fact(feeling) to the situation when we create multiple `promise`s at one time, thinking that lately created `promise`s would wait for the earlier ones to be settled. But:

- waiting happens when there's `pending` promise in a chain. You can't just make a `promise` independently then "pause" it there, neither from inside nor outside.
- a `pending` promise never pauses itself. When a promise is created, its original state is `pending`, but from an internal view, `pending` doesn't mean pausing/waiting. As long as there is call for `resolve` or `reject` thereafter, a `pending` promise is approaching the state of `fulfilled` or `rejected`.

So creating a bunch of `promise`s doesn't mean the latter ones will wait for the earlier ones, doesn't mean they be completed in the order of creation. Unless you wrap the process of creating promise inside a function(a function returns a `promise`), then arrange them in a chain. There is a big difference between "creating a promise" and "a function that creates a promise". Because when we pass "a function that creates a promise" to `then()`, the creation of promise won't start before the chain advances to that `then`.

**how to maintain sequence of operations**

How to chain the requests in a wanted sequence or say initiate them one after another? Also with `forEach`, but this time a bit different.

```js
let chain = Promise.resovle('');

[u1, u2, u3].forEach(url => {
  chain = chain.then(() => requestURL(url));
})
```

Notice `chain.then(() => requestURL(url))` is different from `chain.then(requestURL(url))`,  `requestURL(url)` is a function invocation that will create a `promise` immediately, you should always pass a *function* to `then()`.

#### 2.3 `resolve` happens immediately

The same example:

```js
function fetchURL(url) { // returns promise
  return new Promise((resolve, reject) => {
    let xhr = new XMLHttpRequest();
    xhr.open('GET', url);
    xhr.addEventListener('load', () => {
      let suburl = xhr.response[0];
      resolve(suburl);
    })
  });
};
```

This is a tricky point. The `resolve` method don't know how much time a request would take. We call `resolve` in `Promise` constructor, and that happens inside the `'load'` event listener. Here `resolve(suburl)` has no notion about `sync/async` it's called immediately when the request is `'load'`ed, and calling `resolve(suburl)` grants the state `fulfilled` to the promise with `suburl` as its value to prepare for possible future operations. And resolving of a promise is synchronous or say happens instantly.

This may seem obvious after you've noticed it. But realizing this fact can fill some mental gaps while trying to understand the using of promise. Since promise is heavily about "async", it's easy to forget that there're also "sync" things there. It's easy to grumble questions like "how does the promise know when to resolve itself", the answer is it doesn't know. Because the "resolving" moment depends on something else such as explicit writing sync code to resolve the `promise`, like `Promise.resolve()` or call `resolve` in a `Promise` constructor.

To me "`resolve` happens immediately" is a very useful nonsense.

#### 2.4 function is the only currency within a promise chain

I think initially we all know that `then` takes functions as arguments after we learned about the definition and use of promise. But as days roll on, we may want to stuff anything inside that pair of parentheses `()` followed by `then`. Especially things that are not function.

[Promise/A+ spec](https://github.com/promises-aplus/promises-spec) also mentions that `then` must return a promise and if `onFulfilled` *is not a function*, a `then` called on a resolved promise must return a new promise resolved with the value of the previous promise. It's better to be expressed by code:

```js
let resolvedPromise = Promise.resolve("One"); // 1
resolvedPromise.then("two"); // 2
```

Line 1 returns a promise resolved with "One", but line 2 returns a new `promise`: `Promise {<fulfilled>: "One"}` resolved with `"One"` NOT `"Two"`. The string `"Two"` we pass the `then()` is ignored.


If we make a promise chain with several non-functions inserted for example:

```js
resolvedPromise.then(func).then(non-func).then(func).then(non-func)
```

We can imagine that we strikethrough the `.then(non-func)` parts like:

![](https://tva1.sinaimg.cn/large/007S8ZIlgy1gig7q4l7irj32a407w3zv.jpg)

Some call this "promise fall through". What if one of the `non-func` is a `promise`? You may think the promise chain won't ignore a `promise`. Let's try by code:

```js
let resolvedPromise = Promise.resolve("I was resolved");

let starterPromise = Promise.resolve("I am the starter promise.");

starterPromise.then(resolvedPromise);
// Promise {<fulfilled>: "I am the starter promise."}
```

The last line returns `Promise {<fulfilled>: "I am the starter promise."}`, the resolved value of the `resolvedPromise` we passed to `then()` was not taken. So there's no exception for this rule. *Function is the only currency within a promise chain*. If you want to insert a `promise` into a promise chain, use a function that returns a `promise`.

#### 2.5 two kinds of waiting on promises

Personally I prefer to understand that there're actually two kinds of waiting for a `pending` promise. One is wait from "outside", the other is wait from "inside".

Wait from inside" means inside a `Promise` constructor, after a `promise` is created, it's initially set to `pending`, and then it's waiting to be either fulfilled or rejected. This kind of waiting is often neglected. On the contrary, the waiting made by `then()` is stressed a lot, and this is "wait from outside". *Both kinds of waitings wait on a `promise` to transit from `pending` to `fulfilled/rejected`*, but they are different. Having a notion of this helped me better understand the states of promise as well as the behavior of a promise chain.

##### 2.5.1 how to make a `pending` promise?

This is fun and easy. Remember I said when trying to create a `promise` always consider `Promise` constructor? So the answer of this is "just make it but don't resolve it". That is:

```js
let pendingPromise = new Promise((resolve, reject) => {}); // Promise {<pending>}
```

By doing this we get a pending promise `Promise {<pending>}` since we don't call `resolve()` or `reject()` at all inside the callback. Another theoretically possible scenario is we called `resolve()` or `reject()` but the time before that happens was "forever". For example, `resolve()` or `reject()` is waiting to be called after a data retrieving task that never ends.

##### 2.5.2 pauses on `then`s are "visible"

Now if we have a `pending` promise, let's see how the chain will pause:

```js
let pendingPromise = new Promise((resolve, reject) => {}); // Promise {<pending>}

pendingPromise.then(() => console.log("Hello World.")); // Not words printed out
            //  ^
            //paused
```

Since `pendingPromise` is at the state of `pending`, the next `then` will wait on it. I often see words like "waiting on a promise", though this is not wrong, but this gives us a sense that where there is a promise there is a waiting. But waiting only happens on `pending` promise.

##### 2.5.3 `then()` only waits on `pending` promises doesn't mean settled ones are skipped

```js
Promise.resolve("one").then(() => Promise.resolve("two")); // Promise {<fulfilled>: "two"}
Promise.resolve("one").then(() => Promise.resolve("two")).then(() => Promise.resolve("three")); // Promise {<fulfilled>: "three"}
```

Here both lines start with a `promise` resolved with `"one"`. When we chain one `then` we get a new `promise` resolved with `"two"`. When chain two `then`s we get a new `promise` resolved with `"three"`. Based on line 1 we know there is a "middle promise" with "two" as its value existed transitorily. But no `promise` is skipped even through they are resolved ones.

If we configure a promise chain appropriately, of course the chain will wait on `pending` promises, but the chain also won't forget to go through every `fulfilled` or `rejected` ones.

### 3 Try to nurture intimacy with standard

This is more of a suggestion than another key point, but I think it's important for learning promise too.
If you've ever explored some articles about promise, you may have been introduced with the [Promise/A+](https://promisesaplus.com/) standard, I mentioned it several times in this article. As it states, it's:

> An open standard for sound, interoperable JavaScript promises—by implementers, for implementers.

In that page, there are just several sections of structured rules. So promise is more of a model, it's not some hard-coded packages. The rules describe how to implement promise, but there doesn't exist a single right way to implement it. This is very similar to what we talk about the mental model of event loop. Actually if you have known the basic aspects of promise and are using the correct terms, reading the standard is more helpful when you are confused by "promise puzzles". The standard is really boring, but it's also very reliable.

### 4 Summary

In this 2-part article, I think the important takeaway are:

- the separation of async and sync is for better coordinating different tasks, and event loop model is one way to do the coordinating work.
- differentiate sync and async part when using promise; there are two kinds of wait for a pending promise; function is the only currency in a promise chain.
- try to nurture intimacy with standards and docs.

We've been through a long journey from setTimeout to Promise. In part 1, we spend most time discussing what is sync and async, and how they are coordinated by the event loop model. Although we barely mentioned promise in part 1 but all the discussion there will support our understanding of promise. In this part 2, I don't write about how to use promise, instead I focus on some key points that may be missed during the process of learning promise. Hope this can help you a bit on the journey of exploring promise.

---

*References:*

https://web.dev/promises/

https://pouchdb.com/2015/05/18/we-have-a-problem-with-promises.html

https://en.wikipedia.org/wiki/Futures_and_promises

https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/Promise

https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise

https://promisesaplus.com/

https://stackoverflow.com/questions/31324110/why-does-the-promise-constructor-require-a-function-that-calls-resolve-when-co

https://stackoverflow.com/questions/22519784/how-do-i-convert-an-existing-callback-api-to-promises
