class FunctionalAreaRepo < RepoBase
  def initialize
    main_table :functional_areas
    table_wrapper FunctionalArea
  end
end
