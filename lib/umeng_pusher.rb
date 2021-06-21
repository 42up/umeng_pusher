require "umeng_pusher/version"
require "umeng_pusher/configuration"
require "umeng_pusher/sign"
require "umeng_pusher/client"
require "umeng_pusher/params"

module UmengPusher
  class Error < StandardError; end

  def self.configuration
    @configuration ||= Configuration.new
  end

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def appkey(platform)
      platform.downcase == 'ios' ? configuration.ios_appkey : configuration.android_appkey
    end

    def app_master_secret(platform)
      platform.downcase == 'ios' ? configuration.ios_app_master_secret : configuration.android_app_master_secret
    end

    def production_mode
      configuration.production_mode
    end
  end
end
