require "spec_helper"
require "support/api"
require "support/array_type"

describe "https://rxnav.nlm.nih.gov/REST/rxclass" do
  before :all do
    @url      = URI "https://rxnav.nlm.nih.gov/REST/rxclass/json"
    @response = Net::HTTP.get(@url)
    @json     = JSON.parse(@response)
  end

  it "should be online" do
    expect(@json).to_not be_empty
  end
end

describe RxNav::RxClass do
  describe "remote endpoints" do
    url = "http://rxnav.nlm.nih.gov/REST/rxclass"
    response = Net::HTTP.get(URI("#{url}/json"))
    subject { JSON.parse(response)["resourceList"]["resource"] }

    include_examples 'uses valid endpoints', %W(
      #{url}/allClasses?classTypes={classTypes}
      #{url}/class/byRxcui?rxcui={rxcui}&relaSource={relaSource}&relas={relas}
      #{url}/class/byDrugName?drugName={drugName}&relaSource={relaSource}&relas={relas}
      #{url}/relaSources
    )
  end

  describe "#all_classes" do
    subject { RxNav::RxClass.all_classes class_types: "MOA" }

    include_examples 'should be an array of', RxNav::RxClassMinConcept
  end

  describe "#by_drug_name" do
    context "with no options" do
      subject { RxNav::RxClass.by_drug_name "Ibuprofen" }
      include_examples 'should be an array of', RxNav::RxClassMinConcept
    end

    context "with multiple results" do
      subject { RxNav::RxClass.by_drug_name "Ibuprofen",
                                            rela_source: "DAILYMED" }
      include_examples 'should be an array of', RxNav::RxClassMinConcept
    end

    context "with single result" do
      subject { RxNav::RxClass.by_drug_name "Ibuprofen",
                                            rela_source: "DAILYMED",
                                            relas: "has_EPC" }
      it { is_expected.to be_a(RxNav::RxClassMinConcept) }
    end
  end

  describe "#by_rxcui" do
    context "with no options" do
      subject { RxNav::RxClass.by_rxcui 7052 }
      include_examples 'should be an array of', RxNav::RxClassMinConcept
    end

    context "with multiple results" do
      subject { RxNav::RxClass.by_rxcui 7052, rela_source: "DAILYMED" }
      include_examples 'should be an array of', RxNav::RxClassMinConcept
    end

    context "with single result" do
      subject do
        RxNav::RxClass.by_rxcui 7052, rela_source: "DAILYMED", relas: "has_EPC"
      end

      it { is_expected.to be_a(RxNav::RxClassMinConcept) }
    end
  end

  describe "#rela_sources" do
    subject { RxNav::RxClass.rela_sources }

    include_examples "should be an array of", String
    it { is_expected.to include("ATC") }
  end
end
