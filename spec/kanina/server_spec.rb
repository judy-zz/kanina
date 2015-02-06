describe Kanina::Server do
  before do
    @server = Class.new(Kanina::Server)
    @server.config = { host: 'localhost' }
  end
  describe '.status' do
    context 'when the server is not started' do
      it "returns 'off'" do
        expect(@server.status).to eql 'off'
      end
    end
    context 'when the server is started' do
      it "returns 'started'" do
        @server.start
        sleep(0.1)
        expect(@server.status).to eql 'started'
      end
    end
  end

  describe '.stop' do
    it 'closes the connection to rabbitmq' do
      @server.start
      sleep(0.1)
      expect(@server.status).to eql 'started'
      @server.stop
      expect(@server.status).to eql 'off'
    end
  end

  describe '.start' do
    it 'opens a connection to rabbitmq' do
      @server.start
      sleep(0.1)
      expect(@server.connection).to be_kind_of(Bunny::Session)
      expect(@server.channel).to be_kind_of(Bunny::Channel)
    end
  end
end
