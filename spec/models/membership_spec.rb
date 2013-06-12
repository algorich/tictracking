require 'spec_helper'

describe Membership do

  it 'should have false by default for admin' do
    expect(Membership.create!.admin).to eq(false)
  end

  describe '#toggle_admin!' do
    it 'should toggle the admin' do
      membership = create(:membership, admin: false)

      expect(membership.admin).to be_false
      membership.toggle_admin!
      expect(membership.reload.admin).to be_true
    end
  end
end
