# frozen_string_literal: true

module Decidim
  module Cleaner
    # A custom mailer for Decidim so we can notify users
    # when their account was blocked
    include Decidim::TranslatableAttributes
    class InactiveUsersMailer < Decidim::ApplicationMailer
      helper Decidim::Cleaner::DelaysHelper
      def warning_inactive(user)
        with_user(user) do
          @user = user
          @organization = user.organization
          @organization_name = translated_attribute(@organization.name, @organization)
          subject = I18n.t(
            "decidim.cleaner.inactive_users_mailer.warning_inactive.subject",
            organization_name: @organization_name
          )
          mail(to: user.email, subject:)
        end
      end

      def warning_deletion(user)
        with_user(user) do
          @user = user
          @organization = user.organization
          @organization_name = translated_attribute(@organization.name, @organization)
          subject = I18n.t(
            "decidim.cleaner.inactive_users_mailer.warning_deletion.subject",
            organization_name: @organization_name
          )
          mail(to: user.email, subject:)
        end
      end
    end
  end
end
