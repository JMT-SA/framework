class ProgramFunction < Dry::Struct
  attribute :id, Types::Int
  attribute :program_id, Types::Int
  attribute :program_function_name, Types::String  
  attribute :group_name, Types::String  
  attribute :url, Types::String  
  attribute :program_function_sequence, Types::Int
  attribute :restricted_user_access, Types::Bool
  attribute :active, Types::Bool
end
__END__
id integer NOT NULL DEFAULT nextval('program_functions_id_seq'::regclass),
program_id integer NOT NULL,
program_function_name character varying(255) NOT NULL,
group_name character varying(255),
url character varying(255) NOT NULL,
program_function_sequence integer NOT NULL DEFAULT 0,
restricted_user_access boolean DEFAULT false,
active boolean DEFAULT true,
created_at timestamp without time zone NOT NULL,
updated_at timestamp without time zone NOT NULL,
