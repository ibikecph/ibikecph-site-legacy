class Theming < ActiveRecord::Base
  belongs_to :theme
  belongs_to :issue
end
