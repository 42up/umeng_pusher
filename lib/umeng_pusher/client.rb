require "httpx"
require "json"
require "active_support"

module UmengPusher
  class Client
    attr_reader :payload, :ret, :task_id, :error_code, :file_id, :platform, :content
    CAST_TYPE = %w|unicast listcast filecast broadcast groupcast customizedcast|
    SEND_URL = "http://msg.umeng.com/api/send"
    STATUS_URL = "http://msg.umeng.com/api/status"
    CANCEL_URL = "http://msg.umeng.com/api/cancel"
    UPLOAD_URL = "http://msg.umeng.com/upload"

    def initialize(platform, options, debug_mode = true)
      @platform = platform
      @options = options
      @debug_mode = debug_mode
    end

    # unicast-单播
    # listcast-列播，要求不超过500个device_token
    # broadcast-广播
    # filecast-文件播，多个device_token可通过文件形式批量发送
    # groupcast-组播，按照filter筛选用户群,请参照filter参数
    # customizedcast，通过alias进行推送，包括以下两种case:
    #   -alias:对单个或者多个alias进行推送
    #   -file_id:将alias存放到文件后，根据file_id来推送
    def send
      post(SEND_URL, Params.send_params(@platform, @options))
    end

    def status
      post(STATUS_URL, Params.status_params(@platform, @options[:task_id]))
    end

    def cancel
      post(CANCEL_URL, Params.cancel_params(@platform, @options[:task_id]))
    end

    def upload
      post(UPLOAD_URL, Params.upload_params(@platform, @options))
    end

    private

    def post(url, payload)
      sign = Sign.generate @platform, url, payload

      puts payload.to_json if @debug_mode

      resp = HTTPX.post("#{url}?sign=#{sign}", json: payload)

      if resp.status == 200
        r = JSON.parse(resp.body)
        { message: r["ret"], error_code: r["data"]["error_code"] || 0, data: r["data"] }
      elsif resp.status == 400
        r = JSON.parse(resp.body)
        { message: r["data"]["error_msg"], error_code: r["data"]["error_code"], data: r["data"] }
      else
        { message: "系统错误", error_code: "999", data: {} }
      end
    end
  end
end
