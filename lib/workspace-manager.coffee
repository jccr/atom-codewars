{CompositeDisposable} = require 'atom'

module.exports =
class WorkspaceManager

  constructor: ->

  setupWorkspace: ->
    # We don't need the tree view
    atom.packages.getActivePackage('tree-view')?.deactivate()

    # Let's close the item that's going to open
    disposable = new CompositeDisposable
    disposable.add atom.workspace.observeTextEditors (editor) =>
      setImmediate ->
        editor.destroy()
        disposable.dispose()

    # Replace all background tips with our own
    atom.packages.activatePackage('background-tips').then (pack) =>
      view = pack.mainModule.backgroundTipsView
      proto = Object.getPrototypeOf view
      tip = view.renderTip 'Toggle Codewars with {codewars:toggle}'
      proto.showNextTip = ->
        @message.innerHTML = tip
        @message.classList.add('fade-in')
        setImmediate => clearInterval(@interval) if @interval?
