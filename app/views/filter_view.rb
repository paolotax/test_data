class FilterView < UIView
	
	stylesheet :nel_baule

	attr_accessor :delegate, :group_items

	def initWithFrame(frame)
    super.tap do
    	
    	@group_segment = subview(UISegmentedControl, :segmented_group).tap do |seg|
    		# seg.insertSegmentWithImage("96-book-black".uiimage, atIndex:0, animated:false)
    		# seg.insertSegmentWithImage("53-house-black".uiimage, atIndex:1, animated:false)
    		# seg.insertSegmentWithImage("83-calendar-black".uiimage, atIndex:2, animated:false)
    		# seg.insertSegmentWithImage("178-city-black".uiimage, atIndex:3, animated:false)
    	end
    	@group_segment.on(:change) do
    		changeGroupValue @group_segment
    	end
    	#subview(UILabel, :pino)
    end
  end

  def group_items=(group_items)
  	group_items.each_with_index do |item, index|
  		@group_segment.insertSegmentWithImage("#{item}".uiimage, atIndex:index, animated:false)
  	end
  end

  def changeGroupValue(sender)
  	@delegate.filterChange(sender)
  end


end