class User < ApplicationRecord
  # hack until we fully remove company,
  # prevents a validation error when saving a user without a company
  belongs_to :company # , optional: true

  validates \
    :first_name,
    :last_name,
    :email,
    presence: true

  validates \
    :email,
    uniqueness: {
      case_insensitive: true
    }

  def active?
    archived_at.blank?
  end

  def archived?
    archived_at.present?
  end

  def archive!
    write_attribute(:archived_at, Time.now)
    # TODO  remove validate clause after we delete company table
    save(validate: false)
  end

  def unarchived?
    archived_at.blank?
  end

  def unarchive!
    write_attribute(:archived_at, nil)
    # TODO  remove validate clause after we delete company table
    save(validate: false)
  end
end
