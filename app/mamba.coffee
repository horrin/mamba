Snake = require './snake'
Cell = require './cell'
settings = require './settings'
{keyhandler, renderer, position, game_over} = require './util'

_ = require 'underscore'
$ = window.$


class Mamba
  ###
    Has-one Renderer
    Has-one Keyhandler
  ###

  @motion_keys =
    37: position.value_of(0, -1)  # L
    38: position.value_of(-1, 0)  # U
    39: position.value_of(0, +1)  # R
    40: position.value_of(+1, 0)  # D

  @method_keys =
    82: '__restart'

  constructor: (grid_node) ->
    @_game_over = null
    @_reset_snake()
    @_keyhandler = keyhandler
      .from_handler(@_keyup, $)
      .handle()
    @_renderer = renderer
      .mount(grid_node)
      .render(@_renderprops())

  _reset_snake: ->
    @_snake = Snake.at_position(
      position.random(settings.GRID.dimension - 1))

  _keyup: (keycode) =>
    motion = @constructor.motion_keys[keycode]
    method = @constructor.method_keys[keycode]
    if motion && (@_game_over isnt game_over.failure)
      @_snake.motion(motion)
      (!@_renderer.looping()) && @_renderer.loop(
        @_renderloop_hook, settings.RENDER.interval)
    else if method?
      @[method]()

  __restart: ->
    @_game_over = null
    @_reset_snake()
    @_renderer.reset(@_renderprops())

  _renderloop_hook: =>
    @_snake.move()
    @_renderprops()

  _renderprops: (props = {}) ->
    _.defaults props,
      snake: @_snake
      on_smash: @_on_smash
      on_reset: @_on_reset
      game_over: @_game_over

  _on_reset: (@_Items_left) =>

  _on_smash: (cell) =>
    if cell is Cell.Wall
      @_game_over = game_over.failure
      @_snake.motion(null)
      @_snake.rewind() # this is a hack for the UI: no cell-overlap during collision
      @_renderer.update @_renderprops(), =>
        @_renderer.stop()
    else if cell is Cell.Item
      @_Items_left--
      if @_Items_left is 0
        @_game_over = game_over.success
        @_renderer.stop()
      else
        @_snake.grow()

if $?
  ROOT = $('#mamba')[0]
  window.mamba = new Mamba ROOT
else
  throw new Error "Couldn't find window.$, are you sure jQuery is loaded?"