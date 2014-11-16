Eye.application('handy') do
  uid 'handy'
  gid 'handy'
  working_dir '/u/apps/handy/current'

  process 'unicorn' do
    pid_file '/u/apps/handy/shared/pids/unicorn.pid'

    start_command 'bundle exec unicorn -c config/unicorn.rb -E production -D'
    stop_command 'kill -QUIT {PID}'
    restart_command 'kill -USR2 {PID}'

    restart_grace 10.seconds

    monitor_children do
      stop_command 'kill -QUIT {PID}'
    end
  end

  process 'resque' do
    pid_file '/u/apps/handy/shared/pids/resque.pid'

    start_command 'bundle exec resque-pool -p /u/apps/handy/shared/pids/resque.pid -E production -d'
    stop_command 'kill -QUIT {PID}'

    restart_grace 10.seconds

    monitor_children do
      stop_command 'kill -QUIT {PID}'
    end
  end
end
