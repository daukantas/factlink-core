require 'ohm/contrib'

require_relative 'activity/subject'
require_relative 'activity/listener'
require_relative 'activity/create_listeners'
require_relative 'activity/query'

class Activity < OurOhm
  include Ohm::Timestamping
  reference :user, GraphUser

  alias :old_set_user :user= unless method_defined?(:old_set_user)
  def user=(new_user)
    old_set_user new_user.graph_user
  end

  after :create, :process_activity
  def process_activity
    Resque.enqueue(ProcessActivity, self.id)
  end


  generic_reference :subject
  generic_reference :object

  attribute :action
  index     :action

  def self.for(search_for)
    Activity::Query.for(search_for)
  end

  def to_hash_without_time
    h = { user: user,
          action: action.to_sym,
          subject: subject, }
    h[:object] = object if object
    h
  end

end

