class AboutController < ApplicationController

	def index
	    @blog_entries = BlogEntry.latest.paginate :page => params[:page], :per_page => 10
	end
	  
end