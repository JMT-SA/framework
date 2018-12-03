require 'que'
Sequel.migration do
  up do
    Que.connection = self
    Que.migrate! :version => 4
  end
  down do
    Que.connection = self
    Que.migrate! :version => 0
  end
end
