require 'rspec'

class RSpecDoc::MarkdownFormatter
  RSpec::Core::Formatters.register self, :example_group_started, :example_group_finished, :example_finished,
                      :example_passed, :example_pending, :example_failed, :message, :dump_failures,
                      :dump_summary, :dump_summary, :dump_pending, :seed

  # All formatters inheriting from this formatter will receive these
  # notifications.
  attr_accessor :example_group
  attr_reader :output

  # @api public
  # @param output [IO] the formatter output
  # @see RSpec::Core::Formatters::Protocol#initialize
  def initialize(output)
    @output = output || StringIO.new
    @example_group = nil
    @group_level = 0    
  end

  # @api public
  #
  # @param notification [StartNotification]
  # @see RSpec::Core::Formatters::Protocol#start
  def start(notification)
    start_sync_output
    @example_count = notification.count
  end

  # @api public
  #
  # @param _notification [NullNotification] (Ignored)
  # @see RSpec::Core::Formatters::Protocol#close
  def close(_notification)
    return if output.closed?

    output.puts

    output.flush
  end

  # @api public
  #
  # Used by the reporter to send messages to the output stream.
  #
  # @param notification [MessageNotification] containing message
  def message(notification)
    output.puts "#{space_indentation}#{notification.message}"
  end

  # @api public
  #
  # Dumps detailed information about each example failure.
  #
  # @param notification [NullNotification]
  def dump_failures(notification)
    return if notification.failure_notifications.empty?
    output.puts notification.fully_formatted_failed_examples
  end

  # @api public
  #
  # This method is invoked after the dumping of examples and failures.
  # Each parameter is assigned to a corresponding attribute.
  #
  # @param summary [SummaryNotification] containing duration,
  #   example_count, failure_count and pending_count
  def dump_summary(summary)
    output.puts summary.fully_formatted
  end

  # @private
  def dump_pending(notification)
    return if notification.pending_examples.empty?
    output.puts notification.fully_formatted_pending_examples
  end

  # @private
  def seed(notification)
    return unless notification.seed_used?
    output.puts notification.fully_formatted
  end

  def example_group_started(notification)
    output.puts if @group_level == 0
    output.puts "#{current_indentation}#{notification.group.description.strip}"
    @group_level += 1
  end

  def example_group_finished(_notification)
    @group_level -= 1 if @group_level > 0    
  end

  def example_finished(notification)
  end

  def output_doc(example)
    return unless example.metadata[:md_doc].is_a? Hash
    output.puts
    example.metadata[:md_doc].each do |key, items|
      output.puts "  #{space_indentation}#### #{key.to_s.split('_').map(&:capitalize).join(' ')}"
      items.each do |item| 
        output.puts
        item.each_line { |line| output.puts "  #{space_indentation}#{line}" }
      end
    end
    example.metadata[:md_doc] = {}
  end

  def example_passed(passed)
    output.puts passed_output(passed.example)
    output_doc(passed.example)
  end

  def example_pending(pending)
    output.puts pending_output(pending.example,
                              pending.example.execution_result.pending_message)
    output_doc(pending.example)
  end

  def example_failed(failure)
    output.puts failure_output(failure.example)
    output_doc(failure.example)
  end

private

  def start_sync_output
    @old_sync, output.sync = output.sync, true if output_supports_sync
  end

  def output_supports_sync
    output.respond_to?(:sync=)
  end

  def passed_output(example)
    "#{current_indentation}#{example.description.strip}"
  end

  def pending_output(example, message)
    "#{current_indentation}#{example.description.strip} \n(PENDING: #{message})"
  end

  def failure_output(example)
    "#{current_indentation}#{example.description.strip} \n(FAILED - #{next_failure_index})"
  end

  def next_failure_index
    @next_failure_index ||= 0
    @next_failure_index += 1
  end

  def current_indentation
    return "\n## " if @group_level == 0
    return "\n### " if @group_level == 1

    space_indentation << '- '
  end

  def space_indentation
    return '' if @group_level < 1
    '  ' * (@group_level - 1)
  end
end