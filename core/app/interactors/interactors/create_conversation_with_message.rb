require_relative '../util/mixpanel'

module Interactors
  class CreateConversationWithMessage
    include Pavlov::Interactor
    include Util::Validations
    include Util::Mixpanel

    arguments :fact_id, :recipient_usernames, :sender_id, :content

    def execute
      conversation = command(:'create_conversation',
                                fact_id: fact_id, recipient_usernames: recipient_usernames)

      begin
        command(:'create_message',
                    sender_id: sender_id, content: content, conversation: conversation)
      rescue
        conversation.delete # TODO: replace this with a rollback of the create command
        raise
      end

      sender = User.find(sender_id)
      command(:'create_activity',
                  graph_user: sender.graph_user, action: :created_conversation,
                  subject: conversation, object: nil)

      track_mixpanel

      conversation
    end

    def validate
      validate_non_empty_list :recipient_usernames, recipient_usernames
      unless content.strip.length > 0
        errors.add :content, 'cannot be empty'
      end
      unless content.length <= 5000
        errors.add :content, 'cannot be longer than 5000 characters.'
      end
    end

    def track_mixpanel
      mp_track "Factlink: Created conversation",
        recipients: recipient_usernames,
        fact_id: fact_id
      mp_increment_person_property :conversations_created
    end

    def authorized?
      #relay authorization to commands, only require a user to check
      pavlov_options[:current_user].id.to_s == sender_id.to_s
    end
  end
end
