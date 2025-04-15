# Test loading of the tsf file
require "tsf"
require "minitest/autorun"

class ModelTest < Minitest::Test

  def test_tsf_to_svg_without_image
    # Load the TSF file
    data = File.read("test/fixtures/basic_file.tsf")

    # Parse the TSF data
    vector = Tsf::Vector.load_tsf(data)

    # Check if the vector object is loaded
    assert vector.loaded, "Vector object should be loaded"

    puts vector.to_svg
  end

  def test_tsf_to_svg_with_image
    # Load the TSF file
    data = File.read("test/fixtures/bitmap_file.tsf")

    # Parse the TSF data
    vector = Tsf::Vector.load_tsf(data)

    # Check if the vector object is loaded
    assert vector.loaded, "Vector object should be loaded"

    puts vector.to_svg
  end
end