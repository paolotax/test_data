class ClientiTableViewController < UITableViewController
  
  extend IB

  attr_accessor :refreshHeaderView, :detailViewController

  outlet :searchBar

  def viewDidLoad
    super
    view.dataSource = view.delegate = self
    setupPullToRefresh
    setupSearchBar
    if Device.ipad?
      self.detailViewController = self.splitViewController.viewControllers.lastObject.topViewController
    end
    true
  end

  def viewWillAppear(animated)
    super
    Cliente.reset
    view.reloadData
  end

  def setupPullToRefresh
    @refreshHeaderView ||= begin
      rhv = RefreshTableHeaderView.alloc.initWithFrame(CGRectMake(0, 0 - self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height))
      rhv.delegate = self
      rhv.refreshLastUpdatedDate    
      tableView.addSubview(rhv)
      rhv
    end
  end

  def setupSearchBar
    offset = CGPointMake(0, self.searchBar.frame.size.height)
    self.tableView.contentOffset = offset
  end

  def loadFromBackend
    Store.shared.backend.getObjectsAtPath("api/v1/clienti",
                                parameters: nil,
                                success: lambda do |operation, result|

                                                  Store.shared.save
                                                  Store.shared.persist

                                                  Cliente.reset
                                                  tableView.reloadData
                                                  doneReloadingTableViewData
                                                end,
                                failure: lambda do |operation, error|
                                                  puts error.localizedDescription
                                                end)
  end

  # Storyboard methods
  def prepareForSegue(segue, sender:sender)
    puts segue.identifier
    if segue.identifier.isEqualToString("displayCliente")

      if (self.searchDisplayController.isActive)
        indexPath = self.searchDisplayController.searchResultsTableView.indexPathForCell(sender)
        view.endEditing(true)
        cliente = self.searchDisplayController.searchResultsTableView.cellForRowAtIndexPath(indexPath).cliente
      else
        indexPath = self.tableView.indexPathForCell(sender)
        cliente = self.tableView.cellForRowAtIndexPath(indexPath).cliente
      end  
      if Device.ipad?
        segue.destinationViewController.visibleViewController.cliente = cliente
      else
        segue.destinationViewController.cliente = cliente
      end  
    end
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

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = self.tableView.dequeueReusableCellWithIdentifier("ClienteCell")
    cell ||= ClienteCell.alloc.initWithStyle(UITableViewCellStyleDefault,
                                            reuseIdentifier:"ClienteCell")
    
    cell.cliente = self.fetchControllerForTableView(tableView).objectAtIndexPath(indexPath)
    cell
  end

  def tableView(tableView, commitEditingStyle:editingStyle, forRowAtIndexPath:indexPath)
    # self.fetchControllerForTableView(tableView).objectAtIndexPath(indexPath).remove
    # tableView.updates do
    #   if tableView.numberOfRowsInSection(indexPath.section) == 1
    #     tableView.deleteSections(NSIndexSet.indexSetWithIndex(indexPath.section), withRowAnimation:UITableViewRowAnimationFade)
    #   end
    #   tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:UITableViewRowAnimationFade)
    # end
  end


  ## PullToRefresh 

  def reloadTableViewDataSource
    @reloading = true
  end
  
  def doneReloadingTableViewData
    @reloading = false
    @refreshHeaderView.refreshScrollViewDataSourceDidFinishLoading(self.tableView)
  end
  
  def scrollViewDidScroll(scrollView)
    @refreshHeaderView.refreshScrollViewDidScroll(scrollView)
  end
  
  def scrollViewDidEndDragging(scrollView, willDecelerate:decelerate)
    @refreshHeaderView.refreshScrollViewDidEndDragging(scrollView)
  end
  
  def refreshTableHeaderDidTriggerRefresh(view)
    self.reloadTableViewDataSource
    self.performSelector('loadFromBackend', withObject:nil, afterDelay:0)
  end
    
  def refreshTableHeaderDataSourceIsLoading(view)
    @reloading
  end
  
  def refreshTableHeaderDataSourceLastUpdated(view)
    NSDate.date
  end


end
