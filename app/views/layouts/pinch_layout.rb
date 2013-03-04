class PinchLayout < UICollectionViewFlowLayout
  
  def init
    super.tap do
      self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
      self.minimumLineSpacing = 10000.0
    end
  end

  def isDeletionModeOn
    # correggere conformsToProtocol con respond_to?
    # if (self.collectionView.delegate.class.conformsToProtocol(SpringboardLayoutDelegate)
    puts "PinchLayout isDeletionModeOn"
    return self.collectionView.delegate.isDeletionModeActiveForCollectionView(self.collectionView, layout:self)
    # end      
    # return false
  end  
  
  # UICollectionViewLayout
  
  def self.layoutAttributesClass
    SpringboardLayoutAttributes
  end
  
  def pinchedStackIndex
    @pinched_stack_index
  end
  
  def pinchedStackScale
    @pinched_stack_scale
  end
  
  def pinchedStackCenter
    @pinched_stack_center
  end
  
  def layoutAttributesForItemAtIndexPath(path)
    super.tap do |attrs|
      self.applySettingsToAttributes(attrs)
    end
  end
  
  def layoutAttributesForElementsInRect(rect)
    super.tap do |attrs|
      attrs.enumerateObjectsUsingBlock(lambda do |attributes, idx, stop|
                                                    self.applySettingsToAttributes(attributes)
                                                  end)
    end
  end

  # Properties

  def pinchedStackScale=(new_scale)
    @pinched_stack_scale = new_scale
    self.invalidateLayout
  end
      
  def pinchedStackCenter=(new_center)
    @pinched_stack_center = new_center
    self.invalidateLayout
  end
  
 
  def applySettingsToAttributes(attributes)
    
    indexPath = attributes.indexPath
    attributes.zIndex = -indexPath.item
    if pinchedStackCenter
      attributes.alpha = 1
      if self.isDeletionModeOn
        attributes.deleteButtonHidden = false
      else
        attributes.deleteButtonHidden = true
      end
      deltaX = pinchedStackCenter.x - attributes.center.x
      deltaY = pinchedStackCenter.y - attributes.center.y
      scale = 1.0 - pinchedStackScale;
      transform =  CATransform3DMakeTranslation(deltaX * scale, 0, 0.0)
      attributes.transform3D = transform
    else
      attributes.alpha = 0
    end  
  end

end




  