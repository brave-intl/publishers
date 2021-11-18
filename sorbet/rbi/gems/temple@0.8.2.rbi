# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `temple` gem.
# Please instead update this file by running `bin/tapioca gem temple`.

module Temple; end
module Temple::ERB; end
class Temple::ERB::Engine < ::Temple::Engine; end

class Temple::ERB::Parser < ::Temple::Parser
  def call(input); end
end

Temple::ERB::Parser::ERB_PATTERN = T.let(T.unsafe(nil), Regexp)
class Temple::ERB::Template < ::Temple::Templates::Tilt; end

class Temple::ERB::Trimming < ::Temple::Filter
  def on_multi(*exps); end
end

class Temple::Engine
  include ::Temple::Mixins::Options
  include ::Temple::Mixins::EngineDSL
  extend ::Temple::Mixins::ClassOptions
  extend ::Temple::Mixins::ThreadOptions
  extend ::Temple::Mixins::EngineDSL

  def initialize(opts = T.unsafe(nil)); end

  def call(input); end
  def chain; end

  protected

  def call_chain; end
  def chain_modified!; end

  class << self
    def chain; end
  end
end

class Temple::Filter
  include ::Temple::Utils
  include ::Temple::Mixins::CompiledDispatcher
  include ::Temple::Mixins::CoreDispatcher
  include ::Temple::Mixins::EscapeDispatcher
  include ::Temple::Mixins::ControlFlowDispatcher
  include ::Temple::Mixins::Dispatcher
  include ::Temple::Mixins::Options
  extend ::Temple::Mixins::ClassOptions
  extend ::Temple::Mixins::ThreadOptions
end

class Temple::FilterError < ::RuntimeError; end
module Temple::Filters; end

class Temple::Filters::CodeMerger < ::Temple::Filter
  def on_multi(*exps); end
end

class Temple::Filters::ControlFlow < ::Temple::Filter
  def on_block(code, exp); end
  def on_case(arg, *cases); end
  def on_cond(*cases); end
  def on_if(condition, yes, no = T.unsafe(nil)); end
end

class Temple::Filters::DynamicInliner < ::Temple::Filter
  def on_multi(*exps); end
end

class Temple::Filters::Encoding < ::Temple::Parser
  def call(s); end
end

class Temple::Filters::Eraser < ::Temple::Filter
  def compile(exp); end

  protected

  def do?(list, exp); end
end

class Temple::Filters::Escapable < ::Temple::Filter
  def initialize(opts = T.unsafe(nil)); end

  def on_dynamic(value); end
  def on_escape(flag, exp); end
  def on_static(value); end
end

class Temple::Filters::MultiFlattener < ::Temple::Filter
  def on_multi(*exps); end
end

class Temple::Filters::RemoveBOM < ::Temple::Parser
  def call(s); end
end

class Temple::Filters::StaticAnalyzer < ::Temple::Filter
  def call(exp); end
  def on_dynamic(code); end
end

class Temple::Filters::StaticMerger < ::Temple::Filter
  def on_multi(*exps); end
end

class Temple::Filters::StringSplitter < ::Temple::Filter
  def on_dynamic(code); end

  private

  def string_literal?(code); end

  class << self
    def compile(code); end

    private

    def compile_tokens!(exps, tokens); end
    def shift_balanced_embexpr(tokens); end
    def strip_quotes!(tokens); end
  end
end

class Temple::Filters::StringSplitter::SyntaxChecker < ::Ripper
  private

  def on_parse_error(*_arg0); end

  class << self
    def syntax_error?(code); end
  end
end

class Temple::Filters::StringSplitter::SyntaxChecker::ParseError < ::StandardError; end

class Temple::Generator
  include ::Temple::Utils
  include ::Temple::Mixins::CompiledDispatcher
  include ::Temple::Mixins::Options
  extend ::Temple::Mixins::ClassOptions
  extend ::Temple::Mixins::ThreadOptions

  def call(exp); end
  def create_buffer; end
  def on(*exp); end
  def on_capture(name, exp); end
  def on_code(code); end
  def on_dynamic(code); end
  def on_multi(*exp); end
  def on_newline; end
  def on_static(text); end
  def postamble; end
  def preamble; end
  def restore_buffer; end
  def return_buffer; end
  def save_buffer; end

  protected

  def buffer; end
  def capture_generator; end
  def concat(str); end
end

module Temple::Generators; end

class Temple::Generators::Array < ::Temple::Generator
  def create_buffer; end
  def return_buffer; end
end

class Temple::Generators::ArrayBuffer < ::Temple::Generators::Array
  def call(exp); end
  def return_buffer; end
end

class Temple::Generators::ERB < ::Temple::Generator
  def call(exp); end
  def on_capture(name, exp); end
  def on_code(code); end
  def on_dynamic(code); end
  def on_multi(*exp); end
  def on_static(text); end
end

class Temple::Generators::RailsOutputBuffer < ::Temple::Generators::StringBuffer
  def call(exp); end
  def concat(str); end
  def create_buffer; end
end

class Temple::Generators::StringBuffer < ::Temple::Generators::ArrayBuffer
  def create_buffer; end
  def on_dynamic(code); end
  def return_buffer; end
end

module Temple::HTML; end

class Temple::HTML::AttributeMerger < ::Temple::HTML::Filter
  def on_html_attrs(*attrs); end
end

class Temple::HTML::AttributeRemover < ::Temple::HTML::Filter
  def initialize(opts = T.unsafe(nil)); end

  def on_html_attr(name, value); end
  def on_html_attrs(*attrs); end
end

class Temple::HTML::AttributeSorter < ::Temple::HTML::Filter
  def call(exp); end
  def on_html_attrs(*attrs); end
end

module Temple::HTML::Dispatcher
  def on_html_attr(name, content); end
  def on_html_attrs(*attrs); end
  def on_html_comment(content); end
  def on_html_condcomment(condition, content); end
  def on_html_js(content); end
  def on_html_tag(name, attrs, content = T.unsafe(nil)); end
end

class Temple::HTML::Fast < ::Temple::HTML::Filter
  def initialize(opts = T.unsafe(nil)); end

  def on_html_attr(name, value); end
  def on_html_attrs(*attrs); end
  def on_html_comment(content); end
  def on_html_condcomment(condition, content); end
  def on_html_doctype(type); end
  def on_html_js(content); end
  def on_html_tag(name, attrs, content = T.unsafe(nil)); end
end

Temple::HTML::Fast::DOCTYPES = T.let(T.unsafe(nil), Hash)
Temple::HTML::Fast::HTML_VOID_ELEMENTS = T.let(T.unsafe(nil), Array)

class Temple::HTML::Filter < ::Temple::Filter
  include ::Temple::HTML::Dispatcher

  def contains_nonempty_static?(exp); end
end

class Temple::HTML::Pretty < ::Temple::HTML::Fast
  def initialize(opts = T.unsafe(nil)); end

  def call(exp); end
  def on_dynamic(code); end
  def on_html_comment(content); end
  def on_html_doctype(type); end
  def on_html_tag(name, attrs, content = T.unsafe(nil)); end
  def on_static(content); end

  protected

  def indent; end
  def preamble; end
  def tag_indent(name); end
end

class Temple::ImmutableMap
  include ::Enumerable

  def initialize(*map); end

  def [](key); end
  def each; end
  def include?(key); end
  def keys; end
  def to_hash; end
  def values; end
end

class Temple::InvalidExpression < ::RuntimeError; end
module Temple::Mixins; end

module Temple::Mixins::ClassOptions
  def default_options; end
  def define_deprecated_options(*opts); end
  def define_options(*opts); end
  def disable_option_validator!; end
  def options; end
  def set_default_options(opts); end
  def set_options(opts); end
end

module Temple::Mixins::CompiledDispatcher
  def call(exp); end
  def compile(exp); end

  private

  def dispatched_methods; end
  def dispatcher(exp); end
  def replace_dispatcher(exp); end
end

class Temple::Mixins::CompiledDispatcher::DispatchNode < ::Hash
  def initialize; end

  def compile(level = T.unsafe(nil), call_parent = T.unsafe(nil)); end
  def method; end
  def method=(_arg0); end
end

module Temple::Mixins::ControlFlowDispatcher
  def on_block(code, content); end
  def on_case(arg, *cases); end
  def on_cond(*cases); end
  def on_if(condition, *cases); end
end

module Temple::Mixins::CoreDispatcher
  def on_capture(name, exp); end
  def on_multi(*exps); end
end

module Temple::Mixins::Dispatcher
  include ::Temple::Mixins::CompiledDispatcher
  include ::Temple::Mixins::CoreDispatcher
  include ::Temple::Mixins::EscapeDispatcher
  include ::Temple::Mixins::ControlFlowDispatcher
end

module Temple::Mixins::EngineDSL
  def after(name, *args, &block); end
  def append(*args, &block); end
  def before(name, *args, &block); end
  def chain_modified!; end
  def filter(name, *options); end
  def generator(name, *options); end
  def html(name, *options); end
  def prepend(*args, &block); end
  def remove(name); end
  def replace(name, *args, &block); end
  def use(*args, &block); end

  private

  def chain_class_constructor(filter, local_options); end
  def chain_element(args, block); end
  def chain_name(name); end
  def chain_proc_constructor(name, filter); end
end

module Temple::Mixins::EscapeDispatcher
  def on_escape(flag, exp); end
end

module Temple::Mixins::GrammarDSL
  def ===(exp); end
  def =~(exp); end
  def Rule(rule); end
  def Value(value); end
  def const_missing(name); end
  def extended(mod); end
  def match?(exp); end
  def validate!(exp); end
end

class Temple::Mixins::GrammarDSL::Element < ::Temple::Mixins::GrammarDSL::Or
  def initialize(grammar, rule); end

  def after_copy(source); end
  def match(exp, unmatched); end
end

class Temple::Mixins::GrammarDSL::Or < ::Temple::Mixins::GrammarDSL::Rule
  def initialize(grammar, *children); end

  def <<(rule); end
  def after_copy(source); end
  def match(exp, unmatched); end
  def |(rule); end
end

class Temple::Mixins::GrammarDSL::Root < ::Temple::Mixins::GrammarDSL::Or
  def initialize(grammar, name); end

  def after_copy(source); end
  def copy_to(grammar); end
  def match(exp, unmatched); end
  def validate!(exp); end
end

class Temple::Mixins::GrammarDSL::Rule
  def initialize(grammar); end

  def ===(exp); end
  def =~(exp); end
  def copy_to(grammar); end
  def match?(exp); end
  def |(rule); end
end

class Temple::Mixins::GrammarDSL::Value < ::Temple::Mixins::GrammarDSL::Rule
  def initialize(grammar, value); end

  def match(exp, unmatched); end
end

module Temple::Mixins::Options
  mixes_in_class_methods ::Temple::Mixins::ClassOptions
  mixes_in_class_methods ::Temple::Mixins::ThreadOptions

  def initialize(opts = T.unsafe(nil)); end

  def options; end

  class << self
    def included(base); end
  end
end

module Temple::Mixins::Template
  include ::Temple::Mixins::ClassOptions

  def compile(code, options); end
  def create(engine, options); end
  def register_as(*names); end
end

module Temple::Mixins::ThreadOptions
  def thread_options; end
  def with_options(options); end

  protected

  def thread_options_key; end
end

class Temple::MutableMap < ::Temple::ImmutableMap
  def initialize(*map); end

  def []=(key, value); end
  def update(map); end
end

class Temple::OptionMap < ::Temple::MutableMap
  def initialize(*map, &block); end

  def []=(key, value); end
  def add_deprecated_keys(*keys); end
  def add_valid_keys(*keys); end
  def deprecated_key?(key); end
  def update(map); end
  def valid_key?(key); end
  def valid_keys; end
  def validate_key!(key); end
  def validate_map!(map); end
end

class Temple::Parser
  include ::Temple::Utils
  include ::Temple::Mixins::Options
  extend ::Temple::Mixins::ClassOptions
  extend ::Temple::Mixins::ThreadOptions
end

module Temple::StaticAnalyzer
  class << self
    def available?; end
    def static?(code); end
    def syntax_error?(code); end
  end
end

Temple::StaticAnalyzer::DYNAMIC_TOKENS = T.let(T.unsafe(nil), Array)
Temple::StaticAnalyzer::STATIC_KEYWORDS = T.let(T.unsafe(nil), Array)
Temple::StaticAnalyzer::STATIC_OPERATORS = T.let(T.unsafe(nil), Array)
Temple::StaticAnalyzer::STATIC_TOKENS = T.let(T.unsafe(nil), Array)

class Temple::StaticAnalyzer::SyntaxChecker < ::Ripper
  private

  def on_parse_error(*_arg0); end
end

class Temple::StaticAnalyzer::SyntaxChecker::ParseError < ::StandardError; end

module Temple::Templates
  class << self
    def method_missing(name, engine, options = T.unsafe(nil)); end
  end
end

class Temple::Templates::Rails
  extend ::Temple::Mixins::ClassOptions
  extend ::Temple::Mixins::Template

  def call(template, source = T.unsafe(nil)); end
  def supports_streaming?; end

  class << self
    def register_as(*names); end
  end
end

class Temple::Templates::Tilt < ::Tilt::Template
  extend ::Temple::Mixins::ClassOptions
  extend ::Temple::Mixins::Template

  def precompiled_template(locals = T.unsafe(nil)); end
  def prepare; end

  class << self
    def default_mime_type; end
    def default_mime_type=(mime_type); end
    def register_as(*names); end
  end
end

module Temple::Utils
  extend ::Temple::Utils

  def empty_exp?(exp); end
  def escape_html(html); end
  def escape_html_safe(html); end
  def indent_dynamic(text, indent_next, indent, pre_tags = T.unsafe(nil)); end
  def unique_name(prefix = T.unsafe(nil)); end
end

Temple::VERSION = T.let(T.unsafe(nil), String)
