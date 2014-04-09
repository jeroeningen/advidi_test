require 'spec_helper'

describe Banner do
  it {should belong_to :campaign}
  
  # Validates weight; must be greater then 0
  it {should_not allow_value(0).for(:weight)}
  it {should allow_value(1).for(:weight)}
end
