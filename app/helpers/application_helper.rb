module ApplicationHelper

  def errors_for(object)
    if object.errors.any?
      render 'layouts/error_messages', target: object
    else
      ''
    end
  end

  def chars_remaining
    '<span class="chars_remaining"></span>'.html_safe
  end

  def attribute_required? object, attribute
    # inspect a model to see if the attribute is required (validates :presence => true)
    target = (object.class == Class) ? object : object.class
    target.validators_on(attribute).map(&:class).include? ActiveModel::Validations::PresenceValidator
  end


  def resource_name
    :user
  end

  def markdown(text)
    Markdown.new(text).to_html
    #options = [:hard_wrap, :filter_html, :autolink, :no_intraemphasis, :fenced_code, :gh_blockcode]
    #syntax_highlighter(Redcarpet.new(text, *options).to_html).html_safe
  end
end
