
CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',
    :aws_access_key_id      => ENV['AWS_ACCESS_KEY_ID'],
    :aws_secret_access_key  => ENV['AWS_SECRET_ACCESS_KEY'],
    :region                 => 'us-east-1' #must match actual location of bucket. might want to make sure it also is the same as where servers are hosted - then transfer inbetween is free
  }
  config.fog_directory  = "ibikecph-#{Rails.env}"
  #config.fog_host       = 'https://assets.example.com'
  config.fog_public     = true
  #config.fog_attributes = {'Cache-Control' => 'max-age=315576000'}
end

#enable setting of quality when resizing images with RMagick
module CarrierWave
  module RMagick
    def quality percentage
      manipulate! do |img|
        img.write(current_path) { self.quality = percentage } unless img.quality == percentage
        img = yield(img) if block_given?
        img
      end
    end
  end
end
