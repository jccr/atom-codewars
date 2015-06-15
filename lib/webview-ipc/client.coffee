DEBUG = true
{Emitter} = require 'atom'

module.exports =
class WebviewClient
  id = 0
  callbacks = []

  @id: -> ++id

  constructor: (@webviewElement) ->
    @emitter = new Emitter

    @webviewElement.addEventListener 'ipc-message', @_messageHandler

  destroy: ->
    @emitter.dispose()

  _messageHandler: (event) =>
    channel = event.channel

    # get callback info for this message
    callback = callbacks[channel.id]

    switch channel.type
      when 'emit'
        channelData = channel.data
        channelData.data.unshift channelData.type
        eventToEmit = channelData.data
        @emitter.emit.apply @emitter, eventToEmit

      when 'execute'
        error = channel.data?.error

        # mangle error
        if error
          if DEBUG then @webviewElement.openDevTools()
          error = new Error channel.data.error.message
          error.stack = callback.fn + '\n' + channel.data.error.stack

        # invoke callback
        callback.cb? error, channel.data?.result

  _encodeObject: (obj) =>
    return JSON.stringify obj

  execute: (fn, cb, args...) =>
    id = WebviewClient.id()

    # wrap function source so it is self executing
    fn = "(#{fn.toString()})()"
    # replace uses of jquery and lodash with internal symbols
    fn = fn.replace /([\$\_\@])(?=[\(\.\[])/, '_$$$&'
    # replace @emitter with _$emitter
    fn = fn.replace /this\.(emitter[.\[])/, '_$$$1'
    # replace variable placeholders with args
    matchIndex = 0
    fn = fn.replace /\$\d+[^\W_\$]?/, => @_encodeObject args[matchIndex++]

    # generate callback info
    callbacks[id] = {fn: fn, cb: cb}

    @webviewElement.send 'execute', id, fn
