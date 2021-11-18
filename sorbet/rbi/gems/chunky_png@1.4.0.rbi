# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `chunky_png` gem.
# Please instead update this file by running `bin/tapioca gem chunky_png`.

module ChunkyPNG
  class << self
    def Color(*args); end
    def Dimension(*args); end
    def Point(*args); end
    def Vector(*args); end

    private

    def build_dimension_from_object(source); end
    def build_point_from_object(source); end
  end
end

ChunkyPNG::COLOR_GRAYSCALE = T.let(T.unsafe(nil), Integer)
ChunkyPNG::COLOR_GRAYSCALE_ALPHA = T.let(T.unsafe(nil), Integer)
ChunkyPNG::COLOR_INDEXED = T.let(T.unsafe(nil), Integer)
ChunkyPNG::COLOR_TRUECOLOR = T.let(T.unsafe(nil), Integer)
ChunkyPNG::COLOR_TRUECOLOR_ALPHA = T.let(T.unsafe(nil), Integer)
ChunkyPNG::COMPRESSED_CONTENT = T.let(T.unsafe(nil), Integer)
ChunkyPNG::COMPRESSION_DEFAULT = T.let(T.unsafe(nil), Integer)
class ChunkyPNG::CRCMismatch < ::ChunkyPNG::Exception; end

class ChunkyPNG::Canvas
  include ::ChunkyPNG::Canvas::PNGEncoding
  include ::ChunkyPNG::Canvas::StreamExporting
  include ::ChunkyPNG::Canvas::DataUrlExporting
  include ::ChunkyPNG::Canvas::Operations
  include ::ChunkyPNG::Canvas::Drawing
  include ::ChunkyPNG::Canvas::Resampling
  include ::ChunkyPNG::Canvas::Masking
  extend ::ChunkyPNG::Canvas::PNGDecoding
  extend ::ChunkyPNG::Canvas::Adam7Interlacing
  extend ::ChunkyPNG::Canvas::StreamImporting
  extend ::ChunkyPNG::Canvas::DataUrlImporting

  def initialize(width, height, initial = T.unsafe(nil)); end

  def ==(other); end
  def [](x, y); end
  def []=(x, y, color); end
  def area; end
  def column(x); end
  def dimension; end
  def eql?(other); end
  def get_pixel(x, y); end
  def height; end
  def include?(*point_like); end
  def include_point?(*point_like); end
  def include_x?(x); end
  def include_xy?(x, y); end
  def include_y?(y); end
  def inspect; end
  def palette; end
  def pixels; end
  def replace_column!(x, vector); end
  def replace_row!(y, vector); end
  def row(y); end
  def set_pixel(x, y, color); end
  def set_pixel_if_within_bounds(x, y, color); end
  def to_image; end
  def width; end

  protected

  def assert_height!(vector_length); end
  def assert_size!(matrix_width, matrix_height); end
  def assert_width!(vector_length); end
  def assert_x!(x); end
  def assert_xy!(x, y); end
  def assert_y!(y); end
  def replace_canvas!(new_width, new_height, new_pixels); end

  private

  def initialize_copy(other); end

  class << self
    def from_canvas(canvas); end
  end
end

module ChunkyPNG::Canvas::Adam7Interlacing
  def adam7_extract_pass(pass, canvas); end
  def adam7_merge_pass(pass, canvas, subcanvas); end
  def adam7_multiplier_offset(pass); end
  def adam7_pass_size(pass, original_width, original_height); end
  def adam7_pass_sizes(original_width, original_height); end
end

module ChunkyPNG::Canvas::DataUrlExporting
  def to_data_url; end
end

module ChunkyPNG::Canvas::DataUrlImporting
  def from_data_url(string); end
end

module ChunkyPNG::Canvas::Drawing
  def bezier_curve(points, stroke_color = T.unsafe(nil)); end
  def circle(x0, y0, radius, stroke_color = T.unsafe(nil), fill_color = T.unsafe(nil)); end
  def compose_pixel(x, y, color); end
  def compose_pixel_unsafe(x, y, color); end
  def line(x0, y0, x1, y1, stroke_color, inclusive = T.unsafe(nil)); end
  def line_xiaolin_wu(x0, y0, x1, y1, stroke_color, inclusive = T.unsafe(nil)); end
  def polygon(path, stroke_color = T.unsafe(nil), fill_color = T.unsafe(nil)); end
  def rect(x0, y0, x1, y1, stroke_color = T.unsafe(nil), fill_color = T.unsafe(nil)); end

  private

  def binomial_coefficient(n, k); end
end

module ChunkyPNG::Canvas::Masking
  def change_mask_color!(new_color); end
  def change_theme_color!(old_theme_color, new_theme_color, bg_color = T.unsafe(nil), tolerance = T.unsafe(nil)); end
  def extract_mask(mask_color, bg_color = T.unsafe(nil), tolerance = T.unsafe(nil)); end
end

module ChunkyPNG::Canvas::Operations
  def border(size, color = T.unsafe(nil)); end
  def border!(size, color = T.unsafe(nil)); end
  def compose(other, offset_x = T.unsafe(nil), offset_y = T.unsafe(nil)); end
  def compose!(other, offset_x = T.unsafe(nil), offset_y = T.unsafe(nil)); end
  def crop(x, y, crop_width, crop_height); end
  def crop!(x, y, crop_width, crop_height); end
  def flip; end
  def flip!; end
  def flip_horizontally; end
  def flip_horizontally!; end
  def flip_vertically; end
  def flip_vertically!; end
  def grayscale; end
  def grayscale!; end
  def mirror; end
  def mirror!; end
  def replace(other, offset_x = T.unsafe(nil), offset_y = T.unsafe(nil)); end
  def replace!(other, offset_x = T.unsafe(nil), offset_y = T.unsafe(nil)); end
  def rotate_180; end
  def rotate_180!; end
  def rotate_clockwise; end
  def rotate_clockwise!; end
  def rotate_counter_clockwise; end
  def rotate_counter_clockwise!; end
  def rotate_left; end
  def rotate_left!; end
  def rotate_right; end
  def rotate_right!; end
  def trim(border = T.unsafe(nil)); end
  def trim!(border = T.unsafe(nil)); end

  protected

  def check_size_constraints!(other, offset_x, offset_y); end
end

module ChunkyPNG::Canvas::PNGDecoding
  def decode_png_pixelstream(stream, width, height, color_mode, depth, interlace, decoding_palette, transparent_color); end
  def from_blob(str); end
  def from_datastream(ds); end
  def from_file(filename); end
  def from_io(io); end
  def from_stream(io); end
  def from_string(str); end

  protected

  def decode_png_extract_1bit_value(byte, index); end
  def decode_png_extract_2bit_value(byte, index); end
  def decode_png_extract_4bit_value(byte, index); end
  def decode_png_image_pass(stream, width, height, color_mode, depth, start_pos, decoding_palette); end
  def decode_png_pixels_from_scanline_grayscale_16bit(stream, pos, width, _decoding_palette); end
  def decode_png_pixels_from_scanline_grayscale_1bit(stream, pos, width, _decoding_palette); end
  def decode_png_pixels_from_scanline_grayscale_2bit(stream, pos, width, _decoding_palette); end
  def decode_png_pixels_from_scanline_grayscale_4bit(stream, pos, width, _decoding_palette); end
  def decode_png_pixels_from_scanline_grayscale_8bit(stream, pos, width, _decoding_palette); end
  def decode_png_pixels_from_scanline_grayscale_alpha_16bit(stream, pos, width, _decoding_palette); end
  def decode_png_pixels_from_scanline_grayscale_alpha_8bit(stream, pos, width, _decoding_palette); end
  def decode_png_pixels_from_scanline_indexed_1bit(stream, pos, width, decoding_palette); end
  def decode_png_pixels_from_scanline_indexed_2bit(stream, pos, width, decoding_palette); end
  def decode_png_pixels_from_scanline_indexed_4bit(stream, pos, width, decoding_palette); end
  def decode_png_pixels_from_scanline_indexed_8bit(stream, pos, width, decoding_palette); end
  def decode_png_pixels_from_scanline_method(color_mode, depth); end
  def decode_png_pixels_from_scanline_truecolor_16bit(stream, pos, width, _decoding_palette); end
  def decode_png_pixels_from_scanline_truecolor_8bit(stream, pos, width, _decoding_palette); end
  def decode_png_pixels_from_scanline_truecolor_alpha_16bit(stream, pos, width, _decoding_palette); end
  def decode_png_pixels_from_scanline_truecolor_alpha_8bit(stream, pos, width, _decoding_palette); end
  def decode_png_resample_16bit_value(value); end
  def decode_png_resample_1bit_value(value); end
  def decode_png_resample_2bit_value(value); end
  def decode_png_resample_4bit_value(value); end
  def decode_png_resample_8bit_value(value); end
  def decode_png_str_scanline(stream, pos, prev_pos, line_length, pixel_size); end
  def decode_png_str_scanline_average(stream, pos, prev_pos, line_length, pixel_size); end
  def decode_png_str_scanline_paeth(stream, pos, prev_pos, line_length, pixel_size); end
  def decode_png_str_scanline_sub(stream, pos, prev_pos, line_length, pixel_size); end
  def decode_png_str_scanline_sub_none(stream, pos, prev_pos, line_length, pixel_size); end
  def decode_png_str_scanline_up(stream, pos, prev_pos, line_length, pixel_size); end
  def decode_png_with_adam7_interlacing(stream, width, height, color_mode, depth, decoding_palette); end
  def decode_png_without_interlacing(stream, width, height, color_mode, depth, decoding_palette); end
end

module ChunkyPNG::Canvas::PNGEncoding
  def encoding_palette; end
  def encoding_palette=(_arg0); end
  def save(filename, constraints = T.unsafe(nil)); end
  def to_blob(constraints = T.unsafe(nil)); end
  def to_datastream(constraints = T.unsafe(nil)); end
  def to_s(constraints = T.unsafe(nil)); end
  def to_string(constraints = T.unsafe(nil)); end
  def write(io, constraints = T.unsafe(nil)); end

  protected

  def determine_png_encoding(constraints = T.unsafe(nil)); end
  def encode_png_image_pass_to_stream(stream, color_mode, bit_depth, filtering); end
  def encode_png_image_with_interlacing(color_mode, bit_depth = T.unsafe(nil), filtering = T.unsafe(nil)); end
  def encode_png_image_without_interlacing(color_mode, bit_depth = T.unsafe(nil), filtering = T.unsafe(nil)); end
  def encode_png_pixels_to_scanline_grayscale_1bit(pixels); end
  def encode_png_pixels_to_scanline_grayscale_2bit(pixels); end
  def encode_png_pixels_to_scanline_grayscale_4bit(pixels); end
  def encode_png_pixels_to_scanline_grayscale_8bit(pixels); end
  def encode_png_pixels_to_scanline_grayscale_alpha_8bit(pixels); end
  def encode_png_pixels_to_scanline_indexed_1bit(pixels); end
  def encode_png_pixels_to_scanline_indexed_2bit(pixels); end
  def encode_png_pixels_to_scanline_indexed_4bit(pixels); end
  def encode_png_pixels_to_scanline_indexed_8bit(pixels); end
  def encode_png_pixels_to_scanline_method(color_mode, depth); end
  def encode_png_pixels_to_scanline_truecolor_8bit(pixels); end
  def encode_png_pixels_to_scanline_truecolor_alpha_8bit(pixels); end
  def encode_png_pixelstream(color_mode = T.unsafe(nil), bit_depth = T.unsafe(nil), interlace = T.unsafe(nil), filtering = T.unsafe(nil)); end
  def encode_png_str_scanline_average(stream, pos, prev_pos, line_width, pixel_size); end
  def encode_png_str_scanline_none(stream, pos, prev_pos, line_width, pixel_size); end
  def encode_png_str_scanline_paeth(stream, pos, prev_pos, line_width, pixel_size); end
  def encode_png_str_scanline_sub(stream, pos, prev_pos, line_width, pixel_size); end
  def encode_png_str_scanline_up(stream, pos, prev_pos, line_width, pixel_size); end
end

module ChunkyPNG::Canvas::Resampling
  def resample(new_width, new_height); end
  def resample_bilinear(new_width, new_height); end
  def resample_bilinear!(new_width, new_height); end
  def resample_nearest_neighbor(new_width, new_height); end
  def resample_nearest_neighbor!(new_width, new_height); end
  def resize(new_width, new_height); end
  def steps(width, new_width); end
  def steps_residues(width, new_width); end
end

module ChunkyPNG::Canvas::StreamExporting
  def to_abgr_stream; end
  def to_alpha_channel_stream; end
  def to_grayscale_stream; end
  def to_rgb_stream; end
  def to_rgba_stream; end
end

module ChunkyPNG::Canvas::StreamImporting
  def from_abgr_stream(width, height, stream); end
  def from_bgr_stream(width, height, stream); end
  def from_rgb_stream(width, height, stream); end
  def from_rgba_stream(width, height, stream); end
end

module ChunkyPNG::Chunk
  class << self
    def read(io); end
    def read_bytes(io, length); end
    def verify_crc!(type, content, found_crc); end
  end
end

class ChunkyPNG::Chunk::Base
  def initialize(type, attributes = T.unsafe(nil)); end

  def type; end
  def type=(_arg0); end
  def write(io); end
  def write_with_crc(io, content); end
end

ChunkyPNG::Chunk::CHUNK_TYPES = T.let(T.unsafe(nil), Hash)

class ChunkyPNG::Chunk::CompressedText < ::ChunkyPNG::Chunk::Base
  def initialize(keyword, value); end

  def content; end
  def keyword; end
  def keyword=(_arg0); end
  def value; end
  def value=(_arg0); end

  class << self
    def read(type, content); end
  end
end

class ChunkyPNG::Chunk::End < ::ChunkyPNG::Chunk::Base
  def initialize; end

  def content; end

  class << self
    def read(type, content); end
  end
end

class ChunkyPNG::Chunk::Generic < ::ChunkyPNG::Chunk::Base
  def initialize(type, content = T.unsafe(nil)); end

  def content; end
  def content=(_arg0); end

  class << self
    def read(type, content); end
  end
end

class ChunkyPNG::Chunk::Header < ::ChunkyPNG::Chunk::Base
  def initialize(attrs = T.unsafe(nil)); end

  def color; end
  def color=(_arg0); end
  def compression; end
  def compression=(_arg0); end
  def content; end
  def depth; end
  def depth=(_arg0); end
  def filtering; end
  def filtering=(_arg0); end
  def height; end
  def height=(_arg0); end
  def interlace; end
  def interlace=(_arg0); end
  def width; end
  def width=(_arg0); end

  class << self
    def read(type, content); end
  end
end

class ChunkyPNG::Chunk::ImageData < ::ChunkyPNG::Chunk::Generic
  class << self
    def combine_chunks(data_chunks); end
    def split_in_chunks(data, level = T.unsafe(nil), chunk_size = T.unsafe(nil)); end
  end
end

class ChunkyPNG::Chunk::InternationalText < ::ChunkyPNG::Chunk::Base
  def initialize(keyword, text, language_tag = T.unsafe(nil), translated_keyword = T.unsafe(nil), compressed = T.unsafe(nil), compression = T.unsafe(nil)); end

  def compressed; end
  def compressed=(_arg0); end
  def compression; end
  def compression=(_arg0); end
  def content; end
  def keyword; end
  def keyword=(_arg0); end
  def language_tag; end
  def language_tag=(_arg0); end
  def text; end
  def text=(_arg0); end
  def translated_keyword; end
  def translated_keyword=(_arg0); end

  class << self
    def read(type, content); end
  end
end

class ChunkyPNG::Chunk::Palette < ::ChunkyPNG::Chunk::Generic; end

class ChunkyPNG::Chunk::Physical < ::ChunkyPNG::Chunk::Base
  def initialize(ppux, ppuy, unit = T.unsafe(nil)); end

  def content; end
  def dpix; end
  def dpiy; end
  def ppux; end
  def ppux=(_arg0); end
  def ppuy; end
  def ppuy=(_arg0); end
  def unit; end
  def unit=(_arg0); end

  class << self
    def read(type, content); end
  end
end

ChunkyPNG::Chunk::Physical::INCHES_PER_METER = T.let(T.unsafe(nil), Float)

class ChunkyPNG::Chunk::Text < ::ChunkyPNG::Chunk::Base
  def initialize(keyword, value); end

  def content; end
  def keyword; end
  def keyword=(_arg0); end
  def value; end
  def value=(_arg0); end

  class << self
    def read(type, content); end
  end
end

class ChunkyPNG::Chunk::Transparency < ::ChunkyPNG::Chunk::Generic
  def grayscale_entry(bit_depth); end
  def palette_alpha_channel; end
  def truecolor_entry(bit_depth); end
end

module ChunkyPNG::Color
  extend ::ChunkyPNG::Color

  def a(value); end
  def alpha_decomposable?(color, mask, bg, tolerance = T.unsafe(nil)); end
  def b(value); end
  def blend(fg, bg); end
  def compose(fg, bg); end
  def compose_precise(fg, bg); end
  def compose_quick(fg, bg); end
  def decompose_alpha(color, mask, bg); end
  def decompose_alpha_component(channel, color, mask, bg); end
  def decompose_alpha_components(color, mask, bg); end
  def decompose_color(color, mask, bg, tolerance = T.unsafe(nil)); end
  def euclidean_distance_rgba(pixel_after, pixel_before); end
  def fade(color, factor); end
  def from_hex(hex_value, opacity = T.unsafe(nil)); end
  def from_hsb(hue, saturation, value, alpha = T.unsafe(nil)); end
  def from_hsl(hue, saturation, lightness, alpha = T.unsafe(nil)); end
  def from_hsv(hue, saturation, value, alpha = T.unsafe(nil)); end
  def from_rgb_stream(stream, pos = T.unsafe(nil)); end
  def from_rgba_stream(stream, pos = T.unsafe(nil)); end
  def fully_transparent?(value); end
  def g(value); end
  def grayscale(teint); end
  def grayscale?(value); end
  def grayscale_alpha(teint, a); end
  def grayscale_teint(color); end
  def html_color(color_name, opacity = T.unsafe(nil)); end
  def int8_mult(a, b); end
  def interpolate_quick(fg, bg, alpha); end
  def opaque!(value); end
  def opaque?(value); end
  def parse(source); end
  def pass_bytesize(color_mode, depth, width, height); end
  def pixel_bitsize(color_mode, depth = T.unsafe(nil)); end
  def pixel_bytesize(color_mode, depth = T.unsafe(nil)); end
  def r(value); end
  def rgb(r, g, b); end
  def rgba(r, g, b, a); end
  def samples_per_pixel(color_mode); end
  def scanline_bytesize(color_mode, depth, width); end
  def to_grayscale(color); end
  def to_grayscale_alpha_bytes(color); end
  def to_grayscale_bytes(color); end
  def to_hex(color, include_alpha = T.unsafe(nil)); end
  def to_hsb(color, include_alpha = T.unsafe(nil)); end
  def to_hsl(color, include_alpha = T.unsafe(nil)); end
  def to_hsv(color, include_alpha = T.unsafe(nil)); end
  def to_truecolor_alpha_bytes(color); end
  def to_truecolor_bytes(color); end

  private

  def cylindrical_to_cubic(hue, saturation, y_component, chroma); end
  def hue_and_chroma(color); end
end

ChunkyPNG::Color::BLACK = T.let(T.unsafe(nil), Integer)
ChunkyPNG::Color::HEX3_COLOR_REGEXP = T.let(T.unsafe(nil), Regexp)
ChunkyPNG::Color::HEX6_COLOR_REGEXP = T.let(T.unsafe(nil), Regexp)
ChunkyPNG::Color::HTML_COLOR_REGEXP = T.let(T.unsafe(nil), Regexp)
ChunkyPNG::Color::MAX = T.let(T.unsafe(nil), Integer)
ChunkyPNG::Color::MAX_EUCLIDEAN_DISTANCE_RGBA = T.let(T.unsafe(nil), Float)
ChunkyPNG::Color::PREDEFINED_COLORS = T.let(T.unsafe(nil), Hash)
ChunkyPNG::Color::TRANSPARENT = T.let(T.unsafe(nil), Integer)
ChunkyPNG::Color::WHITE = T.let(T.unsafe(nil), Integer)

class ChunkyPNG::Datastream
  def initialize; end

  def chunks; end
  def data_chunks; end
  def data_chunks=(_arg0); end
  def each_chunk; end
  def end_chunk; end
  def end_chunk=(_arg0); end
  def header_chunk; end
  def header_chunk=(_arg0); end
  def imagedata; end
  def metadata; end
  def other_chunks; end
  def other_chunks=(_arg0); end
  def palette_chunk; end
  def palette_chunk=(_arg0); end
  def physical_chunk; end
  def physical_chunk=(_arg0); end
  def save(filename); end
  def to_blob; end
  def to_s; end
  def to_string; end
  def transparency_chunk; end
  def transparency_chunk=(_arg0); end
  def write(io); end

  class << self
    def from_blob(str); end
    def from_file(filename); end
    def from_io(io); end
    def from_string(str); end
    def verify_signature!(io); end
  end
end

ChunkyPNG::Datastream::SIGNATURE = T.let(T.unsafe(nil), String)

class ChunkyPNG::Dimension
  def initialize(width, height); end

  def <=>(other); end
  def ==(other); end
  def area; end
  def eql?(other); end
  def hash; end
  def height; end
  def height=(_arg0); end
  def include?(*point_like); end
  def to_a; end
  def to_ary; end
  def width; end
  def width=(_arg0); end
end

ChunkyPNG::Dimension::DIMENSION_REGEXP = T.let(T.unsafe(nil), Regexp)
ChunkyPNG::EXTRA_BYTE = T.let(T.unsafe(nil), String)
class ChunkyPNG::Exception < ::StandardError; end
class ChunkyPNG::ExpectationFailed < ::ChunkyPNG::Exception; end
ChunkyPNG::FILTERING_DEFAULT = T.let(T.unsafe(nil), Integer)
ChunkyPNG::FILTER_AVERAGE = T.let(T.unsafe(nil), Integer)
ChunkyPNG::FILTER_NONE = T.let(T.unsafe(nil), Integer)
ChunkyPNG::FILTER_PAETH = T.let(T.unsafe(nil), Integer)
ChunkyPNG::FILTER_SUB = T.let(T.unsafe(nil), Integer)
ChunkyPNG::FILTER_UP = T.let(T.unsafe(nil), Integer)
ChunkyPNG::INTERLACING_ADAM7 = T.let(T.unsafe(nil), Integer)
ChunkyPNG::INTERLACING_NONE = T.let(T.unsafe(nil), Integer)

class ChunkyPNG::Image < ::ChunkyPNG::Canvas
  def initialize(width, height, bg_color = T.unsafe(nil), metadata = T.unsafe(nil)); end

  def metadata; end
  def metadata=(_arg0); end
  def metadata_chunks; end
  def to_datastream(constraints = T.unsafe(nil)); end

  private

  def initialize_copy(other); end

  class << self
    def from_datastream(ds); end
  end
end

ChunkyPNG::Image::METADATA_COMPRESSION_TRESHOLD = T.let(T.unsafe(nil), Integer)
class ChunkyPNG::InvalidUTF8 < ::ChunkyPNG::Exception; end
class ChunkyPNG::NotSupported < ::ChunkyPNG::Exception; end
class ChunkyPNG::OutOfBounds < ::ChunkyPNG::ExpectationFailed; end

class ChunkyPNG::Palette < ::Set
  def initialize(enum, decoding_map = T.unsafe(nil)); end

  def [](index); end
  def best_color_settings; end
  def black_and_white?; end
  def can_decode?; end
  def can_encode?; end
  def determine_bit_depth; end
  def grayscale?; end
  def index(color); end
  def indexable?; end
  def opaque?; end
  def opaque_palette; end
  def to_plte_chunk; end
  def to_trns_chunk; end

  class << self
    def from_canvas(canvas); end
    def from_chunks(palette_chunk, transparency_chunk = T.unsafe(nil)); end
    def from_pixels(pixels); end
  end
end

class ChunkyPNG::Point
  def initialize(x, y); end

  def <=>(other); end
  def ==(other); end
  def eql?(other); end
  def to_a; end
  def to_ary; end
  def within_bounds?(*dimension_like); end
  def x; end
  def x=(_arg0); end
  def y; end
  def y=(_arg0); end
end

ChunkyPNG::Point::POINT_REGEXP = T.let(T.unsafe(nil), Regexp)
class ChunkyPNG::SignatureMismatch < ::ChunkyPNG::Exception; end
ChunkyPNG::UNCOMPRESSED_CONTENT = T.let(T.unsafe(nil), Integer)
class ChunkyPNG::UnitsUnknown < ::ChunkyPNG::Exception; end
ChunkyPNG::VERSION = T.let(T.unsafe(nil), String)

class ChunkyPNG::Vector
  include ::Enumerable

  def initialize(points = T.unsafe(nil)); end

  def ==(other); end
  def [](index); end
  def dimension; end
  def each(&block); end
  def each_edge(close = T.unsafe(nil)); end
  def edges(close = T.unsafe(nil)); end
  def eql?(other); end
  def height; end
  def length; end
  def max_x; end
  def max_y; end
  def min_x; end
  def min_y; end
  def offset; end
  def points; end
  def width; end
  def x_range; end
  def y_range; end

  class << self
    def multiple_from_array(source); end
    def multiple_from_string(source_str); end
  end
end
