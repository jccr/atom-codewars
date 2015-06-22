{TextEditor} = require 'atom'

module.exports =
class FilelessEditor extends TextEditor
  isFileless: true

  constructor: ->
    super
    @setText 'Loading...'

  saveAs: null

  getTitle: ->
    title = super
    # Drop extension
    title.replace /\..*?$/, ''
