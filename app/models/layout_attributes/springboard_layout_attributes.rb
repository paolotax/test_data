class SpringboardLayoutAttributes < UICollectionViewLayoutAttributes
  
  attr_accessor :deleteButtonHidden
  
  def copyWithZone(zone)
    super.tap do |attrs|
      attrs.deleteButtonHidden = self.deleteButtonHidden
      attrs
    end
  end

  def isDeleteButtonHidden
    self.deleteButtonHidden
  end
end