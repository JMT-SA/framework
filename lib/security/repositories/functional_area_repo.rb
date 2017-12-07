class FunctionalAreaRepo < RepoBase
  crud_calls_for :functional_areas, name: :functional_area, wrapper: FunctionalArea
end
