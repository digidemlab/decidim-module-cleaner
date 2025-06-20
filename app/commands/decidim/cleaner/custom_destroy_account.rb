# frozen_string_literal: true

module Decidim
  module Cleaner
    # This command destroys the user's account.
    class CustomDestroyAccount < Decidim::DestroyAccount
      # Destroy a user's account.
      #
      # user - The user to be updated.
      # form - The form with the data.
      def initialize(user, form)
        @user = user
        @form = form
      end

      private

      def destroy_user_account!
        @user.name = ""
        @user.nickname = ""
        @user.email = ""
        @user.personal_url = ""
        @user.about = ""
        @user.delete_reason = @form.delete_reason
        @user.admin = false if @user.admin?
        @user.deleted_at = Time.current
        @user.skip_reconfirmation!
        @user.avatar.purge
        @user.save!

        # Invalidate all sessions after cleaning Decidim::User record to prevent Active Record error
        @user.invalidate_all_sessions!
      end

      def destroy_user_identities
        @user.identities.destroy_all
      end

      def destroy_user_group_memberships
        Decidim::UserGroupMembership.where(user: @user).destroy_all
      end

      def destroy_follows
        Decidim::Follow.where(followable: @user).destroy_all
        Decidim::Follow.where(user: @user).destroy_all
      end

      def destroy_participatory_space_private_user
        Decidim::ParticipatorySpacePrivateUser.where(user: @user).destroy_all
      end

      def delegate_destroy_to_participatory_spaces
        Decidim.participatory_space_manifests.each do |space_manifest|
          space_manifest.invoke_on_destroy_account(@user)
        end
      end
    end
  end
end
