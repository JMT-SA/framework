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
          stock_adj: { sign_off: false }
        }
      }.freeze

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
    end
  end
end
