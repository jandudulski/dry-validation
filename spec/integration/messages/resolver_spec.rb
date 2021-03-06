# frozen_string_literal: true

RSpec.describe Dry::Validation::Messages::Resolver, '#message' do
  shared_context 'resolving' do
    subject(:resolver) do
      contract_class.new(schema: proc {}).message_resolver
    end

    let(:contract_class) do
      Class.new(Dry::Validation::Contract)
    end

    before do
      contract_class.config.messages.load_paths << SPEC_ROOT
        .join("fixtures/messages/errors.#{locale}.yml").realpath

      I18n.available_locales << :pl
    end

    context ':en' do
      let(:locale) { :en }

      it 'returns message text for base rule' do
        expect(resolver.message(:not_weekend, path: [nil], locale: locale))
          .to eql(['this only works on weekends', {}])
      end

      it 'returns message text for flat rule' do
        expect(resolver.message(:taken, path: [:email], tokens: { email: 'jane@doe.org' }, locale: locale))
          .to eql(['looks like jane@doe.org is taken', {}])
      end

      it 'returns message text for nested rule when it is defined under root' do
        expect(resolver.message(:invalid, path: %i[address city], locale: locale))
          .to eql(['is not a valid city name', {}])
      end

      it 'returns message text for nested rule' do
        expect(resolver.message(:invalid, path: %i[address street], locale: locale))
          .to eql(["doesn't look good", {}])
      end

      it 'raises error when template was not found' do
        expect { resolver.message(:not_here, path: [:email]) }
          .to raise_error(Dry::Validation::MissingMessageError, <<~STR)
            Message template for :not_here under "email" was not found
          STR
      end
    end

    context ':pl' do
      let(:locale) { :pl }

      it 'returns message text for base rule' do
        expect(resolver.message(:not_weekend, path: [nil], locale: locale))
          .to eql(['to działa tylko w weekendy', {}])
      end

      it 'returns message text for flat rule' do
        expect(resolver.message(:taken, path: [:email], tokens: { email: 'jane@doe.org' }, locale: locale))
          .to eql(['wygląda, że jane@doe.org jest zajęty', {}])
      end

      it 'returns message text for nested rule when it is defined under root' do
        expect(resolver.message(:invalid, path: %i[address city], locale: locale))
          .to eql(['nie jest poprawną nazwą miasta', {}])
      end

      it 'returns message text for nested rule' do
        expect(resolver.message(:invalid, path: %i[address street], locale: locale))
          .to eql(['nie wygląda dobrze', {}])
      end
    end
  end

  context 'using :yaml' do
    before do
      contract_class.config.messages.backend = :yaml
    end

    include_context 'resolving'
  end

  context 'using :i18n' do
    before do
      contract_class.config.messages.backend = :i18n
    end

    include_context 'resolving'
  end
end
