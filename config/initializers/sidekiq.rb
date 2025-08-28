require 'sidekiq'
require 'sidekiq-scheduler'
require 'yaml'

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0') }
  config.on(:startup) do
    schedule_file = Rails.root.join('config', 'schedule.yml')

    if File.exist?(schedule_file)
      Sidekiq.schedule = YAML.load_file(schedule_file)
      
      Rails.logger.info "Loaded Sidekiq schedule from #{schedule_file}"
    else
      Rails.logger.warn "Schedule file not found: #{schedule_file}"
    end
    
    SidekiqScheduler::Scheduler.instance.reload_schedule!
    Rails.logger.info "Sidekiq scheduler reloaded with #{Sidekiq.schedule.keys.count} jobs"
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0') }
end