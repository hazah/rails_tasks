require 'active_support/concern'
require 'active_support/dependencies'
require 'action_controller/metal/renderers'
require 'rack/rewindable_input'

module RailsTasks
  extend ActiveSupport::Concern
  
  ActionController::Renderers.add :controller do |controller, options|
    const_name = "#{controller.to_s.camelize}Controller"
    controller = ActiveSupport::Dependencies.constantize(const_name)
    
    new_env = env.dup
    new_env["action_dispatch.request.path_parameters"] ||= {}
    new_env["rack.input"] ||= Rack::RewindableInput.new($stdin)
    new_env["REQUEST_METHOD"] ||= 'GET'
    
    new_env["action_dispatch.request.path_parameters"].merge! options
    
    s, h, r = controller.action(options[:action]).call(new_env)
    
    self.status = s
    self.headers.merge! h
    
    self.response_body = r.body
  end
  
  ActiveSupport.on_load :action_view do
    include RailsTasks
  end
  
  def render(options = {}, locals = {}, &block)
    if options.is_a?(Hash) && options.has_key?(:controller)
      controller._handle_render_options(options).html_safe || super
    else
      super
    end
  end
  
end
