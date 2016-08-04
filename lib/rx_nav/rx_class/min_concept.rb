require "ostruct"

module RxNav
  module RxClass
    class MinConcept < OpenStruct
      def id
        class_id
      end

      def name
        class_name
      end

      def type
        class_type
      end
    end
  end
end
