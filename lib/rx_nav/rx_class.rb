module RxNav
  class RxClass
    class << self
      # Public: Get all classes for each specified class type
      # Options:
      #   class_type - a string specifying class types
      def all_classes options = {}
        query = "/allClasses"
        query << "?classTypes=#{options[:class_types]}" if options[:class_types]
        data = get_response_hash(query)
        return nil if data.nil? ||
                      data[:rxclass_min_concept_list].nil?
        data[:rxclass_min_concept_list][:rxclass_min_concept].nil?

        concepts = data[:rxclass_min_concept_list][:rxclass_min_concept]
        concepts.map{ |c| RxClassMinConcept.new(c) }
      end

      # Public: Get the classes containing a specifed drug name as a member
      # Options:
      #   rela_source -  a source of drug-class relationships. See #relaSources
      #     for the list of sources of drug-class relations. If this field is
      #     omitted, all sources of drug-class relationships will be used.
      #   relas - a list of relationships of the drug to the class.
      def by_drug_name name, options = {}
        query = "/class/byDrugName?drugName=#{name}"

        params = options.select{ |o| %w(rela_source relas).include? o.to_s }
        query << params.map{ |k,v| "&#{camelize(k.to_s)}=#{v}"}.join("")
        data = get_response_hash(query)

        return nil if data.nil? ||
                      data[:rxclass_drug_info_list].nil? ||
                      data[:rxclass_drug_info_list][:rxclass_drug_info].nil?

        c = data[:rxclass_drug_info_list][:rxclass_drug_info]
        if c.is_a?(Hash) && !c[:rxclass_min_concept_item].nil?
          return RxNav::RxClassMinConcept.new(c[:rxclass_min_concept_item])
        end

        c.map{ |concept| RxNav::RxClassMinConcept.new(concept) }
      end

      # Public: Get the classes of a RxNorm drug identifier
      # Options:
      #   rela_source - a source of drug-class relationships. See #rela_sources
      #     for the list of sources of drug-class relations. If this field is
      #     omitted, all sources of drug-class relationships will be used.
      #
      #   relas - a list of relationships of the drug to the class.
      def by_rxcui rxcui, options = {}
        query = "/class/byRxcui?rxcui=#{rxcui}"

        params = options.select{ |o| %w(rela_source relas).include? o.to_s }
        query << params.map{ |k,v| "&#{camelize(k.to_s)}=#{v}"}.join("")
        data = get_response_hash(query)

        return nil if data.nil? ||
                      data[:rxclass_drug_info_list].nil? ||
                      data[:rxclass_drug_info_list][:rxclass_drug_info].nil?

        c = data[:rxclass_drug_info_list][:rxclass_drug_info]
        if c.is_a?(Hash) && !c[:rxclass_min_concept_item].nil?
          return RxNav::RxClassMinConcept.new(c[:rxclass_min_concept_item])
        end

        c.map{ |concept| RxNav::RxClassMinConcept.new(concept) }
      end

      # Public: Get the classid of a RxNorm drug class
      def by_classname drug_class, options = {}
        query = "/class/byName?className=#{drug_class}"

        params = options.select{ |o| %w(rela_source relas).include? o.to_s }
        query << params.map{ |k,v| "&#{camelize(k.to_s)}=#{v}"}.join("")
        data = get_response_hash(query)

        return nil if data.nil? ||
                      data[:rxclass_min_concept_list].nil? ||
                      data[:rxclass_min_concept_list][:rxclass_min_concept].nil?

        c = data[:rxclass_min_concept_list][:rxclass_min_concept]

      end


      # Public: Gets all drugs in the class
      def drugs_in_class drug_class_id, options = {}

        sources = ['ATC', 'DAILYMED', 'FDASPL', 'MESH', 'NDFRT']

        drugs = []

        sources.each do |source|

          query = "/classMembers?classId=#{drug_class_id}&relaSource=#{source}"

          params = options.select{ |o| %w(rela_source relas).include? o.to_s }
          query << params.map{ |k,v| "&#{camelize(k.to_s)}=#{v}"}.join("")
          data = get_response_hash(query)

          next if data.nil? ||
                  data[:drug_member_group].nil? ||
                  data[:drug_member_group][:drug_member].nil?

          c = data[:drug_member_group][:drug_member]

          c.each do |concept|
            drugs << concept[:min_concept][:name]
          end

        end

        return drugs

      end


      # Public: Get the list of sources that associate generic drugs to the
      #   class types
      def rela_sources
        data = get_response_hash("/relaSources")
        return nil if data.nil? ||
                      data[:rela_source_list].nil? ||
                      data[:rela_source_list][:rela_source_name].nil?
        data[:rela_source_list][:rela_source_name]
      end

      private

      def get_response_hash query
        RxNav.make_request("/rxclass" + query)[:rxclassdata]
      end

      # Internal: Camelize a snake case string
      def camelize(s)
        return nil if s.nil?
        return "" if s.empty?
        camelized = s.split("_").map(&:capitalize).join("")
        camelized[0] = s[0]
        camelized
      end
    end
  end
end
