require 'spec_helper'

describe "jobs/index" do
  before do
    assign(:jobs, [
      stub_model(Job,
        :title => "Title",
        :content => "MyText"
      ),
      stub_model(Job,
        :title => "Title",
        :content => "MyText"
      )
    ])
  end

  it "renders a list of jobs" do
    render
  end
end
