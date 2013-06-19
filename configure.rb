configure do # Customize your blog.
	set :title, "This is my blog"
	set :description, "Building a blog with redis."
	set :db_list_title, "posts" # Change this in the case that you are using one Redis database for multiple blogs.
	
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

RedisPagination.configure do |configuration|
  configuration.redis = @@redis
  configuration.page_size = 2
end