require 'mini_magick'

# Thumbnailize filter.
module Nanoc::Photomator::Thumbnailize

  class Filter < Nanoc::Filter

    identifier :thumbnailize
    type :binary

    # @param [Hash] params the options to create a thumbnail with.
    # @option params [String] :size the size of the thumbnail
    # @option params [Int] :quality the quality between 0-100 of the thumbnail
    #
    # :size can be either one of the followings:
    # - :sq small square 75x75
    # - :q  large square 150x150
    # - :t  thumbnail, 100 on longest side
    # - :s  small, 240 on longest side
    # - :n  small, 320 on longest side
    # - :m  medium, 500 on longest side
    # - :z  medium 640, 640 on longest side
    # - :c  medium 800, 800 on longest side
    # - :l  large, 1024 on longest side*
    # - :o  original image, either a jpg, gif or png, depending on source format
    def run(filename, params={})
      manipulate! do |image|
        case params[:size] || :t
          when :sq
            square image, 75, @item[:ROI]
          when :s
            square image, 100, @item[:ROI]
          when :t
            fit image, 100
          when :s
            fit image, 240
          when :n
            fit image, 320
          when :m
            fit image, 500
          when :z
            fit image, 640
          when :c
            fit image, 800
          when :l
            fit image, 1024
          #when /^\d+x\d+$/
          #  raise "Unsupported feature"
          else
            fit image, 2400
        end

        image.quality params[:quality].to_s if params[:quality]
      end
    end

    protected

    def manipulate!
      image = MiniMagick::Image.open(filename)
      yield(image)
      image.write(output_filename)
    rescue MiniMagick::Error, MiniMagick::Invalid => e
      raise "Failed to manipulate with MiniMagick, maybe it is not an image? Original Error: #{e}"
    end

    # Crop and resize an :image as a square thumbnail according
    # to a given :size and a :roi. The cropping and resizing will
    # be done so that to wrapper the :roi
    def square(image, size, roi)
      if roi
        rx = (roi[:x]*image[:width]).to_i
        ry = (roi[:y]*image[:height]).to_i
        rw = (roi[:w]*image[:width]).to_i
        rh = (roi[:h]*image[:height]).to_i
      else
        rx, ry, rw, rh = 0, 0, image[:width], image[:height]
      end

      cx, cy = rx + rw/2, ry + rh/2
      cw = ch = [size, [rw, rh].min].max

      image.crop "#{cw}x#{ch}+#{cx-cw/2}+#{cy-ch/2}"
      image.resize "#{size}x#{size}"
    end

    # Resize an :image to fit a :max size
    def fit(image, max)
      width, height = image[:width], image[:height]
      unless [width, height].max < max
        if width > height
          image.resize "#{max}x#{height*max/width}"
        else
          image.resize "#{width*max/height}x#{max}"
        end
      end
    end

  end
end