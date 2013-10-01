#!/usr/bin/env ruby
# coding: utf-8

require 'sinatra/base'
require 'sinatra/content_for'
require 'haml'
require 'sass'
require 'rdiscount'


class Blog < Sinatra::Base
    helpers Sinatra::ContentFor

    # config run evn 
    configure do
        set :root, File.dirname(__FILE__)
        set :public_folder, Proc.new {File.join(root, 'assets')}
        set :views, :sass => 'stylesheets', :markdown => 'snippets', :default => 'views'

        helpers do
            def find_template(views, name, engine, &block)
                _, folder = views.detect { |k,v| engine == Tilt[k] }
                folder ||= views[:default]
                super(folder, name, engine, &block)
            end

        end
    end

    # response handlers
    get '/' do
        @index = markdown(:index)
        haml :index
    end

    get '/*' do |snippet|
        @content = markdown(snippet.to_sym)
        haml :snippet
    end

    get '/css/*.css' do |file_name|
        sass file_name.to_sym
    end

    # error handlers
    not_found do
        'This is nowhere to be found'
    end

    error do
        'Sorry there was nasty error - '+ env['sinatra.error'].name
    end
end
