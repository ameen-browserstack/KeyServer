require 'thread'
require 'thread_safe'

class KeyServer
  attr_reader :available_keys, :blocked_keys
  def initialize
    @available_keys = ThreadSafe::Hash.new(0)
    @blocked_keys = ThreadSafe::Hash.new(0)
    @last_accessed = ThreadSafe::Hash.new
  end

  def delete_key_after_5_min (key)
    Thread.new do
      sleep 5*60
      if Time.now - @last_accessed[key] >= 5*60
        delete_key(key)
      end
    end      
  end

  def generate_keys(n)
    n.times do 
      key = random_key
      @available_keys[key] = 1
      @last_accessed[key] = Time.now

      delete_key_after_5_min key
    end
  end

  def serve_key
    if @available_keys.size  == 0
      "404"
    else
      key = @available_keys.first.first
      @available_keys.delete key
      @blocked_keys[key] = 1
      Thread.new do
        sleep 60
        unblock_key(key)
      end
      key
    end
  end

  def unblock_key(key)
    if @blocked_keys[key] == 1
      @blocked_keys.delete(key)
      @available_keys[key] = 1
    end
  end

  def delete_key(key)
    @available_keys.delete key
    @blocked_keys.delete key
  end

  def keep_alive(key)
    @last_accessed[key] = Time.now
    delete_key_after_5_min key
  end

  def random_key
    (0...8).map { (65 + rand(26)).chr }.join
  end

  def to_s
    @available_keys.to_s + "\n" + @blocked_keys.to_s
  end
end


