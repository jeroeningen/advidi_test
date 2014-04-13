# Helper to determine wheter we're on Heroku
def heroku?
  $environment == :production
end