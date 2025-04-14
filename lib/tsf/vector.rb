module Tsf
  # Loads a TSF file and parses its content
  class Vector
    attr_reader :loaded, :grouped_data, :polygons, :headers
    attr_reader :material_group, :material_name, :job_name, :job_number, :resolution, :size, :bitmap

    # Initialize the Vector class
    def initialize
      @loaded = false
      @grouped_data = nil
      @polygons = []
      @headers = []

      ## Header information. Deconstructed.
      # Material settings for the job.
      @material_group = nil
      @material_name = nil

      # Job name as set in the Trotec software.
      @job_name = nil
      @job_number = nil

      # Usualy 500 DPI.
      @resoultion = nil
      # Will be set artboard size. when creating the tsf.
      @size = nil

      ## Image Data
      # Images in TSF files are stored as a monochrome bitmap.
      # The bitmap is used to determine the engraving area.
      # Image data, if present.
      @bitmap = nil

      #####

      # Minimum required variables to be present in the TSF file.
      # CamelCase
      @min_vars = ['MaterialGroup', 'MaterialName', 'JobName', 'JobNumber', 'Resolution', 'Size']
    end

    # Data is the raw data from the TSF file.
    # data = File.read('path/to/file.tsf')
    def self.load_tsf(data)
      vector = new
      if data.is_a?(String) 

        # Check if the data is empty
        if data.empty?
          raise ArgumentError, "Data is empty. Please provide a valid TSF file."
        end

        # Parse vector data
        vector.parse_tsf(data)
      else
        raise ArgumentError, "Expected a String, got #{data.class}"
      end
      vector
    end

  
    def parse_tsf(data)
      # Tsf files are text formatted files that repsresnte vector paths for a Troctec laser to follow. Similar to that of Gcode.
      # TSF file use a xml-like format the prefix "BegGroup" and "EndGroup" to denote the start and end of a group of commands or meta data.
      # TSF files are structed it to 4 top level groups.
      # - Header - Contains the header information of the file.
      # - JobMeta - Contains meta data about the job, such as the name, date, and other information.
      # - Bitmap - Contains the engraving data, such as the image to be engraved.
      # - DrawCommands - Contains the vector data, such as the paths to be followed by the laser.
      #     - contains many "DrawPolygon" commands, which are the actual vector paths to be followed by the laser.
      #     - Each "DrawPolygon" command contains a list of points, which are the coordinates of the points to be followed by the laser. Delimtited by a ;.
      #     - The first 4 digits of the command contain, ID, then R,G,B color values of the Polygon.

      @grouped_data = get_grouped_data(data)

      # Check if the grouped data has the required groups
      # A TSF file is not complete if it does not have a header and draw commands.
      unless @grouped_data.key?('Header') || @grouped_data.key?('DrawCommands')
        raise ArgumentError, "Invalid TSF data. Missing required groups core groups: Header, DrawCommands"
      end

      # Check if the grouped data has the required keys
      missing_headers = @min_vars - @grouped_data['Header'].keys
      if missing_headers.any?
        raise ArgumentError, "Invalid TSF data. Missing required headers: #{missing_headers.join(', ')}"
      end


      @material_group = @grouped_data['Header']['MaterialGroup']
      @material_name = @grouped_data['Header']['MaterialName']

      @job_name = @grouped_data['Header']['JobName']
      @job_number = @grouped_data['Header']['JobNumber']

      @resolution = @grouped_data['Header']['Resolution'].to_i
      @size = @grouped_data['Header']['Size'].split(";").map(&:to_f)

      @polygons = get_polygons(@grouped_data)

      @loaded = true
      @grouped_data
    end

    def get_grouped_data(data)
      # Groups are delimited by the "BegGroup" and "EndGroup" tags.
      # Each group contains a list of commands or meta data.
      # The normal groups are:
      # - Header
      # - JobMeta
      # - Bitmap (optional)
      # - DrawCommands

      # Auto create nested hash when accessed.
      nested_group_and_values = Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }
      # Typically, we only get 2 levels of groups. But we can have more.
      current_groups = []

      data.split("\n").each do |line|
        # a line is a command and a value. ie. <JobNumber: 1234> or <DrawPolygon: 12;0;1;2;3>
        # a line can define a group where value is the group name. ie. <BegGroup: Header> <EndGroup: Header>
        # groups can have groups (max 2.)
        # groups can have multple commands.
        # a command has only one value.

        command, value = line.split(":").map(&:strip).map { |s| s.gsub(/<|>/, '') }
        
        case command
        when "BegGroup"
          # Start a new group
          current_groups << value
        when "EndGroup"
          # End the current group
          current_groups.pop
        else
          # Assign the command and value to the appropriate group
          if current_groups.any?
            current = nested_group_and_values.dig(*current_groups)
            current[command] = value
          end
        end

      end
      nested_group_and_values
    end

    def get_polygons(grouped_data)
      polygons = []
      grouped_data['DrawCommands'].each do |key, value|
        polygon_string = value['DrawPolygon']
        polygon_array = polygon_string.split(";")

        polygon = {
          'id': polygon_array[0].to_i,
          'color': {
            'r': polygon_array[1].to_i,
            'g': polygon_array[2].to_i,
            'b': polygon_array[3].to_i,
          },
          'points': []
        }

        polygon[:data] = polygon_array.drop(4).map(&:to_i).each_slice(2).to_a

        polygons << polygon
      end
      polygons
    end
  end
end
