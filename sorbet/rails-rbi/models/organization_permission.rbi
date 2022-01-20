# This is an autogenerated file for dynamic methods in OrganizationPermission
# Please rerun bundle exec rake rails_rbi:models[OrganizationPermission] to regenerate.

# typed: strong
module OrganizationPermission::ActiveRelation_WhereNot
  sig { params(opts: T.untyped, rest: T.untyped).returns(T.self_type) }
  def not(opts, *rest); end
end

module OrganizationPermission::GeneratedAttributeMethods
  sig { returns(String) }
  def id; end

  sig { params(value: T.any(String, Symbol)).void }
  def id=(value); end

  sig { returns(T::Boolean) }
  def id?; end

  sig { returns(T::Boolean) }
  def offline_reporting; end

  sig { params(value: T::Boolean).void }
  def offline_reporting=(value); end

  sig { returns(T::Boolean) }
  def offline_reporting?; end

  sig { returns(T.nilable(String)) }
  def organization_id; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def organization_id=(value); end

  sig { returns(T::Boolean) }
  def organization_id?; end

  sig { returns(T::Boolean) }
  def referral_codes; end

  sig { params(value: T::Boolean).void }
  def referral_codes=(value); end

  sig { returns(T::Boolean) }
  def referral_codes?; end

  sig { returns(T::Boolean) }
  def uphold_wallet; end

  sig { params(value: T::Boolean).void }
  def uphold_wallet=(value); end

  sig { returns(T::Boolean) }
  def uphold_wallet?; end
end

module OrganizationPermission::GeneratedAssociationMethods
  sig { returns(T.nilable(::Organization)) }
  def organization; end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::Organization).void)).returns(::Organization) }
  def build_organization(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::Organization).void)).returns(::Organization) }
  def create_organization(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::Organization).void)).returns(::Organization) }
  def create_organization!(*args, &block); end

  sig { params(value: T.nilable(::Organization)).void }
  def organization=(value); end

  sig { returns(T.nilable(::Organization)) }
  def reload_organization; end
end

module OrganizationPermission::CustomFinderMethods
  sig { params(limit: Integer).returns(T::Array[OrganizationPermission]) }
  def first_n(limit); end

  sig { params(limit: Integer).returns(T::Array[OrganizationPermission]) }
  def last_n(limit); end

  sig { params(args: T::Array[T.any(Integer, String)]).returns(T::Array[OrganizationPermission]) }
  def find_n(*args); end

  sig { params(id: T.nilable(Integer)).returns(T.nilable(OrganizationPermission)) }
  def find_by_id(id); end

  sig { params(id: Integer).returns(OrganizationPermission) }
  def find_by_id!(id); end
end

class OrganizationPermission < ApplicationRecord
  include OrganizationPermission::GeneratedAttributeMethods
  include OrganizationPermission::GeneratedAssociationMethods
  extend OrganizationPermission::CustomFinderMethods
  extend OrganizationPermission::QueryMethodsReturningRelation
  RelationType = T.type_alias { T.any(OrganizationPermission::ActiveRecord_Relation, OrganizationPermission::ActiveRecord_Associations_CollectionProxy, OrganizationPermission::ActiveRecord_AssociationRelation) }
end

module OrganizationPermission::QueryMethodsReturningRelation
  sig { returns(OrganizationPermission::ActiveRecord_Relation) }
  def all; end

  sig { params(block: T.nilable(T.proc.void)).returns(OrganizationPermission::ActiveRecord_Relation) }
  def unscoped(&block); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_Relation) }
  def reselect(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_Relation) }
  def order(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_Relation) }
  def reorder(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_Relation) }
  def group(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_Relation) }
  def limit(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_Relation) }
  def offset(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_Relation) }
  def joins(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_Relation) }
  def left_joins(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_Relation) }
  def left_outer_joins(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_Relation) }
  def where(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_Relation) }
  def rewhere(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_Relation) }
  def preload(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_Relation) }
  def extract_associated(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_Relation) }
  def eager_load(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_Relation) }
  def includes(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_Relation) }
  def from(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_Relation) }
  def lock(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_Relation) }
  def readonly(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_Relation) }
  def or(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_Relation) }
  def having(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_Relation) }
  def create_with(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_Relation) }
  def distinct(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_Relation) }
  def references(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_Relation) }
  def none(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_Relation) }
  def unscope(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_Relation) }
  def optimizer_hints(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_Relation) }
  def merge(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_Relation) }
  def except(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_Relation) }
  def only(*args); end

  sig { params(block: T.proc.params(e: OrganizationPermission).returns(T::Boolean)).returns(T::Array[OrganizationPermission]) }
  def select(&block); end

  sig { params(args: T.any(String, Symbol, T::Array[T.any(String, Symbol)])).returns(OrganizationPermission::ActiveRecord_Relation) }
  def select_columns(*args); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(OrganizationPermission::ActiveRecord_Relation) }
  def extending(*args, &block); end

  sig do
    params(
      of: T.nilable(Integer),
      start: T.nilable(Integer),
      finish: T.nilable(Integer),
      load: T.nilable(T::Boolean),
      error_on_ignore: T.nilable(T::Boolean),
      block: T.nilable(T.proc.params(e: OrganizationPermission::ActiveRecord_Relation).void)
    ).returns(ActiveRecord::Batches::BatchEnumerator)
  end
  def in_batches(of: 1000, start: nil, finish: nil, load: false, error_on_ignore: nil, &block); end
end

module OrganizationPermission::QueryMethodsReturningAssociationRelation
  sig { returns(OrganizationPermission::ActiveRecord_AssociationRelation) }
  def all; end

  sig { params(block: T.nilable(T.proc.void)).returns(OrganizationPermission::ActiveRecord_Relation) }
  def unscoped(&block); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_AssociationRelation) }
  def reselect(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_AssociationRelation) }
  def order(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_AssociationRelation) }
  def reorder(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_AssociationRelation) }
  def group(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_AssociationRelation) }
  def limit(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_AssociationRelation) }
  def offset(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_AssociationRelation) }
  def joins(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_AssociationRelation) }
  def left_joins(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_AssociationRelation) }
  def left_outer_joins(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_AssociationRelation) }
  def where(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_AssociationRelation) }
  def rewhere(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_AssociationRelation) }
  def preload(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_AssociationRelation) }
  def extract_associated(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_AssociationRelation) }
  def eager_load(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_AssociationRelation) }
  def includes(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_AssociationRelation) }
  def from(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_AssociationRelation) }
  def lock(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_AssociationRelation) }
  def readonly(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_AssociationRelation) }
  def or(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_AssociationRelation) }
  def having(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_AssociationRelation) }
  def create_with(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_AssociationRelation) }
  def distinct(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_AssociationRelation) }
  def references(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_AssociationRelation) }
  def none(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_AssociationRelation) }
  def unscope(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_AssociationRelation) }
  def optimizer_hints(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_AssociationRelation) }
  def merge(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_AssociationRelation) }
  def except(*args); end

  sig { params(args: T.untyped).returns(OrganizationPermission::ActiveRecord_AssociationRelation) }
  def only(*args); end

  sig { params(block: T.proc.params(e: OrganizationPermission).returns(T::Boolean)).returns(T::Array[OrganizationPermission]) }
  def select(&block); end

  sig { params(args: T.any(String, Symbol, T::Array[T.any(String, Symbol)])).returns(OrganizationPermission::ActiveRecord_AssociationRelation) }
  def select_columns(*args); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(OrganizationPermission::ActiveRecord_AssociationRelation) }
  def extending(*args, &block); end

  sig do
    params(
      of: T.nilable(Integer),
      start: T.nilable(Integer),
      finish: T.nilable(Integer),
      load: T.nilable(T::Boolean),
      error_on_ignore: T.nilable(T::Boolean),
      block: T.nilable(T.proc.params(e: OrganizationPermission::ActiveRecord_AssociationRelation).void)
    ).returns(ActiveRecord::Batches::BatchEnumerator)
  end
  def in_batches(of: 1000, start: nil, finish: nil, load: false, error_on_ignore: nil, &block); end
end

class OrganizationPermission::ActiveRecord_Relation < ActiveRecord::Relation
  include OrganizationPermission::ActiveRelation_WhereNot
  include OrganizationPermission::CustomFinderMethods
  include OrganizationPermission::QueryMethodsReturningRelation
  Elem = type_member(fixed: OrganizationPermission)
end

class OrganizationPermission::ActiveRecord_AssociationRelation < ActiveRecord::AssociationRelation
  include OrganizationPermission::ActiveRelation_WhereNot
  include OrganizationPermission::CustomFinderMethods
  include OrganizationPermission::QueryMethodsReturningAssociationRelation
  Elem = type_member(fixed: OrganizationPermission)
end

class OrganizationPermission::ActiveRecord_Associations_CollectionProxy < ActiveRecord::Associations::CollectionProxy
  include OrganizationPermission::CustomFinderMethods
  include OrganizationPermission::QueryMethodsReturningAssociationRelation
  Elem = type_member(fixed: OrganizationPermission)

  sig { params(records: T.any(OrganizationPermission, T::Array[OrganizationPermission])).returns(T.self_type) }
  def <<(*records); end

  sig { params(records: T.any(OrganizationPermission, T::Array[OrganizationPermission])).returns(T.self_type) }
  def append(*records); end

  sig { params(records: T.any(OrganizationPermission, T::Array[OrganizationPermission])).returns(T.self_type) }
  def push(*records); end

  sig { params(records: T.any(OrganizationPermission, T::Array[OrganizationPermission])).returns(T.self_type) }
  def concat(*records); end
end
