Eye.application('pittapi') do
  uid 'pittapi'
  gid 'pittapi'
  working_dir '/u/apps/pittapi/current'

  process 'gunicorn' do
    pid_file '/u/apps/pittapi/pids/gunicorn.pid'

    start_command '../bin/gunicorn -p /u/apps/pittapi/pids/gunicorn.pid -b unix:/u/apps/pittapi/sockets/gunicorn.sock -w 1 -D server:apiwrapper'
    stop_command 'kill -QUIT {PID}'
    restart_command 'kill -USR2 {PID}'

    start_grace 5.seconds
    stop_grace 5.seconds
    restart_grace 10.seconds

    monitor_children do
      stop_command 'kill -QUIT {PID}'
    end
  end
end
