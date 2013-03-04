class AppuntiController < UIViewController
  
  extend IB

  attr_accessor :refreshControl

  outlet :appuntiTableView, UITableView

  def viewDidLoad
    super
    @refreshControl = UIRefreshControl.alloc.init
    @refreshControl.addTarget(self, action:"loadFromBackend", forControlEvents:UIControlEventValueChanged)
    self.appuntiTableView.addSubview(refreshControl)

    self.navigationItem.rightBarButtonItem = self.editButtonItem

    self.appuntiTableView.registerClass(AppuntoCell, forCellReuseIdentifier:"appuntoCell")
  end

  def viewWillAppear(animated)
    super
    Appunto.reset
    self.appuntiTableView.reloadData
    "appuntiListDidLoadBackend".add_observer(self, :reload)
    "appuntiListErrorLoadBackend".add_observer(self, :errorLoad)
    "errorLogin".add_observer(self, :errorLoad)
  end

  def viewWillDisappear(animated)
    super
    "appuntiListDidLoadBackend".remove_observer(self, :reload)
    "appuntiListErrorLoadBackend".remove_observer(self, :errorLoad)
    "errorLogin".remove_observer(self, :errorLoad)
  end
  
  def reload
    Appunto.reset
    self.appuntiTableView.reloadData
    @refreshControl.endRefreshing
  end

  def errorLoad
    @refreshControl.endRefreshing
  end

  # Storyboard methods
  def prepareForSegue(segue, sender:sender)

    if (self.searchDisplayController.isActive)
      indexPath = self.searchDisplayController.searchResultsTableView.indexPathForCell(sender)
      appunto = self.searchDisplayController.searchResultsTableView.cellForRowAtIndexPath(indexPath).appunto
    else
      indexPath = self.appuntiTableView.indexPathForCell(sender)
      appunto = self.appuntiTableView.cellForRowAtIndexPath(indexPath).appunto
    end

    if segue.identifier.isEqualToString("displayAppunto")
      segue.destinationViewController.appunto = appunto

    elsif segue.identifier.isEqualToString("modalAppunto")
      segue.destinationViewController.visibleViewController.appunto = appunto
    end

  end

  def searchDisplayController(controller, shouldReloadTableForSearchString:searchString)
    Appunto.reset  
    @searchString = searchString
    true
  end

  def fetchControllerForTableView(tableView)
    if tableView == self.appuntiTableView then Appunto.controller else Appunto.searchController(@searchString) end
  end

  # UITableViewDelegate

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
    cell = self.appuntiTableView.dequeueReusableCellWithIdentifier("appuntoCell")
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    cell.appunto = self.fetchControllerForTableView(tableView).objectAtIndexPath(indexPath)
    cell
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    95
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
  
  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true) unless Device.ipad?
    cell = tableView.cellForRowAtIndexPath(indexPath)
    if Device.ipad?
      self.performSegueWithIdentifier("modalAppunto", sender:cell )
    else
      self.performSegueWithIdentifier("displayAppunto", sender:cell )
    end
  end

  # def tableView(tableView, commitEditingStyle:editing_style, forRowAtIndexPath:indexPath)
  #   if editing_style == UITableViewCellEditingStyleDelete
  #     editing_style = "UITableViewCellEditingStyleDelete"
  #     delete_appunto(self.tableView.cellForRowAtIndexPath(indexPath).appunto)
  #     @appunti.delete_at(indexPath.row)
  #     self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:UITableViewRowAnimationAutomatic)
  #   end
  # end

  # def delete_appunto(appunto)
  #   puts "Deleting cliente #{appunto.remote_id}"
  #   App.delegate.backend.deleteObject(appunto, path:nil, parameters:nil,
  #                             success: lambda do |operation, result|
  #                                         puts "deleted"  
  #                                      end,
  #                             failure: lambda do |operation, error|
  #                                               App.alert error.localizedDescription
  #                                             end)
  # end


  private

    def loadFromBackend
      Store.shared.login do
        Store.shared.backend.getObjectsAtPath("api/v1/appunti",
                                    parameters: nil,
                                    success: lambda do |operation, result|
                                                      "appuntiListDidLoadBackend".post_notification
                                                      "reload_appunti_collections".post_notification
                                                      @refreshControl.endRefreshing
                                                    end,
                                    failure: lambda do |operation, error|
                                                      "appuntiListDidLoadBackend".post_notification
                                                      App.alert("#{error.localizedDescription}")
                                                    end)
      end
    end


end