require "test_helper"
require "shale/schema"

class ApplicationRecordToShaleServiceTest < ActiveSupport::TestCase
  subject { ApplicationRecordToShaleService }
  let(:instance) { subject.new }

  before do
    instance.call(Publisher, "UserTestSchema")
  end

  describe "#initialize" do
    describe "when successful" do
      it "should return an instance" do
        assert_instance_of(subject, instance)
      end
    end

    describe "#call" do
      describe "when successful" do
        it "should create a global class that inherits from Shale::Mapper" do
          assert UserTestSchema
          UserTestSchema.ancestors.include?(Shale::Mapper)
        end

        it "should respond to the attributes found on Publisher" do
          inst = UserTestSchema.new
          assert inst.respond_to?(:name)
        end

        describe "when converting to schema" do
          let(:schema) {
            JSON.parse(Shale::Schema.to_json(
              UserTestSchema,
              id: "http://foo.bar/schema/person",
              description: "My description",
              pretty: true
            ))
          }

          it "should be able to generate jsonschema" do
            assert schema.fetch("$id")
          end

          it "should properly set mapped types" do
            assert_equal(schema.dig("$defs", "UserTestSchema", "properties", "created_via_api", "type")[0], "boolean")
          end
        end
      end
    end
  end
end
