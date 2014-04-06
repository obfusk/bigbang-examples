# --                                                            ; {{{1
#
# File        : todolist.coffee
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-04-05
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : GPLv3+
#
# --                                                            ; }}}1

# create a todo
#
# TODO:
#   * optimize storage
#   * optimize drawing
#
todo = (div, opts = {}) ->
  close = '<button type="button" class="close" aria-hidden="true">' + \
            '&times;</button>'
  items = opts.items || []
  send  = opts.send
  bb    = null

  trigger =
    remove: (c, i)  -> e = $.Event 'bb_remove'; e.index = i; c.trigger e
    set:    (c, xs) -> e = $.Event 'bb_set'; e.items = xs; c.trigger e

  api =
    add:    (w, item) -> w.concat [item]
    remove: (w, i) -> w.slice(0,i).concat w.slice(i+1)
    set:    (w, xs) -> xs

  start = (opts = {}) ->
    send  = opts.send if opts.send
    bb    = bigbang
      world: items, canvas: div, to_draw: to_draw, on: api,
      setup: setup, teardown: teardown

  # draw list of items (w/ handlers)
  to_draw = (w) -> (c) ->
    ti = $('.todo-items', c); ti.empty()
    for x, i in w
      do (i) ->
        tr = $ '<tr>'; td = $ '<td>'; cl = $ close
        td.text x; cl.on 'click', -> trigger.remove c, i
        td.append cl; tr.append td; ti.append tr
    null

  # setup handlers
  setup = (c, hs) ->
    h_set = (e) -> hs.set e.items
    h_rem = (e) -> hs.remove e.index
    h_add = (e) ->
      tt = $('.todo-text', c); x = tt.val(); tt.val ''; hs.add x
      false # prevent default
    h_send = (e) -> send bb.world(); false

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

  start: start, set: (xs) -> trigger.set div, xs

# highlight, start
$ ->
  hljs.initHighlightingOnLoad()
  t1 = todo $('#todo-left'), items: 'foo bar baz'.split(/\s+/)
  t2 = todo $('#todo-right'), items: 'spam ham eggs'.split(/\s+/)
  t1.start send: t2.set; t2.start send: t1.set

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
