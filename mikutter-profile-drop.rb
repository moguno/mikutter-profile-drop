require File.join(CHIConfig::PLUGIN_PATH, "change_account", "interactive")

Plugin.create(:mikutter_profile_drop) {
  command(:profile_drop,
          name: _('プロフィールドロップ'),
          condition: Plugin::Command[:HasOneMessage],
          visible: true,
          role: :timeline) do |opt|

    user = opt.messages.first.user

    Service.primary.friendship(target_id: user[:id], source_id: Service.primary.user_obj[:id]).next{ |rel|
      msg_str = [] 

      msg_str << "（これはプロフィールです）"
      msg_str << ""
      msg_str << "#{user[:description]}"

      if opt.messages.first.user[:url]
        msg_str << ""
        msg_str << "#{opt.messages.first.user[:url]}"
      end

      new_msg = Message.new(:message => msg_str.join("\n"), :system => true)
      new_msg[:user] = opt.messages.first.user

      new_msg[:confirm] = rel[:following]?["あんふぉろー"]:["ふぉろー"]
      new_msg[:confirm_callback] = lambda { |button| 
        if rel[:following]
          Service.primary.unfollow(user_id: user[:id])
        else
          Service.primary.follow(user_id: user[:id])
        end
      }

      opt.widget << new_msg
    }
  end
}
