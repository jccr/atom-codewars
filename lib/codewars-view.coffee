{$, View} = require 'space-pen'
WebViewClient = require './webview/client'

module.exports =
class CodewarsView extends View
  @content: ->
    @div class: 'codewars logo', =>
      @div class: 'message', =>
        @tag 'webview',
          class: 'dashboard-frame invisible',
          src: 'http://www.codewars.com/dashboard',
          preload: 'file://' + require.resolve('./webview/server')

  initialize: (serializedState) ->
    onCancel = (event) =>
      @hide()
      event.stopPropagation()

    atom.commands.add 'atom-workspace', 'core:cancel': onCancel
    $(atom.views.getView(atom.workspace)).click(onCancel)

    @panel ?= atom.workspace.addModalPanel(item: @)
    @parent().addClass('codewars-panel')
    @hide()
    @webview = @find('.dashboard-frame')
    @webviewClient = new WebViewClient(@webview.get(0))
    @webview.one 'did-stop-loading', =>
      @webview.hide()
      @webview.removeClass('invisible')
      @webview.fadeIn(400, => @removeClass('logo'))
      @webviewClient.execute(-> console.log('hello'))
      @_injectToWebview()

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

  # == PRIVATE FUNCTIONS ==

  _injectToWebview: ->

    interceptHistory = ->
      _pushState = window.history.pushState
      window.history.pushState = ->
        console.log(arguments)
        _pushState.apply(window.history, arguments)

    @webviewClient.execute(interceptHistory)
