_ = require 'lodash'
{CompositeDisposable} = require 'atom'
DetectElementResize = require './third-party/detect-element-resize'
WorkspaceManager = require './workspace-manager'
WebviewView = require './webview-view'

module.exports =
class MainView
  attached: false
  pane: null

  constructor: (@path, serializedState) ->
    console.log 'mv constructor'
    @subscriptions = new CompositeDisposable
    @workspaceManager = new WorkspaceManager
    @resizeDetector = new DetectElementResize

    @item = document.createElement('div')
    @item.style.position = 'absolute'
    @item.style.width = '100%'
    @item.style.height = '100%'
    @item.getTitle = -> 'Codewars'
    @item.getURI = -> 'codewars-uri'
    @item.destroy = => @detach()
    @item.dispose = => @detach()
    @item.activate = => @activate()

    @workspaceManager.setupWorkspace =>
      @subview = new WebviewView @path, serializedState
      @subview.hide()

      resizeHandler = _.debounce (=> @_cropSubView()), 150
      @resizeDetector.addResizeListener @item, resizeHandler
      @pane = atom.workspace.getActivePane()

      @subscriptions.add @pane.on

      @activate()

  serialize: ->
    console.log 'mv serialize'

  destroy: ->
    console.log 'mv destroying'
    @subscriptions.dispose()
    @subview.destroy()
    @item.remove()

  detach: ->
    console.log 'mv detach'
    @attached = false
    @subview.detach()

  activate: ->
    console.log 'mv activate'
    @attached = true
    @pane.activateItem @item
    setImmediate =>
      @_cropSubView()
      @subview.activate()

  isAttached: -> @attached

  # == Private functions == #
  _cropSubView: ->
    @subview.crop @item.getBoundingClientRect()
