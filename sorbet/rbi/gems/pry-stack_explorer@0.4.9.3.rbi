# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `pry-stack_explorer` gem.
# Please instead update this file by running `bin/tapioca gem pry-stack_explorer`.

module PryStackExplorer
  class << self
    def bindings_equal?(b1, b2); end
    def clear_frame_managers(_pry_); end
    def create_and_push_frame_manager(bindings, _pry_, options = T.unsafe(nil)); end
    def delete_frame_managers(_pry_); end
    def frame_hash; end
    def frame_manager(_pry_); end
    def frame_managers(_pry_); end
    def pop_frame_manager(_pry_); end

    private

    def pop_helper(popped_fm, _pry_); end
    def push_helper(fm, options = T.unsafe(nil)); end
  end
end

PryStackExplorer::Commands = T.let(T.unsafe(nil), Pry::CommandSet)

module PryStackExplorer::FrameHelpers
  private

  def find_frame_by_block(up_or_down); end
  def find_frame_by_object_regex(class_regex, method_regex, up_or_down); end
  def find_frame_by_regex(regex, up_or_down); end
  def frame_description(b); end
  def frame_info(b, verbose = T.unsafe(nil)); end
  def frame_manager; end
  def frame_managers; end
  def prior_context_exists?; end
  def signature_with_owner(meth_obj); end
end

class PryStackExplorer::FrameManager
  include ::Enumerable

  def initialize(bindings, _pry_); end

  def binding_index; end
  def binding_index=(_arg0); end
  def bindings; end
  def bindings=(_arg0); end
  def change_frame_to(index, run_whereami = T.unsafe(nil)); end
  def current_frame; end
  def each(&block); end
  def prior_backtrace; end
  def prior_binding; end
  def refresh_frame(run_whereami = T.unsafe(nil)); end
  def set_binding_index_safely(index); end
  def user; end
end

PryStackExplorer::VERSION = T.let(T.unsafe(nil), String)

class PryStackExplorer::WhenStartedHook
  include ::Pry::Helpers::BaseHelpers

  def call(target, options, _pry_); end
  def caller_bindings(target); end

  private

  def internal_frames_with_indices(bindings); end
  def nested_session?(bindings); end
  def pry_method_frame?(binding); end
  def remove_debugger_frames(bindings); end
  def remove_internal_frames(bindings); end
  def valid_call_stack?(bindings); end
end

SE = PryStackExplorer
