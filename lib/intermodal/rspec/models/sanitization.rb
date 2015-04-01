module Intermodal
  module RSpec
    module Sanitization
      extend ActiveSupport::Concern

      module ClassMethods
        def expects_sanitization_of(_field, _options, &additional_examples)
          # We are not trying to retest the sanitizer so much as lightly demonstrating
          # idempotence. That is, repeated calls to the sanitizer should produce the
          # same output

          context _field.inspect do
            subject { resource.update_attributes!(updated_attributes); resource }
            let(:updated_attributes) { { _field => value } }
            let(:accepted_tags) { _options[:accepted_tags] }
            let(:rejected_tags) { _options[:rejected_tags] }

            context 'with a random string' do
              let(:value) { SecureRandom.hex(16) }
              it 'should leave it alone' do
                expect(subject).not_to be_changed     # Check update has persisted
                expect(subject.send(_field)).to eql(value)
              end
            end

            context 'with approved html tag' do
              let(:tag)     { accepted_tags.sample }
              let(:content) { SecureRandom.hex(16) }
              let(:value)   { "<#{tag}>#{content}</#{tag}>" }
              it 'should leave it alone' do
                expect(subject).not_to be_changed     # Check update has persisted
                expect(subject.send(_field)).to eql(value)
              end
            end

            context 'with tag not on whitelist' do
              let(:tag)     { rejected_tags.sample }
              let(:content) { SecureRandom.hex(16) }
              let(:value)   { "<#{tag}>#{content}</#{tag}>" }
              it 'should sanitize tag' do
                expect(subject).not_to be_changed     # Check update has persisted
                expect(subject.send(_field)).to eql(content)
              end
            end

            instance_eval(&additional_examples) if additional_examples
          end
        end

        def expects_stripping_of(_field, &additional_examples)
          # We are not trying to retest the sanitizer so much as lightly demonstrating
          # idempotence. That is, repeated calls to the sanitizer should produce the
          # same output

          context _field.inspect do
            subject { resource.update_attributes!(updated_attributes); resource }
            let(:updated_attributes) { { _field => value } }
            let(:rejected_tags) { %w(p div span ol ul li em strong) }

            context 'with a random string' do
              let(:value) { SecureRandom.hex(16) }
              it 'should leave it alone' do
                expect(subject).not_to be_changed     # Check update has persisted
                expect(subject.send(_field)).to eql(value)
              end
            end

            context 'with any tag' do
              let(:tag)     { rejected_tags.sample }
              let(:content) { SecureRandom.hex(16) }
              let(:value)   { "<#{tag}>#{content}</#{tag}>" }
              it 'should sanitize tag' do
                expect(subject).not_to be_changed     # Check update has persisted
                expect(subject.send(_field)).to eql(content)
              end
            end

            instance_eval(&additional_examples) if additional_examples
          end
        end
      end
    end
  end
end
