class AppuntoFormController < UITableViewController

  attr_accessor :appunto, :cliente, 
                :presentedAsModal, :isNew, 
                :presentedInPopover, :presentedInDetailView, :saveBlock


  def viewDidLoad
    super
    puts "0. didLoad"
    puts Store.shared.stats
  end

  def viewWillAppear(animated)
    super
    puts "0. willAppear"
    puts Store.shared.stats

    view.reloadData   
    puts "1. reloadData"
    puts Store.shared.stats

    

    unless isNew?
      self.navigationItem.rightBarButtonItem = UIBarButtonItem.action {
        url = NSURL.URLWithString("http://youpropa.com/appunti/#{@appunto.remote_id}.pdf")
        UIApplication.sharedApplication.openURL(url)
      }
    end

    if presentedAsModal?
      self.navigationItem.setLeftBarButtonItem(UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemCancel, target:self, action:"cancel:"))
    end

    # non funzia
    #"NSManagedObjectContextObjectsDidChangeNotification".add_observer(self, "changes:")

    didChange = NSManagedObjectContextObjectsDidChangeNotification
    center = NSNotificationCenter.defaultCenter
    center.addObserver(self, 
              selector:"changes:",
                  name:didChange, 
                object:Store.shared.context)

    didSave = NSManagedObjectContextDidSaveNotification
    center.addObserver(self, 
              selector:"didSave:",
                  name:didSave,
                object:Store.shared.context)
  end

  def viewDidAppear(animated)
    self.contentSizeForViewInPopover = self.tableView.contentSize
  end


  def changes(sender)
    puts "---changes---"
    puts Store.shared.stats
    if presentedInPopover?
      "unallow_dismiss_popover".post_notification
    end
    self.navigationItem.setRightBarButtonItem(UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemDone, target:self, action:"save:"))
    self.navigationItem.setLeftBarButtonItem(UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemCancel, target:self, action:"cancel:"))
  end

  def didSave(sender)
    puts "---didSave---"
    puts Store.shared.stats
  end

  def viewWillDisappear(sender)
    super
    puts "---dismiss changes---"
    puts Store.shared.stats

    name = NSManagedObjectContextObjectsDidChangeNotification
    center = NSNotificationCenter.defaultCenter
    center.removeObserver(self, 
                     name:name, 
                   object:Store.shared.context)
  end



  # UITableViewDelegate

  def numberOfSectionsInTableView(tableView)
    4
  end

  def tableView(tableView, numberOfRowsInSection:section)
    if (section == 1)
       @appunto.righe.count + 1
    elsif section == 0
       6
    else
      1
    end
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    
    if indexPath.section == 0

      if indexPath.row == 2

        cellID = "noteCell"
        cell = tableView.dequeueReusableCellWithIdentifier(cellID) 
        cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleCustom, reuseIdentifier:cellID)
        field = cell.viewWithTag(1123)
        field.text = @appunto.note      
      
      else

        case indexPath.row
        when 0
          column = 'cliente_nome'
        when 1
          column = 'destinatario'
        when 3
          column = 'status'
        when 4
          column = 'email'
        when 5
          column = 'telefono'
        end

        cellID = "#{column}Cell"
        cell = tableView.dequeueReusableCellWithIdentifier(cellID) 
        cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleRightDetail, reuseIdentifier:cellID)
        
        value = @appunto.valueForKey(column)
        if column == 'status'
          value = value.split("_").join(" ")
        end
        cell.detailTextLabel.text = value
      end

    elsif indexPath.section == 1

      if indexPath.row == 0
        cellID = "addRigaCell"
        cell = tableView.dequeueReusableCellWithIdentifier(cellID) 
        cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cellID)
      else
        cellID = "rigaCell"
        cell = tableView.dequeueReusableCellWithIdentifier(cellID) 
        cell ||= RigaTableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cellID)
        cell.riga = @appunto.righe.objectAtIndex(indexPath.row - 1)
      end
    
    elsif indexPath.section == 2

      cellID = "addReminderCell"
      cell = tableView.dequeueReusableCellWithIdentifier(cellID) 
      cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleCustom, reuseIdentifier:cellID)
    
    elsif indexPath.section == 3

      cellID = "deleteCell"
      cell = tableView.dequeueReusableCellWithIdentifier(cellID) 
      cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleCustom, reuseIdentifier:cellID)
    
    end   
    cell
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    if indexPath.section == 0 && indexPath.row == 2
      97
    else
      44
    end
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
    tableView.deselectRowAtIndexPath(indexPath, animated:true)
    
    if indexPath.section == 3
      cell = tableView.cellForRowAtIndexPath(indexPath)
      @actionSheet = UIActionSheet.alloc.initWithTitle("Sei sicuro?",
                                              delegate:self,
                                          cancelButtonTitle:"Annulla",
                                          destructiveButtonTitle:"Elimina",
                                          otherButtonTitles:nil)

      @actionSheet.showFromRect(cell.frame, inView:self.view, animated:true)
      #appunto.remove
    end

  end


  def actionSheet(actionSheet, didDismissWithButtonIndex:buttonIndex)
    if buttonIndex != @actionSheet.cancelButtonIndex

      puts "elimina todo"

      #self.delegate playerDetailsViewController:self didDeletePlayer:self.playerToEdit
    end
    @actionSheet = nil
  end


  # segues
  
  def prepareForEditDestinatarioSegue(segue, sender:sender)
    editController = segue.destinationViewController
    editController.testo = @appunto.destinatario
    editController.setTextChangedBlock( lambda do |text, error|
        path = NSIndexPath.indexPathForRow(1, inSection:0)
        cell = self.tableView.cellForRowAtIndexPath(path)
        cell.detailTextLabel.setText(text)
        @appunto.destinatario = text
        return true
      end
    )
  end
 
  def prepareForEditNoteSegue(segue, sender:sender)
    editController = segue.destinationViewController
    editController.testo = @appunto.note
    editController.setTextChangedBlock( lambda do |text, error|
        path = NSIndexPath.indexPathForRow(2, inSection:0)
        cell = self.tableView.cellForRowAtIndexPath(path)
        temp = cell.viewWithTag(1123)
        temp.setText(text)
        @appunto.note = text
        return true
      end
    )
  end

  def prepareForEditEmailSegue(segue, sender:sender)
    editController = segue.destinationViewController
    editController.testo = @appunto.email
    editController.setTextChangedBlock( lambda do |text, error|
        path = NSIndexPath.indexPathForRow(4, inSection:0)
        cell = self.tableView.cellForRowAtIndexPath(path)
        cell.detailTextLabel.setText(text)
        @appunto.email = text
        return true
      end
    )
  end

  def prepareForEditTelefonoSegue(segue, sender:sender)
    editController = segue.destinationViewController
    editController.testo = @appunto.telefono
    editController.setTextChangedBlock( lambda do |text, error|
        path = NSIndexPath.indexPathForRow(5, inSection:0)
        cell = self.tableView.cellForRowAtIndexPath(path)
        cell.detailTextLabel.setText(text)
        @appunto.telefono = text
        return true
      end
    )
  end


  def prepareForEditStatoSegue(segue, sender:sender)
    statoController = segue.destinationViewController
    statoController.appunto = @appunto
    statoController.delegate = self
  end
  
  # editStatoController delegate
  def editStatoController(controller, didSelectStato:stato)
    @appunto.status = stato
    self.navigationController.popViewControllerAnimated(true)
  end


  def prepareForShowClienteSegue(segue, sender:sender)
    editController = segue.destinationViewController.visibleViewController
    editController.cliente = @appunto.cliente
  end

  def prepareForAddRigaSegue(segue, sender:sender)
    segue.destinationViewController.appunto = @appunto
  end

  def prepareForEditRigaSegue(segue, sender:sender)
    indexPath = self.tableView.indexPathForCell(sender)
    @riga = self.tableView.cellForRowAtIndexPath(indexPath).riga
    if @riga.remote_appunto_id != @appunto.remote_id 
      @riga.remote_appunto_id = @appunto.remote_id 
    end
    segue.destinationViewController.riga = @riga
    segue.destinationViewController.appunto = @appunto
  end

  def prepareForAddReminderSegue(segue, sender:sender)
    editController = segue.destinationViewController
    editController.appunto = @appunto
    editController.setReminderChangedBlock( lambda do |text, date, error|
        path = NSIndexPath.indexPathForRow(0, inSection:2)
        cell = self.tableView.cellForRowAtIndexPath(path)
        main_queue = Dispatch::Queue.main
        main_queue.async do
          cell.textLabel.setText(text)
        end
        return true
      end
    )
  end

  def prepareForSegue(segue, sender:sender)
    if segue.identifier.isEqualToString("editDestinatario") 
      self.prepareForEditDestinatarioSegue(segue, sender:sender)
    
    elsif segue.identifier.isEqualToString("editNote") 
      self.prepareForEditNoteSegue(segue, sender:sender)
    
    elsif segue.identifier.isEqualToString("editStato") 
      self.prepareForEditStatoSegue(segue, sender:sender)
    
    elsif segue.identifier.isEqualToString("editTelefono") 
      self.prepareForEditTelefonoSegue(segue, sender:sender)
    
    elsif segue.identifier.isEqualToString("editEmail") 
      self.prepareForEditEmailSegue(segue, sender:sender)  
    
    elsif segue.identifier.isEqualToString("showCliente") 
      self.prepareForShowClienteSegue(segue, sender:sender)
    
    elsif segue.identifier.isEqualToString("editRiga") 
      self.prepareForEditRigaSegue(segue, sender:sender)
    
    elsif segue.identifier.isEqualToString("addReminder") 
      self.prepareForAddReminderSegue(segue, sender:sender)
    
    elsif segue.identifier.isEqualToString("addRiga") 
      self.prepareForAddRigaSegue(segue, sender:sender)
    end
  end





  # save

  def save(sender)
    
    if @appunto.isUpdated
      @appunto.updated_at = Time.now
      puts "0. updated time"
      puts Store.shared.stats
    end
    

    Store.shared.save
    puts "1. save"
    puts Store.shared.stats

    Store.shared.persist
    puts "2. persist"
    puts Store.shared.stats
    
    self.appunto.save_to_backend  
    puts "3. backend"
    puts Store.shared.stats
    
    "appuntiListDidLoadBackend".post_notification
    "reload_appunti_collections".post_notification
    "allow_dismiss_popover".post_notification

    if presentedAsModal?
      puts "4. presentedAsModal"  
      puts Store.shared.stats
      self.dismissViewControllerAnimated(true, completion:nil)
    end
    
    if presentedInPopover?
      puts "4. presentedInPopover"  
      puts Store.shared.stats
      self.navigationController.popViewControllerAnimated(true)
    end

    if presentedInDetailView?
      puts "4. presentedInDetailView"
      puts Store.shared.stats
      puts "ce l'ho"
      self.navigationItem.title = "ce l'ho"
      self.navigationItem.leftBarButtonItem = UIBarButtonItem.imaged("38-house".uiimage) {

      }
      self.navigationItem.rightBarButtonItem = UIBarButtonItem.action {
        url = NSURL.URLWithString("http://youpropa.com/appunti/#{@appunto.remote_id}.pdf")
        UIApplication.sharedApplication.openURL(url)
      }
    end 
  end

  def cancel(sender)

    if isNew?
      puts "1. isNew = true"
      puts Store.shared.stats
      @appunto.remove
      puts "2. remove"
      puts Store.shared.stats
    else
      puts "1. update"
      puts Store.shared.stats
      Store.shared.context.rollback
      puts "2. rollback"
      puts Store.shared.stats
    end

    if presentedAsModal?
      puts "3. closemodal"
      puts Store.shared.stats
      self.dismissViewControllerAnimated(true, completion:nil)
    end

    if presentedInPopover?
      puts "3. pop navigation"
      puts Store.shared.stats
      "allow_dismiss_popover".post_notification
      self.navigationController.popViewControllerAnimated(true)
    end

    if presentedInDetailView?
      puts "3. reset detail view"
      puts Store.shared.stats
      self.navigationItem.title = "ce l'ho"
      self.navigationItem.leftBarButtonItem = UIBarButtonItem.imaged("38-house".uiimage) {

      }
      self.navigationItem.rightBarButtonItem = UIBarButtonItem.action {
        url = NSURL.URLWithString("http://youpropa.com/appunti/#{@appunto.remote_id}.pdf")
        UIApplication.sharedApplication.openURL(url)
      }
    end 

  end

  private

    def presentedAsModal?
      presentedAsModal == true
    end

    def isNew?
      isNew == true
    end

    def presentedInPopover?
      presentedInPopover == true
    end
    
    def presentedInDetailView?
      presentedInDetailView == true
    end

end