require "ostruct"

module RxNav
  class RxClassMinConcept < OpenStruct
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
