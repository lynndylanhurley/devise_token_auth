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
    end
  end
end
