require "sidekiq/testing"

class SidekiqTestCase < ActiveJob::TestCase
  before do
    Sidekiq::Testing.fake!
  end
  before :each do
    Sidekiq::Worker.clear_all
  end
end
