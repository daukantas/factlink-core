class Export
  def export
    output = ''

    User.all.each do |user|
      output << import('user', user, User.import_export_simple_fields + [
        :encrypted_password, :confirmed_at, :confirmation_token,
        :confirmation_sent_at, :updated_at
      ])

      user.social_accounts.each do |social_account|
        output << import('social_account', social_account,
          SocialAccount.import_export_simple_fields, 'username: ' + to_ruby(user.username))
      end
    end

    FactData.all.each do |fact_data|
      output << import('fact', fact_data, [
        :fact_id, :displaystring, :title, :site_url, :created_at
      ])
    end

    output
  end

  private

  def to_ruby(value)
    case value
    when Time
      return 'Time.parse(' + value.utc.iso8601.inspect + ')'
    when String, Integer, NilClass, TrueClass, FalseClass, Hash
      return value.inspect
    else
      fail "Unsupported type: " + value.class.name
    end
  end

  def hash_field_for(object, name)
    name.to_s + ': ' + to_ruby(object.public_send(name)) + ', '
  end

  def import(name, object, fields, additional_fields="")
    object_fields = fields.map { |name| hash_field_for(object, name) }.join('')
    "FactlinkImport.new.#{name}({#{object_fields}#{additional_fields}})\n"
  end
end
