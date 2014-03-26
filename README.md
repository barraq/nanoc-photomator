nanoc-photomator
================

[Photomator](https://github.com/barraq/nanoc-photomator) provides a set of tools, filters and helpers to automate handling of photos and photosets in [Nanoc](http://nanoc.ws).

## Installation

`gem install nanoc-photomator`

## Usage

### Tools

[Photomator](https://github.com/barraq/nanoc-photomator) is thought to make the management of photosets easy. One of the nice features to have when manipulating photosets is to be able to generate for each photo a thumbnails according to some region of interest. In [Photomator](https://github.com/barraq/nanoc-photomator) the task of setting a region of interest (ROI) for each photo is automated using the following commands

    $ nanoc photomator roi --path content/photography/pictures/

Executing this command will open a minimalist graphical user interface (shown below) that will let you draw for each photo a region of interest. This ROI will then be stored in a metadata file. The metadata file is automatically created if it does not exist. In the meantime the GUI allows you to edit the metadata manually to add extra fields such as a *title*, a *description* etc.

![screenshot of photomator](https://raw.githubusercontent.com/barraq/nanoc-photomator/master/screenshots/photomator.png)

### Filters

#### Meta

```ruby
filter :meta
```

The filter **meta** can be used to filter-out metadata from a binary file
in order to use the metadata for some other purpose.

For instance it can be used to generate a preview page from a binary photo item with a simple rule:

```ruby
compile %r{/photography/pictures/.*}, :rep => :preview do
  filter :meta
  layout 'photography/preview'
end
```

#### Thumbnailize

```ruby
filter :thumbnailize
```

The filter **thumbnailize** is aimed to automate the generation of thumbnails.
It can take two optional parameters:
- *:size* which lets you choose between a predefined thumbnail size
- *:quality* which lets you choose the compression quality of the thumbnail.

The *:size* can be selected among [Flickr like sizes](https://www.flickr.com/services/api/flickr.photos.getSizes.html):
- :sq small square 75x75
- :q  large square 150x150
- :t  thumbnail, 100 on longest side
- :s  small, 240 on longest side
- :n  small, 320 on longest side
- :m  medium, 500 on longest side
- :z  medium 640, 640 on longest side
- :c  medium 800, 800 on longest side
- :l  large, 1024 on longest side*
- :o  original image, either a jpg, gif or png, depending on source format

A simple example:

```ruby
compile %r{/photography/pictures/.*}, :rep => :thumbnail do
  filter :thumbnailize, :size => :s, :quality => 60
end

compile %r{/photography/pictures/.*}, :rep => :default do
  filter :thumbnailize, :size => :o, :quality => 85
end
```

### Helpers

@todo