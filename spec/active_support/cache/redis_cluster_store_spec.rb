require "spec_helper"

describe ::ActiveSupport::Cache::RedisClusterStore do
  let(:options) { {} }

  subject { described_class.new(options) }

  describe "#delete" do
    context "when error is raised" do
      before { expect(subject).to receive(:with).and_raise(::Redis::CommandError, "upstream failure") }

      it "still returns false" do
        expect(subject.delete("test")).to eq(false)
      end

      context "raise_errors? is enabled" do
        let(:options) { {:raise_errors => true} }

        it "raises an error" do
          expect { subject.delete("test") }.to raise_error(::Redis::CommandError, "upstream failure")
        end
      end

      context "error_handler is set" do
        let(:handler) { double("handler") }
        let(:options) { { :error_handler => -> (exception:, method:, returning:) { handler.(exception, method, returning) } } }

        it "calls error handler" do
          expect(handler).to receive(:call) do |exception, method, returning|
            expect(exception).to be_a(::Redis::CommandError)
            expect(exception.message).to eq("upstream failure")
            expect(method).to eq(:delete_entry)
            expect(returning).to eq(false)
          end

          subject.delete("test")
        end
      end
    end
  end

  describe "#delete_matched" do
    it "is not supported with redis cluster" do
      expect{ subject.delete_matched(nil, nil) }.to raise_error(::NotImplementedError, "Deleting keys with a matcher is not supported with redis cluster")
    end
  end

  describe "#fetch_multi" do
    it "is not supported with redis cluster" do
      expect{ subject.fetch_multi(nil) }.to raise_error(::NotImplementedError)
    end
  end

  describe "#increment" do
    let(:fake_client) { Redis.new }
    before { allow(subject).to receive(:with).and_yield(fake_client) }

    it "only returns the new value after being incremented with ttl" do
      expect(subject.increment("testing", 1, :expires_in => 5.minutes)).to eq(1)
      expect(subject.increment("testing", 5, :expires_in => 5.minutes)).to eq(6)
    end

    it "can increment without a ttl" do
      expect(fake_client).to_not receive(:pipelined).and_call_original
      expect(subject.increment("testing")).to eq(1)
    end

    it "can increment with a ttl" do
      expect(fake_client).to receive(:pipelined).and_yield
      expect(fake_client).to receive(:incrby).with("testing", 1)
      expect(fake_client).to receive(:expire).with("testing", 300)
      subject.increment("testing", 1, :expires_in => 5.minutes)
    end
  end

  describe "#read" do
    context "when error is raised" do
      before { expect(subject).to receive(:with).and_raise(::Redis::CommandError, "upstream failure") }

      it "still returns nil" do
        expect(subject.read("test")).to be_nil
      end

      context "raise_errors? is enabled" do
        let(:options) { {:raise_errors => true} }

        it "raises an error" do
          expect { subject.read("test") }.to raise_error(::Redis::CommandError, "upstream failure")
        end
      end

      context "error_handler is set" do
        let(:handler) { double("handler") }
        let(:options) { { :error_handler => -> (exception:, method:, returning:) { handler.(exception, method, returning) } } }

        it "calls error handler" do
          expect(handler).to receive(:call) do |exception, method, returning|
            expect(exception).to be_a(::Redis::CommandError)
            expect(exception.message).to eq("upstream failure")
            expect(method).to eq(:read_entry)
            expect(returning).to eq(nil)
          end

          subject.read("test")
        end
      end
    end
  end

  describe "#write" do
    context "when error is raised" do
      before { expect(subject).to receive(:with).and_raise(::Redis::CommandError, "upstream failure") }

      it "still returns false" do
        expect(subject.write("test", "yolo")).to eq(false)
      end

      context "raise_errors? is enabled" do
        let(:options) { {:raise_errors => true} }

        it "raises an error" do
          expect { subject.write("test", "yolo") }.to raise_error(::Redis::CommandError, "upstream failure")
        end
      end

      context "error_handler is set" do
        let(:handler) { double("handler") }
        let(:options) { { :error_handler => -> (exception:, method:, returning:) { handler.(exception, method, returning) } } }

        it "calls error handler" do
          expect(handler).to receive(:call) do |exception, method, returning|
            expect(exception).to be_a(::Redis::CommandError)
            expect(exception.message).to eq("upstream failure")
            expect(method).to eq(:write_entry)
            expect(returning).to eq(false)
          end

          subject.write("test", "yolo")
        end
      end
    end
  end
end
