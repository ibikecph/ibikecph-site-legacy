module ApplicationHelper

  def errors_for(object)
    if object.errors.any?
      render 'layouts/error_messages', :target => object
    else
      ''
    end
  end  

  def chars_remaining
    '<span class="chars_remaining"></span>'.html_safe
  end

  def attribute_required? object, attribute
    #inspect a model to see if the attribute is required (validates :presence => true)
    target = (object.class == Class) ? object : object.class
    target.validators_on(attribute).map(&:class).include?( ActiveModel::Validations::PresenceValidator )
  end
  
  def image_fields form, object, klass=nil, note=nil
    out = ''
    out << form.label(:image)
    if note
      out << %{ <span class="note">#{note}</span>}
    end
    out << '<br>'
		if object.image?
		  klass = object.image.is_a?(SquareImageUploader) ? 'g2 square' : 'g2'
			out << image_tag(object.image.g2.url,:class => klass)
  		unless attribute_required? object, :image
  		  out << form.check_box(:remove_image)
  		  out << ' Remove<br>'
  		end
  	end
		out << form.file_field(:image)
		if object.image?
  	end
		out << form.hidden_field(:image_cache)
		out.html_safe
	end
	


end
