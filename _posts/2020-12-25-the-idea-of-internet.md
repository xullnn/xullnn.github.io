---
title:  "The beautiful idea of the internet"
categories:
  - Work
tags:
  - information
layout: post
---

In this post, I'll share my thoughts about the big picture of the internet without mentioning too many tech terms.

When we think about the internet by looking around our daily life. Most of us can recall terms like "wifi", "router", "modem", "cables" or even "4G", "5G". When we message a friend, we know messages will get sent from our phone to our friend's over the internet. But we don't have a big picture about how this exactly works.

The internet is a huge topic but what's most important is the design philosophy behind.

> One thing that most people do not appreciate is that the internet is really a design philosophy and an architecture expressed in a set of protocols.

-- [Vinton Cerf on Khan Academy](https://www.khanacademy.org/computing/code-org/computers-and-the-internet/internet-works/v/the-internet-ip-addresses-and-dns)

### A general feel by dissecting the word "Internet"

To get a general picture of the internet we can gain some insights from the name of it "Internet"

Net

There're many 'net-related' things in our life, to the most basic sense it's anything that are comprised of two or more nodes connected together by some physical medium. More concretely and officially net can be defined as "a length of open-meshed material made of twine, cord, rope, or something similar, used typically for catching fish or other animals"

Inter-

When we use 'inter-' as a prefix, it means "between", "among", "together".

Inter-net

When we compound these two conceptions together we get the big picture of the internet. It's just many nets connected in a way that how a single net is comprised. It's a net of nets or network of networks, or more complex, networks of networks.

![](https://tva1.sinaimg.cn/large/0081Kckwly1gm06zgpxfjj30xc0hiafi.jpg)

### Protocols, things that enable communication over the internet

At the atomic level, there are only nodes and connections that connect them. But nodes don't randomly talk to other nodes, typically one node want to talk to a known node somewhere in the internet. How we find the person we want to communicate? What if we don't want anybody else to know what we are talking? What can we do if messages get lost the midway? How we recover if part of the network is broken?

At this point we know that only nodes and connections are not enough for the internet to work successfully, at least it won't be a reliable way to communicate. That's where the different protocols come in. Essentially, a protocol is a solution to one of the many concerns we mentioned. And those solutions are not done by changing any structure of the internet at the infrastructure level, instead each protocol can select certain attributes from the physical carrier or other protocols and some kind "concoct" a formula to solve problem(s) about the communications over the internet.

For example the [Internet Protocol](https://en.wikipedia.org/wiki/Internet_Protocol) concerns about the problem of "how to find someone"; the [Transmission Control Protocol](https://en.wikipedia.org/wiki/Transmission_Control_Protocol) concerns about the problem of how to make sure the message is reliably received by the other party. And yes one protocol can be designed to solve multiple problems. And for one problem, different people may have different solutions(protocols). That's why there're are so many different protocols and there'll be more in the future.

It's just rules taking care of various problems about communications over the internet.

### Spider, Sponge and Starfish

The idea is simple, it's just a network of networks and the protocols added upon. But simple combination can give much of the power of the internet.

**Spider web the approachability**

A spider can get from one point on the web to another by possibly choosing any paths, it doesn't have to be the shortest one, as long as we get to the destination. The internet is, in a sense, just like a spider web. But unlike a spider, things don't move by itself over the internet. Information moved over the internet is driven by protocols and different network devices such as routers. Thanks protocols and network devices, each node along the path knows where the next node to go. Sometimes for a single message delivery, there'er may have multiple paths to be used. It's like when we order many products from JD.com, but for some reason -- some products are not currently in stock, some must be delivered by ships/cars/airplanes while others don't have to -- they have to be split in multiple packages and may arrive at different time. Though information goes through many nodes, but eventually, it gets sent to the destination correctly whether it's slow or fast.

**Sponge the flexibility**

Sponge can absorb water as well as squeeze out water. The internet has scalability. When we want to absorb more nodes into the internet, or we want to abandon some nodes even some network from the internet, the rest of the internet can keep working. More nodes means more possible path combinations and vice versa. And it's the cooperation of the internet infrastructure and the protocols operating on it that makes this flexibility.

**Starfish the resiliency**

What would happen if part of a spider web is damaged? The spider would just bypass the broken paths and simply choose another path. What would happen if we cut down a tentacle of a starfish? It won't die and instead it grows out a new tentacle.

The scenario will be similar if the same thing happens to the internet. The internet can recover from a local damage or congestion, and the rest of it can still work. This is also the cooperation of the internet infrastructure and the protocols operating on it that makes this resiliency.

### Bad things happen

The combination of infrastructure plus protocols let things flow all around the world easily. But such a powerful system is not born to be "kind-hearted", if useful information can be delivered and good things can be done via the internet, then useless information and bad things exist too.  

Protocols provide solutions to take care of different aspects of the communication. And a large amount of the solutions are about preventing bad things from happening. Protocols such as TLS do things like encryption, authentication and integrity.

**Encryption** cares about how to keep data transfer private and the communication content can only be seen by those who should know the real content. Ways of doing this often involve some complicated but elegant math like [symmetric key encryption](https://en.wikipedia.org/wiki/Symmetric-key_algorithm) and [asymmetric key encryption](https://en.wikipedia.org/wiki/Public-key_cryptography). It's like two people speak in front of a crowd but in a language that only they(the two people) can understand.

**Authentication** cares about identity verification during a communication. It's like we normally don't talk to strangers, if we have to, we must confirm the other party's identity. This is usually done by both parties take out a piece of proof to show their identity. The instances include terms like 'session id', 'Certificate' etc., but in essence they are just ways to verify identity.

**Integrity** cares about the intactness of the data. It ensures that when data arrive, nothing has changed about it. This often needs a recipe that consists of a piece of data extracted from the raw data(the complete data we want to transfer), some math formula and value that both parties know, then mix them up to get a "digital dish". This dish will first be made on the side who sends data, then it gets delivered along with the raw data to the receiver. When data arrive, the receiver will use the same ingredients, the same recipe, the same way to make a same dish. Then it compares the dish it just made against the one delivered from the other side. If the two dishes are exactly the same, then it knows the data hasn't been changed.

### Summary

The magical thing here is how different protocols can pick one or more characteristics from the lower level medium or protocol. Then construct something that looks like completely new and can provide features that other layers don't provide. It's as magical as how life is originated from basic elements that don't have life. Complexity builds layer by layer, things get more and more concrete towards the higher level and more and more abstract towards the lower level. Back to the beginning, what we have is just nodes and connections and ideas(protocols), so I believe this is beautiful.






