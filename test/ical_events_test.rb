# frozen_string_literal: true

require "minitest/autorun"
require "rbconfig"
load File.expand_path("../ical_events", __dir__)

class IcalEventsTest < Minitest::Test
  def setup
    @events = [
      Event.new(title: "Keep", calendar: "Work", urls: ["https://example.com/keep"]),
      Event.new(title: "Skip", calendar: "Personal", urls: ["https://example.com/skip"]),
    ]
  end

  def test_predicate_preserves_original_events
    selected = filter_events(@events, '.title != "Skip"')
    assert_equal [@events.first], selected
    assert_same @events.first, selected.first
  end

  def test_jq_truthiness_and_multiple_results
    ["true", "0", '""', "false, true"].each do |expression|
      assert_equal @events, filter_events(@events, expression), expression
    end
    ["false", "null", "empty", "false, null"].each do |expression|
      assert_empty filter_events(@events, expression), expression
    end
  end

  def test_optional_filter_and_empty_input
    assert_same @events, filter_events(@events, nil)
    assert_empty filter_events([], "true")
  end

  def run_cli(*args, env: {})
    script = <<~'RUBY'
      load "./ical_events"
      def configuration
        {}
      end
      def require_icalbuddy(*)
      end
      def get_calendars
        [Calendar.new(title: "Work", uid: "work")]
      end
      def get_events(_calendars, argv)
        abort "unexpected arguments: #{argv.inspect}" unless argv == ["eventsNow"]
        [Event.new(title: "Keep", urls: ["https://example.com/keep"]),
         Event.new(title: "Skip", urls: ["https://example.com/skip"])]
      end
      def get_reminders
        [Reminder.new(title: "Keep", urls: ["https://example.com/keep"]),
         Reminder.new(title: "Skip", urls: ["https://example.com/skip"])]
      end
      def open_event_urls(events)
        warn "opened: #{events.map(&:title).join(',')}"
        true
      end
      main
    RUBY
    Open3.capture3(env, RbConfig.ruby, "-e", script, "--", *args,
                   chdir: File.expand_path("..", __dir__))
  end

  def test_cli_filters_output_and_urls_with_options_anywhere
    [["--jq", '.title != "Skip"', "--open-urls", "eventsNow"],
     ["eventsNow", "--open-urls", "--jq", '.title != "Skip"'],
     ["reminders", "--jq", '.title != "Skip"', "--open-urls"]].each do |args|
      out, err, status = run_cli(*args)
      assert status.success?, err
      assert_equal ["Keep"], JSON.parse(out).map { |event| event.fetch("title") }
      assert_equal "opened: Keep\n", err
    end
  end

  def test_jq_errors_prevent_opening_urls
    ["(", 'error("test failure")'].each do |expression|
      out, err, status = run_cli("--open-urls", "--jq", expression)
      refute status.success?
      assert_empty out
      assert_includes err, "--jq:"
      refute_includes err, "opened:"
    end
  end

  def test_missing_expression
    out, err, status = run_cli("--jq")
    refute status.success?
    assert_empty out
    assert_includes err, "--jq requires an expression"
  end

  def test_missing_jq
    out, err, status = run_cli("--open-urls", "--jq", "true", env: { "PATH" => "" })
    refute status.success?
    assert_empty out
    assert_includes err, "--jq requires jq on PATH"
    refute_includes err, "opened:"
  end
end
