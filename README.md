# Monocat

#### Automated asset inlining

Monocat is ideal for deploying small, static, single-page sites where you want to minimize the number of http requests. Monocat compresses and writes the contents of external assets into the html source for an easy speed optimization.


### Installation:

You'll need [Node.js](http://nodejs.org) installed. Then:

```
$ npm install -g monocat
```


### Usage:

Monocat works sort of like a jQuery plugin, but from the commandline.

Just add the class `monocat` to any `<script>` or `<link>` (stylesheets only) tag you want to inline:

```html
<link rel="stylesheet" href="css/main.css" class="monocat">
<script src="js/huge-lib.js"></script>
<script src="js/main.js" class="monocat"></script>
```

Notice that the second tag will be ignored since it lacks the `monocat` class.

To create an optimized version of your html file, run this:

```
$ monocat index.html
```

By default, this will create a ready-to-deploy file called `index_monocat.html` in the same directory.

Pass an optional output filename as the second argument:

```
$ monocat src/index.html build/index.html
```

### Example:
[ChainCal](http://chaincalapp.com) (view source)

