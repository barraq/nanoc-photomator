# MetaFilter filter.
#
# This filter can be used to filter-out metadata
# from a binary file in order to use these metadata
# for some other purpose.
#
# For instance it can be used
# to generate a page from a binary picture item:
#
#   compile %r{/photography/pictures/.*}, :rep => :preview do
#     filter :meta
#     layout 'photography/preview'
#   end
module Nanoc::Photomator::MetaFilter

  class Filter < Nanoc::Filter
    identifier :meta
    type :binary => :text

    def run(filename, params={})
      # do nothing !
    end
  end
end