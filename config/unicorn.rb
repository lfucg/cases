worker_processes 2

app_dir = File.expand_path(File.join(File.dirname(__FILE__), '..'))
working_directory app_dir

stderr_path "#{app_dir}/log/unicorn.stderr.log"
stdout_path "#{app_dir}/log/unicorn.stderr.log"
pid "#{app_dir}/tmp/pids/unicorn_geoevents.pid"

preload_app true
timeout 30
listen 3003, tcp_nopush: true
listen "#{app_dir}/tmp/sockets/unicorn.geoevents.sock"

GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
