module Pavlov
  module SmartInit
    extend ActiveSupport::Concern
    module ClassMethods
      # arguments :foo, :bar
      #
      # results in
      #
      # def initialize(foo, bar)
      #   @foo = foo
      #   @bar = bar
      # end
      def arguments *keys
        define_method :initialize do |*names|
          (keys.zip names).each do |pair|
            name = "@" + pair[0].to_s
            value = pair[1]
            instance_variable_set(name, value)
          end
        end
      end
    end
  end
end