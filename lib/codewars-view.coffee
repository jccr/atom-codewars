{$, View} = require 'space-pen'
WebviewClient = require './webview/client'

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
    @client = new WebviewClient(@webview.get(0))

    # Bind events
    @webview.one 'did-stop-loading', @_onReady
    @client.on 'interceptNavigation', @_onNavigation

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

  # == Event handlers == #
  _onReady: =>
    @_fadeOutWebView()
    @_injectToWebview()
    @client.execute(-> console.log('hello'))

  _onNavigation: (url) =>
    console.log('navigation', url)

  # == Private functions == #
  _fadeOutWebView: ->
    @webview.hide()
    @webview.removeClass('invisible')
    @webview.fadeIn(400, => @removeClass('logo'))

  _injectToWebview: ->
    interceptNavigation = ->
      _replaceState = history.replaceState
      history.replaceState = ->
        $wh.emit('interceptNavigation', arguments[2])
        _replaceState.apply(history, arguments)

    @client.execute(interceptNavigation)
