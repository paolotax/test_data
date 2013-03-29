class RigaSmallCell < UITableViewCell

  attr_reader :riga
  
  def initWithStyle(style, reuseIdentifier: identifier)
    super.tap do
      selectionStyle = UITableViewCellSelectionStyleNone
      
      self.backgroundView = RigaSmallView.alloc.initWithFrame(self.frame)
      self.selectedBackgroundView = RigaSmallView.alloc.initWithFrame(self.frame)

      self.contentView.stylesheet = Teacup::Stylesheet[:appunto_style]
      layout(self.contentView, :content_view) do
        @titolo_label = subview(UILabel, :titolo)
        @quantita_label = subview(UILabel, :quantita)
      end
    end
  end

  def riga=(riga)
    @riga = riga
    @titolo_label.text = @riga.libro.titolo
    @quantita_label.text = @riga.quantita.to_s
  end


end