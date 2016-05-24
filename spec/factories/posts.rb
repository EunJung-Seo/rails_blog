# encoding: utf-8

FactoryGirl.define do
  factory :post do
    title 'title'
    content 'content'
    name 'user1'
  end

  factory :invalid_post, parent: :post do
    title nil
  end
end
