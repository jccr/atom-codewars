{$, View} = require 'space-pen'
CodewarsController = require './codewars-controller'
{CompositeDisposable} = require 'event-kit'

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
    @subscriptions = new CompositeDisposable

    onCancel = (event) =>
      @hide()
      event.stopPropagation()

    atom.commands.add 'atom-workspace', 'core:cancel': onCancel
    $(atom.views.getView(atom.workspace)).click(onCancel)

    @panel ?= atom.workspace.addModalPanel(item: @)
    @parent().addClass('codewars-panel')
    @hide()

    @webview = @find('.dashboard-frame')
    @controller = new CodewarsController(@webview)

    @_bindEventHandlers()

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

  # == Event handlers == #
  _bindEventHandlers: ->
    @subscriptions.add @controller.onDidLoad @_onDidLoad
    @subscriptions.add @controller.onDidNavigate @_onDidNavigate

  _onDidLoad: =>
    @_fadeOutWebView()
    @controller.execute(-> console.log('hello'))

  _onDidNavigate: (url) =>
    console.log('navigation', url)

  # == Private functions == #
  _fadeOutWebView: ->
    @webview.hide()
    @webview.removeClass('invisible')
    @webview.fadeIn(400, => @removeClass('logo'))
