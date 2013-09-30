# encoding: utf-8

require 'sinatra'
require 'sinatra/content_for'
require 'sinatra/reloader' if development?
require 'haml'
require 'sass'
require 'rdiscount'

get '/' do
    @index = RDiscount.new(File.open("snippets/index.md").read).to_html
    haml :index
end
