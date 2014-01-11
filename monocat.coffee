#!/usr/bin/env coffee

fs       = require 'fs'
uglify   = require 'uglify-js'
cheerio  = require 'cheerio'
cleanCss = require 'clean-css'


args = process.argv
initialDir = process.cwd()
$ = fileName = null
len = completed = 0
log        = console.log.bind   console, '\x1b[32m  '
logErr     = console.error.bind console, '\x1b[31m  '


init = ->
  if args.length <= 2
    logErr 'please pass an html file'
    process.exit 1

  filePath = args[2]
  splitPath = filePath.split '/'
  fileName = splitPath.pop()
  dir = splitPath.join '/'

  process.chdir dir if dir

  fs.readFile fileName, (err, data) ->
    if err
      logErr "cannot read `#{ filePath }`"
      process.exit 1

    $ = cheerio.load data
    targets = $ '.monocat'
    len = targets.length
    if len is 0
      logErr 'found no elements with `monocat` class... exiting.'
      process.exit 1

    log 'gathering assets...'

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
            logErr "cannot read `#{ path }`"
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
      logErr "cannot write to `#{ outputFile }`"
      process.exit 1

    log "output to `#{ outputFile }`"


init()
