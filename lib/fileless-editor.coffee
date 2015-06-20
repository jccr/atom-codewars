{TextEditor} = require 'atom'

module.exports =
class FilelessEditor extends TextEditor
  title: ''

  isFileless: true

  constructor: -> super

  saveAs: null

  getTitle: -> @title

  setTitle: (title) ->
    @title = title
    @emitter.emit 'did-change-title', title
