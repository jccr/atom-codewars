{$, View} = require 'space-pen'
{CompositeDisposable} = require 'atom'
WebviewModel = require './webview-model'

module.exports =
class WebviewView extends View
  attached: false

  @content: ->
    @div class: 'codewars logo', =>
      @div class: 'message', =>
        @tag 'webview',
          class: 'dashboard-frame invisible',
          src: 'http://www.codewars.com/dashboard',
          preload: 'file://' + require.resolve './webview-ipc/server'

  initialize: (@path, serializedState) ->
    console.log 'initialize'
    @subscriptions = new CompositeDisposable

    @parent().addClass 'codewars-panel'
    @webview = @find '.dashboard-frame'

    @model = new WebviewModel @webview

    @appendTo atom.views.getView(atom.workspace)

    @_bindEventHandlers()

  serialize: ->
    console.log 'wvv serialize'

  destroy: ->
    console.log 'wvv destroying'
    @subscriptions.dispose()
    @model.destroy()
    @remove()

  detach: ->
    console.log 'wvv detach'
    @attached = false
    @hide()

  activate: ->
    console.log 'wvv activate'
    @attached = true
    @show()
    @focus()

  isAttached: -> @attached

  crop: (rect) ->
    @css rect

  isPlayingChallenge: false

  tearDownChallenge: (id) ->
    @isPlayingChallenge = false

  setupChallenge: (id) ->
    @isPlayingChallenge = true


  # == Event handlers == #
  _bindEventHandlers: ->
    @subscriptions.add @model.onDidLoad @_onDidLoad
    @subscriptions.add @model.onWillOpenChallenge @_onWillOpenChallenge
    @subscriptions.add @model.onDidSolveChallenge @_onDidSolveChallenge

  _onDidLoad: =>
    @_fadeOutWebView()
    @model.execute -> console.log 'test console output'

  _onDidSolveChallenge: (id) =>
    console.log 'solved challenge', id
    @tearDownChallenge id
    @show()

  _onWillOpenChallenge: (id) =>
    console.log 'opening challenge', id
    @hide()
    @setupChallenge id


  # == Private functions == #
  _fadeOutWebView: ->
    @webview.hide()
    @webview.removeClass 'invisible'
    @webview.fadeIn 400, => @removeClass 'logo'
