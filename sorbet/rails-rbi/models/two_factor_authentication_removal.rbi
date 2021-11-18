# This is an autogenerated file for dynamic methods in TwoFactorAuthenticationRemoval
# Please rerun bundle exec rake rails_rbi:models[TwoFactorAuthenticationRemoval] to regenerate.

# typed: strong
module TwoFactorAuthenticationRemoval::ActiveRelation_WhereNot
  sig { params(opts: T.untyped, rest: T.untyped).returns(T.self_type) }
  def not(opts, *rest); end
end

module TwoFactorAuthenticationRemoval::GeneratedAttributeMethods
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

  sig { returns(String) }
  def publisher_id; end

  sig { params(value: T.any(String, Symbol)).void }
  def publisher_id=(value); end

  sig { returns(T::Boolean) }
  def publisher_id?; end

  sig { returns(T.nilable(T::Boolean)) }
  def removal_completed; end

  sig { params(value: T.nilable(T::Boolean)).void }
  def removal_completed=(value); end

  sig { returns(T::Boolean) }
  def removal_completed?; end

  sig { returns(ActiveSupport::TimeWithZone) }
  def updated_at; end

  sig { params(value: T.any(Date, Time, ActiveSupport::TimeWithZone)).void }
  def updated_at=(value); end

  sig { returns(T::Boolean) }
  def updated_at?; end
end

module TwoFactorAuthenticationRemoval::GeneratedAssociationMethods
  sig { returns(::Publisher) }
  def publisher; end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::Publisher).void)).returns(::Publisher) }
  def build_publisher(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::Publisher).void)).returns(::Publisher) }
  def create_publisher(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::Publisher).void)).returns(::Publisher) }
  def create_publisher!(*args, &block); end

  sig { params(value: ::Publisher).void }
  def publisher=(value); end

  sig { returns(::Publisher) }
  def reload_publisher; end
end

module TwoFactorAuthenticationRemoval::CustomFinderMethods
  sig { params(limit: Integer).returns(T::Array[TwoFactorAuthenticationRemoval]) }
  def first_n(limit); end

  sig { params(limit: Integer).returns(T::Array[TwoFactorAuthenticationRemoval]) }
  def last_n(limit); end

  sig { params(args: T::Array[T.any(Integer, String)]).returns(T::Array[TwoFactorAuthenticationRemoval]) }
  def find_n(*args); end

  sig { params(id: T.nilable(Integer)).returns(T.nilable(TwoFactorAuthenticationRemoval)) }
  def find_by_id(id); end

  sig { params(id: Integer).returns(TwoFactorAuthenticationRemoval) }
  def find_by_id!(id); end
end

class TwoFactorAuthenticationRemoval < ApplicationRecord
  include TwoFactorAuthenticationRemoval::GeneratedAttributeMethods
  include TwoFactorAuthenticationRemoval::GeneratedAssociationMethods
  extend TwoFactorAuthenticationRemoval::CustomFinderMethods
  extend TwoFactorAuthenticationRemoval::QueryMethodsReturningRelation
  RelationType = T.type_alias { T.any(TwoFactorAuthenticationRemoval::ActiveRecord_Relation, TwoFactorAuthenticationRemoval::ActiveRecord_Associations_CollectionProxy, TwoFactorAuthenticationRemoval::ActiveRecord_AssociationRelation) }
end

module TwoFactorAuthenticationRemoval::QueryMethodsReturningRelation
  sig { returns(TwoFactorAuthenticationRemoval::ActiveRecord_Relation) }
  def all; end

  sig { params(block: T.nilable(T.proc.void)).returns(TwoFactorAuthenticationRemoval::ActiveRecord_Relation) }
  def unscoped(&block); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_Relation) }
  def select(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_Relation) }
  def reselect(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_Relation) }
  def order(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_Relation) }
  def reorder(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_Relation) }
  def group(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_Relation) }
  def limit(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_Relation) }
  def offset(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_Relation) }
  def joins(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_Relation) }
  def left_joins(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_Relation) }
  def left_outer_joins(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_Relation) }
  def where(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_Relation) }
  def rewhere(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_Relation) }
  def preload(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_Relation) }
  def extract_associated(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_Relation) }
  def eager_load(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_Relation) }
  def includes(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_Relation) }
  def from(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_Relation) }
  def lock(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_Relation) }
  def readonly(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_Relation) }
  def or(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_Relation) }
  def having(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_Relation) }
  def create_with(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_Relation) }
  def distinct(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_Relation) }
  def references(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_Relation) }
  def none(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_Relation) }
  def unscope(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_Relation) }
  def optimizer_hints(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_Relation) }
  def merge(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_Relation) }
  def except(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_Relation) }
  def only(*args); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(TwoFactorAuthenticationRemoval::ActiveRecord_Relation) }
  def extending(*args, &block); end

  sig do
    params(
      of: T.nilable(Integer),
      start: T.nilable(Integer),
      finish: T.nilable(Integer),
      load: T.nilable(T::Boolean),
      error_on_ignore: T.nilable(T::Boolean),
      block: T.nilable(T.proc.params(e: TwoFactorAuthenticationRemoval::ActiveRecord_Relation).void)
    ).returns(ActiveRecord::Batches::BatchEnumerator)
  end
  def in_batches(of: 1000, start: nil, finish: nil, load: false, error_on_ignore: nil, &block); end
end

module TwoFactorAuthenticationRemoval::QueryMethodsReturningAssociationRelation
  sig { returns(TwoFactorAuthenticationRemoval::ActiveRecord_AssociationRelation) }
  def all; end

  sig { params(block: T.nilable(T.proc.void)).returns(TwoFactorAuthenticationRemoval::ActiveRecord_Relation) }
  def unscoped(&block); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_AssociationRelation) }
  def select(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_AssociationRelation) }
  def reselect(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_AssociationRelation) }
  def order(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_AssociationRelation) }
  def reorder(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_AssociationRelation) }
  def group(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_AssociationRelation) }
  def limit(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_AssociationRelation) }
  def offset(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_AssociationRelation) }
  def joins(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_AssociationRelation) }
  def left_joins(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_AssociationRelation) }
  def left_outer_joins(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_AssociationRelation) }
  def where(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_AssociationRelation) }
  def rewhere(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_AssociationRelation) }
  def preload(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_AssociationRelation) }
  def extract_associated(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_AssociationRelation) }
  def eager_load(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_AssociationRelation) }
  def includes(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_AssociationRelation) }
  def from(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_AssociationRelation) }
  def lock(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_AssociationRelation) }
  def readonly(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_AssociationRelation) }
  def or(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_AssociationRelation) }
  def having(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_AssociationRelation) }
  def create_with(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_AssociationRelation) }
  def distinct(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_AssociationRelation) }
  def references(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_AssociationRelation) }
  def none(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_AssociationRelation) }
  def unscope(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_AssociationRelation) }
  def optimizer_hints(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_AssociationRelation) }
  def merge(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_AssociationRelation) }
  def except(*args); end

  sig { params(args: T.untyped).returns(TwoFactorAuthenticationRemoval::ActiveRecord_AssociationRelation) }
  def only(*args); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(TwoFactorAuthenticationRemoval::ActiveRecord_AssociationRelation) }
  def extending(*args, &block); end

  sig do
    params(
      of: T.nilable(Integer),
      start: T.nilable(Integer),
      finish: T.nilable(Integer),
      load: T.nilable(T::Boolean),
      error_on_ignore: T.nilable(T::Boolean),
      block: T.nilable(T.proc.params(e: TwoFactorAuthenticationRemoval::ActiveRecord_AssociationRelation).void)
    ).returns(ActiveRecord::Batches::BatchEnumerator)
  end
  def in_batches(of: 1000, start: nil, finish: nil, load: false, error_on_ignore: nil, &block); end
end

class TwoFactorAuthenticationRemoval::ActiveRecord_Relation < ActiveRecord::Relation
  include TwoFactorAuthenticationRemoval::ActiveRelation_WhereNot
  include TwoFactorAuthenticationRemoval::CustomFinderMethods
  include TwoFactorAuthenticationRemoval::QueryMethodsReturningRelation
  Elem = type_member(fixed: TwoFactorAuthenticationRemoval)
end

class TwoFactorAuthenticationRemoval::ActiveRecord_AssociationRelation < ActiveRecord::AssociationRelation
  include TwoFactorAuthenticationRemoval::ActiveRelation_WhereNot
  include TwoFactorAuthenticationRemoval::CustomFinderMethods
  include TwoFactorAuthenticationRemoval::QueryMethodsReturningAssociationRelation
  Elem = type_member(fixed: TwoFactorAuthenticationRemoval)
end

class TwoFactorAuthenticationRemoval::ActiveRecord_Associations_CollectionProxy < ActiveRecord::Associations::CollectionProxy
  include TwoFactorAuthenticationRemoval::CustomFinderMethods
  include TwoFactorAuthenticationRemoval::QueryMethodsReturningAssociationRelation
  Elem = type_member(fixed: TwoFactorAuthenticationRemoval)

  sig { params(records: T.any(TwoFactorAuthenticationRemoval, T::Array[TwoFactorAuthenticationRemoval])).returns(T.self_type) }
  def <<(*records); end

  sig { params(records: T.any(TwoFactorAuthenticationRemoval, T::Array[TwoFactorAuthenticationRemoval])).returns(T.self_type) }
  def append(*records); end

  sig { params(records: T.any(TwoFactorAuthenticationRemoval, T::Array[TwoFactorAuthenticationRemoval])).returns(T.self_type) }
  def push(*records); end

  sig { params(records: T.any(TwoFactorAuthenticationRemoval, T::Array[TwoFactorAuthenticationRemoval])).returns(T.self_type) }
  def concat(*records); end
end
