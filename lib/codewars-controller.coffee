WebviewClient = require './webview/client'

module.exports =
class CodewarsController extends WebviewClient

  constructor: (@webview) ->
    super @webview.get(0)
    @webview.one 'did-stop-loading', @_onDidLoad

  onDidLoad: (callback) ->
    @emitter.on 'did-load', callback

  onDidNavigate: (callback) ->
    @emitter.on 'did-navigate', callback

  # == Event handlers == #
  _onDidLoad: =>
    @emitter.emit 'did-load'
    @_injectToWebview()

  # == Private functions == #
  _injectToWebview: ->

    interceptNavigation = ->
      _replaceState = history.replaceState
      history.replaceState = ->
        @emitter.emit 'did-navigate', arguments[2]
        _replaceState.apply(history, arguments)

    @execute(interceptNavigation)
