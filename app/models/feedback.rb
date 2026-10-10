# A charity's internal feedback on a donation it received. Never shown to the donor.
class Feedback < ApplicationRecord
  belongs_to :offer

  # collection check boxes can post blanks or repeats
  normalizes :tags, with: ->(tags) { tags.compact_blank.uniq }

  validates :offer_id, uniqueness: true
  validate :tags_are_known
  validate :tags_or_comment_present

  # [[group, [tag, ...]], ...] in FeedbackTags order, for display
  def grouped_tags
    FeedbackTags::TAGS.select { |tag| tags.include?(tag[:slug].to_s) }
                      .group_by { |tag| tag[:group] }
  end

  private

  def tags_are_known
    unknown = tags - FeedbackTags.slugs
    errors.add(:tags, :inclusion) if unknown.any?
  end

  def tags_or_comment_present
    errors.add(:base, :tags_or_comment_required) if tags.empty? && comment.blank?
  end
end
