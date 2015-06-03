module.exports =
class CodewarsWebView
  constructor: (@webview) ->

  execute: (fn) ->
    @webview.send('execute', fn.toString())
