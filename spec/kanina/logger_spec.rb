describe Kanina::Logger do
  class DummyClass; end

  before(:each) do
    @dummy_class = DummyClass.new
    @dummy_class.extend(Kanina::Logger)
  end

  describe "#say" do
    it "sends the message to standard out if @loud is true" do
      @dummy_class.instance_variable_set(:@loud, true)
      expect(STDOUT).to receive(:puts).with("test")
      @dummy_class.say("test")
    end

    it "sends the message to the log file" do
      Timecop.freeze do
        expect(@dummy_class.logger).to receive(:add).with(1, "HARE: test")
        @dummy_class.say("test")
      end
    end
  end

end
