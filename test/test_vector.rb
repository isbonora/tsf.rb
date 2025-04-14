# Test loading of the tsf file
require "tsf"
require "minitest/autorun"

class ModelTest < Minitest::Test

  def test_load_tsf
    # Load the TSF file
    data = File.read("test/fixtures/basic_file.tsf")

    # Parse the TSF data
    vector = Tsf::Vector.load_tsf(data)

    # Check if the vector object is loaded
    assert vector.loaded, "Vector object should be loaded"
    assert vector.grouped_data, "Grouped data should be present"
    assert vector.polygons, "Polygons should be present"
    assert vector.headers, "Headers should be present"

    # Check if the header information is present
    assert_equal vector.material_group, "Acrylic"
    assert_equal vector.material_name, "3mm Acrylic"
    assert_equal vector.job_name, "ISAAC BONORA black monochrome"
    assert_equal vector.job_number, "1234"
    assert_equal vector.resolution, 500
    assert_equal vector.size, [52.02, 292.05]
    # basic file has no bitmap
    assert_nil vector.bitmap

    # Check if the polygons are present
    assert vector.polygons.any?, "Polygons should be present"

  end

  def test_polygon_data
    # Load the TSF file
    data = File.read("test/fixtures/basic_file.tsf")

    # Parse the TSF data
    vector = Tsf::Vector.load_tsf(data)

    # Check if the polygons are present
    assert vector.polygons.any?, "Polygons should be present"
    assert_equal vector.polygons.size, 80, "There should be eighty polygon"

    # Check if the polygons are valid
    vector.polygons.each do |polygon|
      assert polygon.is_a?(Hash), "Polygon should be an hash"
      assert polygon.key?(:id), "Polygon should have a id"
      assert polygon.key?(:points), "Polygon should have points"
      assert polygon.key?(:color), "Polygon should have a color"
    end
  end

  def test_incomplete_data
    # Load the TSF file
    data = "<BegGroup: Header>\n<JobName: TestJob>\n<EndGroup: Header>"

    # Parse the TSF data
    

    # Check if the vector object is loaded
    assert_raises(ArgumentError, "Missing required variables: MaterialGroup, MaterialName, JobNumber, Resolution, Size") do
      Tsf::Vector.load_tsf(data)
    end

  end

  def test_empty_data
    # Load the TSF file
    data = ""

    # Parse the TSF data should raise argument error
    assert_raises(ArgumentError, "Data is empty. Please provide a valid TSF file.") do
      Tsf::Vector.load_tsf(data)
    end

  end
end