require 'sinatra'
require 'redis'
require 'json'
require 'hiredis'

ENV['REDISTOGO_URL'] = 'redis://localhost:6379' unless ENV['REDISTOGO_URL']
uri = URI.parse(ENV['REDISTOGO_URL'])
$redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)

configure do
	set :title, "This is my blog"
	set :description, "Building a blog with redis."
	set :enable_disqus, true # Set this to true if you want to enable Disqus comments on your posts
	set :disqus_shortname, "XXXXXXXXXXX" # Your Disqus shortname
end

helpers do
	def get_body(slug)
		JSON.parse($redis.GET(slug))['body']
	end
	def get_title(slug)
		JSON.parse($redis.GET(slug))['title']
	end
end

get '/' do
	@posts = $redis.LRANGE('posts', '-100', '100').reverse
	erb :index
end

get '/post' do
	erb :new
end

post '/post' do
	
	post = {
		:body => params[:body],
		:title => params[:title],
		:slug => params[:slug],
		:time => Time.now.to_i,
		:formatted_time => Time.now.strftime("%A %B %e, %Y")
	}
	
	$redis.set(params[:slug], post.to_json) # Save the JSON in Redis, with the key being the slug.
	$redis.RPUSH('posts', params[:slug]) # Ok, now we'll append the post slug to a list, for easy sorting on the homepage.
	
	redirect "/#{params[:slug]}" # Redirect to the post after posting it
end

get '/:slug' do # AKA the post page
	@post = JSON.parse($redis.get(params[:slug]))
	
	erb :post
end