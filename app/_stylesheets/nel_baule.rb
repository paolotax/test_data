# -*- encoding : utf-8 -*-
Teacup::Stylesheet.new(:nel_baule) do
  style :root,
    backgroundColor: '#f0f0f0'.uicolor,
    constraints: [:full]

  style :header_view,
    constraints: [
      :top_left,
      :full_width,
      constrain_height(73)
    ]

  style :table_view,
    separatorStyle: UITableViewCellSeparatorStyleNone,
    separatorColor: '#c6c6c6'.uicolor,
    constraints: [
      :full_width,
      :full_height
      # constrain_below(:header_view).minus(10),
      # constrain(:height).equals(:superview, :height).minus(63)
    ]
  style :table_view_background,
    backgroundColor: '#7a7a7a'.uicolor

end