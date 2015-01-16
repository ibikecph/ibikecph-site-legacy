class Follow < ActiveRecord::Base

  belongs_to :user
  belongs_to :followable, polymorphic: true

  # attr_accessible :active

end
