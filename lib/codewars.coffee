CodewarsView = require './codewars-view'
{CompositeDisposable} = require 'atom'

module.exports = Codewars =
  codewarsView: null
  subscriptions: null

  activate: (state) ->
    @codewarsView = new CodewarsView(state.codewarsViewState)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'codewars:toggle': => @toggle()

  deactivate: ->
    @subscriptions.dispose()
    @codewarsView.destroy()

  serialize: ->
    codewarsViewState: @codewarsView.serialize()

  toggle: ->
    console.log 'Codewars was toggled!'

    if @codewarsView.isVisible()
      @codewarsView.hide()
    else
      @codewarsView.show()
