# typed: ignore

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `actioncable` gem.
# Please instead update this file by running `bin/tapioca gem actioncable`.

module ActionCable
  extend ::ActiveSupport::Autoload

  private

  def server; end

  class << self
    def gem_version; end
    def server; end
    def version; end
  end
end

module ActionCable::Channel
  extend ::ActiveSupport::Autoload
end

class ActionCable::Channel::Base
  include ::ActiveSupport::Callbacks
  include ::ActionCable::Channel::Callbacks
  include ::ActionCable::Channel::PeriodicTimers
  include ::ActionCable::Channel::Streams
  include ::ActionCable::Channel::Naming
  include ::ActionCable::Channel::Broadcasting
  include ::ActiveSupport::Rescuable
  extend ::ActiveSupport::Callbacks::ClassMethods
  extend ::ActiveSupport::DescendantsTracker
  extend ::ActionCable::Channel::Callbacks::ClassMethods
  extend ::ActionCable::Channel::PeriodicTimers::ClassMethods
  extend ::ActionCable::Channel::Naming::ClassMethods
  extend ::ActionCable::Channel::Broadcasting::ClassMethods
  extend ::ActiveSupport::Rescuable::ClassMethods

  def initialize(connection, identifier, params = T.unsafe(nil)); end

  def __callbacks; end
  def __callbacks?; end
  def _run_subscribe_callbacks(&block); end
  def _run_unsubscribe_callbacks(&block); end
  def _subscribe_callbacks; end
  def _unsubscribe_callbacks; end
  def connection; end
  def identifier; end
  def logger(*_arg0, &_arg1); end
  def params; end
  def perform_action(data); end
  def periodic_timers=(_arg0); end
  def rescue_handlers; end
  def rescue_handlers=(_arg0); end
  def rescue_handlers?; end
  def subscribe_to_channel; end
  def unsubscribe_from_channel; end

  private

  def action_signature(action, data); end
  def defer_subscription_confirmation!; end
  def defer_subscription_confirmation?; end
  def delegate_connection_identifiers; end
  def dispatch_action(action, data); end
  def ensure_confirmation_sent; end
  def extract_action(data); end
  def processable_action?(action); end
  def reject; end
  def reject_subscription; end
  def subscribed; end
  def subscription_confirmation_sent?; end
  def subscription_rejected?; end
  def transmit(data, via: T.unsafe(nil)); end
  def transmit_subscription_confirmation; end
  def transmit_subscription_rejection; end
  def unsubscribed; end

  class << self
    def __callbacks; end
    def __callbacks=(value); end
    def __callbacks?; end
    def _subscribe_callbacks; end
    def _subscribe_callbacks=(value); end
    def _unsubscribe_callbacks; end
    def _unsubscribe_callbacks=(value); end
    def action_methods; end
    def periodic_timers; end
    def periodic_timers=(value); end
    def periodic_timers?; end
    def rescue_handlers; end
    def rescue_handlers=(value); end
    def rescue_handlers?; end

    private

    def clear_action_methods!; end
    def method_added(name); end
  end
end

module ActionCable::Channel::Broadcasting
  extend ::ActiveSupport::Concern

  mixes_in_class_methods ::ActionCable::Channel::Broadcasting::ClassMethods

  def broadcast_to(*_arg0, &_arg1); end
  def broadcasting_for(*_arg0, &_arg1); end
end

module ActionCable::Channel::Broadcasting::ClassMethods
  def broadcast_to(model, message); end
  def broadcasting_for(model); end
  def serialize_broadcasting(object); end
end

module ActionCable::Channel::Callbacks
  extend ::ActiveSupport::Concern
  include GeneratedInstanceMethods
  include ::ActiveSupport::Callbacks

  mixes_in_class_methods GeneratedClassMethods
  mixes_in_class_methods ::ActiveSupport::Callbacks::ClassMethods
  mixes_in_class_methods ::ActiveSupport::DescendantsTracker
  mixes_in_class_methods ::ActionCable::Channel::Callbacks::ClassMethods

  module GeneratedClassMethods
    def __callbacks; end
    def __callbacks=(value); end
    def __callbacks?; end
  end

  module GeneratedInstanceMethods
    def __callbacks; end
    def __callbacks?; end
  end
end

module ActionCable::Channel::Callbacks::ClassMethods
  def after_subscribe(*methods, &block); end
  def after_unsubscribe(*methods, &block); end
  def before_subscribe(*methods, &block); end
  def before_unsubscribe(*methods, &block); end
  def on_subscribe(*methods, &block); end
  def on_unsubscribe(*methods, &block); end
end

module ActionCable::Channel::ChannelStub
  def confirmed?; end
  def rejected?; end
  def start_periodic_timers; end
  def stop_all_streams; end
  def stop_periodic_timers; end
  def stream_from(broadcasting, *_arg1); end
  def streams; end
end

class ActionCable::Channel::ConnectionStub
  def initialize(identifiers = T.unsafe(nil)); end

  def identifiers; end
  def logger; end
  def subscriptions; end
  def transmissions; end
  def transmit(cable_message); end
end

module ActionCable::Channel::Naming
  extend ::ActiveSupport::Concern

  mixes_in_class_methods ::ActionCable::Channel::Naming::ClassMethods

  def channel_name(*_arg0, &_arg1); end
end

module ActionCable::Channel::Naming::ClassMethods
  def channel_name; end
end

class ActionCable::Channel::NonInferrableChannelError < ::StandardError
  def initialize(name); end
end

module ActionCable::Channel::PeriodicTimers
  extend ::ActiveSupport::Concern
  include GeneratedInstanceMethods

  mixes_in_class_methods GeneratedClassMethods
  mixes_in_class_methods ::ActionCable::Channel::PeriodicTimers::ClassMethods

  private

  def active_periodic_timers; end
  def start_periodic_timer(callback, every:); end
  def start_periodic_timers; end
  def stop_periodic_timers; end

  module GeneratedClassMethods
    def periodic_timers; end
    def periodic_timers=(value); end
    def periodic_timers?; end
  end

  module GeneratedInstanceMethods
    def periodic_timers=(value); end
  end
end

module ActionCable::Channel::PeriodicTimers::ClassMethods
  def periodically(callback_or_method_name = T.unsafe(nil), every:, &block); end
end

module ActionCable::Channel::Streams
  extend ::ActiveSupport::Concern

  def pubsub(*_arg0, &_arg1); end
  def stop_all_streams; end
  def stop_stream_for(model); end
  def stop_stream_from(broadcasting); end
  def stream_for(model, callback = T.unsafe(nil), coder: T.unsafe(nil), &block); end
  def stream_from(broadcasting, callback = T.unsafe(nil), coder: T.unsafe(nil), &block); end
  def stream_or_reject_for(record); end

  private

  def default_stream_handler(broadcasting, coder:); end
  def identity_handler; end
  def stream_decoder(handler = T.unsafe(nil), coder:); end
  def stream_handler(broadcasting, user_handler, coder: T.unsafe(nil)); end
  def stream_transmitter(handler = T.unsafe(nil), broadcasting:); end
  def streams; end
  def worker_pool_stream_handler(broadcasting, user_handler, coder: T.unsafe(nil)); end
end

class ActionCable::Channel::TestCase < ::ActiveSupport::TestCase
  include ::ActiveSupport::Testing::ConstantLookup
  include ::ActionCable::TestHelper
  include ::ActionCable::Channel::TestCase::Behavior
  extend ::ActiveSupport::Testing::ConstantLookup::ClassMethods
  extend ::ActionCable::Channel::TestCase::Behavior::ClassMethods

  def _channel_class; end
  def _channel_class=(_arg0); end
  def _channel_class?; end
  def connection; end
  def subscription; end

  class << self
    def _channel_class; end
    def _channel_class=(value); end
    def _channel_class?; end
  end
end

module ActionCable::Channel::TestCase::Behavior
  include ::ActionCable::TestHelper
  extend ::ActiveSupport::Concern
  include GeneratedInstanceMethods
  include ::ActiveSupport::Testing::ConstantLookup

  mixes_in_class_methods GeneratedClassMethods
  mixes_in_class_methods ::ActiveSupport::Testing::ConstantLookup::ClassMethods
  mixes_in_class_methods ::ActionCable::Channel::TestCase::Behavior::ClassMethods

  def assert_broadcast_on(stream_or_object, *args); end
  def assert_broadcasts(stream_or_object, *args); end
  def assert_has_stream(stream); end
  def assert_has_stream_for(object); end
  def assert_no_streams; end
  def perform(action, data = T.unsafe(nil)); end
  def stub_connection(identifiers = T.unsafe(nil)); end
  def subscribe(params = T.unsafe(nil)); end
  def transmissions; end
  def unsubscribe; end

  private

  def broadcasting_for(stream_or_object); end
  def check_subscribed!; end

  module GeneratedClassMethods
    def _channel_class; end
    def _channel_class=(value); end
    def _channel_class?; end
  end

  module GeneratedInstanceMethods
    def _channel_class; end
    def _channel_class=(value); end
    def _channel_class?; end
  end
end

ActionCable::Channel::TestCase::Behavior::CHANNEL_IDENTIFIER = T.let(T.unsafe(nil), String)

module ActionCable::Channel::TestCase::Behavior::ClassMethods
  def channel_class; end
  def determine_default_channel(name); end
  def tests(channel); end
end

module ActionCable::Connection
  extend ::ActiveSupport::Autoload
end

module ActionCable::Connection::Assertions
  def assert_reject_connection(&block); end
end

module ActionCable::Connection::Authorization
  def reject_unauthorized_connection; end
end

class ActionCable::Connection::Authorization::UnauthorizedError < ::StandardError; end

class ActionCable::Connection::Base
  include ::ActionCable::Connection::Identification
  include ::ActionCable::Connection::InternalChannel
  include ::ActionCable::Connection::Authorization
  include ::ActiveSupport::Rescuable
  extend ::ActionCable::Connection::Identification::ClassMethods
  extend ::ActiveSupport::Rescuable::ClassMethods

  def initialize(server, env, coder: T.unsafe(nil)); end

  def beat; end
  def close(reason: T.unsafe(nil), reconnect: T.unsafe(nil)); end
  def dispatch_websocket_message(websocket_message); end
  def env; end
  def event_loop(*_arg0, &_arg1); end
  def identifiers; end
  def identifiers=(_arg0); end
  def identifiers?; end
  def logger; end
  def on_close(reason, code); end
  def on_error(message); end
  def on_message(message); end
  def on_open; end
  def process; end
  def protocol; end
  def pubsub(*_arg0, &_arg1); end
  def receive(websocket_message); end
  def rescue_handlers; end
  def rescue_handlers=(_arg0); end
  def rescue_handlers?; end
  def send_async(method, *arguments); end
  def server; end
  def statistics; end
  def subscriptions; end
  def transmit(cable_message); end
  def worker_pool; end

  private

  def allow_request_origin?; end
  def cookies; end
  def decode(websocket_message); end
  def encode(cable_message); end
  def finished_request_message; end
  def handle_close; end
  def handle_open; end
  def invalid_request_message; end
  def message_buffer; end
  def new_tagged_logger; end
  def request; end
  def respond_to_invalid_request; end
  def respond_to_successful_request; end
  def send_welcome_message; end
  def started_request_message; end
  def successful_request_message; end
  def websocket; end

  class << self
    def identifiers; end
    def identifiers=(value); end
    def identifiers?; end
    def rescue_handlers; end
    def rescue_handlers=(value); end
    def rescue_handlers?; end
  end
end

class ActionCable::Connection::ClientSocket
  def initialize(env, event_target, event_loop, protocols); end

  def alive?; end
  def client_gone; end
  def close(code = T.unsafe(nil), reason = T.unsafe(nil)); end
  def env; end
  def parse(data); end
  def protocol; end
  def rack_response; end
  def start_driver; end
  def transmit(message); end
  def url; end
  def write(data); end

  private

  def begin_close(reason, code); end
  def emit_error(message); end
  def finalize_close; end
  def open; end
  def receive_message(data); end

  class << self
    def determine_url(env); end
    def secure_request?(env); end
  end
end

ActionCable::Connection::ClientSocket::CLOSED = T.let(T.unsafe(nil), Integer)
ActionCable::Connection::ClientSocket::CLOSING = T.let(T.unsafe(nil), Integer)
ActionCable::Connection::ClientSocket::CONNECTING = T.let(T.unsafe(nil), Integer)
ActionCable::Connection::ClientSocket::OPEN = T.let(T.unsafe(nil), Integer)

module ActionCable::Connection::Identification
  extend ::ActiveSupport::Concern
  include GeneratedInstanceMethods

  mixes_in_class_methods GeneratedClassMethods
  mixes_in_class_methods ::ActionCable::Connection::Identification::ClassMethods

  def connection_identifier; end

  private

  def connection_gid(ids); end

  module GeneratedClassMethods
    def identifiers; end
    def identifiers=(value); end
    def identifiers?; end
  end

  module GeneratedInstanceMethods
    def identifiers; end
    def identifiers=(value); end
    def identifiers?; end
  end
end

module ActionCable::Connection::Identification::ClassMethods
  def identified_by(*identifiers); end
end

module ActionCable::Connection::InternalChannel
  extend ::ActiveSupport::Concern

  private

  def internal_channel; end
  def process_internal_message(message); end
  def subscribe_to_internal_channel; end
  def unsubscribe_from_internal_channel; end
end

class ActionCable::Connection::MessageBuffer
  def initialize(connection); end

  def append(message); end
  def process!; end
  def processing?; end

  private

  def buffer(message); end
  def buffered_messages; end
  def connection; end
  def receive(message); end
  def receive_buffered_messages; end
  def valid?(message); end
end

class ActionCable::Connection::NonInferrableConnectionError < ::StandardError
  def initialize(name); end
end

class ActionCable::Connection::Stream
  def initialize(event_loop, socket); end

  def close; end
  def each(&callback); end
  def flush_write_buffer; end
  def hijack_rack_socket; end
  def receive(data); end
  def shutdown; end
  def write(data); end

  private

  def clean_rack_hijack; end
end

class ActionCable::Connection::StreamEventLoop
  def initialize; end

  def attach(io, stream); end
  def detach(io, stream); end
  def post(task = T.unsafe(nil), &block); end
  def stop; end
  def timer(interval, &block); end
  def writes_pending(io); end

  private

  def run; end
  def spawn; end
  def wakeup; end
end

class ActionCable::Connection::Subscriptions
  def initialize(connection); end

  def add(data); end
  def execute_command(data); end
  def identifiers; end
  def logger(*_arg0, &_arg1); end
  def perform_action(data); end
  def remove(data); end
  def remove_subscription(subscription); end
  def unsubscribe_from_all; end

  private

  def connection; end
  def find(data); end
  def subscriptions; end
end

class ActionCable::Connection::TaggedLoggerProxy
  def initialize(logger, tags:); end

  def add_tags(*tags); end
  def debug(message); end
  def error(message); end
  def fatal(message); end
  def info(message); end
  def tag(logger); end
  def tags; end
  def unknown(message); end
  def warn(message); end

  private

  def log(type, message); end
end

class ActionCable::Connection::TestCase < ::ActiveSupport::TestCase
  include ::ActiveSupport::Testing::ConstantLookup
  include ::ActionCable::Connection::Assertions
  include ::ActionCable::Connection::TestCase::Behavior
  extend ::ActiveSupport::Testing::ConstantLookup::ClassMethods
  extend ::ActionCable::Connection::TestCase::Behavior::ClassMethods

  def _connection_class; end
  def _connection_class=(_arg0); end
  def _connection_class?; end
  def connection; end

  class << self
    def _connection_class; end
    def _connection_class=(value); end
    def _connection_class?; end
  end
end

module ActionCable::Connection::TestCase::Behavior
  include ::ActionCable::Connection::Assertions
  extend ::ActiveSupport::Concern
  include GeneratedInstanceMethods
  include ::ActiveSupport::Testing::ConstantLookup

  mixes_in_class_methods GeneratedClassMethods
  mixes_in_class_methods ::ActiveSupport::Testing::ConstantLookup::ClassMethods
  mixes_in_class_methods ::ActionCable::Connection::TestCase::Behavior::ClassMethods

  def connect(path = T.unsafe(nil), **request_params); end
  def cookies; end
  def disconnect; end

  private

  def build_test_request(path, params: T.unsafe(nil), headers: T.unsafe(nil), session: T.unsafe(nil), env: T.unsafe(nil)); end

  module GeneratedClassMethods
    def _connection_class; end
    def _connection_class=(value); end
    def _connection_class?; end
  end

  module GeneratedInstanceMethods
    def _connection_class; end
    def _connection_class=(value); end
    def _connection_class?; end
  end
end

module ActionCable::Connection::TestCase::Behavior::ClassMethods
  def connection_class; end
  def determine_default_connection(name); end
  def tests(connection); end
end

ActionCable::Connection::TestCase::Behavior::DEFAULT_PATH = T.let(T.unsafe(nil), String)

module ActionCable::Connection::TestConnection
  def initialize(request); end

  def logger; end
  def request; end
end

class ActionCable::Connection::TestCookieJar < ::ActiveSupport::HashWithIndifferentAccess
  def encrypted; end
  def signed; end
end

class ActionCable::Connection::TestRequest < ::ActionDispatch::TestRequest
  def cookie_jar; end
  def cookie_jar=(_arg0); end
  def session; end
  def session=(_arg0); end
end

class ActionCable::Connection::WebSocket
  def initialize(env, event_target, event_loop, protocols: T.unsafe(nil)); end

  def alive?; end
  def close; end
  def possible?; end
  def protocol; end
  def rack_response; end
  def transmit(data); end

  private

  def websocket; end
end

class ActionCable::Engine < ::Rails::Engine; end
module ActionCable::Helpers; end

module ActionCable::Helpers::ActionCableHelper
  def action_cable_meta_tag; end
end

ActionCable::INTERNAL = T.let(T.unsafe(nil), Hash)

class ActionCable::RemoteConnections
  def initialize(server); end

  def server; end
  def where(identifier); end
end

class ActionCable::RemoteConnections::RemoteConnection
  include ::ActionCable::Connection::InternalChannel
  include ::ActionCable::Connection::Identification
  extend ::ActionCable::Connection::Identification::ClassMethods

  def initialize(server, ids); end

  def disconnect; end
  def identifiers; end
  def identifiers=(_arg0); end
  def identifiers?; end

  protected

  def server; end

  private

  def set_identifier_instance_vars(ids); end
  def valid_identifiers?(ids); end

  class << self
    def identifiers; end
    def identifiers=(value); end
    def identifiers?; end
  end
end

class ActionCable::RemoteConnections::RemoteConnection::InvalidIdentifiersError < ::StandardError; end

module ActionCable::Server
  extend ::ActiveSupport::Autoload
end

class ActionCable::Server::Base
  include ::ActionCable::Server::Broadcasting
  include ::ActionCable::Server::Connections

  def initialize(config: T.unsafe(nil)); end

  def call(env); end
  def config; end
  def connection_identifiers; end
  def disconnect(identifiers); end
  def event_loop; end
  def logger(*_arg0, &_arg1); end
  def mutex; end
  def pubsub; end
  def remote_connections; end
  def restart; end
  def worker_pool; end

  class << self
    def config; end
    def config=(val); end
    def logger; end
  end
end

module ActionCable::Server::Broadcasting
  def broadcast(broadcasting, message, coder: T.unsafe(nil)); end
  def broadcaster_for(broadcasting, coder: T.unsafe(nil)); end
end

class ActionCable::Server::Broadcasting::Broadcaster
  def initialize(server, broadcasting, coder:); end

  def broadcast(message); end
  def broadcasting; end
  def coder; end
  def server; end
end

class ActionCable::Server::Configuration
  def initialize; end

  def allow_same_origin_as_host; end
  def allow_same_origin_as_host=(_arg0); end
  def allowed_request_origins; end
  def allowed_request_origins=(_arg0); end
  def cable; end
  def cable=(_arg0); end
  def connection_class; end
  def connection_class=(_arg0); end
  def disable_request_forgery_protection; end
  def disable_request_forgery_protection=(_arg0); end
  def log_tags; end
  def log_tags=(_arg0); end
  def logger; end
  def logger=(_arg0); end
  def mount_path; end
  def mount_path=(_arg0); end
  def pubsub_adapter; end
  def url; end
  def url=(_arg0); end
  def worker_pool_size; end
  def worker_pool_size=(_arg0); end
end

module ActionCable::Server::Connections
  def add_connection(connection); end
  def connections; end
  def open_connections_statistics; end
  def remove_connection(connection); end
  def setup_heartbeat_timer; end
end

ActionCable::Server::Connections::BEAT_INTERVAL = T.let(T.unsafe(nil), Integer)

class ActionCable::Server::Worker
  include ::ActiveSupport::Callbacks
  include ::ActionCable::Server::Worker::ActiveRecordConnectionManagement
  extend ::ActiveSupport::Callbacks::ClassMethods
  extend ::ActiveSupport::DescendantsTracker

  def initialize(max_size: T.unsafe(nil)); end

  def __callbacks; end
  def __callbacks?; end
  def _run_work_callbacks(&block); end
  def _work_callbacks; end
  def async_exec(receiver, *args, connection:, &block); end
  def async_invoke(receiver, method, *args, connection: T.unsafe(nil), &block); end
  def connection; end
  def connection=(obj); end
  def executor; end
  def halt; end
  def invoke(receiver, method, *args, connection:, &block); end
  def stopping?; end
  def work(connection); end

  private

  def logger; end

  class << self
    def __callbacks; end
    def __callbacks=(value); end
    def __callbacks?; end
    def _work_callbacks; end
    def _work_callbacks=(value); end
    def connection; end
    def connection=(obj); end
  end
end

module ActionCable::Server::Worker::ActiveRecordConnectionManagement
  extend ::ActiveSupport::Concern

  def with_database_connections; end
end

module ActionCable::SubscriptionAdapter
  extend ::ActiveSupport::Autoload
end

class ActionCable::SubscriptionAdapter::Async < ::ActionCable::SubscriptionAdapter::Inline
  private

  def new_subscriber_map; end
end

class ActionCable::SubscriptionAdapter::Async::AsyncSubscriberMap < ::ActionCable::SubscriptionAdapter::SubscriberMap
  def initialize(event_loop); end

  def add_subscriber(*_arg0); end
  def invoke_callback(*_arg0); end
end

class ActionCable::SubscriptionAdapter::Base
  def initialize(server); end

  def broadcast(channel, payload); end
  def identifier; end
  def logger; end
  def server; end
  def shutdown; end
  def subscribe(channel, message_callback, success_callback = T.unsafe(nil)); end
  def unsubscribe(channel, message_callback); end
end

module ActionCable::SubscriptionAdapter::ChannelPrefix
  def broadcast(channel, payload); end
  def subscribe(channel, callback, success_callback = T.unsafe(nil)); end
  def unsubscribe(channel, callback); end

  private

  def channel_with_prefix(channel); end
end

class ActionCable::SubscriptionAdapter::Inline < ::ActionCable::SubscriptionAdapter::Base
  def initialize(*_arg0); end

  def broadcast(channel, payload); end
  def shutdown; end
  def subscribe(channel, callback, success_callback = T.unsafe(nil)); end
  def unsubscribe(channel, callback); end

  private

  def new_subscriber_map; end
  def subscriber_map; end
end

class ActionCable::SubscriptionAdapter::SubscriberMap
  def initialize; end

  def add_channel(channel, on_success); end
  def add_subscriber(channel, subscriber, on_success); end
  def broadcast(channel, message); end
  def invoke_callback(callback, message); end
  def remove_channel(channel); end
  def remove_subscriber(channel, subscriber); end
end

class ActionCable::SubscriptionAdapter::Test < ::ActionCable::SubscriptionAdapter::Async
  def broadcast(channel, payload); end
  def broadcasts(channel); end
  def clear; end
  def clear_messages(channel); end

  private

  def channels_data; end
end

class ActionCable::TestCase < ::ActiveSupport::TestCase
  include ::ActionCable::TestHelper
end

module ActionCable::TestHelper
  def after_teardown; end
  def assert_broadcast_on(stream, data, &block); end
  def assert_broadcasts(stream, number, &block); end
  def assert_no_broadcasts(stream, &block); end
  def before_setup; end
  def broadcasts(*_arg0, &_arg1); end
  def clear_messages(*_arg0, &_arg1); end
  def pubsub_adapter; end

  private

  def broadcasts_size(channel); end
end

module ActionCable::VERSION; end
ActionCable::VERSION::MAJOR = T.let(T.unsafe(nil), Integer)
ActionCable::VERSION::MINOR = T.let(T.unsafe(nil), Integer)
ActionCable::VERSION::PRE = T.let(T.unsafe(nil), String)
ActionCable::VERSION::STRING = T.let(T.unsafe(nil), String)
ActionCable::VERSION::TINY = T.let(T.unsafe(nil), Integer)
