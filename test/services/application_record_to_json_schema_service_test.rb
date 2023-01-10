require "test_helper"

class ApplicationRecordToJsonSchemaServiceTest < ActiveSupport::TestCase
  subject { ApplicationRecordToJsonSchemaService }
  let(:instance) { subject.new }

  describe "#initialize" do
    describe "when successful" do
      it "should return an instance" do
        assert_instance_of(subject, instance)
      end
    end

    describe "#call" do
      describe "when has whitelist" do
        let(:schema) { instance.call(Publisher, "UserTestSchema") }

        describe "when successful" do
          it "should be able to generate jsonschema" do
            assert schema.fetch("properties")
          end
        end
      end
      describe "when whitelist is empty" do
        let(:schema) { instance.call(UpholdConnection, "UserTestSchema") }

        describe "when successful" do
          it "should be able to generate jsonschema" do
            assert schema.fetch("properties")
          end
        end
      end
    end
  end
end
