require 'nanoc/photomator/io'

module Nanoc
  module Photomator
    class ROIMator < Qt::Widget

      slots 'prev()'
      slots 'next()'
      slots 'updateROI(QRectF)'

      def initialize(parent = nil, path)
        super parent

        @id = -1

        # check data
        unless File.directory?(path) and load_data(path)
          puts "No photos found at #{path}!"
          exit(0)
        end

        # init user interface
        init_ui
        resize 800, 600
        move 300, 300

        # bind events
        connect(@interactor, SIGNAL('onUpdateROI(QRectF)'), self, SLOT('updateROI(QRectF)'))
        connect(@nextButton, SIGNAL('clicked()'), self, SLOT('next()'))
        connect(@prevButton, SIGNAL('clicked()'), self, SLOT('prev()'))

        # preview next item
        preview next_item
        show
      end

      private

      include Nanoc::Photomator::IO

      def load_data(path)
        @items = all_photos_and_metafile_at(path).map do |meta_filename, photo_filename|
          { :meta_filename => meta_filename, :photo_filename => photo_filename }
        end

        not @items.empty?
      end

      def preview(item)
        meta = meta_from(item[:meta_filename])
        unless meta.empty?
          puts meta
          @meta_edit.setPlainText meta_as_string(meta)
        end

        roi = {'x' => 0.0, 'y' => 0.0, 'w' => 1.0, 'h' => 1.0}.update(meta['ROI'] || {})

        @interactor.preview item[:photo_filename], roi
      end

      def has_prev
        @id > 0
      end

      def prev_item
        if has_prev
          @id -= 1
        end

        @items[@id]
      end

      def prev
        if has_prev
          preview prev_item
          @nextButton.setEnabled true
        else
          @prevButton.setEnabled false
        end
      end

      def has_next
        @items.length - 1 > @id
      end

      def current_item
        @items[@id]
      end

      def next_item
        if has_next
          @id += 1
        end

        @items[@id]
      end

      def next
        if has_next
          preview next_item
          @prevButton.setEnabled true
        else
          @nextButton.setEnabled false
        end
      end

      def updateROI(roi)
        # get meta from edit
        meta = YAML.load(@meta_edit.plainText)
        meta['ROI'] = {'x' => roi.x, 'y' => roi.y, 'w' => roi.width, 'h' => roi.height}

        # save it to file
        save_meta_at(current_item[:meta_filename], meta)

        #update ui
        @meta_edit.setPlainText meta_as_string(meta)
      end

      def init_ui
        window_title = "Photomator::ROI"

        vbox = Qt::VBoxLayout.new self
        @interactor = ImageInteractorContainer.new self
        vbox.addWidget @interactor

        @meta_edit = Qt::TextEdit.new self
        vbox.addWidget @meta_edit

        hbox = Qt::HBoxLayout.new self
        @nextButton = Qt::PushButton.new 'next >'
        @prevButton = Qt::PushButton.new '< previous'
        @prevButton.setEnabled false
        hbox.addWidget @prevButton
        hbox.addWidget @nextButton
        vbox.addLayout hbox

        setLayout vbox
      end
    end
  end
end