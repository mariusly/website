title: Sweet new website!
date: 2025-09-01 13:46
tags: scheme, lisp
---

I thought it was about time I actually made something useful. So here it is. A
website.. with posts! In all seriousness, it was quite interesting. Although
this post is just here to have something here.

Static site generators have grown rather complicated. Far more complicated than
I would ever need. Additionally, I would rather not have to relearn the damn
thing every time I want to change the site. So I went looking for simple.
Preferably written in a lisp-like language or a lisp dialect, because I thought
that would be fun. After a little bit of searching, the choice was between
[Haunt](https://dthompson.us/projects/haunt.html), written in [Guile
Scheme](https://www.gnu.org/software/guile/), and
[Bagatto](https://bagatto.co/), written in [Janet](https://janet-lang.org/).

I ended up with Haunt, simply because it was in nixpkgs which in turn made my
life easier. You can check out the source of the website
[here](https://git.marius.pm/website/). ¯\_(ツ)_/¯ Documentation was so-so, but
by taking advantage of the awesome people who made stuff with Haunt over at
[Awesome Haunt](https://awesome.haunt.page/), I managed to get up and running.
It really is quite a powerful ssg.

That said, Janet might be worth checking out at some point.
