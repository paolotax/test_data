Teacup::Stylesheet.new(:nel_baule) do
  
  style :root,
    backgroundColor: '#f0f0f0'.uicolor,
    constraints: [:full]

  style :header_view,
    backgroundColor: '#7a7a7a'.uicolor,
    constraints: [
      :top_left,
      :full_width,
      constrain_height(50)
    ]

  style :table_view,
    separatorStyle: UITableViewCellSeparatorStyleNone,
    #separatorColor: '#c6c6c6'.uicolor,
    constraints: [
      :full_width,
      constrain_below(:header_view),
      constrain(:height).equals(:superview, :height).minus(50)
    ]
  
  style :table_view_background,
    backgroundColor: '#7a7a7a'.uicolor

  style :segmented_group,
    selectedSegmentIndex: 0,
    constraints: [
      constrain(:width).equals(:superview, :width).minus(40),
      :center_y, 
      :center_x, 
      constrain(:height).equals(:superview, :height).minus(12)
    ]

  style :pino,
    constraints: [
      constrain(:width).equals(:superview, :width).minus(40),
      constrain_below(:segmented_group).plus(6), 
      :center_x, 
      constrain_height(18)
    ]
end