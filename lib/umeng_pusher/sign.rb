require "digest/md5"

module UmengPusher
  class Sign
    def self.generate(platform, url, payload)
      Digest::MD5.hexdigest("POST" + url + payload.to_json + UmengPusher.app_master_secret(platform))
    end
  end
end
