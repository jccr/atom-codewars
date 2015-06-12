fs = require 'fs'
path = require 'path'
mkdirp = require 'mkdirp'
Q = require 'q'

{CompositeDisposable} = require 'atom'
CodewarsView = require './codewars-view'

module.exports = Codewars =
  dataDir: 'codewars-workspace'
  codewarsView: null
  subscriptions: null
  openNewWindow: false
  windowWasOpened: false

  checkWindowLock: (callback) ->
    writeLockFile = (cb) =>
      fs.writeFile @windowLockPath, atom.getCurrentWindow().id, cb

    fs.readFile @windowLockPath, (err, data) =>
      if err or atom.getCurrentWindow().id is 1
        @clearWindowLock =>
          writeLockFile (err) =>
            throw err if err
            @openNewWindow = true
            callback false
      else if (parseInt data.toString()) < atom.getCurrentWindow().id
        writeLockFile (err) ->
          throw err if err
          callback true
      else
        callback false

  clearWindowLock: (callback) ->
    fs.unlink @windowLockPath, callback

  activate: (state) ->
    @path = path.join atom.getConfigDirPath(), @dataDir
    @windowLockPath = path.join @path, 'window.lock'

    mkdirp @path, (err) =>
      throw err if err
      @checkWindowLock (activate) =>
        return unless activate
        @createView state

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'codewars:toggle': => @toggle()

  createView: (state) ->
    window.codewars = @
    @codewarsView = new CodewarsView @path, state.codewarsViewState
    @codewarsView.show()

  deactivate: ->
    @clearWindowLock()
    @subscriptions?.dispose()
    @codewarsView?.destroy()

  serialize: ->
    codewarsViewState: @codewarsView.serialize()

  toggle: ->
    if @windowWasOpened
      @checkWindowLock (activate) =>
        if @openNewWindow
          @windowWasOpened = false
          @toggle()
        else atom.notifications.addInfo "Codewars is already open in another window."
      return

    if @openNewWindow
      atom.open pathsToOpen: [path.join(@path, 'codewars')], newWindow: true
      @windowWasOpened = true
      @openNewWindow = false
      return

    if @codewarsView.isVisible()
      @codewarsView.hide()
    else
      @codewarsView.show()
