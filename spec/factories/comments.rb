# encoding: utf-8

FactoryGirl.define do
  factory :comment do
    commenter 'user1'
    body '32자 이내'
  end

  factory :invalid_commenter, parent: :comment do
    commenter nil
  end

  factory :invalid_body, parent: :comment do
    body nil
  end

  factory :wrong_commenter, parent: :comment do
    commenter '!'
  end

  factory :wrong_body, parent: :comment do
    body '32자 이상, 32자 이상, 32자 이상, 32자 이상, 32자 이상'
  end
end
