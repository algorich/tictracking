require 'spec_helper'

describe Project do
  it { should_not have_valid(:name).when(nil) }  
end
