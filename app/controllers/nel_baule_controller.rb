# -*- encoding : utf-8 -*-
class NelBauleController < UIViewController

  stylesheet :nel_baule

  def init
    super.tap do
      load_data
    end
  end

  layout do
    @table_view = subview(UITableView, :table_view) do |view|
      view.backgroundView = subview(UIView, :table_view_background)
      view.tableFooterView = subview(UIView, :table_view_background)
    end
    @table_view.dataSource = self
    @table_view.delegate = self
    # @header_view = subview(RMIScheduleHeaderView, :header_view, {days: @days})
    # @header_view.buttons.each do |button|
    #   button.on(:touch) do
    #     @header_view.clear_selection
    #     button.selected = true
    #     @current_day = button.tag
    #     @grouped_baule = @schedule[@days[@current_day]]
    #     @table_view.reloadData
    #     @table_view.scrollToRowAtIndexPath([0, 0].nsindexpath, atScrollPosition: UITableViewScrollPositionTop, animated: true)
    #   end
    # end
    # @header_view.buttons.first.selected = true
  end

  def load_data
    @clienti = Cliente.nel_baule
    @appunti = Appunto.nel_baule
    @righe   = Riga.nel_baule

    # Mah!!!
    @grouped_baule = []
    @clienti.each do |cliente|
      @grouped_baule << cliente
      appunti = []
      appunti = @appunti.select {|a| a.cliente == cliente }
      appunti.each do |appunto|
        @grouped_baule << appunto
        appunto.righe.each do |riga|
          @grouped_baule << riga
        end
        @grouped_baule << { totale_copie: appunto.totale_copie, totale_importo: appunto.totale_importo, telefono: appunto.telefono }
      end
    end  
  end

  def viewWillAppear(animated)
    super
    self.navigationItem.title = "#{@clienti.count} nel baule"
    "baule_did_change".add_observer(self, :reload)
  end
  
  def viewWillDisappear(animated)
    super
    "baule_did_change".remove_observer(self, :reload)
  end
  
  def reload
    load_data
    @table_view.reloadData
    @table_view.reloadSections(NSIndexSet.indexSetWithIndex(0), withRowAnimation:UITableViewRowAnimationFade)
    self.navigationItem.title = "#{@clienti.count} nel baule"
  end


  #{{{ Table view delegate

  def numberOfSectionsInTableView(table_view)
    1
  end

  def tableView(tableView, numberOfRowsInSection: section)
    @grouped_baule.size
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    item = @grouped_baule[indexPath.row]
    if item.class == NSKVONotifying_Cliente_Cliente_
      cell = tableView.dequeueReusableCellWithIdentifier("ClienteSmallCell") || ClienteSmallCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "ClienteSmallCell")
      cell.cliente = @grouped_baule[indexPath.row]
    
    elsif item.class == Appunto_Appunto_
      cell = tableView.dequeueReusableCellWithIdentifier("AppuntoSmallCell") || AppuntoSmallCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "AppuntoSmallCell")

      cell.appunto = @grouped_baule[indexPath.row]
    
    elsif item.class == Riga_Riga_
      cell = tableView.dequeueReusableCellWithIdentifier("RigaSmallCell") || RigaSmallCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "RigaSmallCell")

      cell.riga = @grouped_baule[indexPath.row]
    else
      cell = tableView.dequeueReusableCellWithIdentifier("TotaliSmallCell") || TotaliSmallCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "TotaliSmallCell")
      
      cell.fill(item)
    end
    cell
  end

   def tableView(table_view, heightForRowAtIndexPath: indexPath)
    item = @grouped_baule[indexPath.row]
    if item.class == NSKVONotifying_Cliente_Cliente_ 
      44
    elsif item.class == Appunto_Appunto_
      75
    elsif item.class == Riga_Riga_
      25
    else
      42
    end
  end

  def tableView(tableView, heightForFooterInSection:section)
     # This will create a "invisible" footer
     return 0.01
  end

    
  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    item = @grouped_baule[indexPath.row]
    if item.class == NSKVONotifying_Cliente_Cliente_ 
      "pushClienteController".post_notification(self, cliente: item)
    end
  end

  def tableView(tableView, canEditRowAtIndexPath:indexPath)
    item = @grouped_baule[indexPath.row]
    if item.class == NSKVONotifying_Cliente_Cliente_ 
      true
    else
      false
    end
  end

  def tableView(tableView, commitEditingStyle:editing_style, forRowAtIndexPath:indexPath)
    item = @grouped_baule[indexPath.row]
    if editing_style == UITableViewCellEditingStyleDelete
      item.nel_baule = 0
      item.update
      Store.shared.persist
      "baule_did_change".post_notification
      "reload_annotations".post_notification
    end
  end

end