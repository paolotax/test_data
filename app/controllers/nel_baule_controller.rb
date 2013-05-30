# -*- encoding : utf-8 -*-
class NelBauleController < UIViewController

  stylesheet :nel_baule

  PAGE_CLIENTI = 0
  PAGE_RIGHE   = 1
  PAGE_ADOZIONI = 2

  ORDER_LIBRO   = ["libro.titolo"]
  GROUP_LIBRO   = ["libro.titolo"]

  ORDER_TITOLO = ["libro.titolo", 
                  "classe.cliente.provincia", 
                  "classe.cliente.comune", 
                  "classe.cliente.ClienteId",
                  "classe.num_classe",
                  "classe.sezione"]
    
  GROUP_TITOLO  = ["libro.titolo"]



  attr_accessor :selected_page, :controller, :btnEsandi

  def init
    super.tap do
      load_data
      
      @selected_page = PAGE_CLIENTI

      @esandi   = false
      @group_by = GROUP_LIBRO
      @order_by = ORDER_LIBRO
      @status   = "da_fare"
      @sectionsOpened = []

    end
  end

  layout do

    @table_view = subview(UITableView, :table_view) do |view|
      view.backgroundView = subview(UIView, :table_view_background)
      view.tableFooterView = subview(UIView, :table_view_background)
    end
    @table_view.dataSource = self
    @table_view.delegate = self
    
    @header_view = subview(FilterView, :header_view)
    @header_view.delegate = self
    @header_view.group_items = ["53-house-black", 
                                "96-book-black", 
                                "76-baby-black"]


    @table_view.registerClass(RigaCell, forCellReuseIdentifier:"rigaCell")
    @table_view.registerClass(RigaHeaderView, forHeaderFooterViewReuseIdentifier:"rigaHeaderView")
    @table_view.sectionHeaderHeight = 44
    



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

  def filterChange(segmentedControl)
    @selected_page = segmentedControl.selectedSegmentIndex
    reload
  end
  
  def load_data
    
    @clienti = Cliente.nel_baule
    @appunti = Appunto.nel_baule
    @righe   = Riga.nel_baule

    # Mah!!!
    @grouped_baule = []
    @clienti.each do |cliente|
      @grouped_baule << { cliente: cliente }
      appunti = []
      appunti = @appunti.select {|a| a.cliente == cliente }
      appunti.each do |appunto|
        @grouped_baule << { appunto: appunto }
        appunto.righe.each do |riga|
          @grouped_baule << { riga: riga }
        end
        @grouped_baule << { totali: { totale_copie: appunto.totale_copie, totale_importo: appunto.totale_importo, telefono: appunto.telefono }}
      end
    end  
  end

  def load_righe
    @controller ||= begin
      context = Store.shared.context
      request = NSFetchRequest.alloc.init
      request.entity = NSEntityDescription.entityForName("Riga", inManagedObjectContext:context)
      
      pred = nil
      predicates = [] 
      predicates.addObject(NSPredicate.predicateWithFormat("appunto.cliente.nel_baule = 1"))
      predicates.addObject(NSPredicate.predicateWithFormat("appunto.status = 'da_fare' or appunto.status = 'preparato'"))

      pred = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
        
      request.predicate = pred
      request.sortDescriptors = @order_by.collect { |sortKey|
        NSSortDescriptor.alloc.initWithKey(sortKey, ascending:true)
      }
      
      error_ptr = Pointer.new(:object)
      @controller = NSFetchedResultsController.alloc.initWithFetchRequest(request, managedObjectContext:context, sectionNameKeyPath:"#{@group_by.firstObject}", cacheName:nil)      
      unless @controller.performFetch(error_ptr)
        raise "Error when fetching data: #{error_ptr[0].description}"
      end
      @controller
    end
  end

  def load_adozioni
    @controller ||= begin
      context = Store.shared.context
      request = NSFetchRequest.alloc.init
      request.entity = NSEntityDescription.entityForName("Adozione", inManagedObjectContext:context)

      pred = nil
      predicates = [] 
      predicates.addObject(NSPredicate.predicateWithFormat("classe.cliente.nel_baule = 1"))

      pred = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
        
      request.predicate = pred
      request.sortDescriptors = @order_by.collect { |sortKey|
        NSSortDescriptor.alloc.initWithKey(sortKey, ascending:true)
      }
      
      error_ptr = Pointer.new(:object)
      @controller = NSFetchedResultsController.alloc.initWithFetchRequest(request, managedObjectContext:context, sectionNameKeyPath:"#{@group_by.firstObject}", cacheName:nil)      
      unless @controller.performFetch(error_ptr)
        raise "Error when fetching data: #{error_ptr[0].description}"
      end
      @controller
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
    if @selected_page == PAGE_CLIENTI 
      
      load_data
      
      @table_view.reloadData
      @table_view.reloadSections(NSIndexSet.indexSetWithIndex(0), withRowAnimation:UITableViewRowAnimationFade)
      self.navigationItem.title = "#{@clienti.count} nel baule"
      self.navigationItem.rightBarButtonItem = nil
    
    elsif @selected_page == PAGE_RIGHE 
      
      @controller = nil
      @order_by = ORDER_LIBRO
      @group_by = GROUP_LIBRO
      load_righe
      
      @table_view.reloadData
      self.navigationItem.title = "#{@controller.fetchedObjects.valueForKeyPath("@sum.quantita").to_i} da consegnare"
      
      @btnEsandi = UIBarButtonItem.titled('esandi') do
        toggle_esandi self
      end
      self.navigationItem.rightBarButtonItem = @btnEsandi
    
    elsif @selected_page == PAGE_ADOZIONI
      
      @controller = nil
      
      @order_by = ORDER_TITOLO
      @group_by = GROUP_TITOLO
      
      load_adozioni

      @table_view.reloadData
      self.navigationItem.title = "#{@controller.fetchedObjects.valueForKeyPath("@count")} sezioni adottate"
      @btnEsandi = UIBarButtonItem.titled('esandi') do
        toggle_esandi self
      end
      self.navigationItem.rightBarButtonItem = @btnEsandi
    end

  end

  def toggle_esandi(sender)

    
    if @esandi == false
      setEsandiTutto
    else
      setComprimiTutto
    end
    
    reload  
  end

  def setEsandiTutto
    puts @btnEsandi
    @esandi = true
    @btnEsandi.title = 'contrai'
    @sectionsOpened.clear
    @controller.sections.each_with_index {|s, i| @sectionsOpened << i }
  end

  def setComprimiTutto
    @esandi = false
    @btnEsandi.title = 'esandi'
    @sectionsOpened.clear
  end


  #{{{ Table view delegate

  def numberOfSectionsInTableView(table_view)
    if @selected_page == PAGE_CLIENTI
      1
    elsif @selected_page == PAGE_RIGHE
      @controller.sections.size
    elsif @selected_page == PAGE_ADOZIONI
      @controller.sections.size
    end
  end

  def tableView(tableView, numberOfRowsInSection: section)
    if @selected_page == PAGE_CLIENTI
      @grouped_baule.size
    else
      isOpened = @sectionsOpened.include? section
      if isOpened == true
        @controller.sections[section].numberOfObjects
      else
        0
      end
    end       
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    
    if @selected_page == PAGE_CLIENTI

      item = @grouped_baule[indexPath.row].keys[0].to_s
      if item == "cliente"
        cell = tableView.dequeueReusableCellWithIdentifier("ClienteSmallCell") || ClienteSmallCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "ClienteSmallCell")
        cell.cliente = @grouped_baule[indexPath.row][:cliente]
      elsif item == "appunto"
        cell = tableView.dequeueReusableCellWithIdentifier("AppuntoSmallCell") || AppuntoSmallCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "AppuntoSmallCell")
        cell.appunto = @grouped_baule[indexPath.row][:appunto]      
      elsif item == "riga"
        cell = tableView.dequeueReusableCellWithIdentifier("RigaSmallCell") || RigaSmallCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "RigaSmallCell")

        cell.riga = @grouped_baule[indexPath.row][:riga]
      else
        cell = tableView.dequeueReusableCellWithIdentifier("TotaliSmallCell") || TotaliSmallCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "TotaliSmallCell")
        
        cell.fill(@grouped_baule[indexPath.row][:totali])
      end

    elsif @selected_page == PAGE_RIGHE
      cell = tableView.dequeueReusableCellWithIdentifier("rigaCell")
      cell.label = @controller.objectAtIndexPath(indexPath).appunto.cliente.nome
      cell.quantita = @controller.objectAtIndexPath(indexPath).quantita
    elsif @selected_page == PAGE_ADOZIONI
      cell = tableView.dequeueReusableCellWithIdentifier("rigaCell")
      cell.label = @controller.objectAtIndexPath(indexPath).classe.cliente.nome
      cell.label = "#{@controller.objectAtIndexPath(indexPath).classe.cliente.nome} #{@controller.objectAtIndexPath(indexPath).libro.sigla} #{@controller.objectAtIndexPath(indexPath).kit_1}"
      classe = @controller.objectAtIndexPath(indexPath).classe
      cell.quantita = "#{classe.num_classe} #{classe.sezione}"
    end
        
    cell
  end

  def tableView(table_view, heightForRowAtIndexPath: indexPath)
 
    if @selected_page == PAGE_CLIENTI
      
      item = @grouped_baule[indexPath.row].keys[0].to_s
      if item == "cliente"
        44
      elsif item == "appunto"
        75
      elsif item == "riga"
        25
      else
        42
      end    
    elsif @selected_page == PAGE_RIGHE
      44
    elsif @selected_page == PAGE_ADOZIONI
      44
    end

  end

  def tableView(tableView, heightForFooterInSection:section)
     # This will create a "invisible" footer
     return 0.01
  end
  
  def tableView(tableView, heightForHeaderInSection:section)
    if @selected_page == PAGE_CLIENTI
      0
    else
      44
    end
  end

  def tableView(tableView, viewForHeaderInSection:section)
    if @selected_page == PAGE_RIGHE
      sectionHeaderView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("rigaHeaderView")
      
      isOpened = @sectionsOpened.include?(section)
      sectionHeaderView.disclosureButton.selected = isOpened
      sectionHeaderView.titolo   = @controller.sections[section].name
      sectionHeaderView.quantita = @controller.sections[section].objects.valueForKeyPath("@sum.quantita").to_i.to_s
      
      sectionHeaderView.tintColor = UIColor.darkGrayColor    
      sectionHeaderView.section = section
      sectionHeaderView.delegate = self
      
      sectionHeaderView
    elsif @selected_page == PAGE_ADOZIONI
      sectionHeaderView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("rigaHeaderView")

      isOpened = @sectionsOpened.include? section
      sectionHeaderView.disclosureButton.selected = isOpened

      sectionHeaderView.titolo   = @controller.sections[section].name
      sectionHeaderView.quantita = @controller.sections[section].objects.valueForKeyPath("@count").to_i.to_s
      
      sectionHeaderView.tintColor = UIColor.darkGrayColor    
      sectionHeaderView.section = section
      sectionHeaderView.delegate = self
      
      sectionHeaderView
    end
  end

    
  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    item = @grouped_baule[indexPath.row].keys[0].to_s
    if item == "cliente"
      "pushClienteController".post_notification(self, cliente: @grouped_baule[indexPath.row][:cliente])
    elsif item == "appunto"
      "pushAppuntoController".post_notification(self, appunto: @grouped_baule[indexPath.row][:appunto])
    end
  end

  # def tableView(tableView, canEditRowAtIndexPath:indexPath)
  #   item = @grouped_baule[indexPath.row].keys[0].to_s
  #   if item == "cliente"
  #     true
  #   else
  #     false
  #   end
  # end

  # def tableView(tableView, commitEditingStyle:editing_style, forRowAtIndexPath:indexPath)
    
  #   if editing_style == UITableViewCellEditingStyleDelete

  #     cliente = @grouped_baule[indexPath.row][:cliente]
      
  #     cliente.nel_baule = 0
  #     cliente.update
  #     Store.shared.persist

  #     @grouped_baule.removeObjectAtIndex indexPath.row
       
  #     tableView.beginUpdates
  #     tableView.deleteRowsAtIndexPaths(NSArray.arrayWithObject(indexPath),withRowAnimation:UITableViewRowAnimationFade)
  #     tableView.endUpdates

  #     "baule_did_change".post_notification
  #     "reload_annotations".post_notification
  #   end
  # end


  # select rigaHeaderView delegates

  def rigaHeaderView(rigaHeaderView, sectionOpened:sectionOpened)

    @sectionsOpened << sectionOpened
    countOfRowsToInsert = @controller.sections[sectionOpened].numberOfObjects
    
    indexPathsToInsert = []
    for i in 0..countOfRowsToInsert-1 do
      indexPathsToInsert.addObject(NSIndexPath.indexPathForRow(i, inSection:sectionOpened))
    end

    insertAnimation = UITableViewRowAnimationTop

    @table_view.beginUpdates
    @table_view.insertRowsAtIndexPaths(indexPathsToInsert, withRowAnimation:insertAnimation)
    #@table_view.deleteRowsAtIndexPaths(indexPathsToDelete, withRowAnimation:deleteAnimation)
    @table_view.endUpdates

  end


  def rigaHeaderView(rigaHeaderView, sectionClosed:sectionClosed)

    @sectionsOpened.delete sectionClosed 

    countOfRowsToDelete = @controller.sections[sectionClosed].numberOfObjects

    indexPathsToDelete = []
    for i in 0..countOfRowsToDelete-1 do
      indexPathsToDelete.addObject(NSIndexPath.indexPathForRow(i, inSection:sectionClosed))
    end

    @table_view.deleteRowsAtIndexPaths(indexPathsToDelete, withRowAnimation:UITableViewRowAnimationTop)
  end

end