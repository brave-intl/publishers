# This is an autogenerated file for dynamic methods in DailyMetric
# Please rerun bundle exec rake rails_rbi:models[DailyMetric] to regenerate.

# typed: strong
module DailyMetric::ActiveRelation_WhereNot
  sig { params(opts: T.untyped, rest: T.untyped).returns(T.self_type) }
  def not(opts, *rest); end
end

module DailyMetric::GeneratedAttributeMethods
  sig { returns(ActiveSupport::TimeWithZone) }
  def created_at; end

  sig { params(value: T.any(Date, Time, ActiveSupport::TimeWithZone)).void }
  def created_at=(value); end

  sig { returns(T::Boolean) }
  def created_at?; end

  sig { returns(Date) }
  def date; end

  sig { params(value: Date).void }
  def date=(value); end

  sig { returns(T::Boolean) }
  def date?; end

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

  sig { returns(T.any(T::Array[T.untyped], T::Boolean, Float, T::Hash[T.untyped, T.untyped], Integer, String)) }
  def result; end

  sig { params(value: T.any(T::Array[T.untyped], T::Boolean, Float, T::Hash[T.untyped, T.untyped], Integer, String)).void }
  def result=(value); end

  sig { returns(T::Boolean) }
  def result?; end

  sig { returns(ActiveSupport::TimeWithZone) }
  def updated_at; end

  sig { params(value: T.any(Date, Time, ActiveSupport::TimeWithZone)).void }
  def updated_at=(value); end

  sig { returns(T::Boolean) }
  def updated_at?; end
end

module DailyMetric::CustomFinderMethods
  sig { params(limit: Integer).returns(T::Array[DailyMetric]) }
  def first_n(limit); end

  sig { params(limit: Integer).returns(T::Array[DailyMetric]) }
  def last_n(limit); end

  sig { params(args: T::Array[T.any(Integer, String)]).returns(T::Array[DailyMetric]) }
  def find_n(*args); end

  sig { params(id: T.nilable(Integer)).returns(T.nilable(DailyMetric)) }
  def find_by_id(id); end

  sig { params(id: Integer).returns(DailyMetric) }
  def find_by_id!(id); end
end

class DailyMetric < ApplicationRecord
  include DailyMetric::GeneratedAttributeMethods
  extend DailyMetric::CustomFinderMethods
  extend DailyMetric::QueryMethodsReturningRelation
  RelationType = T.type_alias { T.any(DailyMetric::ActiveRecord_Relation, DailyMetric::ActiveRecord_Associations_CollectionProxy, DailyMetric::ActiveRecord_AssociationRelation) }
end

module DailyMetric::QueryMethodsReturningRelation
  sig { returns(DailyMetric::ActiveRecord_Relation) }
  def all; end

  sig { params(block: T.nilable(T.proc.void)).returns(DailyMetric::ActiveRecord_Relation) }
  def unscoped(&block); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_Relation) }
  def reselect(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_Relation) }
  def order(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_Relation) }
  def reorder(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_Relation) }
  def group(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_Relation) }
  def limit(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_Relation) }
  def offset(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_Relation) }
  def joins(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_Relation) }
  def left_joins(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_Relation) }
  def left_outer_joins(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_Relation) }
  def where(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_Relation) }
  def rewhere(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_Relation) }
  def preload(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_Relation) }
  def extract_associated(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_Relation) }
  def eager_load(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_Relation) }
  def includes(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_Relation) }
  def from(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_Relation) }
  def lock(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_Relation) }
  def readonly(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_Relation) }
  def or(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_Relation) }
  def having(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_Relation) }
  def create_with(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_Relation) }
  def distinct(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_Relation) }
  def references(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_Relation) }
  def none(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_Relation) }
  def unscope(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_Relation) }
  def optimizer_hints(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_Relation) }
  def merge(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_Relation) }
  def except(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_Relation) }
  def only(*args); end

  sig { params(block: T.proc.params(e: DailyMetric).returns(T::Boolean)).returns(T::Array[DailyMetric]) }
  def select(&block); end

  sig { params(args: T.any(String, Symbol, T::Array[T.any(String, Symbol)])).returns(DailyMetric::ActiveRecord_Relation) }
  def select_columns(*args); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(DailyMetric::ActiveRecord_Relation) }
  def extending(*args, &block); end

  sig do
    params(
      of: T.nilable(Integer),
      start: T.nilable(Integer),
      finish: T.nilable(Integer),
      load: T.nilable(T::Boolean),
      error_on_ignore: T.nilable(T::Boolean),
      block: T.nilable(T.proc.params(e: DailyMetric::ActiveRecord_Relation).void)
    ).returns(ActiveRecord::Batches::BatchEnumerator)
  end
  def in_batches(of: 1000, start: nil, finish: nil, load: false, error_on_ignore: nil, &block); end
end

module DailyMetric::QueryMethodsReturningAssociationRelation
  sig { returns(DailyMetric::ActiveRecord_AssociationRelation) }
  def all; end

  sig { params(block: T.nilable(T.proc.void)).returns(DailyMetric::ActiveRecord_Relation) }
  def unscoped(&block); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_AssociationRelation) }
  def reselect(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_AssociationRelation) }
  def order(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_AssociationRelation) }
  def reorder(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_AssociationRelation) }
  def group(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_AssociationRelation) }
  def limit(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_AssociationRelation) }
  def offset(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_AssociationRelation) }
  def joins(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_AssociationRelation) }
  def left_joins(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_AssociationRelation) }
  def left_outer_joins(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_AssociationRelation) }
  def where(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_AssociationRelation) }
  def rewhere(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_AssociationRelation) }
  def preload(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_AssociationRelation) }
  def extract_associated(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_AssociationRelation) }
  def eager_load(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_AssociationRelation) }
  def includes(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_AssociationRelation) }
  def from(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_AssociationRelation) }
  def lock(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_AssociationRelation) }
  def readonly(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_AssociationRelation) }
  def or(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_AssociationRelation) }
  def having(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_AssociationRelation) }
  def create_with(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_AssociationRelation) }
  def distinct(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_AssociationRelation) }
  def references(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_AssociationRelation) }
  def none(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_AssociationRelation) }
  def unscope(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_AssociationRelation) }
  def optimizer_hints(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_AssociationRelation) }
  def merge(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_AssociationRelation) }
  def except(*args); end

  sig { params(args: T.untyped).returns(DailyMetric::ActiveRecord_AssociationRelation) }
  def only(*args); end

  sig { params(block: T.proc.params(e: DailyMetric).returns(T::Boolean)).returns(T::Array[DailyMetric]) }
  def select(&block); end

  sig { params(args: T.any(String, Symbol, T::Array[T.any(String, Symbol)])).returns(DailyMetric::ActiveRecord_AssociationRelation) }
  def select_columns(*args); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(DailyMetric::ActiveRecord_AssociationRelation) }
  def extending(*args, &block); end

  sig do
    params(
      of: T.nilable(Integer),
      start: T.nilable(Integer),
      finish: T.nilable(Integer),
      load: T.nilable(T::Boolean),
      error_on_ignore: T.nilable(T::Boolean),
      block: T.nilable(T.proc.params(e: DailyMetric::ActiveRecord_AssociationRelation).void)
    ).returns(ActiveRecord::Batches::BatchEnumerator)
  end
  def in_batches(of: 1000, start: nil, finish: nil, load: false, error_on_ignore: nil, &block); end
end

class DailyMetric::ActiveRecord_Relation < ActiveRecord::Relation
  include DailyMetric::ActiveRelation_WhereNot
  include DailyMetric::CustomFinderMethods
  include DailyMetric::QueryMethodsReturningRelation
  Elem = type_member(fixed: DailyMetric)
end

class DailyMetric::ActiveRecord_AssociationRelation < ActiveRecord::AssociationRelation
  include DailyMetric::ActiveRelation_WhereNot
  include DailyMetric::CustomFinderMethods
  include DailyMetric::QueryMethodsReturningAssociationRelation
  Elem = type_member(fixed: DailyMetric)
end

class DailyMetric::ActiveRecord_Associations_CollectionProxy < ActiveRecord::Associations::CollectionProxy
  include DailyMetric::CustomFinderMethods
  include DailyMetric::QueryMethodsReturningAssociationRelation
  Elem = type_member(fixed: DailyMetric)

  sig { params(records: T.any(DailyMetric, T::Array[DailyMetric])).returns(T.self_type) }
  def <<(*records); end

  sig { params(records: T.any(DailyMetric, T::Array[DailyMetric])).returns(T.self_type) }
  def append(*records); end

  sig { params(records: T.any(DailyMetric, T::Array[DailyMetric])).returns(T.self_type) }
  def push(*records); end

  sig { params(records: T.any(DailyMetric, T::Array[DailyMetric])).returns(T.self_type) }
  def concat(*records); end
end
