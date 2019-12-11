# Using https://github.com/jstrait/nanosynth as reference/guide
class Driver
  attr_reader :time
  def initialize(sample_rate: 44100)
    @sample_rate = sample_rate

    @time = 0.0
    @time_step = 1.0 / @sample_rate
    @max_sample = 0xff
    @pipe = IO.popen("aplay --rate #{@sample_rate} --format U8", "w")
  end

  def run(instrument)
    Thread.new do
      while(!@pipe.closed?)
        play(instrument)
      end
    end
  end

  def clip(sample, max)
    if sample >= 0.0
      [sample, max].min
    else
      [sample, -max].max
    end
  end

  def play(instrument)
    samples = []
    @sample_rate.times do |i|
      samples << ((clip(instrument.sample(@time), 1.0) * 127.0).round + 128)# * @max_sample

      @time += @time_step
    end

    @pipe.write( samples.pack("C*") ) if samples.size > 0
  end

  def close
    @pipe.close
  end
end