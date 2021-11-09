# This is an autogenerated file for dynamic methods in GithubChannelDetails
# Please rerun bundle exec rake rails_rbi:models[GithubChannelDetails] to regenerate.

# typed: ignore
module GithubChannelDetails::ActiveRelation_WhereNot
  sig { params(opts: T.untyped, rest: T.untyped).returns(T.self_type) }
  def not(opts, *rest); end
end

module GithubChannelDetails::GeneratedAttributeMethods
  sig { returns(T.nilable(String)) }
  def auth_provider; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def auth_provider=(value); end

  sig { returns(T::Boolean) }
  def auth_provider?; end

  sig { returns(String) }
  def channel_url; end

  sig { params(value: T.any(String, Symbol)).void }
  def channel_url=(value); end

  sig { returns(T::Boolean) }
  def channel_url?; end

  sig { returns(ActiveSupport::TimeWithZone) }
  def created_at; end

  sig { params(value: T.any(Date, Time, ActiveSupport::TimeWithZone)).void }
  def created_at=(value); end

  sig { returns(T::Boolean) }
  def created_at?; end

  sig { returns(String) }
  def github_channel_id; end

  sig { params(value: T.any(String, Symbol)).void }
  def github_channel_id=(value); end

  sig { returns(T::Boolean) }
  def github_channel_id?; end

  sig { returns(String) }
  def id; end

  sig { params(value: T.any(String, Symbol)).void }
  def id=(value); end

  sig { returns(T::Boolean) }
  def id?; end

  sig { returns(String) }
  def name; end

  sig { params(value: T.any(String, Symbol)).void }
  def name=(value); end

  sig { returns(T::Boolean) }
  def name?; end

  sig { returns(T.nilable(String)) }
  def nickname; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def nickname=(value); end

  sig { returns(T::Boolean) }
  def nickname?; end

  sig { returns(T.nilable(T.any(T::Array[T.untyped], T::Boolean, Float, T::Hash[T.untyped, T.untyped], Integer, String))) }
  def stats; end

  sig { params(value: T.nilable(T.any(T::Array[T.untyped], T::Boolean, Float, T::Hash[T.untyped, T.untyped], Integer, String))).void }
  def stats=(value); end

  sig { returns(T::Boolean) }
  def stats?; end

  sig { returns(String) }
  def thumbnail_url; end

  sig { params(value: T.any(String, Symbol)).void }
  def thumbnail_url=(value); end

  sig { returns(T::Boolean) }
  def thumbnail_url?; end

  sig { returns(ActiveSupport::TimeWithZone) }
  def updated_at; end

  sig { params(value: T.any(Date, Time, ActiveSupport::TimeWithZone)).void }
  def updated_at=(value); end

  sig { returns(T::Boolean) }
  def updated_at?; end
end

module GithubChannelDetails::GeneratedAssociationMethods
  sig { returns(T.nilable(::Channel)) }
  def channel; end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::Channel).void)).returns(::Channel) }
  def build_channel(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::Channel).void)).returns(::Channel) }
  def create_channel(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::Channel).void)).returns(::Channel) }
  def create_channel!(*args, &block); end

  sig { params(value: T.nilable(::Channel)).void }
  def channel=(value); end

  sig { returns(T.nilable(::Channel)) }
  def reload_channel; end

  sig { returns(::PaperTrail::Version::ActiveRecord_Associations_CollectionProxy) }
  def versions; end

  sig { returns(T::Array[String]) }
  def version_ids; end

  sig { params(value: T::Enumerable[::PaperTrail::Version]).void }
  def versions=(value); end
end

module GithubChannelDetails::CustomFinderMethods
  sig { params(limit: Integer).returns(T::Array[GithubChannelDetails]) }
  def first_n(limit); end

  sig { params(limit: Integer).returns(T::Array[GithubChannelDetails]) }
  def last_n(limit); end

  sig { params(args: T::Array[T.any(Integer, String)]).returns(T::Array[GithubChannelDetails]) }
  def find_n(*args); end

  sig { params(id: T.nilable(Integer)).returns(T.nilable(GithubChannelDetails)) }
  def find_by_id(id); end

  sig { params(id: Integer).returns(GithubChannelDetails) }
  def find_by_id!(id); end
end

class GithubChannelDetails < BaseChannelDetails
  include GithubChannelDetails::GeneratedAttributeMethods
  include GithubChannelDetails::GeneratedAssociationMethods
  extend GithubChannelDetails::CustomFinderMethods
  extend GithubChannelDetails::QueryMethodsReturningRelation
  RelationType = T.type_alias { T.any(GithubChannelDetails::ActiveRecord_Relation, GithubChannelDetails::ActiveRecord_Associations_CollectionProxy, GithubChannelDetails::ActiveRecord_AssociationRelation) }
end

module GithubChannelDetails::QueryMethodsReturningRelation
  sig { returns(GithubChannelDetails::ActiveRecord_Relation) }
  def all; end

  sig { params(block: T.nilable(T.proc.void)).returns(GithubChannelDetails::ActiveRecord_Relation) }
  def unscoped(&block); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_Relation) }
  def reselect(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_Relation) }
  def order(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_Relation) }
  def reorder(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_Relation) }
  def group(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_Relation) }
  def limit(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_Relation) }
  def offset(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_Relation) }
  def joins(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_Relation) }
  def left_joins(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_Relation) }
  def left_outer_joins(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_Relation) }
  def where(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_Relation) }
  def rewhere(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_Relation) }
  def preload(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_Relation) }
  def extract_associated(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_Relation) }
  def eager_load(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_Relation) }
  def includes(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_Relation) }
  def from(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_Relation) }
  def lock(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_Relation) }
  def readonly(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_Relation) }
  def or(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_Relation) }
  def having(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_Relation) }
  def create_with(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_Relation) }
  def distinct(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_Relation) }
  def references(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_Relation) }
  def none(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_Relation) }
  def unscope(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_Relation) }
  def optimizer_hints(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_Relation) }
  def merge(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_Relation) }
  def except(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_Relation) }
  def only(*args); end

  sig { params(block: T.proc.params(e: GithubChannelDetails).returns(T::Boolean)).returns(T::Array[GithubChannelDetails]) }
  def select(&block); end

  sig { params(args: T.any(String, Symbol, T::Array[T.any(String, Symbol)])).returns(GithubChannelDetails::ActiveRecord_Relation) }
  def select_columns(*args); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(GithubChannelDetails::ActiveRecord_Relation) }
  def extending(*args, &block); end

  sig do
    params(
      of: T.nilable(Integer),
      start: T.nilable(Integer),
      finish: T.nilable(Integer),
      load: T.nilable(T::Boolean),
      error_on_ignore: T.nilable(T::Boolean),
      block: T.nilable(T.proc.params(e: GithubChannelDetails::ActiveRecord_Relation).void)
    ).returns(ActiveRecord::Batches::BatchEnumerator)
  end
  def in_batches(of: 1000, start: nil, finish: nil, load: false, error_on_ignore: nil, &block); end
end

module GithubChannelDetails::QueryMethodsReturningAssociationRelation
  sig { returns(GithubChannelDetails::ActiveRecord_AssociationRelation) }
  def all; end

  sig { params(block: T.nilable(T.proc.void)).returns(GithubChannelDetails::ActiveRecord_Relation) }
  def unscoped(&block); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_AssociationRelation) }
  def reselect(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_AssociationRelation) }
  def order(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_AssociationRelation) }
  def reorder(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_AssociationRelation) }
  def group(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_AssociationRelation) }
  def limit(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_AssociationRelation) }
  def offset(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_AssociationRelation) }
  def joins(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_AssociationRelation) }
  def left_joins(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_AssociationRelation) }
  def left_outer_joins(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_AssociationRelation) }
  def where(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_AssociationRelation) }
  def rewhere(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_AssociationRelation) }
  def preload(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_AssociationRelation) }
  def extract_associated(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_AssociationRelation) }
  def eager_load(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_AssociationRelation) }
  def includes(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_AssociationRelation) }
  def from(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_AssociationRelation) }
  def lock(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_AssociationRelation) }
  def readonly(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_AssociationRelation) }
  def or(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_AssociationRelation) }
  def having(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_AssociationRelation) }
  def create_with(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_AssociationRelation) }
  def distinct(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_AssociationRelation) }
  def references(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_AssociationRelation) }
  def none(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_AssociationRelation) }
  def unscope(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_AssociationRelation) }
  def optimizer_hints(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_AssociationRelation) }
  def merge(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_AssociationRelation) }
  def except(*args); end

  sig { params(args: T.untyped).returns(GithubChannelDetails::ActiveRecord_AssociationRelation) }
  def only(*args); end

  sig { params(block: T.proc.params(e: GithubChannelDetails).returns(T::Boolean)).returns(T::Array[GithubChannelDetails]) }
  def select(&block); end

  sig { params(args: T.any(String, Symbol, T::Array[T.any(String, Symbol)])).returns(GithubChannelDetails::ActiveRecord_AssociationRelation) }
  def select_columns(*args); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(GithubChannelDetails::ActiveRecord_AssociationRelation) }
  def extending(*args, &block); end

  sig do
    params(
      of: T.nilable(Integer),
      start: T.nilable(Integer),
      finish: T.nilable(Integer),
      load: T.nilable(T::Boolean),
      error_on_ignore: T.nilable(T::Boolean),
      block: T.nilable(T.proc.params(e: GithubChannelDetails::ActiveRecord_AssociationRelation).void)
    ).returns(ActiveRecord::Batches::BatchEnumerator)
  end
  def in_batches(of: 1000, start: nil, finish: nil, load: false, error_on_ignore: nil, &block); end
end

class GithubChannelDetails::ActiveRecord_Relation < ActiveRecord::Relation
  include GithubChannelDetails::ActiveRelation_WhereNot
  include GithubChannelDetails::CustomFinderMethods
  include GithubChannelDetails::QueryMethodsReturningRelation
  Elem = type_member(fixed: GithubChannelDetails)
end

class GithubChannelDetails::ActiveRecord_AssociationRelation < ActiveRecord::AssociationRelation
  include GithubChannelDetails::ActiveRelation_WhereNot
  include GithubChannelDetails::CustomFinderMethods
  include GithubChannelDetails::QueryMethodsReturningAssociationRelation
  Elem = type_member(fixed: GithubChannelDetails)
end

class GithubChannelDetails::ActiveRecord_Associations_CollectionProxy < ActiveRecord::Associations::CollectionProxy
  include GithubChannelDetails::CustomFinderMethods
  include GithubChannelDetails::QueryMethodsReturningAssociationRelation
  Elem = type_member(fixed: GithubChannelDetails)

  sig { params(records: T.any(GithubChannelDetails, T::Array[GithubChannelDetails])).returns(T.self_type) }
  def <<(*records); end

  sig { params(records: T.any(GithubChannelDetails, T::Array[GithubChannelDetails])).returns(T.self_type) }
  def append(*records); end

  sig { params(records: T.any(GithubChannelDetails, T::Array[GithubChannelDetails])).returns(T.self_type) }
  def push(*records); end

  sig { params(records: T.any(GithubChannelDetails, T::Array[GithubChannelDetails])).returns(T.self_type) }
  def concat(*records); end
end
