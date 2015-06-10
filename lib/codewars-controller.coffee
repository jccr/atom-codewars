{CompositeDisposable} = require 'event-kit'
WebviewClient = require './webview/client'

module.exports =
class CodewarsController extends WebviewClient

  constructor: (@webview) ->
    super @webview.get 0
    @subscriptions = new CompositeDisposable
    @_bindEventHandlers()

  destroy: ->
    super
    @subscriptions.dispose()

  onDidLoad: (callback) ->
    @emitter.on 'did-load', callback

  onDidNavigate: (callback) ->
    @emitter.on 'did-navigate', callback

  onDidGetOutput: (callback) ->
    @emitter.on 'did-get-output', callback

  onWillOpenChallenge: (callback) ->
    @emitter.on 'will-open-challenge', callback

  onDidOpenChallenge: (callback) ->
    @emitter.on 'did-open-challenge', callback

  onDidSolveChallenge: (callback) ->
    @emitter.on 'did-solve-challenge', callback

  getCode: (callback) ->
    @execute (-> App.controller.editor?.editor.getValue()), callback

  setCode: (code, callback) ->
    @execute (-> App.controller.editor?.editor.setValue($0)), callback, code


  # == Event handlers == #

  _bindEventHandlers: ->
    @webview.one 'did-stop-loading', @_onDidLoad
    @subscriptions.add @onDidNavigate @_onDidNavigate

  _onDidLoad: =>
    @emitter.emit 'did-load'
    @_injectForeignFunctions()

  _onDidNavigate: (url) =>
    idWhenOpened = (url.match /\/kata\/(.*?)\/train\/(.*?)$/)?[1]
    idWhenSolved = (url.match /\/kata\/(.*?)\/solutions\/(.*?)$/)?[1]

    if idWhenOpened
      @emitter.emit 'will-open-challenge', idWhenOpened
      @execute $detectAfterLoad

    else if idWhenSolved
      @emitter.emit 'did-solve-challenge', idWhenSolved


  # == Foreign functions == #
  # Self executing functions that
  # run on the server (webview) end
  # and are not part of this closure
  #
  # You have access to these libraries:
  # `$` is jquery
  # `_` is lodash
  # `@emitter` is a proxy of the emitter of this class
  # but only has the `emit` method implemented

  $interceptNavigation = ->
    _replaceState = history.replaceState
    history.replaceState = ->
      url = arguments[2]
      if url then @emitter.emit 'did-navigate', url
      _replaceState.apply history, arguments

  $detectAfterLoad = ->
    didLoad = ->
      if App.controller.editor then didLoadCompletely() else
        observer = (changes) ->
          return unless _.findWhere changes, {name: 'editor'}
          didLoadCompletely()
          Object.unobserve App.controller, observer

        Object.observe App.controller, observer, ['add']

    didLoadCompletely = ->
      @emitter.emit 'did-open-challenge', App.data.id

    if App.loaded then didLoad()
    else App.afterLoad didLoad


  # == Private functions == #

  _injectForeignFunctions: ->
    @execute $interceptNavigation
