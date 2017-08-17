CarrierWave.configure do |config|
  if Rails.env.production? || Rails.env.staging?
    config.fog_provider = 'fog/aws'
    config.fog_credentials = {
      :provider               => 'AWS',
      :aws_access_key_id      => ENV['AWS_ACCESS_KEY_ID'],        # values from Heroku configs
      :aws_secret_access_key  => ENV['AWS_SECRET_ACCESS_KEY'],
      :region                 => ENV['S3_BUCKET_REGION'] #must match actual location of bucket. might want to make sure it also is the same as where servers are hosted - then transfer inbetween is free
    }
    config.fog_directory  = ENV['S3_BUCKET_NAME']
    config.asset_host     = "//#{ENV['ASSET_HOST']}"    # // mean use same protocol (http or https) as the original request
    config.fog_public     = true
    #config.fog_attributes = {'Cache-Control' => 'max-age=315576000'}
  elsif Rails.env.test?
    config.storage :file
    config.enable_processing = false
  else Rails.env.development?
    config.storage :file
  end
end

##enable setting of quality when resizing images with RMagick
#module CarrierWave
#  module RMagick
#    def quality percentage
#      manipulate! do |img|
#        img.write(current_path) { self.quality = percentage } unless img.quality == percentage
#        img = yield(img) if block_given?
#        img
#      end
#    end
#  end
#end
#
