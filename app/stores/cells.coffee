{MotionKeyAction, MethodKeyAction} = require '../actions'
{Ticker, XY, GAME} = require '../utility'
Cell = require '../views/cell'
{GRID, LEVEL} = require '../settings'

Dispatcher = require '../dispatcher'
{EmittingStore} = require './emitter'
Immutable = require 'immutable'

LAST_CELLS = null
LIVE_CELLS = Immutable.OrderedMap().withMutations (mutable_cells) ->
  range = GRID.range()
  for row in range
    for col in range
      mutable_cells.set XY.value_of(row, col), null

CellStore = Object.create EmittingStore,

  _post_initialize_hook:
    enumerable: false
    value: ->
      @_reset()

  cellmap:
    enumerable: true
    value: ->
      LIVE_CELLS

  add_change_listener:
    enumerable: true
    value: (listener) ->
      @addListener @_CHANGE_EVENT, listener

  items_left:
    enumerable: true
    value: ->
      GAME.items_left()

  _CHANGE_EVENT:
    value: 'change'

  _METHOD_KEYMAP:
    value: Immutable.Map [
      ['restart', '_restart']
    ]

  _handle_action:
    value: (action) ->
      if action.is_a MotionKeyAction
        motion = action.motion()

        if motion? && not GAME.over()
          GAME.set_motion(motion)
          if not Ticker.ticking()
            @_tick()
      else if action.is_a MethodKeyAction
        method = @_METHOD_KEYMAP.get(action.method())
        @[method]()

  _emit_cells:
    value: ->
      @emit(@_CHANGE_EVENT, cellmap: LIVE_CELLS)

  _tick:
    value: ->
      LAST_CELLS = LIVE_CELLS
      @_update()

      if GAME.out_of_bounds()
        GAME.collide Cell.WALL
      if GAME.over()
        @_finish()
      else
        Ticker.tick => @_tick()

      @_emit_cells()

  _reset:
    value: ->
      GAME.reset()

      LAST_CELLS = null
      LIVE_CELLS = LEVEL.reset(LIVE_CELLS)

      LIVE_CELLS.entrySeq().forEach (entry) ->
        [cell, __] = entry
        if cell is Cell.ITEM
          GAME.add_item()

      @_emit_cells()

  _finish:
    value: ->
      if GAME.failed()
        transform_to_cell = Cell.COLLISION
        @_rewind()
      else
        transform_to_cell = Cell.ITEM

      @_batch_mutate (mutable_cells) ->
        mutable_cells.forEach (cell, xy) ->
          if cell is Cell.SNAKE
            mutable_cells.set xy, transform_to_cell

  _batch_mutate:
    value: (mutator) ->
      LIVE_CELLS = LIVE_CELLS.withMutations mutator

  _rewind:
    value: ->
      LIVE_CELLS = LAST_CELLS
      LAST_CELLS = null

  _update:
    value: ->
      GAME.move_snake()

      @_batch_mutate (mutable_cells) =>
        mutable_cells.forEach (previous_cell, xy) =>
          if GAME.collision xy
            if previous_cell is Cell.VOID
              mutable_cells.set xy, Cell.SNAKE
            else
              if previous_cell is Cell.ITEM
                mutable_cells.set xy, Cell.SNAKE
              GAME.collide previous_cell, xy
          else if previous_cell is Cell.SNAKE
            mutable_cells.set xy, Cell.VOID

  _restart:
    value: ->
      Ticker.stop => @_reset()


module.exports = CellStore