---
title:  "A workaround for syntax highlighter not working after deploying to github"
categories:
  - Work
layout: post
recent: true
---

A problem bothered me for a few days when I redesigned my blog with jekyll.

## 1 Problem

I used coderay as syntax highlighter for the site as [jekyll doc describes](https://jekyllrb.com/docs/configuration/markdown/#syntax-highlighting-coderay).

When I view the site on local machine, all code syntaxes are highlighted appropriately, but after pushing to github, there's only basic styles for code blocks, without any colors.


## 2 Trace

After checking HTML both locally and remotely, I found coderay is wrapping code blocks and neither keywords are not wrapped by style code. **So the browser is using different HTML.**

And if check the HTML of highlighted code, you'll find styles are added via inline styles. This is done via the specified highlighter, in this case coderay, when jekyll generates files including HTML files.

Based on [description of file structures](https://jekyllrb.com/docs/structure/), when a jekyll site is being served locally, it actually renders the `_site` directory, and all html files can be found there.

> This is where the generated site will be placed (by default) once Jekyll is done transforming it. It’s probably a good idea to add this to your .gitignore file.

But by default, `_site` is added to `.gitignore` so it won't be pushed to github. So from where github pages render the site remotely?

Github gives a choice, in the site repo's `setting -> pages` panel, [there's an option that let you choose from which directory or branch you want to the site to be rendered](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site). But it only gives 2 options, from a branch or `/docs` folder.

If you choose the a branch, the `main` branch normally, github pages and jekyll will generated all the files on the fly, and of course all the HTML files. But what generated from there may be not the same as what we get locally.

In this case, coderay's not applied to code blocks.

## 3 Experiments

So the cause was coderay somehow hadn't participated in the process of build the site on github pages. No HTML structures and inline styles were added to the files.

A lot of similar questions can be found on the internet and I also tried some. Such as reinstall all gems, checking the referential relationships of style files, tinkering the `.config.yml` file. But none of them worked.

I suspected that all installed gems(dependencies) can work together to generated site files locally. But there's not such a step and environment on github pages to install them, so the gems won't be incorporated into the process of building site remotely, after all it's not a remote server.

## 4 Solution

If we can get correct HTML, we get the correct results. So we just need specify github pages to render the directory with correct files in it, and 'correct' means the same as the local directory.

**Two step:**

1. let jekyll generated site to `/docs` directory
2. change site repo's `setting -> pages -> source` to `/docs`

Thus it hard coded all the files and not let github pages generated them on the fly.

But one thing needs to be remembered: run `jekyll build` each time before pushing to github.

And it works.


