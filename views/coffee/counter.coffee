# --                                                            ; {{{1
#
# File        : counter.coffee
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-04-03
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : GPLv3+
#
# --                                                            ; }}}1

# start the universe
start = () ->
  canvas  = counter: $('#counter'), start: $('#start')
  world   = running: false, count: '...'
  bb_opts =
    canvas: canvas, fps: 1, world: world, on_tick: on_tick,
    on: { start: on_start }, to_draw: to_draw,
    setup: setup, teardown: teardown
  bigbang bb_opts

# the world changes (every second): when running we count down
on_tick = (w, t) ->
  if w.running
    switch w.count
      when '...'    then running: true , count: 10
      when 0        then running: true , count: 'boom!'
      when 'boom!'  then running: false, count: '...'
      else               running: true , count: w.count - 1
  else
    running: false, count: w.count

# the start/stop button inverts world.running
on_start = (w) -> running: !w.running, count: w.count

# draw: text + button label
to_draw = (w) -> (c) ->
  c.counter.text w.count
  c.start.html "#{ if w.running then 'Stop' else 'Start' } &raquo;"

# add event handler
setup = (c, hs) -> c.start.on 'click', hs.start

# remove event handler
teardown = (c, hs) -> c.start.off 'click', hs.start

# highlight, start
$ -> hljs.initHighlightingOnLoad(); start()

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
