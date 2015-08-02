Eye.application('heaven') do
  uid 'heaven'
  gid 'heaven'
  working_dir '/u/apps/heaven/current'

  env \
    'GITHUB_TOKEN' => '{{ heaven_github_token }}',
    'GITHUB_CLIENT_ID' => '{{ heaven_github_client_id }}',
    'GITHUB_CLIENT_SECRET' => '{{ heaven_github_client_secret }}',
    'RAILS_SECRET_KEY_BASE' => '{{ heaven_rails_secret_key_base }}',
    'REDIS_PROVIDER' => '{{ heaven_redis_provider }}',
    'DEPLOYMENT_PRIVATE_KEY' => '{{ heaven_deployment_private_key }}'

  process 'unicorn' do
    pid_file '/u/apps/heaven/shared/pids/unicorn.pid'

    start_command 'bundle exec unicorn -c config/unicorn.rb -E production -D'
    stop_command 'kill -QUIT {PID}'
    restart_command 'kill -USR2 {PID}'

    start_grace 5.seconds
    stop_grace 5.seconds
    restart_grace 10.seconds

    monitor_children do
      stop_command 'kill -QUIT {PID}'
    end
  end

  process 'resque' do
    pid_file '/u/apps/heaven/shared/pids/resque.pid'

    start_command 'bundle exec resque-pool -p /u/apps/heaven/shared/pids/resque.pid -E production -d'
    stop_command 'kill -QUIT {PID}'

    start_grace 5.seconds
    stop_grace 5.seconds
    restart_grace 10.seconds

    monitor_children do
      stop_command 'kill -QUIT {PID}'
    end
  end
end
