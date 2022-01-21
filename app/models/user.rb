class User < ApplicationRecord
  validates :firebase_uid, uniqueness: true
end
