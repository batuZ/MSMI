require_relative 'boot'

require 'rails/all'
require 'aliyun/oss'
require 'aliyun/sts'
require 'net-http2'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MSMI
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # WS:来源过滤
    config.action_cable.disable_request_forgery_protection = true

    # 管理员用来签名的密钥
    config.x.m_key = IO.readlines('./config/keys/manager_key').first
  end
end

module Rails
  # 判断当前运行环境
  def self.t?; Rails.env.eql?('test'); end
  def self.p?; Rails.env.eql?('production'); end
  def self.d?; Rails.env.eql?('development'); end

  # Rails.application.credentials.config[][]代理
  def self.secrets
    Rails.application.credentials.config
  end
end