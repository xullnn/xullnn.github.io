---
title:  "Lazy regular expression to match SQL statements"
categories:
  - Work
tags:
  - regex
  - programming
layout: post
recent: true
---

In my recent work I had to extract regex statements from a `.sql` file, and get an array of strings. And I need a refresh on regular expression. A simplified example file may look like this `schema.sql`:

```SQL
CREATE TABLE users (
  id serial PRIMARY KEY,
  nickname varchar(100) CHECK(length(nickname) > 2) UNIQUE NOT NULL
);

-- This table holds food items such as egg, pork, fried potato, multiple food items
CREATE TABLE food_items (
  id serial PRIMARY KEY,
  name text NOT NULL UNIQUE CHECK (length(name) > 2),
  amount integer NOT NULL CHECK (amount > 0)
);

-- more statements omitted
```

## Match things from `CREATE` to semicolon `;`

If there's only one SQL statement, things would be easy: `/CREATE(.|\n)+;/` or `/CREATE[\s\S]+;/` can work. But now there're more than one(assuming we don't user `;` in comments). So very likely we need the `g` flag to perform a global match on every single statement.

And the two regexes mentioned above won't stop till the last `;` in the string. Then the two statements are merged into one, with the comments mixed in.

## As many as vs. As soon as

**Greedy**

With the `+` quantifier, the default match style of regex is the 'greedy' mode. The regex will try to consume as many characters as it can to find the final match. For example `/CREATE(.|\n)+;/` will match things from the first `CREATE` then traverse any chars including `;`, note that `(.|\n)` doesn't exclude `;`, till it hits *the end of the string.*. Because if you don't go through all the chars, you won't know if you miss any `;` in the middle. After hitting the end of the string the regex will backtrace the string to find the last `;` in the string. Then the matching complete, it has matched as many chars as it can by the giving rule. That's "greedy".

We can try in `Node.js` with the `fs` module:

```js
const fs = require('fs');

fs.readFile('./db/schema.sql', 'utf8', (err, data) => {
  console.log(data.match(/CREATE(.|\n)+;/g));
  // we can also use [\s\S]+ instead of (.|\n)+
});
```

**Lazy**

The opposite of greedy is lazy. And to make the previously greedy regex lazy, we need another quantifier `?`. The `?` means 'zero or more' if it is used alone, for example `/a?/` means zero or more `'a'`. And the match result of `'cba'.match(/a?/)` would be an mepty string `''` because 'zero or more' means zero(no match) is ok too.

But when combining with `+` quantifier, the meaning changes. In our SQL case, adding `?` right after `+` will convert the match mode to be 'lazy' -- `/CREATE(.|\n)+?;/g`. This simple change let the regex stop on first `;` it meets, then it counts a match. With the user of the global match flag `g`, the next matching starts after the first `;`. We can say that the regex is satisfied as soon as it hit the first `;` because it's 'lazy'.

## Neither greedy nor lazy

It's a bit tricky to figure things out when thinking about 'greedy' and 'lazy'. However, we have alternatives. I mentioned that `(.|\n)` or `[\s\S]+` doesn't exclude `;`, so in greedy mode the regex keeps going when it meets `;` before it hits the end of the string.

By simply exclude `;` in the middle, we get rid of the consideration of greedy or lazy mode. How about `/CREATE[^;]+;/g`. Though technically we are in greedy mode but we may not have noticed it if I don't mention this. Here `[^;]+` means "one or more non-semicolon chars", in other words, this matches all chars except for `;`. This 'shrinks' the searching logic to the nearest semicolon. And it works just like a lazy one in the mode of greedy.

## Summary

Playing with regex can be both frustrating and interesting. But you'll find the simple logic of `true` or `false`, `include` or `exclude` can generate so many different solutions to the same task. It's fun!


