# typed: strict

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `minitest-retry` gem.
# Please instead update this file by running `bin/tapioca gem minitest-retry`.

module Minitest
  class << self
    def __run(reporter, options); end
    def after_run(&block); end
    def autorun; end
    def backtrace_filter; end
    def backtrace_filter=(_arg0); end
    def clock_time; end
    def extensions; end
    def extensions=(_arg0); end
    def filter_backtrace(bt); end
    def info_signal; end
    def info_signal=(_arg0); end
    def init_plugins(options); end
    def load_plugins; end
    def parallel_executor; end
    def parallel_executor=(_arg0); end
    def process_args(args = T.unsafe(nil)); end
    def reporter; end
    def reporter=(_arg0); end
    def run(args = T.unsafe(nil)); end
    def run_one_method(klass, method_name); end
  end
end

Minitest::ENCS = T.let(T.unsafe(nil), TrueClass)

module Minitest::Retry
  class << self
    def consistent_failure_callback; end
    def exceptions_to_retry; end
    def failure_callback; end
    def failure_to_retry?(failures = T.unsafe(nil), klass_method_name); end
    def io; end
    def methods_to_retry; end
    def on_consistent_failure(&block); end
    def on_failure(&block); end
    def on_retry(&block); end
    def prepended(base); end
    def retry_callback; end
    def retry_count; end
    def use!(retry_count: T.unsafe(nil), io: T.unsafe(nil), verbose: T.unsafe(nil), exceptions_to_retry: T.unsafe(nil), methods_to_retry: T.unsafe(nil)); end
    def verbose; end
  end
end

module Minitest::Retry::ClassMethods
  def run_one_method(klass, method_name); end
end

Minitest::Retry::VERSION = T.let(T.unsafe(nil), String)
Minitest::VERSION = T.let(T.unsafe(nil), String)
