# -*- encoding : utf-8 -*-
class Comment < ActiveRecord::Base
  belongs_to :post

  validates :commenter, presence: true,
                        format: { with: /\A\w+\z/, message: '특수문자는 사용할 수 없습니다.'}
  validates :body, presence: true, length: { :maximum => 32 }
end
