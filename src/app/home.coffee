app = require './index'

app.get app.pages.home.href, (page, model, params, next) ->
  titleColor = model.at 'home2.titleColor'
  colors = model.at 'home2.colors'
  model.subscribe titleColor, colors, (err) ->
    return next err if err
    titleColor.setNull 'black'
    colors.setNull [
      {name: 'black'}
      {name: 'deep pink'}
      {name: 'lime green'}
      {name: 'coral'}
      {name: 'dark turquoise'}
      {name: 'dark orchid'}
    ]
    page.render 'home'

app.component 'home:colored-title', class ColoredTitle
  init: (model) ->
    model.ref 'titleColor', model.scope('home2.titleColor')
    @colors = model.scope 'home2.colors'
    model.ref 'colors', @colors

  unspace: (s) ->
    return s if typeof s isnt 'string'
    return s.replace /\s/g, ''

  capitalize: (s) ->
    return s if typeof s isnt 'string'
    return s.charAt(0).toUpperCase() + s.slice(1).toLowerCase()

  colorInputValue:
    get: (name, titleColor) -> name
    set: (value, name, titleColor) ->
      return if name == titleColor then [value, value] else [value]

  titleInputValue:
    get: (titleColor) -> titleColor
    set: (value, titleColor) ->
      for color, i in @colors.get() || []
        if color.name == titleColor
          @colors.setDiff i + '.name', value
      return [value]
