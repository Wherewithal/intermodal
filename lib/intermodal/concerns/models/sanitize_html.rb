require 'rails-html-sanitizer'

module Intermodal
  module Models
    module SanitizeHTML
      extend ActiveSupport::Concern

      included do
        # Whitelist sanitizer
        # sanitize_html :description
        # sanitize_html :description, tags: %w(table tr td), attributes: %w(id class style)
        def self.sanitize_html(field, options={})
          before_validation do
            # Only sanitize if there is something to sanitize
            if self.send(field) and self.send("#{field}_changed?")
              self.send("#{field}=", Rails::Html::WhiteListSanitizer.new.sanitize(self.send(field), options))
            end
          end
        end

      end
    end
  end
end
