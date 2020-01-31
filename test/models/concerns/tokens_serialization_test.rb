require 'test_helper'

if DEVISE_TOKEN_AUTH_ORM == :active_record
  describe 'DeviseTokenAuth::Concerns::TokensSerialization' do
    let(:ts) { DeviseTokenAuth::Concerns::TokensSerialization }
    let(:user) { FactoryBot.create(:user) }
    let(:tokens) do
      # Сreate all possible token's attributes combinations
      user.create_token
      2.times { user.create_new_auth_token(user.tokens.first[0]) }
      user.create_new_auth_token
      user.create_token

      user.tokens
    end
    let(:json) { JSON.generate(tokens) }

    it 'is defined' do
      assert_equal(ts.present?, true)
      assert_kind_of(Module, ts)
    end

    describe '.load(json)' do
      let(:default) { {} }

      it 'is defined' do
        assert_respond_to(ts, :load)
      end

      it 'handles nil' do
        assert_equal(ts.load(nil), default)
      end

      it 'handles string' do
        assert_equal(ts.load(json), JSON.parse(json))
      end

      it 'returns object of undesirable class' do
        assert_equal(ts.load([]), [])
      end
    end

    describe '.dump(object)' do
      let(:default) { 'null' }

      it 'is defined' do
        assert_respond_to(ts, :dump)
      end

      it 'handles nil' do
        assert_equal(ts.dump(nil), default)
      end

      it 'handles empty hash' do
        assert_equal(ts.dump({}), '{}')
      end

      it 'deserialize tokens' do
        assert_equal(ts.dump(tokens), json)
      end

      it 'removes nil values' do
        new_tokens = tokens.dup
        new_tokens[new_tokens.first[0]][:kos] = nil

        assert_equal(ts.dump(tokens), ts.dump(new_tokens))
      end

      describe 'updated_at' do
        before do
          @default_format = ::Time::DATE_FORMATS[:default]
          ::Time::DATE_FORMATS[:default] = 'imprecise format'
        end

        after do
          ::Time::DATE_FORMATS[:default] = @default_format
        end

        let(:updated_ats) { tokens.values.flat_map { |token| [:updated_at, 'updated_at'].map { |key| token[key] } }.compact.map(&:to_s) }

        it 'is defined' do
          refute_empty updated_ats
        end

        it 'uses iso8601' do
          as_json = updated_ats.map do |time_string|
            Time.zone.parse(time_string).iso8601
          end

          assert_equal(updated_ats, as_json)
        end

        it 'does not rely on Time#to_s' do
          refute_includes(updated_ats, 'imprecise format')
        end
      end
    end
  end
end
