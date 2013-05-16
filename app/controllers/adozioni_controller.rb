class AdozioniController < UIViewController

  extend IB

  outlet :tableView


  PER_TITOLO = ["libro.titolo", 
                 "classe.cliente.provincia", 
                 "classe.cliente.comune", 
                 "classe.cliente.ClienteId",
                 "classe.num_classe",
                 "classe.sezione"]
  
  PER_CLIENTE = ["classe.cliente.nome", 
                 "libro.titolo",
                 "classe.num_classe",
                 "classe.sezione"]


  def viewDidLoad
    super

    # frame = self.navigationController.view.bounds
    # frame.size.height -= 90 # 40 di navigation
    # frame.origin.y = 50
    # @tableView = UITableView.plain(frame)
    # @tableView.dataSource = @tableView.delegate = self
    # self.view.addSubview @tableView

    @tableView = self.tableView	  
    @tableView.registerClass(RigaCell, forCellReuseIdentifier:"rigaCell")
    @tableView.registerClass(RigaHeaderView, forHeaderFooterViewReuseIdentifier:"rigaHeaderView")
    @tableView.sectionHeaderHeight = 44
    
    @esandi   = false
    @group_by = PER_TITOLO

    #@status   = "da_fare"

    @sectionsOpened = []
    true
  end


  def viewWillAppear(animated)
    super
    reload
  end

  def viewWillDisappear(animated)
    super
  end
  
  def reload
    @controller = nil
    @sectionsOpened.clear
    @tableView.reloadData
    self.title = "Adozioni: #{@controller.fetchedObjects.valueForKeyPath("@count")}"
  end

  def fetchControllerForTableView(tableView)
    
    @controller ||= begin
      context = Store.shared.context
      request = NSFetchRequest.alloc.init
      request.entity = NSEntityDescription.entityForName("Adozione", inManagedObjectContext:context)

      pred = nil
      predicates = [] 
      
      if @status
        if @status == "consegnato"
          predicates << NSPredicate.predicateWithFormat("kit_1 = 'consegnato'")
          pred = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
        else
          predicates << NSPredicate.predicateWithFormat("kit_1 != 'consegnato' OR kit_1 == null")
          pred = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
        end
      end

      request.predicate = pred

      request.sortDescriptors = @group_by.collect { |sortKey|
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

  def toggle_esandi(sender)
    @esandi = @esandi == true ? false : true
    if @esandi == true
      sender.title = 'contrai'
    else
      sender.title = 'esandi'
    end
    reload
  end

  def groupSegmentSwitch(sender)
    
    segmentedControl = sender
    selectedSegment = segmentedControl.selectedSegmentIndex
    if (selectedSegment == 0)
      @group_by = PER_TITOLO
    elsif (selectedSegment == 1)
      @group_by = PER_CLIENTE
    end
    reload
  end

  def statusSegmentSwitch(sender)
    
    segmentedControl = sender
    selectedSegment = segmentedControl.selectedSegmentIndex

    if (selectedSegment == 0)
      @status = nil
    elsif (selectedSegment == 1)
      @status = ""
    elsif (selectedSegment == 2)
      @status = "consegnato"
    end
    reload
  end






  # tableView delegates

  def numberOfSectionsInTableView(tableView)
    self.fetchControllerForTableView(tableView).sections.size
  end
  
  def tableView(tableView, numberOfRowsInSection:section) 	
    isOpened = @sectionsOpened.include? section
    if isOpened == true || @esandi == true
      self.fetchControllerForTableView(tableView).sections[section].numberOfObjects
    else
      0
    end
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier("rigaCell")
    
    if @group_by == PER_TITOLO
      cell.label = @controller.objectAtIndexPath(indexPath).classe.cliente.nome
    else
      cell.label = @controller.objectAtIndexPath(indexPath).libro.titolo
    end

    classe = @controller.objectAtIndexPath(indexPath).classe
    cell.quantita = "#{classe.num_classe} #{classe.sezione}"
    cell
  end
    
  def tableView(tableView, viewForHeaderInSection:section)

    sectionHeaderView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("rigaHeaderView")

    isOpened = @sectionsOpened.include? section
    sectionHeaderView.disclosureButton.selected = isOpened

    sectionHeaderView.titolo   = self.fetchControllerForTableView(tableView).sections[section].name
    sectionHeaderView.quantita = self.fetchControllerForTableView(tableView).sections[section].objects.valueForKeyPath("@count").to_i.to_s
    
    sectionHeaderView.tintColor = UIColor.darkGrayColor    
    sectionHeaderView.section = section
    sectionHeaderView.delegate = self
    
    sectionHeaderView
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true) unless Device.ipad?
    if Device.ipad?
      adozione = @controller.objectAtIndexPath(indexPath)
      "pushClienteController".post_notification(self, cliente: adozione.classe.cliente)
    else
    end
  end

  # select rigaHeaderView delegates

  def rigaHeaderView(rigaHeaderView, sectionOpened:sectionOpened)

    @sectionsOpened << sectionOpened

    countOfRowsToInsert = self.fetchControllerForTableView(tableView).sections[sectionOpened].numberOfObjects
    
    indexPathsToInsert = []
    for i in 0..countOfRowsToInsert-1 do
      indexPathsToInsert.addObject(NSIndexPath.indexPathForRow(i, inSection:sectionOpened))
    end

    insertAnimation = UITableViewRowAnimationTop

    @tableView.beginUpdates
    @tableView.insertRowsAtIndexPaths(indexPathsToInsert, withRowAnimation:insertAnimation)
    #@tableView.deleteRowsAtIndexPaths(indexPathsToDelete, withRowAnimation:deleteAnimation)
    @tableView.endUpdates

  end


  def rigaHeaderView(rigaHeaderView, sectionClosed:sectionClosed)

    @sectionsOpened.delete sectionClosed 

    countOfRowsToDelete = self.fetchControllerForTableView(tableView).sections[sectionClosed].numberOfObjects

    indexPathsToDelete = []
    for i in 0..countOfRowsToDelete-1 do
      indexPathsToDelete.addObject(NSIndexPath.indexPathForRow(i, inSection:sectionClosed))
    end

    @tableView.deleteRowsAtIndexPaths(indexPathsToDelete, withRowAnimation:UITableViewRowAnimationTop)
  end


  
end