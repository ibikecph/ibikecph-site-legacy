#filter that transforms #34 to a link to issue with id 34

AutoHtml.add_filter(:issue_link) do |text|
  text.gsub(/\#(\d+)/) do |match|
    id = $1
    if Issue.exists? id
      url = Rails.application.routes.url_helpers.issue_path(:id=>id)
      %{<a href="#{url}">##{id}</a>}
    else
      "##{id}"
    end
  end
end
