require 'Qt'

module Nanoc
  module Photomator

    # ScrollArea zoom widget.
    class ScrollAreaZoomPadWidget < Qt::Widget

      signals 'onScaleToFit()'

      def initialize parent
        super parent
      end

      def mouseDoubleClickEvent e
        emit onScaleToFit
      end

      def paintEvent event
        painter = Qt::Painter.new self
        drawWidget painter
        painter.end
      end

      private

      def drawWidget painter
        painter.setRenderHint Qt::Painter::Antialiasing

        fg = Qt::Color.new 150, 150, 150
        bg = Qt::Color.new 255, 255, 255

        painter.setPen fg
        painter.setBrush Qt::Brush.new bg
        painter.drawEllipse 1, 1, width()-2, width()-2

        center = width()/2
        painter.setBrush Qt::Brush.new fg
        painter.drawEllipse center-1, center-1, 3, 3
      end
    end

    # Image interactor widget.
    class ImageInteractorWidget < Qt::Label

      #signals 'onRegionSelected(float, float, float, float)'
      signals 'onRegionSelected(QRectF)'

      def initialize parent = nil
        super parent

        @move = false

        setROI 0.0, 0.0, 1.0, 1.0

        setBackgroundRole Qt::Palette::Base
        setSizePolicy Qt::SizePolicy::Ignored, Qt::SizePolicy::Ignored
        setScaledContents true
      end

      def setROI x, y, width, height
        @roi = Qt::RectF.new x, y, width, height
        update
      end

      def mousePressEvent event
        @start = event.pos
      end

      def mouseMoveEvent event
        @move = true
        @current = event.pos
        update
      end

      def mouseReleaseEvent event
        @move = false
        @stop = event.pos

        top = [0.0, [@start.y, @stop.y].min/height.to_f].max
        left = [0.0, [@start.x, @stop.x].min/width.to_f].max
        bottom = [[@start.y, @stop.y].max/height.to_f, 1.0].min
        right = [[@start.x, @stop.x].max/width.to_f, 1.0].min

        setROI left, top, right-left, bottom-top

        emit onRegionSelected(@roi)
      end

      def paintEvent event
        super
        painter = Qt::Painter.new self
        drawROI painter
        painter.end
      end

      private

      def drawROI painter
        painter.setRenderHint Qt::Painter::Antialiasing

        fg = Qt::Color.new 150, 150, 150
        mv = Qt::Color.new 150, 0, 0
        bd = Qt::Color.new 0, 0, 0

        if @move
          painter.setPen mv
          painter.drawRect @start.x, @start.y, @current.x - @start.x, @current.y - @start.y
        else
          painter.setPen fg
          painter.drawRect @roi.x*width(), @roi.y*height(), @roi.width*width(), @roi.height*height()

          painter.setPen bd
          painter.drawRect @roi.x*width()-1, @roi.y*height()-1, @roi.width*width()+2, @roi.height*height()+2
          painter.drawRect @roi.x*width()+1, @roi.y*height()+1, @roi.width*width()-2, @roi.height*height()-2
        end
      end

    end

    # Image interactor container
    class ImageInteractorContainer < Qt::ScrollArea

      slots 'scaleToFit()'
      slots 'selectRegion(QRectF)'
      signals 'onUpdateROI(QRectF)'

      def initialize parent = nil
        super parent

        @imageInteractor = ImageInteractorWidget.new self
        setWidget @imageInteractor

        zoompad = ScrollAreaZoomPadWidget.new self
        setCornerWidget zoompad

        setWidgetResizable false
        setBackgroundRole Qt::Palette::Dark
        setVerticalScrollBarPolicy Qt::ScrollBarAlwaysOn

        connect(zoompad, SIGNAL('onScaleToFit()'), self, SLOT('scaleToFit()'))
        connect(@imageInteractor, SIGNAL('onRegionSelected(QRectF)'), self, SLOT('selectRegion(QRectF)'))
      end

      def preview image_path, roi={}
        @imageInteractor.setPixmap Qt::Pixmap.new image_path
        @imageInteractor.resize @imageInteractor.pixmap.size * 0.3
        @imageInteractor.setROI roi['x']||0.0, roi['y']||0.0, roi['w']||1.0, roi['h']||1.0
      end

      private

      def scaleToFit
        factor = [width/@imageInteractor.pixmap.width.to_f, height/@imageInteractor.pixmap.height.to_f].min
        @imageInteractor.resize @imageInteractor.pixmap.size * factor
      end

      def selectRegion roi
        emit onUpdateROI roi
      end
    end
  end
end