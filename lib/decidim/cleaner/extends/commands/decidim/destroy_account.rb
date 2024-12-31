# frozen_string_literal: true

module Decidim
  module Cleaner
    module Extends
      # This command destroys the user's account.
      module DestroyAccount
        extend ActiveSupport::Concern

        included do
          private

          # Invalidate all sessions after cleaning Decidim::User record to prevent Active Record error
          def destroy_user_account!
            current_user.name = ""
            current_user.nickname = ""
            current_user.email = ""
            current_user.personal_url = ""
            current_user.about = ""
            current_user.delete_reason = @form.delete_reason
            current_user.admin = false if current_user.admin?
            current_user.deleted_at = Time.current
            current_user.skip_reconfirmation!
            current_user.avatar.purge
            current_user.save!

            current_user.invalidate_all_sessions!
          end
        end
      end
    end
  end
end
