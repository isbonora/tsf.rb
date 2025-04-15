
module Tsf
  # Converts a TSF file to an SVG format
  module Convert
    class Svg
      def initialize(vector)
        @size = vector.size
        @resolution = vector.resolution
        @polygons = vector.polygons
        @bitmap = vector.bitmap
      end


      def convert()
        
        # Logic to convert TSF to SVG
        
        width = @size[0] * @resolution / 25.4
        height = @size[1] * @resolution / 25.4
        image = nil
        # Bitmap support
        if @bitmap
          require 'vips'
          require 'base64'
          
          # Decode the bitmap data from the custom format
          decoded_bitmap = @bitmap.b
          puts "Decoded bitmap data: #{decoded_bitmap[0..1000].force_encoding("ISO-8859-1").inspect}"
          # Convert BMP to PNG using ruby-vips
          bmp_image = Vips::Image.new_from_buffer(decoded_bitmap, "")
          png_data = bmp_image.write_to_buffer(".png")

          # Encode PNG to Base64
          encoded_image = Base64.encode64(png_data)
          image = "data:image/png;base64,#{encoded_image}"
        end

        svg = "<svg xmlns='http://www.w3.org/2000/svg' version='1.1' width='#{width}' height='#{height}'>"

        if image
          svg += "<image href='#{image}' width='#{width}' height='#{height}' />"
        end

        @polygons.each do |polygon|
          points = polygon[:points].each_slice(2).map { |x, y| "#{x},#{y}" }.join(" ")
          color = polygon[:color]
          svg += "<polygon points='#{points}' stroke='rgb(#{color[:r]}, #{color[:g]}, #{color[:b]})' fill='none' />"
        end
        svg += "</svg>"



        
        # test: save to local disk
        File.open("output.svg", "w") do |file|
          file.write(svg)
        end
        # Conversion logic goes here
      end
    end
  end
end