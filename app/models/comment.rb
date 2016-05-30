class Comment < ActiveRecord::Base
  belongs_to :post

  validates :commenter, presence: true,
                        format: { with: /\A[a-zA-Z]+\z/, message: 'only allows letters'}
  validates :body, presence: true, length: { :maximum => 32 }
end
