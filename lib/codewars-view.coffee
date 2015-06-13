
{$, View} = require 'space-pen'
{CompositeDisposable} = require 'event-kit'
CodewarsController = require './codewars-controller'

module.exports =
class CodewarsView extends View
  @content: ->
    @div class: 'codewars logo', =>
      @div class: 'message', =>
        @tag 'webview',
          class: 'dashboard-frame invisible',
          src: 'http://www.codewars.com/dashboard',
          preload: 'file://' + require.resolve './webview/server'

  initialize: (@path, serializedState) ->
    @subscriptions = new CompositeDisposable

    onCancel = (event) =>
      @hide()
      event.stopPropagation()

    atom.commands.add 'atom-workspace', 'core:cancel': onCancel
    $(atom.views.getView atom.workspace).click onCancel

    @panel ?= atom.workspace.addModalPanel item: @
    @parent().addClass 'codewars-panel'
    @hide()

    @webview = @find '.dashboard-frame'
    @controller = new CodewarsController @webview

    @_bindEventHandlers()

    @_setupWorkspace()

  # Returns an object that can be retrieved when package is activated
  serialize: ->


  # Tear down any state and detach
  destroy: ->
    @subscriptions.dispose()
    @controller.destroy()
    @panel.destroy()
    @remove()

  show: ->
    @focus()
    @panel.show()

  hide: ->
    @panel.hide()

  isVisible: ->
    @panel.isVisible()

  isPlayingChallenge: false

  tearDownChallenge: (id) ->
    @isPlayingChallenge = false

  setupChallenge: (id) ->
    @isPlayingChallenge = true


  # == Event handlers == #
  _bindEventHandlers: ->
    @subscriptions.add @controller.onDidLoad @_onDidLoad
    @subscriptions.add @controller.onWillOpenChallenge @_onWillOpenChallenge
    @subscriptions.add @controller.onDidSolveChallenge @_onDidSolveChallenge

  _onDidLoad: =>
    @_fadeOutWebView()
    @controller.execute -> console.log 'test console output'

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

  _setupWorkspace: ->
    # We don't need the tree view
    atom.packages.getActivePackage('tree-view').deactivate()
