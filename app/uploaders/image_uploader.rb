class ImageUploader < CarrierWave::Uploader::Base
  # Use Fog on Heroku
  storage ($environment == :production ? :fog : :file)
end