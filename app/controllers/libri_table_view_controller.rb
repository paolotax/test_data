class LibriTableViewController < UITableViewController
  
  extend IB

  attr_accessor :riga, :appunto
  attr_accessor :detailViewController

  outlet :searchBar

  def viewDidLoad
    super
    view.dataSource = view.delegate = self
  end

  def viewDidAppear(animated)
    super
    self.searchBar.becomeFirstResponder
  end

  def viewWillAppear(animated)
    super
  end

  # Storyboard methods
  def prepareForSegue(segue, sender:sender)

    if (self.searchDisplayController.isActive)
      indexPath = self.searchDisplayController.searchResultsTableView.indexPathForCell(sender)
      libro = self.searchDisplayController.searchResultsTableView.cellForRowAtIndexPath(indexPath).libro
    else
      indexPath = self.tableView.indexPathForCell(sender)
      libro = self.tableView.cellForRowAtIndexPath(indexPath).libro
    end  

    riga = Riga.add do |r|
      r.appunto = appunto
      r.remote_appunto_id = appunto.remote_id 
      r.libro = libro  
      r.libro_id = libro.LibroId
      r.titolo   = libro.titolo
      r.prezzo_copertina    = libro.prezzo_copertina
      r.prezzo_unitario     = libro.prezzo_consigliato
      r.prezzo_consigliato  = libro.prezzo_consigliato
      r.sconto   = 0
      r.quantita = 1
    end
    
    segue.destinationViewController.riga  = riga  
    segue.destinationViewController.appunto = appunto
  
  end

  def searchDisplayController(controller, shouldReloadTableForSearchString:searchString)
    Libro.reset  
    @searchString = searchString
    true
  end

  def fetchControllerForTableView(tableView)
    if tableView == self.tableView then Libro.controller else Libro.searchController(@searchString) end
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
    cell = self.tableView.dequeueReusableCellWithIdentifier("libroCell")
    cell ||= LibroCell.alloc.initWithStyle(UITableViewCellStyleDefault,
                                            reuseIdentifier:"libroCell")
    cell.libro = self.fetchControllerForTableView(tableView).objectAtIndexPath(indexPath)
    cell
  end



end
