require './framework.rb'

# EXAMPLE of quick+dirty debug middleware:
#
# class WrapRck
#   def initialize(app)
#     @app = app
#   end
#
#   def call(env)
#     status, head, body = @app.call(env)
#     p ">>> |||RACK||| body: #{env['PATH_INFO']}"
#     # p body.first.encoding unless body.empty?
#     body.each { |b| p b.encoding } if env['PATH_INFO'].include?('/labels')
#     [status, head, body]
#   end
# end
# use WrapRck

run Framework
