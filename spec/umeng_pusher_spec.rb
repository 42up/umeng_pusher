require "pry"

RSpec.describe UmengPusher do
  it "has a version number" do
    expect(UmengPusher::VERSION).not_to be nil
  end

  describe "a specification" do
    before do
      @ios_appkey = "test_ios_appkey"
      @ios_app_master_secret = "test_ios_app_master_secret"
      @android_appkey = "test_android_appkey"
      @android_app_master_secret = "test_android_app_master_secret"
      @production_mode = "false"

      UmengPusher.configure do |config|
        config.ios_appkey = @ios_appkey
        config.ios_app_master_secret = @ios_app_master_secret
        config.android_appkey = @android_appkey
        config.android_app_master_secret = @android_app_master_secret
        config.production_mode = "false"
      end
    end

    it "config should be ok" do
      expect(UmengPusher.appkey("ios")).to eq(@ios_appkey)
      expect(UmengPusher.app_master_secret("ios")).to eq(@ios_app_master_secret)

      expect(UmengPusher.appkey("android")).to eq(@android_appkey)
      expect(UmengPusher.app_master_secret("android")).to eq(@android_app_master_secret)

      expect(UmengPusher.production_mode).to eq(@production_mode)
    end

    it "invalid task id" do
      options = { task_id: "task_not_exist" }
      ret = UmengPusher::Client.new('ios', options).status

      expect(ret[:error_code]).to eq(1014)
    end

    it "valid task id" do
      # 只对任务类型有效
      options = { task_id: "um3qfjp162425040000011" }
      ret = UmengPusher::Client.new('ios', options).status

      expect(ret[:error_code]).to eq(0)
    end

    it "unicast" do
      options = {
        type: "unicast",
        device_tokens: "170d7aa57be36652a99294b509dd6119f9d904dd61a316ddecbe028bc04c5b42",
        alert: "foo 🥣",
        extra: {
          scheme_url: "judou://detail?type=sentence&id=7ca577ca-690f-48eb-8383-add833fd82fe",
          message_id: -1
        }
      }
      ret = UmengPusher::Client.new('ios', options).send

      expect(ret[:error_code]).to eq(0)
    end

    it "broadcast" do
      options = {
        type: "broadcast",
        alert: "晚安 🌜",
        # extra: {
        #   scheme_url: "judou://detail?type=sentence&id=7ca577ca-690f-48eb-8383-add833fd82fe",
        #   message_id: -1
        # }
      }
      ret = UmengPusher::Client.new('ios', options).send

      expect(ret[:error_code]).to eq(0)
    end
  end
end
