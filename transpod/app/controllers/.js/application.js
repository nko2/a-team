(function() {
  var Application;
  Application = (function() {
    function Application() {}
    Application.prototype.start = function() {
      return console.log('App started');
    };
    return Application;
  })();
  this.Application = Application;
}).call(this);
