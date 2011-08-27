(function() {
  describe('podcast model', function() {
    it('should handle the truth', function() {
      return expect(true).toBeTruthy();
    });
    it('should exist', function() {
      return expect(Podcast).toBeTruthy();
    });
    return it('should instantiate', function() {
      var x;
      x = new Podcast;
      expect(x instanceof Podcast).toBeTruthy();
      return expect(x instanceof Backbone.Model).toBeTruthy();
    });
  });
}).call(this);
