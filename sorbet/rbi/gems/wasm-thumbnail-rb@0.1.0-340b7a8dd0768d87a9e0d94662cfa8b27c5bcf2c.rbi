# typed: strict

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `wasm-thumbnail-rb` gem.
# Please instead update this file by running `bin/tapioca gem wasm-thumbnail-rb`.

module Wasm; end
module Wasm::Thumbnail; end

module Wasm::Thumbnail::Rb
  class << self
    def register_panic(_msg_ptr = T.unsafe(nil), _msg_len = T.unsafe(nil), _file_ptr = T.unsafe(nil), _file_len = T.unsafe(nil), _line = T.unsafe(nil), _column = T.unsafe(nil)); end
    def resize_and_pad(file_bytes:, width:, height:, size:, quality: T.unsafe(nil)); end
    def resize_and_pad_with_header(file_bytes:, width:, height:, size:, quality: T.unsafe(nil)); end
  end
end

class Wasm::Thumbnail::Rb::Error < ::StandardError; end

class Wasm::Thumbnail::Rb::GetWasmInstance
  class << self
    def call; end
  end
end

Wasm::Thumbnail::Rb::VERSION = T.let(T.unsafe(nil), String)
