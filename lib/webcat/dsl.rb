module Webcat
  class << self
    attr_writer :default_driver, :current_driver

    attr_accessor :app

    def default_driver
      @default_driver || :rack_test
    end

    def current_driver
      @current_driver || default_driver 
    end
    alias_method :mode, :current_driver

    def use_default_driver
      @current_driver = nil 
    end

    def current_session
      session_pool["#{current_driver}#{app.object_id}"] ||= Webcat::Session.new(current_driver, app)
    end
    
    def reset_sessions!
      @session_pool = nil
    end

  private

    def session_pool
      @session_pool ||= {}
    end
  end

  extend(self)

  def page
    Webcat.current_session
  end

  SESSION_METHODS = [
    :visit, :body, :click_link, :click_button, :fill_in, :choose, :has_xpath?, :has_css?,
    :check, :uncheck, :attach_file, :select, :has_content?, :within, :save_and_open_page
  ]
  SESSION_METHODS.each do |method|
    class_eval <<-RUBY, __FILE__, __LINE__+1
      def #{method}(*args, &block)
        page.#{method}(*args, &block)
      end
    RUBY
  end

end
