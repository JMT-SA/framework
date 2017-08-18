class FunctionalArea < Dry::Struct
  attribute :id, Types::Int
  attribute :functional_area_name, Types::String  
  attribute :active, Types::Bool
end
__END__
  id integer NOT NULL DEFAULT nextval('functional_areas_id_seq'::regclass),
  functional_area_name character varying(255) NOT NULL,
  active boolean DEFAULT true,
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL,<Paste>
