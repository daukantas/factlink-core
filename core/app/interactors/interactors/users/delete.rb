module Interactors
  module Users
    class Delete
      include Pavlov::Interactor
      include Util::CanCan

      arguments :user_id

      def authorized?
        can? :delete, user
      end

      def user
        @user ||= User.find user_id
      end

      def validate
        validate_hexadecimal_string :user_id, user_id
      end

      def execute
        command :'users/mark_as_deleted', user: user
      end
    end
  end
end
