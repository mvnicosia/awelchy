preload_app!
rackup "config/config.ru"
port ENV['PORT']
log_requests
