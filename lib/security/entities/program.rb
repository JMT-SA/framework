class Program < Dry::Struct
  attribute :id, Types::Int
  attribute :program_name, Types::String  
  attribute :functional_area_id, Types::Int
  attribute :active, Types::Bool
end
__END__
  program_name character varying(255) NOT NULL,
  active boolean DEFAULT true,
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL,
  functional_area_id integer NOT NULL,
