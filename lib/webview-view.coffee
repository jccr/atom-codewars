_ = require 'lodash'
{$, View} = require 'space-pen'
{CompositeDisposable} = require 'atom'
WebviewModel = require './webview-model'
WorkspaceManager = require './workspace-manager'

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

  initialize: (@path, serializedState, @delegate) ->
    @subscriptions = new CompositeDisposable

    @parent().addClass 'codewars-panel'
    @webview = @find '.dashboard-frame'

    @model = new WebviewModel @webview

    @appendTo atom.views.getView(atom.workspace)

    @_bindEventHandlers()

  serialize: ->

  destroy: ->
    @subscriptions.dispose()
    @model.destroy()
    @remove()

  detach: ->
    @attached = false
    @hide()

  attach: ->
    @attached = true
    @show()
    @focus()

  isAttached: -> @attached

  crop: (rect) ->
    @css rect

  isPlayingChallenge: false

  tearDownChallenge: (id) ->
    @isPlayingChallenge = false
    @delegate.activate()

  setupChallenge: (id) ->
    @delegate.deactivate()
    @isPlayingChallenge = true
    @model.getChallengeInfo (err, challengeInfo) =>
      if err then throw err

      @challengeURIs = @_getURIsForId id, challengeInfo
      atom.workspace.open @challengeURIs.code
      atom.workspace.open @challengeURIs.fixture, split: 'right'

      @model.getInstructions (err, text) =>
        @_instructionsPaneItem =
          WorkspaceManager.createMarkdownView @challengeURIs.instructions, text
        fixturePane = atom.workspace.paneForURI(@challengeURIs.fixture)
        fixturePane?.splitUp items: [@_instructionsPaneItem]


  readyChallenge: (id) ->
    return unless @isPlayingChallenge
    _.each atom.workspace.getTextEditors(), (editor) =>
      return unless editor.isFileless

      switch editor.getURI()
        when @challengeURIs.code then getterFn = @model.getCode
        when @challengeURIs.fixture then getterFn = @model.getFixture

      getterFn?.call @model, (err, text) ->
        if err then throw err
        editor.setText text
        editor.save()


  # == Event handlers == #
  _bindEventHandlers: ->
    @subscriptions.add @model.onDidLoad @_onDidLoad
    @subscriptions.add @model.onWillOpenChallenge @_onWillOpenChallenge
    @subscriptions.add @model.onDidOpenChallenge @_onDidOpenChallenge
    @subscriptions.add @model.onDidSolveChallenge @_onDidSolveChallenge

  _onDidLoad: =>
    @_fadeOutWebView()
    @model.execute -> console.log 'test console output'

  _onDidSolveChallenge: (id) =>
    console.log 'solved challenge', id
    @tearDownChallenge id

  _onWillOpenChallenge: (id) =>
    console.log 'opening challenge', id
    @setupChallenge id

  _onDidOpenChallenge: (id) =>
    console.log 'ready challenge', id
    @readyChallenge id

  # == Private functions == #
  _fadeOutWebView: ->
    @webview.hide()
    @webview.removeClass 'invisible'
    @webview.fadeIn 400, => @removeClass 'logo'

  _getURIsForId: (id, challengeInfo) ->
    language = challengeInfo.activeLanguage
    extension = @_findExtensionForLanguage language
    challengeName = challengeInfo.challengeName
    code: "codewars://#{id}/code/#{challengeName}.#{extension}"
    fixture: "codewars://#{id}/fixture/Test Cases.#{extension}"
    instructions: "codewars://#{id}/instructions/Instructions"

  languageExtensions =
    javascript: 'js'
    coffeescript: 'coffee'
    ruby: 'rb'
    clojure: 'clj'
    python: 'py'
    csharp: 'cs'
    haskell: 'hs'
    java: 'java'

  _findExtensionForLanguage: (language) ->
    languageExtensions[language]
