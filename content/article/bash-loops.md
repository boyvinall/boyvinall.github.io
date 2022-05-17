---
title: "Bash Loops"
date: 2022-05-19
draft: false
summary: A brief summary of some different ways to loop over things in bash.
series: "Bash howto"
tags:
- bash
- shell
---

Speaking to some colleagues [recently](/page/about), I realised it could be useful to have a few little howto pages on doing
things in bash.  Yes, there are probably a bunch of pages out there already, but sometimes finding things is
harder than just writing them.  So here's part one (of _some_) about doing things in bash. This part is
focused on some simple looping constructs.

## for

Your typical `for` loop looks like this:

```bash
for f in foo bar baz; do
    echo $f
done
```

Running that on a single line and pairing it with the output of some other command:

```bash
for f in $(ls -1); do echo $f; done
```

This then gets more interesting when the nested command is more complicated than a simple `ls -1`,
but that's for another day.

## xargs

For a very simple command, a `for` loop might be overkill.  Here's another way of doing the same thing
as above, but slightly easier for simple commands.   By default, `xargs` reads from stdin and appends
to the end of the command:

```bash
echo foo bar baz | xargs -n1 echo
```

{{< terminal "/Users/mattv" >}}
$ echo foo bar baz | xargs -n1 echo HELLO
HELLO foo
HELLO bar
HELLO bar
{{< /terminal >}}

Some useful arguments to xargs:

- `-n number` : Set the maximum number of arguments taken from standard input for each
  invocation of <u>utility</u>.
- `-L number` : Call <u>utility</u> for every number non-empty lines read.
- `-I replstr` : Replace <u>replstr</u> in the command with arguments from stdin.
- `-t` : Echo the command to be executed to stderr immediately before executing it, useful
  for debug/tracing.

A few examples using sample input:

{{< terminal "/Users/mattv" >}}
$ cat foo.txt
foo bar baz
qux abc def
{{< /terminal >}}

Limiting the `xargs` iteration by number of whitespace-delimited tokens:

{{< terminal "/Users/mattv" >}}
$ cat foo.txt | xargs -n1 echo HELLO
HELLO foo
HELLO bar
HELLO baz
HELLO qux
HELLO abc
HELLO def
$ cat foo.txt | xargs -n2 echo HELLO
HELLO foo bar
HELLO baz qux
HELLO abc def
{{< /terminal >}}

Limiting by complete lines of input:

{{< terminal "/Users/mattv" >}}
$ cat foo.txt | xargs -L1 echo HELLO
HELLO foo bar baz
HELLO qux abc def
$ cat foo.txt | xargs -L2 echo HELLO
HELLO foo bar baz qux abc def
{{< /terminal >}}

Use token replacement and print the command before you execute it, here each input token
is dropped into the `%` character in the output string `AA % BB`:

{{< terminal "/Users/mattv" >}}
$ cat foo.txt | xargs -n1 echo | xargs -I% -t echo AA % BB
echo AA foo BB
AA foo BB
echo AA bar BB
AA bar BB
echo AA baz BB
AA baz BB
echo AA qux BB
AA qux BB
echo AA abc BB
AA abc BB
echo AA def BB
AA def BB
{{< /terminal >}}

## while

Sometimes you need to run commands using multiple fields from each line of output.
Here you can assign variables using `read` - so, given this input:

{{< terminal "/Users/mattv" >}}
$ ls -al
total 24
drwxr-xr-x  16 mattv  staff   512 19 May 18:40 .
drwxr-xr-x  13 mattv  staff   416 19 May 19:22 ..
drwxr-xr-x  15 mattv  staff   480 20 May 08:44 .git
drwxr-xr-x   3 mattv  staff    96 19 May 19:37 .github
-rw-r--r--   1 mattv  staff    28 19 May 19:37 .gitignore
-rw-r--r--   1 mattv  staff   340 19 May 19:55 .gitmodules
-rw-r--r--   1 mattv  staff     0 19 May 19:25 .hugo_build.lock
drwxr-xr-x   3 mattv  staff    96 19 May 19:37 archetypes
-rw-r--r--   1 mattv  staff  1719 19 May 20:49 config.yml
drwxr-xr-x   5 mattv  staff   160 19 May 18:44 content
drwxr-xr-x   2 mattv  staff    64 19 May 19:22 data
drwxr-xr-x   3 mattv  staff    96 19 May 19:29 layout
drwxr-xr-x  17 mattv  staff   544 19 May 19:30 public
drwxr-xr-x   3 mattv  staff    96 19 May 19:25 resources
drwxr-xr-x   3 mattv  staff    96 19 May 19:25 static
drwxr-xr-x   4 mattv  staff   128 19 May 19:16 themes
{{< /terminal >}}

we can easily pick out some pieces of the listing .. notice that
`mode`, `links`, `user`, `group`, `size`, `D`, `M`, `T`, `name` are variables parsed out from
the input and usable inside the body of the loop:

```bash
ls -al | while read mode links user group size D M T name; do
  echo $user $size $name
done | column -t
```

{{< terminal "/Users/mattv" >}}
$ ls -al | while read mode links user group size D M T name; do
> echo $user $size $name
> done | column -t
mattv  512   .
mattv  416   ..
mattv  480   .git
mattv  96    .github
mattv  28    .gitignore
mattv  340   .gitmodules
mattv  0     .hugo_build.lock
mattv  96    archetypes
mattv  1719  config.yml
mattv  160   content
mattv  64    data
mattv  96    layout
mattv  544   public
mattv  96    resources
mattv  96    static
mattv  128   themes
{{< /terminal >}}

If you have more input fields than your `read` refers to, then the last variable will
contain all the remaining fields .. so `$stuff` here has the date, month, time and name:

{{< terminal "/Users/mattv" >}}
$ ls -al | while read mode links user group size stuff; do
> echo "[$user] [$stuff]"
> done
[] []
[mattv] [19 May 18:40 .]
[mattv] [19 May 19:22 ..]
[mattv] [20 May 08:44 .git]
[mattv] [19 May 19:37 .github]
[mattv] [19 May 19:37 .gitignore]
[mattv] [19 May 19:55 .gitmodules]
[mattv] [19 May 19:25 .hugo_build.lock]
[mattv] [19 May 19:37 archetypes]
[mattv] [19 May 20:49 config.yml]
[mattv] [19 May 18:44 content]
[mattv] [19 May 19:22 data]
[mattv] [19 May 19:29 layout]
[mattv] [19 May 19:30 public]
[mattv] [19 May 19:25 resources]
[mattv] [19 May 19:25 static]
[mattv] [19 May 19:16 themes]
{{< /terminal >}}

For more details here see the [read man page](https://linuxcommand.org/lc3_man_pages/readh.html)

That's it for now.  Next time, we'll look at extracting text from lines of input.
