---
title:  "An overview of WeChat MiniProgram 1: The niche"
categories:
  - Work
tags:
  - information
  - WeChat
layout: post
---

Wechat MiniProgram is a type of small programs that can be used in the [WeChat app](https://en.wikipedia.org/wiki/WeChat). By 2020, the daily active users of MiniProgram have reached 400 million. And the number for WeChat itself is much higher. The official guide defines it as:

> Weixin Mini Programs are a new way of connecting users and services. They are easy to access and share on Weixin, delivering excellent user experience.

Why MiniProgram grew so fast?  What is "the new way"? Let's explore.

# 1 A brief history

## Gaining popularity

It's hard to imagine today in China there's a phone without WeChat installed. Besides traditional phone call and messaging features, WeChat provided almost everything you can imagine to facilitate communication. And yes in early days, as its name 'WeChat' implies, WeChat was just for communication, it gained popularity with 'audio message' feature. Then it introduced [WeChat Pay](https://en.wikipedia.org/wiki/WeChat_Pay), a service like [Alipay](https://en.wikipedia.org/wiki/Alipay). Money then flew through WeChat.

## The third way of opening webpages in WeChat

As users increased rapidly, more and more users used WeChat as the entrance to open webpages, they had two choices that time: 1) open webpage within WeChat via [WebView](https://ldapwiki.com/wiki/WebView), it's like a simplified browser embedded in WeChat; 2) copy the url and open webpage with browsers such as safari or chrome. With way 1, we don't have to leave WeChat, but the user experience is not good. And of course the experience won't be good either for way 2. After trying some workarounds, MiniProgram was born.

# 2 Typical using scenarios for MiniProgram

But WeChat MiniProgram was not designed to be a one-fit-all solution for any services, though it was initially provided to be a mini browser with a better user experience when accessing webpages., it's not equal to a browser. Some using scenarios are:

1.  when we want a service that only takes short period of time such as ordering coffee or get a health code
2.  when we need to access services that are less frequently required such as ordering train tickets or flights

**1 Use it then leave immediately**

Imagine you walk in a restaurant and people there ask you to sit down and scan the code on the table to order food using your phone. Or when you are visiting a museum, the staff ask you to show your health code issued by government to prove that you are not exposed to COVID-19. You are most likely doing these via WeChat MiniProgram. In the restaurant, you scan, open a MiniProgram then you order food, you pay with WeChat pay, then you leave. Maybe you'll come back again maybe not.

There's no new app added to your phone nor you need to open a browser, all are done within WeChat app, the whole process is smooth and convenient.

**2 Services that are used less frequently**

Let's take the example of ordering train ticket. If you don't travel too often, you may order train tickets online once or twice a year. Possible situations are:

You install a booking app on your phone then use it one or two times a year, then it sleeps on your phone until the next time you need it, maybe a year later. What if you have many "occasionally needed" apps on your phone, are they a waste of resource for your phone? Another scenario is to use the web app version, and a web app running on a phone won't provide a great user experience.

Booking tickets is not a complex process and it can be done by a MiniProgram. In this case you open WeChat, find the booking MiniProgram, book the ticket, then leave. The whole process may only take 5 minutes or less, no app and browser are needed, it doesn't leave a trace on your phone.

# 3 Deliberately to be 'Mini'

You may wonder how many restaurants or cafes can afford to such an ordering system. Well if this is done by traditional ways of building a web app or mobile app, except for some big ones there won't be too many, but in China today so many stores are using MiniProgram even small cafes.

If you ever used a few MiniPrograms, you'll find they are not trivial at all and you may wonder how all these can be done within 12 MB code. If a MiniProgram is fast enough, you may have the illusion that you were using a native app installed on your phone. If you try several more MiniPrograms, you'll find the UI of them are similar this is because developing a MiniProgram we don't have to write everything from scratch, the use of built-in 'Components' make things a lot simpler.

Here's a demonstration of a cafe MiniProgram:

![](https://tva1.sinaimg.cn/large/008i3skNgy1groxybq3pzg308v0ftu0x.gif)

## Being versatile without writing much code

To develop a MiniProgram, you don't have to write as much code as developing a traditional web app. Two reasons:

1.  you're just writing the client side code, mostly frontend code

2.  MiniProgram uses [components](https://developers.weixin.qq.com/miniprogram/dev/framework/view/component.html) as the basic building blocks at its presentation layer.

A component is like a `HTML` tag, but unlike in a browser there isn't a DOM. A component can directly provide basic view and features for a widget on a page. Some components are actually a complete implementation of specific feature at both view and logical layers. For example a progress bar: in traditional web development, we need to write code in `html`, `js`, and `css` to construct a basic view and function of a progress bar, but in MiniProgram, we can simply achieve this by using a [`<progress>` component](https://developers.weixin.qq.com/miniprogram/dev/component/progress.html).

`<progress percent="20" show-info />`

With no more code, we get a progress bar and we are allowed to update the percentage view by updating the `percent` attribute which also doesn't need to much code.

## The 2 MB limit

MiniPrograms can only be run in WeChat app, it's not meant to be a general purpose environment supporting all sorts of apps though theoretically we can do almost anything where we can write code. But you may not want to write a full featured [Taobao](https://en.wikipedia.org/wiki/Taobao) MiniProgram. In this case I believe that a [mobile app](taobao.com) or web app are way better choices than a MiniProgram. And although the types of components would keep expanding in the future but it is not meant to cover as many types as they can.

There is a limitation on the total size of the codebase of a MiniProgram. [The total size of all packages must be smaller than 20 MB and a single package must be smaller than 2 MB](https://developers.weixin.qq.com/miniprogram/dev/framework/subpackages.html). This also limits the scale and type of MiniPrograms and I think this is why they call it 'Mini' program. Think about the opposite situation when there's no limit on the size of MiniProgram. Think about many MiniPrograms sized over 200 MB running in WeChat. At least it doesn't make sense at this point.

# 4 Summary

It's interesting to think about how things happened and how things would develop within an app which has over 1 billion users. Having tons of 'program's running inside of an app, how these "parasitic" programs "live" inside their host program?
How do they communicate to their host program? How do they communicate to external servers? How to transfer from a traditional web app or native app to MiniProgram? Will MiniProgram replace any web app or native app? These are all interesting questions to explore.

Despite all these puzzles MiniProgram does solve some pain points for users. I remember when there's no MiniProgram, it's not easy to use a web app opened via WeChat, and there's also so much inconsistency in UI. MiniProgram does provide "a new way of connecting users and services. They are easy to access and share on Weixin, delivering excellent user experience."
