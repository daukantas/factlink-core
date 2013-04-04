require_relative '../../app/ohm-models/many_to_many_timestamped_relation'

describe ManyToManyTimestampedRelation do

  let(:many_to_many_relation) { ManyToManyTimestampedRelation.new nest_key }

  let(:nest_key) do
    nest_key = mock
    nest_key.stub(:[]).with(:relation).and_return(mock)
    nest_key.stub(:[]).with(:reverse_relation).and_return(mock)
    nest_key
  end

  describe '.add_at_time' do
    it 'adds with a call to time_to_score' do
      from_id = mock
      to_id = mock
      time = mock
      score = mock

      many_to_many_relation.should_receive(:time_to_score).with(time).and_return(score)
      many_to_many_relation.should_receive(:add).with(from_id, to_id, score)

      many_to_many_relation.add_at_time(from_id, to_id, time)
    end
  end

  describe '.replace_at_time' do
    it 'adds with a call to time_to_score' do
      from_id = mock
      to_id = mock
      time = mock
      score = mock

      many_to_many_relation.should_receive(:time_to_score).with(time).and_return(score)
      many_to_many_relation.should_receive(:replace).with(from_id, to_id, score)

      many_to_many_relation.replace_at_time(from_id, to_id, time)
    end
  end

  describe '.add_now' do
    it 'adds with a call to time_to_score' do
      from_id = mock
      to_id = mock
      time = mock
      score = mock

      stub_const 'DateTime', Class.new
      DateTime.should_receive(:now).and_return(time)

      many_to_many_relation.should_receive(:time_to_score).with(time).and_return(score)
      many_to_many_relation.should_receive(:add).with(from_id, to_id, score)

      many_to_many_relation.add_now(from_id, to_id)
    end
  end

  describe '.replace_now' do
    it 'adds with a call to time_to_score' do
      from_id = mock
      to_id = mock
      time = mock
      score = mock

      stub_const 'DateTime', Class.new
      DateTime.should_receive(:now).and_return(time)

      many_to_many_relation.should_receive(:time_to_score).with(time).and_return(score)
      many_to_many_relation.should_receive(:replace).with(from_id, to_id, score)

      many_to_many_relation.replace_now(from_id, to_id)
    end
  end

end
