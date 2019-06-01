# frozen_string_literal: true

module Crossbeams
  module Config
    # Store rules for user-specific permissions.
    #
    # BASE contains the default rules as a Hash "tree".
    # Leaf nodes must be true or false.
    #
    # The first key must be the Webapp (matches the Roda class)
    class UserPermissions
      WEBAPP = :Framework

      BASE = {
        WEBAPP => {
          stock_adj: { sign_off: false, approve: true },
          invoice: { complete: false, approve: { fruit: true, assets: false } }
        }
      }.freeze

      DOCUMENTATION = {
        WEBAPP => {
          stock_adj: { sign_off: 'Sign off on a stock adjustment', approve: 'dummy appr' },
          invoice: { complete: 'dummy complete', approve: { fruit: 'dummy fruit', assets: 'dummy asset' } }
        }
      }.freeze

      # Ensure documentation matches declaration.
      raise 'Crossbeams::Config::UserPermissions documentation is incomplete' if DOCUMENTATION[WEBAPP].keys != BASE[WEBAPP].keys

      # Does the given user have a certain permission?
      #
      # @param user [User,Hash] the user to be checked.
      # @param permission_tree [Array] the tree of permission keys (Excluding the top-most [Webapp] key)
      # @return [boolean]
      def self.can_user?(user, *permission_tree)
        keys = permission_tree.unshift(WEBAPP)

        permissions = (user[:permission_tree] || {}).dig(*keys)
        permissions = BASE.dig(*keys) if permissions.nil?

        permissions.is_a? TrueClass
      end

      # INSTANCE
      # --------------------------------
      attr_reader :tree

      def initialize(user)
        @user_permissions = user[:permission_tree] || {}
        @tree = make_tree(user)
      end

      def fields
        tree.field_array
      end

      def grouped_fields
        tree.field_array.group_by { |g| g[:group] }
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

      def make_tree(user)
        @permissions = BASE[WEBAPP].dup
        user_permissions = user[:permission_tree] || {}
        @new_set = UtilityFunctions.merge_recursively(@permissions, user_permissions)

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
        leaf = DOCUMENTATION.dig(*node.keys.push(key))
        desc = leaf.is_a?(String) ? leaf : ''
        child = TreeNode.new(key, desc, node_val, group)
        node.add_child(child)
        return unless node_val.nil?
        value.each do |k, v|
          build_tree(child, k, v, group)
        end
      end
    end

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

      def keys
        return [keyname] if parent.nil?
        ar = []
        node = self
        while node.parent
          ar << node.keyname
          node = node.parent
        end
        ar << node.keyname
        ar.reverse
      end

      def field_array
        ar = []
        children.each { |child| ar += child.leaf_set }
        ar
      end

      def leaf_set
        ar = []
        if children?
          children.each { |child| ar += child.leaf_set }
        else
          ar << { field: fieldname, description: description, value: permission, group: group }
        end
        ar
      end

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
        s = String.new("#{@keyname}: #{@permission} #{kids}")
        ind = indent + 2
        @children.each { |c| s << "\n#{' ' * ind}#{c.to_s(ind)}" }
        s
      end
    end
  end
end
