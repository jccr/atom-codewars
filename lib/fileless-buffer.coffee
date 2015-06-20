{TextBuffer} = require 'atom'

module.exports =
class FilelessBuffer extends TextBuffer
  filePath: null

  constructor: (params) ->
    # Dummy file object, to not have real file IO
    @file =
      read: ->
      readSync: ->
      write: ->
      writeSync: ->
      existsSync: -> true
      setEncoding: ->
      getEncoding: -> 'utf8'
      getDigestSync: ->
      getBaseName: -> ''
      onDidChange: ->
      onDidDelete: ->
      onDidRename: ->
      onWillThrowWatchError: ->

    super params
    @loaded = true

  setPath: (path) -> @filePath = path

  getPath: -> @filePath
