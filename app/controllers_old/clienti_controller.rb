class ClientiController < UITableViewController
  attr_accessor :delegate

  def viewDidLoad
    view.dataSource = view.delegate = self

    @searchBar ||= UISearchBar.alloc.initWithFrame(CGRectMake(0.0, 0.0, self.view.bounds.size.width, 44.0))
    @searchDisplayController ||= UISearchDisplayController.alloc.initWithSearchBar(@searchBar, contentsController:self).tap do |sc|
      sc.delegate = sc.searchResultsDataSource = sc.searchResultsDelegate = self
    end
    tableView.tableHeaderView = @searchBar
  end

  def viewWillAppear(animated)
    self.title = 'Clienti'
    
    navigationItem.leftBarButtonItem = editButtonItem
    navigationItem.rightBarButtonItem = UIBarButtonItemAdd.withTarget(self, action:'addCliente')

    self.contentSizeForViewInPopover = CGSizeMake(310.0, view.rowHeight*10)
   end
  
  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown
  end

  def addCliente
    #Store.shared.clear
    Store.shared.login( 
      lambda do
        puts "loggato"
        Store.shared.backend.getObjectsAtPath("api/v1/clienti",
                                parameters: nil,
                                success: lambda do |operation, result|
                                                  puts "Clienti: #{result.array.count}"
                                                  Cliente.reset
                                                  self.tableView.reloadData
                                                  self.addAppunti
                                                end,
                                failure: lambda do |operation, error|
                                                  puts error
                                                end)
      end
    )
    view.reloadData
  end

  def addAppunti
    Store.shared.backend.getObjectsAtPath("api/v1/appunti",
                                parameters: nil,
                                success: lambda do |operation, result|
                                                  puts "Appunti: #{result.array.count}"
                                                  self.addLibri
                                                end,
                                failure: lambda do |operation, error|
                                                  puts error
                                                end)
  end

  def addLibri
    Store.shared.backend.getObjectsAtPath("api/v1/libri",
                                parameters: nil,
                                success: lambda do |operation, result|
                                                  puts "Libri: #{result.array.count}"
                                                  self.addRighe
                                                end,
                                failure: lambda do |operation, error|
                                                  puts error
                                                end)
  end

  def addRighe
    Store.shared.backend.getObjectsAtPath("api/v1/righe",
                                parameters: nil,
                                success: lambda do |operation, result|
                                                  puts "Righe: #{result.array.count}"
                                                end,
                                failure: lambda do |operation, error|
                                                  puts error
                                                end)
  end

  def searchDisplayController(controller, shouldReloadTableForSearchString:searchString)
    Cliente.reset  
    @searchString = searchString
    true
  end

  def fetchControllerForTableView(tableView)
    if tableView == self.tableView then Cliente.controller else Cliente.searchController(@searchString) end
  end
  
  def numberOfSectionsInTableView(tableView)
    self.fetchControllerForTableView(tableView).sections.size
  end

  def tableView(tableView, titleForHeaderInSection:section)
    self.fetchControllerForTableView(tableView).sections[section].name
  end
  
  def tableView(tableView, numberOfRowsInSection:section)
    self.fetchControllerForTableView(tableView).sections[section].numberOfObjects
  end

  CellID = 'CellIdentifier'
  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier(CellID) || UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:CellID).tap do |c|
      c.accessoryType = UIDevice.ipad? ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator
    end
    
    cell.textLabel.text = self.fetchControllerForTableView(tableView).objectAtIndexPath(indexPath).nome
    cell
  end

  def tableView(tableView, commitEditingStyle:editingStyle, forRowAtIndexPath:indexPath)
    self.fetchControllerForTableView(tableView).objectAtIndexPath(indexPath).remove
    tableView.updates do
      if tableView.numberOfRowsInSection(indexPath.section) == 1
        tableView.deleteSections(NSIndexSet.indexSetWithIndex(indexPath.section), withRowAnimation:UITableViewRowAnimationFade)
      end
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:UITableViewRowAnimationFade)
    end
  end
  
  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)

    @delegate.openCliente(self.fetchControllerForTableView(tableView).objectAtIndexPath(indexPath))
    navigationController.pushViewController(@delegate, animated:true) unless UIDevice.ipad?
  end
end