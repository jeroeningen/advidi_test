campaign_with_banners, campaign_with_banners2, campaign_with_banners3, campaign_with_banners4 = [], [], [], []
second_campaign_with_banners, updated_banners, two_banners, high_weighted_banners = [], [], [], []
400.times do
  campaign_with_banners << FactoryGirl.build(:banner)
end
400.times do
  campaign_with_banners2 << FactoryGirl.build(:banner)
end
400.times do
  campaign_with_banners3 << FactoryGirl.build(:banner)
end
400.times do
  campaign_with_banners4 << FactoryGirl.build(:banner)
end
400.times do
  second_campaign_with_banners << FactoryGirl.build(:banner)
end
400.times do
  updated_banners << FactoryGirl.build(:banner)
end
2.times do
  two_banners << FactoryGirl.build(:banner)
end
high_weighted_banners << FactoryGirl.build(:banner)
high_weighted_banners << FactoryGirl.build(:high_weighted_banner)


FactoryGirl.define do
  factory :mixed_requests_campaign, :class => :campaign do
    name "mixed_requests_campaign"
    random_ratio 35
  end
  factory :other_mixed_requests_campaign, :class => :campaign do
    name "other_mixed_requests_campaign"
    random_ratio 66
  end
  factory :random_requests_campaign, :class => :campaign do
    name "random_requests_campaign"
    random_ratio 100
  end
  factory :weighted_requests_campaign, :class => :campaign do
    name "weighted_requests_campaign"
    random_ratio 0
  end
  #duplicated factories made to overcome that test will fail
  factory :campaign_with_banners, :class => :campaign do
    name "campaign_with_banners"
    random_ratio 100
    banners campaign_with_banners
  end
  factory :campaign_with_banners2, :class => :campaign do
    name "campaign_with_banners2"
    random_ratio 100
    banners campaign_with_banners2
  end
  factory :campaign_with_banners3, :class => :campaign do
    name "campaign_with_banners3"
    random_ratio 100
    banners campaign_with_banners3
  end
  factory :campaign_with_banners4, :class => :campaign do
    name "campaign_with_banners4"
    random_ratio 100
    banners campaign_with_banners4
  end
  factory :campaign_with_two_banners, :class => :campaign do
    name "campaign_with_two_banners"
    random_ratio 100
    banners two_banners
  end
  factory :second_campaign_with_banners, :class => :campaign do
    name "second_campaign_with_banners"
    random_ratio 100
    banners second_campaign_with_banners
  end
  factory :update_campaign, :class => :campaign do
    name "updated_campaign"
    random_ratio 100
    banners updated_banners
  end
  factory :weighted_requests_campaign_with_banners, :class => :campaign do
    name "weighted_requests_campaign_with_banners"
    random_ratio 0
    banners high_weighted_banners
  end
  factory :redis_raketask_campaign, :class => :campaign do
    name "redis_raketask_campaign"
    random_ratio 10
    banners [FactoryGirl.build(:banner)]
  end
end