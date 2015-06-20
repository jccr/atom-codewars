_ = require 'lodash'
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
    codeEditorUri = "codewars://#{id}/code"
    fixtureEditorUri = "codewars://#{id}/fixture"
    atom.workspace.open codeEditorUri
    atom.workspace.open fixtureEditorUri, split: 'right'
    @model.getChallengeInfo (err, challengeInfo) ->
      if err then throw err
      language = challengeInfo.activeLanguage
      potentialGrammars = _.map atom.grammars.getGrammars(), (grammar) ->
        score = 0
        return unless grammar.packageName
        grammarName = grammar.name.replace '#', 'sharp'
        score++ if grammar.packageName.includes language
        score++ if grammarName.toLowerCase().includes language
        score++ if grammarName.toLowerCase() is language
        score++ if grammar.scopeName.includes language
        score++ if grammar.includedGrammarScopes.length is 0
        return if score is 0
        return {score, grammar}

      selectedGrammar = (_.max potentialGrammars, 'score').grammar
      _.each atom.workspace.getTextEditors(), (editor) =>
        return unless editor.isFileless
        if editor.getURI() is codeEditorUri or editor.getURI() is fixtureEditorUri
          editor.setGrammar selectedGrammar
        if editor.getURI() is codeEditorUri
          editor.setTitle challengeInfo.challengeName
        if editor.getURI() is fixtureEditorUri
          editor.setTitle "Test Cases"

  readyChallenge: (id) ->
    codeEditorUri = "codewars://#{id}/code"
    fixtureEditorUri = "codewars://#{id}/fixture"
    _.each atom.workspace.getTextEditors(), (editor) =>
      return unless editor.isFileless

      switch editor.getURI()
        when codeEditorUri then getterFn = @model.getCode
        when fixtureEditorUri then getterFn = @model.getFixture

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
