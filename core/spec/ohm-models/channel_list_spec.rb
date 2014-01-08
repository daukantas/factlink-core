require 'spec_helper'

describe ChannelList do
  include PavlovSupport

  describe ".channels" do
    before do
      @graph_user = create :graph_user
    end
    describe "initially" do
      it "contains only the expected channels" do
        ChannelList.new(@graph_user).channels.to_a.should =~ []
      end
    end
    describe "after creating a channel" do
      it "contains the channel and the expected channels" do
        ch1 = Channel.create created_by: @graph_user, title: 'foo'
        ChannelList.new(@graph_user).channels.to_a.should =~ [ch1]
      end
    end
    describe "after creating two channels" do
      it "contains the two channels and the expected channels" do
        ch1 = Channel.create created_by: @graph_user, title: 'foo'
        ch2 = Channel.create created_by: @graph_user, title: 'foo2'
        ChannelList.new(@graph_user).channels.to_a.should =~ [ch1,ch2]
      end
    end
    describe "after creating two channels and deleting the first" do
      it "should contain the second channel and the expected channels" do
        ch1 = Channel.create created_by: @graph_user, title: 'foo'
        ch2 = Channel.create created_by: @graph_user, title: 'foo2'
        ch1.delete
        ChannelList.new(@graph_user).channels.to_a.should =~ [ch2]
      end
    end
    describe "after creating a channel, and someone else creates a channel" do
      it "only contains our channel, and the expected channels" do
        ch1 = Channel.create created_by: @graph_user, title: 'foo'
        ch2 = Channel.create created_by: (create :graph_user), title: 'foo2'

        ChannelList.new(@graph_user).channels.to_a.should =~ [ch1]
      end
    end
  end

  describe ".sorted_channels" do
    it "should return the channels" do
      gu1 = create :graph_user
      ch1 = create :channel, created_by: gu1, title: 'a'
      ch2 = create :channel, created_by: gu1, title: 'b'
      ch3 = create :channel, created_by: gu1, title: 'c'

      list = ChannelList.new(gu1)

      expect(list.sorted_channels.map(&:title)).
        to eq ['a', 'b', 'c']
    end
  end
end
