class Card < ApplicationRecord
  class << self
    def truncate
      connection.execute "delete from cards;" #sqlite
    end
  end
end
