# This is an autogenerated file for dynamic methods in CachedUpholdTip
# Please rerun bundle exec rake rails_rbi:models[CachedUpholdTip] to regenerate.

# typed: strong
module CachedUpholdTip::ActiveRelation_WhereNot
  sig { params(opts: T.untyped, rest: T.untyped).returns(T.self_type) }
  def not(opts, *rest); end
end

module CachedUpholdTip::GeneratedAttributeMethods
  sig { returns(T.nilable(String)) }
  def amount; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def amount=(value); end

  sig { returns(T::Boolean) }
  def amount?; end

  sig { returns(ActiveSupport::TimeWithZone) }
  def created_at; end

  sig { params(value: T.any(Date, Time, ActiveSupport::TimeWithZone)).void }
  def created_at=(value); end

  sig { returns(T::Boolean) }
  def created_at?; end

  sig { returns(String) }
  def id; end

  sig { params(value: T.any(String, Symbol)).void }
  def id=(value); end

  sig { returns(T::Boolean) }
  def id?; end

  sig { returns(T.nilable(String)) }
  def settlement_amount; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def settlement_amount=(value); end

  sig { returns(T::Boolean) }
  def settlement_amount?; end

  sig { returns(T.nilable(String)) }
  def settlement_currency; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def settlement_currency=(value); end

  sig { returns(T::Boolean) }
  def settlement_currency?; end

  sig { returns(ActiveSupport::TimeWithZone) }
  def updated_at; end

  sig { params(value: T.any(Date, Time, ActiveSupport::TimeWithZone)).void }
  def updated_at=(value); end

  sig { returns(T::Boolean) }
  def updated_at?; end

  sig { returns(T.nilable(String)) }
  def uphold_connection_for_channel_id; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def uphold_connection_for_channel_id=(value); end

  sig { returns(T::Boolean) }
  def uphold_connection_for_channel_id?; end

  sig { returns(T.nilable(ActiveSupport::TimeWithZone)) }
  def uphold_created_at; end

  sig { params(value: T.nilable(T.any(Date, Time, ActiveSupport::TimeWithZone))).void }
  def uphold_created_at=(value); end

  sig { returns(T::Boolean) }
  def uphold_created_at?; end

  sig { returns(T.nilable(String)) }
  def uphold_transaction_id; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def uphold_transaction_id=(value); end

  sig { returns(T::Boolean) }
  def uphold_transaction_id?; end
end

module CachedUpholdTip::GeneratedAssociationMethods
  sig { returns(T.nilable(::UpholdConnectionForChannel)) }
  def uphold_connection_for_channel; end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::UpholdConnectionForChannel).void)).returns(::UpholdConnectionForChannel) }
  def build_uphold_connection_for_channel(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::UpholdConnectionForChannel).void)).returns(::UpholdConnectionForChannel) }
  def create_uphold_connection_for_channel(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::UpholdConnectionForChannel).void)).returns(::UpholdConnectionForChannel) }
  def create_uphold_connection_for_channel!(*args, &block); end

  sig { params(value: T.nilable(::UpholdConnectionForChannel)).void }
  def uphold_connection_for_channel=(value); end

  sig { returns(T.nilable(::UpholdConnectionForChannel)) }
  def reload_uphold_connection_for_channel; end
end

module CachedUpholdTip::CustomFinderMethods
  sig { params(limit: Integer).returns(T::Array[CachedUpholdTip]) }
  def first_n(limit); end

  sig { params(limit: Integer).returns(T::Array[CachedUpholdTip]) }
  def last_n(limit); end

  sig { params(args: T::Array[T.any(Integer, String)]).returns(T::Array[CachedUpholdTip]) }
  def find_n(*args); end

  sig { params(id: T.nilable(Integer)).returns(T.nilable(CachedUpholdTip)) }
  def find_by_id(id); end

  sig { params(id: Integer).returns(CachedUpholdTip) }
  def find_by_id!(id); end
end

class CachedUpholdTip < ApplicationRecord
  include CachedUpholdTip::GeneratedAttributeMethods
  include CachedUpholdTip::GeneratedAssociationMethods
  extend CachedUpholdTip::CustomFinderMethods
  extend CachedUpholdTip::QueryMethodsReturningRelation
  RelationType = T.type_alias { T.any(CachedUpholdTip::ActiveRecord_Relation, CachedUpholdTip::ActiveRecord_Associations_CollectionProxy, CachedUpholdTip::ActiveRecord_AssociationRelation) }
end

module CachedUpholdTip::QueryMethodsReturningRelation
  sig { returns(CachedUpholdTip::ActiveRecord_Relation) }
  def all; end

  sig { params(block: T.nilable(T.proc.void)).returns(CachedUpholdTip::ActiveRecord_Relation) }
  def unscoped(&block); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_Relation) }
  def reselect(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_Relation) }
  def order(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_Relation) }
  def reorder(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_Relation) }
  def group(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_Relation) }
  def limit(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_Relation) }
  def offset(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_Relation) }
  def joins(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_Relation) }
  def left_joins(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_Relation) }
  def left_outer_joins(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_Relation) }
  def where(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_Relation) }
  def rewhere(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_Relation) }
  def preload(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_Relation) }
  def extract_associated(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_Relation) }
  def eager_load(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_Relation) }
  def includes(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_Relation) }
  def from(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_Relation) }
  def lock(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_Relation) }
  def readonly(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_Relation) }
  def or(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_Relation) }
  def having(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_Relation) }
  def create_with(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_Relation) }
  def distinct(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_Relation) }
  def references(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_Relation) }
  def none(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_Relation) }
  def unscope(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_Relation) }
  def optimizer_hints(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_Relation) }
  def merge(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_Relation) }
  def except(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_Relation) }
  def only(*args); end

  sig { params(block: T.proc.params(e: CachedUpholdTip).returns(T::Boolean)).returns(T::Array[CachedUpholdTip]) }
  def select(&block); end

  sig { params(args: T.any(String, Symbol, T::Array[T.any(String, Symbol)])).returns(CachedUpholdTip::ActiveRecord_Relation) }
  def select_columns(*args); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(CachedUpholdTip::ActiveRecord_Relation) }
  def extending(*args, &block); end

  sig do
    params(
      of: T.nilable(Integer),
      start: T.nilable(Integer),
      finish: T.nilable(Integer),
      load: T.nilable(T::Boolean),
      error_on_ignore: T.nilable(T::Boolean),
      block: T.nilable(T.proc.params(e: CachedUpholdTip::ActiveRecord_Relation).void)
    ).returns(ActiveRecord::Batches::BatchEnumerator)
  end
  def in_batches(of: 1000, start: nil, finish: nil, load: false, error_on_ignore: nil, &block); end
end

module CachedUpholdTip::QueryMethodsReturningAssociationRelation
  sig { returns(CachedUpholdTip::ActiveRecord_AssociationRelation) }
  def all; end

  sig { params(block: T.nilable(T.proc.void)).returns(CachedUpholdTip::ActiveRecord_Relation) }
  def unscoped(&block); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_AssociationRelation) }
  def reselect(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_AssociationRelation) }
  def order(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_AssociationRelation) }
  def reorder(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_AssociationRelation) }
  def group(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_AssociationRelation) }
  def limit(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_AssociationRelation) }
  def offset(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_AssociationRelation) }
  def joins(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_AssociationRelation) }
  def left_joins(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_AssociationRelation) }
  def left_outer_joins(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_AssociationRelation) }
  def where(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_AssociationRelation) }
  def rewhere(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_AssociationRelation) }
  def preload(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_AssociationRelation) }
  def extract_associated(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_AssociationRelation) }
  def eager_load(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_AssociationRelation) }
  def includes(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_AssociationRelation) }
  def from(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_AssociationRelation) }
  def lock(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_AssociationRelation) }
  def readonly(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_AssociationRelation) }
  def or(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_AssociationRelation) }
  def having(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_AssociationRelation) }
  def create_with(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_AssociationRelation) }
  def distinct(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_AssociationRelation) }
  def references(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_AssociationRelation) }
  def none(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_AssociationRelation) }
  def unscope(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_AssociationRelation) }
  def optimizer_hints(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_AssociationRelation) }
  def merge(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_AssociationRelation) }
  def except(*args); end

  sig { params(args: T.untyped).returns(CachedUpholdTip::ActiveRecord_AssociationRelation) }
  def only(*args); end

  sig { params(block: T.proc.params(e: CachedUpholdTip).returns(T::Boolean)).returns(T::Array[CachedUpholdTip]) }
  def select(&block); end

  sig { params(args: T.any(String, Symbol, T::Array[T.any(String, Symbol)])).returns(CachedUpholdTip::ActiveRecord_AssociationRelation) }
  def select_columns(*args); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(CachedUpholdTip::ActiveRecord_AssociationRelation) }
  def extending(*args, &block); end

  sig do
    params(
      of: T.nilable(Integer),
      start: T.nilable(Integer),
      finish: T.nilable(Integer),
      load: T.nilable(T::Boolean),
      error_on_ignore: T.nilable(T::Boolean),
      block: T.nilable(T.proc.params(e: CachedUpholdTip::ActiveRecord_AssociationRelation).void)
    ).returns(ActiveRecord::Batches::BatchEnumerator)
  end
  def in_batches(of: 1000, start: nil, finish: nil, load: false, error_on_ignore: nil, &block); end
end

class CachedUpholdTip::ActiveRecord_Relation < ActiveRecord::Relation
  include CachedUpholdTip::ActiveRelation_WhereNot
  include CachedUpholdTip::CustomFinderMethods
  include CachedUpholdTip::QueryMethodsReturningRelation
  Elem = type_member(fixed: CachedUpholdTip)
end

class CachedUpholdTip::ActiveRecord_AssociationRelation < ActiveRecord::AssociationRelation
  include CachedUpholdTip::ActiveRelation_WhereNot
  include CachedUpholdTip::CustomFinderMethods
  include CachedUpholdTip::QueryMethodsReturningAssociationRelation
  Elem = type_member(fixed: CachedUpholdTip)
end

class CachedUpholdTip::ActiveRecord_Associations_CollectionProxy < ActiveRecord::Associations::CollectionProxy
  include CachedUpholdTip::CustomFinderMethods
  include CachedUpholdTip::QueryMethodsReturningAssociationRelation
  Elem = type_member(fixed: CachedUpholdTip)

  sig { params(records: T.any(CachedUpholdTip, T::Array[CachedUpholdTip])).returns(T.self_type) }
  def <<(*records); end

  sig { params(records: T.any(CachedUpholdTip, T::Array[CachedUpholdTip])).returns(T.self_type) }
  def append(*records); end

  sig { params(records: T.any(CachedUpholdTip, T::Array[CachedUpholdTip])).returns(T.self_type) }
  def push(*records); end

  sig { params(records: T.any(CachedUpholdTip, T::Array[CachedUpholdTip])).returns(T.self_type) }
  def concat(*records); end
end
