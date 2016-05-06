xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title " I Bike CPH - Blog"
    xml.description "The latest news from I Bike CPH"
    xml.link blog_entry_index_url

    for entry in @blog_entries
      xml.item do
        xml.title entry.title
        xml.description do 
          xml.cdata! entry.body
        end
        xml.PublishedDate entry.created_at.strftime("%Y-%m-%dT%H:%M:%SZ%Z")
        xml.link blog_entry_url(entry)
      end
    end
  end
end