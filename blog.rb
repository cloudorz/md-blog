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

    get %r{^/(\w[\w|-]+\w)$} do |snippet|
        begin
            @content = markdown(snippet.to_sym)
            haml :snippet
        rescue Errno::ENOENT
            not_found
        end
    end

    get '/css/*.css' do |file_name|
        begin
            sass file_name.to_sym
        rescue Errno::ENOENT
            not_found
        end
    end

    # iOS UDID Retrive
    before do
        if request.path_info == '/udid'
            request.body.rewind
            raw_data = request.body.read.encode('UTF-16', 'UTF-8', :invalid=>:replace, :replace=>"").encode('UTF-8')
            contained_udid = raw_data.split('<key>UDID</key>')[1].split('<key>VERSION</key>')[0]
            udid = />(.*)</.match(contained_udid)[1]
            params['udid'] = udid unless udid == nil
        end
    end

    post '/udid' do
        redirect "mailto:cloud@liulishuo.com?subject=iOS UDID &body=Hi, Cloud %0d%0aUDID: #{params['udid']}, %0d%0aName: Enter your name, Please", 301
    end

    # error handlers
    not_found do
        '404'
    end

    error do
        'Oops~~!'
    end
end
