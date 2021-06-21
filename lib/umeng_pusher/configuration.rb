module UmengPusher
  class Configuration
    attr_accessor :ios_appkey, :ios_app_master_secret,
                  :android_appkey, :android_app_master_secret,
                  :production_mode

    def initialize
      @ios_appkey = ""
      @ios_app_master_secret = ""
      @android_appkey = ""
      @android_app_master_secret = ""
      @production_mode = "false"
    end
  end
end
