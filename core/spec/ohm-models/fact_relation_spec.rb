require 'spec_helper'
require_relative 'believable_shared'

describe FactRelation do
  it_behaves_like 'a believable object'
  subject {create(:fact_relation)}

  let(:gu) {create(:active_user).graph_user}
  let(:gu2) {create(:active_user).graph_user}

  let(:evidence) {create :fact}
  let(:parent) {create :fact}

  let(:fact1) {create :fact}
  let(:fact2) {create :fact}

  describe "#get_or_create" do
    it "should return a new factrelation when the relation does not exist" do
      fr = FactRelation.get_or_create(fact1, :supporting, fact2, gu)
      fr.should be_a(FactRelation)
      fr.should_not be_new
    end


    [:supporting, :weakening, 'supporting','weakening'].each do |type|
      it "should return a new factrelation when the relation does not exist" do
        fr = FactRelation.new type: type,
                              fact: fact1,
                              from_fact: fact2,
                              created_by: gu
        fr.save
        fr.should_not be_new
      end
    end

    it "should return a new factrelation when the relation does not exist" do
      fr = FactRelation.new type: :retroverting,
                            fact: fact1,
                            from_fact: fact2,
                            created_by: gu
      fr.save
      fr.should be_new
    end

    it "should have a created_by GraphUser when created" do
      fr = FactRelation.get_or_create(evidence, :supporting, parent, gu)
      fr.created_by.should be_a(GraphUser)
    end

    it "should find the relation when the relation does exist" do
      fr = FactRelation.get_or_create(fact1,:supporting,fact2,gu)
      fr.should be_a(FactRelation)
      fr2 = FactRelation.get_or_create(fact1,:supporting,fact2,gu)
      fr2.should be_a(FactRelation)
      fr3 = FactRelation.get_or_create(fact1,:supporting,fact2,gu)
      fr3.should be_a(FactRelation)
      expect(fr).to eq fr2
      expect(fr2).to eq fr3
    end
  end

  it "should add itself to the list of evidence" do
    FactRelation.get_or_create(fact1,:supporting,fact2,gu)
    fact2.evidence(:supporting).to_a.collect{ |x| x.from_fact }.should =~ [fact1]
  end

  it "should delete itself from lists referring to it" do
    FactRelation.get_or_create(fact1,:supporting,fact2,gu)
    fact1.delete
    expect(fact2.evidence(:supporting).size).to eq 0
  end

  it "should not be able to create identical factRelations" do
    FactRelation.get_or_create(fact1,:supporting,fact2,gu)
    FactRelation.get_or_create(fact1,:supporting,fact2,gu)
    expect(FactRelation.all.size).to eq 1
    FactRelation.get_or_create(fact2,:supporting,fact1,gu)
    FactRelation.get_or_create(fact2,:supporting,fact1,gu)
    expect(FactRelation.all.size).to eq 2
  end

  describe :deletable? do
    include PavlovSupport
    let(:fr) {FactRelation.get_or_create(fact1,:supporting,fact2,gu)}

    it "should be true initially" do
      fr.deletable?.should be_true
    end
    it "should be true if only the creator believes it" do
      fr.add_opiniated(:believes, gu)
      fr.deletable?.should be_true
    end
    it "should be false after someone else believes the relation" do
      fr.add_opiniated(:believes, gu2)
      fr.deletable?.should be_false
    end
    it "should be true if only the creator believes it" do
      fr.add_opiniated(:disbelieves, gu2)
      fr.deletable?.should be_true
    end
    it "should be true if only the creator believes it" do
      fr.add_opiniated(:doubts, gu2)
      fr.deletable?.should be_true
    end
    it "should be false after someone comments on it" do
      as(fr.created_by.user) do |pavlov|
        pavlov.interactor(:'sub_comments/create_for_fact_relation', fact_relation_id: fr.id.to_i, content: 'hoi')
      end

      fr.deletable?.should be_false
    end
  end

end
