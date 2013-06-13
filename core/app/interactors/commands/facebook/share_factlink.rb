require 'pavlov'

module Commands
  module Facebook
    class ShareFactlink
      include Pavlov::Command

      arguments :message, :fact_id

      private

      def execute
        client.put_connections("me",
                "factlinkdevelopment:share",
                factlink: fact.url)
      end

      def token
        @options[:current_user].identities['facebook']['credentials']['token']
      end

      def fact
        @fact ||= query :'facts/get_dead', @fact_id
      end

      def client
        ::Koala::Facebook::API.new(token)
      end

      def validate
        validate_nonempty_string :message, message
        validate_integer_string :fact_id, fact_id
      end
    end
  end
end
