# encoding: utf-8

usage 'exif [options]'
summary 'extract EXIF data from photos'
description <<-EOS
Go through all photos from a collection located at --path and extract
EXIF data. EXIF data is added in the metadata file associated to the photo under
the field 'EXIF'. If the metadata file does not exist for a given photo it then created.
EOS

option :p, :path, 'specify the path of the photo collection to process', :argument => :required

require 'exifr'
require 'nanoc/photomator/io'

module Nanoc::Photomator::Tasks

  class EXIF < ::Nanoc::CLI::CommandRunner

    def run
      # Make sure we are in a nanoc site directory
      require_site

      # Make sure the path exists
      path = options.fetch(:path)
      unless Dir.exist?(path)
        raise "Path #{path} does not exist!"
      end

      # Starting task
      puts "Starting EXIF task…"

      # get exif config if exists
      unless site.config[:photomator] and site.config[:photomator][:exif]
        raise "No config found for photomator::exif in config.yaml!"
      end

      exif_fields = site.config[:photomator][:exif]

      all_photos_and_metafile_at(path).each do |meta_filename, photo_filename|
        # load meta if exists
        meta = meta_from(meta_filename)

        puts meta
        next

        # load exif if possible
        exif = exif_from(photo_filename)

        unless exif
          puts "skipping #{meta_filename}, no EXIF data were found."
          next
        end

        # import selected exif fields
        meta[:exif] = {} unless meta[:exif]
        exif_fields.each do |field|
          meta[:exif][field.to_sym] = exif[field.to_sym]
        end

        # save exif to meta
        puts "saving EXIF data for #{photo_filename} to #{meta_filename}."
        save_meta_at(meta_filename, meta)
      end

      puts "done"
    end

    protected

    include Nanoc::Photomator::IO

    def exif_from(file_name)
      case File.extname(file_name)
        when '.jpg' then
          pics = EXIFR::JPEG.new(file_name)
        when '.tiff' then
          pics = EXIFR::TIFF.new(file_name)
        else
          pics = nil
      end

      pics.exif unless pics.nil? or not pics.exif?
    end

  end
end

runner Nanoc::Photomator::Tasks::EXIF