# encoding: utf-8

usage       'roi [options]'
summary     'set region of interest from photo collection'
description <<-EOS
Go through all photos from a collection located at --path and provide
a graphical user interface (GUI) to set region of interest (ROI) in each
photo. The ROI is added in the metadata file associated to the photo under
the field 'ROI'. If the metadata file does not exist of a given photo it
is then created.
EOS

option :p, :path,           'specify the path of the photo collection to process', :argument => :required

require 'Qt'

module Nanoc::Photomator::Tasks

  class ROI < ::Nanoc::CLI::CommandRunner
    def run
      puts "Starting ROI task…"

      path = options.fetch(:path)

      app = Qt::Application.new ARGV
      widget = Nanoc::Photomator::ROIMator.new path
      app.exec

      puts
      puts "ROI task completed"
    end
  end
end

runner Nanoc::Photomator::Tasks::ROI