Eye.application('slackin') do
  uid 'slackin'
  gid 'slackin'
  working_dir '/home/slackin'

  process 'slackin' do
    pid_file '/home/slackin/slackin.pid'

    start_command 'slackin -p "{{ slackin_port }}" -s "{{ slackin_subdomain }}" "{{ slackin_api_token }}"'

    start_grace 5.seconds
    stop_grace 5.seconds
    restart_grace 10.seconds

    daemonize true
  end
end
