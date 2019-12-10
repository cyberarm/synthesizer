# Using https://github.com/jstrait/nanosynth as reference/guide
class Driver
  CACHE = {}
  def initialize(type: :sine, freq:, duration: 0.1, amplitude: 1.0, sample_rate: 44100)
    @type = type
    @freq = freq
    @duration = duration
    @amplitude= amplitude
    @sample_rate = sample_rate

    @pipe = IO.popen("aplay -r 44100 -f U8", "w")
  end

  def generate(number_of_samples)
    samples = [].fill(0.0, 0, number_of_samples)
    position_in_period = 0.0
    position_in_period_delta = @freq.to_f / @sample_rate

    number_of_samples.times do |i|
      case @type
      when :sine
        samples[i] = Math.sin((position_in_period * (Math::PI*2)) * @amplitude)
      when :square
        samples[i] = (position_in_period >= 0.5) ? @amplitude : -@amplitude
      when :saw
        samples[i] = ((position_in_period * 2.0) - 1.0) * @amplitude
      when :triangle
        samples[i] = @amplitude - (((position_in_period * 2.0) - 1.0) * @amplitude * 2.0).abs
      when :noise
        samples[i] = rand(-@amplitude..@amplitude)
      end

      position_in_period += position_in_period_delta

      if(position_in_period >= 1.0)
        position_in_period -= 1.0
      end
    end

    return samples
  end

  def play
    # 44100 / 20 => 2205
    samples = generate(2205)

    @pipe.write( samples.map { |sample| (sample * 127.0).round + 128 }.pack("C*") )
  end

  def close
    @pipe.close
  end
end


tone = ToneGenerator.new(type: :sine, freq: 4400)
loop do
  tone.play
end

at_exit do
  tone.close
end