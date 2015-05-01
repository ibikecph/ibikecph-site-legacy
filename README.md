I Bike CPH Site
===============

This is a Rails app that runs the I Bike CPH bicycle route planner at
http://www.ibikecph.dk. OpenStreetMap data is used for maps and
routing. Routing is handled by [OSRM](http://project-osrm.org/) 
running on a separate server.

### How to set up your local development environment

Install RVM

    wget https://raw.githubusercontent.com/rvm/rvm/master/binscripts/rvm-installer
    bash rvm-installer stable --ruby=2.2.0
    source /home/YOUR_USER_HOME_HERE/.rvm/scripts/rvm
    ruby --version
    cd ibikecph-site
    bundle install


Install Nodejs

    cd /tmp
    wget http://nodejs.org/dist/v0.12.2/node-v0.12.2.tar.gz
    sudo apt-get install g++ curl libssl-dev
    tar -xvzf node-v0.12.2.tar.gz
    cd node-v0.12.2
    ./configure
    make
    sudo make install

Create postgres DB on your local environment:

    sudo su - postgres
    createuser -W ibikecph
    createdb -O ibikecph ibikecph_development


Edit config/database.yml and add/update the with your dev username and passwd:

    username: ibikecph
    password: ibikecph123
    host: localhost


Migrate DB and start the dev server:
    rake db:migrate
    rails server -e development


### Don't forget to migrate your DB:

    rake acts_as_taggable_on_engine:install:migrations
    rake db:migrate

