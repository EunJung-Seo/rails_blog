# encoding: utf-8

FactoryGirl.define do
  factory :post do
    title 'title'
    content 'content'
    name 'user1'
  end

  factory :invalid_post_title, parent: :post do
    title nil
  end

  factory :short_post_title, parent: :post do
    title '5'
  end

  factory :invalid_post_name, parent: :post do
    name nil
  end
end
