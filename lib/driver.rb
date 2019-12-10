# Using https://github.com/jstrait/nanosynth as reference/guide
class Driver
  def initialize(sample_rate: 44100)
    @sample_rate = sample_rate

    @time = 0.0
    @time_step = 1.0 / @sample_rate
    @max_sample = 0xff
    @pipe = IO.popen("aplay -r #{@sample_rate} -f U8", "w")
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
    # 44100 / 20 => 2205
    @sample_rate.times do |i|
      samples << clip(instrument.sample(@time), 1.0)# * @max_sample

      @time += @time_step
    end

    @pipe.write( samples.map { |sample| (sample * 127.0).round + 128 }.pack("C*") )
  end

  def close
    @pipe.close
  end
end