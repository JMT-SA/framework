# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'mocha/minitest'
require 'minitest/stub_any_instance'
require 'minitest/hooks/test'
require 'minitest/rg'

require 'bundler'
Bundler.require(:default, ENV.fetch('RACK_ENV', 'development'))

require './config/environment'

require './lib/types_for_dry'
require './lib/crossbeams_responses'
require './lib/base_repo'

root_dir = File.expand_path('../..', __FILE__)

Dir["#{root_dir}/helpers/**/*.rb"].each { |f| require f }
require './lib/base_service'
require './lib/base_interactor'
require './lib/ui_rules'

Dir["#{root_dir}/lib/applets/*.rb"].each { |f| require f }

class MiniTestWithHooks < Minitest::Test
  include Minitest::Hooks

  def around
    DB.transaction(rollback: :always, savepoint: true, auto_savepoint: true) do
      super
    end
  end

  def around_all
    DB.transaction(rollback: :always) do
      db_create_seeds
      super
    end
  end

  def db_create_seeds
    @fixed_table_set = {}
    # roles

    # domain
    dom_id = DB[:material_resource_domains].insert(
      domain_name: PackMaterialApp::DOMAIN_NAME,
      product_table_name: 'pack_material_products',
      variant_table_name: 'pack_material_product_variants'
    )
    @fixed_table_set[:domain_id] = dom_id

    # product columns
    DB[prod_col_sql].insert

    # mr type
    type_id = DB[:material_resource_types].insert(
      material_resource_domain_id: dom_id,
      internal_seq: 1,
      type_name: 'PM SC Type',
      short_code: 'SC',
      description: 'This is the description field'
    )
    @fixed_table_set[:matres_types] = { sc: { id: type_id, short_code: 'SC' } }

    # mr sub
    sql = <<~SQL
      SELECT id FROM material_resource_product_columns
      WHERE column_name IN ('unit', 'style', 'brand_1')
    SQL
    prod_code_ids = DB[sql].select_map
    sub_id = DB[:material_resource_sub_types].insert(
      material_resource_type_id: type_id,
      internal_seq: 1,
      sub_type_name: 'PM SC Sub Type',
      short_code: 'SC',
      product_code_ids: "{#{prod_code_ids.join(',')}}"
    )
    @fixed_table_set[:matres_sub_types] = { sc: { id: sub_id, short_code: 'SC', prod_code_ids: [prod_code_ids] } }

    # commodities

    # mkt varieties
  end

  def prod_col_sql
    <<~SQL
      INSERT INTO material_resource_product_columns (material_resource_domain_id, column_name, short_code, description)
        SELECT dom.id, sub.column_name, sub.short_code, sub.description
        FROM material_resource_domains dom
          JOIN (SELECT * FROM (VALUES ('unit', 'UNIT', 'Unit', 1),
            ('style', 'STYL', 'Style', 1),
            ('alternate', 'ALTE', 'Alternate', 1),
            ('shape', 'SHPE', 'Shape', 1),
            ('reference_size', 'REFS', 'Reference Size', 1),
            ('reference_dimension', 'REFD', 'Reference Dimension', 1),
            ('reference_quantity', 'REFQ', 'Reference Quantity', 1),
            ('brand_1', 'BRD1', 'Brand1', 1),
            ('brand_2', 'BRD2', 'Brand2', 1),
            ('colour', 'COLR', 'Colour', 1),
            ('material', 'MATR', 'Material', 1),
            ('assembly', 'ASSM', 'Assembly', 1),
            ('reference_mass', 'REFM', 'Reference Mass', 1),
            ('reference_number', 'REFN', 'Reference Number', 1),
            ('market', 'MRKT', 'Market', 1),
            ('marking', 'MARK', 'Marking', 1),
            ('model', 'MODL', 'Model', 1),
            ('pm_class', 'CLAS', 'Class', 1),
            ('grade', 'GRAD', 'Grade', 1),
            ('language', 'LANG', 'Language', 1),
            ('other', 'OTHR', 'Other', 1),
            ('commodity_id', 'COMM', 'Commodity', 1),
            ('marketing_variety_id', 'VARY', 'Variety', 1))
            AS t(column_name, short_code, description, n)) sub ON sub.n = 1
        WHERE dom.domain_name = 'Pack Material';
    SQL
  end
end

def current_user
  DevelopmentApp::User.new(
    id: 1,
    login_name: 'usr_login',
    user_name: 'User Name',
    password_hash: '$2a$10$wZQEHY77JEp93JgUUyVqgOkwhPb8bYZLswD5NVTWOKwU1ssQTYa.K',
    email: 'current_user@example.com',
    active: true
  )
end
