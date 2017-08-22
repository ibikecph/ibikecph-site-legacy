# we use a geocoding api provided by kortforsyningen.dk.
# login happens using a "ticket" (a token) which expires after 24 hours:
# https://kortforsyningen.dk/content/login
#
# to avoid calling an external api during request, which is slow and
# error prone, a background task renews the ticket regularly, and stores
# it in a KortforsyningenTicket model.
#
# the most current ticket is passed to the front-end where it's used when making
# geocoding queries.


require 'net/http'
require 'uri'

class KortforsyningenTicket < ActiveRecord::Base
  validates_presence_of :code
end
