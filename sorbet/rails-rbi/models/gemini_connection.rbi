# This is an autogenerated file for dynamic methods in GeminiConnection
# Please rerun bundle exec rake rails_rbi:models[GeminiConnection] to regenerate.

# typed: ignore
module GeminiConnection::ActiveRelation_WhereNot
  sig { params(opts: T.untyped, rest: T.untyped).returns(T.self_type) }
  def not(opts, *rest); end
end

module GeminiConnection::GeneratedAttributeMethods
  sig { returns(T.nilable(ActiveSupport::TimeWithZone)) }
  def access_expiration_time; end

  sig { params(value: T.nilable(T.any(Date, Time, ActiveSupport::TimeWithZone))).void }
  def access_expiration_time=(value); end

  sig { returns(T::Boolean) }
  def access_expiration_time?; end

  sig { returns(T.nilable(String)) }
  def country; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def country=(value); end

  sig { returns(T::Boolean) }
  def country?; end

  sig { returns(ActiveSupport::TimeWithZone) }
  def created_at; end

  sig { params(value: T.any(Date, Time, ActiveSupport::TimeWithZone)).void }
  def created_at=(value); end

  sig { returns(T::Boolean) }
  def created_at?; end

  sig { returns(T.nilable(String)) }
  def display_name; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def display_name=(value); end

  sig { returns(T::Boolean) }
  def display_name?; end

  sig { returns(T.nilable(String)) }
  def encrypted_access_token; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def encrypted_access_token=(value); end

  sig { returns(T::Boolean) }
  def encrypted_access_token?; end

  sig { returns(T.nilable(String)) }
  def encrypted_access_token_iv; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def encrypted_access_token_iv=(value); end

  sig { returns(T::Boolean) }
  def encrypted_access_token_iv?; end

  sig { returns(T.nilable(String)) }
  def encrypted_refresh_token; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def encrypted_refresh_token=(value); end

  sig { returns(T::Boolean) }
  def encrypted_refresh_token?; end

  sig { returns(T.nilable(String)) }
  def encrypted_refresh_token_iv; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def encrypted_refresh_token_iv=(value); end

  sig { returns(T::Boolean) }
  def encrypted_refresh_token_iv?; end

  sig { returns(T.nilable(String)) }
  def expires_in; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def expires_in=(value); end

  sig { returns(T::Boolean) }
  def expires_in?; end

  sig { returns(String) }
  def id; end

  sig { params(value: T.any(String, Symbol)).void }
  def id=(value); end

  sig { returns(T::Boolean) }
  def id?; end

  sig { returns(T.nilable(T::Boolean)) }
  def is_verified; end

  sig { params(value: T.nilable(T::Boolean)).void }
  def is_verified=(value); end

  sig { returns(T::Boolean) }
  def is_verified?; end

  sig { returns(String) }
  def publisher_id; end

  sig { params(value: T.any(String, Symbol)).void }
  def publisher_id=(value); end

  sig { returns(T::Boolean) }
  def publisher_id?; end

  sig { returns(T.nilable(String)) }
  def recipient_id; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def recipient_id=(value); end

  sig { returns(T::Boolean) }
  def recipient_id?; end

  sig { returns(T.nilable(String)) }
  def scope; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def scope=(value); end

  sig { returns(T::Boolean) }
  def scope?; end

  sig { returns(T.nilable(String)) }
  def state_token; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def state_token=(value); end

  sig { returns(T::Boolean) }
  def state_token?; end

  sig { returns(T.nilable(String)) }
  def status; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def status=(value); end

  sig { returns(T::Boolean) }
  def status?; end

  sig { returns(ActiveSupport::TimeWithZone) }
  def updated_at; end

  sig { params(value: T.any(Date, Time, ActiveSupport::TimeWithZone)).void }
  def updated_at=(value); end

  sig { returns(T::Boolean) }
  def updated_at?; end
end

module GeminiConnection::GeneratedAssociationMethods
  sig { returns(::GeminiConnectionForChannel::ActiveRecord_Associations_CollectionProxy) }
  def gemini_connection_for_channels; end

  sig { returns(T::Array[String]) }
  def gemini_connection_for_channel_ids; end

  sig { params(value: T::Enumerable[::GeminiConnectionForChannel]).void }
  def gemini_connection_for_channels=(value); end

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

  sig { returns(::PaperTrail::Version::ActiveRecord_Associations_CollectionProxy) }
  def versions; end

  sig { returns(T::Array[String]) }
  def version_ids; end

  sig { params(value: T::Enumerable[::PaperTrail::Version]).void }
  def versions=(value); end
end

module GeminiConnection::CustomFinderMethods
  sig { params(limit: Integer).returns(T::Array[GeminiConnection]) }
  def first_n(limit); end

  sig { params(limit: Integer).returns(T::Array[GeminiConnection]) }
  def last_n(limit); end

  sig { params(args: T::Array[T.any(Integer, String)]).returns(T::Array[GeminiConnection]) }
  def find_n(*args); end

  sig { params(id: T.nilable(Integer)).returns(T.nilable(GeminiConnection)) }
  def find_by_id(id); end

  sig { params(id: Integer).returns(GeminiConnection) }
  def find_by_id!(id); end
end

class GeminiConnection < ApplicationRecord
  include GeminiConnection::GeneratedAttributeMethods
  include GeminiConnection::GeneratedAssociationMethods
  extend GeminiConnection::CustomFinderMethods
  extend GeminiConnection::QueryMethodsReturningRelation
  RelationType = T.type_alias { T.any(GeminiConnection::ActiveRecord_Relation, GeminiConnection::ActiveRecord_Associations_CollectionProxy, GeminiConnection::ActiveRecord_AssociationRelation) }

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_Relation) }
  def self.payable(*args); end
end

class GeminiConnection::ActiveRecord_Relation < ActiveRecord::Relation
  include GeminiConnection::ActiveRelation_WhereNot
  include GeminiConnection::CustomFinderMethods
  include GeminiConnection::QueryMethodsReturningRelation
  Elem = type_member(fixed: GeminiConnection)

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_Relation) }
  def payable(*args); end
end

class GeminiConnection::ActiveRecord_AssociationRelation < ActiveRecord::AssociationRelation
  include GeminiConnection::ActiveRelation_WhereNot
  include GeminiConnection::CustomFinderMethods
  include GeminiConnection::QueryMethodsReturningAssociationRelation
  Elem = type_member(fixed: GeminiConnection)

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_AssociationRelation) }
  def payable(*args); end
end

class GeminiConnection::ActiveRecord_Associations_CollectionProxy < ActiveRecord::Associations::CollectionProxy
  include GeminiConnection::CustomFinderMethods
  include GeminiConnection::QueryMethodsReturningAssociationRelation
  Elem = type_member(fixed: GeminiConnection)

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_AssociationRelation) }
  def payable(*args); end

  sig { params(records: T.any(GeminiConnection, T::Array[GeminiConnection])).returns(T.self_type) }
  def <<(*records); end

  sig { params(records: T.any(GeminiConnection, T::Array[GeminiConnection])).returns(T.self_type) }
  def append(*records); end

  sig { params(records: T.any(GeminiConnection, T::Array[GeminiConnection])).returns(T.self_type) }
  def push(*records); end

  sig { params(records: T.any(GeminiConnection, T::Array[GeminiConnection])).returns(T.self_type) }
  def concat(*records); end
end

module GeminiConnection::QueryMethodsReturningRelation
  sig { returns(GeminiConnection::ActiveRecord_Relation) }
  def all; end

  sig { params(block: T.nilable(T.proc.void)).returns(GeminiConnection::ActiveRecord_Relation) }
  def unscoped(&block); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_Relation) }
  def select(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_Relation) }
  def reselect(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_Relation) }
  def order(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_Relation) }
  def reorder(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_Relation) }
  def group(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_Relation) }
  def limit(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_Relation) }
  def offset(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_Relation) }
  def joins(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_Relation) }
  def left_joins(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_Relation) }
  def left_outer_joins(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_Relation) }
  def where(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_Relation) }
  def rewhere(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_Relation) }
  def preload(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_Relation) }
  def extract_associated(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_Relation) }
  def eager_load(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_Relation) }
  def includes(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_Relation) }
  def from(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_Relation) }
  def lock(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_Relation) }
  def readonly(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_Relation) }
  def or(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_Relation) }
  def having(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_Relation) }
  def create_with(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_Relation) }
  def distinct(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_Relation) }
  def references(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_Relation) }
  def none(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_Relation) }
  def unscope(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_Relation) }
  def optimizer_hints(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_Relation) }
  def merge(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_Relation) }
  def except(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_Relation) }
  def only(*args); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(GeminiConnection::ActiveRecord_Relation) }
  def extending(*args, &block); end

  sig do
    params(
      of: T.nilable(Integer),
      start: T.nilable(Integer),
      finish: T.nilable(Integer),
      load: T.nilable(T::Boolean),
      error_on_ignore: T.nilable(T::Boolean),
      block: T.nilable(T.proc.params(e: GeminiConnection::ActiveRecord_Relation).void)
    ).returns(ActiveRecord::Batches::BatchEnumerator)
  end
  def in_batches(of: 1000, start: nil, finish: nil, load: false, error_on_ignore: nil, &block); end
end

module GeminiConnection::QueryMethodsReturningAssociationRelation
  sig { returns(GeminiConnection::ActiveRecord_AssociationRelation) }
  def all; end

  sig { params(block: T.nilable(T.proc.void)).returns(GeminiConnection::ActiveRecord_Relation) }
  def unscoped(&block); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_AssociationRelation) }
  def select(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_AssociationRelation) }
  def reselect(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_AssociationRelation) }
  def order(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_AssociationRelation) }
  def reorder(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_AssociationRelation) }
  def group(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_AssociationRelation) }
  def limit(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_AssociationRelation) }
  def offset(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_AssociationRelation) }
  def joins(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_AssociationRelation) }
  def left_joins(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_AssociationRelation) }
  def left_outer_joins(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_AssociationRelation) }
  def where(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_AssociationRelation) }
  def rewhere(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_AssociationRelation) }
  def preload(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_AssociationRelation) }
  def extract_associated(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_AssociationRelation) }
  def eager_load(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_AssociationRelation) }
  def includes(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_AssociationRelation) }
  def from(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_AssociationRelation) }
  def lock(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_AssociationRelation) }
  def readonly(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_AssociationRelation) }
  def or(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_AssociationRelation) }
  def having(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_AssociationRelation) }
  def create_with(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_AssociationRelation) }
  def distinct(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_AssociationRelation) }
  def references(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_AssociationRelation) }
  def none(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_AssociationRelation) }
  def unscope(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_AssociationRelation) }
  def optimizer_hints(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_AssociationRelation) }
  def merge(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_AssociationRelation) }
  def except(*args); end

  sig { params(args: T.untyped).returns(GeminiConnection::ActiveRecord_AssociationRelation) }
  def only(*args); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(GeminiConnection::ActiveRecord_AssociationRelation) }
  def extending(*args, &block); end

  sig do
    params(
      of: T.nilable(Integer),
      start: T.nilable(Integer),
      finish: T.nilable(Integer),
      load: T.nilable(T::Boolean),
      error_on_ignore: T.nilable(T::Boolean),
      block: T.nilable(T.proc.params(e: GeminiConnection::ActiveRecord_AssociationRelation).void)
    ).returns(ActiveRecord::Batches::BatchEnumerator)
  end
  def in_batches(of: 1000, start: nil, finish: nil, load: false, error_on_ignore: nil, &block); end
end
