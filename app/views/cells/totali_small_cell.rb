class TotaliSmallCell < UITableViewCell

  attr_reader :importo_label, :copie_label, :telefono_label
  #attr_reader :data_label, :destinatario_label, :telefono_label, :note_label, :status_image
  
  def initWithStyle(style, reuseIdentifier: identifier)
    super.tap do
      selectionStyle = UITableViewCellSelectionStyleNone

      self.backgroundView = TotaliSmallView.alloc.initWithFrame(self.frame)
      self.selectedBackgroundView = TotaliSmallView.alloc.initWithFrame(self.frame)

      self.contentView.stylesheet = Teacup::Stylesheet[:appunto_style]
      layout(self.contentView, :content_view) do
        @telefono_label = subview(UILabel, :telefono)
        @importo_label = subview(UILabel, :importo)
        @copie_label   = subview(UILabel, :copie)
      end
    end
  end

  def fill(item)
    @telefono_label.text = "#{item[:telefono]}"
    
    if item[:totale_copie] > 0
      @importo_label.text = "€ #{item[:totale_importo].round(2)}"
      @copie_label.text   = "#{item[:totale_copie]}"
    else
      @importo_label.text = ""
      @copie_label.text   = ""
    end
  end

end