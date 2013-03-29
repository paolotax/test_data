# -*- coding: utf-8 -*-
class AppuntoSmallCell < UITableViewCell

  attr_reader :appunto
  #attr_reader :data_label, :destinatario_label, :telefono_label, :note_label, :status_image
  
  def initWithStyle(style, reuseIdentifier: identifier)
    super.tap do
      selectionStyle = UITableViewCellSelectionStyleNone

      self.backgroundView = AppuntoSmallView.alloc.initWithFrame(self.frame)
      self.selectedBackgroundView = AppuntoSmallView.alloc.initWithFrame(self.frame)

      self.contentView.stylesheet = Teacup::Stylesheet[:appunto_style]
      layout(self.contentView, :content_view) do
        
        @data_label = subview(UILabel, :data)
        @destinatario_label = subview(UILabel, :destinatario)
        @note_label = subview(MTLabel, :note)
        @note_label.limitToNumberOfLines = true
        @note_label.resizeToFitText = true
        @status_image = subview(UIImageView, :status)
        subview(UIImageView, :frame)
      end
    end
  end

  def appunto=(appunto)
    @appunto = appunto
    @destinatario_label.text = @appunto.destinatario
    @note_label.text = "#{@appunto.note}"
    @status_image.setImage UIImage.imageNamed("task-#{@appunto.status}")
    @data_label.text = format_date(@appunto.created_at)
  end

  def layoutSubviews
    super
    #self.contentView.layer.sublayers[0].frame = self.contentView.bounds
    f = @note_label.frame
    h = self.class.note_height(@note_label.text, f.size.width)
    f = CGRectMake(f.origin.x, 40 + ((36 - h) / 2), f.size.width, h)
    @note_label.frame = f
  end

  def self.note_height(note, width)
    puts "note #{note}"
    @font ||= 'Cassannet Regular'.uifont(14)
    c = CGSizeMake(width, 36)
    s = note.sizeWithFont(@font, constrainedToSize: c)
    puts "note_height #{s.height} #{width}"
    s.height
  end

  private

    def format_date(date)
      formatter = NSDateFormatter.alloc.init
      formatter.setLocale(NSLocale.alloc.initWithLocaleIdentifier("it_IT"))
      if date.year == Time.now.year
        formatter.setDateFormat("d MMM")
      else
        formatter.setDateFormat("MMM yy")
      end
      date_str = formatter.stringFromDate(date)
      date_str
    end

end