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
      delegate =
        activate: =>
          @workspaceManager.cleanWorkspace()
          @activate()
        deactivate: =>
          @deactivate()
          @workspaceManager.cleanWorkspace()

      @subview = new WebviewView @path, serializedState, delegate
      @subview.hide()

      resizeHandler = _.debounce (=> @_cropSubView()), 150
      @resizeDetector.addResizeListener @item, resizeHandler

      @activate()

      @subscriptions.add atom.workspace.onDidChangeActivePaneItem (item) =>
        setImmediate =>
          itemNotVisible = @item.clientWidth is 0 and @item.clientHeight is 0
          if itemNotVisible then @detach()
          else if item is @item then @attach()

  serialize: ->

  destroy: ->
    @subscriptions.dispose()
    @subview.destroy()
    @item.remove()

  detach: ->
    return if not @attached
    @attached = false
    @subview.detach()

  attach: ->
    @_cropSubView()
    @subview.attach()
    @attached = true

  activate: ->
    pane = atom.workspace.paneForItem(@item) or atom.workspace.getActivePane()
    pane.activateItem @item
    pane.activate()
    setImmediate => @attach()

  deactivate: ->
    @detach()
    atom.workspace.paneForItem(@item).destroyItem @item

  isAttached: -> @attached

  # == Private functions == #
  _cropSubView: ->
    @subview.crop @item.getBoundingClientRect()
