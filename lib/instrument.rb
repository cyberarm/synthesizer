module Synthesizer
  class Instrument
    include Generator

    def initialize
      @notes = {}

      @volume = 0.4
    end

    def key_down(key, time, frequency)
      @notes[key] = Note.new(frequency: frequency)
      @notes[key].on(time)
    end

    def key_released(key, time)
      @notes[key].off(time) if @notes[key]
    end

    def sample(time)
      @notes.delete_if { |key, note| note.done? }

      result = 0.0

      @notes.values.each do |note|
        result += note.amplitude(time) * sound(time, note.frequency)
      end

      return result * @volume
    end

    def sound(time, frequency)
      ( 1.0 + generate(:sine, frequency * 0.5, time) ) +
      ( 1.0 + generate(:saw_analog, frequency, time) )
    end

    def update
    end
  end

  class Note
    attr_reader :frequency, :attack_time, :decay_time, :start_amplitude, :sustain_amplitude,
                :release_time, :trigger_off_time, :trigger_on_time
    attr_accessor :on
    def initialize(frequency:, attack_time: 0.1, decay_time: 0.01, start_amplitude: 1.0, sustain_amplitude: 0.8, release_time: 0.20)
      @frequency = frequency

      @attack_time = attack_time
      @decay_time = decay_time
      @start_amplitude = start_amplitude
      @sustain_amplitude = sustain_amplitude
      @release_time = release_time

      @on = false
      @trigger_off_time = 0.0
      @trigger_on_time = 0.0

      @last_amplitude = 0.0
    end

    def on(time)
      @trigger_on_time = time
      @on = true
    end

    def off(time)
      @trigger_off_time = time
      @on = false
    end

    def amplitude(time)
      _amplitude = 0.0
      _life_time = time - @trigger_on_time

      if @on
        if _life_time < @attack_time
          _amplitude = (_life_time / @attack_time) * @start_amplitude
        end

        if  _life_time > @attack_time && _life_time <= (@attack_time + @decay_time)
          _amplitude = ((_life_time - @attack_time) / @decay_time) * (@sustain_amplitude - @start_amplitude) + @start_amplitude
        end

        if _life_time > (@attack_time + @decay_time)
          _amplitude = @sustain_amplitude
        end
      else
        _amplitude = ((time - @trigger_off_time) / @release_time) * (0.0 - @sustain_amplitude) + @sustain_amplitude
      end

      _amplitude = 0.0 if _amplitude < 0.001

      @last_amplitude = _amplitude
      return _amplitude
    end

    def done?
      !@on && @trigger_off_time > @trigger_on_time && @last_amplitude <= 0.0
    end
  end
end