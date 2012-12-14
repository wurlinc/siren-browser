# Siren Browser

A [Siren](https://github.com/kevinswiber/siren) client.

It's a mostly browser based client, but it uses Rails for deployment for
a few reasons:

- it's implemented in CoffeeScript, so it's taking advantage of the
  Rails asset pipeline.
- it's an easy deploy to Heroku.

## Live Demo
A live demo is up at [Heroku](http://siren-browser.herokuapp.com/)


## Getting Started

Steps for getting started to work on this app.

#### Clone the repo

    git clone https://github.com/wurlinc/siren-browser.git
    cd siren-browser
    

#### Install dependencies
  It's currently only tested with Ruby 1.9.2.

    bundle install

#### Run the server
    bundle exec rails server

#### Launch the app
    open http://localhost:5000

