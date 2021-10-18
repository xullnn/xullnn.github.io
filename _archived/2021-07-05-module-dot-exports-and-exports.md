---
title:  "The difference between module.exports and exports in Node.js"
categories:
  - Work
tags:
  - programming
layout: post
---

*This post discusses the difference between `module.exports` and `exports` in the context of `Node.js`.*


Exporting and importing modules are common operations in a Node app.

```js
// toBeExported.js
function f() {  };
module.exports.f = f;
  // or exports.f = f;

// toImport.js
const { f } = require("./toBeExported");
  // or const f = require("./toBeExported").f;
```


And I was once confused by the different exporting syntax of `module.exports` and `exports`.
A lot of articles on the internet and the [node doc](https://nodejs.org/api/modules.html#modules_exports_shortcut) explains this topic in various level. Practically , there's a simpler way to understand the difference.

## An object and a variable that references it

Let's do some warmup.

If we have an nested object `nested_object`:

```js
const nested_object = {
  a: 'hello world',
  x: {
    f: () => { console.log('I am a func')},
    p: 'nested'
  }
};

let x = nested_object.x; // references the nested object

x.another_f = () => { console.log('I am also a func') };

nested_object.x;
```

Is `another_f` injected in the nested object `nested_object.x;`?

Yes of course. Because the local variable `x` is referencing the nested object which is also a property of `nested_object`. So the property `x` and variable `x` are pointing to the same object, changes made by either side will be reflected on the commonly referencing object.

What if we reassign the local variable `x`:

```js
// ... omit code

x = {
  newF: () => {console.log('I am new func')}
};
```
How would this affect the `nested_object.x`? No effect, this simply lets the local `x` lose its original reference to the nested object.

## The scope of `exports` is local to the current file

You might have guessed that the `nested_object` implied `module` and `x` implied `exports`. The relationship of `module.exports` and `exports` is pretty much just like that.

The [node doc](https://nodejs.org/api/modules.html#modules_exports_shortcut) writes:

> The `exports` variable is available within a module's file-level scope, and is assigned the value of module.exports before the module is evaluated.

> It allows a shortcut, so that module.exports.f = ... can be written more succinctly as exports.f = .... However, be aware that like any variable, if a new value is assigned to exports, it is no longer bound to module.exports

So `exports` is just a shortcut in the current file to reference the `module.exports` object. The actual object that will be exported is the `module.exports`, so a reassignment to the `exports` variable does nothing more than losing its use.

Following this logic, a reassignment to `module.exports` will also disable the `exports` because "(`exports`) is assigned the value of `module.exports` before the module(file) is evaluated". This means the referential relation is built right after the `module` instance object is instantiated and before all the functions and properties are written in it. It may look like:

```js
class Module {
  constructor() {
    exports: {}
  }
};

const module = new Module();

let exports = module.exports;

// Then write functions and properties exported into module.exports
```

And this entails a bonus point. What's the `module` under the context of a module file?

## `module` is an instance object

Often in a project, there are multiple modules to be exported, we may do `module.exports = objectA;` in one file, and `module.exports  = objectB` in another file. Are we dealing with the same `module` here?

If the answer was 'yes' then all the exporting operations were just messing things up. We can do a simple investigation within a module file.

We can try `console.log(module)` or simply evaluate `module` in `Node` console, it logs:

```js
Module {
  id: '<repl>',
  path: '.',
  exports: {},
  parent: undefined,
  filename: null,
  loaded: false,
  children: [],
  paths: [
    '/Users/xullnn/blog/repl/node_modules',
    '/Users/xullnn/blog/node_modules',
    '/Users/xullnn/node_modules',
    '/Users/node_modules',
    '/node_modules',
    '/Users/xullnn/.node_modules',
    '/Users/xullnn/.node_libraries',
    '/usr/local/Cellar/node/14.11.0/lib/node'
  ]
}
```

First on the top there's the `Module`. This indicates `module` in the current file is an instance of a class called `Module`. We can check this in `Node`:

```js
module.constructor.name

// => 'Module'
```

So for each module file, new `Module` instance will be created instead of using a global `module` object that can be rewritten everywhere in the project.

When we import a module by using `const objectA = require(./path/to/module_file)`, this line only imports the `module.exports` object specific to the file being exported.

Second notice the `exports` property, that's just the manifestation of the 'nested object' we just talked about.

Third is the `paths` array, which is the [search paths](https://nodejs.org/api/modules.html#modules_module_paths) for the `module`.

## Summary

Normally we tend not to use different syntaxes for the same feature in our code for example we may not use both `module.exports` and `exports` in a single file. I think if `exports` confused people so much, then this so called "shortcut" has little value. But the difference is easy to understand once we find the proper perspective.



