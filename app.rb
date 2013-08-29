%w{sinatra redis json sinatra/flash}.each { |x| require x }

redis_url = ENV['REDISTOGO_URL'] || 'redis://localhost:6379'
uri = URI.parse(redis_url)
REDIS = Redis.new(host: uri.host, port: uri.port, password: uri.password)

require_relative 'configure.rb'

enable :sessions

helpers do 
  def current_user
    @current_user = session[:user].capitalize if session[:user]
  end
  
  def authenticate!
    redirect '/login' unless current_user
  end

  def json_parse(slug)
    JSON.parse(REDIS.get(slug))
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
  authenticate!
  @post = JSON.parse(REDIS.get(params[:slug]))
  @page_title = "Editing #{@post['title']} - #{settings.title}"
  erb :edit
end

get '/post/:slug/delete' do
  authenticate!
  REDIS.DEL(params[:slug])
  REDIS.lrem(settings.db_list_title, 0, params[:slug])
  redirect '/'
end

get '/' do
  @posts = REDIS.LRANGE('posts', '0', '-1').reverse
  @page_title = settings.title
  erb :index
end

get '/post/new' do
  authenticate!
  @page_title = "New Post - #{settings.title}"
  erb :new
end

post '/post/new' do
  authenticate!
	
  post = {
    body: params[:body],
    title: params[:title],
    slug: params[:slug],
    time: Time.now.to_i,
    formatted_time: Time.now.strftime("%A %B %e, %Y")
  }
	
  REDIS.set(params[:slug], post.to_json) # Save the JSON in Redis, with the key being the slug.
  REDIS.RPUSH(settings.db_list_title, params[:slug]) # Ok, now we'll append the post slug to a list, for easy sorting on the homepage.
	
  redirect "/#{params[:slug]}" # Redirect to the post after posting it
end

post '/post/edit' do
  authenticate!
	
  post = {
    body: params[:body],
    title: params[:title],
    slug: params[:slug]
  }
	
  REDIS.set(params[:slug], post.to_json) # Save the JSON in Redis, with the key being the slug.
  if params[:slug] != params['old-slug']
    REDIS.DEL(params['old-slug'])
    REDIS.lrem(settings.db_list_title, 0, params['old-slug'])
    REDIS.RPUSH(settings.db_list_title, params[:slug])
  end
	
  redirect "/#{params[:slug]}" # Redirect to the post after posting it
end

get '/:slug' do # the post page
  @post = JSON.parse(REDIS.get(params[:slug]))
  @page_title = "#{@post['title']} - #{settings.title}"
  erb :post
end
