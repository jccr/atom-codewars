DEBUG = true
{EventEmitter} = require 'events'

module.exports =
class WebviewClient extends EventEmitter
  id = 0
  callbacks = []

  @id: -> ++id

  constructor: (@webview) ->
    window.client1 = @

    @webview.addEventListener 'ipc-message', @_messageHandler

  _messageHandler: (event) =>
    channel = event.channel

    # get callback info for this message
    callback = callbacks[channel.id]

    switch channel.type
      when 'emit'
        channelData = channel.data
        channelData.data.unshift(channelData.type)
        eventToEmit = channelData.data
        @emit.apply @, eventToEmit

      when 'execute'
        error = channel.data?.error

        # mangle error
        if error
          if DEBUG then @webview.openDevTools()
          error = new Error(channel.data.error.message)
          error.stack = callback.fn + '\n' + channel.data.error.stack

        # invoke callback
        callback.cb?(error, channel.data?.result)


  execute: (fn, cb) =>
    id = WebviewClient.id()

    # wrap function source so it is self executing
    fn = "(#{fn.toString()})()"
    # replace uses of jquery and lodash with internal symbols
    fn = fn.replace(/([\$\_])(?=[\(\.\[])/, '_$$$&')

    # generate callback info
    callbacks[id] = {fn: fn, cb: cb}

    @webview.send('execute', id, fn)
