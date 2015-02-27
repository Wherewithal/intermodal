module Intermodal
  module DSL
    module PresentationHelpers
      using Intermodal::Functional

      ### Helpers
      #   These are helpers to make things easier to map. They will typically return a function, so using
      #   an applicative operator such as the one found in rlet/functional.rb will work well

      # Use this to map to a presenter
      #
      # Example:
      #   presentation_for :account do
      #     presents :contact, with: presenter(:contact, scope: :details)
      #   end
      #
      def presenter(name, opt={})
        attribute(name) | maybe(to_presentation(name, opt))
      end

      # Use this to map a value to a presenter
      # Unlike #presenter() helper, this will not check if the attribute is ni
      def to_presentation(name, opt={})
        ->(value) { presenters[name].call(value, opt) }
      end

      # Use this to handle nil cases
      #
      # Example:
      #   using Intermodal::Functional
      #
      #   acceptance_for :article do
      #     accepts :published_at, with: params(:published_at) | maybe(parse_datetime)
      #   end
      def maybe(f)
        ->(value) { value.nil? ? nil : f.call(value) }
      end

      # Use this to call a getter method on the model
      #
      # Example:
      #   using Intermodal::Functional
      #
      #   presentation_for :item do
      #     presents :price, with: attribute(:price) | helper(:number_to_currency)
      #   end
      def attribute(field)
        ->(resource) { resource.send(field) }
      end

      # Use this to get a value from the params hash, most useful for acceptors
      #
      # Example:
      #   using Intermodal::Functional
      #
      #   acceptance_for :article do
      #     accepts :published_at, with: params(:published_at) | maybe(parse_datetime)
      #   end
      def params(field)
        ->(p) { p[field] }
      end

      # Use this to access Rails ActionView helpers, most useful in presenters
      # in conjunction with attribute
      # Example:
      #   using Intermodal::Functional
      #
      #   presentation_for :item do
      #     presents :price, with: attribute(:price) | helper(:number_to_currency)
      #   end
      def helper(_method)
        ActionController::Base.helpers.method(_method)
      end

      # Use this to look up a value in a hash or anything that will accept a []
      # message (including ActiveModel objects). Useful when you want to convert
      # a value into a human-friendly form, or for translations.
      #
      # Example:
      #   using Intermodal::Functional
      #
      #   presentation_for :ledger do
      #     presents :t_code
      #     presents :t_code_description, with: attribute(:t_code) | map_to(Ledger::Description)
      def map_to(hash)
        ->(x) { hash[x] }
      end

      # Use this to convert a string to a datetime. ActiveRecord .create() and
      # .update_attributes() is not very robust when we try to put in different datatypes.
      # This will parse something to a datetime, and if it fails, we throw a BadRequest
      # exception. Intermodal will rescue from that and respond with HTTP 400 Bad Request error.
      def to_datetime
        @_to_datetime = proc do |dt|
          begin
            DateTime.parse(dt.to_s)
          rescue ArgumentError
            raise Intermodal::BadRequest
          end
        end
      end
    end
  end
end
