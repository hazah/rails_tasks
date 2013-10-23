require 'active_support/concern'
require 'active_support/dependencies'
require 'action_controller/metal/renderers'
require 'rack/rewindable_input'

module RailsTasks
  module ActionView
    extend ActiveSupport::Concern

    def render(options = {}, locals = {}, &block)
      if options.is_a?(Hash) && options.has_key?(:controller)
        controller._handle_render_options(options).try(:html_safe) || super
      else
        super
      end
    end
  end
end

# The controller renderer dispatches to any other ActionController.
ActionController::Renderers.add :controller do |controller, options|
  const_name = "#{controller.to_s.camelize}Controller"
  controller = ActiveSupport::Dependencies.constantize(const_name)

  # Do not affect the surrounding environment directly through the controller,
  # copy it back in after instead.
  new_env = request.env.dup
  new_env["action_dispatch.request.path_parameters"].merge! options

  status, headers, response = controller.action(options[:action]).call(new_env)

  # The status & headers allow us to redirect from within the controller stack.
  self.status = status
  self.headers.merge! headers
  self.response_body = response.body
end

ActiveSupport.on_load :action_view do
  include RailsTasks::ActionView
end
