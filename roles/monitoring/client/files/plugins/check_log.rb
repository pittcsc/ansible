#!/usr/bin/env ruby
require 'sensu-plugin/check/cli'
require 'fileutils'

class CheckLog < Sensu::Plugin::Check::CLI
  BASE_DIR = '/u/sensu/cache/check_log'

  option :state_file_directory,
    description: 'Set state file name',
    short: '-n NAME',
    long: '--name NAME',
    proc: proc { |arg| "#{BASE_DIR}/#{arg}" }

  option :file_path,
    description: 'Path to log file',
    short: '-f FILE',
    long: '--file FILE'

  option :file_encoding,
    description: 'Encoding of the log file',
    short: '-e ENCODING',
    long: '--encoding ENCODING'

  option :pattern,
    description: 'Pattern to search for in file',
    short: '-p PAT',
    long: '--pattern PAT'

  option :warning,
    description: 'Warning threshold for number of matches since last check',
    short: '-w N',
    long: '--warn N',
    proc: proc(&:to_i)

  option :critical,
    description: 'Critical threshold for number of matches since last check',
    short: '-c N',
    long: '--crit N',
    proc: proc(&:to_i)

  def run
    unknown 'No file path specified' unless config[:file_path]
    unknown 'No pattern specified' unless config[:pattern]

    message "Found #{new_matches_count} matches for #{config[:pattern]}"
    if new_matches_count > config[:critical]
      critical
    elsif new_matches_count > config[:warning]
      warning
    else
      ok
    end
  rescue => e
    unknown "Error: #{e}"
  end

  private
    def new_matches_count
      @new_matches_count ||= search_log
    end

    def search_log
      new_matches_count = 0

      open_log_file do |file|
        new_bytes_read = 0

        file.each_line do |line|
          new_bytes_read += line.size
          new_matches_count += 1 if line.match(config[:pattern])
        end

        update_state_file bytes_to_skip + new_bytes_read
      end

      new_matches_count
    end

    def open_log_file
      File.open(absolute_file_path, "r:#{file_encoding}") do |file|
        file.seek(bytes_to_skip) if bytes_to_skip > 0
        yield file
      end
    end

    def bytes_to_skip
      @bytes_to_skip ||= read_bytes_to_skip_from_state_file
    end

    def read_bytes_to_skip_from_state_file
      File.open(absolute_state_file_path) do |file|
        file.readline.to_i
      end
    rescue
      0
    end

    def update_state_file(bytes_read)
      File.open(absolute_state_file_path, 'w') do |file|
        file.write(bytes_read)
      end
    end

    def absolute_state_file_path
      @absolute_state_file_path ||= File.join(config[:state_file_directory], absolute_file_path)
    end

    def absolute_file_path
      @absolute_file_path ||= File.expand_path(config[:file_path])
    end

    def file_encoding
      config[:file_encoding] || 'US-ASCII'
    end
end
