# typed: false
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: publisher_prefix_list.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("publisher_prefix_list.proto", :syntax => :proto3) do
    add_message "publishers_pb.PublisherPrefixList" do
      optional :prefix_size, :uint32, 1
      optional :compression_type, :enum, 2, "publishers_pb.PublisherPrefixList.CompressionType"
      optional :uncompressed_size, :uint32, 3
      optional :prefixes, :bytes, 4
    end
    add_enum "publishers_pb.PublisherPrefixList.CompressionType" do
      value :NO_COMPRESSION, 0
      value :BROTLI_COMPRESSION, 1
    end
  end
end

module PublishersPb
  PublisherPrefixList = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("publishers_pb.PublisherPrefixList").msgclass
  PublisherPrefixList::CompressionType = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("publishers_pb.PublisherPrefixList.CompressionType").enummodule
end
