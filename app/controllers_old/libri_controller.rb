class LibriController < UITableViewController
  
  attr_accessor :libri

  def viewDidLoad
    view.dataSource = view.delegate = self

    search_bar = UISearchBar.alloc.initWithFrame([[0,0],[320,44]])
    search_bar.delegate = self
    view.addSubview(search_bar)
    view.tableHeaderView = search_bar

    load_libri
  end


  def load_libri 
    LibriStore.shared.backend.getObjectsAtPath("api/v1/libri",
                                parameters: nil,
                                success: lambda do |operation, result|
                                                  LibriStore.shared.libri = result.array
                                                  self.tableView.reloadData
                                                end,
                                failure: lambda do |operation, error|
                                                  puts error
                                                end)
    
  end




  def viewWillAppear(animated)
    navigationItem.title = 'Libri'
    navigationItem.leftBarButtonItem = editButtonItem
    navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemAdd, target:self, action:'addLibro')

    # The Add button is disabled by default, and will be enabled once the location manager is ready to return the current location.
    #navigationItem.rightBarButtonItem.enabled = false

  end

  def addLibro

    LibriStore.shared.add_libro do |libro|
      # We set up our new libro object here.
      #libro.LibroId = 1
      libro.titolo = "A Gino #{Time.now.strftime("%s")}"
      libro.prezzo_copertina = 10.2
      libro.prezzo_consigliato = 9.45
      libro.settore = "Scolastico"
      libro.save_to_backend
    end

    view.reloadData
  end

  def tableView(tableView, numberOfRowsInSection:section)
    LibriStore.shared.libri.size
  end

  CellID = 'CellIdentifier'
  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier(CellID) || UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier:CellID)
    libro = LibriStore.shared.libri[indexPath.row]

    cell.textLabel.text = libro.titolo
    cell.textLabel.adjustsFontSizeToFitWidth = true
    cell.detailTextLabel.text = "#{libro.LibroId}"
    # unless libro.prezzo_copertina.nil? || libro.prezzo_consigliato.nil?
    #   cell.detailTextLabel.text = "€ %0.2f - € %0.2f" % [libro.prezzo_copertina, libro.prezzo_consigliato]
    # end

    cell
  end

  def tableView(tableView, editingStyleForRowAtIndexPath:indexPath)
    UITableViewCellEditingStyleDelete
  end

  def tableView(tableView, commitEditingStyle:editingStyle, forRowAtIndexPath:indexPath)
    libro = LibriStore.shared.libri[indexPath.row]
    LibriStore.shared.remove_libro(libro)
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:UITableViewRowAnimationFade)
  end


  # UISearchBar methods
  def searchBar(searchBar, textDidChange:searchString)
    puts "textDidChange"
    self.filterLibriForTerm(searchString);
    true
  end

  def filterLibriForTerm(text)

    context = LibriStore.shared.objectStore.mainQueueManagedObjectContext

    LibriStore.shared.libri = []
    #@searchResults = NSMutableArray.alloc.init
    fetchRequest = NSFetchRequest.alloc.init
 
    # Define the entity we are looking for
    entity = NSEntityDescription.entityForName("Libro", inManagedObjectContext:context)
    fetchRequest.setEntity(entity)
 
    # Define how we want our entities to be sorted
    sortDescriptor = NSSortDescriptor.alloc.initWithKey("titolo", ascending:true)
    fetchRequest.setSortDescriptors([sortDescriptor])
  
    # If we are searching for anything...
    if (text.length != 0)
      # Define how we want our entities to be filtered
      predicate = NSPredicate.predicateWithFormat("(titolo CONTAINS[c] '#{text}') OR (settore CONTAINS[c] '#{text}')")
      fetchRequest.setPredicate(predicate)
    end
 
    error = Pointer.new(:object)
 
    # Finally, perform the load
    loadedEntities = context.executeFetchRequest(fetchRequest, error:error)
    LibriStore.shared.libri = loadedEntities
 
    self.tableView.reloadData
  end

  #   @searchResults = LibriStore.shared.libri.select do |c|
  #     index = "#{c.titolo}".downcase  
  #     condition = text.downcase
  #     index.include?( condition )
  #   end  
  #   view.reloadData
  # end


end