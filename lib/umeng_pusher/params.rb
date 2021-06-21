require "securerandom"

module UmengPusher
  module Params
    extend self

    def send_params(platform, options)

      params = {
        "appkey" => UmengPusher.appkey(platform),
        "timestamp" => Time.now.to_i.to_s,
        "type" => options[:type],
        "device_tokens" => options[:device_tokens],
        "alias_type" => options[:alias_type], # 当type=customizedcast时,必填
        "alias" => options[:alias], #当type=customizedcast时,选填(此参数和file_id二选一)
        "file_id" => options[:file_id], # 当type=filecast时，必填
        "policy" => { # 可选，定时任务策略
          "start_time" => options[:start_time],
          "expire_time" => options[:expire_time],
          "max_send_num" => options[:max_send_num],
          "out_biz_no" => options[:out_biz_no], # 强烈建议开发者在发送任务类消息时填写这个字段，友盟服务端会根据这个字段对消息做去重避免重复发送、根据业务推送内容填写，out_biz_no只对任务类消息有效
        },
        "production_mode" => UmengPusher.production_mode,
        "description" => options[:description], # 可选，发送消息描述，建议填写
      }

      ios_payload = {
        "payload" => {
          "aps" => {
            "alert" => options[:alert],
            "badge" => options[:badge] || 1,
            "sound" => options[:sound] || "default",
            "content-available" => options["content-available".to_sym],
            "category" => options[:category],
          },
        },
      }

      # body为业务自定义字段
      ios_payload["payload"]["body"] = options[:extra] if options.has_key?(:extra)

      android_payload = {
        "payload" => {
          "display_type" => options[:display_type],
          "body" => {
            "ticker" => options[:ticker],
            "title" => options[:title],
            "text" => options[:text],
            "icon" => options[:icon],
            "largeIcon" => options[:largeIcon],
            "img" => options[:img],
            "sound" => options[:sound],
            "builder_id" => (options[:builder_id] || 0),
            "play_vibrate" => (options[:play_vibrate] || "true"),
            "play_lights" => (options[:play_lights] || "true"),
            "play_sound" => (options[:play_sound] || "true"),
            "after_open" => (options[:after_open] || "go_app"),
            "url" => options[:url],
            "activity" => options[:activity],
            "custom" => options[:custom],
          },
          "extra" => options[:extra] || {},
        },
      }

      platform.downcase == "ios" ? params.merge!(ios_payload) : params.merge!(android_payload)
      compact_params(params)
    end

    def status_params(platform, task_id)
      {
        "appkey" => UmengPusher.appkey(platform),
        "timestamp" => Time.now.to_i.to_s,
        "task_id" => task_id,
      }
    end

    def cancel_params(platform, task_id)
      {
        "appkey" => UmengPusher.appkey(platform),
        "timestamp" => Time.now.to_i.to_s,
        "task_id" => task_id,
      }
    end

    def upload_params(platform, content)
      {
        "appkey" => UmengPusher.appkey(platform),
        "timestamp" => Time.now.to_i.to_s,
        "content" => content,
      }
    end

    private

    def compact_params(params)
      custom_compact = Proc.new { |k, v| v.delete_if(&custom_compact) if v.kind_of?(Hash); v.blank? }
      params.delete_if &custom_compact
    end
  end
end
