campaign_with_banners, updated_banners, two_banners, high_weighted_banners = [], [], [], []
400.times do
  campaign_with_banners << FactoryGirl.build(:banner)
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
  factory :random_requests_campaign, :class => :campaign do
    name "random_requests_campaign"
    random_ratio 100
  end
  factory :weighted_requests_campaign, :class => :campaign do
    name "weighted_requests_campaign"
    random_ratio 0
  end
  factory :campaign_with_banners, :class => :campaign do
    name "campaign_with_banners"
    random_ratio 100
    banners campaign_with_banners
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
end