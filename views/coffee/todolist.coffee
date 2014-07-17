# --                                                            ; {{{1
#
# File        : todolist.coffee
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-04-07
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : GPLv3+
#
# --                                                            ; }}}1

# create a todo
#
#     todo div,
#       items:          [...],
#       optimise_draw:  boolean,
#       optimise_data:  boolean
#
todo = (div, opts = {}) ->
  close         = '<button type="button" class="close" ' + \
                    'aria-hidden="true">&times;</button>'
  items         = opts.items || []
  send          = opts.send
  optimise_draw = opts.optimise_draw
  optimise_data = opts.optimise_data
  bb            = null

  # trigger events
  trigger =
    remove: (c, i)  -> e = $.Event 'bb_remove'; e.index = i; c.trigger e
    set:    (c, xs) -> e = $.Event 'bb_set'; e.items = xs; c.trigger e

  # update world
  api =
    add:    (w, item) -> w.concat [item]
    remove: (w, i)    -> w.slice(0,i).concat w.slice(i+1)
    set:    (w, xs)   -> xs

  # mutable api
  #
  # NB: * be careful w/ mutable state!
  #     * only use it if performance is actually an issue!
  #     * never use it with a queue (of more than one item)!
  api_mutable =
    add:    (w, item) -> w.push item; w
    remove: (w, i)    -> w.splice i, 1; w
    set:    (w, xs)   -> xs.slice()

  # keep log of last action so we can use that to draw instead of
  # having to re-draw the whole todo list
  api_w_log = (api) -> _.reduce api, (x,v,k) ->
    x[k] = (w, args...) ->
      world: v(w.world, args...), action: k, args: args
    x
  , {}

  # remove item
  draw_rm = (c, ti, i) ->
    trs = $('tr', ti)
    for j in [i+1..trs.length-1] by 1
      --$('.close', trs[j]).data().index
    $(trs[i]).remove()

  # add item
  draw_add = (c, ti, x, i) ->
    tr = $ '<tr>'; td = $ '<td>'; cl = $ close
    td.text x; cl.data().index = i
    cl.on 'click', -> trigger.remove c, $(this).data().index
    td.append cl; tr.append td; ti.append tr

  # draw: clear and add all items
  to_draw = (w) -> (c) ->
    ti = $('.todo-items', c); ti.empty()
    for x, i in w
      draw_add c, ti, x, i
    null

  # optimised draw: add, remove or set based on log
  to_draw_w_log = (w) -> (c) ->
    ti = $('.todo-items', c)
    switch w.action
      when 'add'    then draw_add c, ti, w.args[0], w.world.length-1
      when 'remove' then draw_rm c, ti, w.args[0]
      when 'set'    then to_draw(w.world)(c)

  if optimise_data
    _a = api_mutable
  else
    _a = api

  if optimise_draw
    _w = world: items, action: 'set', args: [items]
    _d = to_draw_w_log
    _o = api_w_log _a
    _s = -> send bb.world().world
  else
    _w = items
    _d = to_draw
    _o = _a
    _s = -> send bb.world()

  # setup handlers
  setup = (c, hs) ->
    h_set = (e) -> hs.set e.items
    h_rem = (e) -> hs.remove e.index
    h_add = (e) ->
      tt = $('.todo-text', c); x = tt.val(); tt.val ''; hs.add x
      false # prevent default
    h_send = (e) -> _s(); false

    c.on 'bb_set', h_set
    c.on 'bb_remove', h_rem
    $('.todo-controls', c).on 'submit', h_add
    $('.todo-send', c).on 'click', h_send

    {h_set,h_rem,h_add,h_send}

  # cleanup handlers
  teardown = (c, hs, sv) ->
    c.off 'bb_set', sv.h_set
    c.off 'bb_remove', sv.h_rem
    $('.todo-add', c).off 'submit', sv.h_add
    $('.todo-send', c).off 'click', sv.h_send

  start = (opts = {}) ->
    send  = opts.send if opts.send
    bb    = bigbang
      world: _w, canvas: div, to_draw: _d, on: _o, setup: setup,
      teardown: teardown

  start: start, set: (xs) -> trigger.set div, xs

# highlight, start
$ ->
  hljs.initHighlightingOnLoad()

  t0 = todo $('#todo-0'), items: 'foo bar baz'.split(/\s+/), \
                          optimise_data: true
  t1 = todo $('#todo-1'), items: 'spam ham eggs'.split(/\s+/), \
                          optimise_draw: true
  t2 = todo $('#todo-2'), items: 'one two three'.split(/\s+/), \
                          optimise_draw: true, optimise_data: true
  t3 = todo $('#todo-3'), items: '37 42 97'.split(/\s+/)

  t0.start send: t1.set; t1.start send: t3.set
  t2.start send: t0.set; t3.start send: t2.set

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
