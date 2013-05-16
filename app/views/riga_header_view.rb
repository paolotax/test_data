class RigaHeaderView < UITableViewHeaderFooterView
	
  attr_accessor :titolo, :quantita, :delegate, :section, :disclosureButton

  def initWithReuseIdentifier(reuseIdentifier)
    super.tap do      
      self.contentView.stylesheet = Teacup::Stylesheet[:appunto_style]
      layout(self.contentView, :content_view) do
        @disclosureButton = subview(UIButton, :disclosure_button)        
        @titolo_label   = subview(UILabel, :titolo_header)
        @quantita_label = subview(UILabel, :quantita_header)
        subview(UIImageView, :frame)

        tapGesture = UITapGestureRecognizer.alloc.initWithTarget(self, action:'toggleOpen:')
        self.addGestureRecognizer(tapGesture)
      end
    end
  end

  def titolo=(titolo)
    @titolo_label.text = titolo
  end

  def quantita=(quantita)
    @quantita_label.text = quantita
  end

  def toggleOpen(sender)   
    toggleOpenWithUserAction(true)
  end

  def toggleOpenWithUserAction(userAction)
    
    @disclosureButton.selected = !@disclosureButton.isSelected
    
    if (userAction)
      if (@disclosureButton.isSelected == true)
        if (self.delegate.respondsToSelector('rigaHeaderView:sectionOpened:'))
            self.delegate.rigaHeaderView(self, sectionOpened:self.section)
        end
      elsif (self.delegate.respondsToSelector('rigaHeaderView:sectionClosed:'))
        self.delegate.rigaHeaderView(self, sectionClosed:self.section)
      end
    end
  end


end