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
          before_save do
            # Only sanitize if there is something to sanitize
            if self.send(field) and self.send("#{field}_changed?")
              self.send("#{field}=", ::Rails::Html::WhiteListSanitizer.new.sanitize(self.send(field), options))
            end
          end
        end

        # Completely strips out all HTML tags
        # strip_html :title
        def self.strip_html(field)
          before_save do
            # Only strip if there is something to sanitize
            if self.send(field) and self.send("#{field}_changed?")
              self.send("#{field}=", ::Rails::Html::FullSanitizer.new.sanitize(self.send(field)))
            end
          end
        end

      end
    end
  end
end
