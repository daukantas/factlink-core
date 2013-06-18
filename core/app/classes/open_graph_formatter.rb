class OpenGraphFormatter
  def add graph_object
    rules.merge! graph_object.to_hash
  end

  def to_hash
    rules
  end

  private

  def rules
    @rules ||= {
      'fb:app_id' => FactlinkUI::Application.config.omniauth_conf['facebook']['id'],
      'og:image'  => 'http://cdn.factlink.com/1/avatar.png'
    }
  end
end
