# config.ru
require 'rubygems'
require 'sinatra/base'
require 'rack/reloader'
require './app'

run MyApp
