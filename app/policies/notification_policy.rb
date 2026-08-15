class NotificationPolicy < ApplicationPolicy
  def dismiss?
    record.recipient == user.donor || record.recipient == user.charity
  end
end
