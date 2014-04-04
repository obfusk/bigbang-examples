# --                                                            ; {{{1
#
# File        : examples.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-04-03
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : GPLv3+
#
# --                                                            ; }}}1

require 'coffee-script'
require 'haml'
require 'sinatra/base'

class Examples < Sinatra::Base

  CSS = %w{
    /css/bootstrap.min.css
    /css/hljs/docco.css
    /css/examples.css
  }

  SCRIPTS = %w{
    /js/jquery.min.js
    /js/underscore.min.js
    /js/highlight.pack.js
    /__coffee__/bigbang.js
  }

  COPYRIGHT     = 'Felix C. Stegerman'
  LINK_BB       = 'https://github.com/obfusk/bigbang.coffee'
  LINK_GH       = 'https://github.com/obfusk/bigbang-examples'
  HEROKU_SNAKE  = 'http://bigbang-snake.herokuapp.com'
  SNAKE         = ENV['SNAKE_URL'] || HEROKU_SNAKE

  EXAMPLES      = %w{ counter todo }
  NAV           = EXAMPLES.map do |x|
    { link: "/#{x}", title: x }
  end + [{ link: '/snake', title: '&raquo; snake' }]

  get '/' do
    haml :index
  end

  EXAMPLES.each do |ex|
    get "/#{ex}" do
      @link     = "/#{ex}"
      @scripts  = SCRIPTS + %W{ /__coffee__/#{ex}.js }
      haml ex.to_sym
    end
  end

  get '/snake' do
    redirect SNAKE
  end

  get '/__coffee__/:name.js' do |name|
    content_type 'text/javascript'
    coffee :"coffee/#{name}"
  end

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
