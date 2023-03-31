class SecureIdentity < ApplicationRecord
  validates_presence_of :sid
  validates_presence_of :mod_name
  validates_presence_of :mod_id

  def locked?
    locked_at.present?
  end
end
