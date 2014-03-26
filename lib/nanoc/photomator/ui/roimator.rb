module Nanoc
  module Photomator
    class ROIMator < Qt::Widget

      slots 'prev()'
      slots 'next()'
      slots 'updateROI(QRectF)'

      def initialize parent = nil, path
        super parent

        @id = -1
        @path = path

        unless File.directory?(@path) and load_data
          exit(0)
        end
        init_ui

        resize 800, 600
        move 300, 300

        preview next_item

        connect(@interactor, SIGNAL('onUpdateROI(QRectF)'), self, SLOT('updateROI(QRectF)'))
        connect(@nextButton, SIGNAL('clicked()'), self, SLOT('next()'))
        connect(@prevButton, SIGNAL('clicked()'), self, SLOT('prev()'))

        show
      end

      private

      def updateROI roi

        metadata = YAML.load(@metaedit.plainText)
        metadata['ROI'] = {'x' => roi.x, 'y' => roi.y, 'w' => roi.width, 'h' => roi.height}

        File.open(metadata_path(@items[@id]), 'w') { |file| file.write(metadata.to_yaml.gsub(%r{\A---\n}, '')) }

        preview @items[@id]
      end

      def preview item
        metadata = {}

        if File.exists? metadata_path item
          metadata = (YAML::load_file metadata_path item) || {}
          @metaedit.setPlainText metadata.to_yaml.gsub(%r{\A---\n}, '')
        end

        roi = {'x' => 0.0, 'y' => 0.0, 'w' => 1.0, 'h' => 1.0}.update(metadata['ROI'] || {})

        @interactor.preview image_path(item), roi
      end

      def load_data
        @items = Dir.entries(@path).select { |f| File.extname(f) == '.jpg' }.map { |f| File.basename(f, '.*') }
        not @items.empty?
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

      def image_path item
        File.join(@path, item) + '.jpg'
      end

      def metadata_path item
        File.join(@path, item) + '.yaml'
      end

      def init_ui
        window_title = "Photomator::ROI"

        vbox = Qt::VBoxLayout.new self
        @interactor = ImageInteractorContainer.new self
        vbox.addWidget @interactor

        @metaedit = Qt::TextEdit.new self
        vbox.addWidget @metaedit

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