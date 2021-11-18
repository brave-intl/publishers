# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `fugit` gem.
# Please instead update this file by running `bin/tapioca gem fugit`.

module Fugit
  class << self
    def determine_type(s); end
    def do_parse(s, opts = T.unsafe(nil)); end
    def do_parse_at(s); end
    def do_parse_cron(s); end
    def do_parse_duration(s); end
    def do_parse_in(s); end
    def do_parse_nat(s, opts = T.unsafe(nil)); end
    def isostamp(show_date, show_time, show_usec, time); end
    def parse(s, opts = T.unsafe(nil)); end
    def parse_at(s); end
    def parse_cron(s); end
    def parse_duration(s); end
    def parse_in(s); end
    def parse_nat(s, opts = T.unsafe(nil)); end
    def time_to_plain_s(t = T.unsafe(nil), z = T.unsafe(nil)); end
    def time_to_s(t); end
    def time_to_zone_s(t = T.unsafe(nil)); end
  end
end

module Fugit::At
  class << self
    def do_parse(s); end
    def parse(s); end
  end
end

class Fugit::Cron
  def ==(o); end
  def brute_frequency(year = T.unsafe(nil)); end
  def day_match?(nt); end
  def eql?(o); end
  def hash; end
  def hour_match?(nt); end
  def hours; end
  def match?(t); end
  def min_match?(nt); end
  def minutes; end
  def month_match?(nt); end
  def monthday_match?(nt); end
  def monthdays; end
  def months; end
  def next_time(from = T.unsafe(nil)); end
  def original; end
  def previous_time(from = T.unsafe(nil)); end
  def rough_frequency; end
  def sec_match?(nt); end
  def seconds; end
  def timezone; end
  def to_a; end
  def to_cron_s; end
  def to_h; end
  def weekday_hash_match?(nt, hsh); end
  def weekday_match?(nt); end
  def weekday_modulo_match?(nt, mod); end
  def weekdays; end
  def zone; end

  protected

  def compact(key); end
  def compact_month_days; end
  def determine_hours(arr); end
  def determine_minutes(arr); end
  def determine_monthdays(arr); end
  def determine_months(arr); end
  def determine_seconds(arr); end
  def determine_timezone(z); end
  def determine_weekdays(arr); end
  def expand(min, max, r); end
  def init(original, h); end
  def range(min, max, sta, edn, sla); end
  def rough_days; end

  class << self
    def do_parse(s); end
    def new(original); end
    def parse(s); end
  end
end

Fugit::Cron::FREQUENCY_CACHE = T.let(T.unsafe(nil), Hash)

class Fugit::Cron::Frequency
  def initialize(deltas, span); end

  def delta_max; end
  def delta_min; end
  def occurrences; end
  def span; end
  def span_years; end
  def to_debug_s; end
  def yearly_occurrences; end
end

Fugit::Cron::MAXDAYS = T.let(T.unsafe(nil), Array)
Fugit::Cron::MAX_ITERATION_COUNT = T.let(T.unsafe(nil), Integer)

module Fugit::Cron::Parser
  include ::Raabro
  extend ::Raabro::ModuleMethods
  extend ::Raabro
  extend ::Fugit::Cron::Parser

  def _dom(i); end
  def _dow(i); end
  def _hou(i); end
  def _mon(i); end
  def _mos(i); end
  def _tz(i); end
  def _tz_delta(i); end
  def _tz_name(i); end
  def classic_cron(i); end
  def comma(i); end
  def cron(i); end
  def dom(i); end
  def dom_elt(i); end
  def dow(i); end
  def dow_elt(i); end
  def dow_elt_(i); end
  def dow_hash(i); end
  def h_dow(i); end
  def hou(i); end
  def hou_elt(i); end
  def hyphen(i); end
  def ldom_(i); end
  def ldow(i); end
  def lhou_(i); end
  def list_dom(i); end
  def list_dow(i); end
  def list_hou(i); end
  def list_min(i); end
  def list_mon(i); end
  def list_sec(i); end
  def lmin_(i); end
  def lmon_(i); end
  def lsec_(i); end
  def mod(i); end
  def mod_dow(i); end
  def mon(i); end
  def mon_elt(i); end
  def mos(i); end
  def mos_elt(i); end
  def r_dom(i); end
  def r_dow(i); end
  def r_hou(i); end
  def r_mon(i); end
  def r_mos(i); end
  def rewrite_bound(k, t); end
  def rewrite_cron(t); end
  def rewrite_elt(k, t); end
  def rewrite_entry(t); end
  def rewrite_mod(k, t); end
  def rewrite_tz(t); end
  def s(i); end
  def second_cron(i); end
  def slash(i); end
  def sor_dom(i); end
  def sor_dow(i); end
  def sor_hou(i); end
  def sor_mon(i); end
  def sor_mos(i); end
  def sorws_dom(i); end
  def sorws_dow(i); end
  def sorws_hou(i); end
  def sorws_mon(i); end
  def sorws_mos(i); end
  def star(i); end
end

Fugit::Cron::Parser::DOW_REX = T.let(T.unsafe(nil), Regexp)
Fugit::Cron::Parser::MONTHS = T.let(T.unsafe(nil), Array)
Fugit::Cron::Parser::MONTH_REX = T.let(T.unsafe(nil), Regexp)
Fugit::Cron::Parser::WEEKDAYS = T.let(T.unsafe(nil), Array)
Fugit::Cron::Parser::WEEKDS = T.let(T.unsafe(nil), Array)
Fugit::Cron::SLOTS = T.let(T.unsafe(nil), Array)
Fugit::Cron::SPECIALS = T.let(T.unsafe(nil), Hash)

class Fugit::Cron::TimeCursor
  def initialize(cron, t); end

  def day; end
  def dec(i); end
  def dec_day; end
  def dec_hour; end
  def dec_min; end
  def dec_month; end
  def dec_sec; end
  def hour; end
  def inc(i); end
  def inc_day; end
  def inc_hour; end
  def inc_min; end
  def inc_month; end
  def inc_sec; end
  def min; end
  def month; end
  def rday; end
  def rweek; end
  def sec; end
  def time; end
  def to_i; end
  def wday; end
  def wday_in_month; end
  def year; end
end

Fugit::DAY_S = T.let(T.unsafe(nil), Integer)

class Fugit::Duration
  def +(a); end
  def -(a); end
  def -@; end
  def ==(o); end
  def add(a); end
  def add_duration(d); end
  def add_numeric(n); end
  def add_to_time(t); end
  def deflate(options = T.unsafe(nil)); end
  def drop_seconds; end
  def eql?(o); end
  def h; end
  def hash; end
  def inflate; end
  def next_time(from = T.unsafe(nil)); end
  def opposite; end
  def options; end
  def original; end
  def subtract(a); end
  def to_h; end
  def to_iso_s; end
  def to_long_s(opts = T.unsafe(nil)); end
  def to_plain_s; end
  def to_rufus_h; end
  def to_rufus_s; end
  def to_sec; end

  protected

  def _to_s(key); end
  def init(original, options, h); end

  class << self
    def common_rewrite_dur(t); end
    def do_parse(s, opts = T.unsafe(nil)); end
    def new(s); end
    def parse(s, opts = T.unsafe(nil)); end
    def to_iso_s(o); end
    def to_long_s(o, opts = T.unsafe(nil)); end
    def to_plain_s(o); end
  end
end

Fugit::Duration::INFLA_KEYS = T.let(T.unsafe(nil), Array)

module Fugit::Duration::IsoParser
  include ::Raabro
  extend ::Raabro::ModuleMethods
  extend ::Raabro
  extend ::Fugit::Duration::IsoParser

  def date(i); end
  def day(i); end
  def delt(i); end
  def dur(i); end
  def hou(i); end
  def min(i); end
  def mon(i); end
  def p(i); end
  def rewrite_dur(t); end
  def sec(i); end
  def t(i); end
  def t_time(i); end
  def telt(i); end
  def time(i); end
  def wee(i); end
  def yea(i); end
end

Fugit::Duration::KEYS = T.let(T.unsafe(nil), Hash)
Fugit::Duration::NON_INFLA_KEYS = T.let(T.unsafe(nil), Array)

module Fugit::Duration::Parser
  include ::Raabro
  extend ::Raabro::ModuleMethods
  extend ::Raabro
  extend ::Fugit::Duration::Parser

  def day(i); end
  def dur(i); end
  def elt(i); end
  def hou(i); end
  def merge(h0, h1); end
  def min(i); end
  def mon(i); end
  def rewrite_dur(t); end
  def rewrite_sdur(t); end
  def sdur(i); end
  def sec(i); end
  def sek(i); end
  def sep(i); end
  def sign(i); end
  def wee(i); end
  def yea(i); end
end

Fugit::Duration::SECOND_ROUND = T.let(T.unsafe(nil), Integer)

module Fugit::Nat
  class << self
    def do_parse(s, opts = T.unsafe(nil)); end
    def parse(s, opts = T.unsafe(nil)); end
  end
end

module Fugit::Nat::Parser
  include ::Raabro
  extend ::Raabro::ModuleMethods
  extend ::Raabro
  extend ::Fugit::Nat::Parser

  def _and(i); end
  def _and_or_or(i); end
  def _and_or_or_or_comma(i); end
  def _at(i); end
  def _day_s(i); end
  def _dmin(i); end
  def _every(i); end
  def _from(i); end
  def _in_or_on(i); end
  def _minute(i); end
  def _on(i); end
  def _point(i); end
  def _rewrite_sub(t, key = T.unsafe(nil)); end
  def _rewrite_subs(t, key = T.unsafe(nil)); end
  def _sep(i); end
  def _space(i); end
  def _the(i); end
  def _to(i); end
  def _to_or_dash(i); end
  def adjust_h(h, ap); end
  def ampm(i); end
  def and_dmin(i); end
  def at(i); end
  def at_object(i); end
  def at_objects(i); end
  def at_p(i); end
  def at_point(i); end
  def city_tz(i); end
  def count(i); end
  def counts(i); end
  def dark(i); end
  def delta_tz(i); end
  def digital_hour(i); end
  def every(i); end
  def every_interval(i); end
  def every_named(i); end
  def every_object(i); end
  def every_objects(i); end
  def every_of_the_month(i); end
  def every_single_interval(i); end
  def every_weekday(i); end
  def from(i); end
  def from_object(i); end
  def from_objects(i); end
  def interval(i); end
  def monthday(i); end
  def monthdays(i); end
  def named_h(i); end
  def named_hour(i); end
  def named_m(i); end
  def named_min(i); end
  def named_tz(i); end
  def nat(i); end
  def nat_elt(i); end
  def omonthday(i); end
  def omonthdays(i); end
  def on(i); end
  def on_days(i); end
  def on_minutes(i); end
  def on_object(i); end
  def on_objects(i); end
  def on_the(i); end
  def on_thes(i); end
  def on_thex(i); end
  def on_weekdays(i); end
  def otm(i); end
  def rewrite_at(t); end
  def rewrite_at_p(t); end
  def rewrite_digital_hour(t); end
  def rewrite_dmin(t); end
  def rewrite_every(t); end
  def rewrite_every_interval(t); end
  def rewrite_every_named(t); end
  def rewrite_every_single_interval(t); end
  def rewrite_monthday(t); end
  def rewrite_named_hour(t); end
  def rewrite_nat(t); end
  def rewrite_omonthday(t); end
  def rewrite_on(t); end
  def rewrite_on_days(t); end
  def rewrite_on_minutes(t); end
  def rewrite_on_thes(t); end
  def rewrite_on_thex(t); end
  def rewrite_on_weekdays(t); end
  def rewrite_simple_hour(t); end
  def rewrite_to_hour(t); end
  def rewrite_to_omonthday(t); end
  def rewrite_to_weekday(t); end
  def rewrite_tz(t); end
  def rewrite_weekday(t); end
  def rewrite_weekdays(t); end
  def simple_h(i); end
  def simple_hour(i); end
  def slot(key, data0, data1 = T.unsafe(nil), opts = T.unsafe(nil)); end
  def to_hour(i); end
  def to_omonthday(i); end
  def to_weekday(i); end
  def tz(i); end
  def tzone(i); end
  def weekday(i); end
  def weekday_range(i); end
  def weekdays(i); end
end

Fugit::Nat::Parser::INTERVALS = T.let(T.unsafe(nil), Array)
Fugit::Nat::Parser::INTERVAL_REX = T.let(T.unsafe(nil), Regexp)
Fugit::Nat::Parser::MONTHDAY_REX = T.let(T.unsafe(nil), Regexp)
Fugit::Nat::Parser::NAMED_H_REX = T.let(T.unsafe(nil), Regexp)
Fugit::Nat::Parser::NAMED_M_REX = T.let(T.unsafe(nil), Regexp)
Fugit::Nat::Parser::NHOURS = T.let(T.unsafe(nil), Hash)
Fugit::Nat::Parser::NMINUTES = T.let(T.unsafe(nil), Hash)
Fugit::Nat::Parser::OMONTHDAYS = T.let(T.unsafe(nil), Hash)
Fugit::Nat::Parser::OMONTHDAY_REX = T.let(T.unsafe(nil), Regexp)
Fugit::Nat::Parser::POINTS = T.let(T.unsafe(nil), Array)
Fugit::Nat::Parser::POINT_REX = T.let(T.unsafe(nil), Regexp)
Fugit::Nat::Parser::WEEKDAYS = T.let(T.unsafe(nil), Array)
Fugit::Nat::Parser::WEEKDAY_REX = T.let(T.unsafe(nil), Regexp)

class Fugit::Nat::Slot
  def initialize(key, d0, d1 = T.unsafe(nil), opts = T.unsafe(nil)); end

  def _data0; end
  def _data0=(_arg0); end
  def _data1; end
  def _data1=(_arg0); end
  def a; end
  def append(slot); end
  def data0; end
  def data1; end
  def graded?; end
  def inspect; end
  def key; end
  def strong; end
  def weak; end

  protected

  def conflate(index, slot); end
  def hour_range; end
  def to_a(x); end
end

class Fugit::Nat::SlotGroup
  def initialize(slots); end

  def to_crons(opts); end

  protected

  def determine_hms; end
  def make_slot(key, data0, data1 = T.unsafe(nil)); end
  def parse_cron(hm); end
  def slot(key, default); end
end

Fugit::VERSION = T.let(T.unsafe(nil), String)
Fugit::YEAR_S = T.let(T.unsafe(nil), Integer)
