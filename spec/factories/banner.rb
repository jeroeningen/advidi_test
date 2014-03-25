FactoryGirl.define do
  factory :banner, :class => :banner do
    sequence(:banner_file_name) {|n| "banner_#{n}"}
    sequence(:weight) {|n| (n % 2) + 1}
  end
  factory :high_weighted_banner, :class => :banner do
    banner_file_name "high_weighted_banner"
    weight 10
  end
end