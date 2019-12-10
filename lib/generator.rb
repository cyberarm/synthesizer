module Synthesizer
  module Generator
    def generate(type, hertz, time)
      case type
      when :sine
        return Math.sin(w(hertz) * time)

      when :saw_analog
	      output = 0.0

        40.times do |i|
          n = i.to_f + 1

          output += (Math.sin(n * w(hertz) * time)) / n
        end

        return output * (2.0 / Math::PI)

      else
        raise ArgumentError, "Unknown Generator type: #{type.inspect}"
      end
    end

    def w(hertz)
      hertz * 2.0 * Math::PI
    end
  end
end