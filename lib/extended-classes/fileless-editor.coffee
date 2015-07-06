{TextEditor} = require 'atom'

module.exports =
class FilelessEditor extends TextEditor
  isFileless: true

  constructor: (params) ->
    super params
    @setText 'Loading...' unless params.registerEditor

  saveAs: null

  getTitle: ->
    title = super
    # Drop extension
    title.replace /\..*?$/, ''

  copy: ->
    displayBuffer = @displayBuffer.copy()
    softTabs = @getSoftTabs()
    newEditor = new FilelessEditor({
      @buffer,
      displayBuffer,
      @tabLength,
      softTabs,
      suppressCursorCreation: true,
      registerEditor: true
    })
    
    for marker in @findMarkers(editorId: @id)
      marker.copy editorId: newEditor.id, preserveFolds: true
    newEditor
