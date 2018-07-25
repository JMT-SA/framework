# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

module PackMaterialApp
  class TestPmProductInteractor < Minitest::Test
    def test_repo
      repo = interactor.send(:repo)
      assert repo.is_a?(PackMaterialApp::PmProductRepo)
    end

    private

    def interactor
      @interactor ||= PmProductInteractor.new(current_user, {}, {}, {})
    end

    def pm_product_attrs
      {
        id: 1,
        active: true,
        material_resource_sub_type_id: 1,
        alternate: 'alternate',
        assembly: 'assembly',
        brand_1: 'brand_1',
        brand_2: 'brand_2',
        colour: 'colour',
        commodity_id: 1,
        grade: 'grade',
        language: 'language',
        market: 'market',
        marking: 'marking',
        material: 'material',
        model: 'model',
        other: 'other',
        pm_class: 'pm_class',
        product_code: 'product_code',
        product_number: 11_223_333_444,
        reference_dimension: 'reference_dimension',
        reference_mass: 'reference_mass',
        reference_number: 'reference_number',
        reference_quantity: 'reference_quantity',
        reference_size: 'reference_size',
        shape: 'shape',
        specification_notes: 'specification_notes',
        style: 'style',
        unit: 'unit',
        marketing_variety_id: 1
      }
    end

    def fake_pm_product
      PmProduct.new(pm_product_attrs)
    end

    def invalid_pm_product_attrs
      pm_product_attrs.merge(material_resource_sub_type_id: nil)
    end

  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize



#     def create_pm_product(params)
#       res = validate_new_pm_product_params(params)
#       return validation_failed_response(res) unless res.messages.empty?
#       pm_product_create(res)
#     end
#
#     def clone_pm_product(params)
#       res = validate_clone_pm_product_params(params)
#       return validation_failed_response(res) unless res.messages.empty?
#       pm_product_create(res)
#     end
#
#     def pm_product_create(res)
#       id = nil
#       DB.transaction do
#         id = repo.create_pm_product(res)
#       end
#       instance = pm_product(id)
#       success_response('Created product', instance)
#     rescue Sequel::UniqueConstraintViolation
#       validation_failed_response(OpenStruct.new(messages: { product_number: ['This product already exists'] }))
#     end
#
#     def update_pm_product(id, params)
#       # Update should test for product code uniqueness
#       # and generate the product code & product number
#       res = validate_edit_pm_product_params(params)
#       return validation_failed_response(res) unless res.messages.empty?
#       repo.update_pm_product(id, res)
#       success_response("Updated product #{pm_product.product_code}", pm_product(id))
#     end
#
#     def delete_pm_product(id)
#       name = pm_product(id).product_code
#       repo.delete_pm_product(id)
#       success_response("Deleted product #{name}")
#     end
#
#     def create_pm_product_variant(parent_id, params)
#       params[:pack_material_product_id] = parent_id
#       res = validate_pm_product_variant_params(params)
#       return validation_failed_response(res) unless res.messages.empty?
#       pm_product_variant_create(res)
#     end
#
#     def clone_pm_product_variant(parent_id, params)
#       params[:pack_material_product_id] = parent_id
#       res = validate_clone_pm_product_variant_params(params)
#       return validation_failed_response(res) unless res.messages.empty?
#       pm_product_variant_create(res)
#     end
#
#     def pm_product_variant_create(res)
#       id = nil
#       DB.transaction do
#         id = repo.create_pm_product_variant(res)
#       end
#       instance = pm_product_variant(id)
#       success_response('Created product variant', instance)
#     rescue Sequel::UniqueConstraintViolation
#       validation_failed_response(OpenStruct.new(messages: { unit: ['This product variant already exists'] }))
#     end
#
#     def update_pm_product_variant(id, params)
#       res = validate_pm_product_variant_params(params)
#       return validation_failed_response(res) unless res.messages.empty?
#       DB.transaction do
#         repo.update_pm_product_variant(id, res)
#       end
#       instance = pm_product_variant(id)
#       success_response("Updated pack material product variant #{instance.product_variant_number}", instance)
#     end
#
#     def delete_pm_product_variant(id)
#       name = pm_product_variant(id).unit
#       DB.transaction do
#         repo.delete_pm_product_variant(id)
#       end
#       success_response("Deleted pack material product variant #{name}")
#     end
#
#     private

#     def pm_product(id)
#       repo.find_pm_product(id)
#     end
#
#     def pm_product_variant(id)
#       repo.find_pm_product_variant(id)
#     end
#
#     def validate_new_pm_product_params(params)
#       NewPmProductSchema.call(params)
#     end
#
#     def validate_edit_pm_product_params(params)
#       EditPmProductSchema.call(params)
#     end
#
#     def validate_clone_pm_product_params(params)
#       ClonePmProductSchema.call(params)
#     end
#
#     def validate_completed_pm_product_params(params)
#       CompletedPmProductSchema.call(params)
#     end
#
#     def validate_pm_product_variant_params(params)
#       PmProductVariantSchema.call(params)
#     end
#
#     def validate_clone_pm_product_variant_params(params)
#       ClonePmProductVariantSchema.call(params)
#     end
#
#     def validate_completed_pm_product_variant_params(params)
#       CompletedPmProductVariantSchema.call(params)
#     end
#   end
# end