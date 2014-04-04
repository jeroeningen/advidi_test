FactoryGirl.define do
  factory :banner, :class => :banner do
    # Image set the same way as the images in the path 'db/fixtures/images'
    sequence(:image_file_name) {|n| "image_#{n + 100}.png"}
    image_content_type "image/png"
    sequence(:weight) {|n| (n % 2) + 1}
  end
  factory :high_weighted_banner, :class => :banner do
    image_file_name "high_weighted_banner"
    weight 10
  end
end