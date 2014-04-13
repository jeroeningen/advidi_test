class ImageUploader < CarrierWave::Uploader::Base
  # Use Fog on Heroku
  storage (heroku? ? :fog : :file)
end