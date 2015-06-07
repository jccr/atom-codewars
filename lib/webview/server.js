// In guest page.
var ipc = require('ipc');

window.ipc = ipc;
window._$$ = require('jquery');
window._$_ = require('lodash');

(function() {

  function Message(type, data, id) {
    this.type = type;
    this.data = data;
    this.id = id;
  }

  function Result(error, result) {
    this.error = error;
    this.result = result;
  }

  function handle(type, callback) {
    ipc.on(type, function(id) {
      ipc.sendToHost(new Message(type, callback.apply(this, [].slice.call(arguments, 1)), id));
    });
  }

  handle('execute', function(code) {
    var result = new Result();

    try {
      result.result = eval(code);
    } catch (e) {
      result.error = {
        message: e.message,
        stack: e.stack
      };
    }

    return result;
  });

  function WebViewHost() {}

  WebViewHost.prototype.emit = function(type) {
    ipc.sendToHost(new Message('emit',
      new Message(type, [].slice.call(arguments, 1))
    ));
  };

  window.$wh = new WebViewHost();


})();
