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

      error = data.message?.error

      # mangle error
      if error
        if DEBUG then @webview.openDevTools()
        error = new Error(data.message.error.message)
        error.stack = callback.fn + '\n' + data.message.error.stack

      # invoke callback
      callback.cb?(error, data.message?.result)


  execute: (fn, cb) =>
    id = WebViewClient.id()

    # wrap function source so it is self executing
    fn = "(#{fn.toString()})()"
    # replace uses of jquery and lodash with internal symbols
    fn = fn.replace(/([\$\_])(?=[\(\.\[])/, '_$$$&')

    # generate callback info
    callbacks[id] = {fn: fn, cb: cb}

    @webview.send('execute', id, fn)
