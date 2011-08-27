describe 'podcast model', ->

  it 'should handle the truth', ->
    expect(true).toBeTruthy()

  it 'should exist', ->
    expect(Podcast).toBeTruthy()

  it 'should instantiate', ->
    x = new Podcast
    expect(x instanceof Podcast).toBeTruthy()
    expect(x instanceof Backbone.Model).toBeTruthy()

