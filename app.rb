#!/usr/bin/env ruby

# Libraries:::::::::::::::::::::::::::::::::::::::::::::::::::::::
require 'rubygems'
require 'sinatra/base'
require 'slim'
require 'sass'
require 'coffee-script'
 
class SassHandler < Sinatra::Base
    set :views, File.dirname(__FILE__) + '/templates/sass'
    
    get '/css/*.css' do
        filename = params[:splat].first
        sass filename.to_sym
    end
end
 
class CoffeeHandler < Sinatra::Base
    set :views, File.dirname(__FILE__) + '/templates/coffee'
    
    get '/js/*.js' do
        filename = params[:splat].first
        coffee filename.to_sym
    end
end

class State
  attr_reader :goals
  def initialize
    @goals = []
  end  
end

class Goal
  attr_accessor :name, :description, :goals
  def initialize(name, description)
    @name = name; @description = description
    @goals = [];
  end
end

class MyApp < Sinatra::Base
  def initialize
    @state = @@state
    super
  end

  reset!
  use SassHandler
  use CoffeeHandler
  use Rack::Reloader

  helpers do
    def partial(template, locals = {})
      slim template, :layout => false, :locals => locals
    end
  end
  
  @@state ||= State.new()
  
  get '/' do
    slim :index
  end

  post '/goals' do
    @state.goals << Goal.new(params[:name],"")
    redirect "/"
  end
end

