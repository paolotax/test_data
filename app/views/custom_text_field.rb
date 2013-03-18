class CustomTextField < UITextField

  def textRectForBounds(bounds)
    return CGRectInset(bounds, 5, 0)
  end

  def editingRectForBounds(bounds)
    return CGRectInset(bounds, 5, 0) 
  end

  def drawRect(rect)
    textFieldBackground = "text_field_tile_red.png".uiimage.resizableImageWithCapInsets(UIEdgeInsetsMake(15, 2, 15, 2))
    textFieldBackground.drawInRect(self.bounds)
  end

end