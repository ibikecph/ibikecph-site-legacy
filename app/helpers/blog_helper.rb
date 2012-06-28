module BlogHelper
  include AutoHtml
  include ActsAsTaggableOn::TagsHelper
  
  def auto_html_blog html, options
    #gsub doesn't work on SafeStrings. to avoid this, use to_str to convert to normal stri
    auto_html html.to_str do
      simple_format
      vimeo options
      youtube options
      link :target => 'blank'
    end
    
  end
end
