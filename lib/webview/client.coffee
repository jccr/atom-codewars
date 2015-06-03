module.exports =
class CodewarsWebView
  @id: () -> ++@id

  constructor: (@webview) ->
    @webview.addEventListener 'ipc-message', (event) =>
      console.log event.channel


  execute: (fn) ->
    @webview.send('execute', @id(), fn.toString())
