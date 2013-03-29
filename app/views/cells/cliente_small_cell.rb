class ClienteSmallCell < UITableViewCell

  attr_reader :cliente
  
  def initWithStyle(style, reuseIdentifier: identifier)
    super.tap do
      selectionStyle = UITableViewCellSelectionStyleNone

      self.backgroundView = ClienteSmallView.alloc.initWithFrame(self.frame)
      self.selectedBackgroundView = ClienteSmallView.alloc.initWithFrame(self.frame)

      self.contentView.stylesheet = Teacup::Stylesheet[:cliente_style]
      layout(self.contentView, :content_view) do
        @nome_label = subview(UILabel, :nome)
      end
    end
  end

  def cliente=(cliente)
    @cliente = cliente
    @nome_label.text = @cliente.nome
  end

  def layoutSubviews
    super
    #self.contentView.layer.sublayers[0].frame = self.contentView.bounds
  end

end