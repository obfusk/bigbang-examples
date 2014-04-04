# --                                                            ; {{{1
#
# File        : todo.coffee
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-04-03
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
todo = (div, items = []) ->
  bb = null

  # start
  start = ->
    bb = bigbang
      canvas: div, world: items,
      on: { add: to_add, remove: to_remove },
      to_draw: to_draw, setup: setup, teardown: teardown

  # trigger bb_remove event, passing index
  remove = (c, i) -> e = $.Event 'bb_remove'; e.index = i; c.trigger e

  # add item
  to_add = (w, item) -> w.concat [item]

  # remove item at index
  to_remove = (w, i) -> w.slice(0,i).concat w.slice(i+1)

  # draw list of items (w/ handlers)
  to_draw = (w) -> (c) ->
    ti = $('.todo-items', c); $('ul', ti).remove(); ul = $ '<ul>'
    for x, i in w
      li = $ '<li>'; li.data 'index', i; li.text x
      li.on 'click', -> remove c, $(this).data('index')
      ul.append li
    ti.append ul

  # setup handlers
  setup = (c, hs) ->
    h_rem = (e) -> hs.remove e.index
    h_add = (e) ->
      tt = $('.todo-text', c); x = tt.val(); tt.val ''; hs.add x
      false # prevent default
    h_send = (e) -> alert bb.world(); false

    c.on 'bb_remove', h_rem
    $('.todo-controls', c).on 'submit', h_add
    $('.todo-send', c).on 'click', h_send

    {h_rem,h_add,h_send}

  # cleanup handlers
  teardown = (c, hs, sv) ->
    c.off 'bb_remove', sv.h_rem
    $('.todo-add', c).off 'submit', sv.h_add
    $('.todo-send', c).off 'click', sv.h_send

  {start}

# highlight, start
$ ->
  hljs.initHighlightingOnLoad()
  todo($('#todo-left'), 'foo bar baz'.split(/\s+/)).start()
  todo($('#todo-right'), 'spam ham eggs'.split(/\s+/)).start()

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
