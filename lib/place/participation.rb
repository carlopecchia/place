module Place


class Participation < Ohm::Model
  set :roles

  reference :user, User
  reference :project, Project
end


end