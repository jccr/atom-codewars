DEBUG = true

module.exports =
class WebViewClient
  id = 0
  callbacks = []

  @id: -> ++id

  constructor: (@webview) ->
    window.WebViewClient1 = @

    @webview.addEventListener 'ipc-message', (event) =>
      data = event.channel

      # get callback info for this message
      callback = callbacks[data.id]

      # invoke callback
      callback.cb?()

      # handle incoming errors
      if data.message?.error?.message
        if DEBUG then @webview.openDevTools()
        error = new Error(data.message.error.message)
        error.stack = callback.fn + '\n' + data.message.error.stack
        throw error

  execute: (fn, cb) =>
    id = WebViewClient.id()

    # wrap function source so it is self executing
    fn = "(#{fn.toString()})()"

    # generate callback info
    callbacks[id] = {fn: fn, cb: cb}

    @webview.send('execute', id, fn)
