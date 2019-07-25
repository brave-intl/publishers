require "test_helper"
require "shared/mailer_test_helper"
require "webmock/minitest"

class UpholdConnectionTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  include MailerTestHelper
  include PromosHelper
  include EyeshadeHelper

  describe 'prepare_uphold_state' do
    let(:verified_connection) { uphold_connections(:verified_connection) }
    let(:subject) { verified_connection.prepare_uphold_state_token }

    before do
      verified_connection.uphold_state_token = nil
      subject
    end

    it 'is valid' do
      assert verified_connection.valid?
    end

    it 'generates a new state token' do
      assert verified_connection.uphold_state_token
    end

    describe 'when it is previously set' do
      existing_value = nil

      before do
        existing_value = verified_connection.uphold_state_token
        subject
      end

      it 'does not change' do
        assert_equal existing_value, verified_connection.uphold_state_token
      end
    end
  end

  describe 'validations' do
    let(:uphold_connection) { uphold_connections(:verified_connection) }

    describe 'when uphold_access_parameters is nil' do
      before do
        uphold_connection.uphold_access_parameters = nil
      end

      describe 'when uphold_code is present' do
        before do
          uphold_connection.uphold_code = 'foo'
        end

        it 'is valid' do
          assert uphold_connection.valid?
        end

        describe 'when uphold_verified is true' do
          before do
            uphold_connection.uphold_verified = true
          end

          it 'is not valid' do
            refute uphold_connection.valid?
          end
        end
      end

      describe 'when uphold_code is missing' do
        before do
          uphold_connection.uphold_code = nil
        end

        it 'is valid' do
          assert uphold_connection.valid?
        end

        describe 'when uphold_verified is true' do
          before do
            uphold_connection.uphold_verified = true
          end

          it 'is valid' do
            assert uphold_connection.valid?
          end
        end
      end
    end

    describe 'when uphold_access_parameters are present' do
      before do
        uphold_connection.uphold_access_parameters = 'bar'
      end

      describe 'when uphold_code is present' do
        before do
          uphold_connection.uphold_code = 'foo'
        end

        it 'is not valid' do
          refute uphold_connection.valid?
        end
      end

      describe 'when uphold_code is missing' do
        before do
          uphold_connection.uphold_code = nil
        end

        it 'is valid' do
          assert uphold_connection.valid?
        end

      end
    end
  end

  describe 'receive_uphold_code' do
    uphold_connection = nil
    let(:subject) { uphold_connection.receive_uphold_code('secret!') }

    before do
      uphold_connection = uphold_connections(:verified_connection)
      uphold_connection.uphold_state_token = '1234'
      uphold_connection.uphold_code = nil
      uphold_connection.uphold_access_parameters = '1234'
      uphold_connection.uphold_verified = false

      subject
    end

    it 'uphold_processing? returns true' do
      assert uphold_connection.uphold_processing?
    end

    it 'it sets uphold_code' do
      assert uphold_connection.uphold_code
    end

    it 'clears the uphold_access_parameters field' do
      assert_nil uphold_connection.uphold_access_parameters
    end

    it 'clears the uphold_state_token field' do
      assert_nil uphold_connection.uphold_state_token
    end
  end

  describe 'disconnect upholds' do
    let(:uphold_connection) { uphold_connections(:verified_connection) }

    before do
      uphold_connection.disconnect_uphold
    end

    it 'not uphold_verified?' do
      refute uphold_connection.uphold_verified?
    end

    it 'not uphold_processing?' do
      refute uphold_connection.uphold_processing?
    end

    it 'uphold_connection is valid?' do
      assert uphold_connection.valid?
    end
  end

  describe 'verify_uphold_status' do
    uphold_connection = nil

    before do
      uphold_connection = uphold_connections(:verified_connection)
    end

    describe 'when uphold_code, access_parameters, and uphold_verified are nil'  do
      before do
        uphold_connection.uphold_code = nil
        uphold_connection.uphold_access_parameters = nil
        uphold_connection.uphold_verified = false
      end

      it 'sets the status to unconnected' do
        assert_equal :unconnected, uphold_connection.uphold_status
      end
    end

    describe 'when uphold_code is set but the other parameters are nil' do
      before do
        uphold_connection.uphold_code = 'foo'
        uphold_connection.uphold_access_parameters = nil
        uphold_connection.uphold_verified = false
      end

      it 'returns code_acquired' do
        assert_equal :code_acquired, uphold_connection.uphold_status
      end
    end

    describe 'when uphold_code is nil but there are access parameters' do
      before do
        uphold_connection.uphold_code = nil
        uphold_connection.uphold_access_parameters = "foo"
        uphold_connection.uphold_verified = false
      end

      it 'returns unconnected' do
        assert_equal :unconnected, uphold_connection.uphold_status
      end
    end

    describe 'when uphold_code and access_parameters are nil' do
      before do
        uphold_connection.uphold_code = nil
        uphold_connection.uphold_access_parameters = nil
        uphold_connection.uphold_verified = true
      end

      it 'returns access_parameters_acquired' do
        assert_equal :verified, uphold_connection.uphold_status
      end
    end
  end
end
