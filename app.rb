require 'sinatra'
require 'redis'
require 'json'
require 'sinatra/flash'

ENV['REDISTOGO_URL'] = 'redis://localhost:6379' unless ENV['REDISTOGO_URL']
uri = URI.parse(ENV['REDISTOGO_URL'])
@@redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)

configure do # Customize your blog.
	set :title, "This is my blog"
	set :description, "Building a blog with redis."
	
	# Disqus commenting
	set :enable_disqus, true # Set this to true if you want to enable Disqus comments on your posts
	set :disqus_shortname, "XXXXXXXXXXX" # Your Disqus shortname

	# Dashboard authentication
	set :username, "admin"
	set :password, "password"
	
	# Twitter post sharing
	set :twitter_username, "aley"
	set :enable_twitter_sharing, true # Set to false if you don't want to become famous on Twitter.
end

enable :sessions # You should leave this alone.

helpers do    
	def current_user
  	@current_user ||= session[:user].capitalize if session[:user]
  end
  
  def json_parse(slug)
		JSON.parse(@@redis.get(slug))
	end
end

get '/logout' do
	session['user'] = nil
	redirect "/"
end

get '/login' do
	@page_title = "Log in - #{settings.title}"
	erb :login
end

post '/login' do
	if params[:username] == settings.username && params[:password] == settings.password
		session['user'] = settings.username
		redirect '/'
	else
		flash[:error] = "Either your username or password was incorrect."
		redirect '/login'
	end
end

get '/post/:slug/edit' do
	redirect '/login' unless current_user
	@post = JSON.parse(@@redis.get(params[:slug]))
	@page_title = "Editing #{@post['title']} - #{settings.title}"
	erb :edit
end

get '/post/:slug/delete' do
	redirect '/login' unless current_user
	@@redis.DEL(params[:slug])
	@@redis.lrem('posts', 0, params[:slug])
	redirect '/'
end

get '/' do
	@posts = @@redis.LRANGE('posts', '-100', '100').reverse
	
	@page_title = settings.title
	erb :index
end

get '/post/new' do
		redirect '/login' unless current_user
		@page_title = "New Post - #{settings.title}"
		erb :new
end

post '/post/new' do
	redirect '/login' unless current_user
	
	post = {
		:body => params[:body],
		:title => params[:title],
		:slug => params[:slug],
		:time => Time.now.to_i,
		:formatted_time => Time.now.strftime("%A %B %e, %Y")
	}
	
	@@redis.set(params[:slug], post.to_json) # Save the JSON in Redis, with the key being the slug.
	@@redis.RPUSH('posts', params[:slug]) # Ok, now we'll append the post slug to a list, for easy sorting on the homepage.
	
	redirect "/#{params[:slug]}" # Redirect to the post after posting it
end

post '/post/edit' do
	redirect '/login' unless current_user
	
	post = {
		:body => params[:body],
		:title => params[:title],
		:slug => params[:slug],
		:time => Time.now.to_i,
		:formatted_time => Time.now.strftime("%A %B %e, %Y")
	}
	
	@@redis.set(params[:slug], post.to_json) # Save the JSON in Redis, with the key being the slug.
	if params[:slug] != params['old-slug']
		@@redis.DEL(params['old-slug'])
		@@redis.lrem('posts', 0, params['old-slug'])
		@@redis.RPUSH('posts', params[:slug])
	end
	
	redirect "/#{params[:slug]}" # Redirect to the post after posting it
end

get '/:slug' do # AKA the post page
	@post = JSON.parse(@@redis.get(params[:slug]))
	
	@page_title = "#{@post['title']} - #{settings.title}"
	erb :post
end