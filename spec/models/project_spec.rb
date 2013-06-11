require 'spec_helper'

describe Project do
  it { should_not have_valid(:name).when(nil) }
  it { should_not have_valid(:user_ids).when(nil) }
  it { should have_many(:users).through(:memberships) }
end
