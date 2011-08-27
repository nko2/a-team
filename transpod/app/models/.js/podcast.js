(function() {
  var Podcast;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  Podcast = (function() {
    function Podcast() {
      Podcast.__super__.constructor.apply(this, arguments);
    }
    __extends(Podcast, Backbone.Model);
    Podcast.prototype.initialize = function() {};
    return Podcast;
  })();
  this.Podcast = Podcast;
}).call(this);
