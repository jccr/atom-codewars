// In guest page.
var ipc = require('ipc');

window.ipc = ipc;
window._$$ = require('jquery');
window._$_ = require('lodash');

(function() {

  function Message(id, channel, message) {
    this.id = id;
    this.channel = channel;
    this.message = message;
  }

  function Result(error, result) {
    this.error = error;
    this.result = result;
  }

  function handle(channel, callback) {
    ipc.on(channel, function(id) {
      ipc.sendToHost(new Message(id, channel, callback.apply(this, [].slice.call(arguments, 1))));
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



})();
