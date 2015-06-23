path = require 'path'
markdownViewModuleDir = path.dirname(require.resolve 'markdown-preview')
markdownViewPath = path.join markdownViewModuleDir, 'markdown-preview-view'
MarkdownPreviewView = require markdownViewPath

module.exports =
class MarkdownView extends MarkdownPreviewView

  constructor: (@editor) ->
    super editorId: true

  editorForId: -> @editor

  copy: -> new MarkdownView @editor

  getTitle: ->
    title = super
    # Drop preview suffix
    return title.replace ' Preview', ''
