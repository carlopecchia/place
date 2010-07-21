module Place

class Link < Ohm::Model
  attribute :role
  index :role
  attribute :suspect
  attribute :revision
  
  reference :from, WorkItem
  reference :to, WorkItem
  
  # added only for performance needs
  attribute :from_wid
  index :from_wid
  attribute :to_wid
  index :to_wid
end

end

