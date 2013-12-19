require 'spec_helper'

describe Users::SetupController do
  let(:user) { create(:user, set_up: false) }
  render_views

  describe :edit do
    it "renders the edit page when authenticated" do
      sign_in user

      should_check_can :set_up, user

      get :edit

      expect(response).to be_success
    end
  end

  describe :update do
    it 'updates full name' do
      sign_in user

      expect(user.set_up).to be_false

      post :update, user: {full_name: 'full_name'}

      user.reload
      expect(user.full_name).to eq 'full_name'
      expect(user.set_up).to be_true
    end
  end
end
