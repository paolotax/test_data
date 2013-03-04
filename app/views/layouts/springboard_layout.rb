class SpringboardLayout < UICollectionViewFlowLayout

  def init
    super.tap do
      self.itemSize = CGSize.new(230, 230)
      self.minimumInteritemSpacing = 10;
      self.minimumLineSpacing = 10;
      self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
      self.sectionInset = UIEdgeInsetsMake(32, 32, 32, 32);
    end  
  end

  def isDeletionModeOn

    # correggere conformsToProtocol con respond_to?
    puts "SpringboardLayout isDeletionModeOn"
    # if (self.collectionView.delegate.class.conformsToProtocol(SpringboardLayoutDelegate)
      return self.collectionView.delegate.isDeletionModeActiveForCollectionView(self.collectionView, layout:self)
    # end      
    # return false
  end  

  # def targetContentOffsetForProposedContentOffset(prop_content_offset, withScrollingVelocity:velocity)
  #   puts "delegato SWIPE"
  #   closest_page = (prop_content_offset.x / @page_size.width).round.to_i
  #   closest_page = 0 if closest_page < 0
  #   #closest_page = @page_count - 1 if closest_page >= @page_count
  #   CGPoint.new(closest_page * @page_size.width, prop_content_offset.y)
  # end

  def self.layoutAttributesClass
    SpringboardLayoutAttributes
  end

  def layoutAttributesForItemAtIndexPath(indexPath)
    attributes = super
    if self.isDeletionModeOn
      attributes.deleteButtonHidden = false
    else
      attributes.deleteButtonHidden = true
    end
    return attributes;
  end

  def layoutAttributesForElementsInRect(rect)
    attributesArrayInRect = super
    for attribs in attributesArrayInRect
      if self.isDeletionModeOn
        attribs.deleteButtonHidden = false
      else 
        attribs.deleteButtonHidden = true
      end
    end
    return attributesArrayInRect
  end


end
