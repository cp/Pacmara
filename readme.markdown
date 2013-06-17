Pacmara
===

Pacmara is a simple blog engine built with [Sinatra](http://www.sinatrarb.com/) and [Redis](http://redis.io/). It is well documented and commented, perfect for beginning with Sinatra, and/or Redis. Pacmara is a work in progress and is constantly being updated. Contributions appreciated.

Comes included with a basic template, your's free once you clone this repo. S&H not included.

Try Pacmara out at [pacmara.herokuapp.com](http://pacmara.herokuapp.com).

##Requirements
Pacmara requires a either a [RedisToGo](http://redistogo.com/) account, or Redis running on your local machine.

[Setting up Redis](http://redis.io/topics/quickstart)

Installation
------------

    $ bundle
    $ shotgun

Heroku Deployment 
------------

    $ heroku login
    $ heroku create
    $ git push heroku master
    $ heroku config:set REDISTOGO_URL=http://YOUR_REDISTOGO_URL:3030
    
Todo
------------


Contributing
------------

1. Fork it.
2. Create a branch (`git checkout -b my_pacmara`)
3. Commit your changes (`git commit -am "Added Snarkdown"`)
4. Push to the branch (`git push origin my_pacmara`)
5. Open a [Pull Request](http://github.com/colbyaley/pacmara/pulls)