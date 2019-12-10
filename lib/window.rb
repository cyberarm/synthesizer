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
    end

    def draw
      @font.draw_text("Running on #{OS.linux? ? 'Linux :-)' : 'not Linux :-('}", 10, 10, 0)
    end

    def update
      @instrument.update
      self.caption = "Synthesizer (#{Gosu.fps} fps)"
    end

    def button_down(id)
    end

    def button_up(id)
    end
  end
end