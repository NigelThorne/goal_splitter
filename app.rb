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
  attr_accessor :goals, :active
  def initialize
    @goals = []
  end  

end

class Goal
  attr_accessor :name, :description, :goals, :parent
  def initialize(name, parent = nil)
    @name = name
    @goals = [];
    @parent = parent;
  end
  
end

class MyApp < Sinatra::Base
  def initialize
    @state = @@state
    @state.active = @state.goals.dup
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
  
  @@state ||= State.new() # keep state between reloads.
  
  post '/reset' do
    @state.goals =  to_goals( 
      {
        "Goal planner" => {
          "Web front end" => {
            "Show goals" => {},
            "Add subgoal / Chunk down" => {},
            "Add alternatives / Chunk across" => {},
            "Navigate to parent / Chunk up" => {},
            "Navigate to child / Chunk down" => {},
          },
          "Persistance" => {
            "Options" => {
              "Save to filesystem" => {},
              "Save to database" => {},
            },
          },
          "Published to octohost" => {},
          "Multiple Projects" => {},
          "Multiple Users" => {},
        },
      }
    )
    @state.active = @state.goals.dup
    redirect "/"
  end  
  
  get '/' do
    slim :index
  end

  post '/goals' do
    g = Goal.new(params[:name])
    @state.goals << g
    @state.active << g
    redirect "/"
  end
  
  def to_goals(hash, parent = nil)
    hash.to_a.map{ |k,v| 
      g = Goal.new(k, parent)
      g.goals = to_goals(v, g)
      g
    }
  end
  
 
end

