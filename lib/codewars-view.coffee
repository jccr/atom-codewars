{$, View} = require 'space-pen'

module.exports =
class CodewarsView extends View
  @content: ->
    @div class: 'codewars', =>
      @div class: 'message', =>
        @tag 'webview',
          class: 'dashboard-frame',
          src: 'http://www.codewars.com/dashboard',
          preload: require.resolve('./codewars-webview')

  initialize: (serializedState) ->
    onCancel = (event) =>
      @hide()
      event.stopPropagation()

    atom.commands.add 'atom-workspace', 'core:cancel': onCancel
    $(atom.views.getView(atom.workspace)).click(onCancel)

    @panel ?= atom.workspace.addModalPanel(item: @)
    @parent().addClass('codewars-panel')
    @hide()

  # Returns an object that can be retrieved when package is activated
  serialize: ->


  # Tear down any state and detach
  destroy: ->
    @panel.destroy()
    @remove()

  show: ->
    @focus()
    @panel.show()

  hide: ->
    @panel.hide()

  isVisible: ->
    @panel.isVisible()
