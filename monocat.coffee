fs       = require 'fs'
path     = require 'path'
uglify   = require 'uglify-js'
CleanCss = require 'clean-css'
cheerio  = require 'cheerio'
args     = process.argv
log      = console.log.bind   console, '\x1b[32m  '
logErr   = console.error.bind console, '\x1b[31m  '
fileName = $ = null


init = ->
  if args.length <= 2
    logErr 'please pass an html file'
    process.exit 1

  filePath = args[2]
  fileName = path.basename filePath
  dirName  = path.dirname filePath
  outDir   = path.dirname args[3]

  fs.readFile filePath, (err, data) ->
    if err
      logErr "cannot read `#{ filePath }`"
      process.exit 1

    $         = cheerio.load data
    targets   = $ '.monocat'
    total     = targets.length
    completed = 0

    if total is 0
      logErr 'found no elements with `monocat` class... exiting.'
      process.exit 1

    log 'gathering assets...'

    targets.each (i, el) ->
      $el     = $ el
      tagType = el.name

      if tagType is 'script' and $el.attr 'src'
        type       = $el.attr 'type'
        typeString = if type then " type=\"#{ type }\"" else ''
        srcPath    = path.join dirName, $el.attr 'src'

        $el.after("<script#{ typeString }>#{ uglify.minify(srcPath).code }</script>")
          .remove()
        deliver() if ++completed is total

      else if tagType is 'link' and $el.attr('rel') is 'stylesheet'
        srcPath = path.join dirName, $el.attr 'href'

        fs.readFile srcPath, (err, data) ->
          if err
            logErr "cannot read `#{ srcPath }`"
            process.exit 1

          min   = new CleanCss().minify data.toString()
          urlRx = /url\((.*?)\)/ig
          while url = urlRx.exec min
            continue if /^['"]?data/i.test url[1]
            rel = path.relative outDir, path.join path.dirname(srcPath), url[1]
            min = min.replace url[1], rel

          $el.after("<style>#{ min }</style>").remove()
          deliver() if ++completed is total

      else
        deliver() if ++completed is total


deliver = ->
  if args[3]
    outputPath = args[3]
  else
    split      = fileName.split '.'
    ext        = split.pop()
    outputPath = split.join('.') + '_monocat.' + ext

  fs.writeFile outputPath, $.html(), (err) ->
    if err
      logErr "cannot write to `#{ outputPath }`"
      process.exit 1

    log "output to `#{ outputPath }`"


init()
