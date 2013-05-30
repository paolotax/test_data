class RigaCell < UITableViewCell


  attr_accessor :label, :quantita

  def initWithStyle(style, reuseIdentifier:reuseIdentifier)
  
    super.tap do |cell|
      
      frame = self.frame

      cell.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin
      
      @cliente_label = UILabel.alloc.initWithFrame([[6, 0], [frame.width - 46, frame.height]]).tap do |label|
        #label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont.boldSystemFontOfSize(18.0)
        label.textAlignment = UITextAlignmentLeft
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = UIColor.clearColor
        label.textColor = UIColor.darkGrayColor
        label.highlightedTextColor = UIColor.whiteColor
        cell.contentView.addSubview(label)
      end

      @copie_label = UILabel.alloc.initWithFrame([[frame.width - 46, 0], [40, frame.height]]).tap do |label|
        label.numberOfLines = 1
        label.font = UIFont.systemFontOfSize(20.0)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = UITextAlignmentRight
        label.backgroundColor = UIColor.clearColor
        label.textColor = UIColor.darkGrayColor
        label.highlightedTextColor = UIColor.whiteColor
        cell.contentView.addSubview(label)
      end

      cell.contentView.autoresizesSubviews = true

      cell.contentView.backgroundColor = UIColor.whiteColor

      cell.clipsToBounds = false
    end
  end
  
  def label=(label)
    @label = label
    @cliente_label.text = "#{@label}"
  end

  def quantita=(quantita)
    @quantita = quantita
    @copie_label.text = "#{@quantita}"
  end  

end