class ImageUploader < CarrierWave::Uploader::Base

  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper

  COLUMN_WIDTH = 60
  GUTTER_WIDTH = 40
  ASPECT_RATIO = 2.0 / 3.0

  def self.grid_width columms
    columms * COLUMN_WIDTH + (columms - 1) * GUTTER_WIDTH
  end

  def self.image_size columms, aspect = :landscape
    w = self.grid_width columms
    case aspect
    when :square
      [w, w]
    else
      [w, w * ASPECT_RATIO]
    end
  end

  # Choose what kind of storage to use for this uploader:
  if Rails.env.production? || Rails.env.staging?
    storage :fog
  else
    storage :file
  end

  # Include RMagick or ImageScience support:
  include CarrierWave::MiniMagick

  # Setup cache dir
  if Rails.env.production? || Rails.env.staging?
    def cache_dir
      "#{Rails.root}/tmp/uploads"   # we're deploying on heroku, use /tmp for processing images
    end
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    # "/images/fallback/default.png"
    image_path "default/#{model.class.to_s.underscore}/#{version_name}.png"
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg png gif)
  end

  # Override the filename of the uploaded files:
  # def filename
  #   "something.jpg" if original_filename
  # end
  # encoding: utf-8

end
