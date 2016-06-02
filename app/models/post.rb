# encoding: utf-8
class Post < ActiveRecord::Base
  attr_accessible :content, :name, :title, :tags_attributes

  validates :name,  presence: true
  validates :title, presence: true,
                    length: { :minimum => 5, :maximum => 10 }
  validates :content,  presence: true
  validate :title_does_not_have_prohibited_word
  validate :content_should_have_specific_words

  has_many :comments, :dependent => :destroy
  has_many :tags

  accepts_nested_attributes_for :tags, :allow_destroy => :true,
    :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } }

  private

  def title_does_not_have_prohibited_word
    return if self.title.blank?
    matched_words = []

    prohibited_words = %w(post title 제목 포스트)
    prohibited_words.each do |word|
      if self.title.match(/#{word}/i)
        matched_words.push(word)
      end
    end

    if matched_words.present?
      errors.add(:title, "제목에 들어갈 수 없는 단어가 있습니다 : #{matched_words.join(', ')}")
    end
  end

  def content_has_specific_words
    return if self.content.blank?
    words = %w(어제 오늘 내일)
    matched_words = words.clone
    words.each do |word|
      if self.content.match(/#{word}/i)
        matched_words.delete(word)
      end
    end
    if matched_words.present?
      errors.add(:content, "내용에 빠진 단어가 있습니다 : #{matched_words.join(', ')}")
    end
  end
end
