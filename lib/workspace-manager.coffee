_ = require 'lodash'
path = require 'path'
{CompositeDisposable} = require 'atom'
FilelessEditor = require './extended-classes/fileless-editor'
FilelessBuffer = require './extended-classes/fileless-buffer'
MarkdownView = require './extended-classes/markdown-view'

module.exports =
class WorkspaceManager

  @createFilelessEditor: (uriToOpen) ->
    buffer = new FilelessBuffer filePath: uriToOpen
    return new FilelessEditor buffer: buffer

  @createMarkdownView: (uri, markdownText) ->
    filelessEditor = WorkspaceManager.createFilelessEditor uri
    filelessEditor.setText markdownText
    return new MarkdownView filelessEditor

  constructor: ->

  setupWorkspace: (callback) ->
    # Activate custom workspace styling
    atom.views.getView(atom.workspace).classList.add 'codewars-active'
    
    # We don't need the tree view
    atom.packages.getActivePackage('tree-view')?.deactivate()

    # Let's close the item that's going to open
    disposable = new CompositeDisposable
    disposable.add atom.workspace.observeTextEditors (editor) ->
      setImmediate ->
        editor.destroy()
        disposable.dispose()
        setImmediate ->
          # Close the open project
          atom.project.destroy()
          callback()

    # Replace all background tips with our own
    atom.packages.activatePackage('background-tips').then (pack) ->
      view = pack.mainModule.backgroundTipsView
      proto = Object.getPrototypeOf view
      tip = view.renderTip 'Open Codewars with {codewars:toggle}'
      proto.showNextTip = ->
        @message.innerHTML = tip
        @message.classList.add('fade-in')
        setImmediate => clearInterval(@interval) if @interval?

    # We depend on the markdown preview package
    atom.packages.activatePackage('markdown-preview')

    # The autosave package might cause problems..
    atom.packages.deactivatePackage('autosave')

    @_registerOpener()


  _registerOpener: ->
    url = require 'url'
    atom.workspace.addOpener (uriToOpen) ->
      try
        {protocol, host, pathname} = url.parse(uriToOpen)
      catch error
        return

      return unless protocol is 'codewars:'
      WorkspaceManager.createFilelessEditor uriToOpen

  cleanWorkspace: (callback) ->
    _.each atom.workspace.getPanes(), (pane) ->
      pane.destroy()
