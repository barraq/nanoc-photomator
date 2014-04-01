module Nanoc
  module Photomator
  end
end

# version
require 'nanoc/photomator/version'

# ui
require 'nanoc/photomator/ui/widgets'
require 'nanoc/photomator/ui/roimator'

# filters
require 'nanoc/photomator/filters/meta'
require 'nanoc/photomator/filters/thumbnailize'

# cli integration
require 'nanoc/photomator/cli'