# https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server

# Heroku time outs after 30 seconds, but this will leave the Puma webserver waiting for a reply.
# Use RackTimeout to abort after 25 seconds, so we get an exception and backtrace

Rack::Timeout.timeout = 25      # seconds
Rack::Timeout::Logger.disable   # don't log timings, but still get exceptions