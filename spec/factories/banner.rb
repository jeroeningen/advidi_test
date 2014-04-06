FactoryGirl.define do
  factory :banner, :class => :banner do
    # Image set the same way as the images in the path 'db/fixtures/images'
    # This sequence assumes that the image is available
    sequence(:image) {|n| File.open("#{Dir.pwd}/db/fixtures/images/image_#{(n % 400) + 100}.png")}
    sequence(:weight) {|n| (n % 2) + 1}
  end
  factory :high_weighted_banner, :class => :banner do
    image "high_weighted_banner"
    weight 10
  end
end