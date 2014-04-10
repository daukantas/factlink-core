class MoveNotificationSettingsToUser < Mongoid::Migration
  def self.up
    User.all.each do |user|
      if user['user_notification'].nil?
        Backend::Notifications.reset_edit_token(user: user)
      else
        user['notification_settings_edit_token'] ||=
          user['user_notification']['notification_settings_edit_token']
      end
      ok=false
      begin
        user.save!
        ok=true
      ensure
        if !ok
          puts user.to_json
        end
      end
    end
  end

  def self.down
  end
end
