# --                                                            ; {{{1
#
# File        : examples.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-10-23
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'coffee-script'
require 'haml'
require 'sinatra/base'

class Examples < Sinatra::Base

  SCRIPTS = %w{
    /js/jquery.min.js
    /js/underscore.min.js
    /__coffee__/bigbang.js
  }

  COPYRIGHT     = 'Felix C. Stegerman'
  LINK_BB       = 'https://github.com/obfusk/bigbang.coffee'
  LINK_GH       = 'https://github.com/obfusk/bigbang-examples'
  HEROKU_SNAKE  = 'http://bigbang-snake.herokuapp.com'
  SNAKE         = ENV['SNAKE_URL'] || HEROKU_SNAKE

  NAV = %w{ foo bar baz snake }.map do |x|
    { link: "/#{x}", title: x }
  end

  get '/' do
    @link = '/'
    haml :index
  end

  get '/foo' do
    @link = '/foo'
    haml :foo
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
