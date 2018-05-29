require "spec_helper"
require "sidekiq"
require "sidekiq/postpone"
require "sidekiq/testing"

class MyWorker
  include Sidekiq::Worker

  def perform
    Sidekiq::Postpone.wrap do
      # do something usefull
    end
  end
end

describe "integration spec" do
  context "default testing mode" do
    it "works fine" do
      MyWorker.perform_async

      expect(MyWorker.jobs.count).to eq(1)
    end
  end

  context "testing disabled" do
    after { Sidekiq::Queues["default"].clear }

    it "overflows stack" do
      Sidekiq::Testing.disable! do
        MyWorker.perform_async

        expect(Sidekiq::Queues["default"].size).to eq(1)
      end
    end
  end
end
