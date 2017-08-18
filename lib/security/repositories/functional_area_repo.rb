class FunctionalAreaRepo < RepoBase
  def initialize
    set_main_table :functional_areas
    set_wrapper FunctionalArea
  end
end
