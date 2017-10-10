class DevelopmentRepo < RepoBase
  IGNORE_TABLES = %i{schema_migrations users}

  def table_list
    DB.tables.reject { |table| IGNORE_TABLES.include?(table) }.sort
  end

  def table_columns(table)
    DB.schema(table)
  end

# [
#     [0] [
#         [0] :id,
#         [1] {
#                        :oid => 23,
#                    :db_type => "integer",
#                    :default => "nextval('users_id_seq'::regclass)",
#                 :allow_null => false,
#                :primary_key => true,
#                       :type => :integer,
#             :auto_increment => true,
#               :ruby_default => nil
#         }
#     ],
#     [1] [
#         [0] :login_name,
#         [1] {
#                      :oid => 1043,
#                  :db_type => "character varying(255)",
#                  :default => nil,
#               :allow_null => false,
#              :primary_key => false,
#                     :type => :string,
#             :ruby_default => nil,
#               :max_length => 255
#         }
#     ],

  def table_col_names(table)
    # table_columns(table).map { |col, _| col }
    DB[table.to_sym].columns
  end

  def foreign_keys(table)
    DB.foreign_key_list(table)
  end
  # fk[0][:columns] #=> array of col on this table (:organization_id)
  # fk[0][:key]     #=> array of col on foreign table (:id)
  # fk[0][:table]   #=> symbol - foreign table (:organizations)
# DB.foreign_key_list(:party_roles)                                                                                              
# [
#     [0] {
#               :name => :party_roles_organization_id_fkey,
#            :columns => [
#             [0] :organization_id
#         ],
#                :key => [
#             [0] :id
#         ],
#          :on_update => :no_action,
#          :on_delete => :no_action,
#         :deferrable => false,
#              :table => :organizations
#     },
#     [1] {
#               :name => :party_roles_party_id_fkey,
#            :columns => [
#             [0] :party_id
#         ],
#                :key => [
#             [0] :id
#         ],
#          :on_update => :no_action,
#          :on_delete => :no_action,
#         :deferrable => false,
#              :table => :parties
#     },

end
