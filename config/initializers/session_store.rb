# Be sure to restart your server when you modify this file.

AdvidiTest::Application.config.session_store :cookie_store, key: '_advidi_test_session'

# AdvidiTest::Application.config.session_store :redis_session_store, {
#   key: '_advidi_test_session',
#   redis: {
#     db: 2,
#     expire_after: 120.minutes,
#     key_prefix: 'advidi_test:session:',
#     host: 'localhost', # Redis host name, default is localhost
#     port: 6379   # Redis port, default is 6379
#   }
# }
