#!/usr/bin/env coffee

fs       = require 'fs'
uglify   = require 'uglify-js'
cheerio  = require 'cheerio'
cleanCss = require 'clean-css'


args = process.argv
initialDir = process.cwd()
$ = fileName = null
len = completed = 0


init = ->
  if args.length <= 2
    console.log '\x1b[31m' + 'please pass an html file' + '\x1b[0m'
    process.exit 1

  filePath = args[2]
  splitPath = filePath.split '/'
  fileName = splitPath.pop()
  dir = splitPath.join '/'

  process.chdir dir if dir

  fs.readFile fileName, (err, data) ->
    if err
      console.log '\x1b[31m' + 'cannot read `' + filePath + '`\x1b[0m'
      process.exit 1

    $ = cheerio.load data
    targets = $ '.monocat'
    len = targets.length
    if len is 0
      console.log '\x1b[31m' + 'found no elements with `monocat` class... exiting.' + '\x1b[0m'
      process.exit 1

    console.log '\x1b[33m' + 'gathering assets...' + '\x1b[0m'

    targets.each (i, el) ->
      $el = $ el
      tagType = el.name

      if tagType is 'script' and $el.attr 'src'
        type = $el.attr 'type'
        typeString = if type then " type=\"#{ type }\"" else ''
        $el.after("<script#{ typeString }>#{ uglify.minify($el.attr 'src').code }</script>").remove()
        deliver ++completed

      else if tagType is 'link' and $el.attr('rel') is 'stylesheet'
        path = $el.attr 'href'
        fs.readFile path, (err, data) ->
          if err
            console.log '\x1b[31m' + 'cannot read `' + path + '`\x1b[0m'
            process.exit 1

          $el.after("<style>#{ cleanCss.process data.toString() }</style>").remove()
          deliver ++completed


deliver = ->
  return unless completed is len
  process.chdir initialDir

  if args[3]
    outputFile = args[3]
  else
    split = fileName.split '.'
    ext = split.pop()
    outputFile = split.join '.'
    outputFile += '_monocat.' + ext

  fs.writeFile outputFile, $.html(), (err) ->
    if err
      console.log '\x1b[31m' + 'cannot write to `' + outputFile + '`\x1b[0m'
      process.exit 1

    console.log '\x1b[32m' + 'output to `' + outputFile + '`\x1b[0m'


init()
