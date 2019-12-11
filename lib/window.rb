module Synthesizer
  class Window < Gosu::Window
    def initialize(width: 640, height: 480, resizable: false)
      super(width, height, resizable: false)
      self.caption = "Synthesizer"
      @instrument = Instrument::Saw.new
      @driver = Driver.new
      @driver.run(@instrument)

      at_exit do
        @driver.close
      end

      @font = Gosu::Font.new(28)
      @keys = "zxcvbnm,./".chars
      @base_freq = 110.0
      @stride_freq = 2.0 ** (1.0 / 12.0)
    end

    def draw
      @font.draw_text("Running on #{OS.linux? ? 'Linux :-)' : 'not Linux :-('}", 10, 10, 0)
    end

    def update
      @instrument.update
      self.caption = "Synthesizer (#{Gosu.fps} fps)"
    end

    def button_down(id)
      if index = get_key(id)
        @instrument.key_down(id, @driver.time, @base_freq + (@stride_freq * index))
      end
    end

    def button_up(id)
      if index = get_key(id)
        @instrument.key_released(id, @driver.time)
      end
    end

    def get_key(id)
      @keys.index( Gosu.button_id_to_char(id) )
    end
  end
end