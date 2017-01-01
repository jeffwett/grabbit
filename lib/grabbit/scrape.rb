require 'httparty'
require 'nokogiri'

module Grabbit
  class Scrape

    def initialize(url)
      @url = url
      @doc = get_remote_data
    end

    def title
    	if @doc

    		# Look for og:title or twitter:title first
    		@doc.xpath("//meta[@property='og:title']/@content").each do |element|
  				return element.value.strip
				end

    		# Look for twitter:title first
    		@doc.xpath("//meta[@name='twitter:title']/@content").each do |element|
  				return element.value.strip
				end				
			
				# If no og, look for <title> tags.
				@doc.css("title").each do |element|
  				return element.text.strip					
				end

				# Finally return a blank string
				""
			else
				nil
			end
    end

    def description
    	if @doc

    		# Look for og:description 
    		@doc.xpath("//meta[@property='og:description']/@content").each do |element|
  				return element.value.strip  				
				end

				# Look for twitter:description    	
				@doc.xpath("//meta[@name='twitter:description']/@content").each do |element|
  				return element.value.strip  				
				end

				# If no OG tag or Titter card, look for <meta name='description'> tags.			
    		@doc.xpath("//meta[@name='description']/@content").each do |element|
  				return element.value.strip				
				end
			
			
				# Finally return a blank string
				""
			else
				nil
			end			
    end    

    def images
    	# The following code to return relevant images, is based on the ideas in this blog post:
    	# https://tech.shareaholic.com/2012/11/02/how-to-find-the-image-that-best-respresents-a-web-page/
    	# If the following does not return good results consistently, then consider using 
    	# the Fast Image Gem (https://github.com/sdsykes/fastimage).
      # Check to find the 3 largest images and/or images with an aspect ratio less than 3.0    	

    	images_array = []

    	if @doc
		# Now search for all images in the whole page
		@doc.search("//img/@src").each do |a|
				images_array << image_absolute_uri(a.value)      		
			end
		images_array
   	 end
    end

    private 

			def get_remote_data
				begin
    			response = HTTParty.get(@url)
    		rescue
    			return nil
    		end

	    	if response.code == 200
	    		begin
	    			Nokogiri::HTML(response.body) 
	    		rescue
	    			return nil
	    		end
	    	else
	    		nil
	    	end 
	    end

		  def image_absolute_uri(image_path) 
		    URI.join(@url, image_path).to_s
		  end 
  end
end
