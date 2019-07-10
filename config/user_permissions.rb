# frozen_string_literal: true

module Crossbeams
  module Config
    # Store rules for user-specific permissions.
    #
    # BASE contains the default rules as a Hash "tree".
    # Leaf nodes must be true or false.
    #
    # The first key must be the Webapp (matches the Roda class)
    #
    # DOCUMENTATION mirrors BASE, but supplies a description of each permission
    # to display in the UI to help users understand the context of the setting.
    #
    # The main method to use is Crossbeams::Config::UserPermissions.can_user?
    # - pass the user object (or hash) and an array of permission keys.
    #
    class UserPermissions # rubocop:disable Metrics/ClassLength
      WEBAPP = :Framework

      BASE = {
        WEBAPP => {
          stock_adj: { approve: false, sign_off: false },
          purchase_order: { approve: false },
          delivery: { accept: false }
          # stock_adj: { sign_off: false, approve: true, take_out_rubbish: true },
          # invoice: { complete: false, approve: { fruit: true, assets: false } }
        }
      }.freeze

      DOCUMENTATION = {
        WEBAPP => {
          stock_adj: { approve: 'Approve a stock adjustment', sign_off: 'Sign off on a stock adjustment' },
          purchase_order: { approve: 'Approve a purchase order' },
          delivery: { accept: 'Accept all Over Supply on any line items for this delivery' }
          # stock_adj: { sign_off: 'Sign off on a stock adjustment', approve: 'dummy appr', take_out_rubbish: 'xx' },
          # invoice: { complete: 'dummy complete', approve: { fruit: 'dummy fruit', assets: 'dummy asset' } }
        }
      }.freeze

      # Take a nested hash and return all its keys in an array
      def self.tree_hash_keys_to_a(hash)
        ar = []
        hash.keys.sort.each do |k|
          ar << k
          ar += tree_hash_keys_to_a(hash[k]) if hash[k].is_a?(Hash)
        end
        ar
      end

      # Ensure documentation matches declaration.
      raise 'Crossbeams::Config::UserPermissions documentation is incomplete' unless tree_hash_keys_to_a(DOCUMENTATION[WEBAPP]) == tree_hash_keys_to_a(BASE[WEBAPP])

      # Does the given user have a certain permission?
      #
      # @param user [User,Hash] the user to be checked.
      # @param permission_tree [Array] the tree of permission keys (Excluding the top-most [Webapp] key)
      # @return [boolean]
      def self.can_user?(user, *permission_tree)
        raise ArgumentError, 'User argument is required for "can_user?" method' if user.nil?
        raise ArgumentError, 'Permission tree array argument is required for "can_user?" method' if permission_tree.nil?

        keys = permission_tree.unshift(WEBAPP)

        permissions = UtilityFunctions.symbolize_keys(user[:permission_tree].to_h).dig(*keys)
        permissions = BASE.dig(*keys) if permissions.nil?

        permissions.is_a? TrueClass
      end

      # INSTANCE - used for maintaining a user's permission tree.
      # ---------------------------------------------------------
      attr_reader :tree

      def initialize(user = {})
        top = UtilityFunctions.symbolize_keys(user[:permission_tree].to_h)
        @user_permissions = top[WEBAPP] || {}
        @tree = make_tree
      end

      # An array of User permissions.
      # Each field is a Hash of:
      # - group
      # - field
      # - value
      # - description
      # - keys
      #
      # @return [Array]
      def fields
        tree.field_array
      end

      # Return fields grouped per group value.
      #
      # @return [Hash] key is group and value is array of fields for the group.
      def grouped_fields
        tree.field_array.group_by { |g| g[:group] }
      end

      # Take input parameters, apply them to the base permissions
      # and return a new hash of permissions for the user.
      #
      # @param params [array] the input parameters.
      # @return [hash] the new permissions for the user.
      def apply_params(params)
        permissions = BASE[WEBAPP].dup
        params.each do |compound_key, permission|
          hash_keys = keys_for(compound_key)
          h = permissions
          hash_keys.each do |key|
            if h[key].is_a?(Hash)
              h = h[key]
            else
              h[key] = permission == 't'
            end
          end
        end
        { WEBAPP => permissions }
      end

      private

      # Remove permissions from the merged set that are not defined in the base.
      # (The user might have an obsolete permission)
      #
      # @param keys [array] the list of keys
      def remove_obsolete_permissions(keys)
        res = @permissions.dig(*keys)
        if res.nil?
          h = @new_set
          dk = keys.pop
          keys.each { |a| h = h[a] }
          h.delete(dk)
        else
          res = @new_set.dig(*keys)
          if res.is_a?(Hash)
            res.each_key do |k1|
              remove_obsolete_permissions(keys + Array(k1))
            end
          end
        end
      end

      def make_tree
        @permissions = BASE[WEBAPP].dup
        @new_set = UtilityFunctions.merge_recursively(@permissions, @user_permissions)

        # Clean up the merged permissions - remove obsolete entries.
        @new_set.each_key do |key|
          if @permissions.key?(key)
            remove_obsolete_permissions(Array(key))
          else
            @new_set.delete(key)
          end
        end

        top_node = TreeNode.new(WEBAPP, '', nil, nil)
        @new_set.each do |k, v|
          build_tree(top_node, k, v, k)
        end
        top_node
      end

      def build_tree(node, key, value, group)
        node_val = value.is_a?(Hash) ? nil : value
        leaf = DOCUMENTATION.dig(*node.keys.push(key).unshift(WEBAPP))
        desc = leaf.is_a?(String) ? leaf : ''
        child = TreeNode.new(key, desc, node_val, group)
        node.add_child(child)
        return unless node_val.nil?

        value.each do |k, v|
          build_tree(child, k, v, group)
        end
      end

      def keys_for(compound_key)
        field = fields.find { |f| f[:field] == compound_key }
        raise Crossbeams::InfoError %(There is no user permission for "#{compound_key}") if field.nil?

        field[:keys]
      end
    end

    # Tree component for storing user permissions.
    class TreeNode
      attr_accessor :keyname, :children, :description, :permission, :group, :parent

      # Create without children. Set keyname and the permission (true/false).
      def initialize(keyname, description, permission, group)
        @keyname = keyname
        @description = description
        @permission = permission
        @group = group
        @parent = nil
        @children = []
      end

      # Keys for the node (excludes the top-most node)
      def keys
        return [nil] if parent.nil?

        ar = []
        node = self
        while node.parent
          ar << node.keyname
          node = node.parent
        end
        ar.reverse
      end

      # An array of all the leaf nodes below this node.
      def field_array
        ar = []
        children.each { |child| ar += child.leaf_set }
        ar
      end

      # An array of all leaf nodes in the tree from this node.
      def leaf_set
        ar = []
        if children?
          children.each { |child| ar += child.leaf_set }
        else
          ar << { field: fieldname, description: description, value: permission, group: group, keys: keys.compact }
        end
        ar
      end

      # Fieldname is constructed from a concatenation of all parent keys and this node's key.
      def fieldname
        return keyname if parent.nil?

        ar = []
        node = self
        while node.parent
          ar << node.keyname.to_s
          node = node.parent
        end
        ar.reverse.join('_').to_sym
      end

      # Add a child TreeNode to this instance.
      def add_child(node)
        @children << node
        node.parent = self
        node
      end

      # Remove a child TreeNode from this instance.
      def remove_child(node)
        @children.delete(node)
        node.parent = nil
      end

      # Does this instance have at least one child?
      def children?
        @children != []
      end

      # For debugging, show a simplified version of the tree.
      def to_s(indent = 0)
        kids = @children.empty? ? '' : "#{@children.length} children."
        s = +"#{@keyname}: #{@permission} #{kids}"
        ind = indent + 2
        @children.each { |c| s << "\n#{' ' * ind}#{c.to_s(ind)}" }
        s
      end
    end
  end
end
