# config/puma.rb

# Threads: use the same number for min/max.
max_threads_count = ENV.fetch("RAILS_MAX_THREADS", 5).to_i
min_threads_count = ENV.fetch("RAILS_MIN_THREADS", max_threads_count).to_i
threads min_threads_count, max_threads_count

# Port Heroku provides PORT in env; locally defaults to 3000.
port ENV.fetch("PORT", 3000)

# Environment defaults to development locally; Heroku sets RAILS_ENV=production.
environment ENV.fetch("RAILS_ENV", "development")

# PID file (Heroku ignores, but safe locally).
pidfile ENV.fetch("PIDFILE", "tmp/pids/server.pid")

# Allow `bin/rails restart`
plugin :tmp_restart

# Scale with multiple workers in production (Heroku dynos)
# Only set workers if WEB_CONCURRENCY is present; default 2 in production.
workers_count = ENV.fetch("WEB_CONCURRENCY", ENV["RAILS_ENV"] == "production" ? 2 : 0).to_i
workers workers_count if workers_count > 0

# Preload for copy-on-write memory savings on Heroku
preload_app!

# Reconnect Active Record in each worker
on_worker_boot do
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection_pool.disconnect! rescue nil
    ActiveRecord::Base.establish_connection
  end
end

# Optional: Solid Queue supervisor inside Puma for single-server deploys
plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]
