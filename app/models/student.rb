class Student < ActiveRecord::Base
  belongs_to :group

  def full_name
    first = nick_name.blank? ? first_name : nick_name
    "#{first} #{last_name}"
  end
end
