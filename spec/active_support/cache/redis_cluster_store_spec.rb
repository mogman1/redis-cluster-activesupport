require "spec_helper"

describe ::ActiveSupport::Cache::RedisClusterStore do
  let(:options) { {} }

  subject { described_class.new(options) }

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
    let(:fake_client) { double(:expire => true, :incrby => true, :pipelined => true) }

    before { allow(subject).to receive(:with).and_yield(fake_client) }

    it "can increment without a ttl" do
      expect(fake_client).to_not receive(:pipelined)
      expect(fake_client).to receive(:incrby).with("testing", 1)
      subject.increment("testing")
    end

    it "can increment with a ttl" do
      expect(fake_client).to receive(:pipelined).and_yield
      expect(fake_client).to receive(:incrby).with("testing", 1)
      expect(fake_client).to receive(:expire).with("testing", 300)
      subject.increment("testing", 1, :expires_in => 5.minutes)
    end
  end

  describe "#write_entry" do
    it "returns false when a known error is raised" do
      allow(subject).to receive(:with).and_raise(::Redis::CommandError, "ERR Proxy error")
      expect(subject.write("test", "yolo")).to eq(false)
    end

    it "raises when an unknown command error occurs" do
      allow(subject).to receive(:with).and_raise(::Redis::CommandError, "Yolo dude!")
      expect { subject.write("test", "yolo") }.to raise_error("Yolo dude!")
    end

    context "custom error" do
      let(:options) { {:ignored_command_errors => ["Faked You Out"]} }

      it "returns false when a known error is raised" do
        allow(subject).to receive(:with).and_raise(::Redis::CommandError, "Faked You Out")
        expect(subject.write("test", "yolo")).to eq(false)
      end
    end

    context "raise_errors? is enabled" do
      let(:options) { {:raise_errors => true} }

      it "raises an error" do
        allow(subject).to receive(:with).and_raise(::Redis::CommandError, "ERR Proxy error")
        expect { subject.write("test", "yolo") }.to raise_error("ERR Proxy error")
      end
    end
  end

  describe "#read_entry" do
    it "returns false when a known error is raised" do
      allow(subject).to receive(:with).and_raise(::Redis::CommandError, "ERR Proxy error")
      expect(subject.read("test")).to eq(nil)
    end

    it "raises when an unknown command error occurs" do
      allow(subject).to receive(:with).and_raise(::Redis::CommandError, "Yolo dude!")
      expect { subject.read("test") }.to raise_error("Yolo dude!")
    end

    context "custom error" do
      let(:options) { {:ignored_command_errors => ["Faked You Out"]} }

      it "returns false when a known error is raised" do
        allow(subject).to receive(:with).and_raise(::Redis::CommandError, "Faked You Out")
        expect(subject.read("test")).to eq(nil)
      end
    end

    context "raise_errors? is enabled" do
      let(:options) { {:raise_errors => true} }

      it "raises an error" do
        allow(subject).to receive(:with).and_raise(::Redis::CommandError, "ERR Proxy error")
        expect { subject.read("test") }.to raise_error("ERR Proxy error")
      end
    end
  end

  describe "#delete_entry" do
    it "returns false when a known error is raised" do
      allow(subject).to receive(:with).and_raise(::Redis::CommandError, "ERR Proxy error")
      expect(subject.delete("test")).to eq(false)
    end

    it "raises when an unknown command error occurs" do
      allow(subject).to receive(:with).and_raise(::Redis::CommandError, "Yolo dude!")
      expect { subject.delete("test") }.to raise_error("Yolo dude!")
    end

    context "custom error" do
      let(:options) { {:ignored_command_errors => ["Faked You Out"]} }

      it "returns false when a known error is raised" do
        allow(subject).to receive(:with).and_raise(::Redis::CommandError, "Faked You Out")
        expect(subject.delete("test")).to eq(false)
      end
    end

    context "raise_errors? is enabled" do
      let(:options) { {:raise_errors => true} }

      it "raises an error" do
        allow(subject).to receive(:with).and_raise(::Redis::CommandError, "ERR Proxy error")
        expect { subject.delete("test") }.to raise_error("ERR Proxy error")
      end
    end
  end
end
