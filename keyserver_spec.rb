require_relative 'keyserver'

describe KeyServer do
  before :each do
    @keyserver = KeyServer.new
  end

  describe "#new" do
    it "takes no parameter" do
      expect(@keyserver).to be_an_instance_of KeyServer
    end
  end

  describe "#generate_keys" do
    it "takes one parameter which is the number of keys to be generated" do
      @keyserver.generate_keys(10)
      expect(@keyserver.available_keys.size).to eq 10
    end
  end

  describe "#serve_key" do
    context "There are keys to serve" do
      it "serves an available key" do
        @keyserver.generate_keys(1)
        expect(@keyserver.serve_key).to be_an_instance_of String
      end
    end

    context "There are no available keys" do
      it "gives 404 error" do
        @keyserver.generate_keys(2)
        @keyserver.serve_key
        @keyserver.serve_key
        expect(@keyserver.serve_key).to eq "404"
      end
    end
  end

  describe "#unblock_key" do
    it "Unblocks a key" do
      @keyserver.generate_keys(1)
      key = @keyserver.serve_key
      expect(@keyserver.blocked_keys.key?(key)).to eq true
      expect(@keyserver.available_keys.key?(key)).to eq false
    end
  end

  describe "#delete_key" do
    it "Deletes a key" do
      @keyserver.generate_keys(10)
      key = @keyserver.serve_key
      @keyserver.delete_key key
      expect(@keyserver.available_keys.key?(key)).to eq false
      expect(@keyserver.blocked_keys.key?(key)).to eq false
    end
  end

  describe "#keep_alive" do
    context "Keep alive is not called within the last 5 minutes" do
      it "deletes the key" do
        @keyserver.generate_keys(10)
        sleep 5*60+1
        expect(@keyserver.available_keys.size).to eq 0
      end
    end    

    context "Keep alive is called within last 5 minutes" do
      it "keeps the key alive" do
        @keyserver.generate_keys(10)
        key = @keyserver.available_keys.first.first
        sleep 3*60 
        @keyserver.keep_alive key #Call keep alive at 3 minutes. 
        sleep 3*60  #Check after 3+3=6min if the key is still present
        expect(@keyserver.available_keys.key?(key)).to eq true
        sleep 2*60+1  #Check after 3+3+2=8min that the key has been deleted
        expect(@keyserver.available_keys.key?(key)).to eq false
      end
    end
  end

  it "Automatically releases blocked keys within 60 seconds" do
    @keyserver.generate_keys(10)
    key = @keyserver.serve_key
    expect(@keyserver.blocked_keys.key?(key)).to eq true
    sleep 60+1
    expect(@keyserver.blocked_keys.key?(key)).to eq false
  end
end

