# This is an autogenerated file for dynamic methods in UpholdConnectionForChannel
# Please rerun bundle exec rake rails_rbi:models[UpholdConnectionForChannel] to regenerate.

# typed: strong
module UpholdConnectionForChannel::ActiveRelation_WhereNot
  sig { params(opts: T.untyped, rest: T.untyped).returns(T.self_type) }
  def not(opts, *rest); end
end

module UpholdConnectionForChannel::GeneratedAttributeMethods
  sig { returns(T.nilable(String)) }
  def address; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def address=(value); end

  sig { returns(T::Boolean) }
  def address?; end

  sig { returns(T.nilable(String)) }
  def card_id; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def card_id=(value); end

  sig { returns(T::Boolean) }
  def card_id?; end

  sig { returns(String) }
  def channel_id; end

  sig { params(value: T.any(String, Symbol)).void }
  def channel_id=(value); end

  sig { returns(T::Boolean) }
  def channel_id?; end

  sig { returns(T.nilable(String)) }
  def channel_identifier; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def channel_identifier=(value); end

  sig { returns(T::Boolean) }
  def channel_identifier?; end

  sig { returns(T.nilable(String)) }
  def currency; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def currency=(value); end

  sig { returns(T::Boolean) }
  def currency?; end

  sig { returns(String) }
  def id; end

  sig { params(value: T.any(String, Symbol)).void }
  def id=(value); end

  sig { returns(T::Boolean) }
  def id?; end

  sig { returns(String) }
  def uphold_connection_id; end

  sig { params(value: T.any(String, Symbol)).void }
  def uphold_connection_id=(value); end

  sig { returns(T::Boolean) }
  def uphold_connection_id?; end

  sig { returns(T.nilable(String)) }
  def uphold_id; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def uphold_id=(value); end

  sig { returns(T::Boolean) }
  def uphold_id?; end
end

module UpholdConnectionForChannel::GeneratedAssociationMethods
  sig { returns(::CachedUpholdTip::ActiveRecord_Associations_CollectionProxy) }
  def cached_uphold_tips; end

  sig { returns(T::Array[String]) }
  def cached_uphold_tip_ids; end

  sig { params(value: T::Enumerable[::CachedUpholdTip]).void }
  def cached_uphold_tips=(value); end

  sig { returns(::Channel) }
  def channel; end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::Channel).void)).returns(::Channel) }
  def build_channel(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::Channel).void)).returns(::Channel) }
  def create_channel(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::Channel).void)).returns(::Channel) }
  def create_channel!(*args, &block); end

  sig { params(value: ::Channel).void }
  def channel=(value); end

  sig { returns(::Channel) }
  def reload_channel; end

  sig { returns(::UpholdConnection) }
  def uphold_connection; end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::UpholdConnection).void)).returns(::UpholdConnection) }
  def build_uphold_connection(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::UpholdConnection).void)).returns(::UpholdConnection) }
  def create_uphold_connection(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::UpholdConnection).void)).returns(::UpholdConnection) }
  def create_uphold_connection!(*args, &block); end

  sig { params(value: ::UpholdConnection).void }
  def uphold_connection=(value); end

  sig { returns(::UpholdConnection) }
  def reload_uphold_connection; end
end

module UpholdConnectionForChannel::CustomFinderMethods
  sig { params(limit: Integer).returns(T::Array[UpholdConnectionForChannel]) }
  def first_n(limit); end

  sig { params(limit: Integer).returns(T::Array[UpholdConnectionForChannel]) }
  def last_n(limit); end

  sig { params(args: T::Array[T.any(Integer, String)]).returns(T::Array[UpholdConnectionForChannel]) }
  def find_n(*args); end

  sig { params(id: T.nilable(Integer)).returns(T.nilable(UpholdConnectionForChannel)) }
  def find_by_id(id); end

  sig { params(id: Integer).returns(UpholdConnectionForChannel) }
  def find_by_id!(id); end
end

class UpholdConnectionForChannel < ApplicationRecord
  include UpholdConnectionForChannel::GeneratedAttributeMethods
  include UpholdConnectionForChannel::GeneratedAssociationMethods
  extend UpholdConnectionForChannel::CustomFinderMethods
  extend UpholdConnectionForChannel::QueryMethodsReturningRelation
  RelationType = T.type_alias { T.any(UpholdConnectionForChannel::ActiveRecord_Relation, UpholdConnectionForChannel::ActiveRecord_Associations_CollectionProxy, UpholdConnectionForChannel::ActiveRecord_AssociationRelation) }
end

module UpholdConnectionForChannel::QueryMethodsReturningRelation
  sig { returns(UpholdConnectionForChannel::ActiveRecord_Relation) }
  def all; end

  sig { params(block: T.nilable(T.proc.void)).returns(UpholdConnectionForChannel::ActiveRecord_Relation) }
  def unscoped(&block); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_Relation) }
  def reselect(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_Relation) }
  def order(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_Relation) }
  def reorder(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_Relation) }
  def group(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_Relation) }
  def limit(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_Relation) }
  def offset(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_Relation) }
  def joins(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_Relation) }
  def left_joins(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_Relation) }
  def left_outer_joins(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_Relation) }
  def where(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_Relation) }
  def rewhere(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_Relation) }
  def preload(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_Relation) }
  def extract_associated(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_Relation) }
  def eager_load(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_Relation) }
  def includes(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_Relation) }
  def from(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_Relation) }
  def lock(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_Relation) }
  def readonly(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_Relation) }
  def or(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_Relation) }
  def having(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_Relation) }
  def create_with(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_Relation) }
  def distinct(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_Relation) }
  def references(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_Relation) }
  def none(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_Relation) }
  def unscope(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_Relation) }
  def optimizer_hints(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_Relation) }
  def merge(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_Relation) }
  def except(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_Relation) }
  def only(*args); end

  sig { params(block: T.proc.params(e: UpholdConnectionForChannel).returns(T::Boolean)).returns(T::Array[UpholdConnectionForChannel]) }
  def select(&block); end

  sig { params(args: T.any(String, Symbol, T::Array[T.any(String, Symbol)])).returns(UpholdConnectionForChannel::ActiveRecord_Relation) }
  def select_columns(*args); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(UpholdConnectionForChannel::ActiveRecord_Relation) }
  def extending(*args, &block); end

  sig do
    params(
      of: T.nilable(Integer),
      start: T.nilable(Integer),
      finish: T.nilable(Integer),
      load: T.nilable(T::Boolean),
      error_on_ignore: T.nilable(T::Boolean),
      block: T.nilable(T.proc.params(e: UpholdConnectionForChannel::ActiveRecord_Relation).void)
    ).returns(ActiveRecord::Batches::BatchEnumerator)
  end
  def in_batches(of: 1000, start: nil, finish: nil, load: false, error_on_ignore: nil, &block); end
end

module UpholdConnectionForChannel::QueryMethodsReturningAssociationRelation
  sig { returns(UpholdConnectionForChannel::ActiveRecord_AssociationRelation) }
  def all; end

  sig { params(block: T.nilable(T.proc.void)).returns(UpholdConnectionForChannel::ActiveRecord_Relation) }
  def unscoped(&block); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_AssociationRelation) }
  def reselect(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_AssociationRelation) }
  def order(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_AssociationRelation) }
  def reorder(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_AssociationRelation) }
  def group(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_AssociationRelation) }
  def limit(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_AssociationRelation) }
  def offset(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_AssociationRelation) }
  def joins(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_AssociationRelation) }
  def left_joins(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_AssociationRelation) }
  def left_outer_joins(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_AssociationRelation) }
  def where(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_AssociationRelation) }
  def rewhere(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_AssociationRelation) }
  def preload(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_AssociationRelation) }
  def extract_associated(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_AssociationRelation) }
  def eager_load(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_AssociationRelation) }
  def includes(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_AssociationRelation) }
  def from(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_AssociationRelation) }
  def lock(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_AssociationRelation) }
  def readonly(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_AssociationRelation) }
  def or(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_AssociationRelation) }
  def having(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_AssociationRelation) }
  def create_with(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_AssociationRelation) }
  def distinct(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_AssociationRelation) }
  def references(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_AssociationRelation) }
  def none(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_AssociationRelation) }
  def unscope(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_AssociationRelation) }
  def optimizer_hints(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_AssociationRelation) }
  def merge(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_AssociationRelation) }
  def except(*args); end

  sig { params(args: T.untyped).returns(UpholdConnectionForChannel::ActiveRecord_AssociationRelation) }
  def only(*args); end

  sig { params(block: T.proc.params(e: UpholdConnectionForChannel).returns(T::Boolean)).returns(T::Array[UpholdConnectionForChannel]) }
  def select(&block); end

  sig { params(args: T.any(String, Symbol, T::Array[T.any(String, Symbol)])).returns(UpholdConnectionForChannel::ActiveRecord_AssociationRelation) }
  def select_columns(*args); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(UpholdConnectionForChannel::ActiveRecord_AssociationRelation) }
  def extending(*args, &block); end

  sig do
    params(
      of: T.nilable(Integer),
      start: T.nilable(Integer),
      finish: T.nilable(Integer),
      load: T.nilable(T::Boolean),
      error_on_ignore: T.nilable(T::Boolean),
      block: T.nilable(T.proc.params(e: UpholdConnectionForChannel::ActiveRecord_AssociationRelation).void)
    ).returns(ActiveRecord::Batches::BatchEnumerator)
  end
  def in_batches(of: 1000, start: nil, finish: nil, load: false, error_on_ignore: nil, &block); end
end

class UpholdConnectionForChannel::ActiveRecord_Relation < ActiveRecord::Relation
  include UpholdConnectionForChannel::ActiveRelation_WhereNot
  include UpholdConnectionForChannel::CustomFinderMethods
  include UpholdConnectionForChannel::QueryMethodsReturningRelation
  Elem = type_member(fixed: UpholdConnectionForChannel)
end

class UpholdConnectionForChannel::ActiveRecord_AssociationRelation < ActiveRecord::AssociationRelation
  include UpholdConnectionForChannel::ActiveRelation_WhereNot
  include UpholdConnectionForChannel::CustomFinderMethods
  include UpholdConnectionForChannel::QueryMethodsReturningAssociationRelation
  Elem = type_member(fixed: UpholdConnectionForChannel)
end

class UpholdConnectionForChannel::ActiveRecord_Associations_CollectionProxy < ActiveRecord::Associations::CollectionProxy
  include UpholdConnectionForChannel::CustomFinderMethods
  include UpholdConnectionForChannel::QueryMethodsReturningAssociationRelation
  Elem = type_member(fixed: UpholdConnectionForChannel)

  sig { params(records: T.any(UpholdConnectionForChannel, T::Array[UpholdConnectionForChannel])).returns(T.self_type) }
  def <<(*records); end

  sig { params(records: T.any(UpholdConnectionForChannel, T::Array[UpholdConnectionForChannel])).returns(T.self_type) }
  def append(*records); end

  sig { params(records: T.any(UpholdConnectionForChannel, T::Array[UpholdConnectionForChannel])).returns(T.self_type) }
  def push(*records); end

  sig { params(records: T.any(UpholdConnectionForChannel, T::Array[UpholdConnectionForChannel])).returns(T.self_type) }
  def concat(*records); end
end
