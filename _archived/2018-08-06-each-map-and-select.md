---
title:  "Developing better understanding about the 3 main types of enumerating operation on ruby collection through each, map, and select"
categories:
  - Life
tags:
  - programming
layout: post
---

辨析三个不同的迭代术语所指代的具体操作含义。

Let's start with some code:

```ruby
[1,2,3].map do |num|
  if false
    num
  end
end
```

Can you tell the return value of the code above? What about swapping the `map` method with `each`, or `select`?

When we are new to programming, many may feel methods like `each`, `map`, `select` are so similar to each other. They look like just *'visit every object in the collection, do something, then leave.'* And we can find many questions like "what's the difference between each and map in Ruby?" or "When I should use each and when map?" out there. It may take a long period for us to completely understand how these methods behave.

Truth be told, if we knew several basic facts about these methods, things would become badly understandable. I'll throw them out first.

### Facts we need to know

- Notice the common strucutre of the methods calling is **method + block**
- **Three basic types** of enumerating operations: iteration(traverse), transformation, selection.
  - iteration(traverse): represented by `each`
  - transformation: represented by `map`
  - selection: represented by `select`
- **How** the three types of methods care about the return value of the block
- What's the **Return value** of the block
- What is the **final return value** of the method calling

### Notice the common strucutre of these methods calling is **method + block**

This is obvious.

```ruby
collection.each do |item|
  # do something
end
```

is the same as:

```ruby
collection.each { |item| # do something }
```

`each` is the method we are using, the `do...end` or `{  }` part are different syntaxes.

### **Three basic types** of enumerating operations: iteration(traverse), transformation, selection.

As we mentioned at the beginning--three types: iteration(traverse), transformation, selection.

**iteration(traverse)**

The typical representation of this type is `each` method. It just 'visit' the objects in the collection one by one while it may do something to the object or do nothing. Then it always returns the original caller object, unless you have changed some objects in the original collection during iteration, but normally the caller won't be changed, since it's not a good habit.

```ruby
nums = [1,2,3]
# => [1, 2, 3]

return_value_of_each = nums.each do |num|
                         num**2
                       end
# => [1, 2, 3]
return_value_of_each.object_id == nums.object_id
# => true
```

Most important, `each` do not care about the return value of the block. It directly return the caller object.

**transformation**

The typical representation of this type is `map` method. There are 2 main differences between `map` and `each`:

- `map` will return a new array, not just the caller
- `map` cares about the return value, not just 'visits' every object

```ruby
nums = [1,2,3]
# => [1, 2, 3]

return_value_of_map = nums.map do |num|
                        num**2
                      end
# => [1, 4, 9]
return_value_of_map.object_id == nums.object_id
# => false
```

Another important thing is the returned array of `map` will always keeps the same size as the original collection. It creates a new array, fills every position with the return value of the block--no matter what is the return value.

What would the return value of the code below?

```ruby
[1,2,3].map do |num|
  puts num
end
```

It's `[nil, nil, nil]`. Why? We can use some code to explain this:

```ruby
puts "I'm not nil"
# => nil

[] << (puts "I'm not nil")
# => [nil]
```

Let's take a look at a tricky example:

```ruby
nums = [1,2,3]
# => [1, 2, 3]

return_value_of_map = nums.map do |num|
  nums[i] = num**2
  i += 1
end
# => [1, 2, 3]

return_value_of_map
# => [1, 2, 3]

nums
# => [1,4,9]
```

Why the `return_value_of_map` is still same as the original `nums`? No they are not the same. Remember how Ruby determines the return value? The last line, here it is `i += 1`, this is why we get `[1,2,3]` again.

When mapping through the array, `nums[i] = num**2` was actually mutating the original array, so after the whole procedure, nums has been changed to `[1,4,9]`. But since we were using `map` not `each`, it will not return the caller(now is [1,4,9]), it returns a new array which contains every return value coming from each iterating step, or say, the return values of the block.

**selection**

The typical representation of this type is `select` method. Much like `map`, `select` also cares about the return value of every iterating step(return value of the block). But it not just simply picks up the return values then pushes them into a container object. It first evaluates the return value's to truthiness, then use this truthiness as its choosing criteria--this is why this type named 'selection'--since every 'selection' needs a criteria.

First a simple example:

```ruby
hash = {a: 1, b: 2, c: 3, d: 4}
# => {:a=>1, :b=>2, :c=>3, :d=>4}
hash.select do |key, value|
  value.odd?
end
# => {:a=>1, :c=>3}
```

Three things need to notice:
- `select` returns a new hash
- return hash may smaller than the original caller
- during the iterating, whenever the block's return value evaluated to `true`, the corresponding object in current step will be chose.

Another example:

```ruby
hash = {a: 1, b: 2, c: 3, d: 4}
# => {:a=>1, :b=>2, :c=>3, :d=>4}
hash.select do |key, value|
  "false"
end
# => {:a=>1, :b=>2, :c=>3, :d=>4}
```

All the key-value pairs were selected. The reason is `"false"` will always evaluates to `true` in Ruby. And the returning hash has the same size as the original one. But we should know the returning hash and the original hash are not same object though they look same.

For the sake of clarity, let's took a look at how Ruby handles the return value of the block.

### How the three types of methods care about the return value of the block

In short, the return values of block are all objects, that's it. But we have seen that different methods handle return value differently:
- the 'iteration(traverse)' ones don't care about the return values of block.
- the 'transformation' ones only care about the exact returning object of block.
- the 'selection' ones first need to turn the return object into boolean value then make its choice

The 'transformation' ones only care about the exactly returning object of blokcs. That's easy, we just need to comfirm what's the exact returning object in each step, then put them into new array.

The 'selection' ones need an additional step -- evaluate the truthiness of the returning object.

### What's the **Return value** of the block

Unless we explicitly use `return` in our program, Ruby would use *the last line*'s result as the return value. Here we only care about the return value of the block. And anything but `nil` and `false` objects will be evaluated to `false` in Ruby.

**The truthiness of **Return value** of the block**

Based on the rule we mentioned above, all the truthiness of these situations will be `false` in Ruby:

```ruby
!!(nil)

!!(false)

!!(puts "true")
```

And all the situations below will evaluated to `true` in Ruby:

```ruby
!!(true)

!!(0)

!!("")

!!([])

!!({})
```

Keep these in mind especially when you were using 'selection' ones.

### What is the **final return value** of the method calling

We talked about a lot about the return value of block, at this level return value determines how these methods behave step by step into collection's 'body'. Beside we also care the return value of the whole method calling. Actually we have talked this:

- 'iteration(traverse)' ones return the original caller object.
- 'transformation' ones return a new array.
- 'selection' ones prefer to return a new collection object that has the same type of the original collection.

### Summary

Now it's more easy to answer the question we mentioned at the beginning, the answer is:
- `map` => `[nil, nil, nil]`.
- `each` => `[1,2,3]`
- `select` => `[]`

Facing various methods about different collection objects. We just need to slow down, think about:

1. What kind of method it belongs to: iteration(traverse), transformation, selection?
2. For this kind of method, what's the way it handles the return value of the block: doesn't care, care exact object, care truthiness?
3. Go through every line into the block carefully, figure out the return value of the block.
4. What's the return value(more accurate description shoule be object) of the whole method calling?
5. Feel free to check the ruby doc out.

Just for fun, guess what's the return value of the code below:

```ruby
[1,2,3].map do |num|
  if false
    var = num
  end
  var
end
```
